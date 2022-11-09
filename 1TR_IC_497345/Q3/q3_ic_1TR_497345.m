% Dados fornecidos na questão
D =[122 139 0.115;
    114 126 0.120;
    086 090 0.105;
    134 144 0.090;
    146 163 0.100;
    107 136 0.120;
    068 061 0.105;
    117 062 0.080;
    071 041 0.100;
     098 120 0.115];

% Matrix de variáveis independentes
x = D(:, 1:2);

% Variável dependente
y = D(:, 3);

% matrix que representa [qtd_linhas qtd_colunas]
data_size = size(D);
% data_rows representa o 'n', quantidade de linhas/observações dos dados
data_rows = data_size(:, 1);

% Matrix preenchida com valores 1 de dimensão n x 1
ones_matrix = ones(data_rows, 1);

X = [ones_matrix];
% Adicionando as colunas dos dados de entrada na matrix X
for i = 1:2
    to_append = x(:, i);
    X(:, end+1) = to_append;
end

% Matrix de coeficientes
beta = inv(X'*X)*X'*y;
y_predictions = X*beta;

x1 = x(:, 1);
x2 = x(:, 2);

% Plotando os dados originais
plot3(x1, x2, y, '*');
grid on;
hold on;

[x1, x2] = meshgrid(0:0.5:180, 0:0.5:180);
% Y_predictions corresponde ao y chapéu, predições do modelo
Y_predictions = beta(1) + beta(2) * x1 + beta(3) * x2;
mesh(x1, x2, Y_predictions);
colorbar;

SQe = sum((y - y_predictions).^2);
Syy = sum((y - mean(y)).^2);
R2 = 1 - SQe / Syy;