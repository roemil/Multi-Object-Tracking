%%%%% PMBM %%%%%
function [XuUpd, Xpred, Xupd, Xest, Pest, rest, west, labelsEst, newLabel, jEst, normGlobWeights] = ...
    PMBMpredFunc(Z, XuUpdPrev, XupdPrev, Nh, nbrOfBirths, maxKperGlobal, maxNbrGlobal, newLabel, birthSpawn, mode, normGlobWeightsOld, k)
global uniformBirths

load('simVariables')
Wold = 0;
C = [];
nbrOldTargetsPrev = 1e4;
%startPred = tic;

%%%%%%%%%%%%%%%%%%%%%%
%%%%% Prediction %%%%%
%%%%%%%%%%%%%%%%%%%%%%

% Add hypotheses for births
% for i = 1:nbrOfBirths
%     XmuPred(end+1).w = 1/nbrOfBirths;
%     XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
%         unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
%     XmuPred(end).P = covBirth*eye(4);
% end

if ~uniformBirths
    % Poisson prediction
    for i = 1:size(XuUpdPrev,2) % For each single target component i
        [XuPred(i).state, XuPred(i).P] = KFPred(XuUpdPrev(i).state,F, XuUpdPrev(i).P, Q);

        XmuPred(i).w = XuUpdPrev(i).w;    % Pred weight
        XmuPred(i).state = XuPred(i).state;      % Pred state
        XmuPred(i).P = XuPred(i).P;      % Pred cov    

        % MIGHT HAVE MIXED UP PREDICTION STEPS
    end

    XmuPred = generateBirthHypo(XmuPred, motionModel, nbrPosStates, mode, k);

    % Update the poisson components
    XuUpdTmp = updatePoisson(XmuPred,Pd);
end
% Disp
%size(XuUpdTmp,2)
% Predict states for old potential targets
Xpred = predictDetectedBernoulli(XupdPrev, F, Q, Ps);

%timePred = toc(startPred);
%startUpd = tic;

%disp(['Error: ', num2str(5)])
% Find global hypotheses weights and weight sum for normalization
%Xtmp = Xpred;
Xtmp = generateTargetHypov3(Xpred, 0, size(Xpred,2), Pd, H, R, Z, motionModel, nbrPosStates, nbrMeasStates);
wSum = cell(size(Xtmp,2),1);
for j = 1:size(Xtmp,2)
    wSum{j} = 0;
    wGlob(j) = 0;
    iInd = 1;
    if ~isempty(Xtmp{j})
        for i = 1:size(Xtmp{j},2)
            if ~isempty(Xtmp{j}(i).w)
                wGlob(j) = wGlob(j)+Xtmp{j}(i).w;
                if Xtmp{j}(i).r > threshold
                    wSum{j}(iInd) = Xtmp{j}(i).w;
                    iInd = iInd + 1;
                end
            end
        end
    end
end

%timeUpd = toc(startUpd);

%disp(['Error: ', num2str(6)])
% Estimate states using Estimator 1
[Xest, Pest, rest, west, labelsEst, jEst] = est1(Xtmp, thresholdEst, motionModel);
%disp(['Error: ', num2str(7)])
% Keep the Nh best global hypotheses

% Test
% [~,ind,~] = unique(wGlob);
% compVec = (1:size(wGlob,2))';
% indVec = find(ismember(compVec,ind) == 0);
% diffVec = 0;
% for j = 1:size(wSum,1)
%     if size(wSum{j},2) > 1
%         diffj = sum(diff(wSum{j}));
%         if abs(diffj-diffVec) > 1e-3
%             indVec = [indVec, j];
%             diffVec = [diffVec;diffj];
%         end
%     end
% end
% if ~isempty(indVec)
%     indEqual = find(ismember(compVec,indVec) == 0);
%     wGlob(indEqual) = wGlob(indEqual)-1e6;
% end

compVec = (1:size(wGlob,2))';
% added test
ww = zeros(size(wSum,1),1);
for j = 1:size(wSum,1)
    if size(wSum{j},2) ~= 1
        ww(j) = sum(normalizeLogWeights(wSum{j})); %
    else
        ww(j) = wSum{j};
    end
