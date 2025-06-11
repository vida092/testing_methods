function [P, convergence, status, err_msg] = compute_projection(method_name, X, y, dim)

    try
        switch method_name
            case 'LDA'
                P = lda_projection(X, y, dim);
                convergence = [];
                status = "ok";
                err_msg = "";

            case 'PCA_LDA'
                P = pca_lda_projection(X, y, dim);
                convergence = [];
                status = "ok";
                err_msg = "";

            case 'GLDA'          
                [P, convergence, status, err_msg] = glda(X, y, dim);

            case 'GPDA'
                disp("aplicando gpda")
                [P, convergence] = gpda(X, y, dim);
                status = "ok";
                err_msg = "";

            otherwise
                error("Método no reconocido: %s", method_name);
        end

    catch ME
        P = [];
        convergence = [];
        status = "failed";
        err_msg = ME.message;
    end
end
