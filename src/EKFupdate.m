%   Perform update with linear KF and Gaussian models
%   
%   Input:      Xpred:  Predicted states
%               Ppred:  Covariance matri of predicted states
%               H:      Measurement model
%               Jh:     Jacobian matrix
%               Z:      Measurements
%               R:      Measurement covariance
% 
%   Output:     X:      Estimated states
%               P:      Covariance matrix of estimated states
%
%
%
%
%%

function [X,P] = EKFupdate(Xpred, Ppred, H, Jh, Z, R)

S = Jh(Xpred)*Ppred*Jh(Xpred).'+eye(2)*R; % Create innovation covariance matrix S
K = Ppred*Jh(Xpred).'/(S); % Calculate kalman gain
X = Xpred+K*(Z-H(Xpred));  % Perform update on states
P = Ppred-K*S*K.'; % Perform update on covariance matrix

end