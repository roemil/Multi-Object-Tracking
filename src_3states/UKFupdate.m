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

% Plot conf
% if k == 60
%     seq = '0003';
%     frameNbr = sprintf('%06d',k-1);
%     imagePath = strcat('../../kittiTracking/','training','/image_02/',seq,'/',frameNbr,'.png');
%     img = imread(imagePath);
%     figure;
%     imagesc(img);
%     axis('image')
%     hold on
%     plot(hX(1,:),hX(2,:),'r*')
%     plot(yhatpred(1),yhatpred(2),'r+','linewidth',1)
%     plot(Z(1),Z(2),'g+','linewidth',1)
%     phi = linspace(0,2*pi,100);
%     x = repmat(yhatpred(1:2,1),1,100)+3*sqrtm(S(1:2,1:2))*[cos(phi);sin(phi)];
%     plot(x(1,:),x(2,:),'-y','LineWidth',1)
%     waitforbuttonpress
% end