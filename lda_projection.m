function [P, status, err_msg] = lda_projection(X, y, dim)
    % LDA con manejo de errores
    status = "ok";
    err_msg = "";
    P = [];

    try
        classes = unique(y);
        num_classes = numel(classes);
        [n_samples, n_features] = size(X);

        mu_global = mean(X, 1);
        S_W = zeros(n_features, n_features);
        S_B = zeros(n_features, n_features);

        for i = 1:num_classes
            idx = (y == classes(i));
            X_i = X(idx, :);
            mu_i = mean(X_i, 1);
            n_i = size(X_i, 1);

            S_W = S_W + (X_i - mu_i)' * (X_i - mu_i);
            mean_diff = (mu_i - mu_global)';
            S_B = S_B + n_i * (mean_diff * mean_diff');
        end

        % Revisión del rango de S_W
        if rank(S_W) < size(S_W, 1)
            status = "failed";
            err_msg = "S_W no es de rango completo. LDA no puede aplicarse.";
            return;
        end

        [V, D] = eig(S_B, S_W);
        [eigenvals, idx] = sort(diag(D), 'descend');
        V = V(:, idx);

        max_dim = num_classes - 1;
        max_dim = num_classes - 1;
        if dim > max_dim
            warning("LDA solo tiene %d dimensiones útiles (c - 1). Se devolverán %d componentes con autovalores nulos.", max_dim, dim);
        end
        P = V(:, 1:dim);  % Devolver lo que el usuario pidió



    catch ME
        P = [];
        status = "failed";
        err_msg = ME.message;
    end
end
