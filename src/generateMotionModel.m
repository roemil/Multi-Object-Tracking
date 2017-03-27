%%%%% Function for generating motion model %%%%%
% Assumptions: 2D
% Input:
%       Xprev:  Previous state x. If xprev is full sequence, input x{1,k-1}
%       sigmaQ: Motion variance
%       T:      Sampling time
%       model:  Choice of motion model (cv,ca,ct,bm)
% Output:
%       F:      Motion model
%       Q:      Motion covariance matrix

function [F, Q] = generateMotionModel(sigmaQ, T, model)

% Constant velocity
if strcmp(model,'cv')
    % x = [x,y,vx,vy]^T
    F = kron([1 T; 0 1],eye(2));
    Q = sigmaQ^2*kron([T^3/3 T^2/2;T^2/2,T],eye(2));

% Constant acceleration
elseif strcmp(model,'ca')
    % x = [x,y,vx,vy,ax,ay]^T
    F = kron([1 T T^2/2; 0 1 T; 0 0 1],eye(2));
    Q = sigmaQ^2*kron([T^5/20 T^4/8 T^3/6;T^4/8 T^3/3 T^2/2;T^3/6 T^2/2 T],eye(2));

% Coordinated turn
elseif strcmp(model,'ct')
    disp('ERROR: Not yet implemented')
    return
    
% Bicycle model
elseif strcmp(model,'bm')
    disp('ERROR: Not yet implemented')
    return
    
end