function newPopulation = InsertBestIndividual(population, bestChromosome, nc)
% InsertBestIndividual: 將最佳個體插入族群

% 用最佳個體替換族群中的隨機個體
newPopulation = population;
randIndexes = ceil(rand(nc, 1) * size(population, 1)); % 生成隨機索引
newPopulation(randIndexes, :) = repmat(bestChromosome, nc, 1); % 用最佳個體替換對應位置的個體

return
