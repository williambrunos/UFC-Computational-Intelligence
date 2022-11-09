% Questão 1 - 1º Trabalho de Inteligência Computacional - 2022.2
% Universidade Federal do Ceará - Campus Sobral
% Professor Jarbas Joaci
% Aluno: William Bruno Sales de Paula Lima
% Matrícula: 497345

% Solicitação de inputs de temperatura e preço ao usuário
prompt = "Digite a temperatura: ";
temperatura = input(prompt);
prompt = "Digite o preço: ";
preco = input(prompt);

% Definição dos valores dos intervalos de temperatura e preço - 
% Dados do livro solicitado na lista
range_de_preco = linspace(1, 6, 10000);
range_de_temperatura = linspace(15, 45, 10000);
range_de_consumo = 500:6000;

% Verificação se a temperature e o preço informado estão dentro dos ranges
% aceitáveis
if temperatura < range_de_temperatura(1) || temperatura > range_de_temperatura(length(range_de_temperatura))
    error("Temperatura fora do range especificado");
end
if preco < range_de_preco(1) || preco > range_de_preco(length(range_de_preco))
    error("Preço fora do range especificado");
end

% Valores de pertinência para os diferentes níveis de temperatura
temperatura_baixa = gaussmf(temperatura, [6.369, 15]);
temperatura_media = gaussmf(temperatura, [6.369, 30]);
temperatura_alta = gaussmf(temperatura, [6.369, 45]);

% Valores de pertinência para os diferentes níveis de pressão
pressao_baixa = gaussmf(preco, [1.061, 1]);
pressao_media = gaussmf(preco, [1.061, 3.05]);
pressao_alta = gaussmf(preco, [1.061, 6]);

% Definição das funções de pertinência dos diferentes níveis de consumo
consumo_pequeno = trimf(range_de_consumo, [-2250, 500, 3250]);
consumo_medio = trimf(range_de_consumo, [500, 3250, 6000]);
consumo_grande = trimf(range_de_consumo, [3250, 6000, 8750]);

% Regras definidas como produtos, de acordo com o livro
regra_1 = prod([temperatura_baixa, pressao_baixa]);
regra_2 = prod([temperatura_baixa, pressao_media]);
regra_3 = prod([temperatura_baixa, pressao_alta]);
regra_4 = prod([temperatura_media, pressao_baixa]);
regra_5 = prod([temperatura_media, pressao_media]);
regra_6 = prod([temperatura_media, pressao_alta]);
regra_7 = prod([temperatura_alta, pressao_baixa]);
regra_8 = prod([temperatura_alta, pressao_media]);
regra_9 = prod([temperatura_alta, pressao_alta]);

% Regras de implicação para os conumos, de acordo com o livro
implica_consumo_pequeno = prod([regra_3, regra_6, regra_9]);
implica_consumo_medio = prod([regra_2, regra_5, regra_8]);
implica_consumo_grande = prod([regra_1, regra_4, regra_7]);
        
% Agregação que resulta em graus de pertinência para os diferentes níveis
% de consumo
consumo_baixo_pertencimento = min(implica_consumo_pequeno, consumo_pequeno);
consumo_medio_pertencimento = min(implica_consumo_medio, consumo_medio);
consumo_alto_pertencimento = min(implica_consumo_grande, consumo_grande);


agrega = max(consumo_baixo_pertencimento, consumo_medio_pertencimento);
agrega = max(agrega, consumo_alto_pertencimento);

% Cálculo do consumo final - Centróide final
consumo = sum(agrega .* range_de_consumo) / sum(agrega);