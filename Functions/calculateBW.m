function [BW, f_center] = calculateBW(freq, s11)
%calculateBW Calculate the bandwidth and center frequency based on the
%reflection coefficient s11 [dB]. Considers peak values larger than 50% of the
%largest peak (peaks are negative).

    [peaks,locs] = findpeaks(-s11,'MinPeakHeight',0.5*max(-s11)) % choice of 50%
    f_center = freq(locs)
    
    for loc = locs
        [~,idx] = min( abs( s11 + (s11(loc)+3) ) )
    end
end

