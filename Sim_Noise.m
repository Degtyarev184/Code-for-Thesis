clc
close all
clear all
DisF1N = zeros(30,30);
DisF2N = zeros(30,30);
Dis2FN = zeros(30,30);
OrgDis =[45:25:775];
for i = 1:1
    for j = 1:10
        DisF1N(i,j) = CS_TOF_SingleFreq1_Noise(OrgDis(i));
        DisF2N(i,j) = CS_TOF_SingleFreq2_Noise(OrgDis(i));
        Dis2FN(i,j) = CS_TOF_FDsim_Noise(OrgDis(i));
    end
end
AvgDis2FN = mean(Dis2FN,2);
AvgDisF1N = mean(DisF1N,2);
AvgDisF2N = mean(DisF2N,2);
AvgDis2FNR = AvgDis2FN';
AvgDisF1NR = AvgDisF1N';
AvgDisF2NR = AvgDisF2N';
OrgDisR = OrgDis';
figure()
plot(AvgDisF1N,'-sr');
hold on
plot(AvgDisF2N,'-sg');
hold on
plot(AvgDis2FN,'-sb');
legend("1MHz","1.2MHz","Two Frequency");
title("Measured Distance with SNR = 50dB");
xlabel("Average Measured (m)");
ylabel("Preset Distance (m)"); 