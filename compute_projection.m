function [P, convergence, status, err_msg] = compute_projection(method_name, X, y, dim_target)
    % Inicialización por defecto
    P = [];
    convergence = [];
    status = "ok";
    err_msg = "";

    try
        switch method_name
            case 'LDA'
                [P, status, err_msg] = lda_projection(X, y, dim_target);
                convergence = [];

            case 'PCA_LDA'
                [P, status, err_msg] = pca_lda_projection(X, y, dim_target);
                convergence = [];

            case 'GLDA'
                [P, convergence, status, err_msg] = glda(X, y, dim_target);

            case 'GPDA'
                [P, convergence] = gpda(X, y, dim_target);
                status = "ok";
                err_msg = "";

            otherwise
                status = "failed";
                err_msg = "Método no reconocido.";
        end

    catch ME
        % Captura de errores generales
        status = "failed";
        err_msg = sprintf("Error en %s: %s", method_name, ME.message);
        P = [];
        convergence = [];
    end
end
