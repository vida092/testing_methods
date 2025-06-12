% === Configuración ===
databases = {'iris', 'wine', 'diabetes'};
dims = [2, 3];

for d = dims
    for db = databases
        filename = sprintf('results_%s_%dD.mat', db{1}, d);
        fprintf('Modificando archivo: %s\n', filename);
        load(filename, 'results');

        % Asumimos que la base original también está disponible como .csv o similar
        raw_data = readmatrix(db{1});
        features = raw_data(:, 1:end-1);
        labels = raw_data(:, end);
        classes = unique(labels);
        num_classes = numel(classes);
        train_ratio = 0.7;

        for rep = 1:length(results)
            % === Reconstruir X_train e y_train ===
            rng(rep);  % Control aleatorio reproducible
            train_data = [];

            for i = 1:num_classes
                class = classes(i);
                idx = find(labels == class);
                num_samples = numel(idx);
                num_train = round(train_ratio * num_samples);
                shuffled = idx(randperm(num_samples));

                train_idx = shuffled(1:num_train);
                train_data = [train_data; raw_data(train_idx, :)];
            end

            X_train = train_data(:, 1:end-1);
            y_train = train_data(:, end);

            % === Aplicar GLDA ===
            method = 'GLDA';
            tic;
            [P, convergence, status, err_msg] = compute_projection(method, X_train, y_train, d);
            exec_time = toc;

            if status == "failed"
                warning("Repetición %d falló para GLDA: %s", rep, err_msg);
                results(rep).(method).status = status;
                results(rep).(method).error_message = err_msg;
                continue;
            end

            % === Calcular desempeño ===
            Z_train = X_train * P;
            Z_test  = [];  % No se calcula aquí
            Z_total = features * P;
            y_total = labels;

            sil_train = compute_silhouette(Z_train, y_train);
            sil_total = compute_silhouette(Z_total, y_total);
            fisher_train = compute_fisher_criterion(Z_train, y_train);
            fisher_total = compute_fisher_criterion(Z_total, y_total);

            % === Guardar resultados ===
            results(rep).(method).P = P;
            results(rep).(method).convergence = convergence;
            results(rep).(method).execution_time = exec_time;
            results(rep).(method).silhouette_train = sil_train;
            results(rep).(method).silhouette_test  = NaN;  % No se reconstruye test
            results(rep).(method).silhouette_total = sil_total;
            results(rep).(method).fisher_train = fisher_train;
            results(rep).(method).fisher_total = fisher_total;
            results(rep).(method).status = status;
            results(rep).(method).error_message = err_msg;
        end

        % === Guardar archivo actualizado ===
        save(filename, 'results');
        fprintf('Archivo %s actualizado correctamente.\n\n', filename);
    end
end