end
[~,tmp,~] = unique(ww);
indEqual = find(ismember(compVec,tmp) == 0);
wGlob(indEqual) = wGlob(indEqual)-1e6;
%added test
% [~,ind,~] = unique(wGlob); %round(wGlob,3)
% indEqual = find(ismember(compVec,ind) == 0);
% wGlob(indEqual) = wGlob(indEqual)-1e6;

minTmp = min(size(wGlob,2), Nh);

[keepGlobs,C] = murty(-wGlob,min(maxNbrGlobal,minTmp));
%disp('Error: Murty')
%ind = find(diff(C) > 100);
%if ~isempty(ind)
%    keepGlobs = keepGlobs(1:ind(1));
%end
%disp(['Error: ', num2str(8)])
% Remove bernoulli components with low probability of existence
Xupd = cell(1,1);
jInd = 1;
if sum(keepGlobs ~= 0) ~= 0
    keepGlobs = keepGlobs(keepGlobs ~= 0);
    %disp(['Nbr of new globals: ', num2str(size(keepGlobs,1))])
    for j = 1:size(keepGlobs,1)
        if ~isempty(wSum{keepGlobs(j)})
            if jEst == keepGlobs(j)
                jEst = jInd;
            end
            globWeight(jInd) = 0;
            iInd = 1;
            if size(wSum{keepGlobs(j)},2) == 1
                weights = wSum{keepGlobs(j)}(1);
            else
                [weights, ~] = normalizeLogWeights(wSum{keepGlobs(j)});
            end
            %Xupd{k,j} = removeLowProbExistence(Xtmp{k,keepGlobs(j)},keepGlobs(j),threshold,wSum);
            for i = 1:size(Xtmp{keepGlobs(j)},2)
                if Xtmp{keepGlobs(j)}(i).r > threshold
                    Xupd{jInd}(iInd) = Xtmp{keepGlobs(j)}(i);
                    Xupd{jInd}(iInd).w = weights(iInd);
                    globWeight(jInd) = globWeight(jInd)+weights(iInd);
                    iInd = iInd+1;
                end
            end
            jInd = jInd+1;
        end
    end
else % TODO: Do we wanna do this?!
    disp('keepGlobs is 0')
    for j = 1:size(Xtmp,2)
        if ~isempty(wSum{j})
            if j == jEst
                jEst = jInd;
            end
            globWeight(jInd) = 0;
            iInd = 1;
            if size(wSum{j},2) == 1
                weights = wSum{j}(1);
            else
                [weights, ~] = normalizeLogWeights(wSum{j});
            end
            %Xupd{k,j} = removeLowProbExistence(Xtmp{k,keepGlobs(j)},keepGlobs(j),threshold,wSum);
            for i = 1:size(Xtmp{j},2)
                if Xtmp{j}(i).r > threshold
                    Xupd{j}(iInd) = Xtmp{j}(i);
                    Xupd{j}(iInd).w = weights(iInd);
                    globWeight(jInd) = globWeight(jInd)+weights(iInd);
                    iInd = iInd+1;
                end
            end
            jInd = jInd+1;
        end
    end
end

if size(Xupd{1},2) ~= 0
    normGlobWeights = normalizeLogWeights(globWeight);
else
    normGlobWeights = [];
end

for j = 1:size(globWeight,2)
    if size(Xupd{j},2) == 1
        Xupd{j}(1).w = normGlobWeights(j);
    end
end

%disp(['Error: ', num2str(9)])
% Prune poisson components with low weight
if ~uniformBirths
    ind = 1;
    for i = 1:size(XuUpdTmp,2)
        if XuUpdTmp(i).w > poissThresh
            XuUpd(ind) = XuUpdTmp(i);
            ind = ind+1;
        end
    end
else
    XuUpd = [];
end

% DISP
%size(XuUpd,2)

%disp(['Find A time: ', num2str(sum(timeA)), 's'])
%disp(['Murty time: ', num2str(sum(murtTime)), 's'])
%disp(['Glob time: ', num2str(sum(globTime)), 's'])
%disp(['Pred time: ', num2str(timePred), 's'])
%disp(['Upd time: ', num2str(timeUpd), 's'])
%disp(['Nbr global hypo pre murty: ', num2str(size(wGlob,2))])
%disp(['Nbr global hypo: ', num2str(size(Xupd,2))])