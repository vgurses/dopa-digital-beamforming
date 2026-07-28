close all;
clear all;
% clc;

% path='../data/';
path='../data/fig4_beamforming_20221209_meas2/';
% M = readmatrix([path,'test8_1.csv']);
% M = readmatrix([path,'268deg28_2.csv']);
M = readmatrix([path,'272deg.csv']);
M = M(end-20E3:end,:);
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

dataIX = M(start+1:start+floor(length(M)/Frac),2);
dataIY = M(start+1:start+floor(length(M)/Frac),6); % 2,3,4,5,6,8

t = 1:floor(length(M)/Frac/N);
t = t*1/Fsample;
dt = t(2)-t(1); 

SignalX = dataIX;
SignalY = dataIY;

% % dt =DataPreemble.xincrement;
% % t = 0:length(dataS)-1;
% t = t*dt;

% figure('Renderer', 'painters', 'Position', [100 100 800 350])
% title('Raw signal TD');
% hold all;
% plot(t*1e6,SignalX);
% plot(t*1e6,SignalY);
% xlabel('time (us)')
% title('raw');
% figure('Renderer', 'painters', 'Position', [100 100 800 350])
% title('Raw signal TD');
% hold all;
% % plot(t*1e6,Trigger)
% xlabel('time (us)')

SigIX_Filt = bandpass(SignalX,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigIY_Filt = bandpass(SignalY,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);

% plot(t*1e6,SigIX_Filt);
% plot(t*1e6,SigIY_Filt);
% 
% xlabel('time (us)')
% title('Filtered');

% Nend = 499;
Nend = 199;
[pks,locsX] = findpeaks(SigIX_Filt,t,'MinPeakDistance',.5e-6);
locsX = locsX(1:Nend);
[pks,locsY] = findpeaks(SigIY_Filt,t,'MinPeakDistance',.5e-6);
locsY = locsY(1:Nend);
% figure();
% hold all;
% plot(locsX-locsY)


CHX = SignalX;
L = length(CHX);
Y = fft(CHX);
P2 = abs(Y/length(CHX));
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
P1_CHX = P1;

CHX = SigIX_Filt;
L = length(CHX);
Y = fft(CHX);
P2 = abs(Y/length(CHX));
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
P1_CHX_filt = P1;

f = Fs*(0:(L/2))/L;
figure('Renderer', 'painters', 'Position', [100 100 800 350])
title('FFT Signal');
hold all;
plot(f/1e3,10*log10(P1_CHX))
plot(f/1e3,10*log10(P1_CHX_filt))
xlabel('Frequency (kHz)');
ylabel('Power (dB)');
axis([0 20e3 min(10*log10(P1_CHX)) max(10*log10(P1_CHX))])
legend('Mix','Mix DigitalFilter');



HT_CHX = hilbert(SigIX_Filt);
HT_CHY = hilbert(SigIY_Filt);

% figure()
% subplot(3,1,1);
% hold all;
% plot(t*1e6,real(HT_CHX));
% plot(t*1e6,imag(HT_CHY));
% subplot(3,1,2);
% plot(t*1e6,atan(imag(HT_CHX)./real(HT_CHX)));
% subplot(3,1,3);
% plot(t*1e6,(imag(HT_CHY)).^2+(real(HT_CHY)).^2);

amp2_X = (imag(HT_CHX)).^2+(real(HT_CHX)).^2;
amp2_Y = (imag(HT_CHY)).^2+(real(HT_CHY)).^2;

phase_CHX = atan2(imag(HT_CHX),real(HT_CHX));
phase_CHX = unwrap(phase_CHX);
phase_CHY = atan2(imag(HT_CHY),real(HT_CHY));
phase_CHY = unwrap(phase_CHY);

% figure()
% subplot(2,1,1);
% hold all;
% plot(t*1e6,phase_CHX);
% plot(t*1e6,phase_CHY);
% title('ChX/ChY phase');
% subplot(2,1,2);
% hold all;
% plot(t*1e6,amp2_X);
% plot(t*1e6,amp2_Y);
% 
% title('ChX/ChY amps');

amp2_X(t>(max(t)-50e-6))=[];
amp2_X(t<(50e-6))=[];
amp2_Y(t>(max(t)-50e-6))=[];
amp2_Y(t<(50e-6))=[];

%%

phiO = 0;
PhaseDiff = mod(phase_CHX-phase_CHY+phiO,2*pi)-phiO;
PhaseDiff(t>(max(t)-50e-6))=[];
PhaseDiff(t<(50e-6))=[];
t2 = t;
t2(t2<50e-6)=[];
t2(t2>max(t)-50e-6)=[];

% figure()
% % subplot(2,1,1);
% hold all;
%  plot(t2*1e6,PhaseDiff1);
% subplot(2,1,1);
% hold all;
%  plot(t2*1e6,PhaseDiff*180/pi);
 
%  title('ChX/ChY phase diff');
%  subplot(2,1,2);
%  hold all;
%  plot(t2*1e6,amp2_X);
%  plot(t2*1e6,amp2_Y);
%  title('Ch amps');

amp_env=amp2_X.*amp2_Y;

amp_max = max(amp_env);
Q = floor(amp_env.*10./amp_max);
Q(Q<8)=0;
counts = repelem(PhaseDiff.*180./pi,Q);

f=figure;
histogram(counts);

% counts are in degrees

%median(counts)
fprintf('Median =%4.2f\n',median(counts));
fprintf('Mean =%4.2f\n',mean(counts));
fprintf('Std =%4.2f\n',std(counts));
if(std(counts)>10)
    fprintf('BAD DATA');
end
% mode(counts)
