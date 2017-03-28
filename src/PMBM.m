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
Xhypo = cell(1,1); % Xhypo{t,z}(i)

% Initiate potential targets. X = {t,j}(i)
%Xpred = cell(1,1,1,5);
%Xupd = cell(1,1,1,5);
Xpred = cell(1,1);
Xupd = cell(1,1);
% x = [w, state, P, r, z]'

% Generate motion and measurement models
F = generateMotionModel(sigmaQ, T, 'cv');
H = generateMeasurementModel({},'linear');

K = 100; % Length of sequence
for k = 2:K % For each time step
    %%%%% Prediction %%%%%
    
    % TODO: Special case for k == 1?? 
    
    % Poisson - Assume constant birth atm
    for i = 1:size(XuUpd{k-1},2) % For each single target component i
        [XmuPred{k}(i).state, XmuPred{k}(i).P] = KFPred(XuUpd{k-1}(i).state,F, XuUpd{k-1}(i).P, Q);
     
%     XmuPred{k,1} = [wb{1} XuUpd{k-1,1}];    % Pred weight
%     XmuPred{k,2} = [Xb{1} XuPred{k,2}];      % Pred state
%     XmuPred{k,3} = [Pb{1} XuPred{k,3}];      % Pred cov
        XmuPred{k}(i).w = [wb{1} XuUpd{k-1}(i).w];    % Pred weight
        XmuPred{k}(i).state = [Xb{1} XuPred{k}.state];      % Pred state
        XmuPred{k}(i).P = [Pb{1} XuPred{k}(i).P];      % Pred cov    
        mu = @(x) gaussMix(XuPred{k}(i).w,XuPred{k}(i).state,XuPred{k}(i).P); % Pred Poisson intensity
        
        % MIGHT HAVE MIXED UP PREDICTION STEPS
        
        % Update undetected targets (Poisson component)
        XuUpd{k}(i).w = (1-Pd)*XmuPred{k}(i).w;
        XuUpd{k}(i).state = XmuPred{k}(i).state;
        XuUpd{k}(i).P = XmuPred{k}(i).P;
    end
    
    for j = 1:size(Xupd{k},2)
        for i = 1:size(Xupd{k,j},2)
            % Bernoulli
            Xpred{k,j}(i).w = Xupd{k-1,j}(i).w;      % Pred weight
            [Xpred{k,j}(i).state, Xpred{k,j}(i).P] = KFPred(Xupd{k-1,j}(i).state, F, Xupd{k-1,j}(i).P ,Q);    % Pred state
            Xpred{k,j}(i).r = Ps*Xupd{k-1,j}(i).r;   % Pred prob. of existence
        end
    end

    %%%%% Update %%%%%

    % Update for potential targets detected for the first time
    for z = 1:size(Z{k},2)
        w = zeros(1,size(Z{k},2));
        Xmutmp = zeros(4,size(XmuPred{k,2},2));
        Stmp = cell(size(XmuPred{k,2},2));
        for i = 1:size(XmuPred{k,2},2)
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
        
        e = Pd*generateGaussianMix(Z{k}(:,z), H*Xmutmp, Stmp);
        XmuUpd{k,z}.w = e+c; % rho
        XmuUpd{k,z}.r = e/XmuUpd{k,z}.w;
    end
    
    % Create missdetection hypo in index size(Z{k},2)+1
    for j = 1:size(Xpred{k},2)
        for i = 1:size(Xpred{k,j},2)
            Xhypo{k,size(Z{k},2)+1}(i).w = Xpred{k,j}(i).w*(1-Xpred{k,j}(i).r+Xpred{k,j}(i).r*(1-Pd));
            Xhypo{k,size(Z{k},2)+1}(i).r = Xpred{k,j}(i).r*(1-Pd)/(1-Xpred{k,j}(i).r+Xpred{k,j}(i).r*(1-Pd));
            Xhypo{k,size(Z{k},2)+1}(i).state = Xpred{k,j}(i).state;
            Xhypo{k,size(Z{k},2)+1}(i).P = Xpred{k,j}(i).P;
        end
    end
            
    % Update for previously potentially detected targets
    for z = 1:size(Z{k},2)
        for j = 1:size(Xpred{k},2)
            for i = 1:size(Xpred{k,j},2)
end
