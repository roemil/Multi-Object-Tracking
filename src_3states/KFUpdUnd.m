%   Perform update with linear KF and Gaussian models
%   
%   Input: Previous states Xprev, measurement model F, 
%   motion variance matrix P, measurement covariance R and measurement z
%
%   Output: Predicted states X and predicted covariance matrix P
%
%
%
%
%
%%

function [X,P,S] = KFUpdUnd(Xprev,H, P, R, z)

S = H*P*H'+R; % create inovation variance matrix S
K = P*H'/S; % calculate kalman gain
tmp = [H; zeros(1,2), 1, zeros(1,3)]*Xprev;
if tmp(3) ~= 0
    HXprev = tmp(1:2)/tmp(3);
else
    HXprev = tmp(1:2);
end
v = z - HXprev; % compute innovation
X = Xprev+K*v;  % Perform update on states
P = P - K*S*K'; % Perform update on covariance matrix

end