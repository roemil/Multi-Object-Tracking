%%%%% PMBM %%%%%
function [XuUpd, Xpred, Xupd, Xest, Pest, rest, west, labelsEst, newLabel, jEst] = PMBMfunc(Z, XuUpdPrev, XupdPrev, Nh, nbrOfBirths, maxKperGlobal, maxNbrGlobal, newLabel, k)

load('simVariables')
Wold = 0;
C = [];
nbrOldTargetsPrev = 1e4;
startPred = tic;

%%%%%%%%%%%%%%%%%%%%%%
%%%%% Prediction %%%%%
%%%%%%%%%%%%%%%%%%%%%%

% Poisson prediction
for i = 1:size(XuUpdPrev,2) % For each single target component i
    [XuPred(i).state, XuPred(i).P] = KFPred(XuUpdPrev(i).state,F, XuUpdPrev(i).P, Q);

    XmuPred(i).w = XuUpdPrev(i).w;    % Pred weight
    XmuPred(i).state = XuPred(i).state;      % Pred state
    XmuPred(i).P = XuPred(i).P;      % Pred cov    

    % MIGHT HAVE MIXED UP PREDICTION STEPS
end

% Add hypotheses for births
% for i = 1:nbrOfBirths
%     XmuPred(end+1).w = 1/nbrOfBirths;
%     XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
%         unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
%     XmuPred(end).P = covBirth*eye(4);
% end

XmuPred = generateBirthHypo(XmuPred, nbrOfBirths, FOVsize, boarder, pctWithinBoarder,...
    covBirth, vinit, weightBirth);

% Update the poisson components
XuUpdTmp = updatePoisson(XmuPred,Pd);
% Disp
%size(XuUpdTmp,2)
% Predict states for old potential targets
Xpred = predictDetectedBernoulli(XupdPrev, F, Q, Ps);

timePred = toc(startPred);
startUpd = tic;

%%%%%%%%%%%%%%%%%%
%%%%% Update %%%%%
%%%%%%%%%%%%%%%%%%

% Update for potential targets detected for the first time
nbrOfMeas = size(Z,2);
if ~isempty(Xpred)
    nbrOfGlobHyp = size(Xpred,2);
else
    nbrOfGlobHyp = 0;
end

disp(['Nbr of old globals: ', num2str(nbrOfGlobHyp)])

% Find newly detected potential targets
[XpotNew, rho, newLabel] = updateNewPotTargets(XmuPred, nbrOfMeas, Pd, H, R, Z, c, newLabel);

%%%% Update for previously potentially detected targets %%%%
Xhypo = generateTargetHypo(Xpred, nbrOfMeas, nbrOfGlobHyp, Pd, H, R, Z);    

oldInd = 0;
m = size(Z,2);
Wnew = diag(rho);
nbrTargetInd = 1;
nbrVec = 0;
for j = 1:max(1,nbrOfGlobHyp)
    clear Amat; clear S;
    %disp(['Error: ', num2str(1)])
    findA(j) = tic;
    if ~isempty(Xhypo{j})
        nbrOldTargets = size(Xhypo{j,1},2);
        if sum(nbrOldTargets == nbrVec) > 0
           tInd = find(nbrOldTargets == nbrVec);
           Amat = Atot{tInd};
           for i = 1:size(Stot,2)
               if isempty(Stot{tInd,i})
                   break
               end
               S(:,:,i) = Stot{tInd,i};
           end
        else
           [S, Amat] = generateGlobalIndv2(m, nbrOldTargets); %TODO: THIS IS CURRENTLY THE BEST ONE
           Atot{nbrTargetInd} = Amat;
           for i = 1:size(S,3)
               Stot{nbrTargetInd,i} = S(:,:,i);
           end
           nbrVec(nbrTargetInd) = nbrOldTargets;
           nbrTargetInd = nbrTargetInd+1;
        end
    else
        nbrOldTargets = 0;
        Amat = 1:m;
        S = zeros(m,m,1);
        S(:,:,1) = eye(m);
    end
    %disp(['Error: ', num2str(2)])
    % Display nbr old targets and measurements 
    %disp(['Nbr of old targets: ', num2str(nbrOldTargets)])
    %disp(['Nbr measurements: ', num2str(m)])
    
    timeA(j) = toc(findA(j));
    %%%%% MURTY %%%%%%
    startMurt(j) = tic;
    ass = KbestGlobal(nbrOfMeas, Xhypo, Z, Xpred, Wnew, Nh, S, Pd, H, j, maxKperGlobal);
    murtTime(j) = toc(startMurt(j));
    %%%%% Find new global hypotheses %%%%%
    startGlob(j) = tic;
    %disp(['Error: ', num2str(3)])
    [newGlob, newInd] = generateGlobalHypo5(Xhypo(j,:), XpotNew(:), Z, oldInd, Amat, ass, nbrOldTargets);
    globTime(j) = toc(startGlob(j));
    %disp(['Error: ', num2str(4)])
    for jnew = oldInd+1:newInd
        Xtmp{jnew} = newGlob{jnew-oldInd};
    end
    oldInd = newInd;
