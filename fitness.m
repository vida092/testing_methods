% function fitness = fitness(D,B)
%     rows = size(D,2);
%     features = D(:,1:rows-1);
%     labels = D(:,rows);
%     projectedFeatures = features * B;
%     projectedData = [projectedFeatures, labels];
% 
% 
%     cluster1Points = projectedData(projectedData(:, end) == 1, 1:end-1);
%     cluster2Points = projectedData(projectedData(:, end) == 2, 1:end-1);
% 
%     centroid1 = mean(cluster1Points, 1);
%     centroid2 = mean(cluster2Points, 1);
% 
%     distances1 = sqrt(sum((cluster1Points - centroid1).^2, 2));
%     intraClusterDist1 = mean(distances1);
% 
%     distances2 = sqrt(sum((cluster2Points - centroid2).^2, 2));
%     intraClusterDist2 = mean(distances2);
% 
%     intraClusterDist = (intraClusterDist1 + intraClusterDist2) / 2;
%     interClusterDist = norm(centroid1 - centroid2);
% 
%     fitness =   interClusterDist/intraClusterDist; %maximizar
%     %fitness = intraClusterDist / interClusterDist; %minimizar
% end

function fitness = fitness(D, B)
    rows = size(D, 2);
    features = D(:, 1:rows-1);
    labels = D(:, rows);
    projectedFeatures = features * B;
    projectedData = [projectedFeatures, labels];
    
    % Obtener las etiquetas únicass
    unique_labels = unique(labels);
    num_classes = length(unique_labels);
    
    intraClusterDistances = zeros(num_classes, 1);
    interClusterDistances = [];
    
    % Calcular distancias intraCluster
    for i = 1:num_classes
        clusterPoints = projectedData(projectedData(:, end) == unique_labels(i), 1:end-1);
        centroid = mean(clusterPoints, 1);
        distances = sqrt(sum((clusterPoints - centroid).^2, 2));
        intraClusterDistances(i) = mean(distances);
    end
    
    % Calcular distancias interCluster
    for i = 1:num_classes
        for j = i+1:num_classes
            cluster1Points = projectedData(projectedData(:, end) == unique_labels(i), 1:end-1);
            cluster2Points = projectedData(projectedData(:, end) == unique_labels(j), 1:end-1);
            centroid1 = mean(cluster1Points, 1);
            centroid2 = mean(cluster2Points, 1);
            interClusterDistances = [interClusterDistances; norm(centroid1 - centroid2)];
        end
    end
    
    % Calcular promedios
    avgIntraClusterDistance = mean(intraClusterDistances);
    avgInterClusterDistance = median(interClusterDistances);
    
    % Calcular el valor de fitness como el cociente
    %fitness = avgInterClusterDistance / avgIntraClusterDistance; % Maximizar
    fitness = avgIntraClusterDistance / avgInterClusterDistance; % Minimizar
end



