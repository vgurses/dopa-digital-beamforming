function [freqsI,dataI_FT] = spectrumRead(filename,ch)
M = readmatrix(filename);
N=1;
Fsample = 100e6/N;
Frac = 1;
start = 0;

t = 1:floor(length(M)/Frac/N);
t = t*1/Fsample;
dt = t(2)-t(1); 

dT = dt;
Fs = 1/dT;

dataI=[];
ord=[2,8,3,4,5,6];
for i=1:6
    dataI=[dataI,M(start+1:start+floor(length(M)/Frac),ord(i))];
end

dataI_FT = fft(dataI(:,ch));
freqsI = (0:length(dataI_FT)-1)*Fs/length(dataI_FT);

n=length(dataI_FT);
dataI_FT = dataI_FT(1:floor(n/2));
n=length(freqsI);
freqsI = freqsI(1:floor(n/2));
end

