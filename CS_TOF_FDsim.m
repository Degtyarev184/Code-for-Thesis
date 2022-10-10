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
plot(SigRef,'g');
hold on 
plot(SigObj,'r');
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
plot(abs(CodeObj),'g');
hold all
plot(abs(CodeRef),'r');
legend('Transmitted Object','Transmitted Reference');
title('Transmitted Signal');

figure(3)
plot(abs(OutObj),'g');
hold all
plot(abs(OutRef),'r');
legend('Compressed Object','Compressed Reference');
title('Captured Signal');

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
plot(real(ifft(xpR)),'g');
xlim([0 500])
hold all
plot(real(ifft(xp)),'r');
legend('Reference','Object')
title('Processed signal')
xlabel('ms')
ylabel('Amplitude')

PCR = zeros(2,1); %Reference phase element array
PCO = zeros(2,1); %Object phase element array

for k = 1:length(PCO)
    for i = 2:length(xp)
        if(real(xp(i)) > 1)
            PCO(k) = xp(i);
            xp(i) = xp(i)*0;
            break;
        end
    end
end

for k = 1:length(PCR)
    for i = 2:length(xpR)
        if(real(xpR(i)) > 1)
            PCR(k) = xpR(i);
            xpR(i) = xpR(i)*0;
            break;
        end
    end
end

PDCO1 = atan(imag(PCO(1))/real(PCO(1)));
PDCO2 = atan(imag(PCO(2))/real(PCO(2)));

PDCR1 = atan(imag(PCR(1))/real(PCR(1)));
PDCR2 = atan(imag(PCR(2))/real(PCR(2)));

PDS1 = abs(abs(PDCR1) - abs(PDCO1));
PDS2 = abs(abs(PDCR2) - abs(PDCO2));

PDS = PhaseDelta(PDS1,PDS2);

LightSpeed = 3*10^8;
Distance = (LightSpeed/(2*abs(F2 - F1)*10^3))*(PDS/(2*pi));
fprintf('Measured Distance = %.2fm\n',Distance)