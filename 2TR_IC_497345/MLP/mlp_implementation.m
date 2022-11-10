% Lendo o arquivo .dat
fileID = fopen('database/column_3C.dat');
% Lendo os dados do arquivo .dat com a última coluna sendo string
C = textscan(fileID, '%f %f %f %f %f %f %s', 'Delimiter',',');

labels = C{7};
N = length(labels);
uniqueLabels = unique(labels);
labelColumns = zeros(N, length(uniqueLabels));
        
for i = 1 : N
   for j = 1 : length(uniqueLabels)
       labelColumns(i, j) = strcmp(labels{i}, uniqueLabels(j));
   end
end

dataset = [C{1}, C{2}, C{3}, C{4}, C{5}, C{6}, labelColumns];

X = dataset(:, 1:6);
X = X';
y = dataset(:, 7:9);
y = y';

X_norm = normalize(X);

trainingPercentage = 0.7;

% Seta o percentual de amostras para treinamento/testes para 70%/30%
trainingPercentage = 0.7;

% Seta 10 épocas
totalEpochs = 10;
accuracy = zeros(1, totalEpochs);

net = feedforwardnet(30);

for epoch = 1 : totalEpochs
     % Em cada época é realizado um novo hold out

    [inputClasses, totalSamples] = size(X);
    [outputClasses, ~] = size(y);
    
    testingPercentage = 1 - trainingPercentage;
    quantityOfTestingSamples = round(testingPercentage * totalSamples);
    
    % X_train recebe X com os valores embaralhados
    shuffledSampleIndexes = randperm(length(X));
    
    X_train = X_norm(:, shuffledSampleIndexes);
    Y_train = y(:, shuffledSampleIndexes);
    
    % As amostras excedentes são gradativamente retiradas de
    % X_train, Y_train e alocadas em X_test e Y_test.
    X_test = zeros(inputClasses, quantityOfTestingSamples);
    Y_test = zeros(outputClasses, quantityOfTestingSamples);


    for i = 1 : quantityOfTestingSamples
        Y_test(:, i) = Y_train(:, i);
        X_test(:, i) = X_train(:, i);
    
        X_train(:, i) = [];
        Y_train(:, i) = [];
    end

    % O modelo é treinado
    net = train(net, X_train, Y_train);
    
    % Uma predição é feita com os dados de teste
    prediction = net(X_test);

    % É comparado os dados de teste com a predição por meio da acurácia
    [~, testSamples] = size(Y_test);
    [~, predictedClass] = max(prediction);
    [~, actualClass] = max(Y_test);

    hitsArr = predictedClass == actualClass;
    testHits = sum(hitsArr);
    accuracy(epoch) = testHits / testSamples;
end


% É mostrado de forma visual os valores das acurácias para cada época e
% tambéma acurácia média.
fprintf('===== Treinamento e Teste para MLP =====\n');

for i = 1 : totalEpochs
    fprintf('Acurácia Época %d: %f\n', i, accuracy(i));
end 

fprintf('Acurácia Média: %f\n', mean(accuracy));
