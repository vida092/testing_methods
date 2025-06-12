function J = compute_fisher_criterion(Z, y)
    % COMPUTE_FISHER_CRITERION
    % Calcula el índice de Fisher basado en determinantes en un espacio proyectado Z.
    % Z : matriz proyectada (muestras × dimensión reducida)
    % y : vector de etiquetas

    classes = unique(y);
    num_classes = numel(classes);
    [~, k] = size(Z);

    mu_global = mean(Z, 1);
    S_B = zeros(k, k);
    S_W = zeros(k, k);

    for i = 1:num_classes
        idx = (y == classes(i));
        Z_i = Z(idx, :);
        mu_i = mean(Z_i, 1);
        n_i = size(Z_i, 1);

        % Entre clases
        diff_mu = (mu_i - mu_global)';
        S_B = S_B + n_i * (diff_mu * diff_mu');

        % Dentro de clases
        Z_centered = Z_i - mu_i;
        S_W = S_W + (Z_centered') * Z_centered;
    end

    % === Versión basada en determinante ===
    if det(S_W) == 0
        J = 0;  % o muy pequeño, según prefieras
    else
        J = det(S_B) / det(S_W);
    end
end
