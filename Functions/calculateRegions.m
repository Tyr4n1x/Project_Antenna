function [R_Fresnel, R_Fraunhofer] = calculateRegions(D, lambda)
%CALCULATEREGIONS Caclulate the boundaries of the three regions of a
%transmitting antenna: Reactive Near Field - Fresnel region - Fraunhofer
%region.
    
    fprintf('Formula \t Fresnel \t Fraunhofer \n')
    fprintf('1. \t \t \t %0.4f m \t %0.4f m \n', 20*lambda/(2*pi), 20*lambda/(2*pi) )
    fprintf('2. \t \t \t %0.4f m \t %0.4f m \n', 20*D, 20*D )
    fprintf('3. \t \t \t %0.4f m \t %0.4f m \n', 0.6*sqrt(D^3/lambda), 2*D^2/lambda )
    
    R_Fresnel = max([0.6*sqrt(D^3/lambda), 20*D, 20*lambda/(2*pi)]);
    R_Fraunhofer = max([2*D^2/lambda, 20*D, 20*lambda/(2*pi)]);
end

