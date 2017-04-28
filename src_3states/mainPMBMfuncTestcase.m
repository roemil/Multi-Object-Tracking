clc

%%%%%% Inititate %%%%%%
sigmaQ = 4;         % Process (motion) noise
R = 0.01*[1 0;0 1];    % Measurement noise
T = 0.1; % sampling time, 1/fps
FOVsize = [20,30]; % in m
 
% Assume constant
Pd = 0.9;   % Detection probability
Ps = 0.99;   % Survival probability
c = 0.25;    % clutter intensity
 
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

vinit = 1;
nbrInitBirth = 40;
 
% TODO: Initial guess??
for i = 1:nbrInitBirth
    XmuUpd{1}(i).w = 1/nbrInitBirth;    % Pred weight
    XmuUpd{1}(i).state = [unifrnd(-FOVsize(1)/2, FOVsize(1)/2), ...
        unifrnd(0, FOVsize(2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';      % Pred state
    XmuUpd{1}(i).P = 7*eye(4);      % Pred cov
 
    XuUpd{1}(i).w = 1/nbrInitBirth;    % Pred weight
    XuUpd{1}(i).state = [unifrnd(-FOVsize(1)/2, FOVsize(1)/2), ...
        unifrnd(0, FOVsize(2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';      % Pred state
    XuUpd{1}(i).P = 7*eye(4);      % Pred cov
end
 
Xupd = cell(1);

%%%%%% INITIATE %%%%%%
threshold = 0.05;    % CHANGED 0.1
thresholdEst = 0.4;
poissThresh = 1e-3;
Nhconst = 100;
nbrOfBirths = 15;
maxKperGlobal = 20;
maxNbrGlobal = 100;

% Save everything in simVariables and load at the begining of the filter
%save('simVariables','R','T','FOVsize','R','F','Q','H','Pd','Ps','c','threshold','poissThresh','vinit','thresholdEst');

% For birth case
% ind = 1;
% for i = 1 : size(z,2)
%     if(~isempty(z{i}))
%         Z{ind} = z{i};
%         ind = ind + 1;
%     end
% end

K =size(Z,2); % Length of sequence

T = 1; % Nbr of simulations

nbrMissmatch = zeros(1,T);

startTime = tic;
for t = 1:T
    disp('-------------------------------------')
    disp(['--------------- t = ', num2str(t), ' ---------------'])
    disp('-------------------------------------')
    
    %Z = measGenerateCase2(X, R, FOVsize, K);
    Nh = Nhconst*size(Z{k},2);    %Murty
    %[XuUpd{t,1}, Xupd{t,1}, Xest{t,1}, Pest{t,1}, rest{t,1}, west{t,1}] = ...
    %    PMBMinitFunc(Z{t,1}(1:2,:), XmuUpd{t,1}, XuUpd{t,1}, Nh, nbrOfBirths, maxKperGlobal, maxNbrGlobal);

    for k = 2:20 % For each time step
        disp(['--------------- k = ', num2str(k), ' ---------------'])
        Nh = Nhconst*size(Z{k},2);    %Murty
        [XuUpd{t,k}, Xpred{t,k}, Xupd{t,k}, Xest{t,k}, Pest{t,k}, rest{t,k}, west{t,k}] = ...
            PMBMfunc(Z{t,k}(1:2,:), XuUpd{t,k-1}, Xupd{t,k-1}, Nh, nbrOfBirths, maxKperGlobal, maxNbrGlobal);
        
        disp(['Nbr targets: ', num2str(size(X{t,k},2))])
        disp(['Nbr estimates: ', num2str(size(Xest{t,k},2))])
        disp(['Nbr prop targets: ', num2str(sum(rest{t,k} == 1))])
        disp(['Nbr clutter points: ', num2str(size(Z{k},2)-size(X{k},2))])
        if size(X{t,k},2) ~= size(Xest{t,k},2)
           nbrMissmatch(t) = nbrMissmatch(t)+1;
        end
    end
    
end
simTime = toc(startTime);

disp('--------------- Simulation Complete ---------------')
disp(['Total simulation time: ', num2str(simTime)])
    
    
    