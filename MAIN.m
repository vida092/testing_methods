clear
clc
train_ratio = 0.7;
num_reps = 30;
methods = {'LDA','PCA_LDA','GLDA',  'GPDA'};
dim_target = 3;  % o 3
databases={'golub_cleaned'};

for db_idx = 1:length(databases)
    database = databases{db_idx};
    disp("Trabajando en base de datos " + database)
    
    % === 1. Cargar datos ===
    D = readmatrix(database);
    features = D(:, 1:end-1);
    labels = D(:, end);
    [m, n_total] = size(D);
    n = n_total - 1;
    classes = unique(labels);
    num_classes = numel(classes);
    
    % Inicializar estructura de resultados
    results = struct();

    for rep = 1:num_reps
        disp("Repetición #" + rep)

        % === 2. Split estratificado ===
        train_data = [];
        test_data = [];

        rng(rep);  % Control de aleatoriedad para reproducibilidad

        for i = 1:num_classes
            class = classes(i);
            class_indices = find(labels == class);
            num_samples = numel(class_indices);
            num_train_samples = round(train_ratio * num_samples);
            shuffled_indices = class_indices(randperm(num_samples));

            train_indices = shuffled_indices(1:num_train_samples);
            test_indices = shuffled_indices(num_train_samples + 1:end);

            train_data = [train_data; D(train_indices, :)];
            test_data = [test_data; D(test_indices, :)];
        end

        % Separar características y etiquetas
        X_train = train_data(:, 1:end-1);
        y_train = train_data(:, end);
        X_test = test_data(:, 1:end-1);
        y_test = test_data(:, end);

        % === 3. Aplicar cada método de proyección ===
        for m_idx = 1:length(methods)
            method_name = methods{m_idx};
            fprintf("Aplicando %s...\n", method_name)
            t_start=tic;

            % ---- Entrenar método sobre X_train ----
            % TODO: implementar cada método como función que retorna matriz de proyección P
            [P, convergence, status, err_msg] = compute_projection(method_name, X_train, y_train, dim_target);
            exec_time=toc(t_start);

            if status == "failed"
                warning("Fallo %s en repetición %d: %s", method_name, rep, err_msg);
                results(rep).(method_name).status = status;
                results(rep).(method_name).error_message = err_msg;
                continue;
            end


            % ---- Aplicar proyección ----
            Z_train = X_train * P;
            Z_test  = X_test * P;
            Z_total = [X_train; X_test] * P;  % o directamente: Z_total = features * P;
            
            % ---- Etiquetas para Z_total
            y_total = [y_train; y_test];  % o: y_total = labels;
            
            % ---- Evaluar desempeño ----
            sil_train  = compute_silhouette(Z_train, y_train);
            sil_test   = compute_silhouette(Z_test, y_test);
            sil_total  = compute_silhouette(Z_total, y_total);
            
            fisher_train = compute_fisher_criterion(Z_train, y_train);
            fisher_total = compute_fisher_criterion(Z_total, y_total);

            
            % ---- Guardar resultados ----
            results(rep).(method_name).silhouette_train = sil_train;
            results(rep).(method_name).silhouette_test  = sil_test;
            results(rep).(method_name).silhouette_total = sil_total;
            
            results(rep).(method_name).fisher_train = fisher_train;
            results(rep).(method_name).fisher_total = fisher_total;
            
            results(rep).(method_name).P = P;
            results(rep).(method_name).convergence = convergence;  % Puede ser [] o un vector
            results(rep).(method_name).execution_time = exec_time;


        end
    end

    % === 4. Guardar resultados por base de datos ===
    save("results_" + erase(database, ".csv") + "_"+ dim_target + "D.mat", "results")

end





