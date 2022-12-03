close all
clc;
ErrObjMean = mean(ErrObj,2);
ErrObjStd = std(ErrObj,0,2);
figure();
plot(SNR,ErrObjMean,'-sr');
xlabel("SNR(dB)");
ylabel("Mean Squared Error");
title("Relation between SNR and Recover MSE");
hold on
errorbar(SNR,ErrObjMean,ErrObjStd,'r');
ErrDisStd = std(ErrDis,0,2);
ErrDisMean = mean(ErrDis,2);
figure();
plot(SNR,ErrDisMean,'-sg');
xlabel("SNR(dB)");
ylabel("Percentage (%)");
title("Relation between SNR and Distance Error Rate");
hold on
errorbar(SNR,ErrDisMean,ErrDisStd,'g');