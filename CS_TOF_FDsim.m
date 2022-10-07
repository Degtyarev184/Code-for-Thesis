clear all;
close all;
clc;

Fbasis = 1000; %KHz
F1 = Fbasis; %KHz = 1MHz
F2 = 1.2*Fbasis; %KHz = 1.2MHz
PD1 = pi/6; %1st Phase Difference Component
PD2 = pi/5; %2nd Phase Difference Component
SampPerCyc = 20;
Fs = 10; %Sampling Frequency
PDS = PhaseDelta(PD1,PD2);
L = SampPerCyc*(F1+F2)/Fs; %Length of the signal
LoopNum = SampPerCyc*(F1+F2)/1000;

SampleShift = L/LoopNum;
Pos = zeros(LoopNum,1);

for i=1:LoopNum
    Pos(i,1) = (i-1)*SampleShift+1;
end
CodeMatrix = randi([0 1],L,L);
SigObj = zeros(L,1);
SigRef = zeros(L,1);

for i=1:L
    SigObj(i) = cos(2*pi*F1/(Fbasis*SampPerCyc).*i)+cos(2*pi*F2/(Fbasis*SampPerCyc).*i)+2;
    SigRef(i) = cos(2*pi*F1/(Fbasis*SampPerCyc).*i+PD1)+cos(2*pi*F2/(Fbasis*SampPerCyc).*i+PD2)+2;
end

figure(1)
plot(SigRef,'c');
hold on 
plot(SigObj,'k');
xlim([0 500]);
legend('Reference','Object')
title('Original Signal')
xlabel('ms')
ylabel('Amplitude')

OutObj = zeros(LoopNum,1);
OutRef = zeros(LoopNum,1);
Phi = zeros(LoopNum,L);

CodeObj = CodeMatrix*SigObj;
CodeRef = CodeMatrix*SigRef;

for i=1:LoopNum
    loc = Pos(i,1);
    OutObj(i,1) = CodeObj(loc,1);
    OutRef(i,1) = CodeRef(loc,1);
    Phi(i,:) = CodeMatrix(loc,:);
end

figure(2)
plot(abs(CodeObj),'c');
hold all
plot(abs(CodeRef),'k');
legend('Transmitted Object','Transmitted Reference');
title('Transmitted Signal');

figure(3)
plot(abs(OutObj),'c');
hold all
plot(abs(OutRef),'k');
legend('Compressed Object','Compressed Reference');
title('Received Signal');

Psi = inv(fft(eye(L)));
cvx_begin
    variable xp(L) complex;
    minimize(norm(xp,1));
    subject to
    Phi*Psi*xp == OutObj;
cvx_end

cvx_begin
    variable xpR(L) complex;
    minimize(norm(xpR,1));
    subject to
    Phi*Psi*xpR == OutRef;
cvx_end

figure(4)
plot(real(ifft(xpR)),'c');
xlim([0 500])
hold all
plot(real(ifft(xp)),'k');
legend('Reference','Object')
title('Processed signal')
xlabel('ms')
ylabel('Amplitude')

LightSpeed = 3*10^8;
Distance = (LightSpeed/(2*abs(F2 - F1)*10^3))*(PDS/(2*pi));
fprintf('Measured Distance = %.2fm\n',Distance)