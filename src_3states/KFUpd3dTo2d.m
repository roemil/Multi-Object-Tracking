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

function [X,P,S] = KFUpd3dTo2d(Xprev,H, Pprev, R, z)

nbrMeas = size(z,1);

S = H(1:nbrMeas,:)*Pprev*H(1:nbrMeas,:)'+R; % create inovation variance matrix S
K = Pprev*H(1:nbrMeas,:)'/S; % calculate kalman gain
St = H(1:3,:)*Pprev*H(1:3,:)'+[R, zeros(2,1); zeros(1,3)];
Kt = Pprev*H(1:3,:)'/St;
zt = [z;1];
tmp = H*Xprev;
if tmp(3) ~= 0
    HXprev = tmp(1:2)/tmp(3);
    HXprevt = tmp(1:3)/tmp(3);
else
    HXprev = tmp(1:2);
end
v = z - HXprev; % compute innovation
vt = zt-HXprevt;
X = Xprev+K*v;  % Perform update on states
Xt = Xprev+tmp(3)*Kt*vt;
%[distanceToMeas(Xprev,z,'0000','training',1), distanceToMeas(X,z,'0000','training',1), distanceToMeas(Xt,z,'0000','training',1)]
Pt = Pprev - Kt*St*Kt';
P = Pprev - K*S*K'; % Perform update on covariance matrix
%P
%Pt
end