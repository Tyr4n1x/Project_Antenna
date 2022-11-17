function [dec] = dB2dec(dB)
%dB2dec Convert dB values to decimal

    dec = 10.^(dB/20);
    
end

