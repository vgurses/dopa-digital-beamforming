close all;
clear all;
clc;

motor_angles = 266:1:278;

filepath='../data/fig4_beamforming_20221209_meas2/';
file = strcat(num2str(motor_angles(1)),"deg.csv");
filename = strcat(filepath,file);
M = readmatrix(filename);

%
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
Center_Freq = 1e6;%8.57e6;%11.66e6;%8.57e6;%9.5e6;
% BPF_L = 1e6;
% BPF_H = 15e6;
BPF_L = Center_Freq-Filter_BW/2;
BPF_H = Center_Freq+Filter_BW/2;

dataT = M(start+1:start+floor(length(M)/Frac),8);
dataI1 = M(start+1:start+floor(length(M)/Frac),8);
dataI2 = M(start+1:start+floor(length(M)/Frac),3);%3
dataI3 = M(start+1:start+floor(length(M)/Frac),2);
dataI4 = M(start+1:start+floor(length(M)/Frac),4);
dataI5 = M(start+1:start+floor(length(M)/Frac),5);
dataI6 = M(start+1:start+floor(length(M)/Frac),6);


t = 1:floor(length(M)/Frac/N);
t = t*1/Fsample;
dt = t(2)-t(1); 

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

f=figure;
hold all
plot(t*1e6,SigI1_Filt);
plot(t*1e6,SigI2_Filt);
plot(t*1e6,SigI3_Filt);
plot(t*1e6,SigI4_Filt);
plot(t*1e6,SigI5_Filt);
plot(t*1e6,SigI6_Filt);

xlabel('time (us)')
title('Filtered');

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
% figure('Renderer', 'painters', 'Position', [100 100 800 350])
% title('FFT Signal');
% hold all;
% plot(f/1e3,10*log10(P1_CH1))
% plot(f/1e3,10*log10(P1_CH1_filt))
% xlabel('Frequency (kHz)');
% ylabel('Power (dB)');
% axis([0 20e3 min(10*log10(P1_CH1)) max(10*log10(P1_CH1))])
% legend('Mix','Mix DigitalFilter');



HT_CH1 = hilbert(SigI1_Filt);
HT_CH2 = hilbert(SigI2_Filt);
HT_CH3 = hilbert(SigI3_Filt);
HT_CH4 = hilbert(SigI4_Filt);
HT_CH5 = hilbert(SigI5_Filt);
HT_CH6 = hilbert(SigI6_Filt);

% figure()
% subplot(3,1,1);
% hold all;
% plot(t*1e6,real(HT_CH1));
% plot(t*1e6,imag(HT_CH1));
% subplot(3,1,2);
% plot(t*1e6,atan(imag(HT_CH1)./real(HT_CH1)));
% subplot(3,1,3);
% plot(t*1e6,(imag(HT_CH1)).^2+(real(HT_CH1)).^2);

% figure()
% subplot(2,1,1);
% hold all;
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
% plot(t*1e6,phase_CH1);
% plot(t*1e6,phase_CH2);
% plot(t*1e6,phase_CH3);
% plot(t*1e6,phase_CH4);
% plot(t*1e6,phase_CH5);
% plot(t*1e6,phase_CH6);
% title('Ch1/Ch2 phase');
% subplot(2,1,2);
% hold all;
amp2_1 = (imag(HT_CH1)).^2+(real(HT_CH1)).^2;
amp2_2 = (imag(HT_CH2)).^2+(real(HT_CH2)).^2;
amp2_3 = (imag(HT_CH3)).^2+(real(HT_CH3)).^2;
amp2_4 = (imag(HT_CH4)).^2+(real(HT_CH4)).^2;
amp2_5 = (imag(HT_CH5)).^2+(real(HT_CH5)).^2;
amp2_6 = (imag(HT_CH6)).^2+(real(HT_CH6)).^2;
% plot(t*1e6,amp2_1);
% plot(t*1e6,amp2_2);
% plot(t*1e6,amp2_3);
% plot(t*1e6,amp2_4);
% plot(t*1e6,amp2_5);
% plot(t*1e6,amp2_6);
% 
% title('Ch1/Ch2 amps');
%
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
 
 legend('CH12','CH13','CH14','CH15','CH16')
 
 subplot(2,1,2);
 hold all;
 plot(t*1e6,amp2_1);
 plot(t*1e6,amp2_2);
 plot(t*1e6,amp2_3);
 plot(t*1e6,amp2_4);
 plot(t*1e6,amp2_5);
 plot(t*1e6,amp2_6);
 title('Ch amps');
 
 
legend('CH1','CH2','CH3','CH4','CH5','CH6')
 
%  plot(t2*1e6,PhaseDiff3);
%  plot(t2*1e6,PhaseDiff4);
%  plot(t2*1e6,PhaseDiff5);
% scatter(t(1:end-1)*1e6,(diff(phase_CH1-phase_CH3)));
% scatter(t(1:end-1)*1e6,(diff(phase_CH1-phase_CH4)));
% scatter(t(1:end-1)*1e6,(diff(phase_CH1-phase_CH5)));
% scatter(t(1:end-1)*1e6,(diff(phase_CH1-phase_CH6)));


