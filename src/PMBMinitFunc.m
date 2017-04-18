%%%%% PMBM %%%%%
function [XuUpd, Xupd, Xest, Pest, rest, west] = PMBMinitFunc(Z, XmuInit, XuInit, Nh, nbrOfBirths, maxKperGlobal, maxNbrGlobal)

load('simVariables')
Wold = 0;
C = [];
nbrOldTargetsPrev = 1e4;

% Init undetected targets
XuUpdTmp = [XuInit, XmuInit];

%%%%%%%%%%%%%%%%%%
%%%%% Update %%%%%
%%%%%%%%%%%%%%%%%%

% Update for potential targets detected for the first time
nbrOfMeas = size(Z,2);
nbrOfGlobHyp = 0;

% Find newly detected potential targets
[XpotNew, rho] = updateNewPotTargets(XuUpdTmp, nbrOfMeas, Pd, H, R, Z, c);
 
m = size(Z,2);

nbrOldTargets = 0;
Amat = 1:m;
S(:,:,1) = eye(m);

% Find global hypotheses weights and weight sum for normalization
wSum = 0;
wGlob = 1;
for i = 1:size(XpotNew,2)
    Xtmp{1}(i) = XpotNew{i};
    wGlob = wGlob*Xtmp{1}(i).w;
    if Xtmp{1}(i).r > threshold
        wSum = wSum + Xtmp{1}(i).w;
    end
end

% Estimate states using Estimator 1
[Xest, Pest, rest, west] = est1(Xtmp, thresholdEst);

% Remove bernoulli components with low probability of existence
iInd = 1;
for i = 1:size(Xtmp{1},2)
    if Xtmp{1}(i).r > threshold
        Xupd{1}(iInd) = Xtmp{1}(i);
        Xupd{1}(iInd).w = Xtmp{1}(i).w/wSum;
        iInd = iInd+1;
    end
end

% Prune poisson components with low weight
ind = 1;
for i = 1:size(XuUpdTmp,2)
    %if XuUpdTmp(i).w > poissThresh
        XuUpd(ind) = XuUpdTmp(i);
        ind = ind+1;
    %end
end
keyboard