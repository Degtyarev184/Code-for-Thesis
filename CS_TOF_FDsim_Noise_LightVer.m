clc
clear all
close all
%% Create signal
LightSpeed = 3e8;
OrgDis = 775; %m
Fbase = 1000; %KHz
F1 = Fbase; %KHz = 1MHz %First frequency of the signal
F2 = 1.2*Fbase; %KHz = 1.2MHz %Second frequency of the signal
PD1 = (2*pi*10^3*2*F1*OrgDis)/LightSpeed; %1st Component Phase Difference
PD2 = (2*pi*10^3*2*F2*OrgDis)/LightSpeed; %2nd Component Phase Difference
SpL = 2; %Sparse level
SampPerCyc = 60;
Fs = 10; %Sampling Frequency at 10 KHz
L = (SampPerCyc*(F1+F2)/Fs)/2; %Length of the signal reduced 2 times for faster calculation
LoopNum = SampPerCyc*(F1+F2)/1000; %Signal repeat times number
SampleShift = L/LoopNum; %Delay between sample capture
Pos = zeros(LoopNum,1); %Captured position of signal
RealGrabRef = zeros(L,1);
RealGrabObj = zeros(L,1);

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
NoiseCodeObj = awgn(CodeObj,50,'measured');
for i=1:LoopNum
    loc = Pos(i,1);
    GrabObj(i,1) = NoiseCodeObj(loc,1);
    GrabRef(i,1) = CodeRef(loc,1);
    Phi(i,:) = CodeMatrix(loc,:);
    RealGrabObj(i*SampleShift,1) = GrabObj(i,1);
    RealGrabRef(i*SampleShift,1) = GrabRef(i,1);
end

figure()
plot(NoiseCodeObj,'g');
hold all
plot(CodeRef,'r');
legend('Reflected Object','Transmitted Reference');
title('Encrypted Signal');
ylabel('Intensity')
xlabel('ms');

figure()
plot(GrabObj,'g');
title('Captured Object Signal');
ylabel('Intensity');
xlabel('ms');

figure()
plot(GrabRef,'r');
title('Captured Reference Signal');
ylabel('Intensity');
xlabel('ms');

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
figure()
plot(real(xp),'r')
title('Fourier Transform Of Object Signal');
figure()
plot(real(xpR),'r')
title('Fourier Transform Of Reference Signal');

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
Distance = (LightSpeed/(2*abs(F1-F2)*10^3))*(PDS/(2*pi));
DisError = abs(Distance - OrgDis);
fprintf('Measured Distance = %.2fm\n',Distance)
%% Evaluation
ObjErrorRate = immse(SigObj,ifft(xp));
fprintf('Object Recovery Mean Square Error: %.6f\n', ObjErrorRate);