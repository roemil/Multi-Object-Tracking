%%%%% Function for passing states through the motion model in a controlled manner %%%%%
% Assumptions: 2D
% Input:
%       Xprev:  Previous state x. If xprev is full sequence, input x{1,k-1}
%       sigmaQ: Motion variance
%       T:      Sampling time
%       model:  Choice of motion model (cv,ca,ct,bm)
% Output:
%       X:      xprev through motion model. If xprev is full sequence and
%               concaination is wanted, use x = {xprev{1,end+1},x}
%       Q:      Motion covariance matrix

function [X, Q] = motionCurve(Xprev, sigmaQ, T, model, turnRate)

% Constant velocity
if strcmp(model,'cv')
    if size(Xprev,1) == 4
        % x = [x,y,vx,vy]^T
        vAbs = sqrt(Xprev(3,1)^2+Xprev(4,1)^2);
        X = kron([1 T; 0 1],eye(2))*Xprev;
        X(3:4,1) = Xprev(3:4,1)'*[cosd(turnRate) -sind(turnRate); sind(turnRate) cosd(turnRate)];
        Q = sigmaQ*kron([T^3/3 T^2/2;T^2/2,T],eye(2));
        % Add noise. NOTE: No correlation between pos and velo
        for i = 1:size(X,2)
            X(:,i) = X(:,i)+normrnd(zeros(4,1),sigmaQ*[0, 0, abs(X(3,i)), abs(X(4,i))]',4,1);
        end
    else
        disp('ERROR: xprev has the wrong number of states')
        return
    end

% Constant acceleration
elseif strcmp(model,'ca')
    disp('ERROR: Not yet implemented')
    return

% Coordinated turn
elseif strcmp(model,'ct')
    disp('ERROR: Not yet implemented')
    return
    
% Bicycle model
elseif strcmp(model,'bm')
    disp('ERROR: Not yet implemented')
    return
    
end