clear all, close all, clc
%% Free space link
    %% Power for different distances

addpath('Data','Functions','Images')
load('./Data/Center_Frequency.mat')

D = 16.9*10^-2; % [m]
lambda_B = 3*10^8/freq_center; % [m]
[R_Fresnel_B, R_Fraunhofer_B] = calculateRegions(D,lambda_B); % [m]

d = [3.81	 3.23    2.63    2.03    1.43    0.83]; % [m]
P = [-35.9  -36.8   -35.6   -31.8   -29.1   -24.1]; % [dBm]

opts = optimset('Display','off');
fun = @(a,d) a(1)./d.^2 + a(2);
a0 = [10 -10];
coeff = lsqcurvefit(fun,a0,d,P,[],[], opts);
d1 = linspace(floor(min(d)),ceil(max(d)));
fit = fun(coeff,d1);

figure(); hold on
plot(d, P, '*')
plot(d1, fit, 'b')
xline([R_Fresnel_B R_Fraunhofer_B],'r')
xlabel('Distance from Tx [m]'); ylabel('Received power [dBm]')
grid on, grid minor
axis([0 4 -40 -10])
title('Received power in function of distance')
legend('Measured values', 'Polyfit $\frac{a}{x^2} + b $','Fraunhofer / Fresnel limit',...
       'Location','SouthWest','Interpreter','Latex')

exportgraphics(gcf,'./Images/FreeSpace_Distance.png')

    %% Polarization mismatch
    
theta = 0:15:90; % [°]
P = [-36.2  -37.2   -39.5   -46.7   -54.4   -62.4   -52.3]; % [dBm]

figure();
polarplot(deg2rad(theta), P, '*--')
thetalim([theta(1) theta(end)]);
thetaticks(theta);
rlim([-65 -35])
title('Polarization mismatch')

exportgraphics(gcf,'./Images/FreeSpace_Polarization.png')

    %% Relative angle

theta = -90:15:90; % [°]
P = [-45.1  -45.0   -55.8   -51.7   -44.3   -40.9   -36.8 ...
     -35.1  -36.5   -38.0   -43.9   -54.8   -46.2]; % [dBm]

figure();
polarplot(deg2rad(theta), P, '*--')
thetalim([theta(1) theta(end)]);
thetaticks(theta);
rlim([-65 -35])
title('Relative angle')

ax = gca;
ax.ThetaDir = 'counterclockwise';
ax.ThetaZeroLocation = 'top';
ax.RAxisLocation = 0;

exportgraphics(gcf,'./Images/FreeSpace_Relative_Angle.png')

%% Two-ray model
clc, close all
    %% Position of hole

P = [-37.9  -37.7   -37.8   -38.1   -37.9   -37.6];

figure();
plot(P,'*--')
grid on, grid minor
xticks(1:length(P)); xticklabels({'@Tx','@Tx+1','@Tx+2','@Tx+3','@Tx+4','@Tx+5'})
xlim([0.5 length(P)+0.5]); ylim([-40 -35])
xlabel('Position of hole')
ylabel('Received power [dBm]')
title('Influence of hole position')

exportgraphics(gcf,'./Images/TwoRay_Position.png')

rel_diff = abs( max(P) - min(P) ) / abs( max(P) );
fprintf('The relative difference between the highest and lowest received power is %0.2f%%. \n', rel_diff*100)

    %% Number of holes

n_holes = 0:10;
P = [-37.9	-37.6   -37.8   -38.1   -38.3   -38.7 ...
     -38.2  -38.6   -38.6   -38.4   -38.3];

figure();
plot(n_holes, P, '*--')
grid on, grid minor
xticks(n_holes); xticklabels({'0','1','2','3','4','5','5+1','5+2','5+3','5+4','10'})
xlim([-0.5 length(P)-0.5]); ylim([-40 -35])
xlabel('Number of holes')
ylabel('Received power [dBm]')
title('Influence of number of holes')

exportgraphics(gcf,'./Images/TwoRay_NumberHoles.png')

rel_diff = abs( max(P) - min(P) ) / abs( max(P) );
fprintf('The relative difference between the highest and lowest received power is %0.2f%%. \n', rel_diff*100)

%% Small-scale fading
    %% Extract the data
clear all, close all

data = readmatrix('AE_DRONE.csv','Delimiter',';');
received_power = max(data,[],2);
attenuation = 10 - received_power; % 10 dBm start value

figure()
plot(received_power)
grid on, grid minor
xlabel('Time [samples]')
ylabel('Power [dBm]')
title('Received Power')

exportgraphics(gcf,'./Images/SmallScale_Received_Power.png')

    %% Fit a Rician distribution
    
dist = fitdist(attenuation,'Rician');

K = 10*log10( dist.s^2/(2*dist.sigma^2) );

pdf = @(x) pdf(dist,x);
ci(1) = dist.s - 2*dist.sigma; 
ci(2) = dist.s + 2*dist.sigma;

figure(); hold on
fplot(pdf, [0 2*dist.s])
area(linspace(ci(1),ci(2)), pdf(linspace(ci(1),ci(2))), 'LineStyle','none')
ylim( [0 0.075] )
xlabel('Attenuation [dB]'); title({'PDF of the Rician Distribution',sprintf('(K = %0.3f)',K)})

exportgraphics(gcf,'./Images/SmallScale_Rician_Distribution.png')

fprintf('Confidence interval between %0.2f dB and %0.2f dB : %0.2f%% \n',...
        ci(1), ci(2), integral(pdf,ci(1),ci(2))*100 )
