function fitnessValue = EvaluatePopulation(x, runParallel)
% EvaluatePopulation: 計算一個族群中每個個體的適應度值

    % 檢查 runParallel 參數是否存在
    if ~exist('runParallel','var')
        runParallel = false; % 如果不存在，則設為false
    end
    % 獲取個體數量和每個個體的基因數量
    numIndividuals = size(x, 1);
    individualSize = size(x, 2);
    % 初始化適應度值向量
    fitnessValue = zeros(numIndividuals, 1);

    % 根據是否使用平行計算來進行適應度值計算
    if runParallel
        % 使用平行迴圈計算每個個體的適應度值
        parfor index = 1:numIndividuals
        fitnessValue(index) = EvaluateIndividual(x(index, :));
        end
    else
   % 使用迴圈順序計算每個個體的適應度值
   for index = 1:numIndividuals
       fitnessValue(index) = EvaluateIndividual(x(index, :));
   end
end
end