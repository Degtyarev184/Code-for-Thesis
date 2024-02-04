close all
clc;
ErrDisAbs = abs(ErrDis);
LoopNum = [60:5:105];
LoopNum = LoopNum*2.2;
ErrObjMean = flip(mean(ErrObj,2));
ErrObjStd = std(ErrObj,0,2);
figure();
plot(LoopNum,ErrObjMean,'-sr');
xlabel("Samples");
ylabel("Mean Squared Error");
title("Relation between Samples Number and Recover MSE");
hold on
% errorbar(LoopNum,ErrObjMean,ErrObjStd,'r');
ErrDisStd = std(ErrDisAbs,0,2);
ErrDisMean = flip(mean(ErrDisAbs,2));
figure();
plot(LoopNum,ErrDisMean,'-sg');
xlabel("Samples");
ylabel("Percentage (%)");
title("Relation between Samples Number and Distance Error Rate");
hold on
% errorbar(LoopNum,ErrDisMean,ErrDisStd,'g');