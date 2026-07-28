function [phaseDiffs,amps] = phaseCalc(filename)

M = readmatrix(filename);
M = M(1:20E3,:);
N = 1; %undersampling factor
Fsample = 100e6/N;
Frac = 1;
start = 0;

t = 1:floor(length(M)/Frac/N);
t = t*1/Fsample;
dt = t(2)-t(1); 

dT = dt;
Fs = 1/dT;

Filter_BW = 10e3; %2MHz typical
Center_Freq = 1000e3;%8.57e6;%11.66e6;%8.57e6;%9.5e6;
% BPF_L = 1e6;
% BPF_H = 15e6;
BPF_L = Center_Freq-Filter_BW/2;
BPF_H = Center_Freq+Filter_BW/2;

dataI1 = M(start+1:start+floor(length(M)/Frac),2);
dataI2 = M(start+1:start+floor(length(M)/Frac),8);
dataI3 = M(start+1:start+floor(length(M)/Frac),3);
dataI4 = M(start+1:start+floor(length(M)/Frac),4);
dataI5 = M(start+1:start+floor(length(M)/Frac),5);
dataI6 = M(start+1:start+floor(length(M)/Frac),6);

t = 1:floor(length(M)/Frac/N);
t = t*1/Fsample;
dt = t(2)-t(1); 

Signal1 = dataI1;
Signal2 = dataI2;
Signal3 = dataI3;
Signal4 = 2.5*dataI4;
Signal5 = dataI5;
Signal6 = dataI6;


SigI1_Filt = bandpass(Signal1,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI2_Filt = bandpass(Signal2,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI3_Filt = bandpass(Signal3,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI4_Filt = bandpass(Signal4,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI5_Filt = bandpass(Signal5,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI6_Filt = bandpass(Signal6,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);


% Nend = 4990;
Nend = 199;
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



HT_CH1 = hilbert(SigI1_Filt);
HT_CH2 = hilbert(SigI2_Filt);
HT_CH3 = hilbert(SigI3_Filt);
HT_CH4 = hilbert(SigI4_Filt);
HT_CH5 = hilbert(SigI5_Filt);
HT_CH6 = hilbert(SigI6_Filt);

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

amp2_1 = sqrt((imag(HT_CH1)).^2+(real(HT_CH1)).^2);
amp2_2 = sqrt((imag(HT_CH2)).^2+(real(HT_CH2)).^2);
amp2_3 = sqrt((imag(HT_CH3)).^2+(real(HT_CH3)).^2);
amp2_4 = sqrt((imag(HT_CH4)).^2+(real(HT_CH4)).^2);
amp2_5 = sqrt((imag(HT_CH5)).^2+(real(HT_CH5)).^2);
amp2_6 = sqrt((imag(HT_CH6)).^2+(real(HT_CH6)).^2);

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

amp_1=median(amp2_1);
amp_2=median(amp2_2);
amp_3=median(amp2_3);
amp_4=median(amp2_4);
amp_5=median(amp2_5);
amp_6=median(amp2_6);

%%
phiO = pi/2;
PhaseDiff1 = mod(phase_CH6-phase_CH5+phiO,2*pi)-phiO;
PhaseDiff1(t>(max(t)-50e-6))=[];
PhaseDiff1(t<(50e-6))=[];
PhaseDiff2 = mod(phase_CH6-phase_CH4+phiO,2*pi)-phiO;
PhaseDiff2(t>(max(t)-50e-6))=[];
PhaseDiff2(t<(50e-6))=[];
PhaseDiff3 = mod(phase_CH6-phase_CH3+phiO,2*pi)-phiO;
PhaseDiff3(t>(max(t)-50e-6))=[];
PhaseDiff3(t<(50e-6))=[];
PhaseDiff4 = mod(phase_CH6-phase_CH2+phiO,2*pi)-phiO;
PhaseDiff4(t>(max(t)-50e-6))=[];
PhaseDiff4(t<(50e-6))=[];
PhaseDiff5 = mod(phase_CH6-phase_CH1+phiO,2*pi)-phiO;
PhaseDiff5(t>(max(t)-50e-6))=[];
PhaseDiff5(t<(50e-6))=[];
t2 = t;
t2(t2<50e-6)=[];
t2(t2>max(t)-50e-6)=[];


amp_env1=amp2_1.*amp2_2;
amp_max1 = max(amp_env1);
Q1 = floor(amp_env1.*10./amp_max1);
Q1(Q1<8)=0;

amp_env2=amp2_2.*amp2_3;
amp_max2 = max(amp_env2);
Q2 = floor(amp_env2.*10./amp_max2);
Q2(Q2<8)=0;

amp_env3=amp2_3.*amp2_4;
amp_max3 = max(amp_env3);
Q3 = floor(amp_env3.*10./amp_max3);
Q3(Q3<8)=0;

amp_env4=amp2_4.*amp2_5;
amp_max4 = max(amp_env4);
Q4 = floor(amp_env4.*10./amp_max4);
Q4(Q4<8)=0;

amp_env5=amp2_5.*amp2_5;
amp_max5 = max(amp_env5);
Q5 = floor(amp_env5.*10./amp_max5);
Q5(Q5<8)=0;

counts1 = repelem(PhaseDiff1.*180./pi,Q1);
counts2 = repelem(PhaseDiff2.*180./pi,Q2);
counts3 = repelem(PhaseDiff3.*180./pi,Q3);
counts4 = repelem(PhaseDiff4.*180./pi,Q4);
counts5 = repelem(PhaseDiff5.*180./pi,Q5);


% counts are in degrees

phaseDifff1 = median(counts1);
phaseDifff2 = median(counts2);
phaseDifff3 = median(counts3);
phaseDifff4 = median(counts4);
phaseDifff5 = median(counts5);

std_th = 10;

%fprintf('File: ');
%fprintf(filename);
%fprintf('\n');

if(std(counts1)<std_th)
    fprintf('Median1 = %4.2f\n',phaseDifff1);
else
    fprintf('BAD DATA G6G7: ');
    fprintf('stddev = %4.2f\n',std(counts1));
end

if(std(counts2)<std_th)
    fprintf('Median2 = %4.2f\n',phaseDifff2);
else
    fprintf('BAD DATA G6G8: ');
    fprintf('stddev = %4.2f\n',std(counts2));
end

if(std(counts3)<std_th)
    fprintf('Median3 = %4.2f\n',phaseDifff3);
else
    fprintf('BAD DATA G6G9: ');
    fprintf('stddev = %4.2f\n',std(counts3));
end

if(std(counts4)<std_th)
    fprintf('Median4 = %4.2f\n',phaseDifff4);
else
    fprintf('BAD DATA  G6G10: ');
    fprintf('stddev = %4.2f\n',std(counts4));
end

if(std(counts5)<std_th)
    fprintf('Median5 = %4.2f\n',phaseDifff5);
else
    fprintf('BAD DATA G6G11: ');
    fprintf('stddev = %4.2f\n',std(counts5));
end

phaseDiffs = [phaseDifff1, phaseDifff2, phaseDifff3, phaseDifff4,  phaseDifff5];
amps = [amp_1, amp_2, amp_3, amp_4, amp_5, amp_6];
end