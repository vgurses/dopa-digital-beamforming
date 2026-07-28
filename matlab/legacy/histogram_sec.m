close all;
clear all;
clc;

% path='../data/';
path='C:\Users\Administrator\Desktop\pxi python code\dataDOPA\20221120\';
% M = readmatrix([path,'test8_1.csv']);
% M = readmatrix([path,'268deg28_2.csv']);
M = readmatrix([path,'268deg28_t5.csv']);
% M = readmatrix('PXI_data\set2_shotnoiseLimited\Data2_LaserOn_NoMod_m1.csv');
% M = readmatrix(fileName);

N = 1; %undersampling factor
Fsample = 100e6/N;
Frac = 1;
start = 0;

t = 1:floor(length(M)/Frac/N);
t = t*1/Fsample;
dt = t(2)-t(1); 

dT = dt;
Fs = 1/dT;

Filter_BW = 5e3; %2MHz typical
Center_Freq = 1000e3;%8.57e6;%11.66e6;%8.57e6;%9.5e6;
% BPF_L = 1e6;
% BPF_H = 15e6;
BPF_L = Center_Freq-Filter_BW/2;
BPF_H = Center_Freq+Filter_BW/2;

% % dataQ = M(start+1:start+floor(length(M)/Frac),2);
dataT = M(start+1:start+floor(length(M)/Frac),8);
dataI1 = M(start+1:start+floor(length(M)/Frac),8);
dataI2 = M(start+1:start+floor(length(M)/Frac),3);%3
dataI3 = M(start+1:start+floor(length(M)/Frac),2);
dataI4 = M(start+1:start+floor(length(M)/Frac),4);
dataI5 = M(start+1:start+floor(length(M)/Frac),5);
dataI6 = M(start+1:start+floor(length(M)/Frac),6);

% dataQ2 = M(start+1:start+floor(length(M)/Frac),4);
% dataQ(mod(t,N)~=0)=[];
% dataI(mod(t,N)~=0)=[];
% dataT(mod(t,N)~=0)=[];
% dataI2(mod(t,N)~=0)=[];
% dataQ2(mod(t,N)~=0)=[];

t = 1:floor(length(M)/Frac/N);
t = t*1/Fsample;
dt = t(2)-t(1); 

% [DataPreemble] = PreembleExtract(DS4K_preemble);

% Lmax = max(length(dataS),length(dataT));
% 
% if length(dataS)<Lmax
%     dataS(end+1:Lmax) = 0;
% elseif length(dataT)<Lmax
%     dataT(end+1:Lmax) = 0;
% end

Trigger = dataT;
Signal1 = dataI1;
Signal2 = dataI2;
Signal3 = dataI3;
Signal4 = dataI4;
Signal5 = dataI5;
Signal6 = dataI6;

% % dt =DataPreemble.xincrement;
% % t = 0:length(dataS)-1;
% t = t*dt;

figure('Renderer', 'painters', 'Position', [100 100 800 350])
title('Raw signal TD');
hold all;
plot(t*1e6,Signal1);
plot(t*1e6,Signal2);
plot(t*1e6,Signal3);
plot(t*1e6,Signal4);
plot(t*1e6,Signal5);
plot(t*1e6,Signal6);
xlabel('time (us)')
title('raw');
figure('Renderer', 'painters', 'Position', [100 100 800 350])
title('Raw signal TD');
hold all;
% plot(t*1e6,Trigger)
xlabel('time (us)')

