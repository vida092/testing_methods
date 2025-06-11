% === Cargar dataset iris ===
load fisheriris  % Carga 'meas' (150x4) y 'species' (150x1 cell array)

X = meas;  % Características (150 x 4)
y = grp2idx(species);  % Convertir etiquetas a enteros 1,2,3

[m, n] = size(X);
dim = 2;  % Proyectamos a 2 dimensiones

% === Generar una matriz aleatoria de proyección ===
P = orth(randn(n, dim));  % Matriz ortonormal aleatoria (4 x 2)

% === Proyectar datos ===
Z = X * P;

% === Calcular índice de silueta con ambas funciones ===
s1 = compute_silhouette(Z, y);

% Empaquetar como D = [X y] para usar silhouetteFitness
D = [X, y];
s2 = silhouetteFitness(D, P);

% === Mostrar resultados ===
fprintf("Índice de silueta usando compute_silhouette: %.4f\n", s1);
fprintf("Índice de silueta usando silhouetteFitness : %.4f\n", s2);
