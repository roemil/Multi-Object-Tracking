%%%%% PMBM %%%%%
function [XuUpd, Xupd, Xest, Pest, rest, west, labelsEst, newLabel, jEst] = ...
    PMBMinitFunc(Z, XmuInit, XuInit, nbrOfBirths, maxKperGlobal, maxNbrGlobal, newLabel,birthSpawn,mode)
global uniformBirths
load('simVariables')
Wold = 0;
C = [];
nbrOldTargetsPrev = 1e4;

% Init undetected targets
XuUpdTmp = [XuInit, XmuInit];

if ~uniformBirths
    XmuPred = generateBirthHypo(XuUpdTmp,  motionModel, nbrPosStates, mode, 1);
    XuUpdTmp = updatePoisson(XmuPred,Pd);
else
    %XmuPred = generateUniformBirthHypo(Z, mode);
    XmuPred = generateUniformBirthHypov2(Z, mode);
    %XmuPred = []; if updPotNewv2
end

%%%%%%%%%%%%%%%%%%
%%%%% Update %%%%%
%%%%%%%%%%%%%%%%%%

% Update for potential targets detected for the first time
nbrOfMeas = size(Z,2);
nbrOfGlobHyp = 0;

% Find newly detected potential targets
if ~uniformBirths
    [XpotNew, rho, newLabel] = updateNewPotTargets(XmuPred, nbrOfMeas,...
        Z, newLabel, motionModel, nbrPosStates);
else
    [XpotNew, rho, newLabel] = updateNewPotTargetsUniform(XmuPred, nbrOfMeas,...
        Z, newLabel, motionModel, nbrPosStates);
end
 
m = size(Z,2);

nbrOldTargets = 0;
Amat = 1:m;
S(:,:,1) = eye(m);

% Find global hypotheses weights and weight sum for normalization
wGlob = zeros(1,size(XpotNew,2));
for i = 1:size(XpotNew,2)
    Xtmp{1}(i) = XpotNew{i};
    if Xtmp{1}(i).r > threshold
        wGlob(i) = Xtmp{1}(i).w;
    end
end

% Estimate states using Estimator 1
[Xest, Pest, rest, west, labelsEst, jEst] = est1(Xtmp, thresholdEst, motionModel);

% Remove bernoulli components with low probability of existence
iInd = 1;
[norm_weights, ~] = normalizeLogWeights(wGlob);
for i = 1:size(Xtmp{1},2)
    if Xtmp{1}(i).r > threshold
        Xupd{1}(iInd) = Xtmp{1}(i);
        %if nbrPosStates == 4 && strcmp(motionModel,'cvBB')
        %    Xupd{1}(iInd).P = 3*Xupd{1}(iInd).P+diag([30 10 0 0 0 0]);
        %end
        Xupd{1}(iInd).w = norm_weights(iInd);
        iInd = iInd+1;
    end
end

%if nbrPosStates == 4 && strcmp(motionModel,'cvBB')
%    for i = 1:size(Pest,2)
%        Pest{i} = 3*Pest{i}+diag([30 10 0 0 0 0]);
%    end
%end
if ~uniformBirths
    XuUpd = XuUpdTmp;
else
    XuUpd = [];
end
% Prune poisson components with low weight
%ind = 1;
%for i = 1:size(XuUpdTmp,2)
    %if XuUpdTmp(i).w > poissThresh
        %XuUpd(ind) = XuUpdTmp(i);
        %ind = ind+1;
    %end
%end
