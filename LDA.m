clc
clear
file = "wine";
fileName = file + ".csv";
data = readmatrix(fileName);

% Separar características y etiquetas

X = data(:, 1:end-1);
labels = data(:, end);

% División 70/30 aleatoria
numSamples = size(X, 1);
randIdx = randperm(numSamples);
trainCount = round(0.7 * numSamples);

X_train = X(randIdx(1:trainCount), :);
y_train = labels(randIdx(1:trainCount));
X_test = X(randIdx(trainCount+1:end), :);
y_test = labels(randIdx(trainCount+1:end));

% Obtener clases únicas
classes = unique(y_train);
numClasses = length(classes);
[numTrainSamples, numFeatures] = size(X_train);

% Inicializar matrices Sw y Sb
Sw = zeros(numFeatures);
Sb = zeros(numFeatures);
meanTotal = mean(X_train, 1);

% Calcular Sw y Sb con datos de entrenamiento
for i = 1:numClasses
    classData = X_train(y_train == classes(i), :);
    meanClass = mean(classData, 1);
    Sw = Sw + (classData - meanClass)' * (classData - meanClass);
    numSamplesClass = size(classData, 1);
    meanDiff = (meanClass - meanTotal)';
    Sb = Sb + numSamplesClass * (meanDiff * meanDiff');
end

% LDA: resolver Sb * w = lambda * Sw * w
[eigVecs, eigVals] = eig(Sb, Sw);
[eigValsSorted, sortIdx] = sort(diag(eigVals), 'descend');
eigVecsSorted = eigVecs(:, sortIdx);

% Selección de dimensiones
numDimensions = 2;
if numDimensions > size(eigVecsSorted, 2)
    error('La dimensión seleccionada supera el número total de dimensiones posibles.');
end
W = eigVecsSorted(:, 1:numDimensions);

% Proyección de todo el conjunto original con W
X_LDA_full = X * W;
writematrix(X_LDA_full, "LDA_" + fileName);

% Visualización si es 1D o 2D
if numDimensions == 1
    scatter(X_LDA_full, zeros(size(X_LDA_full)), 50, labels, 'filled');
    xlabel('LDA Dim 1');
    title('Proyección LDA en 1D');
elseif numDimensions == 2
    scatter(X_LDA_full(:, 1), X_LDA_full(:, 2), 50, labels, 'filled');
    xlabel('LDA Dim 1');
    ylabel('LDA Dim 2');
    title('Proyección LDA en 2D');
else
    disp('Proyección completada, pero no se puede visualizar en más de 2 dimensiones.');
end

% Calcular índice de silueta
figure;
silhouette(X_LDA_full, labels);
title('Índice de Silueta en espacio LDA');
meanSilhouette = mean(silhouette(X_LDA_full, labels));
disp(['Índice de silueta promedio: ', num2str(meanSilhouette)]);
