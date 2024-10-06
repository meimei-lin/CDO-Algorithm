function population = InitializePopulation(populationSize, numberOfGenes)
% InitializePopulation:用來初始化種群的函數
population = (rand(populationSize, numberOfGenes)<0.5).*1;
return
