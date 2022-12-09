clear all, close all, clc
%% Free space link
    %% power for different distances



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