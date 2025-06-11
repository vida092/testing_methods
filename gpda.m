function [P, convergence] = gpda(X, y, dim)
    % GPDA para proyección de X con etiquetas y a dim dimensiones (2 o 3)

    if dim ~= 2 && dim ~= 3
        error('gpda solo soporta dimensiones 2 o 3.');
    end

    [m, n] = size(X);

    if dim == 2
        num_generations = 3500;
        num_parents = 8;
        num_matrices = 20;
        mutation_probability = 0.5;
        crossover_op = @crossover2;
        mutation_op = @mutate3;
        generate_basis_fn = @generate_basis2;

    elseif dim == 3
        num_generations = 3500;
        num_parents = 8;
        num_matrices = 20;
        mutation_probability = 0.5;
        crossover_op = @crossover;
        mutation_op = @mutate;
        generate_basis_fn = @generate_basis;
    end

    population(num_matrices) = struct('matrix', [], 'fitness', 0);
    for i = 1:num_matrices
        population(i).matrix = generate_basis_fn(n);
        population(i).fitness = silhouetteFitness([X y], population(i).matrix);
    end

    [~, idx] = sort([population.fitness], 'descend');
    population = population(idx);
    best_fitness = population(1).fitness;
    convergence = best_fitness;
    
    generation = 1;
    while generation <= num_generations && best_fitness <= 0.91
        disp("mejor fitness " + best_fitness + " generacion: " + generation )
        parent_indices = stochastic_universal_sampling(population, 2 * num_parents);
        for i = 1:2:(2 * num_parents)
            p1 = population(parent_indices(i)).matrix;
            p2 = population(parent_indices(i+1)).matrix;
            [c1, c2] = crossover_op(p1, p2);

            m1 = mutation_op(c1, mutation_probability, best_fitness);
            m2 = mutation_op(c2, mutation_probability, best_fitness);
            m12 = mutate2(c1, 0.9);
            m22 = mutate2(c2, 0.9);

            population(end+1).matrix = m1;
            population(end).fitness = silhouetteFitness([X y], m1);
            population(end+1).matrix = m2;
            population(end).fitness = silhouetteFitness([X y], m2);
            population(end+1).matrix = m12;
            population(end).fitness = silhouetteFitness([X y], m12);
            population(end+1).matrix = m22;
            population(end).fitness = silhouetteFitness([X y], m22);
        end

        [~, idx] = sort([population.fitness], 'descend');
        population = population(idx);
        best_individual = population(1);
        best_fitness = best_individual.fitness;
        convergence = [convergence, best_fitness];

        num_elite = round(0.7 * length(population));
        probabilities = [linspace(1, 0.3, num_elite), linspace(0.3, 0.1, length(population) - num_elite)];
        probabilities = probabilities / sum(probabilities);

        remaining_population = population(2:end);
        selected_indices = randsample(length(remaining_population), length(population) - (4 * num_parents) - 1, true, probabilities(2:end));
        selected_population = remaining_population(selected_indices);
        population = [best_individual, selected_population];
        generation = generation + 1;
    end

    P = population(1).matrix;
end
