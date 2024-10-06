function main()
clear
clc
close all
% 定義邊界
lb = [-1.5, -3]; 
ub = [4, 4]; 
% 定義基因演算法的參數
popsize = 100; % 種族大小
gen = 1000; % 迭代次數
x_length = 16; % x長度
y_length = 17; % y長度
L = 33; % 基因長度
pc = 0.6; % 交叉概率
pm = 0.001; % 變異概率
pop = initpop(popsize,L);   %初始種群
for i = 1:gen % 迭代1000次
    [objvalue] = cal_objvalue(pop); % 計算函式目標值
    fitvalue = objvalue; % 令適應度等於函式值
    [newpop] = selection(pop,fitvalue);  % 選擇操作
    [newpop] = crossover(newpop,pc);     % 交叉操作
    [newpop] = mutation(newpop,pm);      % 變異操作
    pop = newpop; % 更新種群

    % 將種群的每個個體表示出來
    [A B] = binary2decimal(newpop); % 將newpop的二進制編碼轉為十進制
    [y] = cal_objvalue(newpop); % 計算nowpop的函式值
    figure(1);
    set(1, 'unit', 'normalized', 'position', [0.1,0.1,0.7,0.7]); % 設定圖形的視窗位置和大小
    if  i <= 100 & mod(i,10) == 0 % 每迭代10次做一次圖,畫100次以內的圖
        j = floor(i/10); % 計算目前迭代次數的子圖位置
        % 畫3D圖
        X = -1.5:0.1:4; % x軸座標範圍
        Y = -3:0.1:4; % y軸座標範圍
        subplot(2,5,j); % 建立2*5的子圖
        [X, Y] = meshgrid(X,Y);
        Z = (X-Y).^2 - X + 2.*Y + sin(X+Y) + 1; % 計算目標函式Z的值
        mesh(X,Y,Z);
        hold on
        title(['迭代次數為 n=' num2str(i)]); % 圖的標題
        plot3(A,B,y,'*'); % 在3D圖上繪製種群的點
    end
    [bestindividual,bestfit]=best(pop,fitvalue); % 尋找最優解
    [x y] = binary2decimal(bestindividual); % 將二進位制值轉換為十進位制
    BEST(i) = bestfit; % 將目前迭代次數下的最佳適應度值存在BEST陣列的第i個位置
    X(i) = x; % 將目前迭代次數下的最佳x變數的十進制值存在X陣列的第i個位置
    Y(i) = y; % 將目前迭代次數下的最佳y變數的十進制值存在Y陣列的第i個位置

