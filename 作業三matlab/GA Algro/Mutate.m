function tempPopulation = Mutate(tempPopulation, mutationProbability)
% Mutate:變異函式

% 生成與tempPopulation相同大小的隨機矩陣
% 其中小於mutationProbability的元素為1,其餘為0
indexes = rand(size(tempPopulation)) < mutationProbability;

% 對indexes中為1的位置進行變異操作(按位取反)
tempPopulation(indexes) = tempPopulation(indexes) * -1 + 1