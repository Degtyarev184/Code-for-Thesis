clc
close all
clear all
DisF1 = zeros(1,30);
DisF2 = zeros(1,30);
Dis2F = zeros(1,30);
OrgDis = [45:25:775];
for i = 1:30
    DisF1(i) = CS_TOF_SingleFreq1(OrgDis(i));
    DisF2(i) = CS_TOF_SingleFreq2(OrgDis(i));
    Dis2F(i) = CS_TOF_FDsim(OrgDis(i));
end
Dis2FR = Dis2F';
DisF1R = DisF1';
DisF2R = DisF2';
OrgDisR = OrgDis';
figure()
plot(DisF1,'-sr');
hold on
plot(DisF2,'-sg');
hold on
plot(Dis2F,'-sb');
legend("1MHz","1.2MHz","Two Frequency");
title("Measured Distance");