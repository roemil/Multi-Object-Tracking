%%%%% PMBM %%%%%
function [pred, Xupd, Xest, Pest] = PMBM(Z)

% Inititate
sigmaQ = 2;         % Process (motion) noise
R = 0.1*[1 0;0 1];    % Measurement noise
T = 0.1; % sampling time, 1/fps
FOVsize = [20,30]; % in m
 
% Assume constant
Pd = 0.9;   % Detection probability
Ps = 0.95;   % Survival probability
c = 0.2;    % clutter intensity
 
% Initiate birth
Xb{1} = [Z{2}(:,1); unifrnd(-0.2,0.2); unifrnd(-0.2,0.2)];
Pb{1} = 7*eye(4); %4*diag([2, 2, 1, 1]);
wb{1} = 1;
 
% Initiate undetected targets
% XuPred = cell(1,1,3);
% XuUpd = cell(1,1,3);
XuPred = cell(1);
XuUpd = cell(1);
% Xu = [wu, state, Pu]
 
% Initiate pot new
%XmuPred = cell(1,1,4);
%XmuUpd = cell(1,1,4);
XmuPred = cell(1); % XmuPred{t}(i)
XmuUpd = cell(1,1); % XmuUpd{t,z}(i)
% Xmu = [wu, state, Pu, S]
 
% Inititate hypotheses
Xhypo = cell(1,1,1); % Xhypo{t,j,z}(i)
XpotNew = cell(1,1); % XpotNew{t,z}(i)
 
% Initiate potential targets. X = {t,j}(i)
%Xpred = cell(1,1,1,5);
%Xupd = cell(1,1,1,5);
Xpred = cell(1,1);
Xupd = cell(1,1);
% x = [w, state, P, r, z]'
 
% Generate motion and measurement models
[F, Q] = generateMotionModel(sigmaQ, T, 'cv');
H = generateMeasurementModel({},'linear');
 
% TODO: Initial guess??
for i = 1:20
    XmuUpd{1}(i).w = 1;    % Pred weight
%     XmuUpd{1}(i).state = [unifrnd(-FOVsize(1)/2, FOVsize(1)/2), ...
%         unifrnd(0, FOVsize(2)), unifrnd(-2,2), unifrnd(-2,2)]';      % Pred state
    XmuUpd{1}(i).state = [unifrnd(-FOVsize(1)/2, FOVsize(1)/2), ...
        unifrnd(0, FOVsize(2)), unifrnd(-0.2,0.2), unifrnd(-0.2,0.2)]';      % Pred state
    XmuUpd{1}(i).P = 7*eye(4);      % Pred cov
 
    XuUpd{1}(i).w = 1;    % Pred weight
%     XuUpd{1}(i).state = [unifrnd(-FOVsize(1)/2, FOVsize(1)/2), ...
%         unifrnd(0, FOVsize(2)), unifrnd(-2,2), unifrnd(-2,2)]';      % Pred state
    XuUpd{1}(i).state = [unifrnd(-FOVsize(1)/2, FOVsize(1)/2), ...
        unifrnd(0, FOVsize(2)), unifrnd(-0.2,0.2), unifrnd(-0.2,0.2)]';      % Pred state
    XuUpd{1}(i).P = 7*eye(4);      % Pred cov
end
 
%Xupd{1,1}.w = 1;
%Xupd{1,1}.r = 1;
%Xupd{1,1}.state = [Z{2}(1,1) Z{2}(2,1) 0 0]';
%Xupd{1,1}.P = 0.5*eye(4);
Xupd = cell(1);
%Xtmp = cell(1);

threshold = 0.1;    % CHANGED 0.1
wThresh = 0.007;    % CHANGED 0.005

