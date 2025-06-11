function [child1, child2] = crossover2(parent1, parent2)
    % Verificar que ambos padres tengan el mismo tamaño
    [rows, cols] = size(parent1);
    if ~isequal(size(parent1), size(parent2))
        error('Los padres deben tener las mismas dimensiones.');
    end
    
    % Inicializar los hijos
    child1 = zeros(rows, cols);
    child2 = zeros(rows, cols);
    
    % Itera sobre cada columna
    for col = 1:cols
        % Asegúrate de que el punto de corte es válido (al menos una fila en cada segmento)
        if rows > 1
            cut = randi([1, rows-1]);
        else
            cut = 1;  % Si solo hay una fila, el punto de corte es 1
        end
        
        % Intercambia las coordenadas hasta el punto de corte
        child1(1:cut, col) = parent1(1:cut, col);
        child1(cut+1:end, col) = parent2(cut+1:end, col);
        
        child2(1:cut, col) = parent2(1:cut, col);
        child2(cut+1:end, col) = parent1(cut+1:end, col);
    end
    
    % Asegurarse de que los hijos tengan columnas ortogonales
    child1 = repare2(child1);
    child2 = repare2(child2);
end
