clc
close all
clear all
DisF1N = zeros(11,11);
DisF2N = zeros(11,11);
Dis2FN = zeros(11,11);
AvgDisF1N = zeros(1,11);
AvgDisF2N = zeros(1,11);
AvgDis2FN = zeros(1,11);
OrgDis = [120 145 245 295 370 445 495 595 620 745 775];
for i = 1:11
    SumDisF1 = 0;
    SumDisF2 = 0;
    SumDis2F = 0;
    for j = 1:11
        DisF1N(i,j) = CS_TOF_SingleFreq1_Noise(OrgDis(i));
        SumDisF1 = SumDisF1 + DisF1N(i,j);
        DisF2N(i,j) = CS_TOF_SingleFreq2_Noise(OrgDis(i));
        SumDisF2 = SumDisF2 + DisF2N(i,j);
        Dis2FN(i,j) = CS_TOF_FDsim_Noise(OrgDis(i));
        SumDis2F = SumDis2F + Dis2FN(i,j);
    end
    SumDisF1 = SumDisF1/11;
    AvgDisF1N(i) = SumDisF1;
    SumDisF2 = SumDisF2/11;
    AvgDisF2N(i) = SumDisF2;
    SumDis2F = SumDis2F/11;
    AvgDis2FN(i) = SumDis2F;
end
AvgDis2FNR = AvgDis2FN';
AvgDisF1NR = AvgDisF1N';
AvgDisF2NR = AvgDisF2N';
OrgDisR = OrgDis';
figure()
plot(AvgDisF1N,OrgDis'-sr');
hold on
plot(AvgDisF2N,OrgDis'-sg');
hold on
plot(AvgDis2FN,OrgDis'-sb');
legend("1MHz","1.2MHz","Two Frequency");
title("Measured Distance with SNR = 50dB");
xlabel("Average Measured (m)");
ylabel("Preset Distance (m)"); 