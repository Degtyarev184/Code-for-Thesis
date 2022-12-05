close all
clc
AvgDis2FNR = AvgDis2FN';
AvgDisF1NR = AvgDisF1N';
AvgDisF2NR = AvgDisF2N';

MeanDisF1N = mean(DisF1N,2);
StdDisF1N = std(DisF1N,0,2);

MeanDisF2N = mean(DisF2N,2);
StdDisF2N = std(DisF2N,0,2);

MeanDis2FN = mean(Dis2FN,2);
StdDis2FN = std(Dis2FN,0,2);

OrgDisR = OrgDis';

figure()
plot(OrgDis,MeanDisF1N,'-xr');
hold on
plot(OrgDis,MeanDisF2N,'-xg');
hold on
plot(OrgDis,MeanDis2FN,'-xb');

hold on
errorbar(OrgDis,MeanDisF1N,StdDisF1N,'r');
hold on
errorbar(OrgDis,MeanDisF2N,StdDisF2N,'g');
hold on
errorbar(OrgDis,MeanDis2FN,StdDis2FN,'b');

legend("1MHz","1.2MHz","Two Frequency");
title("Measured Distance with SNR = 50dB");
ylabel("Average Measured (m)");
xlabel("Preset Distance (m)"); 