K =size(Z,2); % Length of sequence
for k = 2:K %K % For each time step
    disp(['-------', num2str(k), '-------'])
    Wold = 0;
    C = [];
    Nh = 100*size(Z{k},2);    %Murty

    %%%%% Prediction %%%%%
    
    % TODO: Special case for k == 1?? 
    
    % Poisson - Assume constant birth atm
    for i = 1:size(XuUpd{k-1},2) % For each single target component i
        [XuPred{k}(i).state, XuPred{k}(i).P] = KFPred(XuUpd{k-1}(i).state,F, XuUpd{k-1}(i).P, Q);
     
%     XmuPred{k,1} = [wb{1} XuUpd{k-1,1}];    % Pred weight
%     XmuPred{k,2} = [Xb{1} XuPred{k,2}];      % Pred state
%     XmuPred{k,3} = [Pb{1} XuPred{k,3}];      % Pred cov
        XmuPred{k}(i).w = XuUpd{k-1}(i).w;    % Pred weight
        XmuPred{k}(i).state = XuPred{k}(i).state;      % Pred state
        XmuPred{k}(i).P = XuPred{k}(i).P;      % Pred cov    
        %mu = @(x) gaussMix(XuPred{k}(i).w,XuPred{k}(i).state,XuPred{k}(i).P); % Pred Poisson intensity (41)
        
        % MIGHT HAVE MIXED UP PREDICTION STEPS
    end
    
    % TODO: Fix births. Atm just 1 birth
    XmuPred{k}(end+1).w = 1; %wb{1};
%     XmuPred{k}(end).state = [unifrnd(-FOVsize(1)/2, FOVsize(1)/2), ...
%         unifrnd(0, FOVsize(2)), unifrnd(-2,2), unifrnd(-2,2)]';%Xb{1};
    XmuPred{k}(end).state = [unifrnd(-FOVsize(1)/2, FOVsize(1)/2), ...
        unifrnd(0, FOVsize(2)), unifrnd(-0.2,0.2), unifrnd(-0.2,0.2)]';%Xb{1};
    XmuPred{k}(end).P = Pb{1};
    
    XuUpd = updatePoisson(XmuPred,k,Pd);
    
    Xpred = predictDetectedBernoulli(Xupd, F, Q, Ps, k);
    
    pred{k} = Xpred{k};
    %%%%% Update %%%%%
    % Update for potential targets detected for the first time
    nbrOfMeas = size(Z{k},2);
    if ~isempty(Xpred{k})
        nbrOfGlobHyp = size(Xpred,2);
    else
        nbrOfGlobHyp = 0;
    end
    
    [XpotNew, rho] = updateNewPotTargets(XmuPred,XmuUpd, nbrOfMeas, Pd, H, R, Z, k, c);
    
    %%%% Update for previously potentially detected targets %%%%
    Xhypo = generateTargetHypo(Xpred, nbrOfMeas, nbrOfGlobHyp,k, Pd, H, R, Z);
    

