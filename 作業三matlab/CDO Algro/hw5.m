clear all
clc
warning('off', 'all');

%%問題參數%%
%%可移動使用時間之電器
movable_appliances = struct(...
    'id', [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], ...
    'intervals', {{[[18, 24], [37, 46]], [[12, 17], [36, 40], [40, 46]], [[0, 16], [32, 0]], [[24, 34]], [[18, 44]], [[28, 40]], [[0, 18]], [[18, 36], [40, 46]], [[12, 16], [36, 40]], [[16, 30], [36, 44]], [[22, 28], [26, 32]], [[12, 18]]}}, ...
    'duration', {{[2, 1.5], 0.5, [3, 4], 2.5, 4, 2, 3.5, 1.5, [1, 1], 2, 1, 1}}, ...
    'power', {{1.26, 1.5, [1, 1.2], 2, 1.8, 1.1, 1.8, 0.73, 0.8, 0.38, 0.9, 0.8}});

%%固定使用時間之電器
fixed_appliances = struct(...
    'id', {1, 2, 3, 4, 5}, ...
    'intervals', {{[38, 0], [0, 47], [[25, 26], [39, 40]], [16, 0], [0, 47]}}, ...
    'power', {0.3, 0.03, 3.5, 0.2, 0.01});


time_slots = 48; % 一天分成48個時段
prices = zeros(1, time_slots); % 初始化電價,所有時段默認為0

%% 因為matlab索引從1開始，所以每個時段的代號都加1
prices(21:25) = 6.20; % 10:00-12:00對應時段t20~t24
prices(27:35) = 6.20; % 13:00-17:00對應時段t26-t34
prices(16:21) = 4.07; % 07:30-10:00對應時段t15-t20  
prices(25:27) = 4.07; % 12:00-13:00對應時段t24-t26
prices(35:46) = 4.07; % 17:00-22:30對應時段t34-t45
prices(1:16) = 1.87; % 00:00-07:30對應時段t0-t15
prices(46:1) = 1.87; % 22:30-00:00對應時段t45-t0

max_load = 13.2; % 最高容許負載功率(kW)

%% CDO參數
SearchAgents_no = 100; % 搜索代理數量
Max_iter = 10; % 最大迭代次數
lb = 0; 
ub = time_slots - 1; 
dim = sum(cellfun(@numel, movable_appliances.intervals));

%% 目標函數
fobj = @(individual) total_cost(individual, prices, movable_appliances, fixed_appliances, max_load);

%% 設置終止條件
obj_threshold = 1e-6; % 目標函數值變化閾值
prev_best_score = inf; % 初始化前一次最優目標函數值
stagnation_counter = 0; % 停滯迭代次數計數器
max_stagnation_iter = 50; % 最大停滯迭代次數

%% 迭代尋找最優解
iter = 1;
while iter <= Max_iter
    disp(['iter:',num2str(iter)]);
    % 調用CDO
    [Best_score, Best_pos, CDO_cg_curve] = CDO(SearchAgents_no, Max_iter, lb, ub, dim, fobj);
    
    % 檢查目標函數值變化
    if abs(prev_best_score - Best_score) < obj_threshold
        stagnation_counter = stagnation_counter + 1;
    else
        stagnation_counter = 0; 
    end
    
    prev_best_score = Best_score;
    iter = iter + 1;
