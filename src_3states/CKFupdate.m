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

function [X,P,S] = CKFupdate(Xpred, Ppred, H, Z, R, n)

X = zeros(size(Xpred,1),2*n);
Wi = 1/(2*n);

for i = 1:n
    Psqrt = chol(Ppred)';
    X(:,i) = Xpred+sqrt(n)*Psqrt(:,i);
    X(:,i+n) = Xpred-sqrt(n)*Psqrt(:,i);
end
hX = H(X);
yhatpred = repmat(Wi*sum(hX,2),1,2*n);
Pxy = Wi*(X-repmat(Xpred,1,2*n))*(hX-yhatpred)';
S = Wi*(hX-yhatpred)*(hX-yhatpred)'+R;
X = Xpred+Pxy/S*(Z-yhatpred(:,1));
P = Ppred-Pxy/S*Pxy';
