clear all;
clc;

%% Setup

filepath='../data/noise_spectra_20221119/';
filename_rx = strcat(filepath,'10deg');
filename_edfa = strcat(filepath,'edfa');
filename_noise = strcat(filepath,'noise');
ch=4;

[freqs_rx,data_rx] = spectrumRead(filename_rx,ch);
[freqs_edfa,data_edfa] = spectrumRead(filename_edfa,ch);
[freqs_noise,data_noise] = spectrumRead(filename_noise,ch);

mov=10;
data_rx=movmean(abs(data_rx),mov);
data_edfa=movmean(abs(data_edfa),mov);
data_noise=movmean(abs(data_noise),mov);


%%
f=figure
hold on
grid on
set(gcf,'color','white')
semilogx(freqs_rx,10.*log10(data_rx));
% semilogx(freqs_edfa,10.*log10(data_edfa));
semilogx(freqs_noise,10.*log10(data_noise));
xlim([0,2E6])
xlabel('Frequency (Hz)')
ylabel('Power (dBm)')