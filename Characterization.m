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

%% Visualize data

    % Reflection coefficient
    
s11_A = data.s11_A_dBMag ;
s11_B = data.s11_B_dBMag ;

figure();
plot(s11_A.x*10^-9, s11_A.y ), hold on
plot(s11_B.x*10^-9, s11_B.y )
legend('Antenna A', 'Antenna B','Location','East','FontSize',12)
grid on, grid minor
title('Reflection coefficient','FontSize',14)
xlabel('Frequency [GHz]','FontSize',12), ylabel('|s_{11}| [dB]','FontSize',12)

exportgraphics(gcf,'./Images/Reflection_Coefficient.png')

    % VSWR measured
    
VSWR_A = data.VSWR_A;
VSWR_B = data.VSWR_B;

figure();
plot(VSWR_A.x*10^-9, VSWR_A.y), hold on
plot(VSWR_B.x*10^-9, VSWR_B.y)
legend('Antenna A', 'Antenna B','Location','SouthEast','FontSize',12)
grid on, grid minor
title('Measured Voltage Standing Wave Ratio','FontSize',14)
xlabel('Frequency [GHz]','FontSize',12), ylabel('VSWR [/]','FontSize',12)
ylim([0 10])

exportgraphics(gcf,'./Images/VSWR_Measured.png')

    % VSWR calculated
    
VSWR_A_calc = ( 1 + abs( dB2dec(s11_A.y) ) )./( 1 - abs( dB2dec(s11_A.y) ) );
VSWR_B_calc = ( 1 + abs( dB2dec(s11_B.y) ) )./( 1 - abs( dB2dec(s11_B.y) ) );

figure();
plot(VSWR_A.x*10^-9, VSWR_A_calc), hold on
plot(VSWR_B.x*10^-9, VSWR_B_calc)
legend('Antenna A', 'Antenna B','Location','SouthEast','FontSize',12)
grid on, grid minor
title('Calculated Voltage Standing Wave Ratio','FontSize',14)
xlabel('Frequency [GHz]','FontSize',12), ylabel('VSWR [/]','FontSize',12)
ylim([0 10])

exportgraphics(gcf,'./Images/VSWR_Calculated.png')

    % VSWR superimposed

figure(); t = tiledlayout(1,2,'TileSpacing','Compact','Padding','Compact');
nexttile; hold on
plot(VSWR_A.x*10^-9, VSWR_A.y)
plot(VSWR_A.x*10^-9, VSWR_A_calc)
ylim([0 10])
grid on, grid minor
title('Antenna A')

nexttile; hold on
plot(VSWR_B.x*10^-9, VSWR_B.y)
plot(VSWR_B.x*10^-9, VSWR_B_calc)
ylim([0 10])
grid on, grid minor
title('Antenna B')

xlabel(t,'Frequency [GHz]'), ylabel(t,'VSWR [/]')
l = legend('Measured', 'Calculated');
l.Layout.Tile = 'North';
linkaxes(t.Children,'xy')

exportgraphics(gcf,'./Images/VSWR_Superimposed.png')

%% Bandwidth and center frequency 

    % bandwidth
    
f = linspace(0,3,10^4); % [GHz]
y_A = interp1(VSWR_A.x*10^-9, VSWR_A.y,f,'Linear');
p_A = InterX([f;y_A],[f;2*ones(1,length(f))]);
y_B = interp1(VSWR_B.x*10^-9, VSWR_B.y,f,'Linear');
p_B = InterX([f;y_B],[f;2*ones(1,length(f))]);

BW_A = p_A(1,4) - p_A(1,3); 
BW_B = p_B(1,4) - p_B(1,3);

figure(); t = tiledlayout(1,2,'TileSpacing','Compact','Padding','Compact');
nexttile; hold on
plot(VSWR_A.x*10^-9, VSWR_A.y)
yline(2,'r:')
plot(p_A(1,1:4),p_A(2,1:4),'ro')
ylim([0 10])
grid on, grid minor
title('Antenna A','FontSize',12)

nexttile; hold on
plot(VSWR_B.x*10^-9, VSWR_B.y)
yline(2,'r:')
plot(p_B(1,1:4),p_B(2,1:4),'ro')
ylim([0 10])
grid on, grid minor
title('Antenna B','FontSize',12)

