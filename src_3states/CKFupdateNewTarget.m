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

function [S] = CKFupdateNewTarget(Xpred, Ppred, n)%, H, Z, R, n)
global pose, global k, global angles

Xtmp = zeros(size(Xpred,1),2*n);
Wi = 1/(2*n);

for i = 1:n
    Psqrt = chol(Ppred)';
    Xtmp(:,i) = Xpred+sqrt(n)*Psqrt(:,i);
    Xtmp(:,i+n) = Xpred-sqrt(n)*Psqrt(:,i);
    
    zApprox = pix2coordtest(Xtmp(1:2,i),Xtmp(3,i));
    hX(:,i) = pixel2cameracoords(Xtmp(1:2,i),zApprox);
    
    zApprox = pix2coordtest(Xtmp(1:2,i+n),Xtmp(3,i+n));
    hX(:,i+n) = pixel2cameracoords(Xtmp(1:2,i+n),zApprox);
end

yhatpred = repmat(Wi*sum(hX,2),1,2*n);
Pxy = Wi*(Xtmp-repmat(Xpred,1,2*n))*(hX-yhatpred)';
S = Wi*(hX-yhatpred)*(hX-yhatpred)';
%X = Xpred+Pxy/S*(Z-yhatpred(:,1));

%Ppred = Ppred.*(max(1,dMax-Z(3)));

%P = Ppred-Pxy/S*Pxy';

%v = Z-yhatpred(:,1);
