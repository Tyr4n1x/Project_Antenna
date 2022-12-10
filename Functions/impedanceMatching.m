function [u,l] = impedanceMatching(Z_0, K1_Ae, lambda, vel_factor, do_plot)
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
    
    u = double( solve(2*pi/(lambda*vel_factor)*u == atan(T), u) );
    
    if abs(imag(u)) < 10^-7
        u = real(u);
    else
        fprintf('Error, u is not purely real')
    end

    K = (1-s*j)/(1+s*j);
    theta = angle(K);
    l = lambda*vel_factor/(4*pi)*abs(theta);
    
    fprintf('Need to add a stub of length %0.2f cm at %0.2f cm from the generator. \n',l*10^2,u*10^2)

    if do_plot

        figure();
        p = smithplot(K1_Ae,'ro',...
                    'TitleTop','Smith Chart before impedance matching',...
                    'TitleTopFontSizeMultiplier',1.5,...
                    'GridType','ZY');
        hold on
        smithplot(K1,'bo')

        start_angle = min(angle(K1_Ae), theta_1);
        end_angle = max(angle(K1_Ae), theta_1);

        circle(0,0,abs(K1_Ae))
        circle(-0.5,0,0.5)
        circle_arc(0,0,abs(K1_Ae),start_angle, end_angle,'r--')

        start_angle = -atan(abs(K1_Ae)/0.5);
        circle_arc(-0.5,0,0.5,start_angle,0,'b--')

        legend(['y_{start} = ', num2str( (1+K1_Ae)/(1-K1_Ae), '%0.2f')],...
               ['y_{2} = ', num2str(y, '%0.2f')],...
               'Location','NorthEast',...
               'FontSize',12)
        
        p.GridValue = [50 20 10 5 4 3 2:-0.2:1.2 1:-0.1:0.1; Inf 50 20 10 5 5 5*ones(1,5) 2*ones(1,10)];
        p.Parent.Children(2).XLim = [-0.1 0.1];
        p.Parent.Children(2).YLim = [-0.1 0.1];
        
    end
end

function circle(x,y,r)
    hold on
    th = 0:pi/100:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    plot(xunit, yunit);
end

function circle_arc(x,y,r, start, stop, linestyle)
    hold on
    th = start:pi/1000:stop;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;

    plot(xunit, yunit,linestyle, LineWidth=2);
end