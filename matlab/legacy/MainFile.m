close all;
clear all;
clc;

% path='../data/';
path='../data/noise_spectra_20221119/';
% M = readmatrix([path,'test8_1.csv']);
M = readmatrix([path,'oop.csv']);
% M = readmatrix('PXI_data\set2_shotnoiseLimited\Data2_LaserOn_NoMod_m1.csv');
% M = readmatrix(fileName);
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
 plot(t*1e6,amp2_1);
 plot(t*1e6,amp2_2);
 plot(t*1e6,amp2_3);
 plot(t*1e6,amp2_4);
 plot(t*1e6,amp2_5);
 plot(t*1e6,amp2_6);
 title('Ch amps');
%  plot(t2*1e6,PhaseDiff3);
%  plot(t2*1e6,PhaseDiff4);
%  plot(t2*1e6,PhaseDiff5);
% scatter(t(1:end-1)*1e6,(diff(phase_CH1-phase_CH3)));
% scatter(t(1:end-1)*1e6,(diff(phase_CH1-phase_CH4)));
% scatter(t(1:end-1)*1e6,(diff(phase_CH1-phase_CH5)));
% scatter(t(1:end-1)*1e6,(diff(phase_CH1-phase_CH6)));


PhaseDiffArr(:,1) = PhaseDiff1;
PhaseDiffArr(:,2) = PhaseDiff2;
PhaseDiffArr(:,3) = PhaseDiff3;
PhaseDiffArr(:,4) = PhaseDiff4;
PhaseDiffArr(:,5) = PhaseDiff5;

PhaseDiffArr_C = PhaseDiffArr;
N = 5;
for kk = 1:N
    PhaseDiff_C = PhaseDiffArr_C(:,kk);
    for jj=2:length(PhaseDiff_C)
        Jump = (PhaseDiff_C(jj)-PhaseDiff_C(jj-1)); 
        if( abs(Jump) > pi/4 )
            PhaseDiff_C(jj:end) = PhaseDiff_C(jj:end)-Jump;
        end
    end
    PhaseDiffArr_C(:,kk) = PhaseDiff_C;
end
figure();
subplot(2,1,1);
hold all;
% plot(PhaseDiff3);
for kk = 1:N
    plot(t2*1e6,PhaseDiffArr_C(:,kk));
end
legend('CH12','CH13','CH14','CH15','CH16')
subplot(2,1,2);
hold all;
amp_t = amp2_1;
% amp_t(t<50e-6)=[];
% amp_t(t>max(t)-50e-6)=[];

