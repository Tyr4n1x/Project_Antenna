clear all, close all, clc
%% Import the data

addpath('Data','Functions')

T_A = readtable('Radiation_Pattern.xlsx','Range','A1:G74','Sheet',1);
T_B = readtable('Radiation_Pattern.xlsx','Range','A1:G74','Sheet',2);

%% Format the Data

phi = T_A.Azimut; phi(isnan(phi)) = [];
theta = T_A.Elevation; theta(isnan(theta)) = [];

%% Polar plot Azimut

figure()
polarpattern(phi,T_A.Amplitude,...
            'AngleAtTop',0);
hold on
polarpattern(phi,T_B.Amplitude,...
            'AngleAtTop',0,...
            'TitleTop','Radiation Pattern in Azimut (zero elevation)');
        
legend('Antenna A','Antenna B','Location','Best')
        
exportgraphics(gcf,'./Images/Radiation_Pattern_Azimut.png')

%% Polar plot Elevation

figure()
polarpattern(theta,T_A.Amplitude_1(1:length(theta)),...
            'AngleAtTop',0,...
            'AngleTickLabelFormat','180',...
            'MagnitudeAxisAngle',180,...
            'View','Top');
hold on
polarpattern(theta,T_B.Amplitude_1(1:length(theta)),...
            'AngleAtTop',0,...
            'AngleTickLabelFormat','180',...
            'MagnitudeAxisAngle',180,...
            'View','Top',...
            'TitleTop','Radiation Pattern in Elevation (zero azimut)');
        
legend('Antenna A','Antenna B','Location','Best')
        
exportgraphics(gcf,'./Images/Radiation_Pattern_Elevation.png')

%% Gain

lambda_A = 0.2584; % [m]
lambda_B = 0.2617; % [m]

Att_cable = 15 - 13.38; % [dB]
P_Rx_A = -32.2; % [dBm]
P_Rx_B = -30.3; % [dBm]
E = 370*10^-3; % [V/m]

syms G
eqn_A = E == sqrt( 10^(P_Rx_A/10) * 10^-3 * (480*pi)/lambda_A^2 * 1/(10^(G/10)) * 1/(10^(Att_cable/10)) );
eqn_B = E == sqrt( 10^(P_Rx_B/10) * 10^-3 * (480*pi)/lambda_B^2 * 1/(10^(G/10)) * 1/(10^(Att_cable/10)) );

eq_A = 20*log10(E*10^3) == 47.8 + 10*log10(G) + 10*log10( 10^(P_Rx_A/10)*10^-6 ) - 20*log10(3*10^-3);

gain_A = double( solve(eqn_A,G) );
gain_B = double( solve(eqn_B,G) );

g = double( solve(eq_A,G) );