close all
clc
figure()
plot(OrgDis,AvgDisF1N,'-sr');
hold on
plot(OrgDis,AvgDisF2N,'-sg');
hold on
plot(OrgDis,AvgDis2FN,'-sb');
legend("1MHz","1.2MHz","Two Frequency");
title("Measured Distance with SNR = 50dB");
ylabel("Average Measured (m)");
xlabel("Preset Distance (m)");