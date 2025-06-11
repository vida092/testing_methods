function [offspring1, offspring2] = crossover_and_mutation(parent1, parent2, crossover_prob)
    % CROSSOVER_AND_MUTATION Realiza cruza y mutaciones específicas
    %
    % Parámetros:
    %   parent1        - Vector del primer padre
    %   parent2        - Vector del segundo padre
    %   crossover_prob - Probabilidad de cruza (base para las mutaciones)
    %
    % Salidas:
    %   offspring1     - Primer descendiente resultante
    %   offspring2     - Segundo descendiente resultante

    % Verificar que los padres tengan el mismo tamaño
    if length(parent1) ~= length(parent2)
        error('Los padres deben tener la misma longitud.');
    end

    % Tamaño del vector
    vector_length = length(parent1);

    % Cruza: Seleccionar un punto aleatorio y combinar los padres
    crossover_point = randi([1, vector_length-1]);
    offspring1 = [parent1(1:crossover_point), parent2(crossover_point+1:end)];
    offspring2 = [parent2(1:crossover_point), parent1(crossover_point+1:end)];

    % Probabilidades específicas de las mutaciones
    random_mut_prob = 0.25 * crossover_prob;
    swap_mut_prob = 0.25 * crossover_prob;
    creep_mut_prob = 0.30 * crossover_prob;
    scramble_mut_prob = 0.20 * crossover_prob;

    % Aplicar mutaciones a los descendientes
    offspring1 = apply_mutations(offspring1, random_mut_prob, swap_mut_prob, creep_mut_prob, scramble_mut_prob);
    offspring2 = apply_mutations(offspring2, random_mut_prob, swap_mut_prob, creep_mut_prob, scramble_mut_prob);
end

function offspring = apply_mutations(offspring, random_mut_prob, swap_mut_prob, creep_mut_prob, scramble_mut_prob)
    % MUTACIÓN ALEATORIA
    if rand() < random_mut_prob
        index = randi(length(offspring));
        offspring(index) = rand(); % Cambiar a un valor aleatorio
    end

    % SWAP-MUTATION
    if rand() < swap_mut_prob
        indices = randperm(length(offspring), 2);
        offspring([indices(1), indices(2)]) = offspring([indices(2), indices(1)]); % Intercambiar valores
    end

    % CREEP-MUTATION
    if rand() < creep_mut_prob
        index = randi(length(offspring));
        creep_value = -0.2 + (0.4) * rand(); % Valor entre -0.2 y 0.2
        offspring(index) = offspring(index) + creep_value;
    end

    % SCRAMBLE-MUTATION
    if rand() < scramble_mut_prob
        offspring = -1 + 2 * rand(size(offspring)); % Reconfigurar completamente
    end
end

