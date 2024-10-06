% 用來繪製基準函數
function func_plot(func_name)
% 獲取函數的界限、維度和目標函數
[lb,ub,dim,fobj]=CEC_Function(func_name);

switch func_name 
    case 'F1' 
        x=-100:2:100; y=x; % 設定 x 和 y 的範圍為 [-100,100]，以步長為 2
    case 'F2' 
        x=-100:2:100; y=x; % 設定 x 和 y 的範圍為 [-100,100]，以步長為 2
    case 'F3' 
        x=-100:2:100; y=x; % 設定 x 和 y 的範圍為 [-100,100]，以步長為 2
    case 'F4' 
        x=-100:2:100; y=x; % 設定 x 和 y 的範圍為 [-100,100]，以步長為 2
    case 'F5' 
        x=-200:2:200; y=x; % 設定 x 和 y 的範圍為 [-200,200]，以步長為 2
    case 'F6' 
        x=-100:2:100; y=x; % 設定 x 和 y 的範圍為 [-100,100]，以步長為 2
    case 'F7' 
        x=-1:0.03:1;  y=x; % 設定 x 和 y 的範圍為 [-1,1]，以步長為 0.03
    case 'F8' 
        x=-500:10:500;y=x; % 設定 x 和 y 的範圍為 [-500,500]，以步長為 10
    case 'F9' 
        x=-5:0.1:5;   y=x; % 設定 x 和 y 的範圍為 [-5,5]，以步長為 0.1
    case 'F10' 
        x=-20:0.5:20; y=x; % 設定 x 和 y 的範圍為 [-20,20]，以步長為 0.5
    case 'F11' 
        x=-500:10:500; y=x; % 設定 x 和 y 的範圍為 [-500,500]，以步長為 10
    case 'F12' 
        x=-10:0.1:10; y=x; % 設定 x 和 y 的範圍為 [-10,10]，以步長為 0.1
    case 'F13' 
        x=-5:0.08:5; y=x; % 設定 x 和 y 的範圍為 [-5,5]，以步長為 0.08
    case 'F14' 
        x=-100:2:100; y=x; % 設定 x 和 y 的範圍為 [-100,100]，以步長為 2
    case 'F15' 
        x=-5:0.1:5; y=x; % 設定 x 和 y 的範圍為 [-5,5]，以步長為 0.1
    case 'F16' 
        x=-1:0.01:1; y=x; % 設定 x 和 y 的範圍為 [-1,1]，以步長為 0.01
    case 'F17' 
        x=-5:0.1:5; y=x; % 設定 x 和 y 的範圍為 [-5,5]，以步長為 0.1
    case 'F18' 
        x=-5:0.06:5; y=x; % 設定 x 和 y 的範圍為 [-5,5]，以步長為 0.06
    case 'F19' 
        x=-5:0.1:5; y=x; % 設定 x 和 y 的範圍為 [-5,5]，以步長為 0.1
    case 'F20' 
        x=-5:0.1:5; y=x; % 設定 x 和 y 的範圍為 [-5,5]，以步長為 0.1
    case 'F21' 
        x=-5:0.1:5; y=x; % 設定 x 和 y 的範圍為 [-5,5]，以步長為 0.1
    case 'F22' 
        x=-5:0.1:5; y=x; % 設定 x 和 y 的範圍為 [-5,5]，以步長為 0.1
    case 'F23' 
        x=-5:0.1:5; y=x; % 設定 x 和 y 的範圍為 [-5,5]，以步長為 0.1  
end    

    

L=length(x);
f=[];
%遍歷x、y每一個組合，並檢查是否為F15、F19、F20、F21、F22、F23特殊函數
for i=1:L
    for j=1:L
        if strcmp(func_name,'F15')==0 && strcmp(func_name,'F19')==0 && strcmp(func_name,'F20')==0 && strcmp(func_name,'F21')==0 && strcmp(func_name,'F22')==0 && strcmp(func_name,'F23')==0
            f(i,j)=fobj([x(i),y(j)]); % 計算目標函數的值
        end
        %%用來處理特殊函數，例如:矩陣大小不相容無法運算，需把運算的矩陣大小轉換成能運算的形式
        if strcmp(func_name,'F15')==1
            f(i,j)=fobj([x(i),y(j),0,0]);
        end
        if strcmp(func_name,'F19')==1
            f(i,j)=fobj([x(i),y(j),0]);
        end
        if strcmp(func_name,'F20')==1
            f(i,j)=fobj([x(i),y(j),0,0,0,0]);
        end       
        if strcmp(func_name,'F21')==1 || strcmp(func_name,'F22')==1 ||strcmp(func_name,'F23')==1
            f(i,j)=fobj([x(i),y(j),0,0]);
        end          
    end
end

surfc(x,y,f,'LineStyle','none');% 繪製三維曲面圖

end