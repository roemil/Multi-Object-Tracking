function [fxk,Fxk] = CT_steering(xk,Ts)

% Constant turn-rate, i.e. non-zero turning-angle

global par

% Velocity
v = xk(3);
% Heading
phi = xk(4);
% Steering angle
omega = xk(5);
% Length of wheelbase
wb = par.wheelbase_factor;
len = xk(6)*wb;

% Distance traveled
d = Ts*v;
% Turning angle
beta = (d/len)*tan(omega);

% Allocate memory for Jacobian
Fxk = eye(7);

if abs(omega)>(1e-9)*pi/180 && d~=0
    % Turning radius
    R = d/beta;
    % Update the state
    fxk = xk+[
        -R*sin(phi)+R*sin(phi+beta); % Update to x-position
        R*cos(phi)-R*cos(phi+beta);  % Update to y-position
        0;                           % Velocity is the same
        beta;                        % Updated heading
        0;                           % Steering angle is the same
        0;                           % Same length
        0                            % Same width
        ];                          
    
    Fxk(1,3) = Ts*cos(phi+beta);
    Fxk(1,4) = R*(-cos(phi)+cos(phi+beta));
    Fxk(1,5) = len*(1+tan(omega)^-2)*(sin(phi)-sin(phi+beta))+v*Ts*cos(phi+beta)*(tan(omega)+tan(omega)^-1);
    Fxk(1,6) = (wb/tan(omega))*(-sin(phi)+sin(phi+beta))-(d/xk(6))*cos(phi+beta);
    
    Fxk(2,3) = Ts*sin(phi+beta);
    Fxk(2,4) = R*(-sin(phi)+sin(phi+beta));
    Fxk(2,5) = len*(1+tan(omega)^-2)*(-cos(phi)+cos(phi+beta))+v*Ts*sin(phi+beta)*(tan(omega)+tan(omega)^-1);
    Fxk(2,6) = (wb/tan(omega))*(cos(phi)-cos(phi+beta))-(d/xk(6))*sin(phi+beta);
    
    Fxk(4,3) = (Ts/len)*tan(omega);
    Fxk(4,5) = (v*Ts/len)*(1+tan(omega)^2);
    Fxk(4,6) = -(d/wb/(xk(6)^2))*tan(omega);
else
    fxk = xk + [
        d*cos(phi);
        d*sin(phi);
        0;
        beta;
        0;
        0;
        0
        ];
    
    Fxk(1,3) = Ts*cos(phi);
    Fxk(1,4) = -d*sin(phi);
    Fxk(1,5) = -0.5*((d^2)/len)*sin(phi);
    
    Fxk(2,3) = Ts*sin(phi);
    Fxk(2,4) = d*cos(phi);
    Fxk(2,5) = 0.5*((d^2)/len)*cos(phi);
    
    Fxk(4,3) = Ts*tan(omega)/len;
    Fxk(4,5) = (d/len)*(1/cos(omega)^2);
    Fxk(4,6) = -(v*Ts*tan(omega)/wb)/(xk(6)^2);
end