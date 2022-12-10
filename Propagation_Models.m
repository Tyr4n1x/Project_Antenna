clear all, close all, clc
%% Free space link
    %% power for different distances
close all

addpath('Data','Functions','Images')
load('./Data/Center_Frequency.mat')

D = 16.9*10^-2; % [m]
lambda_B = 3*10^8/freq_center; % [m]
[R_Fresnel_B, R_Fraunhofer_B] = calculateRegions(D,lambda_B); % [m]

d = [3.81	 3.23    2.63    2.03    1.43    0.83]; % [m]
P = [-35.9  -36.8   -35.6   -31.8   -29.1   -24.1]; % [dBm]
attenuation = 10 - P; % transmit 10 dBm


figure(); hold on
plot(d, attenuation,'*')
xline([R_Fresnel_B R_Fraunhofer_B],'r')
xlabel('Distance from Tx [m]'); ylabel('Attenuation [dB]')
grid on, grid minor
title('Attenuation in function of distance')

exportgraphics(gcf,'./Images/FreeSpace_Distance.png')

x = d.';
y = P.';
n = -2;
A = [];
for i = n:-n:0
  A = [A x.^i];
end
coeff = A\y;

p1 = @(d) coeff(1).*d.^(-2) + coeff(2);
d1 = 0:0.01:4;

figure(); hold on
plot(d, P,'*')
plot(d1,p1(d1),'b')
xline([R_Fresnel_B R_Fraunhofer_B],'r')
xlabel('Distance from Tx [m]'); ylabel('Received power [dBm]')
grid on, grid minor
axis([0 4 -40 -10])
title('Received power in function of distance')
legend('Measured values', 'Polyfit $\frac{a}{x^2} + b $','Fraunhofer / Fresnel limit','Location','SouthWest','Interpreter','latex')

exportgraphics(gcf,'./Images/ReceivedPower_Distance.png')

    %% Polarization mismatch
close all
    
theta = 0:15:90; % [°]
P = [-36.2  -37.2   -39.5   -46.7   -54.4   -62.4   -52.3]; % [dBm]
%attenuation = 10 - P; % transmit 10 dBm

figure();
polarplot( deg2rad(theta) ,P,'*--')
title('Polarization mismatch')
thetalim([theta(1) theta(end)]);
rlim([-65 -35])

exportgraphics(gcf,'./Images/FreeSpace_Polarization.png')

    %% Relative angle
close all

theta = -90:15:90; % [°]
P = [-45.1  -45.0   -55.8   -51.7   -44.3   -40.9   -36.8 ...
     -35.1  -36.5   -38.0   -43.9   -54.8   -46.2]; % [dBm]
%attenuation = 10 - P; % transmit 10 dBm

figure();
polarplot( deg2rad(theta) ,P,'*--')
title('Relative angle')
thetalim([theta(1) theta(end)]);
rlim([-59 -35])

pax = gca;
pax.ThetaDir = 'counterclockwise';
pax.ThetaZeroLocation = 'top';

exportgraphics(gcf,'./Images/FreeSpace_Relative_Angle.png')

%% Two-ray model
clc, close all
    %% position of hole
close all

P = [-37.9  -37.7   -37.8   -38.1   -37.9   -37.6];
%attenuation = 10 - P; % transmit 10 dBm

figure();
plot(P,'*--')
grid on, grid minor
xlabel('Position of hole')
ylabel('Received power [dBm]')
title('Influence of hole position')
exportgraphics(gcf,'./Images/TwoRay_Position.png')

P_sort = sort(P);
rel_diff = abs((P_sort(1) - P_sort(end)))/abs(P_sort(1));
fprintf('The relative difference between the highest and lowest received power is %0.2f%%. \n', rel_diff*100)


    %% number of holes

n_holes = 0:10;
P = [-37.9	-37.6   -37.8   -38.1   -38.3   -38.7 ...
     -38.2  -38.6   -38.6   -38.4   -38.3];
%attenuation = 10 - P; % transmit 10 dBm

figure();
plot(n_holes, P, '*--')
grid on, grid minor
xlabel('Number of holes')
ylabel('Received power [dBm]')
title('Influence of number of holes')
exportgraphics(gcf,'./Images/TwoRay_NumberHoles.png')

P_sort = sort(P);
rel_diff = abs((P_sort(1) - P_sort(end)))/abs(P_sort(1));
fprintf('The relative difference between the highest and lowest received power is %0.2f%%. \n', rel_diff*100)

%% Small-scale fading
    %% Extract the data
clear all, close all

data = readmatrix('AE_DRONE.csv','Delimiter',';');
received_power = max(data,[],2);
attenuation = 10 - received_power; % 10 dBm start value

    %% Fit a Rician distribution
close all
dist = fitdist(attenuation,'Rician');

K = 10*log10( dist.s^2/(2*dist.sigma^2) );

pdf = @(x) pdf(dist,x);
ci(1) = dist.s - 2*dist.sigma; 
ci(2) = dist.s + 2*dist.sigma;

figure(); hold on
fplot(pdf, [0 2*dist.s])
% xline(ci,'r')
ylim( [0 0.075] )
xlabel('Attenuation [dB]'); title({'PDF of the Rician Distribution',sprintf('(K = %0.3f)',K)})

exportgraphics(gcf,'./Images/Rician_Distribution.png')

figure(), hold on
plot(received_power)
title('Received Power')
xlabel('Time [samples]'), ylabel('Power [dBm]')
grid on, grid minor
exportgraphics(gcf,'./Images/DataSmallScale.png')