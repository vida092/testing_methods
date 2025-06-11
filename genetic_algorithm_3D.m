function [stats,best_fitnesses] = genetic_algorithm_3D(database)
    % Crear carpeta para guardar imágenes
    output_folder = 'convergencias_3D';
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    disp("trabajando en base de datos " + database)
    % Leer datos de la base de datos
    D = readmatrix(database);
    features = D(:, 1:end-1);
    labels = D(:, end);
    [m, n] = size(D);
    classes = unique(labels);
    num_classes = numel(classes);
    n = n - 1;
    
   

    % Parámetros del algoritmo genético
    num_executions = 1;
    num_generations = 3500;
    num_parents = 8;
    num_matrices = 20;
    mutation_probability = 0.5;

    all_populations = cell(1, num_executions);
    all_plots = cell(1, num_executions);
    all_train_data = cell(1, num_executions);
    all_test_data = cell(1, num_executions);
    
    for execution = 1:num_executions
        % Dividir en entrenamiento y validación
        train_data = [];
        test_data = [];
        train_ratio = 0.7;
        for i = 1:num_classes
            class = classes(i);
            class_indices = find(labels == class);
            num_samples = numel(class_indices);
            num_train_samples = round(train_ratio * num_samples);
            shuffled_indices = class_indices(randperm(num_samples));
            train_indices = shuffled_indices(1:num_train_samples);
            test_indices = shuffled_indices(num_train_samples + 1:end);
            train_data = [train_data; D(train_indices, :)];
            test_data = [test_data; D(test_indices, :)];
        end
    
        all_train_data{execution} = train_data;
        all_test_data{execution} = test_data;
    
        disp("ejecucion " + execution)
        plot_line = [];
        population(num_matrices) = struct('matrix', [], 'fitness', 0);
    
        for i = 1:num_matrices
            population(i).matrix = generate_basis(n);
            population(i).fitness = silhouetteFitness(train_data, population(i).matrix);
        end
    
        [~, idx] = sort([population.fitness], 'descend');
        population = population(idx);
        generation = 1;
        best_fitness = 0;
    
        while generation <= num_generations && best_fitness <= 0.91
            disp("Generación: " + generation + " ejecucion " + execution)
            disp("Mejor fitness antes de selección: " + best_fitness)
    
            parent_indices = stochastic_universal_sampling(population, 2 * num_parents);
            for i = 1:2:num_parents*2
                parent1 = population(parent_indices(i)).matrix;
                parent2 = population(parent_indices(i+1)).matrix;
                [child1, child2] = crossover(parent1, parent2);
                mutant1 = mutate(child1, mutation_probability, best_fitness);
                mutant2 = mutate(child2, mutation_probability, best_fitness);
    
                child1_fitness = silhouetteFitness(train_data, mutant1);
                child2_fitness = silhouetteFitness(train_data, mutant2);
    
                mutant12 = mutate2(child1, 0.9);
                mutant22 = mutate2(child2, 0.9);
    
                child12_fitness = silhouetteFitness(train_data, mutant12);
                child22_fitness = silhouetteFitness(train_data, mutant22);
    
                population(end+1).matrix = mutant12;
                population(end).fitness = child12_fitness;
                population(end+1).matrix = mutant22;
                population(end).fitness = child22_fitness;
    
                population(end+1).matrix = mutant1;
                population(end).fitness = child1_fitness;
                population(end+1).matrix = mutant2;
                population(end).fitness = child2_fitness;
            end
    
            [~, idx] = sort([population.fitness], 'descend');
            population = population(idx);
            best_individual = population(1);
            best_fitness = best_individual.fitness;
    
            num_elite = round(0.7 * length(population));
            probabilities = [linspace(1, 0.3, num_elite), linspace(0.3, 0.1, length(population) - num_elite)];
            probabilities = probabilities / sum(probabilities);
    
            remaining_population = population(2:end);
            selected_indices = randsample(length(remaining_population), length(population) - (4*num_parents) - 1, true, probabilities(2:end));
            selected_population = remaining_population(selected_indices);
    
            population = [best_individual, selected_population];
            plot_line = [plot_line, best_fitness];
            generation = generation + 1;
        end
    
        all_populations{execution} = population;
        all_plots{execution} = plot_line;
    end
    
    % === CÁLCULO DE FITNESS EN TRAIN, TEST Y TOTAL ===
    fitness_train = zeros(1, num_executions);
    fitness_test = zeros(1, num_executions);
    fitness_total = zeros(1, num_executions);
    
    for i = 1:num_executions
        best_matrix = all_populations{i}(1).matrix;
        fitness_train(i) = silhouetteFitness(all_train_data{i}, best_matrix);
        fitness_test(i) = silhouetteFitness(all_test_data{i}, best_matrix);
        fitness_total(i) = silhouetteFitness(D, best_matrix);
    end
    
    % === ESTADÍSTICAS AGRUPADAS EN FILAS POR CONJUNTO ===
    means = [mean(fitness_train); mean(fitness_test); mean(fitness_total)];
    stds = [std(fitness_train); std(fitness_test); std(fitness_total)];
    maxs = [max(fitness_train); max(fitness_test); max(fitness_total)];
    mins = [min(fitness_train); min(fitness_test); min(fitness_total)];
    medians = [median(fitness_train); median(fitness_test); median(fitness_total)];
    
    sets = {'Train'; 'Test'; 'Total'};
    
    stats = table(sets, means, stds, maxs, mins, medians, ...
        'VariableNames', {'Set', 'Mean', 'StdDev', 'MaxFitness', 'MinFitness', 'MedianFitness'});
    
    % Guardar tabla
    writetable(stats, database + "_stats_3D.csv")
    writematrix(fitness_total, database + "_best_fitness_total_3D.csv")
    
    disp("Estadísticas de " + database);
    disp(stats);


