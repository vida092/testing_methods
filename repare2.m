function matrix = repare2(matrix)

    if size(matrix, 2) ~= 2
        error('La matriz debe tener exactamente dos columnas.');
    end
    
    col1 = matrix(:, 1);
    col2 = matrix(:, 2);
    

    col2 = col2 - (dot(col2, col1) / dot(col1, col1)) * col1;
    

    matrix(:, 2) = col2;
end
