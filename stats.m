% === Archivo a analizar ===
archivo = 'results_iris_2D.mat';  % Cambiar por el deseado
load(archivo);  % Debe cargar la variable 'results'

num_reps = numel(results);
metodos = fieldnames(results(1));
n_met = numel(metodos);

% === Tabla de resumen ===
tabla = table('Size', [n_met, 15], ...
    'VariableTypes', repmat("double", 1, 15), ...
    'VariableNames', {
        'sil_train_mean', 'sil_train_std', 'sil_train_min', 'sil_train_max', 'sil_train_median', ...
        'sil_total_mean', 'sil_total_std', 'sil_total_min', 'sil_total_max', 'sil_total_median', ...
        'fisher_train_mean', 'fisher_train_std', 'fisher_total_mean', 'fisher_total_std', ...
        'execution_time_mean'
    });
tabla.Properties.RowNames = metodos;

% === Inicializar convergencia ===
colores = lines(n_met);  % Paleta de colores
figure;
hold on;
legend_items = {};

for m = 1:n_met
    metodo = metodos{m};
    
    sil_train = NaN(num_reps, 1);
    sil_total = NaN(num_reps, 1);
    fisher_train = NaN(num_reps, 1);
    fisher_total = NaN(num_reps, 1);
    tiempo = NaN(num_reps, 1);

    curvas_convergencia = [];

    for rep = 1:num_reps
        r = results(rep).(metodo);
        if isfield(r, 'status') && strcmp(r.status, "failed")
            continue;
        end
        sil_train(rep) = r.silhouette_train;
        sil_total(rep) = r.silhouette_total;
        fisher_train(rep) = r.fisher_train;
        fisher_total(rep) = r.fisher_total;
        tiempo(rep) = r.execution_time;

        if isfield(r, 'convergence') && ~isempty(r.convergence)
            curvas_convergencia = [curvas_convergencia; r.convergence(:)'];
        end
    end

    % === Estadísticas ===
    tabla{metodo, 'sil_train_mean'} = mean(sil_train, 'omitnan');
    tabla{metodo, 'sil_train_std'}  = std(sil_train, 'omitnan');
    tabla{metodo, 'sil_train_min'}  = min(sil_train, [], 'omitnan');
    tabla{metodo, 'sil_train_max'}  = max(sil_train, [], 'omitnan');
    tabla{metodo, 'sil_train_median'} = median(sil_train, 'omitnan');

    tabla{metodo, 'sil_total_mean'} = mean(sil_total, 'omitnan');
    tabla{metodo, 'sil_total_std'}  = std(sil_total, 'omitnan');
    tabla{metodo, 'sil_total_min'}  = min(sil_total, [], 'omitnan');
    tabla{metodo, 'sil_total_max'}  = max(sil_total, [], 'omitnan');
    tabla{metodo, 'sil_total_median'} = median(sil_total, 'omitnan');

    tabla{metodo, 'fisher_train_mean'} = mean(fisher_train, 'omitnan');
    tabla{metodo, 'fisher_train_std'}  = std(fisher_train, 'omitnan');
    tabla{metodo, 'fisher_total_mean'} = mean(fisher_total, 'omitnan');
    tabla{metodo, 'fisher_total_std'}  = std(fisher_total, 'omitnan');

    tabla{metodo, 'execution_time_mean'} = mean(tiempo, 'omitnan');

    % === Promedio de convergencia si existe ===
    if ~isempty(curvas_convergencia)
        curva_promedio = mean(curvas_convergencia, 1, 'omitnan');
        plot(curva_promedio, 'Color', colores(m,:), 'LineWidth', 1.5);
        legend_items{end+1} = metodo;
    end
end

% Mostrar tabla
disp(tabla)

% === Configuración del gráfico ===
xlabel('Generaciones');
ylabel('Fitness');
title('Curvas de convergencia promedio por método');
legend(legend_items, 'Location', 'best');
grid on;
hold off;
