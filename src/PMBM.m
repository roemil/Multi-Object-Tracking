%%%%% PMBM %%%%%

% Measurements
Z = cell(1);

% Inititate
sigmaQ = 1;
R = [1 0;0 0.1];
T = 0.1;
FOVsize = [20,30];

% Assume constant
Pd = 0.9;
Ps = 0.9;
c = 0.2;

% Initiate birth
Xb{1} = [0; FOVsize(2)/2; 0; 0];
Pb{1} = diag([10, 10, 2 2]);
wb{1} = 1;

% Initiate undetected targets
XuPred = cell(1,1,3);
XuUpd = cell(1,1,3);
% Xu = [wu, state, Pu]

% Initiate pot new
XmuPred = cell(1,1,4);
XmuUpd = cell(1,1,4);
% Xmu = [wu, state, Pu, S]

% Initiate potential targets. X = {t,j,i,x}
Xpred = cell(1,1,1,5);
Xupd = cell(1,1,1,5);
% x = [w, state, P, r, z]'

% Generate motion and measurement models
F = generateMotionModel(sigmaQ, T, 'cv');
H = generateMeasurementModel({},'linear');

K = 100; % Length of sequence
for k = 2:K
    %%%%% Prediction %%%%%
    
    % TODO: Special case for k == 1?? 
    
    % Poisson - Assume constant birth atm
    for i = 1:size(XuUpd{k-1},2)
    [XmuPred{k,2}, XmuPred{k,3}] = KFPred(XuUpd{k-1,2},F, XuUpd{k-1,2}, Q);
     
    XmuPred{k,1} = [wb{1} XuUpd{k-1,1}];    % Pred weight
    XmuPred{k,2} = [Xb{1} XuPred{k,2}];      % Pred state
    XmuPred{k,3} = [Pb{1} XuPred{k,3}];      % Pred cov
    
    mu = @(x) gaussMix(XuPred{k,1},XuPred{k,2},XuPred{k,3}); % Pred Poisson intensity

    
    % Bernoulli
    Xpred{k,1} = Xupd{k-1,1};      % Pred weight
    [Xpred{k,2}, Xpred{k,3}] = KFPred(Xupd{k-1,2}, F, Xupd{k-1,3} ,Q);    % Pred state
    Xpred{k,4} = Ps*Xupd{k-1,4};   % Pred prob. of existence
    
    %%%%% Update %%%%%

    % Update undetected targets (Poisson component)
    XuUpd{k,1} = (1-Pd)*XmuPred{k,1};
    XuUpd{k,2} = XmuPred{k,2};
    XuUpd{k,3} = XmuPred{k,3};

    S = 0;
    w = zeros(1,size(Z{k},2));
    % Update for potential targets detected for the first time
    for z = 1:size(Z{k},2)
        for i = 1:size(XmuPred{k,2},2)
            % Pass through Kalman
            [XmuUpd{k,2}, XmuUpd{k,3}, XmuUpd{k,4}] = KFUpd(XmuPred{k,2},H, XmuPred{k,3}, R, Z{k}(:,z));
            
            % TODO: DEFINE THESE AS FUNCTIONS AND JUST PASS DIFF z? 
            % Compute weight
            w(1,i) = XmuPred{k,1}(:,i)*mvnpdf(Z{k}(:,z), H*XmuPred{k,2}, S); 

            e = Pd*generateGaussianMix(Z{k}(:,z), H*XmuPred{k,2}, S);
        rho = e+c;
        r = e/rho;
        
        
        
    % Update for previously potentially detected targets


end