SigI1_Filt = bandpass(Signal1,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI2_Filt = bandpass(Signal2,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI3_Filt = bandpass(Signal3,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI4_Filt = bandpass(Signal4,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI5_Filt = bandpass(Signal5,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI6_Filt = bandpass(Signal6,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);


plot(t*1e6,SigI1_Filt);
plot(t*1e6,SigI2_Filt);
plot(t*1e6,SigI3_Filt);
plot(t*1e6,SigI4_Filt);
plot(t*1e6,SigI5_Filt);
plot(t*1e6,SigI6_Filt);

xlabel('time (us)')
title('Filtered');

Nend = 4990;
[pks,locs1] = findpeaks(SigI1_Filt,t,'MinPeakDistance',.5e-6);
locs1 = locs1(1:Nend);
[pks,locs2] = findpeaks(SigI2_Filt,t,'MinPeakDistance',.5e-6);
locs2 = locs2(1:Nend);
[pks,locs3] = findpeaks(SigI3_Filt,t,'MinPeakDistance',.5e-6);
locs3 = locs3(1:Nend);
[pks,locs4] = findpeaks(SigI4_Filt,t,'MinPeakDistance',.5e-6);
locs4 = locs4(1:Nend);
[pks,locs5] = findpeaks(SigI5_Filt,t,'MinPeakDistance',.5e-6);
locs5 = locs5(1:Nend);
[pks,locs6] = findpeaks(SigI6_Filt,t,'MinPeakDistance',.5e-6);
locs6 = locs6(1:Nend);
figure();
hold all;
plot(locs1-locs2)
plot(locs1-locs3)
plot(locs1-locs4)
plot(locs1-locs5)
plot(locs1-locs6)


CH1 = Signal1;
L = length(CH1);
Y = fft(CH1);
P2 = abs(Y/length(CH1));
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
P1_CH1 = P1;

CH1 = SigI1_Filt;
L = length(CH1);
Y = fft(CH1);
P2 = abs(Y/length(CH1));
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
P1_CH1_filt = P1;

f = Fs*(0:(L/2))/L;
figure('Renderer', 'painters', 'Position', [100 100 800 350])
title('FFT Signal');
hold all;
plot(f/1e3,10*log10(P1_CH1))
plot(f/1e3,10*log10(P1_CH1_filt))
xlabel('Frequency (kHz)');
ylabel('Power (dB)');
axis([0 20e3 min(10*log10(P1_CH1)) max(10*log10(P1_CH1))])
legend('Mix','Mix DigitalFilter');



HT_CH1 = hilbert(SigI1_Filt);
HT_CH2 = hilbert(SigI2_Filt);
HT_CH3 = hilbert(SigI3_Filt);
HT_CH4 = hilbert(SigI4_Filt);
HT_CH5 = hilbert(SigI5_Filt);
HT_CH6 = hilbert(SigI6_Filt);

figure()
subplot(3,1,1);
hold all;
plot(t*1e6,real(HT_CH1));
plot(t*1e6,imag(HT_CH1));
subplot(3,1,2);
plot(t*1e6,atan(imag(HT_CH1)./real(HT_CH1)));
subplot(3,1,3);
plot(t*1e6,(imag(HT_CH1)).^2+(real(HT_CH1)).^2);

figure()
subplot(2,1,1);
hold all;
phase_CH1 = atan2(imag(HT_CH1),real(HT_CH1));
phase_CH1 = unwrap(phase_CH1);
phase_CH2 = atan2(imag(HT_CH2),real(HT_CH2));
phase_CH2 = unwrap(phase_CH2);
phase_CH3 = atan2(imag(HT_CH3),real(HT_CH3));
phase_CH3 = unwrap(phase_CH3);
phase_CH4 = atan2(imag(HT_CH4),real(HT_CH4));
phase_CH4 = unwrap(phase_CH4);
phase_CH5 = atan2(imag(HT_CH5),real(HT_CH5));
phase_CH5 = unwrap(phase_CH5);
phase_CH6 = atan2(imag(HT_CH6),real(HT_CH6));
phase_CH6 = unwrap(phase_CH6);
plot(t*1e6,phase_CH1);
plot(t*1e6,phase_CH2);
plot(t*1e6,phase_CH3);
plot(t*1e6,phase_CH4);
plot(t*1e6,phase_CH5);
plot(t*1e6,phase_CH6);
title('Ch1/Ch2 phase');
subplot(2,1,2);
hold all;
amp2_1 = (imag(HT_CH1)).^2+(real(HT_CH1)).^2;
amp2_2 = (imag(HT_CH2)).^2+(real(HT_CH2)).^2;
amp2_3 = (imag(HT_CH3)).^2+(real(HT_CH3)).^2;
amp2_4 = (imag(HT_CH4)).^2+(real(HT_CH4)).^2;
amp2_5 = (imag(HT_CH5)).^2+(real(HT_CH5)).^2;
amp2_6 = (imag(HT_CH6)).^2+(real(HT_CH6)).^2;
plot(t*1e6,amp2_1);
plot(t*1e6,amp2_2);
plot(t*1e6,amp2_3);
plot(t*1e6,amp2_4);
plot(t*1e6,amp2_5);
plot(t*1e6,amp2_6);

title('Ch1/Ch2 amps');

amp2_1(t>(max(t)-50e-6))=[];
amp2_1(t<(50e-6))=[];
amp2_2(t>(max(t)-50e-6))=[];
amp2_2(t<(50e-6))=[];
amp2_3(t>(max(t)-50e-6))=[];
amp2_3(t<(50e-6))=[];
amp2_4(t>(max(t)-50e-6))=[];
amp2_4(t<(50e-6))=[];
amp2_5(t>(max(t)-50e-6))=[];
amp2_5(t<(50e-6))=[];
amp2_6(t>(max(t)-50e-6))=[];
amp2_6(t<(50e-6))=[];

%%
figure()
% subplot(2,1,1);
hold all;
phiO = pi/2;
PhaseDiff1 = mod(phase_CH1-phase_CH2+phiO,2*pi)-phiO;
PhaseDiff1(t>(max(t)-50e-6))=[];
PhaseDiff1(t<(50e-6))=[];
PhaseDiff2 = mod(phase_CH1-phase_CH3+phiO,2*pi)-phiO;
PhaseDiff2(t>(max(t)-50e-6))=[];
PhaseDiff2(t<(50e-6))=[];
PhaseDiff3 = mod(phase_CH1-phase_CH4+phiO,2*pi)-phiO;
PhaseDiff3(t>(max(t)-50e-6))=[];
PhaseDiff3(t<(50e-6))=[];
PhaseDiff4 = mod(phase_CH1-phase_CH5+phiO,2*pi)-phiO;
PhaseDiff4(t>(max(t)-50e-6))=[];
PhaseDiff4(t<(50e-6))=[];
PhaseDiff5 = mod(phase_CH1-phase_CH6+phiO,2*pi)-phiO;
PhaseDiff5(t>(max(t)-50e-6))=[];
PhaseDiff5(t<(50e-6))=[];
t2 = t;
t2(t2<50e-6)=[];
t2(t2>max(t)-50e-6)=[];
%  plot(t2*1e6,PhaseDiff1);
subplot(2,1,1);
hold all;
 plot(t2*1e6,PhaseDiff1*180/pi);
 plot(t2*1e6,PhaseDiff2*180/pi);
 plot(t2*1e6,PhaseDiff3*180/pi);
 plot(t2*1e6,PhaseDiff4*180/pi);
 plot(t2*1e6,PhaseDiff5*180/pi);
 
 title('Ch1/Ch2 phase diff');
 subplot(2,1,2);
 hold all;
 plot(t2*1e6,amp2_1);
 plot(t2*1e6,amp2_2);
 plot(t2*1e6,amp2_3);
 plot(t2*1e6,amp2_4);
 plot(t2*1e6,amp2_5);
 plot(t2*1e6,amp2_6);
 title('Ch amps');
%  plot(t2*1e6,PhaseDiff3);
%  plot(t2*1e6,PhaseDiff4);
%  plot(t2*1e6,PhaseDiff5);
% scatter(t(1:end-1)*1e6,(diff(phase_CH1-phase_CH3)));
% scatter(t(1:end-1)*1e6,(diff(phase_CH1-phase_CH4)));
% scatter(t(1:end-1)*1e6,(diff(phase_CH1-phase_CH5)));
% scatter(t(1:end-1)*1e6,(diff(phase_CH1-phase_CH6)));

for i=1:4
    
    amp2_2_temp=amp2_2((i-1).*1E6:i*1E6);
    amp2_6_temp=amp2_2((i-1).*1E6:i*1E6);


    amp_env=amp2_1.*amp2_6;

    amp_max = max(amp_env);
    Q = floor(amp_env.*10./amp_max);
    Q(Q<8)=0;
    counts = repelem(PhaseDiff5.*180./pi,Q);

    f=figure;
    histogram(counts);
end
