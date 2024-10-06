clear all 
clc

SearchAgents_no=30; % 搜索代理數量
Function_name='F1'; 
Max_iteration=1000; 
mutationRate=0.001; %變異率
crossoverRate=0.9; %交叉率
numberOfGenes = 30; %基因數量
tournamentSelectionParameter = 0.5; %比賽選擇參數
variableRange = 10; %變數範圍
numberOfVariables = 2;
tournamentSize = 21;
numberOfReplications = 2;
% 載入所選基準函數的資訊
[lb,ub,dim,fobj]=CEC_Function(Function_name);
% 使用CDO演算法進行最佳化，並傳回最佳目標函數值、最佳位置、收斂曲線
[Best_score,Best_pos,CDO_cg_curve]=CDO(SearchAgents_no,Max_iteration,lb,ub,dim,fobj);
% 使用GA演算法進行最佳化，並傳回最佳目標函數值、最佳位置、收斂曲線
[Best_score1,Best_pos1,GA_cg_curve]=GA(SearchAgents_no,numberOfGenes,tournamentSelectionParameter,variableRange, Max_iteration,numberOfVariables,tournamentSize,numberOfReplications, mutationRate, crossoverRate);

figure('Position',[300 300 660 290])
% 繪製搜索空間
subplot(1,2,1);
func_plot(Function_name);
title('Parameter space')
xlabel('x_1');
ylabel('x_2');
zlabel([Function_name,'( x_1 , x_2 )'])

% 繪製目標空間
subplot(1,2,2);
semilogy(CDO_cg_curve,'Color','r') %CDO收斂取線
hold on
semilogy(GA_cg_curve,'Color','b') %GA收斂取線
title('Objective space')
xlabel('Iteration');
ylabel('Best score obtained so far');
axis tight
grid on
box on
legend('CDO', 'GA')
hold off
% 顯示獲得的最佳解及對應的最佳目標函數值
display(['The best solution obtained by CDO is : ', num2str(Best_pos)]);
display(['The best optimal value of the objective funciton found by CDO is : ', num2str(Best_score)]);
display(['The best solution obtained by GA is : ', num2str(Best_pos1)]);
display(['The best optimal value of the objective funciton found by GA is : ', num2str(Best_score1)]);

