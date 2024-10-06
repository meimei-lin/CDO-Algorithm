clear all
clc
warning('off', 'all');

%% 問題參數 %%
% 可移動使用時間之電器
movable_appliances = struct(...
    'id', [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], ...
    'intervals', {{[[18, 24], [37, 46]], [[12, 17], [36, 40], [40, 46]], [[0, 16], [32, 0]], [[24, 34]], [[18, 44]], [[28, 40]], [[0, 18]], [[18, 36], [40, 46]], [[12, 16], [36, 40]], [[16, 30], [36, 44]], [[22, 28], [26, 32]], [[12, 18]]}}, ...
    'duration', {{[2, 1.5], 0.5, [3, 4], 2.5, 4, 2, 3.5, 1.5, [1, 1], 2, 1, 1}}, ...
    'power', {{1.26, 1.5, [1, 1.2], 2, 1.8, 1.1, 1.8, 0.73, 0.8, 0.38, 0.9, 0.8}});

% 固定使用時間之電器
fixed_appliances = struct(...
    'id', [1, 2, 3, 4, 5], ...
    'intervals', {{[38, 0], [0, 47], [[25, 26], [39, 40]], [16, 0], [0, 47]}}, ...
    'power', {0.3, 0.03, 3.5, 0.2, 0.01});

time_slots = 48; % 一天分成48個時段
prices = zeros(1, time_slots); % 初始化電價,所有時段默認為0

% 設置電價
prices(21:25) = 6.20; % 10:00-12:00對應時段t20~t24
prices(27:35) = 6.20; % 13:00-17:00對應時段t26-t34
prices(16:21) = 4.07; % 07:30-10:00對應時段t15-t20  
prices(25:27) = 4.07; % 12:00-13:00對應時段t24-t26
prices(35:46) = 4.07; % 17:00-22:30對應時段t34-t45
prices(1:16) = 1.87; % 00:00-07:30對應時段t0-t15
prices(46:end) = 1.87; % 22:30-00:00對應時段t45-t0

max_load = 13.2; % 最高容許負載功率(kW)
% CDO參數
SearchAgents_no = 100; % 搜索代理數量
Max_iter = 100; % 最大迭代次數
lb = 0; 
ub = time_slots - 1; 
dim = sum(cellfun(@numel, movable_appliances.intervals));

% 目標函數
fobj = @(individual) total_cost(individual, prices, movable_appliances, fixed_appliances, max_load);
% 調用CDO
[Best_score, Best_pos, CDO_cg_curve] = CDO(SearchAgents_no, Max_iter, lb, ub, dim, fobj);
% 輸出最佳解
best_schedule = reshape(Best_pos, [], dim);
disp('最優排程方案:');
current_idx = 1; % 添加一個索引變量來追踪best_schedule的當前位置

% 處理可移動電器
for i = 1:numel(movable_appliances)
    appliance = movable_appliances(i);
    intervals = appliance.intervals;
    num_intervals = numel(intervals); % 每個電器的時段數量
    appliance_schedule = best_schedule(current_idx:current_idx+num_intervals-1);
    disp(['可移動電器 ', num2str(appliance.id), '使用時段:']);
    current_idx = current_idx + num_intervals;
    
    for j = 1:num_intervals
        interval = intervals{j}; % 當前電器的一個時段
        start_time = interval(1); % 時段的開始時間
        end_time = interval(2); % 時段的結束時間
        usage = appliance_schedule(j); % 當前時段的使用情況
        if usage > 1e-6
            disp(['    使用時段 ', num2str(start_time), ' 到 ', num2str(end_time)]);
        end
    end
end

% 處理固定電器
for i = 1:numel(fixed_appliances)
    fix_appliance = fixed_appliances(i);
    intervals = fix_appliance.intervals;
    disp(['固定電器: ', num2str(fix_appliance.id), ': 使用時段:']);
    for j = 1:numel(intervals)
        interval = intervals{j}; % 當前電器的一個時段
        start_time = interval(1); % 時段的開始時間
        end_time = interval(2); % 時段的結束時間
        disp(['    使用時段 ', num2str(start_time), ' 到 ', num2str(end_time)]);
    end
end

disp(['最優總電費: $', num2str(Best_score)]);

