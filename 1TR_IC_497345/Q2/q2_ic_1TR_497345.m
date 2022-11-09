% Carregando dados
data = load("database/aerogerador.dat");

% wind representa os dados da velocidade do vento - variável independente
wind = data(:, 1);
% power representa os dados de potência do gerador - variável dependente
power = data(:, 2);
% matrix que representa [qtd_linhas qtd_colunas]
data_size = size(wind);
% data_rows representa o 'n', quantidade de linhas/observações dos dados
data_rows = data_size(:, 1);

% Matrix preenchida com valores 1
ones_matrix = ones(data_rows, 1);
% Grau máximo do polinômio
degrees = 7;

% Resultados das regressões
regression_results = [];
count = 1;

tiledlayout(4,2);

nexttile([1, 2]);
plot(wind, power, '*');
title('Dados originais');

% Realiza regressões com polinômios de graus indo de 2 a 7 nos dados
for i = 2:degrees
    hold on;
    X = [ones_matrix];
    % Adiciona valores de xij ^ k no polinômio
    for j = 1:i
        to_append = wind.^j;
        X(:, end+1) = to_append;
    end
    % Calcula a matrix de coeficientes
    beta = inv((X'*X))*X'*power;
    % Faz predições
    y_predictions = X*beta;
  
    nexttile;
    plot(wind, y_predictions, '--');
    title('Regressão de Grau', i);
    
    SQe = sum((power - y_predictions).^2);
    Syy = sum((power - mean(power)).^2);
    R2 = 1 - SQe / Syy;
    
    p = i + 1;
    R2aj = 1 - (SQe/ (data_rows - p)) / (Syy/ (data_rows - 1)); 
   
    % Cada linha de regression_results representa uma regressão, a primeira
    % coluna representa R2 e a terceira R2aj para aquela mesma regressão
    regression_results(count, 1) = R2;
    regression_results(count, 2) = R2aj;
    
    count = count + 1;
end

