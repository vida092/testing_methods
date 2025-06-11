function mutant = mutate3(matrix, mutation_probability,best_fitnes)
    % Genera un número aleatorio entre 0 y 1
    r = rand;
    if best_fitnes<7
        angle =  pi/2 * rand(1, 1);
    else
        angle = pi/4* rand(1, 1);
        mutation_probability = 0.5*mutation_probability;
    end
    % Aplica mutación 
    if r < mutation_probability
        % Genera la matriz de rotación para el ángulo dado y un eje aleatorio
        R = [cos(angle) -sin(angle) ; sin(angle) cos(angle)];
        
        % Aplica la rotación a la matriz original
        mutant = matrix * R;
    else
        mutant = matrix;
    end
end