function [F, Q] = updateMotionModel(F, Q, XupdPrev)

% % Adjust velo
% limFv = 1;
% modifyFv = 2-XupdPrev.nbrMeasAss*(2-limFv)/6;
% 
% F(3,3) = max(modifyFv, limFv)*F(3,3);
% F(4,4) = max(modifyFv, limFv)*F(4,4);

% Update motion more according to velo
limFp = 1;
modifyFp = 2-XupdPrev.nbrMeasAss*(2-limFp)/6;

F(1,3) = max(2*modifyFp, limFp)*F(1,3);
F(1,4) = max(2*modifyFp, limFp)*F(1,4);

limQ = 0.9;
ind = 3;

if XupdPrev.nbrMeasAss > ind
    modifyQ = 1 - (XupdPrev.nbrMeasAss-ind)*(1-limQ)/6;

    Q(1:2,1:2) = max(modifyQ,limQ) * Q(1:2,1:2);
end