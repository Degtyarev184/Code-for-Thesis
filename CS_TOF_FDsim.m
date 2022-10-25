clear all;
close all;
clc;

%% Create signal
Fbase = 1000; %KHz
F1 = Fbase; %KHz = 1MHz %First frequency of the signal
F2 = 1.2*Fbase; %KHz = 1.2MHz %Second frequency of the signal
PD1 = (64/6)*pi; %1st Component Phase Difference
PD2 = (64/5)*pi; %2nd Component Phase Difference
SpL = 2; %Sparse level
SampPerCyc = 60;
Fs = 10; %Sampling Frequency at 10 KHz
L = (SampPerCyc*(F1+F2)/Fs)/2; %Length of the signal reduced 4 times for faster calculation
LoopNum = SampPerCyc*(F1+F2)/1000; %Signal repeat times number
SampleShift = L/LoopNum; %Delay between sample capture
Pos = zeros(LoopNum,1); %Captured position of signal

for i=1:LoopNum
    Pos(i,1) = (i-1)*SampleShift+1;
end

CodeMatrix = randi([0 1],L,L); %Matrix for encrypting signal
SigObj = zeros(L,1); %Signal reflected from object
SigRef = zeros(L,1); %Reference signal used for comparing

for i=1:L
    SigObj(i) = cos(2*pi*F1/(Fbase*SampPerCyc)*i)+cos(2*pi*F2/(Fbase*SampPerCyc)*i)+2;
    SigRef(i) = cos(2*pi*F1/(Fbase*SampPerCyc)*i+PD1)+cos(2*pi*F2/(Fbase*SampPerCyc)*i+PD2)+2;
end

figure()
plot(SigRef,'g');
hold on 
plot(SigObj,'r');
xlim([0 1000]); %Limit for clear view of signal phase difference
legend('Reference','Object')
title('Original Signal')
xlabel('ms')
ylabel('Amplitude')

%% Capture and recover compressed signal
GrabObj = zeros(LoopNum,1); %Captured object signal
GrabRef = zeros(LoopNum,1); %Captured reference signal
Phi = zeros(LoopNum,L); %Matrix for decrypting captured signal
CodeObj = CodeMatrix*SigObj; %Encrypting reflected object signal 
CodeRef = CodeMatrix*SigRef; %Encrypting transmitted reference signal 

for i=1:LoopNum
    loc = Pos(i,1);
    GrabObj(i,1) = CodeObj(loc,1);
    GrabRef(i,1) = CodeRef(loc,1);
    Phi(i,:) = CodeMatrix(loc,:);
end

figure()
plot(CodeObj,'g');
hold all
plot(CodeRef,'r');
legend('Reflected Object','Transmitted Reference');
title('Encrypted Signal');

figure()
plot(GrabObj,'g');
hold all
plot(GrabRef,'r');
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

%% Confirm correct recovery
% figure()
% plot(real(xp))
% figure()
% plot(real(xpR))

figure()
plot(real(ifft(xpR)),'g.');
xlim([0 1000])
hold all
plot(SigRef,'r');
legend('Recovered Reference','Original Reference')
title('Recovery Verify for Reference Signal');

figure()
plot(real(ifft(xp)),'g.');
xlim([0 1000])
hold all
plot(SigObj,'r');
legend('Recovered Object','Original Object')
title('Recovery Verify for Object Signal'); 

figure()
plot(real(ifft(xpR)),'g');
xlim([0 1000]) %Limit for clear view of signal phase difference
hold all
plot(real(ifft(xp)),'r');
legend('Reference','Object')
title('Processed signal')
xlabel('ms')
ylabel('Amplitude')

%% Calculate phase difference (in frequency domain)
% PCR = zeros(2,1); %Reference phase element array
% PCO = zeros(2,1); %Object phase element array
% %Select the correct peak of object signal in frequency domain for phase recovering 
% for k = 1:length(PCO)
%     for i = 2:length(xp)
%         if(real(xp(i)) > 1 || real(xp(i)) < -1)
%             PCO(k) = xp(i);
%             xp(i) = xp(i)*0;
%             break;
%         end
%     end
% end
% 
% %Select the correct peak of reference signal in frequency domain for phase recovering
% for k = 1:length(PCR)
%     for i = 2:length(xpR)
%         if(real(xpR(i)) > 1 || real(xpR(i)) < -1)
%             PCR(k) = xpR(i);
%             xpR(i) = xpR(i)*0;
%             break;
%         end
%     end
% end
% 
% PDCO1 = abs(PhaseDelta(PCO(1))); %Recover phase of first component of object signal
% PDCO2 = abs(PhaseDelta(PCO(2))); %Recover phase of first component of object signal
% 
% PDCR1 = abs(PhaseDelta(PCR(1))); %Recover phase of first component of object signal
% PDCR2 = abs(PhaseDelta(PCR(2))); %Recover phase of first component of object signal
% 
% PD1S = PDCR1 - PDCR2; %Phase difference of first component of 2 signal
% PD2S = PDCO1 - PDCO2; %Phase difference of second component of 2 signal
% 
% PDS = abs(PD2S - PD1S); %Total phase difference
%% Calculate phase difference (in time domain)
MaxObjLoc = 0;
MaxRefLoc = 0;
Cycle = SampPerCyc*Fs/SpL;
RcvObjCyc = zeros(1,Cycle);
RcvRefCyc = zeros(1,Cycle);
RcvObj = real(ifft(xp));
RcvRef = real(ifft(xpR));

for i = 1:Cycle
    RcvObjCyc(i) = RcvObj(i);
    RcvRefCyc(i) = RcvRef(i);
end

for i = 1:length(RcvObjCyc)
    if(RcvObjCyc(i) == max(RcvObjCyc))
        MaxObjLoc = i;
        break;
    end
end

for i = 1:length(RcvRefCyc)
    if(RcvRefCyc(i) == max(RcvRefCyc))
        MaxRefLoc = i;
        break;
    end
end

LocDif = abs(MaxRefLoc - MaxObjLoc);
PDS = ((2*pi*LocDif)/Cycle);
%% Distance calculation
LightSpeed = 3e8;
Distance = (LightSpeed/(2*abs(F1-F2)*10^3))*(PDS/(2*pi));
fprintf('Measured Distance = %.2fm\n',Distance)
fprintf('Measured Distance = %.20fm\n',PD1)
fprintf('Measured Distance = %.20fm\n',PD2)
fprintf('Measured Distance = %.20fm\n',PDS)