%     %min(length(index),size(Xtmp{k},1))
%     for ind = 1 : min(length(index),size(Xtmp{k},1))
%         for nbrOfTarg = 1 : size(Xtmp{k},2)
%             Xtmp2_k{k,ind}(nbrOfTarg) = Xtmp{k,index(ind)}(nbrOfTarg);
%         end
%     end
%     
    
    
    % TODO: Generate new global hypo from Xhypo and XpotNew
    oldInd = 0;
    m = size(Z{k},2);
    Wnew = diag(rho);
    for j = 1:max(1,nbrOfGlobHyp)
        if ~isempty(Xhypo{k,j})
            nbrOldTargets = size(Xhypo{k,j,1},2);
            [A, S, Amat] = generateGlobalInd(m, nbrOldTargets);
        else
            nbrOldTargets = 0;
            A{1} = 1:m;
            Amat = 1:m;
            S = zeros(m,m,1);
            S(:,:,1) = eye(m);
        end
        
        %%%%% MURTY %%%%%%
        
        % TODO: Fix S matrix, use that as input to Global hyp 
        wHyp = 1;
        wHypSum = 0;
        Wold = zeros(nbrOfMeas,size(Xhypo{k,j},2));
        for m = 1 : nbrOfMeas
            for nj = 1 : size(Xhypo{k,j},2)
                % Normalize weights for cost matrix
                Wold(m,nj) = Xhypo{k,j,m}(nj).w*Xhypo{k,j,m}(nj).r*Pd*mvnpdf(Z{k}(:,m)...
                    ,H*Xpred{k,j}(nj).state,Xhypo{k,j,m}(nj).S)...
                    /(Xhypo{k,j,m}(nj).w*(1-Xhypo{k,j,m}(nj).r+Xhypo{k,j,m}(nj).r*(1-Pd))); 
                Wold(m,nj) = Xhypo{k,j,m}(nj).w; 
                wHyp = wHyp * Xpred{k,j}(nj).w;
                wHypSum = wHypSum + Xpred{k,j}(nj).w;
            end
        end
        if(wHypSum == 0)
            wHypSum = 1;
        end
        wHyp = wHyp / wHypSum; % shall I normalize?
        if sum(sum(Wold)) ~= 0
            C = -[log(Wold), log(Wnew)];
        else
            C = -log(Wnew);
        end
        
        [rows,cols] = find(C == inf);
        if ~isempty(rows)
            for i = 1 : size(rows,1)
                C(rows(i),cols(i)) = 1e20;
            end
        end
        
        K_hyp = max(1,ceil(Nh * wHyp));
%         K_old = 1;
        trace_vec = zeros(1,size(S,3));
        for jnew = 1:size(S,3)
            trace_vec(jnew) = trace(S(:,:,jnew)'*C);
        end
    
        [ass, cost] = murty(trace_vec,min(size(trace_vec,2),K_hyp));
        ind = find(ass==0);
        if ~isempty(ind)
            ass = ass(1:ind-1);
        end
        
        [newGlob, newInd] = generateGlobalHypo5(Xhypo(k,j,:), XpotNew(k,:), Z{k}, oldInd, Amat, ass,nbrOldTargets);

        for jnew = oldInd+1:newInd
            Xtmp{k,jnew} = newGlob{jnew-oldInd};
        end
        oldInd = newInd;
    end
    
    %if(~isempty(Xtmp{1})) % TODO: Quick fix - Xtmp will depend on generateGlobalHyp
    for j = 1:size(Xtmp,2)
        wSum(j) = 0;
        wGlob(j) = 1;
        if ~isempty(Xtmp{k,j})
            for i = 1:size(Xtmp{k,j},2)
                if ~isempty(Xtmp{k,j}(i).w)
                    wGlob(j) = wGlob(j)*Xtmp{k,j}(i).w;
                    if Xtmp{k,j}(i).r > threshold
                        wSum(j) = wSum(j) + Xtmp{k,j}(i).w;
                    end
                end
            end
        end
    end

    [Xest{k}, Pest{k}] = est1(Xtmp, threshold,k);
    
    [keepGlobs,~] = murty(wGlob,Nh);
    
    %Xupd{k} = removeLowProbExistence(Xtmp2{k},threshold,wSum, k);
    for j = 1:size(keepGlobs,1)
        iInd = 1;
        for i = 1:size(Xtmp{k,keepGlobs(j)},2)
            if Xtmp{k,keepGlobs(j)}(i).r > threshold
                Xupd{k,j}(iInd) = Xtmp{k,keepGlobs(j)}(i);
                Xupd{k,j}(iInd).w = Xtmp{k,keepGlobs(j)}(i).w/wSum(keepGlobs(j));
                iInd = iInd+1;
            end
        end
    end
    %disp(['k_new: ', num2str(K_new)])
    disp('Nbr global hypo pre murty: ', num2str(size(wGlob,2)))
    disp(['Nbr global hypo: ', num2str(size(Xupd,2))])
end