 % 使用這個函式初始化搜索代理的第一代群體
function Positions=initialization(SearchAgents_no,dim,ub,lb)

Boundary_no= size(ub,2); % 邊界的數量，獲取ub的列數

% 如果ub跟lb相同(維度是1)，則在給定的搜索空間範圍内隨機初始化代理的位置
if Boundary_no==1
    Positions=rand(SearchAgents_no,dim).*(ub-lb)+lb;
end

% 如果維度邊界數量>1，代表搜索空間中每個維度的lb和ub是不同的
if Boundary_no>1
    for i=1:dim % 逐步處理每個維度
        ub_i=ub(i); % 當前維度的上界
        lb_i=lb(i); % 當前維度的下界
        Positions(:,i)=rand(SearchAgents_no,1).*(ub_i-lb_i)+lb_i;
    end
end