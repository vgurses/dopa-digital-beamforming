clear
clc

load('../processed/20221214_10us.mat');
motor_angles = 266:1:278;
N_GC=6;
N_angles=13;


%% Channel Phases

fprintf('Calculating channel phases\n');
figure; hold on; grid on;
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

ref=7;

GC6 = (ordered2(:,1)-ordered2(ref,1))./pi.*180;
GC7 = (ordered2(:,2)-ordered2(ref,2))./pi.*180;
GC8 = (ordered2(:,3)-ordered2(ref,3))./pi.*180;
GC9 = (ordered2(:,4)-ordered2(ref,4))./pi.*180;
GC10 = ordered2(:,5)-ordered2(ref,5);

GC10(6:end)=GC10(6:end)-2*pi;
GC10(9:end)=GC10(9:end)-2*pi;
GC10(12:end)=GC10(12:end)-2*pi;
GC10=GC10./pi.*180;

PhaseDiff = (ordered(:,6)-ordered(1,6));
GC11 = (ordered(:,6)-ordered(1,6));
for jj=2:length(PhaseDiff)
    Jump = (PhaseDiff(jj)-PhaseDiff(jj-1));
    if( Jump > 0)
        dif = -(270-PhaseDiff(jj)+PhaseDiff(jj-1)+90);
    else
        dif = Jump;
    end
        GC11(jj)=GC11(jj-1)+dif;
end

ordered2 = [GC6,GC7,GC8,GC9,GC10,GC11];

for ma = 1:N_GC
    if(ma == 1)
            plot(angles,GC6,'-rx');
        elseif(ma == 2)
            plot(angles,GC7,'-yo');
        elseif(ma == 3)
            plot(angles,GC8,'-g*');
        elseif(ma == 4)
            plot(angles,GC9,'-^','Color','c');
        elseif(ma == 5)
            plot(angles,GC10,'-square','Color','b');
        elseif(ma == 6)
            plot(angles,GC11,'-pentagram','Color','m');
    end
end

legend('GC6','GC7','GC8','GC9','GC10','GC11');
xlabel('Angle of motor (deg)');
ylabel('Relative phase of GC (deg)');
title('Element phases referenced to GC6');

%% Relative Phases

fprintf('Calculating relative phases\n');
figure; hold on; grid on;

lambda = 1555.23e-9;
d = 10.85e-6;
kd = 2*pi/lambda*d;

rphase=diff(ordered2,1);
rangles=angles(2:end);
v=[1;1;1;1;1;1;1;1;1;1;1;1];
for i = 1:N_GC
    rphase_th(:,i)=-ones(length(rangles),1).*sind(v)*(i-1)*kd*360/2/pi;
end

for ma = 1:N_GC
    if(ma == 1)
            plot(rangles,rphase(:,ma),'-rx');
        elseif(ma == 2)
            plot(rangles,rphase(:,ma),'-yo');
        elseif(ma == 3)
            plot(rangles,rphase(:,ma),'-g*');
        elseif(ma == 4)
            plot(rangles,rphase(:,ma),'-^','Color','c');
        elseif(ma == 5)
            plot(rangles,rphase(:,ma),'-square','Color','b');
        elseif(ma == 6)
            plot(rangles,rphase(:,ma),'-pentagram','Color','m');
    end
end


for ma = 1:N_GC
    if(ma == 1)
            plot(rangles,rphase_th(:,ma),'-r');
        elseif(ma == 2)
            plot(rangles,rphase_th(:,ma),'-r');
        elseif(ma == 3)
            plot(rangles,rphase_th(:,ma),'-r');
        elseif(ma == 4)
            plot(rangles,rphase_th(:,ma),'-r');
        elseif(ma == 5)
            plot(rangles,rphase_th(:,ma),'-r');
        elseif(ma == 6)
            plot(rangles,rphase_th(:,ma),'-r');
    end
end

rphase_mean = mean(rphase,1);
rphase_std = std(rphase,1);

legend('GC6','GC7','GC8','GC9','GC10','GC11','Theory');
xlabel('Angle of motor (deg)');
ylabel('Relative phase of GC (deg)');
title('Element phases referenced to previous angle (\Phi_{ma_i}-\Phi_{ma_{i-1}})');

%% Reconstructed Pattern

fprintf('Reconstructing pattern\n');

lambda = 1555.23e-9;
d = 10.85e-6;
kd = 2*pi/lambda*d;

thetas = linspace(-10,10,1000);
AF = zeros(size(thetas));

correction = rand(2,6)*0;
% ordered  = [0 0 0 0;
%             0 10 20 43;
%             0 20 40 63;
%             0 30 60 103;
%             0 40 80 133;
%             0 50 100 143;
%             0 60 120 163;
%             0 70 140 203];


ref = 7;
ref_phase = ordered(ref,:);
for i = 1:N_angles
    ordered(i,:) = ordered(i,:) - ref_phase;
end

figure; hold on; grid on;
ma_all = [3:10]; % which angles to look at
gc_all = [1 2 3 4 6]; % 1 to 6 grating couplers

for ma_idx = 1:length(ma_all)
    AF = zeros(size(thetas));
    ma = ma_all(ma_idx);
    for gc_idx = 1:length(gc_all)
       i = gc_all(gc_idx);
       gc_phase = ordered(ma,gc_idx);
       effect = exp(1j*deg2rad(gc_phase))*exp(1j*(gc_idx-1)*kd*sind(90)*sind(thetas))*exp(1j*deg2rad(correction(gc_idx)));
       AF = AF + effect;
    end
    AF = abs(AF);
    AF = AF./max(AF);
    if(ma == 7)
        plot(thetas,AF,'*');
    elseif(ma == 6)
        plot(thetas,AF,'--');
    else
        plot(thetas,AF);
    end
end
legend

