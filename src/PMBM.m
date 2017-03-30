%%%%% PMBM %%%%%
function [Xpred, Xupd] = PMBM(Z)

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

Xupd{1,1}.w = 1;
Xupd{1,1}.r = 1;
Xupd{1,1}.state = [0 0 0 0]';
Xupd{1,1}.P = 10*eye(4);

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
    
    for i = 1:size(XmuPred{k},2)    
        % Update undetected targets (Poisson component)
        XuUpd{k}(i).w = (1-Pd)*XmuPred{k}(i).w;
        XuUpd{k}(i).state = XmuPred{k}(i).state;
        XuUpd{k}(i).P = XmuPred{k}(i).P;
    end
    
    for j = 1:size(Xupd{k-1},2)
        for i = 1:size(Xupd{k-1,j},2)
            % Bernoulli
            if Xupd{k-1,j}(i).w == 0
                %keyboard
            end
            Xpred{k,j}(i).w = Xupd{k-1,j}(i).w;      % Pred weight
            [Xpred{k,j}(i).state, Xpred{k,j}(i).P] = KFPred(Xupd{k-1,j}(i).state, F, Xupd{k-1,j}(i).P ,Q);    % Pred state
            Xpred{k,j}(i).r = Ps*Xupd{k-1,j}(i).r;   % Pred prob. of existence
        end
    end

    %%%%% Update %%%%%

    % Update for potential targets detected for the first time
    for z = 1:size(Z{k},2)
        % TODO: Fixed?
        %w = zeros(1,size(Z{k},2));
        w = zeros(1,size(XmuPred{k},2));
        %Xmutmp = zeros(4,size(XmuPred{k,2},2));
        %Stmp = cell(size(XmuPred{k,2},2));
        XpotNew{k,z}.state = zeros(4,1);
        XpotNew{k,z}.P = zeros(4,4);
        for i = 1:size(XmuPred{k},2)
            % Pass through Kalman
            [XmuUpd{k,z}(i).state, XmuUpd{k,z}(i).P, XmuUpd{k,z}(i).S] = KFUpd(XmuPred{k}(i).state,H, XmuPred{k}(i).P, R, Z{k}(:,z));
            
            % TODO: DEFINE THESE AS FUNCTIONS AND JUST PASS DIFF z? 
            % Compute weight
            w(1,i) = XmuPred{k}(i).w*mvnpdf(Z{k}(:,z), H*XmuPred{k}(i).state, XmuUpd{k,z}(i).S);
            
            % TODO: temp solution
            Xmutmp(1:4,i) = XmuPred{k}(i).state;
            Stmp{i} = XmuUpd{k,z}(i).S;
        end
        % Normalize weight
        w = w/sum(w);
        % TODOTODO: ERROR HERE!!
        % Find posterior
        for i = 1:size(w,2)
            % TODO: Is the moment matching correct? 
            XpotNew{k,z}.state = XpotNew{k,z}.state+w(1,i)*XmuUpd{k,z}(i).state; % (44)
            XpotNew{k,z}.P = XpotNew{k,z}.P+w(1,i)*XmuUpd{k,z}(i).P; % (44)
        end
        
        e = Pd*generateGaussianMix(Z{k}(:,z), ones(1,size(Xmutmp,2)), H*Xmutmp, Stmp);
        XpotNew{k,z}.w = e+c; % rho (45) (44)
        XpotNew{k,z}.r = e/XpotNew{k,z}.w; % (43) (44)
        %XmuUpd{k,z}.w = e+c; % rho
        %XmuUpd{k,z}.r = e/XmuUpd{k,z}.w;
    end
    
    %%%% Update for previously potentially detected targets %%%%
    % Create missdetection hypo in index size(Z{k},2)+1
    for j = 1:size(Xpred{k},2)
        for i = 1:size(Xpred{k,j},2)
            if Xpred{k,j}(i).w*(1-Xpred{k,j}(i).r+Xpred{k,j}(i).r*(1-Pd)) == 0
                %keyboard
            end
            Xhypo{k,j,size(Z{k},2)+1}(i).w = Xpred{k,j}(i).w*(1-Xpred{k,j}(i).r+Xpred{k,j}(i).r*(1-Pd));
            Xhypo{k,j,size(Z{k},2)+1}(i).r = Xpred{k,j}(i).r*(1-Pd)/(1-Xpred{k,j}(i).r+Xpred{k,j}(i).r*(1-Pd));
            Xhypo{k,j,size(Z{k},2)+1}(i).state = Xpred{k,j}(i).state;
            Xhypo{k,j,size(Z{k},2)+1}(i).P = Xpred{k,j}(i).P;
        end
    end
         
    % Generate hypothesis for each single in each global for each measurement 
    for z = 1:size(Z{k},2)
        for j = 1:size(Xpred{k},2)
            for i = 1:size(Xpred{k,j},2)
                [Xhypo{k,j,z}(i).state, Xhypo{k,j,z}(i).P, Xhypo{k,j,z}(i).S] = KFUpd(Xpred{k,j}(i).state, H, Xpred{k,j}(i).P, R, Z{k}(:,z));
                Xhypo{k,j,z}(i).w = Xpred{k,j}(i).w*Xpred{k,j}(i).r*Pd*mvnpdf(Z{k}(:,z), H*Xpred{k,j}(i).state, Xhypo{k,j,z}(i).S);
                if Xhypo{k,j,z}(i).w == 0
                    %keyboard
                end
                Xhypo{k,j,z}(i).r = 1;
            end
        end
    end
    
    % TODO: Generate new global hypo from Xhypo and XpotNew
    oldInd = 0;
    for j = 1:size(Xpred{k},2)
        % TODO: updated generateGlobalHypo to v2!
        [newGlob, newInd] = generateGlobalHypo2(Xhypo(k,j,:), XpotNew(k,:), Z{k}, oldInd,k);
        for jnew = oldInd+1:newInd
            Xupd{k,jnew} = newGlob{jnew-oldInd};
        end
        oldInd = newInd;
    end
end
