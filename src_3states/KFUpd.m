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

function [X,P,S] = KFUpd(Xprev,H, P, R, z)

S = H*P*H'+R; % create inovation variance matrix S
K = P*H'/S; % calculate kalman gain
v = z - H*Xprev; % compute innovation
X = Xprev+K*v;  % Perform update on states
P = P - K*S*K'; % Perform update on covariance matrix
P = 0.5*(P+P');
%P = P + 1e-3*eye(size(P));

end