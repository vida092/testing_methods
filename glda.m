function [P, convergence, status, err_msg] = glda(X, y, dim)
    % GLDA: optimización de proyección basada en SB y SW usando determinante
    [m, d] = size(X);
    num_individuals = 30;
    num_generations = 500;
    crossover_prob = 0.9;
    tol = 1e-10;

    % Inicialización de salida por defecto
    P = [];
    convergence = [];
    status = "ok";
    err_msg = "";

    % Matrices de dispersión
    [SB, SW] = calculate_scatter_matrices(X, y);

    % Revisión de rango de SW
    if rank(SW, tol) < size(SW, 1)
        warning("GLDA falló: S_W no es de rango completo.");
        status = "failed";
        err_msg = "S_W no tiene rango completo, no se puede usar determinante.";
        return;
    end

    % Inicialización de población
    population.individual = cell(num_individuals, 1);
    population.fitness = zeros(num_individuals, 1);
    convergence = zeros(1, num_generations);

    for i = 1:num_individuals
        population.individual{i} = rand(1, d^2);
        population.fitness(i) = fitness_function(population.individual{i}, SB, SW, 'determinant', d);
    end

    for generation = 1:num_generations
        parents = binary_tournament_selection(population, 2);
        offspring.individual = cell(2,1);
        offspring.fitness = zeros(2,1);

        [offspring1, offspring2] = crossover_and_mutation(parents.individual{1}, parents.individual{2}, crossover_prob);

        offspring.individual{1} = offspring1;
        offspring.individual{2} = offspring2;

        offspring.fitness(1) = fitness_function(offspring1, SB, SW, 'determinant', d);
        offspring.fitness(2) = fitness_function(offspring2, SB, SW, 'determinant', d);

        combined.individual = [population.individual; offspring.individual];
        combined.fitness = [population.fitness; offspring.fitness];

        [~, idx] = sort(combined.fitness, 'descend');
        population.individual = combined.individual(idx(1:num_individuals));
        population.fitness = combined.fitness(idx(1:num_individuals));

        convergence(generation) = population.fitness(1);
    end

    % Mejor individuo
    best_vec = population.individual{1};
    W = reshape(best_vec, [d, d]);  % d × d
    P = W(:, 1:dim);                % d × dim
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

