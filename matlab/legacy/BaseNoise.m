close all;
clear all;
clc;

path='../data/';
M = readmatrix([path,'test7_0.csv']);
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


SigI1_Filt = bandpass(Signal1,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI2_Filt = bandpass(Signal2,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI3_Filt = bandpass(Signal3,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI4_Filt = bandpass(Signal4,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI5_Filt = bandpass(Signal5,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);
SigI6_Filt = bandpass(Signal6,[BPF_L,BPF_H],Fs,'ImpulseResponse','iir','Steepness',0.9);

SigI1_clip = SigI1_Filt;
SigI1_clip(t<500e-6 & t>max(t)-500e-6)=[];
SigI2_clip = SigI2_Filt;
SigI2_clip(t<500e-6 & t>max(t)-500e-6)=[];
SigI3_clip = SigI3_Filt;
SigI3_clip(t<500e-6 & t>max(t)-500e-6)=[];
SigI4_clip = SigI4_Filt;
SigI4_clip(t<500e-6 & t>max(t)-500e-6)=[];
SigI5_clip = SigI5_Filt;
SigI5_clip(t<500e-6 & t>max(t)-500e-6)=[];
SigI6_clip = SigI6_Filt;
SigI6_clip(t<500e-6 & t>max(t)-500e-6)=[];


maxNoise = max(SigI1_clip)