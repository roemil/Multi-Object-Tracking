%%%%% PMBM %%%%%
function [XuUpd, Xpred, Xupd, Xest, Pest, rest, west] = PMBMfunc(Z, XuUpdPrev, XupdPrev, Nh, nbrOfBirths, maxKperGlobal, maxNbrGlobal,k)

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
for i = 1:nbrOfBirths
    XmuPred(end+1).w = 0.5;%/nbrOfBirths;
    XmuPred(end).state = [unifrnd(-FOVsize(1,1), FOVsize(2,1)), ...
        unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
    XmuPred(end).P = covBirth*eye(4);
end

% Update the poisson components
XuUpdTmp = updatePoisson(XmuPred,Pd);

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

% Find newly detected potential targets
[XpotNew, rho] = updateNewPotTargets(XmuPred, nbrOfMeas, Pd, H, R, Z, c);

%%%% Update for previously potentially detected targets %%%%
Xhypo = generateTargetHypo(Xpred, nbrOfMeas, nbrOfGlobHyp, Pd, H, R, Z);    

oldInd = 0;
m = size(Z,2);
Wnew = diag(rho);
nbrTargetInd = 1;
nbrVec = 0;
for j = 1:max(1,nbrOfGlobHyp)
    clear Amat; clear S;
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
           [S, Amat] = generateGlobalIndTest(m, nbrOldTargets); %TODO: THIS IS CURRENTLY THE BEST ONE
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
    
    timeA(j) = toc(findA(j));
    %%%%% MURTY %%%%%%
    startMurt(j) = tic;
    ass = KbestGlobal(nbrOfMeas, Xhypo, Z, Xpred, Wnew, Nh, S, Pd, H, j, maxKperGlobal);
    murtTime(j) = toc(startMurt(j));
    %%%%% Find new global hypotheses %%%%%
    startGlob(j) = tic;
    [newGlob, newInd] = generateGlobalHypo5(Xhypo(j,:), XpotNew(:), Z, oldInd, Amat, ass, nbrOldTargets);
    globTime(j) = toc(startGlob(j));
    
    for jnew = oldInd+1:newInd
        Xtmp{jnew} = newGlob{jnew-oldInd};
    end
    oldInd = newInd;
end

% Find global hypotheses weights and weight sum for normalization
for j = 1:size(Xtmp,2)
    wSum(j) = 0;
    wGlob(j) = 1;
    if ~isempty(Xtmp{j})
        for i = 1:size(Xtmp{j},2)
            if ~isempty(Xtmp{j}(i).w)
                wGlob(j) = wGlob(j)*Xtmp{j}(i).w;
                if Xtmp{j}(i).r > threshold
                    wSum(j) = wSum(j) + Xtmp{j}(i).w;
                end
            end
        end
    end
end
timeUpd = toc(startUpd);

% Estimate states using Estimator 1
[Xest, Pest, rest, west] = est1(Xtmp, thresholdEst);

% Keep the Nh best global hypotheses

minTmp = min(size(wGlob,2), Nh);
weights = 1./wGlob;
weights = weights/max(weights);
[keepGlobs,C] = murty(weights,min(maxNbrGlobal,minTmp));

ind = find(diff(C) > 0.3);
if ~isempty(ind)
    keepGlobs = keepGlobs(1:ind(1));
end

% Remove bernoulli components with low probability of existence
for j = 1:size(keepGlobs,1)
    iInd = 1;
    %Xupd{k,j} = removeLowProbExistence(Xtmp{k,keepGlobs(j)},keepGlobs(j),threshold,wSum);
    if(isempty(keepGlobs) || isempty({Xtmp}))
        keyboard
    end
    for i = 1:size(Xtmp{keepGlobs(j)},2)
        if Xtmp{keepGlobs(j)}(i).r > threshold
            Xupd{j}(iInd) = Xtmp{keepGlobs(j)}(i);
            Xupd{j}(iInd).w = Xtmp{keepGlobs(j)}(i).w/wSum(keepGlobs(j));
            iInd = iInd+1;
        end
    end
end

% Prune poisson components with low weight
ind = 1;
for i = 1:size(XuUpdTmp,2)
    if XuUpdTmp(i).w > poissThresh
        XuUpd(ind) = XuUpdTmp(i);
        ind = ind+1;
    end
end

disp(['Find A time: ', num2str(sum(timeA)), 's'])
disp(['Murty time: ', num2str(sum(murtTime)), 's'])
disp(['Glob time: ', num2str(sum(globTime)), 's'])
disp(['Pred time: ', num2str(timePred), 's'])
disp(['Upd time: ', num2str(timeUpd), 's'])
disp(['Nbr global hypo pre murty: ', num2str(size(wGlob,2))])
disp(['Nbr global hypo: ', num2str(size(Xupd,2))])