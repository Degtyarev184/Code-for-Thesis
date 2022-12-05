clc
close all
LoopNum = [60:5:105];
ErrObj = zeros(10,10);
ErrDis = zeros(10,10);
Dis = zeros(10,10);
AvgObj = zeros(1,10);
AvgDis = zeros(1,10);
for i=1:10
    SumObj = 0;
    SumDis = 0;
    for j=1:10
        [ErrObj(i,j),Dis(i,j),ErrDis(i,j)] = CS_TOF_FDsim_Noise(LoopNum(i));
        SumObj = SumObj + ErrObj(i,j);
        SumDis = SumDis + ErrDis(i,j);
    end
    SumObj = SumObj/10;
    AvgObj(i) = SumObj;
    SumDis = SumDis/10;
    AvgDis(i) = SumDis;
end
save('EvaluationSim2.mat');