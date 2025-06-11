function selected_indices = stochastic_universal_sampling(population, n)
    fitness_values = [population.fitness];
    
    % suma total de fitness
    total_fitness = sum(fitness_values);
    
    % probabilidades de selección
    selection_probabilities = fitness_values / total_fitness;
    
    % probabilidades acumuladas
    cumulative_probabilities = cumsum(selection_probabilities);
    
    % punto de inicio aleatorio entre 0 y 1/n
    start_point = rand / n;
    
    % Genera n puntos igualmente espaciados
    points = start_point + (0:(n-1))' / n;
    
    % Encuentra los índices de los individuos seleccionados
    selected_indices = zeros(n, 1);
    for i = 1:n
        selected_indices(i) = find(cumulative_probabilities >= points(i), 1, 'first');
    end
end
