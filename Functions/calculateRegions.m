function [R_Fresnel, R_Fraunhofer] = calculateRegions(D, lambda)
%CALCULATEREGIONS Caclulate the boundaries of the three regions of a
%transmitting antenna: Reactive Near Field - Fresnel region - Fraunhofer
%region.

    R_Fresnel = max([0.6*sqrt(D^3/lambda), 20*D, 20*lambda/(2*pi)]);
    R_Fraunhofer = max([2*D^2/lambda, 20*D, 20*lambda/(2*pi)]);
end

