clc
close all
clear all
DisF1 = zeros(30,30);
DisF2 = zeros(30,30);
Dis2F = zeros(30,30);
AvgDisF1 = zeros(1,30);
AvgDisF2 = zeros(1,30);
AvgDis2F = zeros(1,30);
OrgDis = [45:25:775];
for i = 1:30
    SumDisF1 = 0;
    SumDisF2 = 0;
    SumDis2F = 0;
    for j = 1:30
        DisF1(i,j) = CS_TOF_SingleFreq1(OrgDis(i));
        SumDisF1 = SumDisF1 + DisF1(i,j);
        DisF2(i,j) = CS_TOF_SingleFreq2(OrgDis(i));
        SumDisF2 = SumDisF2 + DisF2(i,j);
        Dis2F(i,j) = CS_TOF_FDsim(OrgDis(i));
        SumDis2F = SumDis2F + Dis2F(i,j);
    end
    SumDisF1 = SumDisF1/30;
    AvgDisF1(i) = SumDisF1;
    SumDisF1 = SumDisF1/30;
    AvgDisF1(i) = SumDisF1;
    SumDisF1 = SumDisF1/30;
    AvgDisF1(i) = SumDisF1;
end
AvgDis2FR = AvgDis2F';
AvgDisF1R = AvgDisF1';
AvgDisF2R = AvgDisF2';
OrgDisR = OrgDis';
figure()
plot(AvgDisF1,'-sr');
hold on
plot(AvgDisF2,'-sg');
hold on
plot(AvgDis2F,'-sb');
legend("1MHz","1.2MHz","Two Frequency");
title("Measured Distance");