xlabel(t,'Frequency [GHz]','FontSize',12), ylabel(t,'VSWR [/]','FontSize',12)
title(t,'Center frequency and Bandwidth','FontSize',14)
linkaxes(t.Children,'xy')

exportgraphics(gcf,'./Images/CenterFrequency_Bandwidth.png')

    % center frequency
    
[~,idx_A] = findpeaks(-VSWR_A.y,'MinPeakProminence',2.5); idx_A = idx_A(idx_A>15); % to cut the diverging domain in the beginning
[~,idx_B] = findpeaks(-VSWR_B.y,'MinPeakProminence',2.5); idx_B = idx_B(idx_B>15); % to cut the diverging domain in the beginning

fprintf('Overview \n')
fprintf('Antenna \t Center frequency \t Region \t \t \t \t \t \t Bandwidth \n')
fprintf('Antenna A \t %0.4f MHz \t \t %0.4f MHz - %0.4f MHz \t %0.4f MHz \n',...
        VSWR_A.x(idx_A(1))*10^-6, p_A(1,1)*10^3, p_A(1,2)*10^3, p_A(1,2)*10^3-p_A(1,1)*10^3 )
fprintf('Antenna A \t %0.4f GHz \t \t %0.4f GHz - %0.4f GHz \t \t %0.4f MHz \n',...
        VSWR_A.x(idx_A(2))*10^-9, p_A(1,3), p_A(1,4), p_A(1,4)*10^3-p_A(1,3)*10^3 )
fprintf('Antenna B \t %0.4f MHz \t \t %0.4f MHz - %0.4f MHz \t %0.4f MHz \n',...
        VSWR_B.x(idx_B(1))*10^-6, p_B(1,1)*10^3, p_B(1,2)*10^3, p_B(1,2)*10^3-p_B(1,1)*10^3 )
fprintf('Antenna B \t %0.4f GHz \t \t %0.4f GHz - %0.4f GHz \t \t %0.4f MHz \n',...
        VSWR_B.x(idx_B(2))*10^-9,p_B(1,3),p_B(1,4), p_B(1,4)*10^3-p_B(1,3)*10^3 )

freq_center = VSWR_A.x( idx_A(2) );
idx_center = idx_A(2);

save('./Data/Center_Frequency.mat','freq_center','idx_center');

%% Calculate Fresnel and Fraunhofer domains
clc

D = 16.9*10^-2; % [m]
lambda = 3*10^8/freq_center; % [m]

[R_Fresnel, R_Fraunhofer] = calculateRegions(D, lambda); % [m]

%% Smith Chart

s11_A_complex = data.s11_A_Complex;
s11_B_complex = data.s11_B_Complex;
K_A = s11_A_complex.y_real( idx_center ) + j*s11_A_complex.y_imag( idx_center );
K_B = s11_B_complex.y_real( idx_center ) + j*s11_B_complex.y_imag( idx_center );

figure();
p = smithplot(K_A,'ro',...
            'TitleTop','Smith Chart before impedance matching',...
            'TitleTopFontSizeMultiplier',1.5,...
            'GridType','ZY');
hold on
smithplot(K_B,'bo')
legend('Antenna A', 'Antenna B','Location','Best')

exportgraphics(gcf,'./Images/SmithChart_Before.png')

p.GridValue = [50 20 10 5 4 3 2:-0.2:1.2 1:-0.1:0.1; Inf 50 20 10 5 5 5*ones(1,5) 2*ones(1,10)];
p.Parent.Children(2).XLim = [-0.1 0.1];
p.Parent.Children(2).YLim = [-0.1 0.1];

exportgraphics(gcf,'./Images/SmithChart_Before_Zoom.png')

%% Impedance matching
clc, close all

[u_A,l_A] = impedanceMatching(50, K_A, lambda, 0.66, true);

exportgraphics(gcf,'./Images/Impedance_Matching_A.png')

[u_B,l_B] = impedanceMatching(50, K_B, lambda, 0.66, true);

exportgraphics(gcf,'./Images/Impedance_Matching_B.png')
 