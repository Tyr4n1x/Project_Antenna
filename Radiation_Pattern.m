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
        
exportgraphics(gcf,'./Images/Radiation_Pattern_Elevation.png')