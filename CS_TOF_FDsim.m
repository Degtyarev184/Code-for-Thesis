clear all;
close all;
clc;

FSig = 1000; %KHz = 1GHz
SampPerCyc = 20;
Fs = 10; %Sampling Frequency
PhaseDelta = 2*pi/3;
L = SampPerCyc*FSig/Fs; %Length of the signal
LoopNum = SampPerCyc*FSig/1000;

SampleShift = L/LoopNum;
Pos = zeros(LoopNum,1);

for i=1:LoopNum
    Pos(i,1) = (i-1)*SampleShift+1;
end
CodeMatrix = randi([0 1],L,L);
SigObj = zeros(L,1);
SigRef = zeros(L,1);

for i=1:L
    SigObj(i) = cos(2*pi*FSig/(FSig*SampPerCyc)*i)+1;
    SigRef(i) = cos(2*pi*FSig/(FSig*SampPerCyc)*i+PhaseDelta)+1;
end

figure(1)
plot(SigRef,'b');
hold on 
plot(SigObj,'g');
xlim([0 200]);
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
plot(abs(OutObj),'b');
hold all
plot(abs(OutRef),'g');
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

figure(3)
plot(real((ifft(xpR))),'b')
xlim([0 200])
hold all
plot(real((ifft(xp))),'g')
legend('Reference','Object')
title('Processed signal')
xlabel('ms')
ylabel('Amplitude')

LightSpeed = 3*10^8;
Distance = (LightSpeed/(2*FSig*10^3))*(PhaseDelta/(2*pi));
fprintf('Measured Distance = %dm\n',Distance)