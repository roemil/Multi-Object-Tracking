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

function [S, X3D] = UKFupdateNewTarget(Xpred, Ppred, n)%H, Z, R, n)
global pose, global k, global angles


% global FOVsize
% theta = pi/2 / FOVsize(2,1)*(Z(1)-FOVsize(2,1)/2);
% angleThresh = 30*pi/180; % TODO: Move to declareVariables
% distThresh = 10; % TODO: Move to declareVariables
% if abs(theta) > angleThresh && Z(3) < distThresh
%     R(3,3) = 2*R(3,3);
% end

Xtmp = zeros(size(Xpred,1),2*n);

W0 = 1-n/3;%1/(2*n+1);
Wi = (1-W0)/(2*n);

%dMax = 10;
%Ppred = Ppred./(max(1,dMax-Z(3)));

Psqrt = chol(Ppred)';
for i = 1:n
    Xtmp(:,i) = Xpred+sqrt(n/(1-W0))*Psqrt(:,i);
    Xtmp(:,i+n) = Xpred-sqrt(n/(1-W0))*Psqrt(:,i);
    
    zApprox = pix2coordtest(Xtmp(1:2,i),Xtmp(3,i));
    hX(:,i) = pixel2cameracoords(Xtmp(1:2,i),zApprox);
    
    zApprox = pix2coordtest(Xtmp(1:2,i+n),Xtmp(3,i+n));
    hX(:,i+n) = pixel2cameracoords(Xtmp(1:2,i+n),zApprox);
end

Xtmp = [Xpred, Xtmp];
zApprox = pix2coordtest(Xpred(1:2),Xpred(3));
hX = [pixel2cameracoords(Xpred(1:2),zApprox), hX];
% Only yaw
global T02, global TcamToVelo, global TveloToImu
hX = TveloToImu(1:3,:)*TcamToVelo*T02*[hX; ones(1,size(hX,2))];

yhatpred = repmat(W0*hX(:,1)+Wi*sum(hX(:,2:end),2),1,2*n+1);
Pxy = W0*(Xtmp(:,1)-Xpred)*(hX(:,1)-yhatpred(:,1))'+Wi*(Xtmp(:,2:end)-repmat(Xpred,1,2*n))*(hX(:,2:end)-yhatpred(:,2:end))';
S = W0*(hX(:,1)-yhatpred(:,1))*(hX(:,1)-yhatpred(:,1))' + Wi*(hX(:,2:end)-yhatpred(:,2:end))*(hX(:,2:end)-yhatpred(:,2:end))';

X3D = mean(hX,2);

%X = Xpred+Pxy/S*(Z-yhatpred(:,1));

%Ppred = Ppred.*(max(1,dMax-Z(3)));

%P = Ppred-Pxy/S*Pxy';
%P = 0.5*(P+P');
%P = P+1e-3*eye(size(P));

%v = Z-yhatpred(:,1);

