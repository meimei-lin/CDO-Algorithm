function newChromosomePair = Cross( chromosome1, chromosome2)
% 交叉函式
% 獲取基因長度
nGenes = size(chromosome1, 2);

% 隨機選擇交叉點
crossoverPoint = 1 + fix(rand * (nGenes - 1));
assert(crossoverPoint > 0 && crossoverPoint <= nGenes);

% 產生新的子代基因
newChromosomePair(1, :) = [chromosome1(1:crossoverPoint) chromosome2(crossoverPoint+1:end)];
newChromosomePair(2, :) = [chromosome2(1:crossoverPoint) chromosome1(crossoverPoint+1:end)];
