function [best_individual, best_fitness, plot_line,siluete] = genetic_algorithm(csv_file, num_individuals, num_generations, crossover_prob)
    % Leer el archivo CSV y obtener características y etiquetas
    data = readmatrix(csv_file);
    X = data(:, 1:end-1);       % Características
    y = data(:, end);           % Etiquetas
    d = size(X, 2);             % Número de características

    % Inicialización
    plot_line = zeros(1, num_generations);
    population.individual = cell(num_individuals, 1);
    population.fitness = zeros(num_individuals, 1);
    siliuete = [];
    for i = 1:num_individuals
        population.individual{i} = rand(1, d^2);
    end

    % Calcular matrices de dispersión reales
    [SB, SW_Cl] = calculate_scatter_matrices(X, y);

    % Evaluar población inicial
    for i = 1:num_individuals
        population.fitness(i) = fitness_function(population.individual{i}, SB, SW_Cl, 'determinant', d);
    end

    % Evolución por generaciones
    for generation = 1:num_generations
        num_parents = 2;
        parents = binary_tournament_selection(population, num_parents);

        offspring.individual = cell(num_parents, 1);
        offspring.fitness = zeros(num_parents, 1);

        for i = 1:2:num_parents
            parent1 = parents.individual{i};
            parent2 = parents.individual{i+1};

            [offspring1, offspring2] = crossover_and_mutation(parent1, parent2, crossover_prob);

            offspring.individual{i} = offspring1;
            offspring.individual{i+1} = offspring2;

            offspring.fitness(i) = fitness_function(offspring1, SB, SW_Cl, 'determinant', d);
            offspring.fitness(i+1) = fitness_function(offspring2, SB, SW_Cl, 'determinant', d);
        end

        % Selección elitista
        combined_population.individual = [population.individual; offspring.individual];
        combined_population.fitness = [population.fitness; offspring.fitness];

        [~, idx] = sort(combined_population.fitness, 'descend');
        population.individual = combined_population.individual(idx(1:num_individuals));
        population.fitness = combined_population.fitness(idx(1:num_individuals));

        plot_line(generation) = population.fitness(1);
    end

    best_individual = population.individual{1};
    best_fitness = population.fitness(1);

        % Proyección con el mejor individuo
    W = reshape(best_individual, [d, d]);
    X_projected = X * W;
    X_q =[X_projected(:,1) X_projected(:,2)];
    sValues = silhouette(X_q, y);
    siluete = mean(sValues); % Promedio global como fitness
   



end

function [SB, SW] = calculate_scatter_matrices(X, y)
    % Cálculo real de las matrices de dispersión entre clases y dentro de clase
    classes = unique(y);
    d = size(X, 2);
    overall_mean = mean(X, 1);

    SB = zeros(d, d);
    SW = zeros(d, d);

    for i = 1:length(classes)
        Xi = X(y == classes(i), :);
        ni = size(Xi, 1);
        class_mean = mean(Xi, 1);

        % Entre clases
        mean_diff = (class_mean - overall_mean)';
        SB = SB + ni * (mean_diff * mean_diff');

        % Dentro de clases
        centered = Xi - class_mean;
        SW = SW + centered' * centered;
    end
end