% 繪製目標空間
subplot(1,1,1);
semilogy(CDO_cg_curve,'Color','r') % CDO收斂曲線
hold on
title('Objective space')
xlabel('Iteration');
ylabel('Best score obtained so far');
axis tight
grid on
box on
legend('CDO')
hold off
% 顯示獲得的最佳解及對應的最佳目標函數值
display(['The best solution obtained by CDO is : ', num2str(Best_pos)]);
display(['The best optimal value of the objective function found by CDO is : ', num2str(Best_score)]);
%% 解碼函式
function schedule = DecodeChromosome(chrom, movable_appliances, fixed_appliances)
    num_movable = numel(movable_appliances);
    schedule = struct('intervals', {}, 'duration', {});
    chrom = randi([0, 1], 1, 50);
    idx = 1; % 初始化索引
    
    % 解碼可移動電器
    for i = 1:num_movable
        intervals_cell = movable_appliances(i).intervals; % 獲取可移動電器的時段範圍
        durations_cell = movable_appliances(i).duration;  % 獲取可移動電器的持續時間
        num_intervals = numel(intervals_cell); % 時段範圍的數量
        schedule(i).intervals = {};
        schedule(i).duration = {};

        for j = 1:num_intervals
            interval = intervals_cell{j};
            duration = durations_cell{j};
            if any(isempty(interval)) || any(duration == 0)
                continue; % 時段空或者持續時間為0，則跳過
            end
            start_time = interval(1:2:end); % 取得時段的開始時間
            end_time = interval(2:2:end); % 取得時段的結束時間
            for k = 1:size(interval, 1)
                s = start_time(k);
                e = end_time(k);
                if idx + (e - s) - 1 > numel(chrom)
                    break; % 如果索引超出範圍，跳過這個時段
                end
                chromosome_part = chrom(idx:idx + (e - s) - 1);
                disp(['chromosome_part:', num2str(chromosome_part)]);
                req_duration = duration(k);

                if s <= e && s > 0 && e <= numel(chrom) % 確保索引不會超出範圍
                    for t = s:e-1
                        if chromosome_part(t - s + 1) == 1
                            end_time_actual = t + req_duration - 1;
                            if any(end_time_actual) <= e && any(chromosome_part(t - s + 1:end_time_actual - s) == 1)
                                schedule(i).intervals{end+1} = [t, end_time_actual];
                                schedule(i).duration{end+1} = req_duration;
                                chromosome_part(t - s + 1:end_time_actual - s + 1) = 0; % 標記已使用的時間段
                            end
                        end
                    end
                end
            end
            idx = idx + (e - s); % 更新索引
        end
    end

    % 將固定電器加入到排程中
    num_fixed = numel(fixed_appliances);
    for i = 1:num_fixed
        schedule(num_movable + i).intervals = fixed_appliances(i).intervals;
    end
end

function cost = total_cost(chrom, prices, movable_appliances, fixed_appliances, max_load)
    schedule = DecodeChromosome(chrom, movable_appliances, fixed_appliances); % 解碼排程
    time_slots = 48;
    % 計算可移動電器的電費
    movable_cost = 0;
    for i = 1:numel(movable_appliances)
        power = movable_appliances(i).power; % 獲取電器的功率
        intervals = schedule(i).intervals; % 獲取電器的使用時段
        durations = schedule(i).duration; % 獲取電器的使用時長
        
        if isempty(intervals)
            continue; % 若該電器未被安排使用，則跳過
        end
        for j = 1:numel(intervals)
            interval = intervals{j}; % 當前時段
            duration = durations{j}; % 當前時段的持續時間
            power_j = power{j}; % 當前時段的功率
            
            for t = interval(1):interval(2)-1
                t_mod = mod(t-1, time_slots) + 1; % 考慮0點的情況
                movable_cost = movable_cost + power_j * prices(t_mod) * 0.5; % 計算可移動電器的電費
            end
        end
    end
    
    % 計算固定電器電費
    fixed_cost = 0;
    for i = 1:numel(fixed_appliances)
        power = fixed_appliances(i).power; % 獲取電器的功率
        intervals = fixed_appliances(i).intervals; % 獲取電器的使用時段
        for j = 1:numel(intervals)
            start_time = intervals{j}(1); % 起始時段
            end_time = intervals{j}(2); % 結束時段
            if start_time <= end_time
                for t = start_time:end_time
                    t_mod = mod(t-1, time_slots) + 1; % 考慮0點的情況
                    fixed_cost = fixed_cost + power * prices(t_mod) * 0.5; 
                end
            else
                % 處理跨越0點的時間段
                for t = start_time:time_slots
                    t_mod = mod(t-1, time_slots) + 1;
                    fixed_cost = fixed_cost + power * prices(t_mod) * 0.5;
                end
                for t = 1:end_time
                    t_mod = mod(t-1, time_slots) + 1; 
                    fixed_cost = fixed_cost + power * prices(t_mod) * 0.5;
                end
            end
        end
    end
    cost = movable_cost + fixed_cost; % 總電費

    % 檢查總負載約束
    for t = 0:time_slots-1
        % 可移動電器的負載
        movable_load = 0;
        for i = 1:numel(movable_appliances)
            intervals = schedule(i).intervals;
            for j = 1:numel(intervals)
                if intervals{j}(1) <= t && t <= intervals{j}(end)
                    movable_load = movable_load + movable_appliances(i).power{j};
                end
            end
        end
        % 固定電器的負載
        fixed_load = 0;
        for i = 1:numel(fixed_appliances)
            intervals = fixed_appliances(i).intervals;
            power = fixed_appliances(i).power;
            for j = 1:length(intervals)
                ts = intervals{j}(1);
                tf = intervals{j}(2);
                if ts <= tf
                    if ts <= t && t <= tf
                        fixed_load = fixed_load + power;
                    end
                else
                    if ts <= t || t <= tf
                        fixed_load = fixed_load + power;
                    end
                end
            end
        end
        total_load = movable_load + fixed_load;
        if total_load > max_load
            break;
        end
    end
end

