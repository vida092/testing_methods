function matrix = generate_basis2(n)
    % Genera la primera columna con números aleatorios entre -8 y 8
    col1 = -8 + (16 * rand(n, 1));
    
    % Genera la segunda columna ortogonal a la primera
    % Hacemos una proyección de un vector aleatorio en el espacio ortogonal
    % a col1 y luego lo escalamos para tener números en el mismo rango
    col2_temp = -8 + (16 * rand(n, 1));  % Vector temporal aleatorio
    col2 = col2_temp - (dot(col2_temp, col1) / dot(col1, col1)) * col1;
    
    % Combinar las columnas en una matriz n x 2
    col1 = col1/norm(col1);
    col2 = col2/norm(col2);

    matrix = [col1, col2];

end