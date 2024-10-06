function iSelected = TournamentSelect(fitnessValues, tournamentSelectionParameter, tournamentSize)
% TournamentSelect: 競賽選擇法

% 獲取種群大小
populationSize = size(fitnessValues, 1);

% 從種群中隨機選擇競賽參與者
candidates = 1 + fix(rand(1, tournamentSize) * populationSize);

% 獲取參與者的適應度值
candidateFitnesses = fitnessValues(candidates);

% 按適應度值從高到低排序
[~, sortedIndexes] = sort(candidateFitnesses, 1, 'descend');

% 計算選擇概率矩陣
selectionProbabilityMatrix = tournamentSelectionParameter * ((1 - tournamentSelectionParameter) .^ (0:tournamentSize - 2)');

% 根據隨機數和選擇概率矩陣選擇獲勝者
r = rand;
iSelected = candidates(sortedIndexes(r > selectionProbabilityMatrix));

% 如果沒有獲勝者，則選擇適應度值最高的參與者
if isempty(iSelected)
    iSelected = candidates(sortedIndexes(end));
else
    iSelected = iSelected(1);
end
end