function [child1, child2] = crossover(parent1, parent2)
    [rows, cols] = size(parent1);
    
    %  hijos
    child1 = zeros(rows, cols);
    child2 = zeros(rows, cols);
    
    % Itera sobre cada columna
    for col = 1:cols
        % Selecciona un punto de corte aleatorio
        cut = randi([1, rows-1]);
        
        % Intercambia las coordenadas hasta el punto de corte
        child1(1:cut, col) = parent1(1:cut, col);
        child1(cut+1:end, col) = parent2(cut+1:end, col);
        
        child2(1:cut, col) = parent2(1:cut, col);
        child2(cut+1:end, col) = parent1(cut+1:end, col);
    end
    child1 = repare(child1);
    child2 = repare(child2);

end
