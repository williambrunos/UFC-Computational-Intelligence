% 2º Trabalho de Inteligência Computacional - 2022.2
% Curso: Engenharia de Computação
% Prof. Jarbas Joaci
% Universidade Federal do Ceará - UFC/Sobral
% Estudante: William Bruno Sales de Paula Lima
% Matrícula: 497345

% Abrindo o arquivo para obter informações de leitura
fid = fopen('database/column_3C.dat');
% Utilizando fid para ler os dados das colunas do .dat, sendo a última
% coluna como string e o delimitador da vírgula
data_read = textscan(fid, '%f %f %f %f %f %f %s', 'Delimiter',',');

% Início do processo de One Hot Encoding

% Labels da última coluna
labels = data_read{7};
labels_quantity = length(labels);
% Obtendo apenas realizações únicas em labels
unique_labels = unique(labels);
length_unique_labels = length(unique_labels);
% Criando uma matriz de zeros que será "povoada" com 1's para cada registro
% nos dados dependendo do seu rótulo (label) na última coluna
label_columns = zeros(labels_quantity, length(unique_labels));
        
for i = 1 : labels_quantity
   for j = 1 : length_unique_labels
       label_columns(i, j) = strcmp(labels{i}, unique_labels(j));
   end
end

% Fim do processo de One Hot Encoding

% Concatenando todo o dataset com as 6 primeiras colunas do arquivo de
% texto lido e as 3 colunas resultantes do OH Encoding (labels_columns)
dataset = [data_read{1}, data_read{2}, data_read{3}, data_read{4}, data_read{5}, data_read{6}, label_columns];

% Obtendo os dados de features (X) e os rótulos dos dados (Y)
X = dataset(:, 1:6);
X = X';
y = dataset(:, 7:9);
y = y';

% Normalizando os dados de X entre -1 e 1
X_norm = normalize(X);

q = 40;
sigma = 35;

% Seta 10 épocas
epochs = 10;
train_percentual = 0.7;
accuracy = zeros(1, epochs);

for epoch = 1 : epochs
    [input_classes, total_samples] = size(X);
    [output_classes, ~] = size(y);
    
    test_percentual = 1 - train_percentual;
    test_samples_size = round(test_percentual * total_samples);
    
    % X_train recebe X com os valores embaralhados
    random_sample_indexes = randperm(length(X));
    
    % De acordo com os índices das amostras obtidas na linha 66, obtemos os
    % dados de treino de X normalizados e os rótulos de treino de y
    X_train = X_norm(:, random_sample_indexes);
    Y_train = y(:, random_sample_indexes);
   
    X_test = zeros(input_classes, test_samples_size);
    Y_test = zeros(output_classes, test_samples_size);

    % Esta etapa do código destina-se a injetar dados que estão nas
    % matrizes de treino nas matrizes de teste, e depois remover os mesmos
    % dados da matriz de treino. Com isso, não há vazamento de dados (data
    % leakage)
    for i = 1 : test_samples_size
        Y_test(:, i) = Y_train(:, i);
        X_test(:, i) = X_train(:, i);
    
        X_train(:, i) = [];
        Y_train(:, i) = [];
    end

    % Treinamento do modelo
    [p, ~] = size(X_train);
    hidden_w = randn(p, q);

    [~, n] = size(X_train);
    Z = zeros(q, n);

    % Percorre cada elemento da entrada
    for i = 1 : n
        % Percorre cada neurônio
        for neuron_num = 1 : q
            centroid = hidden_w(:, neuron_num); % Armazena o centroid do neurônio
            x = X_train(:, i); % Armazena o elemento
            u = norm(x - centroid); % Calcula a norma da diferença entre vetor do elemento e centroid
            fu = exp(-u .^ 2 / (2 * sigma .^ 2));
            Z(neuron_num, i) = fu;
        end
    end
    
    % Z é (q, n)
    [~, n] = size(Z);
    Z = [(-1) * ones(1, n); Z];
    % Z = RadialBasisFunction.addBias(Z); % Após adicionar o bias/viés, Z é (q + 1, n)

    M = Y_train * Z' / (Z * Z');

    % Fim do treinamento do modelo

    % Início da predição dos rótulos
    [~, n] = size(X_test);
    Z = zeros(q, n);

    % Percorre cada elemento da entrada
    for i = 1 : n
        % Percorre cada neurônio
        for neuron_num = 1 : q
            centroid = hidden_w(:, neuron_num); % Armazena o centroid do neurônio
            x = X_test(:, i); % Armazena o elemento
            u = norm(x - centroid); % Calcula a norma da diferença entre vetor do elemento e centroid
            fu = exp(-u .^ 2 / (2 * sigma .^ 2)); % Processa a norma pela função de ativação
            Z(neuron_num, i) = fu;
        end
    end
    
    % Z é (q, n)
    [~, n] = size(Z);
    Z = [(-1) * ones(1, n); Z];
    % Z = RadialBasisFunction.addBias(Z); % Após adicionar o bias/viés, Z é (q + 1, n)

    predictions = M * Z;

    % Realizando-se a comparação dos rótulos reais com as predições do
    % modelo
    [~, test_samples_size] = size(Y_test);
    [~, predicted_label] = max(predictions);
    [~, right_label] = max(Y_test);

    quantity_of_right_predictions = predicted_label == right_label;
    testHits = sum(quantity_of_right_predictions);
    % Alimentando a matriz com a acurácia desta época
    accuracy(epoch) = testHits / test_samples_size;
end

fprintf('Acurácia Média: %f\n', mean(accuracy));