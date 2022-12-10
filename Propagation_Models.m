clear all, close all, clc
%% Free space link
    %% power for different distances
    
addpath('Data','Functions','Images')
load('./Data/Center_Frequency.mat')

D = 16.9*10^-2; % [m]
lambda_B = 3*10^8/freq_center_B; % [m]
[R_Fresnel_B, R_Fraunhofer_B] = calculateRegions(D,lambda_B); % [m]

d = [3.81	 3.23    2.63    2.03    1.43    0.83]; % [m]
P = [-35.9  -36.8   -35.6   -31.8   -29.1   -24.1]; % [dBm]
attenuation = 10 - P; % transmit 10 dBm

figure(); hold on
plot(d, attenuation,'*')
xline([R_Fresnel_B R_Fraunhofer_B],'r')
xlabel('Distance from Tx [m]'); ylabel('Attenuation [dB]')
title('Attenuation in function of distance')

exportgraphics(gcf,'./Images/FreeSpace_Distance.png')

    %% polarisation mismatch
    
theta = 0:15:90; % [°]
P = [-36.2  -37.2   -39.5   -46.7   -54.4   -62.4   -52.3]; % [dBm]
attenuation = 10 - P; % transmit 10 dBm

figure();
polarplot( deg2rad(theta) ,attenuation)
thetalim([theta(1) theta(end)]);

exportgraphics(gcf,'./Images/FreeSpace_Polarization.png')

    %% relative angle
    
theta = -90:15:90; % [°]
P = [-45.1  -45.0   -55.8   -51.7   -44.3   -40.9   -36.8 ...
     -35.1  -36.5   -38.0   -43.9   -54.8   -46.2]; % [dBm]
attenuation = 10 - P; % transmit 10 dBm

figure();
polarplot( deg2rad(theta) ,attenuation)
thetalim([theta(1) theta(end)]);

exportgraphics(gcf,'./Images/FreeSpace_Relative_Angle.png')

%% Two-ray model

    %% position of hole


P = [-37.9  -37.7   -37.8   -38.1   -37.9   -37.6];
attenuation = 10 - P; % transmit 10 dBm

figure();
plot(attenuation)

exportgraphics(gcf,'./Images/TwoRay_Position.png')

    %% number of holes

n_holes = 0:10;
P = [-37.9	-37.6   -37.8   -38.1   -38.3   -38.7 ...
     -38.2  -38.6   -38.6   -38.4   -38.3];
attenuation = 10 - P; % transmit 10 dBm

figure();
plot(n_holes, attenuation)

exportgraphics(gcf,'./Images/TwoRay_NumberHoles.png')

%% Small-scale fading
    %% Extract the data

data = readmatrix('AE_DRONE.csv','Delimiter',';');
data = 10 - max(data,[],2); % 10 dBm start value

    %% Fit a Rician distribution

dist = fitdist(data,'Rician');

K = 10*log10( dist.s^2/(2*dist.sigma^2) );

pdf = @(x) pdf(dist,x);
ci(1) = dist.s - 2*dist.sigma; ci(2) = dist.s + 2*dist.sigma;

figure(); hold on
fplot(pdf, [0 2*dist.s])
% xline(ci,'r')
ylim( [0 0.075] )
xlabel('Attenuation [dB]'); title({'PDF of the Rician Distribution',sprintf('(K = %0.3f)',K)})

exportgraphics(gcf,'./Images/Rician_Distribution.png')