%% Processing

filepath = 'Insert filepath to data here';

for k = 1:128
    fname = sprintf('file_%d.csv', k);
    data = readmatrix(strcat(filepath,fname));
    x = data(:,1);
    y = data(:,2);

    peaks(k) = max(y);
    if(prod([77 78 79 80] - k) == 0)
        %
    end

    liny = 10.^(y/10);
    floor(k) = mean(liny,'omitnan');
    floor(k) = 10*log10(floor(k));
end

%% LO values

ch_group = 1:4:125; % recorded in groups of 4
% ch_group = [1 5     8     13    18    21    25    29    33    37    41    45    49    53    57    61    65    69    73    77    81    85    89    93    97    101   105   109   113   117   121   125      
means  = [3.444 3.402 3.388 3.420 3.417 3.450 3.470 3.462 3.508 3.528 3.400 3.363 3.433 4.373 3.558 3.487 3.465 4.137 3.445 3.397 3.389 3.384 3.442 3.450 4.259 4.298 4.784 4.810 4.790 4.835 4.370 4.513];
stddev = [0.020 0.011 0.013 0.010 0.012 0.014 0.024 0.010 0.010 0.012 0.014 0.017 0.033 0.038 0.022 0.013 0.011 0.027 0.017 0.014 0.013 0.009 0.018 0.008 0.009 0.025 0.025 0.020 0.019 0.044 0.026 0.008];
nsamp  = [260   130   120   120   150   115   120   115   165   125   120   230   165   170   240   180   220   145   200   285   430   215   377   130   215   215   130   150   105   135   150   140  ];

figure; hold on; grid on; box on;
histogram(means,round(min(means)-0.1):0.1:round(max(means)+0.1),'FaceColor','k');
xlabel('LO tap photocurrent (mA)');
ylabel('# of TIAs');
title('LO tap distribution');

ax = gca;
ax.FontSize = 12;
ax.FontWeight = "bold"; % for slides
lines = findall(ax, 'Type', 'Line'); % for slides
set(lines, 'LineWidth', 3); % for slides
set(lines,'Color','k'); % for slides
set(gcf,'color','w');

%% Figures
close all;

mean_x4 = repelem(means,4);
mean_x4_lin = mean_x4*1e-6; % it's in uW, taking the tap and all into account
mean_x4_dB10 = 10*log10(mean_x4_lin);
mean_x4_dB = 20*log10(mean_x4_lin);

responsivity = 4e-6/6e-6;
TIA_gain_lin = 5e3;
TIA_gain_dB = 20*log10(TIA_gain_lin);

TIA_out_lin = (mean_x4_lin*responsivity*TIA_gain_lin).^2/50;
TIA_out_dB = 10*log10(TIA_out_lin);

CMRR = TIA_out_dB - peaks;

peaks_adj = peaks; % pre-allocate
peaks_adj2 = peaks; % not used
for i = 1:128
    peaks_adj(i) = peaks(i) - (mean_x4_dB(i) - max(mean_x4_dB));
    peaks_adj2(i) = peaks(i) - (mean_x4_dB10(i) - max(mean_x4_dB10));
end

SNR = peaks_adj + CMRR - floor - 10*log10(5e3);

figure; hold on; grid on; box on;
plot(peaks_adj,'k*','LineWidth',2);
xlabel('Channel index');
ylabel('LO leakage (dBm)');
xlim([1 128])
ax = gca;
ax.FontName = 'Calibri';
ax.FontSize = 16;
lines = findall(ax, 'Type', 'Line');
set(gcf,'color','w');

figure; hold on; grid on; box on;
histogram(CMRR,'FaceColor',[0    0.4471    0.7412]);
xlabel('CMRR (dB)');
ylabel('Number of channels');
ax = gca;
ax.FontName = 'Calibri';
ax.FontSize = 16;
lines = findall(ax, 'Type', 'Line'); % for slides
set(gcf,'color','w');

figure; hold on; grid on; box on;
histogram(SNR,'FaceColor',[0    0.4471    0.7412]);
xlabel('SNR (dB)');
ylabel('Number of channels');
ax = gca;
ax.FontName = 'Calibri';
ax.FontSize = 16;
lines = findall(ax, 'Type', 'Line'); % for slides
set(gcf,'color','w');
