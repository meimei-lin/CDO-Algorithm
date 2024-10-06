function [Alpha_score, Alpha_pos, Convergence_curve] = CDO(SearchAgents_no, Max_iter, lb, ub, dim, fobj)
    % 初始化Alpha、Beta和Gamma的位置和分數
    Alpha_pos = zeros(1, dim); % Alpha的位置
    Alpha_score = inf; % Alpha的分數，對於最小化問題設為inf，最大化問題設為-inf

    Beta_pos = zeros(1, dim); % Beta的位置
    Beta_score = inf; % Beta的分數

    Gamma_pos = zeros(1, dim); % Gamma的位置
    Gamma_score = inf; % Gamma的分數

    % 初始化搜索代理的位置
    %Positions = randi([0, 1], SearchAgents_no, dim); % 使用initialization函式初始化搜索代理的位置
    Positions = initialization(SearchAgents_no,dim,ub,lb);
    Convergence_curve = zeros(1, Max_iter); % 初始化收斂曲線

    l = 0; % 迴圈計數器

    % 主迴圈
    while l < Max_iter
        for i = 1:size(Positions, 1)
            % 將超出搜索空間邊界的搜索代理返回到邊界內
            Flag4ub = Positions(i, :) > ub;
            Flag4lb = Positions(i, :) < lb;
            Positions(i, :) = (Positions(i, :) .* ~(Flag4ub + Flag4lb)) + ub .* Flag4ub + lb .* Flag4lb;

            % 計算每個搜索代理的目標函數值
            fitness = fobj(Positions(i, :));
            
            % 更新Alpha、Beta和Gamma的位置和分數
            if fitness < Alpha_score
                Alpha_score = fitness; % 更新Alpha的分數
                Alpha_pos = Positions(i, :); % 更新Alpha的位置
            elseif fitness < Beta_score
                Beta_score = fitness; % 更新Beta的分數
                Beta_pos = Positions(i, :); % 更新Beta的位置
            elseif fitness < Gamma_score
                Gamma_score = fitness; % 更新Gamma的分數
                Gamma_pos = Positions(i, :); % 更新Gamma的位置
            end
        end
        
        WSh = 3 - l * (3 / Max_iter); % 線性地從3減少到0
        
        Sa = (log10((16000 - 1) * rand(1, 1) + 16000)); % 計算Sa，alpha粒子的速度為每秒16000km
        Sb = (log10((270000 - 1) * rand(1, 1) + 270000)); % 計算Sb，beta粒子的速度為每秒270000km
        Sr = (log10((300000 - 1) * rand(1, 1) + 300000)); % 計算Sr，gamma粒子的速度為每秒300000km
                
        % 更新搜索代理的位置
        for i = 1:size(Positions, 1)
            for j = 1:size(Positions, 2)
                % 更新Alpha
                r1 = rand(); % 隨機數r1在[0,1]之間
                r2 = rand(); % 隨機數r2在[0,1]之間
                pa = pi * r1 * r1 / (0.25 * Sa) - WSh * rand(); % 計算pa，論文的公式(23)
                Aa = r2 * r2 * pi; %公式(27)

                D_alpha = abs(Aa * Alpha_pos(j) - Positions(i, j)); %公式(26)
                va = 0.25 * (Alpha_pos(j) - pa * D_alpha); % 公式(22)

                % 更新Beta
                r1 = rand(); % 隨機數r1在[0,1]之間
                r2 = rand(); % 隨機數r2在[0,1]之間
                pb = pi * r1 * r1 / (0.5 * Sb) - WSh * rand(); % 計算pb，公式(17)
                Ab = r2 * r2 * pi;  %公式(21)

                D_beta = abs(Ab * Beta_pos(j) - Positions(i, j)); %公式(20)
                vb = 0.5 * (Beta_pos(j) - pb * D_beta); % 計算vb，公式(16)

                % 更新Gamma
                r1 = rand(); % 隨機數r1在[0,1]之間
                r2 = rand(); % 隨機數r2在[0,1]之間
                pr = (pi * r1 * r1) / Sr - WSh * rand(); % 計算pr，公式(11)
                Ar = r2 * r2 * pi;  %公式(15)

                D_gamma = abs(Ar * Gamma_pos(j) - Positions(i, j)); %公式(14)
                vr = Gamma_pos(j) - pr * D_gamma; % 計算vr，公式(10)

                Positions(i, j) = (va + vb + vr) / 3; % 更新位置，公式(28)
            end
        end
        
        l = l + 1;    
        Convergence_curve(l) = Alpha_score; % 更新收斂曲線
        
    end
end
