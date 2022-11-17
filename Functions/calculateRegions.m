function [R_Fresnel, R_Fraunhofer] = calculateRegions(D, lambda)
%CALCULATEREGIONS Caclulate the boundaries of the three regions of a
%transmitting antenna: Reactive Near Field - Fresnel region - Fraunhofer
%region.

    R_Fresnel = 0.6*sqrt(D^3/lambda);
    R_Fraunhofer = 2*D^2/lambda;
end

