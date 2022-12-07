%% TN515: Antenna Characterization - TP LEMA DRONE
clc, close all, clear all

%% Load and create data
warning('off')

addpath('Data','Functions','Images')
folderSrc = '*/*.csv';
matrixFilelist = dir(folderSrc);

data = struct();
for file = 1:length(matrixFilelist)
    filename = matrixFilelist(file).name;
    name = split( filename, '.'); name = name{1};
    data.(name) = readtable(filename);
    if size(data.(name),2) == 2
        data.(name).Properties.VariableNames = {'x', 'y'};
    elseif size(data.(name),2) == 3
        data.(name).Properties.VariableNames = {'x', 'y_real','y_imag'};
    end
end

%% Plot data

% Reflection coefficient
s11_A = data.s11_A_dBMag ;
s11_B = data.s11_B_dBMag ;

figure('WindowState','maximized');
% plot(s11_A.x*10^-9, dB2dec(s11_A.y) ), hold on
% plot(s11_B.x*10^-9, dB2dec(s11_B.y) )
plot(s11_A.x*10^-9, s11_A.y ), hold on
plot(s11_B.x*10^-9, s11_B.y )
legend('Antenna A', 'Antenna B','Location','East','FontSize',14)
grid on, grid minor
title('Reflection coefficient','FontSize',16)
xlabel('Frequency [GHz]','FontSize',14), ylabel('s_{11} [dB]','FontSize',14)

exportgraphics(gcf,'./Images/Reflection_Coefficient.png')

% VSWR measured
VSWR_A = data.VSWR_A;
VSWR_B = data.VSWR_B;

figure('WindowState','maximized');
plot(VSWR_A.x*10^-9, VSWR_A.y), hold on
plot(VSWR_B.x*10^-9, VSWR_B.y)
legend('Antenna A', 'Antenna B','Location','SouthEast','FontSize',14)
grid on, grid minor
title('Measured Voltage Standing Wave Ratio','FontSize',16)
xlabel('Frequency [GHz]','FontSize',14), ylabel('VSWR [/]','FontSize',14)
ylim([0 10])

exportgraphics(gcf,'./Images/VSWR_Measured.png')

% VSWR calculated
VSWR_A_calc = ( 1 + abs( dB2dec(s11_A.y) ) )./( 1 - abs( dB2dec(s11_A.y) ) );
VSWR_B_calc = ( 1 + abs( dB2dec(s11_B.y) ) )./( 1 - abs( dB2dec(s11_B.y) ) );

figure('WindowState','maximized');
plot(VSWR_A.x*10^-9, VSWR_A_calc), hold on
plot(VSWR_B.x*10^-9, VSWR_B_calc)
legend('Antenna A', 'Antenna B','Location','SouthEast','FontSize',14)
grid on, grid minor
title('Calculated Voltage Standing Wave Ratio','FontSize',16)
xlabel('Frequency [GHz]','FontSize',14), ylabel('VSWR [/]','FontSize',14)
ylim([0 10])

exportgraphics(gcf,'./Images/VSWR_Calculated.png')

% VSWR superimposed

figure('WindowState','maximized'); t = tiledlayout(1,2,'TileSpacing','Compact','Padding','Compact');
nexttile; hold on
plot(VSWR_A.x*10^-9, VSWR_A.y)
plot(VSWR_A.x*10^-9, VSWR_A_calc)
ylim([0 10])
grid on, grid minor
title('Antenna A','FontSize',16)

nexttile; hold on
plot(VSWR_B.x*10^-9, VSWR_B.y)
plot(VSWR_B.x*10^-9, VSWR_B_calc)
ylim([0 10])
grid on, grid minor
title('Antenna B','FontSize',16)

xlabel(t,'Frequency [GHz]','FontSize',14), ylabel(t,'VSWR [/]','FontSize',14)
title(t,'Voltage Standing Wave Ratio','FontSize',20)
l = legend('Measured', 'Calculated','FontSize',14);
l.Layout.Tile = 'North';
linkaxes(t.Children,'xy')

exportgraphics(gcf,'./Images/VSWR_Superimposed.png')

%% Bandwidth and center frequency 

    % center frequency
    
[~,idx_A] = findpeaks(-s11_A.y,'MinPeakHeight',0.5*max(-s11_A.y));
[~,idx_B] = findpeaks(-s11_B.y,'MinPeakHeight',0.5*max(-s11_B.y));

freq_center_A = s11_A.x( idx_A(2) );
freq_center_B = s11_B.x( idx_B(2) );

idx_center = idx_A(2);

    % bandwidth
    %(-->  domain where VSWR < 2 ?)
    % or interpolate s11 and take -3dB
    
% p_A = polyfit(s11_A.x*10^-9, s11_A.y,3); fit_A = polyval(p_A, s11_A.x*10^-9);
% p_B = polyfit(s11_A.x*10^-9, s11_A.y,3); fit_B = polyval(p_B, s11_B.x*10^-9);

figure('WindowState','maximized'); t = tiledlayout(1,2,'TileSpacing','Compact','Padding','Compact');
nexttile; hold on
plot(s11_A.x*10^-9, s11_A.y)
plot(s11_A.x(idx_A)*10^-9, s11_A.y(idx_A),'ro')
% plot(s11_A.x*10^-9, fit_A)
ylim([-45, 5])
grid on, grid minor
title('Antenna A','FontSize',16)

nexttile; hold on
plot(s11_B.x*10^-9, s11_B.y)
plot(s11_B.x(idx_B)*10^-9, s11_B.y(idx_B),'ro')
% plot(s11_B.x*10^-9, fit_B)
ylim([-45, 5])
grid on, grid minor
title('Antenna B','FontSize',16)

xlabel(t,'Frequency [GHz]','FontSize',14), ylabel(t,'s_{11} [dB]','FontSize',14)
title(t,'Center frequency and Bandwidth','FontSize',20)
linkaxes(t.Children,'xy')

% exportgraphics(gcf,'./Images/CenterFrequency_Bandwidth.png')

%% Calculate Fresnel and Fraunhofer domains

D = 16.9*10^-2; % [m]
lambda_A = 3*10^8/freq_center_A; % [m]
lambda_B = 3*10^8/freq_center_B; % [m]

[R_Fresnel_A, R_Fraunhofer_A] = calculateRegions(D,lambda_A); % [m]
[R_Fresnel_B, R_Fraunhofer_B] = calculateRegions(D,lambda_B); % [m]

%% Smith Chart 
close all

s11_A_complex = data.s11_A_Complex;
s11_B_complex = data.s11_B_Complex;
K1_A = s11_A_complex.y_real( idx_center ) + j*s11_A_complex.y_imag( idx_center );
K1_B = s11_B_complex.y_real( idx_center ) + j*s11_B_complex.y_imag( idx_center );

smithplot(K1_A,'ro','TitleTop','Smith Chart before impedance matching')
hold on
smithplot(K1_B,'bo')
legend('Antenna A', 'Antenna B','Location','Best')

exportgraphics(gcf,'./Images/SmithChart_Before.png')

 %%  Impedance matching
 [u_A,l_A] = impedanceMatching(50, K1_A, lambda_A);
 [u_B,l_B] = impedanceMatching(50, K1_B, lambda_B);
