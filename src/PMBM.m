%%%%% PMBM %%%%%
function [Xpred, Xupd, Xest] = PMBM(Z)

% Inititate
sigmaQ = 1;         % Process (motion) noise
R = [1 0;0 0.1];    % Measurement noise
T = 0.1; % sampling time, 1/fps
FOVsize = [20,30]; % in m

% Assume constant
Pd = 0.9;   % Detection probability
Ps = 0.9;   % Survival probability
c = 0.2;    % clutter intensity

% Initiate birth
Xb{1} = [0; FOVsize(2)/2; 0; 0];
Pb{1} = diag([10, 10, 2 2]);
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
XmuUpd{1}(1).w = 1;    % Pred weight
XmuUpd{1}(1).state = [0 0 0 0]';      % Pred state
XmuUpd{1}(1).P = 10*eye(4);      % Pred cov

XuUpd{1}(1).w = 1;    % Pred weight
XuUpd{1}(1).state = [0 0 0 0]';      % Pred state
XuUpd{1}(1).P = 10*eye(4);      % Pred cov

%Xupd{1,1}.w = 1;
%Xupd{1,1}.r = 1;
%Xupd{1,1}.state = [Z{2}(1,1) Z{2}(2,1) 0 0]';
%Xupd{1,1}.P = 0.5*eye(4);
Xupd = cell(1);
%Xtmp = cell(1);
threshold = 0.2;

K = size(Z,2); % Length of sequence
for k = 2:K % For each time step
    k
    %%%%% Prediction %%%%%
    
    % TODO: Special case for k == 1?? 
    
    % Poisson - Assume constant birth atm
    for i = 1:size(XuUpd{k-1},2) % For each single target component i
        [XuPred{k}(i).state, XuPred{k}(i).P] = KFPred(XuUpd{k-1}(i).state,F, XuUpd{k-1}(i).P, Q);
     
%     XmuPred{k,1} = [wb{1} XuUpd{k-1,1}];    % Pred weight
%     XmuPred{k,2} = [Xb{1} XuPred{k,2}];      % Pred state
%     XmuPred{k,3} = [Pb{1} XuPred{k,3}];      % Pred cov
        XmuPred{k}(i).w = XuUpd{k-1}(i).w;    % Pred weight
        XmuPred{k}(i).state = XuPred{k}.state;      % Pred state
        XmuPred{k}(i).P = XuPred{k}(i).P;      % Pred cov    
        %mu = @(x) gaussMix(XuPred{k}(i).w,XuPred{k}(i).state,XuPred{k}(i).P); % Pred Poisson intensity (41)
        
        % MIGHT HAVE MIXED UP PREDICTION STEPS
    end
    
    % TODO: Fix births. Atm just 1 birth
    XmuPred{k}(end+1).w = wb{1};
    XmuPred{k}(end).state = Xb{1};
    XmuPred{k}(end).P = Pb{1};
    
    XuUpd = updatePoisson(XmuPred,k,Pd);
    
    Xpred = predictDetectedBernoulli(Xupd, F, Q, Ps, k);
    
    
    %%%%% Update %%%%%
    % Update for potential targets detected for the first time
    nbrOfMeas = size(Z{k},2);
    nbrOfGlobHyp = size(Xpred,2);
    XpotNew = updateNewPotTargets(XmuPred,XmuUpd, nbrOfMeas, Pd, H, R, Z, k, c);
    
    %%%% Update for previously potentially detected targets %%%%
    Xhypo = generateTargetHypo(Xpred, nbrOfMeas, nbrOfGlobHyp,k, Pd, H, R, Z);
    % TODO: Generate new global hypo from Xhypo and XpotNew
    oldInd = 0;
    for j = 1:nbrOfGlobHyp
        % TODO: updated generateGlobalHypo to v2!
        % TODOTODOTODO: Generate hypo is wrong. We have constraints on
        % measurements on all X!!!
        [newGlob, newInd] = generateGlobalHypo3(Xhypo(k,j,:), XpotNew(k,:), Z{k}, oldInd);
        for jnew = oldInd+1:newInd
            Xtmp{k,jnew} = newGlob{jnew-oldInd};
        end
        oldInd = newInd;
    end
    jInd = 1;
    %if(~isempty(Xtmp{1})) % TODO: Quick fix - Xtmp will depend on generateGlobalHyp
    for j = 1:size(Xtmp,2)
        wGlob = 1;
        wSum = 0;
        if ~isempty(Xtmp{k,j})
            for i = 1:size(Xtmp{k,j},2)
                if ~isempty(Xtmp{k,j}(i).w)
                    wGlob = wGlob*Xtmp{k,j}(i).w;
                    wSum = wSum + Xtmp{k,j}(i).w;
                end
            end
            if wGlob > 0.0005
                for i = 1:size(Xtmp{k,j},2)
                    Xupd{k,jInd}(i) = Xtmp{k,j}(i);
                    Xupd{k,jInd}(i).w = Xupd{k,jInd}(i).w/wSum;
                end
                jInd = jInd+1;
            end
        end
    end
    Xest{k} = est1(Xupd, threshold);
end