function mutatedMatrix = mutate2(matrix, probability)
    % Copia la matriz original para preservar su tamaño y estructura
    mutatedMatrix = matrix;
    % Genera un número aleatorio para decidir si se realiza el swap
    if rand() < probability
        % Selecciona dos filas distintas al azar
        numRows = size(matrix, 1);
        rows = randperm(numRows, 2);
        % Realiza el swap entre las filas seleccionadas
        tempRow = mutatedMatrix(rows(1), :);
        mutatedMatrix(rows(1), :) = mutatedMatrix(rows(2), :);
        mutatedMatrix(rows(2), :) = tempRow;
    end
end
% function mutatedMatrix = mutate2(matrix, probability)
% % MUTATE2 realiza swaps internos en cada fila de una matriz basado en una probabilidad.
% 
%     mutatedMatrix = matrix;
%     [numRows, numCols] = size(matrix);
% 
%     for i = 1:numRows
%         if rand() < probability
%             % Selecciona dos columnas diferentes al azar
%             cols = randperm(numCols, 2);
%             % Realiza el swap en la fila actual
%             temp = mutatedMatrix(i, cols(1));
%             mutatedMatrix(i, cols(1)) = mutatedMatrix(i, cols(2));
%             mutatedMatrix(i, cols(2)) = temp;
%         end
%     end
% end
