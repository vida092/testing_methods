function [stats,best_fitnesses] = genetic_algorithm_2D(database)



    output_folder = 'convergencias_2D';
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % Leer datos de la base de datos
    D = readmatrix(database);
    features = D(:, 1:end-1);
    labels = D(:, end);
    [m, n] = size(D);
    classes = unique(labels);
    num_classes = numel(classes);
    n = n - 1;

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
    % Parámetros del algoritmo genético
    num_executions = 1;
    num_generations = 3500;
    num_parents = 8;
    num_matrices = 20;
    mutation_probability = 0.5;

    % Ejecutar el algoritmo genético
    all_populations = cell(1, num_executions);
    all_plots = cell(1, num_executions);
    for execution = 1:num_executions
        disp("ejecucion " + execution)
        plot_line = [];
        population(num_matrices) = struct('matrix', [], 'fitness', 0);

        for i = 1:num_matrices

            population(i).matrix = generate_basis2(n);
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
                [child1, child2] = crossover2(parent1, parent2);
                mutant1 = mutate3(child1, mutation_probability,best_fitness); %rotation
                mutant2 = mutate3(child2, mutation_probability,best_fitness); %rotation
                child1_fitness = silhouetteFitness(train_data, mutant1);
                child2_fitness = silhouetteFitness(train_data, mutant2);


                mutant12 = mutate2(child1, 0.9); %% row swap
                mutant22 = mutate2(child2, 0.9); %% row swap
                
                child12_fitness = silhouetteFitness(train_data, mutant12);
                
                child22_fitness = silhouetteFitness(train_data, mutant22);



                population(end+1).matrix = mutant22;
                population(end).fitness = child22_fitness;
                population(end+1).matrix = mutant12;
                population(end).fitness = child12_fitness;

                population(end+1).matrix = mutant1;
                population(end).fitness = child1_fitness;
                population(end+1).matrix = mutant2;
                population(end).fitness = child2_fitness;
            end
                        % Ordenar población por fitness descendente
            [~, idx] = sort([population.fitness], 'descend');
            population = population(idx);
            
            % Extraer el mejor individuo antes de la selección
            best_individual = population(1); % Siempre conservar el mejor
            
            % Mostrar debug antes de la condición de parada
            best_fitness = best_individual.fitness;
  
            
            % Definir pesos de selección, dando mayor probabilidad a los mejores
            num_elite = round(0.7 * length(population)); % 70% de los mejores
            probabilities = [linspace(1, 0.3, num_elite), linspace(0.3, 0.1, length(population) - num_elite)];
            probabilities = probabilities / sum(probabilities); % Normalizar
            
            % Excluir el mejor individuo de la selección para garantizar su supervivencia
            remaining_population = population(2:end); % Quitar el mejor antes de la selección
            selected_indices = randsample(length(remaining_population), length(population) - (4*num_parents) - 1, true, probabilities(2:end));
            selected_population = remaining_population(selected_indices);
            
            % Restaurar el mejor individuo en la nueva población
            population = [best_individual, selected_population];


            %mejores_individuos(generation).matrix = population(1).matrix;
        
            % Registro de progreso
            plot_line = [plot_line, best_fitness];        
            generation = generation + 1;

            % [~, idx] = sort([population.fitness], 'descend');
            % population = population(idx);
            % population = population(1:end-(2*num_parents));
            % plot_line = [plot_line, population(1).fitness];

        end
        all_populations{execution} = population;
        all_plots{execution} = plot_line;
    end
    
    % Estadísticas
    best_fitnesses = zeros(1, num_executions);
    for i = 1:num_executions
        best_fitnesses(i) = all_populations{i}(1).fitness;
    end

    [~, idx_max] = max(best_fitnesses);
    [~, idx_min] = min(best_fitnesses);
    sorted_fitnesses = sort(best_fitnesses);
    median_fitness = sorted_fitnesses(ceil(num_executions / 2));
    original_idx_median = find(best_fitnesses == median_fitness, 1, 'first');
    stats = table(mean(best_fitnesses), std(best_fitnesses), ...
                  best_fitnesses(idx_max), best_fitnesses(idx_min), ...
                  median_fitness, ...
                  'VariableNames', {'Mean', 'StdDev', 'MaxFitness', 'MinFitness', 'MedianFitness'});
    
    writetable(stats, database + "_stats_2D_GPDA.csv")
    writematrix(best_fitnesses, database + "_best_fitnesses_2D.csv")
    disp("estadisticas 3D de " + database);
    disp(stats);

    figure;
    plot(all_plots{idx_max}, 'k-', 'LineWidth', 2, 'DisplayName', 'Max'); 
    hold on;
    plot(all_plots{idx_min}, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Min');
    plot(all_plots{original_idx_median}, 'k-.', 'LineWidth', 1.5, 'DisplayName', 'Median'); 
    grid on;
    legend('show', 'Location', 'best'); 
    title("Convergence graph for " + database, 'Interpreter', 'none'); 

    saveas(gcf, fullfile(output_folder, database + "_convergence_2D.png"));
    

    best_matrix = all_populations{1, original_idx_median}(1).matrix;

    DA = features * all_populations{1, original_idx_median}(1).matrix;
    DA = [DA labels];
    csvwrite("GPDA_2D_" + database + ".csv", DA);
    disp("Fitness del mejor individuo en TODO el conjunto:");
    disp(silhouetteFitness(D, best_matrix));
end
