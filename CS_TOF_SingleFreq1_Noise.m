function [Distance] = CS_TOF_SingleFreq1_Noise(OrgDis)

close all;
clc;
%% Create signal
LightSpeed = 3e8;
Fbase = 1000; %KHz
F1 = Fbase; %KHz = 1MHz %First frequency of the signal
PD1 = (2*F1*2*pi*10^3*OrgDis)/LightSpeed; %1st Component Phase Difference
SampPerCyc = 60;
Fs = 10; %Sampling Frequency at 10 KHz
L = (SampPerCyc*(F1)/Fs)/2; %Length of the signal reduced 2 times for faster calculation
LoopNum = SampPerCyc*(F1)/1000; %Signal repeat times number
SampleShift = L/LoopNum; %Delay between sample capture
Pos = zeros(LoopNum,1); %Captured position of signal

for i=1:LoopNum
    Pos(i,1) = (i-1)*SampleShift+1;
end
time = [1:SampleShift:L]';
CodeMatrix = randi([0 1],L,L); %Matrix for encrypting signal
SigObj = zeros(L,1); %Signal reflected from object
SigRef = zeros(L,1); %Reference signal used for comparing

for i=1:L
    SigObj(i) = cos(2*pi*F1/(Fbase*SampPerCyc)*i)+1;
    SigRef(i) = cos(2*pi*F1/(Fbase*SampPerCyc)*i+PD1)+1;
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
end

figure()
plot(NoiseCodeObj,'g');
hold all
plot(CodeRef,'r');
legend('Reflected Object','Transmitted Reference');
title('Encrypted Signal');
xlabel('ms')
ylabel('Intensity')

figure()
plot(GrabObj,'g');
hold all
plot(GrabRef,'r');
legend('Compressed Object','Compressed Reference');
title('Captured Signal');
ylabel('Intensity')
xlabel('Sample')

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
Cycle = SampPerCyc*(F1/Fbase);
RcvObjCyc = zeros(1,Cycle);
RcvRefCyc = zeros(1,Cycle);
RcvObj = real(ifft(xp));
RcvRef = real(ifft(xpR));

for i = 1:Cycle
    RcvObjCyc(i) = RcvObj(i);
    RcvRefCyc(i) = RcvRef(i);
end

for i = 1:length(RcvObj)
    if(RcvObjCyc(i) == max(RcvObjCyc))
        MaxObjLoc = i;
        break;
    end
end

for i = 1:length(RcvRef)
    if(RcvRefCyc(i) == max(RcvRefCyc))
        MaxRefLoc = i;
        break;
    end
end

LocDif = abs(MaxRefLoc - MaxObjLoc);
PDS = ((2*pi*LocDif)/Cycle);
%% Distance calculation
Distance = (LightSpeed/(2*abs(F1)*10^3))*(PDS/(2*pi));
fprintf('Measured Distance = %.2fm\n',Distance);
DistanceError = (abs(OrgDis - Distance)/OrgDis)*100;
fprintf('Error Rate of Measured Distance = %.3f%%\n',DistanceError);
%% Evaluation
RefErrorRate = immse(SigRef,ifft(xpR));
fprintf('Reference Recovery MSE: %.3f\n', RefErrorRate);

ObjErrorRate = immse(SigObj,ifft(xp));
fprintf('Object Recovery MSE: %.3f\n', ObjErrorRate);
end