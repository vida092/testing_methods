function fitness = fitness_function(w, SB, SW_Cl, criterion, d)
    % FITNESS_FUNCTION_SQUARE Calcula el criterio para individuos representados como vectores
    % que forman matrices cuadradas W de dimensión d x d.
    %
    % Parámetros:
    %   w         - Vector del individuo (1x(d^2))
    %   SB        - Matriz de dispersión entre clases (dxd)
    %   SW_Cl     - Matriz de dispersión intra-clase corregida (dxd)
    %   criterion - String: 'determinant' o 'trace' para elegir el criterio
    %   d         - Dimensión de las características originales (W será dxd)
    %
    % Salida:
    %   fitness   - Valor del criterio de aptitud

    % Verificar que la longitud del vector sea válida
    if length(w) ~= d^2
        error('La longitud del vector no coincide con las dimensiones esperadas (d^2).');
    end

    % Convertir el vector w en una matriz W de tamaño d x d
    W = reshape(w, [d, d]);

    % Proyectar las matrices de dispersión en el espacio transformado
    SB_proj = W' * SB * W;
    SW_proj = W' * SW_Cl * W;

    % Calcular fitness basado en el criterio seleccionado
    if strcmpi(criterion, 'determinant')
        % Determinante de las matrices proyectadas
        if det(SW_proj)~= 0;
            fitness = det(SB_proj) / det(SW_proj);
        else
            fitness = 0;
        end
    elseif strcmpi(criterion, 'trace')
        % Traza de las matrices proyectadas
        fitness = trace(SB_proj) / trace(SW_proj);
    else
        error('El criterio especificado debe ser "determinant" o "trace".');
    end
end