end
    [min_value,index] = min(BEST'); % 找出BEST中的最小值和它的索引值
    % 從X、Y中根據索引值取得最佳的x、y值
    best_x = X(index);
    best_y = Y(index);
    figure(2);
    set(2, 'unit', 'normalized', 'position', [0.1,0.1,0.7,0.7]);
    i = 1:1000;
    plot(i,BEST);
    axis([0,1000,-2,40]); % 圖形的座標軸範圍
    xlabel('進化代數');
    ylabel('函式值');
    text(10,30,'交叉概率pc = 0.6  變異概率pm = 0.001  進化代數1000次');
    text(10,38,['After ',num2str(index),' generations,',...
        '  the min value was got.']);
    text(10,36,[' x1 = ',num2str(best_x),'      x2= ',num2str(best_y),...
         '      min value= ', num2str(min_value)]);
    fprintf('After %.0f times iterations, min_value was got.\n',index);
    fprintf('the best x is  --->> %5.4f\n',best_x);
    fprintf('the best y is  --->> %5.4f\n',best_y);
    fprintf('the best f is   --->> %5.5f\n',min_value);
    fprintf('\n');
    fprintf('After %.0f times iterations, final_value was got.\n',1000);
    fprintf('the final x is  --->> %5.4f\n',x);
    fprintf('the final y is  --->> %5.4f\n',y);
    fprintf('the final f is   --->> %5.5f\n',bestfit);

function pop = initpop(popsize,L)
%% -------------初始化種群函式----------------
%    初始化種群大小
%       輸入變數：
%               popsize:種群大小
%               L：基因長度--》轉化的二進位制長度
%       輸出變數：
%               pop：種群
%---------------------------------------
pop = round(rand(popsize,L)); % 隨機產生一個矩陣，每一行是一個長33位染色體；

function [pop1 pop2] = binary2decimal(pop)
%% -----------解碼函式---------------------
%    二進位制轉化為十進位制數
%    輸入變數：
%        二進位制種群
%    輸出變數：
%        十進位制數值
%-----------------------------------------
% 遍歷前16位二進制數，並轉成十進制數放到pop_x
for i = 1:16
    pop_x(:,i) = 2.^(16 - i).*pop(:,i);
end
% 遍歷後17位二進制數，並轉成十進制數放到pop_y
for j = 1:17
    pop_y(:,j) = 2.^(17 - j).*pop(:,j+16);
end
% sum(.,2)對行求和，得到列向量
temp1 = sum(pop_x,2);
temp2 = sum(pop_y,2);
pop1 = -1.5 + temp1*5.5/(2^16-1); % pop1表示輸出x1的十進位制數
pop2 = -3 + temp2*7/(2^17-1);  % pop2表示輸出的x2的十進位制數

function [objvalue] = cal_objvalue(pop)
%% --------------計算函式值函式----------------------
% 計算函式目標值
%輸入變數：二進位制數值
%輸出變數：目標函式值
%---------------------------------------------
[x y] = binary2decimal(pop);
objvalue = (x-y).^2 - x + 2*y + sin(x+y) + 1;

function [newpop] = selection(pop,fitvalue)
%% -----------------根據適應度選擇函式-------------------
% 輸入變數 ：pop:二進位制種群
%           fitvalue: 適應度
%輸出變數：  newpop: 選擇以後的二進位制種群
% -------------------------------------------
[px,py] = size(pop); % 獲取種群的大小
totalfit = sum(fitvalue); % 計算fitvalue的總和
p_fitvalue = 1 ./ fitvalue / sum(1 ./ fitvalue); % 計算每個個體被選擇的概率
p_fitvalue = cumsum(p_fitvalue); % 概率求和後排序
ms = sort(rand(px,1)); % 產生一列隨機數，從小到大排列，相當於轉轉盤10次
fitin = 1; % 初始化適應度索引為 1
newin = 1; % 初始化新種群索引為 1
while newin <= px
    if(ms(newin)) < p_fitvalue(fitin) % 轉盤轉到 fitin 的位置
        newpop(newin,:) = pop(fitin,:); % 新種群的第 newin 個體為pop中的第fitin 個體
        newin = newin + 1;
    else
        fitin = fitin + 1; % 相當於每次都從第一個比較起，依次加1，直至比較完，看轉到的是哪一個
    end
end


function [newpop] = crossover(pop,pc)
%% ----------交叉函式--------------------
% 輸入變數：pop:二進位制的父代種群數
%          pc :交叉概率
% 輸出變數：newpop: 交叉後的種群數
%---------------------------------------
[px,py] = size(pop);
newpop = ones(size(pop)); % 初始化新種群為全 1 矩陣，提高運算速度
for i = 1:2:px-1  % 1與2交叉。3與4交叉。。。。。每次隔一個，因此步長為2
    if (rand<pc)  % pc = 0.6,即有60%的機會交叉
        cpoint = round(rand*py); % 交叉點隨機選取,互換交叉點以後的值
        if cpoint <= 0
          % cpoint = 1;
          continue;
        end
        newpop(i,:) = [pop(i,1:cpoint),pop(i+1,cpoint+1:py)]; % 交叉後的第i個個體
        newpop(i+1,:) = [pop(i+1,1:cpoint),pop(i,cpoint+1:py)];
    else  % 40%的機會不交叉
        newpop(i,:) = pop(i,:);
        newpop(i+1,:) = pop(i+1,:);
    end
end


function [newpop] = mutation(pop,pm)
%% ------------變異函式---------------------------
% 輸入變數 pop: 二進位制種群
%          pm : 變異概率
% 輸出變數： newpop : 變異以後的種群
%-----------------------------------------------
[px,py] = size(pop);
newpop = ones(size(pop)); % 只是起到提前宣告的作用，提高運算速度
for i = 1:px  % 對於種群中的每個個體執行變異操作
    if(rand<pm) % 如果rand小於變異概率 pm，則進行變異操作
        mpoint = round(rand*py); % 隨機選擇變異點
        if mpoint<=0
            mpoint = 1;
        end
        newpop(i,:) = pop(i,:); % 將當前個體複製到新種群中
        if newpop(i,mpoint) == 0 % 若mpoint為0，則改成1，mpoint為1，則改為0，完成變異
            newpop(i,mpoint) = 1;
        else
            newpop(i,mpoint) = 0;
        end
    else  % 如果rand >= pm，則不進行變異操作，直接把當前個體複製到新種群中
        newpop(i,:) = pop(i,:);
    end
end

function [bestindividual, bestfit] = best(pop, fitvalue)
%% --------------選出最優個體函式-----------------------
% 輸入變數： pop :種群
%           fitvalue : 種群適應度
% 輸出變數： bestindividual : 最佳個體（二進位制）
%           bestfit : 最佳適應度值
% ---------------------------------------------

[px, py] = size(pop);

% 檢查種群和適應度值的維度是否一致
if px ~= length(fitvalue)
    error('種群和適應度值的維度不一致');
end

% 確認種群不為空
if px == 0
    error('種群為空');
end

bestindividual = pop(1,:); % 初始化最佳個體為種群中的第一個個體
bestfit = fitvalue(1); % 初始化最佳適應度為種群中的第一個個體的適應度值

% 初始化最佳適應度值為一個極大的數字
bestfit = inf;

for i = 2:px % 遍歷種群中的每個個體，從第二個個體開始
    if fitvalue(i) < bestfit % 如果當前個體的適應度值比最佳適應度值更佳
        bestindividual = pop(i,:); % 更新最佳個體為當前個體
        bestfit = fitvalue(i); % 更新最佳適應度值為當前個體的適應度值
    elseif fitvalue(i) == bestfit % 如果適應度值相等
        % 隨機選擇一個作為最佳個體
        if rand < 0.5
            bestindividual = pop(i,:);
        end
    end
end