end
%disp(['Error: ', num2str(5)])
% Find global hypotheses weights and weight sum for normalization
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

timeUpd = toc(startUpd);
%disp(['Error: ', num2str(6)])
% Estimate states using Estimator 1
[Xest, Pest, rest, west, labelsEst, jEst] = est1(Xtmp, thresholdEst);
%disp(['Error: ', num2str(7)])
% Keep the Nh best global hypotheses

minTmp = min(size(wGlob,2), Nh);

[keepGlobs,C] = murty(-wGlob,min(maxNbrGlobal,minTmp));
%disp('Error: Murty')
ind = find(diff(C) > 50);
if ~isempty(ind)
    keepGlobs = keepGlobs(1:ind(1));
end
%disp(['Error: ', num2str(8)])
% Remove bernoulli components with low probability of existence
if keepGlobs ~= 0
    disp(['Nbr of new globals: ', num2str(size(keepGlobs,1))])
    for j = 1:size(keepGlobs,1)
        if j == keepGlobs(j)
            jEst = j;
        end
        iInd = 1;
        [weights, ~] = normalizeLogWeights(wSum{keepGlobs(j)});
        %Xupd{k,j} = removeLowProbExistence(Xtmp{k,keepGlobs(j)},keepGlobs(j),threshold,wSum);
        for i = 1:size(Xtmp{keepGlobs(j)},2)
            if Xtmp{keepGlobs(j)}(i).r > threshold
                Xupd{j}(iInd) = Xtmp{keepGlobs(j)}(i);
                Xupd{j}(iInd).w = weights(iInd);

                if isnan(Xupd{j}(iInd).w)
                    keyboard
                end
                iInd = iInd+1;
            end
        end
    end
else % TODO: Do we wanna do this?!
    disp('keepGlobs is 0')
    for j = 1:size(Xtmp,2)
        iInd = 1;
        [weights, ~] = normalizeLogWeights(wSum{j});
        %Xupd{k,j} = removeLowProbExistence(Xtmp{k,keepGlobs(j)},keepGlobs(j),threshold,wSum);
        for i = 1:size(Xtmp{j},2)
            if Xtmp{j}(i).r > threshold
                Xupd{j}(iInd) = Xtmp{j}(i);
                Xupd{j}(iInd).w = weights(iInd);
                iInd = iInd+1;
            end
        end
    end
end
Xupd = Xupd(~cellfun(@isempty,Xupd));  
%disp(['Error: ', num2str(9)])
% Prune poisson components with low weight
ind = 1;
for i = 1:size(XuUpdTmp,2)
    if XuUpdTmp(i).w > poissThresh
        XuUpd(ind) = XuUpdTmp(i);
        ind = ind+1;
    end
end

% DISP
size(XuUpd,2)

disp(['Find A time: ', num2str(sum(timeA)), 's'])
%disp(['Murty time: ', num2str(sum(murtTime)), 's'])
%disp(['Glob time: ', num2str(sum(globTime)), 's'])
%disp(['Pred time: ', num2str(timePred), 's'])
%disp(['Upd time: ', num2str(timeUpd), 's'])
%disp(['Nbr global hypo pre murty: ', num2str(size(wGlob,2))])
%disp(['Nbr global hypo: ', num2str(size(Xupd,2))])