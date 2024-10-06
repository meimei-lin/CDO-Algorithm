function x = DecodePopulation(population, numberOfVariables, variableRange)
% DecodePopulation:將二進制編碼的族群解碼為實數變數值

% 獲取族群大小
populationSize = size(population, 1);

% 初始化解碼後的變數矩陣
x = zeros(populationSize, numberOfVariables);

% 計算每個變數所佔的位元數
numberOfBits = size(population, 2) / numberOfVariables;

% 對每個變數進行解碼
for index = 1:numberOfVariables
    
    % 計算當前變數在族群中的起始和結束位置
    geneRangeStart = (((index - 1) * numberOfBits) + 1);
    geneRangeEnd = index * numberOfBits;
    
    % 將二進制基因轉換為灰度編碼值
    x(:, index) = sum(population(:, geneRangeStart:geneRangeEnd) .* repmat((2 .^ -(1:numberOfBits)), populationSize, 1), 2);
    
    % 將灰度編碼值映射到變數的取值範圍
    x(:, index) = -variableRange + 2 * variableRange * x(:, index) / (1 - 2 ^ (-numberOfBits));
    
end
end