end
   
    %% 輸出最佳解
    best_schedule = reshape(Best_pos, [], dim);
    disp('最優排程方案:');
    idx = 1;
    for i = 1:numel(movable_appliances.id)
        appliance_id = num2str(movable_appliances.id(i));
        intervals = movable_appliances.intervals{i};
        num_intervals = numel(intervals);
        appliance_schedule = best_schedule(idx:idx+num_intervals-1);
        appliance_schedule = round(appliance_schedule);
        idx = idx + num_intervals;
        
        used_intervals_idx = find(appliance_schedule > 1);
        %used_intervals = intervals(appliance_schedule(i));
        used_durations = movable_appliances.duration{i};
        disp(['used_durations:', num2str(used_durations)]);
        disp(['used_intervals:', num2str(appliance_schedule)]);
        used_durations_i = used_durations(i);
        appliance_schedule_i = appliance_schedule(i:2);
        disp(['used_durations_i:',num2str(used_durations_i)]);
        disp(['appliance_schedule_i:',num2str(appliance_schedule_i)]);
        %used_durations = used_durations(used_intervals_idx);
        
        disp(['可移動電器: ', num2str(appliance_id), ': 使用時段: ',num2str(appliance_schedule_i:2),' 持續時間: ', num2str(used_durations_i)]);
    end
    for i = 1:numel(fixed_appliances.id)
        appliance_id = num2str(fixed_appliances.id(i));
        intervals = fixed_appliances.intervals{i};
        disp(['固定電器: ', appliance_id, ': 使用時段: ', ...
            strjoin(cellfun(@(x) ['[' num2str(x(1)) ' ' num2str(x(2)) ']'], intervals, 'UniformOutput', false), ', ')]);
    end
    disp(['最優總電費: $', num2str(Best_score)]);
    
    % 繪製目標空間
    subplot(1,1,1);
    semilogy(CDO_cg_curve,'Color','r') %CDO收斂曲線
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
function schedule = DecodeChromosome(chrom, movable_appliances, fixed_appliances)
    num_movable = numel(movable_appliances.id); % 可移動電器數量
    num_fixed = numel(fixed_appliances); % 固定電器數量
    schedule = struct('intervals', {}, 'duration', {}); % 初始化儲存解碼結果的結構體
    idx = 1;
    %disp(['num_movable: ', num2str(num_movable)]);
    
    % 解碼可移動電器
    for i = 1:num_movable
        intervals1_cell = movable_appliances(1).intervals; % 獲取可移動電器的時段範圍
        durations_cell = movable_appliances(1).duration;  % 獲取可移動電器的持續時間
        %disp(['intervals_cell: ', intervals1_cell]);
        num_intervals = numel(intervals1_cell); % 時段範圍的數量
        %disp(['num_intervals: ', num2str(num_intervals)]);
        idx = idx + num_intervals;
        schedule(i).intervals = {};
        schedule(i).duration = {};
        %disp(['numel(durations_cell): ', num2str(numel(durations_cell))]);
        %disp(['durations_cell: ', durations_cell]);
        
        for j = 1:num_intervals
            interval = intervals1_cell{j};
            duration = durations_cell{j};
            if any(isempty(interval)) || any(duration == 0)
                continue; % 時段空或者持續時間為0，則跳過
            end
            start_time = interval(1:2:end); % 取得時段的開始時間
            end_time = interval(2:2:end); % 取得時段的結束時間
            for k = 1:length(start_time)
                s = start_time(k);
                e = end_time(k);
                if idx + (e - s) - 1 > numel(chrom)
                    break; % 如果索引超出範圍，跳過這個時段
                end
                chromosome_part = chrom(idx:idx + (e - s) - 1);
                %disp(['chromosome_part: ', num2str(chromosome_part)]);
                %disp(['start_time: ', num2str(s)]);
                %disp(['end_time: ', num2str(e)]);
                if iscell(durations_cell) && numel(durations_cell) == 1
                    req_duration = durations_cell{1};
                else
                    req_duration = durations_cell{j};
                end
                
                if iscell(req_duration)
                    req_duration = req_duration{1};
                end
                
                if all(s <= e) && all(s > 0) && all(e <= numel(chrom)) % 確保索引不會超出範圍
                    %disp(['numel(chrom):', num2str(numel(chrom))]);
                    for t = s:e-1
                        %disp(['t:', num2str(t),'s:', num2str(s),'e:', num2str(e)]);
                        if chromosome_part(t - s + 1) == 1 % 對應的 chromosome_part 索引
                            %disp(['req_duration:',num2str(req_duration)]);
                            end_time_actual = t + req_duration - 1;
                            %disp(['end_time_actual:',num2str(end_time_actual)]);
                            if all(end_time_actual <= e) && any(chromosome_part(t - s + 1:end_time_actual - s ) == 1)
                                schedule(i).intervals{end+1} = [t, end_time_actual];
                                schedule(i).duration{end+1} = req_duration;
                                chromosome_part(t - s + 1:end_time_actual - s + 1) = 0; % 標記已使用的時間段
                            end
                        end
                    end
                end
            end
        end
    end
    
    % 解碼固定電器
    for i = 1:num_fixed
        intervals1_cell = fixed_appliances(i).intervals;
        schedule(num_movable + i).intervals = {};
        schedule(num_movable + i).duration = {};
        for j = 1:2:numel(intervals1_cell)
            start_time = intervals1_cell{j};
            end_time = intervals1_cell{2};
            schedule(num_movable + i).intervals{end+1} = [start_time, end_time]; % 存儲為 cell 陣列
        end
    end
end

%% 計算總電費
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
        %disp(['numel(intervals):',numel(intervals)]);
        for j = 1:numel(intervals)/2
            %disp(['j:',num2str(j)]);
            interval = intervals(j); % 當前時段
            %disp(['interval:',interval]);
            duration = cell2mat(durations(j)); % 當前時段的持續時間
            %disp(['duration:',num2str(duration)]);
            %disp(['numel(intervals):',num2str(numel(intervals))]);
            power_j = power(j); % 當前時段的功率
            power_j = cell2mat(power_j);
            %disp(['power_j:',num2str(power_j)])
            
            for t = interval
                %disp(['t:',t]);
                t = cell2mat(t);
                t = round(t);
                %disp(['prices{t+1}:',num2str(prices(t+1))])
                for k = 1:length(duration)
                    for j = 1:length(prices(t+1))
                        duration_k = duration(k);
                        prices_j = prices(j);
                        movable_cost = movable_cost + power_j * duration_k * prices_j * 0.5; % 計算可移動電器的電費
                        %disp(['movable_cost:',num2str(movable_cost)]);
                    end
                end
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
            cost = cost + 1e6; % 超出負載約束時添加懲罰分
            break;
        end
    end
end

