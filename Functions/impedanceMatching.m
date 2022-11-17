function [u,l] = impedanceMatching(Z_0, K1_Ae, lambda)
    syms b u
    
    Z_L = Z_0*(1+K1_Ae)/(1-K1_Ae);
    sol = double(solve(abs(K1_Ae) == abs((-2*b*j+b^2)/(4+b^2)),b));

    for i = 1:length(sol)
        if sol(i) > 0
            s = sol(i);
            break
        end
    end

    y = 1+s*j;
    
    Z = 1/y*Z_0;
    K1 = (1-y)/(1+y);
    theta_1 = angle(K1);
    
    T = Z_0*(Z-Z_L)/(Z_0^2-Z*Z_L)/j;
    
    u = double( solve(2*pi/lambda*u == atan(T), u) );
    
    if abs(imag(u)) < 10^-7
        u = real(u);
    else
        fprintf('Error, u is not purely real')
    end

    K = (1-s*j)/(1+s*j);
    theta = angle(K);
    l = lambda/(4*pi)*abs(theta);
end