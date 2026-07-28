%% Channel characterization: LO leakage, CMRR and noise floor across all 128 channels
%
% Generates Figure 3d (LO leakage per channel), 3e (CMRR histogram) and
% 3f (noise floor histogram) of:
%
%   V. Gurses, D. Sarkar, A. Khachaturian, R. Fatemi, A. Hajimiri,
%   "A large-scale integrated optical phased array with digital beamforming,"
%   Scientific Reports (2026).
%
% Input:  ../data/channel_characterization_128ch/File_1.csv ... File_128.csv
%         (Keysight N9952A spectrum-analyzer traces, one per receiver channel,
%          1001 points over a 10 kHz span at 1 Hz RBW and VBW, 0 dB input
%          attenuation, preamp off, positive-peak detector, no averaging)
%
% The traces were recorded with the local oscillator coupled to the chip and
% NO SIGNAL incident on the aperture, so the peak in each trace is the residual
% LO tone at the balanced-detector output, not a received signal.
%
% Author: Debjit Sarkar
% Revised 2026-07-28. Four corrections relative to the version that produced
% the originally submitted figure:
%   1. The CMRR reference is normalised to 1 mW so that it is a level in dBm,
%      matching the dBm trace peaks. It was previously evaluated in dBW and
%      subtracted from a dBm peak, which made every channel read exactly 30 dB
%      low: median 27.4 dB -> 57.4 dB.
%   2. The noise floor is the median of each trace, which excludes the residual
%      LO tone. The previous convention averaged the whole trace in linear
%      power; the tone contributed ~78% of that average and overstated the
%      floor by ~7 dB: median -112.1 dBm -> -118.9 dBm in the 1 Hz RBW.
%   3. Panel (f) previously plotted a per-channel "SNR". No signal was present,
%      and the expression used reduced algebraically to a constant minus the
%      noise floor. Panel (f) now plots the measured noise floor directly, and
%      the sensitivity that follows from it is printed to the console.
%   4. The Fig. 3d normalisation of the leakage to the concurrent LO reading
%      uses 10*log10 of the LO power. It previously used 20*log10, which
%      double-counted by up to ~1.6 dB and shifted the distribution about
%      1.5 dB high: median -80.3 dBm -> -81.8 dBm.

%% Processing

filepath = '../data/channel_characterization_128ch/';

peaks = zeros(1,128);
floorlvl = zeros(1,128);
for k = 1:128
    fname = sprintf('File_%d.csv', k);  % capital F: required on case-sensitive filesystems
    data = readmatrix(strcat(filepath,fname));
    y = data(:,2);

    peaks(k) = max(y);
    % Median of the trace in dB. The trace is 1001 points and the LO tone
    % occupies only a few of them, so the median is the level away from the
    % tone. A linear mean over the whole trace would be dominated by it.
    floorlvl(k) = median(y,'omitnan');
end

%% LO values
%
% LO power per channel in microwatts, referred to the photodiodes, recorded
% separately with DOPABoard.m in groups of 4 channels.
%
% NOTE: the 99:1 monitor tap sits on the input waveguide, upstream of the 1:128
% splitter tree, so it cannot resolve channel-to-channel variation. The spread
% in this array is drift in the input LO over the ~2 h acquisition, mapped onto
% channel index because the channels were measured in sequence. It is used to
% normalise each channel's CMRR to the LO reading taken at the same time, which
% removes that drift; it is deliberately NOT used per channel anywhere else.

means  = [3.444 3.402 3.388 3.420 3.417 3.450 3.470 3.462 3.508 3.528 3.400 3.363 3.433 4.373 3.558 3.487 3.465 4.137 3.445 3.397 3.389 3.384 3.442 3.450 4.259 4.298 4.784 4.810 4.790 4.835 4.370 4.513];
stddev = [0.020 0.011 0.013 0.010 0.012 0.014 0.024 0.010 0.010 0.012 0.014 0.017 0.033 0.038 0.022 0.013 0.011 0.027 0.017 0.014 0.013 0.009 0.018 0.008 0.009 0.025 0.025 0.020 0.019 0.044 0.026 0.008];
nsamp  = [260   130   120   120   150   115   120   115   165   125   120   230   165   170   240   180   220   145   200   285   430   215   377   130   215   215   130   150   105   135   150   140  ];

