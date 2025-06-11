function P = lda_projection(X, y, dim)
    % X: matriz de entrenamiento (muestras x características)
    % y: vector de etiquetas
    % dim: dimensión objetivo para la proyección

    classes = unique(y);
    num_classes = numel(classes);
    [n_samples, n_features] = size(X);

    % === 1. Medias global y por clase ===
    mu_global = mean(X, 1);
    S_W = zeros(n_features, n_features);
    S_B = zeros(n_features, n_features);

    for i = 1:num_classes
        idx = (y == classes(i));
        X_i = X(idx, :);
        mu_i = mean(X_i, 1);
        n_i = size(X_i, 1);

        % Matriz de dispersión intra-clase (scatter dentro de la clase)
        S_W = S_W + (X_i - mu_i)' * (X_i - mu_i);

        % Matriz de dispersión entre clases (scatter entre clases)
        mean_diff = (mu_i - mu_global)';
        S_B = S_B + n_i * (mean_diff * mean_diff');
    end

    % === 2. Resolver el problema generalizado de eigenvalores ===
    if rank(S_W) < size(S_W, 1)
        error("S_W no es de rango completo. LDA no puede aplicarse.");
    end
    [V, D] = eig(S_B, S_W);  % S_B * v = λ * S_W * v
    [eigenvals, idx] = sort(diag(D), 'descend');
    V = V(:, idx);

    % === 3. Elegir las primeras dim direcciones
    max_dim = num_classes - 1;
    if dim > max_dim
        warning("dim = %d es mayor que c-1 = %d. Se ajustará automáticamente.", dim, max_dim);
        dim = max_dim;
    end

    P = V(:, 1:dim);  % Matriz de proyección final (d × k)
end
