%   Perform prediction with linear KF and Gaussian models
%   
%   Input: Previous states Xprev, motion model F, motion variance matrix P,
%          Q is process noice
%
%   Output: Predicted states X and predicted covariance matrix P
%
%
%
%
%
%%


function [X,P] = kalmanfilterPred(Xprev,F, P, Q)

X = F*Xprev; % Perform prediction of states
P = F*P*F'+Q; % Perform prediction of variance


end
