% === CONFIGURACIÓN ===
database = "iris";  % como string, no char
archivo_mat = "results_" + database + "_2D.mat";
archivo_csv = database + ".csv";
           
metodo = 'GLDA';                       % método a graficar: 'LDA', 'PCA_LDA', etc.
modo = 'mediana';                      % opciones: 'mejor', 'peor', 'mediana'

% === CARGAR DATOS ===
load(archivo_mat, 'results');
D = readmatrix(archivo_csv);
features = D(:, 1:end-1);
labels = D(:, end);

% === EXTRAER ÍNDICE DE SILUETA TOTAL PARA TODAS LAS REPETICIONES ===
num_reps = numel(results);
sil_vals = NaN(num_reps, 1);

for i = 1:num_reps
    if isfield(results(i), metodo) && isfield(results(i).(metodo), 'status') && ...
            strcmp(results(i).(metodo).status, "ok")
        sil_vals(i) = results(i).(metodo).silhouette_total;
    end
end

% === SELECCIONAR REPETICIÓN SEGÚN MODO ===
switch lower(modo)
    case 'mejor'
        [~, rep_idx] = max(sil_vals);
    case 'peor'
        [~, rep_idx] = min(sil_vals);
    case 'mediana'
                % Ordenar valores válidos (sin NaN)
        sil_vals_valid = sil_vals(~isnan(sil_vals));
        
        if isempty(sil_vals_valid)
            error('No hay ejecuciones válidas para calcular la mediana.');
        end
        
        % Encontrar el valor mediano
        orden = sort(sil_vals_valid);
        mediana_val = orden(round((length(orden) + 1) / 2));
        
        % Buscar el índice original que tenga ese valor
        rep_idx = find(sil_vals == mediana_val, 1, 'first');
    otherwise
        error('Modo no reconocido. Usa "mejor", "peor" o "mediana".');
end

% === PROYECTAR Y GRAFICAR ===
P = results(rep_idx).(metodo).P;
Z = features * P;

% === SCATTER 2D ===
figure;
gscatter(Z(:,1), Z(:,2), labels);
title(sprintf('Proyección %s (%s, rep #%d)', metodo, modo, rep_idx), 'Interpreter', 'none');
xlabel('Componente 1');
ylabel('Componente 2');
grid on;
