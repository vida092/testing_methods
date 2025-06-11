function [SB, SW_Cl] = compute_scatter_matrices(X, labels)
    % COMPUTE_SCATTER_MATRICES Calcula S_B y S_W,Cl para una base de datos fija
    %
    % Parámetros:
    %   X      - Matriz de datos (NxD, N muestras de dimensión D)
    %   labels - Vector de etiquetas de las muestras (Nx1)
    %
    % Salidas:
    %   SB     - Matriz de dispersión entre clases
    %   SW_Cl  - Matriz de dispersión intra-clase corregida

    % Identificar las clases únicas
    classes = unique(labels);
    C = numel(classes); % Número de clases
    [N, D] = size(X);   % N: muestras, D: dimensión de las características

    % Calcular la media global
    mu_global = mean(X, 1); % Media global (1xD)

    % Inicializar matrices
    SB = zeros(D, D);
    SW_Cl = zeros(D, D);

    % Calcular dispersión para cada clase
    for i = 1:C
        % Extraer datos de la clase i
        class_data = X(labels == classes(i), :); % Muestras de la clase i
        n_i = size(class_data, 1);              % Número de muestras en la clase i
        mu_i = mean(class_data, 1);             % Media de la clase i (1xD)

        % Sumar a S_B (dispersión entre clases)
        diff_mu = mu_i - mu_global;
        SB = SB + n_i * (diff_mu' * diff_mu);

        % Sumar a S_W,Cl (dispersión intra-clase)
        for j = 1:n_i
            diff_x = class_data(j, :) - mu_i;
            SW_Cl = SW_Cl + (diff_x' * diff_x);
        end
    end
end