for jj=2:length(PhaseDiff1)
    Jump = (PhaseDiff1(jj)-PhaseDiff1(jj-1));
    if( abs(Jump) > pi/4 )
        PhaseDiff1(jj:end) = PhaseDiff1(jj:end)-Jump;
    end
end
for jj=2:length(PhaseDiff2)
    Jump = (PhaseDiff2(jj)-PhaseDiff2(jj-1));
    if( abs(Jump) > pi/4 )
        PhaseDiff2(jj:end) = PhaseDiff2(jj:end)-Jump;
    end
end
for jj=2:length(PhaseDiff3)
    Jump = (PhaseDiff3(jj)-PhaseDiff3(jj-1));
    if( abs(Jump) > pi/4 )
        PhaseDiff3(jj:end) = PhaseDiff3(jj:end)-Jump;
    end
end
for jj=2:length(PhaseDiff4)
    Jump = (PhaseDiff4(jj)-PhaseDiff4(jj-1));
    if( abs(Jump) > pi/4 )
        PhaseDiff4(jj:end) = PhaseDiff4(jj:end)-Jump;
    end
end
for jj=2:length(PhaseDiff5)
    Jump = (PhaseDiff5(jj)-PhaseDiff5(jj-1));
    if( abs(Jump) > pi/4 )
        PhaseDiff5(jj:end) = PhaseDiff5(jj:end)-Jump;
    end
end

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

lvl = 0;
mask_1 = (amp2_1 > max(amp2_1).*lvl) & (amp2_2 > max(amp2_2).*lvl);
mask_2 = (amp2_2 > max(amp2_2).*lvl) & (amp2_3 > max(amp2_3).*lvl);
mask_3 = (amp2_3 > max(amp2_3).*lvl) & (amp2_4 > max(amp2_4).*lvl);
mask_4 = (amp2_4 > max(amp2_4).*lvl) & (amp2_5 > max(amp2_5).*lvl);
mask_5 = (amp2_5 > max(amp2_5).*lvl) & (amp2_6 > max(amp2_6).*lvl);

PhaseDiff1 = PhaseDiff1(mask_1);
PhaseDiff2 = PhaseDiff2(mask_2);
PhaseDiff3 = PhaseDiff3(mask_3);
PhaseDiff4 = PhaseDiff4(mask_4);
PhaseDiff5 = PhaseDiff5(mask_5);
t_1 = t2(mask_1);
t_2 = t2(mask_2);
t_3 = t2(mask_3);
t_4 = t2(mask_4);
t_5 = t2(mask_5);

% figure();
% subplot(2,1,1);
% hold all;
% % plot(PhaseDiff3);
% scatter(t_1*1e6,PhaseDiff1);
% scatter(t_2*1e6,PhaseDiff2);
% scatter(t_3*1e6,PhaseDiff3);
% scatter(t_4*1e6,PhaseDiff4);
% scatter(t_5*1e6,PhaseDiff5);
% legend('CH12','CH13','CH14','CH15','CH16')
% subplot(2,1,2);
% hold all;
% amp_t = amp2_1;
% % amp_t(t<50e-6)=[];
% % amp_t(t>max(t)-50e-6)=[];
% 
% plot(t2*1e6,amp2_1);
% plot(t2*1e6,amp2_2);
% plot(t2*1e6,amp2_3);
% plot(t2*1e6,amp2_4);
% plot(t2*1e6,amp2_5);
% plot(t2*1e6,amp2_6);
% meanPhaseDiff = mean(PhaseDiff)
% stdPhaseDiff = std(PhaseDiff)
% subplot(2,1,2);
% hold all;
% amp_CH1 = ((imag(HT_CH1)).^2+(real(HT_CH1)).^2);
% amp_CH2 = ((imag(HT_CH2)).^2+(real(HT_CH2)).^2);
% plot(t*1e6,amp_CH1);
% plot(t*1e6,amp_CH2*(max(amp_CH1)/max(amp_CH2)));
% title('Ch1/Ch2 amp normalized');

legend('CH1','CH2','CH3','CH4','CH5','CH6')

title(filename)

PhaseDiff1=mod(PhaseDiff1,2*pi);
PhaseDiff2=mod(PhaseDiff2,2*pi);
PhaseDiff3=mod(PhaseDiff3,2*pi);
PhaseDiff4=mod(PhaseDiff4,2*pi);
PhaseDiff5=mod(PhaseDiff5,2*pi);

CH12=mean(PhaseDiff1);
CH12std=std(PhaseDiff1);
CH13=mean(PhaseDiff2);
CH13std=std(PhaseDiff2);
CH14=mean(PhaseDiff3);
CH14std=std(PhaseDiff3);
CH15=mean(PhaseDiff4);
CH15std=std(PhaseDiff4);
CH16=mean(PhaseDiff5);
CH16std=std(PhaseDiff5);

CHm=[CH12,CH13,CH14,CH15,CH16];
CHs=[CH12std,CH13std,CH14std,CH15std,CH16std];

