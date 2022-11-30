PercentDis = zeros(1,30);
ScriptDis = 500;
figure();
plot(SNR,AvgObj,'-sr');
xlabel("SNR(dB)");
ylabel("Mean Squared Error");
title("Relation between SNR and Recover MSE");
for i=1:30
    PercentDis(i) = ((AvgDis(i))/ScriptDis)*100;
end
figure();
plot(SNR,PercentDis,'-sg');
xlabel("SNR(dB)");
ylabel("Percentage (%)");
title("Relation between SNR and Distance Error Rate");