%% Derived quantities

responsivity = 4e-6/6e-6;      % A/W  (0.67)
TIA_gain_lin = 5e3;            % ohm
Z0           = 50;             % ohm
mW           = 1e-3;           % reference power for dBm
Ps_ref       = 1e-3;           % 0 dBm reference signal, optical, into one antenna

lo_w = repelem(means,4)*1e-6;  % W per channel

% Fig. 3e -- CMRR. The /mW is what makes the reference a level in dBm; without
% it this is dBW and the result comes out 30 dB low.
TIA_out_dBm = 10*log10((lo_w*responsivity*TIA_gain_lin).^2/Z0/mW);
CMRR = TIA_out_dBm - peaks;

% Fig. 3d -- LO leakage, normalised to the highest LO reading.
% 10*log10 because lo_w is a power. An earlier version used 20*log10, which
% double-counted the correction by up to ~1.6 dB and shifted the whole
% distribution about 1.5 dB high; the published panel has been regenerated.
lo_dB = 10*log10(lo_w);
lo_leakage = peaks - (lo_dB - max(lo_dB));

% Fig. 3f -- noise floor, and the sensitivity that follows from it.
% A balanced pair fed by a 50:50 coupler gives a beat photocurrent of amplitude
% 2*R*sqrt(Ps*PLO); through Rf that is a sinusoid of amplitude
% 2*R*Rf*sqrt(Ps*PLO), whose RMS power into Z0 is V^2/(2*Z0). The LO is held at
% a single stated value rather than taken per channel -- see the note above.
lo_ref  = median(lo_w);
sig_dBm = 10*log10((2*responsivity*TIA_gain_lin)^2 * Ps_ref * lo_ref/(2*Z0)/mW);
SNR     = sig_dBm - floorlvl;
NESP    = 10*log10(Ps_ref/mW) - SNR;   % noise-equivalent signal power, dBm

fprintf('LO leakage   median %8.2f dBm\n', median(lo_leakage));
fprintf('CMRR         median %8.2f dB\n',  median(CMRR));
fprintf('noise floor  median %8.2f dBm/Hz\n', median(floorlvl));
fprintf('SNR (0 dBm)  median %8.2f dB\n',  median(SNR));
fprintf('sensitivity  median %8.2f dBm/Hz\n', median(NESP));
fprintf('LO held at %.2f uW/channel; a 0 dBm signal into one antenna appears at %+.2f dBm\n', lo_ref*1e6, sig_dBm);
fprintf('%d of 128 channels lie within 1 dB of the median floor\n', sum(abs(floorlvl-median(floorlvl))<=1));

%% Figures
close all;

figure; hold on; grid on; box on;
plot(lo_leakage,'k*','LineWidth',2);
xlabel('Channel index'); ylabel('LO leakage (dBm)');
xlim([1 128]);
ax = gca; ax.FontName = 'Calibri'; ax.FontSize = 16; set(gcf,'color','w');

figure; hold on; grid on; box on;
histogram(CMRR,55:1:67,'FaceColor',[0 0.4471 0.7412]);
xlabel('CMRR (dB)'); ylabel('Number of channels');
ax = gca; ax.FontName = 'Calibri'; ax.FontSize = 16; set(gcf,'color','w');

figure; hold on; grid on; box on;
histogram(floorlvl,linspace(-119.5,-115.5,13),'FaceColor',[0 0.4471 0.7412]);
xlabel('Noise floor (dBm/Hz)'); ylabel('Number of channels');
ylim([0 64]);
ax = gca; ax.FontName = 'Calibri'; ax.FontSize = 16; set(gcf,'color','w');
