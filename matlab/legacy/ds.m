% Debjit Sarkar
% DOPA processing

%% Processing
close all;
clear all;
clc

filepath = "../data/20221121_NOT_INCLUDED/";
motor_angles = 265:0.5:275;
files = num2str(motor_angles);
files = "270";
for i = 1:length(files)
    files(i) = strcat(files,"deg.csv");
end

for file_idx = 1:length(files)
    readme = strcat(filepath,files(file_idx));
    M = readmatrix(readme);
    
    Fsample = 100e6;
    Nsamples = length(M);
    t = (1:Nsamples)/Fsample;
    dt = 1/Fsample;
    
    Filter_BW = 10e3; %2MHz typical
    Center_Freq = 1e6;
    BPF_L = Center_Freq-Filter_BW/2;
    BPF_H = Center_Freq+Filter_BW/2;
    
    G6 = process_me(M(:,2),BPF_L,BPF_H); % G6
    ref = G6;
    G8 = process_me_ref(M(:,3),BPF_L,BPF_H,ref); % G8
    G9 = process_me_ref(M(:,4),BPF_L,BPF_H,ref); % G9
    G10 = process_me_ref(M(:,5),BPF_L,BPF_H,ref); % G10
    G11 = process_me_ref(M(:,6),BPF_L,BPF_H,ref); % G11
    G7 = process_me_ref(M(:,8),BPF_L,BPF_H,ref); % G7
    
    % ref = CH2;
    
    all_ch = [G7 G8 G9 G10 G11];

    figure; hold on; grid on;
    %plot(G7);
    plot(mod(G8-G7,2*pi));
    %plot(filter_me(M(:,1)),BPF_L,BPF_H);
    legend('raw','filtered')
%     boxchart(motor_angles(file_idx)*ones(size(CH3)),CH3);
%     boxchart(motor_angles(file_idx)*ones(size(CH4)),CH4);
%     boxchart(motor_angles(file_idx)*ones(size(CH5)),CH5);
%     boxchart(motor_angles(file_idx)*ones(size(CH6)),CH6);
%     boxchart(motor_angles(file_idx)*ones(size(CH8)),CH8);
    %boxchart(motor_angles(file_idx)*ones(size(all_ch)),all_ch);
    xlabel('Motor angle')
    ylabel('Phase between elements')

end


%% Functions

function filtered = filter_me(signal,BPF_L,BPF_H)
Fs = 100e6;
filtered = bandpass(signal,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
end

function phase = process_me(signal,BPF_L,BPF_H)
Fs = 100e6;
filtered = bandpass(signal,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
H = hilbert(filtered);
phase = (unwrap(angle(H)))';
% mag = abs(H);
end

function phase = process_me_ref(signal,BPF_L,BPF_H,ref)
Fs = 100e6;
filtered = bandpass(signal,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
H = hilbert(filtered);
phase = (unwrap(angle(H)))' - ref;
% mag = abs(H);
end