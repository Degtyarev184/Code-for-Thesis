clear all;
close all;
clc;

FSig = 1000; %KHz = 1GHz
SampPerCyc = 20;
SampFreq = 10;
PhaseDelta = 2*pi/3;
L = SampPerCyc*FSig/SampFreq; %Length of the signal
LoopNum = SampPerCyc*FSig/1000;

SampleShift = L/LoopNum;
SampleShiftPos = zeros(LoopNum,1);

for i=1:LoopNum
    SampleShiftPos(i,1) = (i-1)*SampleShift+1;
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
%ylim([0 2]);
legend('Reference','Object')
title('Original signal')

OutObj = zeros(LoopNum,1);
OutRef = zeros(LoopNum,1);
MeasureMatrix = zeros(LoopNum,L);

OutputTotal = CodeMatrix*SigObj;
OutputTotalRef = CodeMatrix*SigRef;

for i=1:LoopNum
    posi = SampleShiftPos(i,1);
    OutObj(i,1) = OutputTotal(posi,1);
    OutRef(i,1) = OutputTotalRef(posi,1);
    MeasureMatrix(i,:) = CodeMatrix(posi,:);
end

figure(2)
plot(abs(OutObj),'b');
hold all
plot(abs(OutRef),'g');
legend('Compressed Object','Compressed Reference');
title('Compressed Signal');

Psi = inv(fft(eye(L)));
cvx_begin
    variable xp(L) complex;
    minimize(norm(xp,1));
    subject to
    MeasureMatrix*Psi*xp == OutObj;
cvx_end

cvx_begin
    variable xpR(L) complex;
    minimize(norm(xpR,1));
    subject to
    MeasureMatrix*Psi*xpR == OutRef;
cvx_end

figure(3)
plot(real((ifft(xpR))),'b')
xlim([0 200])
hold all
plot(real((ifft(xp))),'g')
legend('Reference','Object')
title('Decompressed signal')
xlabel('sec')
ylabel('Amplitude')
LightSpeed = 3*10^8;
Distance = (LightSpeed/(2*FSig*10^4))*(PhaseDelta/(2*pi));
fprintf('Measured Distance = %dm\n',Distance)