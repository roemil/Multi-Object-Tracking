function Qnew = updateMotionModel(XupdPrev)
global sigmaQ, global T, global motionModel, global nbrPosStates, global sigmaBB

limQ = 0.8;
ind = 2;
fact = max(limQ,min((1+limQ) - limQ/ind*XupdPrev.nbrMeasAss,1));
[~, Qnew] = generateMotionModel(fact*sigmaQ, T, motionModel, nbrPosStates, sigmaBB);