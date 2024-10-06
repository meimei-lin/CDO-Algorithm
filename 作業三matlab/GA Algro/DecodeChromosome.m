function x = DecodeChromosome (chromosome, numberOfVariables, variableRange)
% DecodeChromosome:將二進制編碼的染色體解碼為實數變數值
% 初始化解碼後的變數向量
x = zeros(1, numberOfVariables);

% 計算每個變數所佔的位元數
numberOfBits = size(chromosome, 2) / numberOfVariables;

% 對每個變數進行解碼
for index = 1:numberOfVariables
    
    % 初始化當前變數的值為0
    x(index) = 0.0;
    
    % 計算當前變數在染色體中的起始和結束位置
    geneRangeStart = (((index - 1) * numberOfBits) + 1);
    geneRangeEnd = index * numberOfBits;
    
    % 將二進制基因轉換為灰度編碼值
    x(index) = sum(chromosome(geneRangeStart:geneRangeEnd) .* (2 .^ -(1:numberOfBits)));
    
    % 將灰度編碼值映射到變數的取值範圍
    x(index) = -variableRange + 2 * variableRange * x(index) / (1 - 2 ^ (-numberOfBits));
end