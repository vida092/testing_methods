function fitnessValue = silhouetteFitness(D, B)
    % D: Base de datos original (última columna son las etiquetas)
    % B: Matriz de proyección
    rows = size(D, 2);
    features = D(:, 1:rows-1); % 
    labels = D(:, rows);      % Etiquetas

    projectedFeatures = features * B;
    try

        normalizedFeatures = projectedFeatures;
        labels = int32(labels);  % o int32(labels)
        sValues = silhouette(normalizedFeatures, labels);
        fitnessValue = mean(sValues);
    catch

        fitnessValue = -inf;
    end
end
% 
% function fitnessValue = silhouetteFitness(D, B)
%     % D: Base de datos original (última columna son las etiquetas)
%     % B: Matriz de proyección (n × dim)
% 
%     features = D(:, 1:end-1);
%     labels = D(:, end);
% 
%     try
%         Z = features * B;
%         sValues = silhouette(Z, labels, 'Euclidean');
%         fitnessValue = mean(sValues);
%     catch
%         fitnessValue = -inf;
%     end
% end
% 
