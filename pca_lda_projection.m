function P = pca_lda_projection(X, y, dim_target)
    % X: matriz de entrenamiento (muestras x características)
    % y: etiquetas
    % dim_target: dimensión final deseada (e.g., 2 o 3)

    [n_samples, n_features] = size(X);
    classes = unique(y);
    num_classes = numel(classes);
    
    % === 1. Calcular matriz de dispersión intra-clase S_W ===
    mu_global = mean(X, 1);
    S_W = zeros(n_features, n_features);

    for i = 1:num_classes
        Xi = X(y == classes(i), :);
        mu_i = mean(Xi, 1);
        S_W = S_W + (Xi - mu_i)' * (Xi - mu_i);
    end

    % === 2. Calcular el rango de S_W ===
    rank_SW = rank(S_W);

    % === 3. Aplicar PCA y reducir a rank_SW dimensiones ===
    % Centrado de datos
    X_centered = X - mean(X, 1);

    % Matriz de covarianza
    C = cov(X_centered);

    % Eigen-decomposition
    [U, D] = eig(C);
    [eigvals, idx] = sort(diag(D), 'descend');
    U = U(:, idx);

    % Tomar los vectores con valores propios más grandes (hasta el rango)
    P_pca = U(:, 1:rank_SW);  % d × r
    X_pca = X_centered * P_pca;  % m × r

    % === 4. Aplicar LDA sobre el espacio reducido ===
    P_lda = lda_projection(X_pca, y, dim_target);  % r × k

    % === 5. Componer la proyección total ===
    P = P_pca * P_lda;  % d × k
end
