function [minimumFitness, xBest, convergence_curve] = GA(populationSize, numberOfGenes, tournamentSelectionParameter, variableRange, max_iter, numberOfVariables, tournamentSize, numberOfReplications, mutation_rate, crossover_rate)
% 輸入參數:
% populationSize: 族群大小
% numberOfGenes: 基因數量
% tournamentSelectionParameter: 賽局選擇參數
% variableRange: 變數範圍
% max_iter: 最大迭代次數
% numberOfVariables: 變數數量
% tournamentSize: 賽局大小
% numberOfReplications: 重複次數
% mutation_rate: 變異率
% crossover_rate: 交叉率

runparallel = false; % 是否使用平行計算

fitness = zeros(populationSize, 1); % 初始化適應度值

% 初始化族群
population = InitializePopulation(populationSize, numberOfGenes);

% 初始化收斂曲線
convergence_curve = zeros(1, max_iter);

l = 0; % 迭代次數計數器

%% 迭代
while l < max_iter
   
   % 計算每個個體的適應度值
   for iGeneration = 1:size(population, 1)
       
       % 解碼族群
       decodedPopulation = DecodePopulation(population, numberOfVariables, variableRange);
       
       % 計算適應度值
       fitness = EvaluatePopulation(population(iGeneration, :));
       
       % 找到最小適應度值及對應的個體索引
       [minimumFitness, bestIndividualIndex] = min(fitness);
       
       % 紀錄最佳解
       xBest = decodedPopulation(bestIndividualIndex, :);
       
       % 複製族群
       newPopulation = population;
       
   end
   
   %% 產生新一代
   for iGeneration = 1:tournamentSize:populationSize
       
       %% 比賽選擇
       i1 = TournamentSelect(fitness, tournamentSelectionParameter, tournamentSize);
       i2 = TournamentSelect(fitness, tournamentSelectionParameter, tournamentSize);
       
       chromosome1 = population(i1, :);
       chromosome2 = population(i2, :);
       
       %% 交叉
       r = rand;
       if (r < crossover_rate)
           newChromosomePair = Cross(chromosome1, chromosome2);
           newPopulation(iGeneration, :) = newChromosomePair(1, :);
           newPopulation(iGeneration + 1, :) = newChromosomePair(2, :);
       else
           newPopulation(iGeneration, :) = chromosome1;
           newPopulation(iGeneration + 1, :) = chromosome2;
       end
       
       %% 變異
       newPopulation = Mutate(newPopulation, mutation_rate);
       
       %% 保留前一代最佳個體
       bestChromosome = population(bestIndividualIndex, :);
       newPopulation = InsertBestIndividual(newPopulation, bestChromosome, numberOfReplications);
       
       %% 更新族群
       population = newPopulation;
       
   end
   
   l = l + 1; % 更新迭代次數
   
   % 更新收斂曲線
   convergence_curve(l) = minimumFitness;
   
end