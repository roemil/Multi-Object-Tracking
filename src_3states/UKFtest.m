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
end
Xtmp = [Xpred, Xtmp];
% Only yaw
hX = H(Xtmp,pose{k}(1:3,4), angles{k}.heading-angles{1}.heading);

global H3dTo2d, global nbrMeasStates, global R3dTo2d
R = [R, zeros(3,2);zeros(2,3), R3dTo2d(nbrMeasStates+1:end,nbrMeasStates+1:end)];
hX = [hX; H3dTo2d(nbrMeasStates+1:end,1:end-1)*Xtmp];
% Full rotation matrix
%hX = H(Xtmp,pose{k}(1:3,4), angles,k);

yhatpred = repmat(W0*hX(:,1)+Wi*sum(hX(:,2:end),2),1,2*n+1);
Pxy = W0*(Xtmp(:,1)-Xpred)*(hX(:,1)-yhatpred(:,1))'+Wi*(Xtmp(:,2:end)-repmat(Xpred,1,2*n))*(hX(:,2:end)-yhatpred(:,2:end))';
S = W0*(hX(:,1)-yhatpred(:,1))*(hX(:,1)-yhatpred(:,1))' + Wi*(hX(:,2:end)-yhatpred(:,2:end))*(hX(:,2:end)-yhatpred(:,2:end))'+R;
X = Xpred+Pxy/S*(Z-yhatpred(:,1));

%Ppred = Ppred.*(max(1,dMax-Z(3)));

P = Ppred-Pxy/S*Pxy';
P = 0.5*(P+P');
%P = P+1e-3*eye(size(P));

v = Z-yhatpred(:,1);
v = v(1:3);

