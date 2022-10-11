clear all;
close all;
clc;

%% Create signal
Fbasis = 1000; %KHz
F1 = Fbasis; %KHz = 1MHz
F2 = 1.2*Fbasis; %KHz = 1.2MHz
PD1 = pi/6; %1st Component Phase Difference
PD2 = pi/5; %2nd Component Phase Difference
SampPerCyc = 20; %Amount of captured sample
Fs = 10; %Sampling Frequency
L = SampPerCyc*(F1+F2)/Fs; %Length of the signal
LoopNum = SampPerCyc*(F1+F2)/1000; %Number of repeat signal
SampleShift = L/LoopNum; %Delay between signal
Pos = zeros(LoopNum,1); %Captured position of signal

for i=1:LoopNum
    Pos(i,1) = (i-1)*SampleShift+1;
end

CodeMatrix = randi([0 1],L,L); %Matrix for encrypting signal
SigObj = zeros(L,1); %Signal reflected from object
SigRef = zeros(L,1); %Reference signal used for comparing

for i=1:L
    SigObj(i) = cos(2*pi*F1/(Fbasis*SampPerCyc).*i)+cos(2*pi*F2/(Fbasis*SampPerCyc).*i)+2;
    SigRef(i) = cos(2*pi*F1/(Fbasis*SampPerCyc).*i+PD1)+cos(2*pi*F2/(Fbasis*SampPerCyc).*i+PD2)+2;
end

figure(1)
plot(SigRef,'g');
hold on 
plot(SigObj,'r');
%xlim([0 500]); %Limit for clear view of signal phase difference
legend('Reference','Object')
title('Original Signal')
xlabel('ms')
ylabel('Amplitude')

%% Capture and recover compressed signal
GrabObj = zeros(LoopNum,1); %Captured object signal
GrabRef = zeros(LoopNum,1); %Captured reference signal
Phi = zeros(LoopNum,L); %Matrix for decrypting captured signal
CodeObj = CodeMatrix*SigObj; %Encrypted object signal be transmitted
CodeRef = CodeMatrix*SigRef; %Encrypted reference signal be transmitted

for i=1:LoopNum
    loc = Pos(i,1);
    GrabObj(i,1) = CodeObj(loc,1);
    GrabRef(i,1) = CodeRef(loc,1);
    Phi(i,:) = CodeMatrix(loc,:);
end

figure(2)
plot(abs(CodeObj),'g');
hold all
plot(abs(CodeRef),'r');
legend('Transmitted Object','Transmitted Reference');
title('Transmitted Signal');

figure(3)
plot(abs(GrabObj),'g');
hold all
plot(abs(GrabRef),'r');
legend('Compressed Object','Compressed Reference');
title('Captured Signal');

Psi = inv(fft(eye(L))); %Coding matrix
%Recover object signal
cvx_begin
    variable xp(L) complex;
    minimize(norm(xp,1));
    subject to
    Phi*Psi*xp == GrabObj;
cvx_end

%Recover reference signal
cvx_begin
    variable xpR(L) complex;
    minimize(norm(xpR,1));
    subject to
    Phi*Psi*xpR == GrabRef;
cvx_end

figure(4)
plot(real(ifft(xpR)),'g');
%xlim([0 500]) %Limit for clear view of signal phase difference
hold all
plot(real(ifft(xp)),'r');
legend('Reference','Object')
title('Processed signal')
xlabel('ms')
ylabel('Amplitude')

%% Calculate signal difference and final simulation result
PCR = zeros(2,1); %Reference phase element array
PCO = zeros(2,1); %Object phase element array

%Selecting 
for k = 1:length(PCO)
    for i = 2:length(xp)
        if(real(xp(i)) > 1)
            PCO(k) = xp(i);
            xp(i) = xp(i)*0;
            break;
        end
    end
end

%Select the correct 
for k = 1:length(PCR)
    for i = 2:length(xpR)
        if(real(xpR(i)) > 1)
            PCR(k) = xpR(i);
            xpR(i) = xpR(i)*0;
            break;
        end
    end
end

PDCO1 = atan(imag(PCO(1))/real(PCO(1))); %Recover phase of first component of object signal
PDCO2 = atan(imag(PCO(2))/real(PCO(2))); %Recover phase of second component of object signal

PDCR1 = atan(imag(PCR(1))/real(PCR(1))); %Recover phase of first component of reference signal
PDCR2 = atan(imag(PCR(2))/real(PCR(2))); %Recover phase of second component of reference signal

PDS1 = abs(abs(PDCR1) - abs(PDCO1)); %Phase difference of first component of 2 signal
PDS2 = abs(abs(PDCR2) - abs(PDCO2)); %Phase difference of second component of 2 signal

PDS = PhaseDelta(PDS1,PDS2); %Total phase difference

LightSpeed = 3*10^8;
Distance = (LightSpeed/(2*abs(F2 - F1)*10^3))*(PDS/(2*pi));
fprintf('Measured Distance = %.2fm\n',Distance)