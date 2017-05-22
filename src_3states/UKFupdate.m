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

function [X,P,S,v] = UKFupdate(Xpred, Ppred, H, Z, R, n)
global pose, global k, global angles

if isa(R,'function_handle')
    R = R(Z(3));
end

Xtmp = zeros(size(Xpred,1),2*n);

W0 = 1/(2*n+1);
Wi = (1-W0)/(2*n);

%dMax = 10;
%Ppred = Ppred./(max(1,dMax-Z(3)));

Psqrt = chol(Ppred)';
for i = 1:n
    Xtmp(:,i) = Xpred+sqrt(n/(1-W0))*Psqrt(:,i);
    Xtmp(:,i+n) = Xpred-sqrt(n/(1-W0))*Psqrt(:,i);
end
Xtmp = [Xpred, Xtmp];
% Only yaw
hX = H(Xtmp,pose{k}(1:3,4), angles{k}.heading-angles{1}.heading);
% Full rotation matrix
%hX = H(Xtmp,pose{k}(1:3,4), angles,k);

yhatpred = repmat(W0*hX(:,1)+Wi*sum(hX(:,2:end),2),1,2*n+1);
Pxy = Wi*(Xtmp-repmat(Xpred,1,2*n+1))*(hX-yhatpred)';
S = Wi*(hX-yhatpred)*(hX-yhatpred)'+R;
X = Xpred+Pxy/S*(Z-yhatpred(:,1));

%Ppred = Ppred.*(max(1,dMax-Z(3)));

P = Ppred-Pxy/S*Pxy';

v = Z-yhatpred(:,1);
