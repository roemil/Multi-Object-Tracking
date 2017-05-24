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

function [X,P,S,v] = CKFupdate(Xpred, Ppred, H, Z, R, n)
global pose, global k, global angles

if isa(R,'function_handle')
    R = R(Z(3));
end

Xtmp = zeros(size(Xpred,1),2*n);
Wi = 1/(2*n);

%dMax = 10;
%Ppred = Ppred./(max(1,dMax-Z(3)));

Psqrt = chol(Ppred)';
for i = 1:n
    Xtmp(:,i) = Xpred+sqrt(n)*Psqrt(:,i);
    Xtmp(:,i+n) = Xpred-sqrt(n)*Psqrt(:,i);
end
% Only yaw
hX = H(Xtmp,pose{k}(1:3,4), angles{k}.heading-angles{1}.heading);
% Full rotation matrix
%hX = H(Xtmp,pose{k}(1:3,4), angles,k);

% % TEST!! Limit the values to FOVsize
% global FOVsize
% for i = 1:size(hX,2)
%     if hX(1,i) < 0
%         hX(1,i) = 0;
%     elseif hX(1,i) > FOVsize(2,1)
%         hX(1,i) = FOVsize(2,1);
%     end
%     if hX(2,i) < 0
%         hX(2,i) = 0;
%     elseif hX(2,i) > FOVsize(2,2)
%         hX(2,i) = FOVsize(2,2);
%     end
% end

yhatpred = repmat(Wi*sum(hX,2),1,2*n);
Pxy = Wi*(Xtmp-repmat(Xpred,1,2*n))*(hX-yhatpred)';
S = Wi*(hX-yhatpred)*(hX-yhatpred)'+R;
X = Xpred+Pxy/S*(Z-yhatpred(:,1));

%Ppred = Ppred.*(max(1,dMax-Z(3)));

P = Ppred-Pxy/S*Pxy';

v = Z-yhatpred(:,1);