plot(t*1e6,amp2_1);
plot(t*1e6,amp2_2);
plot(t*1e6,amp2_3);
plot(t*1e6,amp2_4);
plot(t*1e6,amp2_5);
plot(t*1e6,amp2_6);
% meanPhaseDiff = mean(PhaseDiff)
% stdPhaseDiff = std(PhaseDiff)
% subplot(2,1,2);
% hold all;
% amp_CH1 = ((imag(HT_CH1)).^2+(real(HT_CH1)).^2);
% amp_CH2 = ((imag(HT_CH2)).^2+(real(HT_CH2)).^2);
% plot(t*1e6,amp_CH1);
% plot(t*1e6,amp_CH2*(max(amp_CH1)/max(amp_CH2)));
% title('Ch1/Ch2 amp normalized');
% %%
% [pks1,locs1] = findpeaks(SigI1_Filt,t,'MinPeakDistance',.1e-7);
% [pks2,locs2] = findpeaks(SigI2_Filt,t,'MinPeakDistance',.1e-7);
% [pks3,locs3] = findpeaks(SigI3_Filt,t,'MinPeakDistance',.1e-7);
% [pks4,locs4] = findpeaks(SigI4_Filt,t,'MinPeakDistance',.1e-7);
% [pks5,locs5] = findpeaks(SigI5_Filt,t,'MinPeakDistance',.1e-7);
% [pks6,locs6] = findpeaks(SigI6_Filt,t,'MinPeakDistance',.1e-7);
% figure();
% hold all;
% plot(t*1e6,SigI1_Filt);
% plot(locs1*1e6,pks1);
% plot(t*1e6,SigI2_Filt);
% plot(locs2*1e6,pks2);
% figure();
% hold all;
% locsDiff1 = locs1(1:1e4-5)-locs2(1:1e4-5); 
% locsDiff2 = locs1(1:1e4-5)-locs3(1:1e4-5); 
% locsDiff3 = locs1(1:1e4-5)-locs4(1:1e4-5); 
% locsDiff4 = locs1(1:1e4-5)-locs5(1:1e4-5); 
% locsDiff5 = locs1(1:1e4-5)-locs6(1:1e4-5); 
% 
% plot(locsDiff1*1e6*360);
% plot(locsDiff2*1e6*360);
% plot(locsDiff3*1e6*360);
% plot(locsDiff4*1e6*360);
% plot(locsDiff5*1e6*360);
% %%
% 
% [pks,locs] = findpeaks(Trigger_Filt,t,'MinPeakDistance',.1e-7);
% disp(['Mean value of pks is: ',num2str(mean(pks))]);
% disp(['Max value of pks is: ',num2str(max(pks))]);
% 
% figure(1);
% scatter(locs*1e6,pks);
% 
% WindowSize = 50e-6;
% 
% t0 = linspace(0,max(t)-WindowSize,100);
% 
% 
% for j = 1:100
%     Segment_t = t(t>=t0(j) & t<t0(j)+WindowSize);
%     Segment_P = Trigger_Filt(t>=t0(j) & t<t0(j)+WindowSize);
% %     figure();
% %     plot(Segment_t,Segment_P)
%     [pks,locs] = findpeaks(Segment_P,Segment_t,'MinPeakDistance',.1e-7);
%     MeanPK(j) = mean(pks);
%     MaxPK(j) = max(pks);
% %     disp(['Mean value of pks is: ',num2str(MeanPK(j))]);
% %     disp(['Max value of pks is: ',num2str(MaxPK(j))]);
% 
%     CH1 = Segment_P;
%     L = length(CH1);
%     Y = fft(CH1);
%     P2 = abs(Y/length(CH1));
%     P1 = P2(1:L/2+1);
%     P1(2:end-1) = 2*P1(2:end-1);
%     P1_Seg = P1;
%     FdomainPeak(j) = max(P1_Seg);
% 
% end
% figure('Renderer', 'painters', 'Position', [100 100 800 350])
% title('Filtered data highest pks');
% hold all;
% plot(MeanPK);
% plot(MaxPK);
% legend('mean peak','max peak');
% 
% BestIndex = find(abs(MaxPK-max(MaxPK))==min(abs(MaxPK-max(MaxPK))));
% BestIndex2 = find(abs(MeanPK-max(MeanPK))==min(abs(MeanPK-max(MeanPK))));
% 
% j = BestIndex2;
% Segment_t = t(t>=t0(j) & t<t0(j)+WindowSize);
% Segment_P = Trigger_Filt(t>=t0(j) & t<t0(j)+WindowSize);
% 
% figure('Renderer', 'painters', 'Position', [100 100 800 350])
% title('Filtered data segment highest pks in TD');
% plot(Segment_t*1e6,Segment_P)
% 
%     
% CH1 = Segment_P;
% L = length(CH1);
% Y = fft(CH1);
% P2 = abs(Y/length(CH1));
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% P1_Seg = P1;
% 
% f = Fs*(0:(L/2))/L;
% figure('Renderer', 'painters', 'Position', [100 100 800 350])
% title('Filtered data segment highest pks in FD');
% hold all;
% plot(f/1e3,10*log10(P1_Seg))
% xlabel('Frequency (kHz)');
% ylabel('Power (dB)');
% axis([0 20e3 min(10*log10(P1_Seg)) max(10*log10(P1_Seg))])
% legend('Mix','Mix DigitalFilter');
% 
% disp(['Measured peak frequency from max amplitude moethod is: ',num2str(f(max(P1_Seg)==P1_Seg)/1e6), ' MHz']);
% 
% figure('Renderer', 'painters', 'Position', [100 100 800 350])
% plot(FdomainPeak);
% title('Highest frequency domain peak');
% 
% BestIndex = find(abs(FdomainPeak-max(FdomainPeak))==min(abs(FdomainPeak-max(FdomainPeak))));
% % BestIndex = find(abs(FdomainPeak-maxk(FdomainPeak,5))==min(abs(FdomainPeak-maxk(FdomainPeak,5))));
% 
% j = BestIndex;
% Segment_t = t(t>=t0(j) & t<t0(j)+WindowSize);
% Segment_P = Trigger_Filt(t>=t0(j) & t<t0(j)+WindowSize);
% figure('Renderer', 'painters', 'Position', [100 100 800 350])
% title('Highest frequency domain peak signal segment');
% plot(Segment_t*1e6,Segment_P)
% 
% CH1 = Segment_P;
% L = length(CH1);
% Y = fft(CH1);
% P2 = abs(Y/length(CH1));
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% P1_Seg = P1;
% 
% f = Fs*(0:(L/2))/L;
% figure('Renderer', 'painters', 'Position', [100 100 800 350])
% title('Highest frequency domain peak signal segment in FD');
% hold all;
% plot(f/1e3,10*log10(P1_Seg))
% xlabel('Frequency (kHz)');
% ylabel('Power (dB)');
% axis([0 20e3 min(10*log10(P1_Seg)) max(10*log10(P1_Seg))])
% legend('Mix','Mix DigitalFilter');
% 
% 
% disp(['Measured peak frequency from max FFT peak moethod is: ',num2str(f(max(P1_Seg)==P1_Seg)/1e6), ' MHz']);
% peaks = maxk(P1_Seg,2);
% peak1 = peaks(1);
% peak2 = peaks(2);
% disp(['Measured Power of sig from max FFT peak moethod is: ',num2str(20*log10(peak1)), ' dB']);
% disp(['Measured SNR of sig from max FFT peak moethod is: ',num2str(20*log10(peak1/peak2)), ' dB']);
% 
% %
% % tmean = mean(diff(locs))
% % tstd = std(diff(locs))
% 
% 
%     x = Segment_P;
%     
% 
%     n = 0:length(t)-1;
%     Fs = 1/(Segment_t(2)-Segment_t(1));
%     nfft = length(n);
%     [P,f] = pmusic(x,2,nfft,Fs); % Window length = 7
%     
%     figure()
%     plot(f,20*log10(abs(P)))
%     xlabel 'Frequency (Hz)', ylabel 'Power (dB)'
%     title 'Pseudospectrum Estimate via MUSIC', grid on
% 
%     Signal = P;
%     [pks,locs] = findpeaks(Signal,f,'MinPeakDistance',10);
%     hold all;
%     scatter(locs,20*log10(pks));
%     
%     maxMUISC_pk = max(pks);
%     f_MUSIC = locs(maxMUISC_pk==max(pks));
%     f_MUSIC = f_MUSIC(1);
% disp(['Measured peak frequency from max FFT peak method + MUSIC is: ',num2str(locs/1e6), ' MHz']);   
% disp(['Measured Power of sig from max MUSIC peak moethod is: ',num2str(20*log10(max(pks))), ' dB']);
% %%
% % Signal = movmean(dataS,1);
% % plot(t*1e6,DataPreemble.yincrement*Signal);
% %%
% % [pks,locs] = findpeaks(Signal,t,'MinPeakDistance',2e-7);
% % 
% % scatter(locs*1e6,pks)
% % 
% % dtMix0_mean = mean(diff(locs));
% % dtMix0_err = std(diff(locs));
% % dtMix0_min = min(diff(locs));
% % dtMix0_max = max(diff(locs));
% %%
% 
% Filter_BW = 2e6; %2MHz typical
% Center_Freq = 11.6e6;%8.57e6;%11.66e6;%8.57e6;%9.5e6;
% % BPF_L = 1e6;
% % BPF_H = 15e6;
% BPF_L = Center_Freq-Filter_BW/2;
% BPF_H = Center_Freq+Filter_BW/2;
% j = 19;
% dT = dt;
% Fs = 1/dT;
% 
% CH1 = Signal;
% CH2 = SignalQ;
% L = length(CH1);
% 
% 
% Y = fft(CH1);
% P2 = abs(Y/length(CH1));
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% P1_CH1 = P1;
% 
% Y = fft(CH2);
% P2 = abs(Y/length(CH2));
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% P1_CH2 = P1;
% 
% f = Fs*(0:(L/2))/L;
% figure('Renderer', 'painters', 'Position', [100 100 800 350])
% hold all;
% plot(f/1e3,10*log10(P1_CH1))
% plot(f/1e3,10*log10(P1_CH2))
% xlabel('Frequency (kHz)');
% ylabel('Power (dB)');
% axis([0 20e3 min(10*log10(P1_CH1)) max(10*log10(P1_CH1))])
% legend('I','Q');
% 
% 
% CH1_BPF = bandpass(CH1,[BPF_L,BPF_H],Fs,'ImpulseResponse','fir','Steepness',0.9);
% CH2_BPF = bandpass(CH2,[BPF_L,BPF_H],Fs,'ImpulseResponse','fir','Steepness',0.9);
% SumSqr = CH1_BPF.^2+CH2_BPF.^2;
% Trigger_Filt = lowpass(Trigger,[5e6],Fs,'ImpulseResponse','fir','Steepness',0.9);
% figure('Renderer', 'painters', 'Position', [100 100 800 350])
% subplot(4,1,1);
% plot(t*1e6,CH1_BPF);
% legend('CH1');
% subplot(4,1,2);
% plot(t*1e6,CH2_BPF);
% legend('CH2');
% subplot(4,1,4);
% plot(t*1e6,Trigger_Filt);
% legend('Trigger');
% % plot(t*1e6,CH1_BPF.^2)
% % plot(t*1e6,CH2_BPF.^2)
% subplot(4,1,3);
% plot(t*1e6,SumSqr)
% legend('CH1^2+CH2^2');
% 
% Y = fft(SumSqr);
% P2 = abs(Y/length(SumSqr));
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% P1_SumSqr = P1;
% 
% 
% f = Fs*(0:(L/2))/L;
% figure('Renderer', 'painters', 'Position', [100 100 800 350])
% hold all;
% plot(f/1e3,10*log10(P1_SumSqr))
% xlabel('Frequency (kHz)');
% ylabel('Power (dB)');
% axis([500 30e3 min(10*log10(P1_SumSqr)) max(10*log10(P1_SumSqr))])
% legend('I^2+Q^2');
% SNRf = max(P1_SumSqr(f>7e6-0.2e6 & f<7e6+0.2e6))/sum(P1_SumSqr(f>7e6-0.2e6 & f<7e6+0.2e6));
% 
% %%
% % [pksF,locsF] = findpeaks(P1_CH1_BPF,f,'MinPeakDistance',200e3);
% % plot(locsF/1e3,10*log10(pksF))
% % pksFI = interp1(locsF,pksF,f,'spline');
% % plot(f/1e3,10*log10(pksFI))
% % SpectralPeak = f(pksFI==max(pksFI));
% %%
% dt2 = dt/200;
% t2 = linspace(0,t(end),t(end)/dt2);
% SumSqr_BPF2 = interp1(t,SumSqr,t2,'spline');
% Trigger_Filt2 = interp1(t,Trigger_Filt,t2,'spline');
% 
% [pks,locs] = findpeaks(SumSqr,t,'MinPeakDistance',.1e-7);
% [pksIQ,locsIQ] = findpeaks(SumSqr_BPF2,t2,'MinPeakDistance',.1e-7);
% [minpksIQ,minlocsIQ] = findpeaks(-SumSqr_BPF2,t2,'MinPeakDistance',.1e-7);
% figure();
% plot(t*1e6,SumSqr);
% hold all;
% plot(locs*1e6,pks)
% plot(minlocsIQ*1e6,-minpksIQ)
% title('BPF response with peaks');
% plot(t2*1e6,SumSqr_BPF2);
% plot(locsIQ*1e6,pksIQ)
% plot(t*1e6,Trigger_Filt*1e-4);
% legend('BPF data','BPF pks','BPF -pks','BPF Int','BPF Int pks');
% 
% locs = locsIQ;
% pks = pksIQ;
% 
% MinLen = min(length(pksIQ),length(minpksIQ));
% PKPK_swingMean = mean(pks(1:MinLen)+minpksIQ(1:MinLen));
% PKPK_swingSTD = std(pks(1:MinLen)+minpksIQ(1:MinLen));
% 
% dtMixF_mean = mean(diff(locs));
% dtMixF_err = std(diff(locs));
% dtMixF_min = min(diff(locs));
% dtMixF_max = max(diff(locs));
% 
% Extract0 = [dtMixF_mean,dtMixF_err,dtMixF_min,dtMixF_max];
% %%
% % 
% % figure();
% % hold all;
% % plot(t*1e6,-abs(SumSqr));
% % [pks2,locs2] = findpeaks(-abs(SumSqr),t,'MinPeakDistance',0.5e-7);
% % plot(locs2*1e6,pks2)
% % plot(t*1e6,Trigger)
% % 
% % plot(t(1:end-1)*1e6,-diff(Trigger))
% % 
% % dtMixFzc_mean = mean(diff(locs2));
% % dtMixFzc_err = std(diff(locs2));
% % dtMixFzc_max = max(diff(locs2));
% % dtMixFzc_min = min(diff(locs2));
% 
% figure();
% hold all;
% plot(t2*1e6,Trigger_Filt2)
% [pksT,locsT] = findpeaks(-diff(Trigger_Filt2),t2(1:end-1),'MinPeakDistance',4e-6);
% plot(t2(1:end-1)*1e6,-diff(Trigger_Filt2))
% scatter(locsT*1e6,pksT)
% title('BPF response with zero crossings');
% legend('TrigFilt2','TrigFilt2Diff','Edge');
% % legend('-|BPF|','ZC','dTrig','Trig Filt','Trig ZC','dTrig_peaks');
% 
% meanWindow = mean(diff(locsT));
% % close figure 10
% figure(10);
% hold all
% 
% B=2;
% %  Block15_t0 = SumSqr(t>=locsT(B) & t<locsT(B+1));
%  
% % Block15_S0 = zeros(length(locsT)-1,length(SumSqr(t>=locsT(B) & t<SumSqr(B)+meanWindow*.95)));
% % BlockStd = zeros(1,length(Block15_t0));
% % BlockAvg = zeros(1,length(Block15_t0));
% 
% clear PhaseLine
% 
% figure(10);
% hold all;
% title('location of peaks w.r.t. trigger');
% clear MeanTime StdTime ZC_fullBlockAvg B
% fitResult = zeros(length(locsT)-1,5);
% 
% trend = 1;
% TrackBestCost = 0;
% 
% fitResult = 0;
% 
% figure(22);
% hold all;
% for B=1:10%length(locsT)-1
%     B
% %     Block15_t = locs2(locs2>=locsT(B) & locs2<locsT(B+1));
%     Block15_t = locs(locs>=locsT(B)+meanWindow*.05 & locs<locsT(B)+meanWindow*.95);
% %     Block15_S = pks2(locs2>=locsT(B) & locs2<locsT(B+1));
%     Block15_S = pks(locs>=locsT(B)+meanWindow*.05 & locs<locsT(B)+meanWindow*.95);
% 
%    
%         Block15_t0 = t(t>=locsT(B) & t<locsT(B)+meanWindow); %discard last 5% of the window data
%         Block15_S0 = SumSqr(t>=locsT(B) & t<locsT(B)+meanWindow);
%         
% %         f = fittype('a*cos(2*pi*b*x+c)+d'); 
% %         x0 = Block15_t0'-min(Block15_t0);
% %         x0 = x0/max(x0);
% %         y2 = Block15_S0;
% %         StartPoint = max(y2);
% %         [fit1,gof,fitinfo] = fit(x0,y2,f,'StartPoint',[StartPoint 100 pi StartPoint/2],'Robust','on');
% %         ci1 = confint(fit1,0.95);
% % %         [fitresult1, gof1] = TestFit1(Block15_t0, Block15_S0);
% %         f_fit(B) = fit1.b;
% %         ConfInt(B) = ci1(2,2)-ci1(1,2);
% %         rmse_fit(B) = gof1.rmse;
% %         R2_fit(B) = gof1.rsquare;
% 
%             x0 = Block15_t0 - min(Block15_t0);
%             x0 = x0';
%             y2 = Block15_S0;
%             y2(x0<5e-7)=[];
%             x0(x0<5e-7)=[];
% 
%             Bounds_a = [-0.01,0.01];
%             Bounds_b = [-0.01,0.01];
%             Bounds_f = [10e6,20e6];
%             Bounds_phi = [0,2*pi];
%             Bounds_DC = [0 0.01];
% 
%             N_a = 20;
%             N_b = 10;
%             N_f = 200;
%             N_phi = 100;
%             N_DC = 20;
% 
%             aTest = linspace(Bounds_a(1),Bounds_a(2),N_a);
%             fTest = linspace(Bounds_f(1),Bounds_f(2),N_f);
%             phiTest = linspace(Bounds_phi(1),Bounds_phi(2),N_phi);
%             DCTest = linspace(Bounds_DC(1),Bounds_DC(2),N_DC);
% 
%             yTest =aTest(1)*cos(2*pi*fTest(1)*x0+phiTest(1))+DCTest(1);
%             BestCost = sum((yTest-y2).^2);
% 
%             Best_a = 0;
%             Best_f = 0;
%             Best_phi = 0;
%             Best_DC = 0;
% 
%             for jj1=1:N_a
%                 for jj2=1:N_f
%                     for jj3=1:N_phi
%                         for jj4=1:N_DC
%                             yTest =aTest(jj1)*cos(2*pi*fTest(jj2)*x0+phiTest(jj3))+DCTest(jj4);
%                             Cost = sum((yTest-y2).^2);
%                             if Cost < BestCost
%                                 BestCost = Cost;
%                                 Best_a = aTest(jj1);
%                                 Best_f = fTest(jj2);
%                                 Best_phi = phiTest(jj3);
%                                 Best_DC = DCTest(jj4);
% 
%                                 TrackBestCost(trend) = BestCost;
%                                 trend = trend+1;
%                             end           
%                         end
%                     end
%                 end
%             end
% 
%             N_a = 10;
%             N_f = 100;
%             N_phi = 10;
%             N_DC = 10;
%             
%             Window = 0.05;
%             
%             Bounds2_f = [(1-Window)*Best_f,(1+Window)*Best_f];
%             Bounds2_a = [(1-Window)*Best_a,(1+Window)*Best_a]; 
%             Bounds2_phi = [(1-Window)*Best_phi,(1+Window)*Best_phi];
%             Bounds2_DC = [(1-Window)*Best_DC,(1+Window)*Best_DC];
%             
%             
%             aTest2 = linspace(Bounds2_a(1),Bounds2_a(2),N_a);
%             fTest2 = linspace(Bounds2_f(1),Bounds2_f(2),N_f);
%             phiTest2 = linspace(Bounds2_phi(1),Bounds2_phi(2),N_phi);
%             DCTest2 = linspace(Bounds2_DC(1),Bounds2_DC(2),N_DC);
%             
%             
%             for jj1=1:N_a
%                 for jj2=1:N_f
%                     for jj3=1:N_phi
%                         for jj4=1:N_DC
%                             yTest =aTest2(jj1)*cos(2*pi*fTest2(jj2)*x0+phiTest2(jj3))+DCTest2(jj4);
%                             Cost = sum((yTest-y2).^2);
%                             if Cost < BestCost
%                                 BestCost = Cost;
%                                 Best_a = aTest2(jj1);
%                                 Best_f = fTest2(jj2);
%                                 Best_phi = phiTest2(jj3);
%                                 Best_DC = DCTest2(jj4);
%                                 
%                                 TrackBestCost(trend) = BestCost;
%                                 trend = trend+1;
%                             end           
%                         end
%                     end
%                 end
%             end
% %             
% %             N_a = 10;
% %             N_f = 50;
% %             N_phi = 20;
% %             N_DC = 10;
% %             
% %             Window = 0.01;
% %             
% %             Bounds2_f = [(1-Window)*Best_f,(1+Window)*Best_f];
% %             Bounds2_a = [(1-Window)*Best_a,(1+Window)*Best_a]; 
% %             Bounds2_phi = [(1-Window)*Best_phi,(1+Window)*Best_phi];
% %             Bounds2_DC = [(1-Window)*Best_DC,(1+Window)*Best_DC];
% %             
% %             
% %             aTest2 = linspace(Bounds2_a(1),Bounds2_a(2),N_a);
% %             fTest2 = linspace(Bounds2_f(1),Bounds2_f(2),N_f);
% %             phiTest2 = linspace(Bounds2_phi(1),Bounds2_phi(2),N_phi);
% %             DCTest2 = linspace(Bounds2_DC(1),Bounds2_DC(2),N_DC);
% %             
% %             
% %             for jj1=1:N_a
% %                 for jj2=1:N_f
% %                     for jj3=1:N_phi
% %                         for jj4=1:N_DC
% %                             yTest =aTest2(jj1)*cos(2*pi*fTest2(jj2)*x0+phiTest2(jj3))+DCTest2(jj4);
% %                             Cost = sum((yTest-y2).^2);
% %                             if Cost < BestCost
% %                                 BestCost = Cost;
% %                                 Best_a = aTest2(jj1);
% %                                 Best_f = fTest2(jj2);
% %                                 Best_phi = phiTest2(jj3);
% %                                 Best_DC = DCTest2(jj4);
% %                                 
% %                                 TrackBestCost(trend) = BestCost;
% %                                 trend = trend+1;
% %                             end           
% %                         end
% %                     end
% %                 end
% %             end
%             
%             fun = @(p,x0) p(1)*cos(2*pi*p(2)*x0+p(3))+p(4);            
% 
% 
% 
%             pGuess = [Best_a Best_f Best_phi Best_DC];
% 
%             %optimize
%             % [p,fminres]=fminsearch(fun,pGuess)
%             options=optimoptions(@lsqcurvefit,'Algorithm','levenberg-marquardt','StepTolerance',1e-10);
%             [p,fminres]=lsqcurvefit(fun,pGuess,x0,y2);
%             
%             fitResult(B,1:4) = p;
%             fitResult(B,5) = fminres;
%    
%         figure();
%         hold all;
%         plot(x0,y2);
%         x1 = 0:(x0(2)-x0(1))/100:max(x0);
%         plot(x1,fitResult(B,1)*cos(2*pi*fitResult(B,2)*x1+fitResult(B,3))+fitResult(B,4));
%         title(num2str(B));
%     Block15_Trig0 = Trigger_Filt(t>=locsT(B) & t<locsT(B)+meanWindow);
%     
%     MaxPksSeg = pks(locs>=locsT(B)+meanWindow*.05 & locs<locsT(B)+meanWindow*.95);
% %     MinPksSeg = minpks(locs>=locsT(B)+meanWindow*.05 & locs<locsT(B)+meanWindow*.95);
% %     MinLen = min(length(MaxPksSeg),length(MinPksSeg));
% %     PKPK_swingMean(B) = mean(MaxPksSeg(1:MinLen)+MinPksSeg(1:MinLen));
% %     PKPK_swingSTD(B) = std(MaxPksSeg(1:MinLen)+MinPksSeg(1:MinLen));
% %     
% %     PhaseLine = Block15_t-locsT(B); 
% % %     stamp = 1:length(PhaseLine);
% % %         plot(stamp,PhaseLine);
% % %     [fitresult, gof] = LinFit(stamp, PhaseLine)
% % %     slope(B-3)=fitresult.p1;
% % %     rmse(B-3)=gof.rmse;
%     
% %     legend('peaks','Trig','CW waveform','TrigWaveform');
% B;
%     Block15_t(1:4)=[];
%     MeanTime(B) = mean(diff(Block15_t));
%     StdTime(B) = std(diff(Block15_t));
%     ZC_fullBlockAvg(B) =  (Block15_t(end)-Block15_t(1))/(length(Block15_t)-1);
%     
%     figure();
%     bar(diff(Block15_t));
%     title(num2str(B));
%     disp(['Result: ',num2str(B),' ',num2str((10e6-1/MeanTime(B)/2)/500e12),' ',num2str((10e6-fitResult(B,2)/2)/500e12)]);
% %     
% %     if StdTime(B)>1e-8
% %         figure();
% %         hold all;
% %         scatter(Block15_t,Block15_S);
% %         scatter(locsT(B),pksT(B));
% %         plot(Block15_t0,Block15_S0);
% %         plot(Block15_t0,Block15_Trig0);
% %         title(num2str(B));
% %     end
% end
% MeanTime(1)=[];   %MeanTime(1:3)=[];   
% StdTime(1)=[];
% ZC_fullBlockAvg(1)=[];
% 
% figure(22);
% plot(1:trend-1,TrackBestCost);
% % figure()
% % title('Vpp and Vrms');
% % errorbar(PKPK_swingMean,PKPK_swingSTD);
% % figure();
% % bar(PKPK_swingSTD);
% %clean high std data
% std_thr = 1.5e-8;
% kk = 1;
% clear ZC_fullBlockAvg_polished MeanTime_polished StdTime_polisehed
% for jk=1:length(ZC_fullBlockAvg)
%     if StdTime(jk) < std_thr
%         ZC_fullBlockAvg_polished(kk) = ZC_fullBlockAvg(jk);
%         MeanTime_polished(kk) = MeanTime(jk);
%         StdTime_polisehed(kk) = StdTime(jk);
%         kk = kk + 1;        
%     end
% end
% 
% % kk2 = 1;
% % clear ZC_fullBlockAvg_SNRp MeanTime_SNRp StdTime_SNRp
% % SNR_thr = 0.05;
% % for jk2=1:length(ZC_fullBlockAvg)
% %     if PKPK_swingSTD(jk2) < SNR_thr
% %         ZC_fullBlockAvg_SNRp(kk2) = ZC_fullBlockAvg(jk2);
% %         MeanTime_SNRp(kk2) = MeanTime(jk2);
% %         StdTime_SNRp(kk2) = StdTime(jk2);
% %         kk2 = kk2 + 1;        
% %     end
% % end
% 
% 
% % BlockAvg = mean(Block15_S0,1);
% % BlockStd = std(Block15_S0,1);
% figure(20)
% hold all;
% % plot(Block15_t0,BlockAvg);
% % errorbar(Block15_t0,BlockAvg,BlockStd);
% 
% % [pks3,locs3] = findpeaks(BlockAvg,Block15_t0,'MinPeakDistance',0.1e-7);
% % plot(locs3,pks3);
% % 
% % pkMean_Block = mean(locs3);
% % pkStd_Block = std(locs3);
% %     figure();
% %     hold all;
% %     errorbar(1:length(locsT)-1,MeanTime,StdTime,'d');
% %     
% tzeroMean = mean(MeanTime);
% tzeroMax = max(MeanTime);
% tzeroMin = min(MeanTime);
% tzeroStd = std(MeanTime);
% fmix = 1/tzeroMean;
% ferr = abs(fmix-(1/abs(tzeroMean-tzeroStd)));
% clear Extract Extract2
% Extract = [tzeroMean,tzeroStd,mean(ZC_fullBlockAvg),std(ZC_fullBlockAvg)]
% SNR = [(PKPK_swingMean),PKPK_swingSTD];
% if kk>1
%     Extract2 = [mean(MeanTime_polished),std(MeanTime_polished),...
%             mean(ZC_fullBlockAvg_polished),std(ZC_fullBlockAvg_polished),kk-1];
%     figure()
%     hold all;
%     plot(ZC_fullBlockAvg_polished)
%     errorbar(MeanTime_polished,StdTime_polisehed)
%     title('mean time and ZC data per block(omit >15ns error)');
% end
% 
% % if kk2>1
% %     Extract3 = [mean(MeanTime_SNRp),std(MeanTime_SNRp),...
% %             mean(ZC_fullBlockAvg_SNRp),std(ZC_fullBlockAvg_SNRp),kk2-1];
% % end
% figure()
% hold all;
% plot(ZC_fullBlockAvg)
% errorbar(MeanTime,StdTime)
% title('mean time and ZC data per block');
% figure();
% plot(ZC_fullBlockAvg-MeanTime)
% 
% % Histogram based calculation
% %  figure();
% %  x=histfit(1./diff(locs)/1e3,100,'kernel');
% %  maxPt = max(x(2).YData);
% %  freqs = x(2).XData;
% %  maxFreq = freqs(x(2).YData == maxPt)
% 
% outputData = [Extract,Extract2,SNR];
% 
% MeanFreq = mean(fitResult(:,2));
% StdFreq = std(fitResult(:,2));
% MeanTau = mean((10e6-fitResult(:,2)/2)/500e12);
% StdTau = std((10e6-fitResult(:,2)/2)/500e12);
% outputData2 = [MeanFreq,StdFreq,MeanTau,StdTau];