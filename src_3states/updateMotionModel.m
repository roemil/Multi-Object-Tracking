function Qnew = updateMotionModel(XupdPrev)
global sigmaQ, global T, global motionModel, global nbrPosStates, global sigmaBB

% Test tighten Q
limQ = 0.7; % 0.8
indSt = 2;
indLim = 10;
fact = max(limQ,min(1 - limQ/indLim*(XupdPrev.nbrMeasAss-indSt),1));
[~, Qnew] = generateMotionModel(fact*sigmaQ, T, motionModel, nbrPosStates, sigmaBB);


% This works! However quite large confidence intervall
% limQ = 0.8; % 0.8
% ind = 2;
% fact = max(limQ,min((1+limQ) - limQ/ind*XupdPrev.nbrMeasAss,1));
% [~, Qnew] = generateMotionModel(fact*sigmaQ, T, motionModel, nbrPosStates, sigmaBB);