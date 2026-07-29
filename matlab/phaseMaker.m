clear all
close all
clc;

%% Setup

filepath='../data/fig4_beamforming_20221209_meas2/';
motor_angles = 266:1:274;  % 266-274 deg = the sweep archived with this release
% motor_angles = 266:1:278;  % full acquisition sweep (raw files 275-278 not deposited)
% motor_angles = 261:1:273;
% motor_angles = 265:0.5:275;
for i = 1:length(motor_angles)
    files(i) = strcat(num2str(motor_angles(i)),"deg.csv");
    filenames(i) = strcat(filepath,files(i));
end

%% Phase processing

phaseDiffs=[];
amps=[];

for i=1:length(files)
    filename = filenames(i);
    [phaseDiff,amp] = phaseCalc(filename);
    phaseDiffs = [phaseDiffs; phaseDiff];
    amps = [amps;amp];
end

%%

N_GC = 6;
N_angles = length(motor_angles);
ordered = zeros(length(motor_angles),N_GC);
ordered(:,2:(N_GC)) = phaseDiffs;
save('../processed/20221214_10us.mat','ordered');

%% Channel Amplitudes

fprintf('Calculating channel amplitudes\n');

amps2=amps./max(amps,[],2);

fig = figure;
set(gcf,'color','w');
x0=500;
y0=500;
width=350;
height=300;
set(gcf,'position',[x0,y0,width,height])
% grid on
hold on
% box on
colormap(hot)
imagesc(10.*log10(amps2'));
cb=colorbar();

xlabel('Angle (deg)');
ylabel('Channel Number');
xlim([0.5,9.5])
ylim([0.5,6.5])

fon=12;
xticks([1,2,3,4,5,6,7,8,9])
xticklabels({'-4','-3','-2','-1','0','1','2','3','4'})
ylabel(cb,'Normalized Amplitude (dB-rel)','FontSize',fon,'Rotation',270)
set(gca,'FontSize',fon);
hColourbar.Label.Position(1) = 10;


%% Channel Phases

fprintf('Calculating channel phases\n');

ref = 5;

fig = figure;
set(gcf,'color','w');
x0=500;
y0=500;
width=350;
height=300;
set(gcf,'position',[x0,y0,width,height])
grid on
hold on
box on

% for i = 1:Nangles
%     for ii = 1:N_GC
%         if(ii == 1)
%             plot(angles(i),ordered(i,ii),'rx');
%         elseif(ii == 2)
%             plot(angles(i),ordered(i,ii),'go');
%         elseif(ii == 3)
%             plot(angles(i),ordered(i,ii),'b*');
%         elseif(ii == 4)
%             plot(angles(i),ordered(i,ii),'^','Color','c');
%         elseif(ii == 5)
%             plot(angles(i),ordered(i,ii),'square','Color','m');
%         elseif(ii == 6)
%             plot(angles(i),ordered(i,ii),'pentagram','Color','y');
%         end
%     end
% end

angles = motor_angles;

ordered2=unwrap(ordered./180.*pi);

GC6 = (ordered2(:,1)-ordered2(ref,1))./pi.*180;
GC7 = (ordered2(:,2)-ordered2(ref,2))./pi.*180;
GC8 = (ordered2(:,3)-ordered2(ref,3))./pi.*180;
GC9 = (ordered2(:,4)-ordered2(ref,4))./pi.*180;
GC10 = (ordered2(:,5)-ordered2(ref,5))./pi.*180;
GC11 = (ordered2(:,6)-ordered2(ref,6))./pi.*180;

GC10(1)=GC10(1)-360;
GC10(1:4)=GC10(1:4)-360;
GC10(7:end)=GC10(7:end)+360;
% GC10(9:end)=GC10(9:end)+360;
% GC10(12:end)=GC10(12:end)+360;

GC11(1)=GC11(1)-360*4;
GC11(2)=GC11(2)-360*3;
GC11(3)=GC11(3)-360*2;
GC11(4)=GC11(4)-360*1;
GC11(6)=GC11(6)+360*1;
GC11(7)=GC11(7)+360*2;
GC11(8)=GC11(8)+360*3;
GC11(9)=GC11(9)+360*4;
GC11(10)=GC11(10)+360*5;
GC11(11)=GC11(11)+360*6;
GC11(12)=GC11(12)+360*6;
GC11(13)=GC11(13)+360*7;


ordered2 = [GC6,GC7,GC8,GC9,GC10,GC11];
angles = angles-angles(ref);


l=2;
for ma = 1:N_GC
    if(ma == 1)
        plot(angles,GC6,'-x',linewidth=l);
    elseif(ma == 2)
        plot(angles,GC7,'-o',linewidth=l);
    elseif(ma == 3)
        plot(angles,GC8,'-*',linewidth=l);
    elseif(ma == 4)
        plot(angles,GC9,'-^',linewidth=l);
    elseif(ma == 5)
        plot(angles,GC10,'-square',linewidth=l);
    elseif(ma == 6)
        plot(angles,GC11,'-pentagram',linewidth=l);
    end
end

% legend('GC6','GC7','GC8','GC9','GC10','GC11');
xlabel('Angle (deg)');
ylabel('Channel Phase (deg)');
xlim([-4,4])
% title('Element phases referenced to CH1');
set(gca,'FontSize',fon);
xticks([-4,-3,-2,-1,0,1,2,3,4])
xticklabels({'-4','-3','-2','-1','0','1','2','3','4'})
legend('CH6','CH5','CH4','CH3','CH2','CH1','FontSize',8,'Location','southeast');

%% Reconstructed Pattern

fprintf('Reconstructing pattern\n');

lambda = 1555.23e-9;
d = 10.85e-6;
kd = 2*pi/lambda*d;

thetas = linspace(-17,17,10000);
AF = zeros(size(thetas));

correction = rand(2,6)*0;
% ordered  = [0 0 0 0 0 0;
%             0 10 20 30 40 50];

ref_phase = ordered(ref,:);
for i = 1:N_angles
    ordered(i,:) = ordered(i,:) - ref_phase;
end


fig = figure;
set(gcf,'color','w');
x0=500;
y0=500;
width=350;
height=300;
set(gcf,'position',[x0,y0,width,height])
grid on
hold on
box on

ma_all = [1:8]; % which angles to look at
gc_all = [6 5 4 3 2 1]; % 1 to 6 grating couplers

AFs=[];
Legend=cell(length(ma_all),1);
for ma_idx = 1:length(ma_all)
    AF = zeros(size(thetas));
    ma = ma_all(ma_idx);
    amp = amps2(ma_idx,:);
    for gc_idx = 1:length(gc_all)
       i = gc_all(gc_idx);
       gc_phase = ordered(ma,i);
       effect = exp(1j*deg2rad(gc_phase))*exp(1j*(gc_idx-1)*kd*sind(thetas));
       AF = AF + effect;
    end
    AFs=[AFs;AF];
    Legend{ma_idx}=strcat(num2str(angles(ma)),' deg');
end
abs_AFs=abs(AFs);
norm_AFs=abs_AFs./max(max(abs_AFs));
log_AFs=20.*log10(norm_AFs); % power decibels: -3 dB marks half power
fovs=[];
bws=[];
for ma_idx = 1:length(ma_all)
%     plot(thetas,norm_AFs(ma_idx,:));
    plot(thetas,log_AFs(ma_idx,:),linewidth=3);
    [m,mi] = findpeaks(norm_AFs(ma_idx,:), "MinPeakProminence",0.3);
%     findpeaks(norm_AFs(ma_idx,:), "MinPeakProminence",0.3)
    fov=abs(thetas(mi(1))-thetas(mi(2)));
    fovs=[fovs,fov];
    dif=round(abs(mi(1)-mi(2))/2);
    pow_beam=log_AFs(ma_idx,mi(2)-dif:mi(2)+dif);
    th_beam=thetas(mi(2)-dif:mi(2)+dif);
    [s,si] = sort(abs(pow_beam+3));
    i=2;
    bw=abs(th_beam(si(i))-th_beam(si(1)));
    while bw<1
        bw=abs(th_beam(si(i))-th_beam(si(1)));
        i=i+1;
    end
    bws=[bws,bw];
end
xlim([-4,4])
ylim([-20,0])
mean(fovs)
mean(bws)

fon=12;

xlabel('Angle (deg)')
ylabel('Normalized Array Factor (dB-rel)')
xticks([-4,-3,-2,-1,0,1,2,3,4])
xticklabels({'-4','-3','-2','-1','0','1','2','3','4'})
legend(Legend,'NumColumns',2,'Location','southeast')
set(gca,'FontSize',fon);