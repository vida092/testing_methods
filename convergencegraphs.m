% === Configuración ===
nombre_archivo = 'results_wine_3D.mat';  % Cambia según sea necesario
metodo = 'GLDA';  % Método a graficar

% === Cargar archivo .mat ===
load(nombre_archivo, 'results');

% === Extraer nombre base de datos y dimensión del archivo ===
tokens = regexp(nombre_archivo, 'results_(.+?)_(\dD)\.mat', 'tokens');
if ~isempty(tokens)
    nombre_bd = tokens{1}{1};
    dimension = tokens{1}{2};
else
    nombre_bd = 'Base desconocida';
    dimension = '??D';
end

% === Preparar figura ===
figure;
hold on;
title(['Convergence graph for: ', metodo, ' in ', upper(nombre_bd), ' (', dimension, ')'], 'FontSize', 10);
xlabel('Generationn');
ylabel('Fitness');
grid on;

% === Reunir curvas y fitness finales ===
curvas = {};
fitness_finales = [];

for rep = 1:length(results)
    if ~isfield(results(rep), metodo)
        continue;
    end
    r = results(rep).(metodo);
    if isfield(r, 'status') && strcmp(r.status, "failed")
        continue;
    end
    if isfield(r, 'convergence') && ~isempty(r.convergence)
        curvas{end+1} = r.convergence(:)';
        fitness_finales(end+1) = r.convergence(end);
    end
end

% === Identificar curvas destacadas ===
[fitness_ordenado, orden] = sort(fitness_finales);
idx_mejor = orden(end);
idx_peor = orden(1);
idx_mediana = orden(round(length(orden)/2));

% Inicializar handles de curvas destacadas
h_mejor = [];
h_peor = [];
h_mediana = [];

% === Graficar curvas ===
for i = 1:length(curvas)
    if i == idx_mejor
        h_mejor = plot(curvas{i}, 'r', 'LineWidth', 2.0);
    elseif i == idx_peor
        h_peor = plot(curvas{i}, 'b', 'LineWidth', 2.0);
    elseif i == idx_mediana
        h_mediana = plot(curvas{i}, 'g', 'LineWidth', 2.0);
    else
        p = plot(curvas{i}, 'k');
        p.Color(4) = 0.2;  % Transparencia para el resto
    end
end

% === Mostrar solo las curvas destacadas en la leyenda ===
legend([h_mejor, h_peor, h_mediana], {'Max', 'Min', 'Median'}, 'Location', 'best');

hold off;
