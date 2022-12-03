close all
clc
figure()
plot(OrgDis,DisF1,'-xr');
hold on
plot(OrgDis,DisF2,'-xg');
hold on
plot(OrgDis,Dis2F,'-xb');
legend("1MHz","1.2MHz","Two Frequency");
title("Measured Distance");
ylabel("m");
xlabel("Preset Distance(m)");
Dis2FR = Dis2F';
DisF1R = DisF1';
DisF2R = DisF2';
OrgDisR = OrgDis';