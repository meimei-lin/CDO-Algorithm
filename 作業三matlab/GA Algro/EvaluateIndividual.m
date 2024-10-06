%% GA演算法測試的目標函式
%%我用呼叫CEC_Function的一直會有錯QQ，只好另外把函式拿出來寫
function fitnessValue = EvaluateIndividual(x,y)
    fitnessValue=sum(x.^2);
end

