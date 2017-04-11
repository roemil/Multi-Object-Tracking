clc

% Inititate
sigmaQ = 2;         % Process (motion) noise
R = 0.1*[1 0;0 1];    % Measurement noise
T = 0.1; % sampling time, 1/fps
FOVsize = [20,30]; % in m
 
% Assume constant
Pd = 0.9;   % Detection probability
Ps = 0.95;   % Survival probability
c = 0.2;    % clutter intensity
 
% Initiate undetected targets
XuPred = cell(1);
XuUpd = cell(1);
 
% Initiate pot new
XmuPred = cell(1); % XmuPred{t}(i)
XmuUpd = cell(1,1); % XmuUpd{t,z}(i)
% Xmu = [wu, state, Pu, S]
 
% Inititate hypotheses
Xhypo = cell(1,1,1); % Xhypo{t,j,z}(i)
XpotNew = cell(1,1); % XpotNew{t,z}(i)
 
% Initiate potential targets. X = {t,j}(i)
Xpred = cell(1,1);
Xupd = cell(1,1);
% x = [w, state, P, r, z]'
 
% Generate motion and measurement models
[F, Q] = generateMotionModel(sigmaQ, T, 'cv');
H = generateMeasurementModel({},'linear');
 
% TODO: Initial guess??
for i = 1:40
    XmuUpd{1}(i).w = 1;    % Pred weight
    XmuUpd{1}(i).state = [unifrnd(-FOVsize(1)/2, FOVsize(1)/2), ...
        unifrnd(0, FOVsize(2)), unifrnd(-0.2,0.2), unifrnd(-0.2,0.2)]';      % Pred state
    XmuUpd{1}(i).P = 7*eye(4);      % Pred cov
 
    XuUpd{1}(i).w = 1;    % Pred weight
    XuUpd{1}(i).state = [unifrnd(-FOVsize(1)/2, FOVsize(1)/2), ...
        unifrnd(0, FOVsize(2)), unifrnd(-0.2,0.2), unifrnd(-0.2,0.2)]';      % Pred state
    XuUpd{1}(i).P = 7*eye(4);      % Pred cov
end
 
Xupd = cell(1);
Xupd2 = cell(1);

threshold = 0.1;    % CHANGED 0.1
poissThresh = 1e-3;
Nhconst = 100;
nbrOfBirths = 5;
maxKperGlobal = 50;
maxNbrGlobal = 200;

% Save everything in simVariables and load at the begining of the filter
save('simVariables','R','T','FOVsize','R','F','Q','H','Pd','Ps','c','threshold','poissThresh');

% For birth case
% ind = 1;
% for i = 1 : size(z,2)
%     if(~isempty(z{i}))
%         Z{ind} = z{i};
%         ind = ind + 1;
%     end
% end

K =size(X,2); % Length of sequence

%Z = measGenerateCase2(X, R, FOVsize, K);

for k = 2:K % For each time step
    disp(['--------------- k = ', num2str(k), ' ---------------'])
    Nh = Nhconst*size(Z{k},2);    %Murty
    [XuUpd{k}, Xpred{k}, Xupd{k}, Xest{k}, Pest{k}] = PMBMfunc(Z{k}, XuUpd{k-1}, Xupd{k-1}, Nh, nbrOfBirths, maxKperGlobal, maxNbrGlobal);
    %XuUpd{k}
    %keyboard
end
    
    
    