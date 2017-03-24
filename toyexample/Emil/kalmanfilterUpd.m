function [X,P] = kalmanfilterUpd(Xprev,P,T,H,R,z)

S = H*P*H'+R;
K = P*H'*inv(S);
v = z - H*Xprev;
X = Xprev+K*v;
P = P - K*S*K';

end