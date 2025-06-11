function selected_parents = binary_tournament_selection(population, num_parents)
    % BINARY_TOURNAMENT_SELECTION Selects parents using Binary Tournament Selection
    %
    % Parameters:
    %   population  - Structure with fields:
    %                 .individual (Nx1 cell array of individual vectors)
    %                 .fitness (Nx1 vector of fitness values)
    %   num_parents - Number of parents to select
    %
    % Output:
    %   selected_parents - Structure with the selected parents
    %                      (same structure as the population)

    % Extract the number of individuals
    num_individuals = length(population.fitness);

    % Initialize the selected parents structure
    selected_parents.individual = cell(num_parents, 1);
    selected_parents.fitness = zeros(num_parents, 1);

    % Perform binary tournament selection
    for i = 1:num_parents
        % Randomly select two individuals
        idx1 = randi(num_individuals);
        idx2 = randi(num_individuals);

        % Ensure idx1 and idx2 are different
        while idx1 == idx2
            idx2 = randi(num_individuals);
        end

        % Compare their fitness and select the one with higher fitness
        if population.fitness(idx1) >= population.fitness(idx2)
            winner_idx = idx1;
        else
            winner_idx = idx2;
        end

        % Store the selected parent
        selected_parents.individual{i} = population.individual{winner_idx};
        selected_parents.fitness(i) = population.fitness(winner_idx);
    end
end
