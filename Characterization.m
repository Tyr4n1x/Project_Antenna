%% TN515: Antenna Characterization - TP LEMA DRONE
clc, close all, clear all

%% Load and create data
warning('off')

addpath('Data','Functions')
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

figure(1);
% plot(s11_A.x*10^-9, dB2dec(s11_A.y) ), hold on
% plot(s11_B.x*10^-9, dB2dec(s11_B.y) )
plot(s11_A.x*10^-9, s11_A.y ), hold on
plot(s11_B.x*10^-9, s11_B.y )
legend('Antenna A', 'Antenna B')
grid on, grid minor
title('Reflection coefficient')
xlabel('Frequency [GHz]'), ylabel('s_{11} [dB]')

% VSWR measured
VSWR_A = data.VSWR_A;
VSWR_B = data.VSWR_B;

figure(2);
plot(VSWR_A.x*10^-9, VSWR_A.y), hold on
plot(VSWR_B.x*10^-9, VSWR_B.y)
legend('Antenna A', 'Antenna B','location','southeast')
grid on, grid minor
title('Measured Voltage Standing Wave Ratio')
xlabel('Frequency [GHz]'), ylabel('VSWR [/]')
ylim([0 10])

% VSWR calculated
VSWR_A_calc = ( 1 + abs( dB2dec(s11_A.y) ) )./( 1 - abs( dB2dec(s11_A.y) ) );
VSWR_B_calc = ( 1 + abs( dB2dec(s11_B.y) ) )./( 1 - abs( dB2dec(s11_B.y) ) );

figure(3)
plot(VSWR_A.x*10^-9, VSWR_A_calc), hold on
plot(VSWR_B.x*10^-9, VSWR_B_calc)
legend('Antenna A', 'Antenna B','location','southeast')
grid on, grid minor
title('Calculated Voltage Standing Wave Ratio')
xlabel('Frequency [GHz]'), ylabel('VSWR [/]')
ylim([0 10])

% VSWR superimposed
figure(4)
subplot(1,2,1), hold on
plot(VSWR_A.x*10^-9, VSWR_A.y)
plot(VSWR_A.x*10^-9, VSWR_A_calc)
legend('Measured', 'Calculated','location','best')
grid on, grid minor
title('Antenna A')
xlabel('Frequency [GHz]'), ylabel('VSWR [/]')
ylim([0 10])

subplot(1,2,2), hold on
plot(VSWR_B.x*10^-9, VSWR_B.y)
plot(VSWR_B.x*10^-9, VSWR_B_calc)
legend('Measured', 'Calculated','location','best')
grid on, grid minor
title('Antenna B')
xlabel('Frequency [GHz]'), ylabel('VSWR [/]')
ylim([0 10])

sgtitle('Voltage Standing Wave Ratio')

%% Bandwidth and center frequency 

[~,idx_A] = findpeaks(-s11_A.y,'MinPeakHeight',0.5*max(-s11_A.y));
[~,idx_B] = findpeaks(-s11_B.y,'MinPeakHeight',0.5*max(-s11_B.y));

freq_center_A = s11_A.x( idx_A(2) );
freq_center_B = s11_B.x( idx_B(2) );

idx_center = idx_A(2);

figure(5)
subplot(1,2,1), hold on
plot(s11_A.x*10^-9, s11_A.y)
plot(s11_A.x(idx_A)*10^-9, s11_A.y(idx_A),'ro')
grid on, grid minor
title('Antenna A')
xlabel('Frequency [GHz]'), ylabel('s_{11} [dB]')
ylim([-45, 5])

subplot(1,2,2), hold on
plot(s11_B.x*10^-9, s11_B.y)
plot(s11_B.x(idx_B)*10^-9, s11_B.y(idx_B),'ro')
grid on, grid minor
title('Antenna B')
xlabel('Frequency [GHz]'), ylabel('s_{11} [dB]')
ylim([-45, 5])

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

figure(1),
smithplot(K1_A,'ro','TitleTop','Smith chart before impedance matching'), hold on
smithplot(K1_B,'bo')
legend('Antenna A', 'Antenna B','location','best')

 %%  Impedance matching
 [u_A,l_A] = impedanceMatching(50, K1_A, lambda_A)
 [u_B,l_B] = impedanceMatching(50, K1_B, lambda_B)
