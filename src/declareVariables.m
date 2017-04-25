function [nbrInitBirth, wInit, FOVinit, vinit, covBirth, Z, nbrOfBirths, ...
    maxKperGlobal, maxNbrGlobal, Nhconst, XmuUpd, XuUpd] ...
    = declareVariables(mode, set, sequence, motionModel)

%%%%%% Load Detections %%%%%%
% Training 0016 and testing 0001
if(strcmp(mode,'linear'))
    datapath = strcat('../data/tracking/',set,'/',sequence,'/');
    filename = [datapath,'inferResult.txt'];
    formatSpec = '%f%f%f%f%f%f%f%f%f';
    f = fopen(filename);
    detections = textscan(f,formatSpec);
    fclose(f);
elseif(strcmp(mode,'nonlinear'))
    datapath = strcat('../data/tracking_dist/',set,'/',sequence,'/');
    filename = [datapath,'inferResult.txt'];
    formatSpec = '%f%f%f%f%f%f%f%f%f';
    f = fopen(filename);
    detections = textscan(f,formatSpec);
    fclose(f);
elseif(strcmp(mode,'GT'))
    datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
end

%detections = textread(filename); % frame, size_x, size_y, class, cx, cy, w, h, conf
%Z = cell(size(detections,1),5);
Z = cell(1);
if(strcmp(mode,'linear'))
oldFrame = detections{1}(1)+1;
count = 1;
    Z{1}(:,1) = [detections{5}(1);detections{6}(1);detections{7}(1);detections{8}(1);detections{9}(1)]; % cx
    for i = 2 : size(detections{1},1)
        frame = detections{1}(i)+1;
        if(frame == oldFrame)
            Z{frame}(:,count+1) = [detections{5}(i);detections{6}(i);detections{7}(i);detections{8}(i);detections{9}(i)]; % cx
            count = count + 1;
            oldFrame = frame;
        else
            Z{frame}(:,1) = [detections{5}(i);detections{6}(i);detections{7}(i);detections{8}(i);detections{9}(i)]; % cx
            count = 1;
            oldFrame = frame;  
        end
    end
elseif(strcmp(mode,'nonlinear'))
    oldFrame = detections{1}(1)+1;
    count = 1;
    Z{1}(:,1) = [detections{5}(1);detections{6}(1);detections{7}(1);detections{8}(1);detections{9}(1);detections{end}(1)]; % cx
    for i = 2 : size(detections{1},1)
        frame = detections{1}(i)+1;
        if(frame == oldFrame)
            Z{frame}(:,count+1) = [detections{5}(i);detections{6}(i);detections{7}(i);detections{8}(i);detections{9}(i);detections{end}(i)]; % cx
            count = count + 1;
            oldFrame = frame;
        else
            Z{frame}(:,1) = [detections{5}(i);detections{6}(i);detections{7}(i);detections{8}(i);detections{9}(i);detections{end}(i)]; % cx
            count = 1;
            oldFrame = frame;  
        end
    end
elseif(strcmp(mode,'GT'))
    Z = generateGT(set,sequence,datapath);
end

if strcmp(motionModel,'cv')
        posStates = 4;
        nbrStates = 4;
        nbrMeas = 2;
        
    elseif strcmp(motionModel,'cvBB')
        posStates = 4;
        nbrStates = 6;
        nbrMeas = 2;
    end

%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Inititate %%%%%%
sigmaQ = 25;         % Process (motion) noise % 20 ok1 || 24 apr 10

if strcmp(motionModel,'cv')
    R = 0.1*eye(2);
elseif strcmp(motionModel,'cvBB')
    R = 0.1*eye(4);    % Measurement noise % 0.01 ok1 || 0.001
end

T = 0.1; % sampling time, 1/fps

if strcmp(mode,'GT')
    FOVsize = [0,0;1242,375]; % in m
else
    FOVsize = [0,0;detections{3}(1),detections{2}(1)]; % in m
end
% Assume constant
Pd = 0.9;   % Detection probability % 0.7 ok1
Ps = 0.99;   % Survival probability % 0.98 ok1
c = 0.001;    % clutter intensity % 0.001 ok1 || 24 apr 0.0001
 
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
sigmaBB = 5;
[F, Q] = generateMotionModel(sigmaQ, T, motionModel, sigmaBB);

if(strcmp(mode,'nonlinear'))
    h = {'distance','angle'};
    H = generateMeasurementModel(h,'nonlinear',motionModel);
elseif(strcmp(mode,'linear'))
    H = generateMeasurementModel({},'linear',motionModel);
elseif(strcmp(mode,'GT'))
    H = generateMeasurementModel({},'linear',motionModel);
end

% Add cov on pos?? 
if strcmp(motionModel,'cv')
    %Q = Q + 25*diag([1.2 1 0 0]); % 10
    Q = Q + 0.1*diag([FOVsize(2,1), FOVsize(2,2), 0, 0]);
elseif strcmp(motionModel, 'cvBB')
    %Q = Q + 25*diag([1.2 1 0 0 0 0]); % 10
    Q = Q + 0.1*diag([FOVsize(2,1), FOVsize(2,2), 0, 0 0 0]);
end

vinit = 0;
nbrInitBirth = 2000; % 600 ok1
covBirth = 20; % 20 ok1
wInit = 1;%0.2;

FOVinit = FOVsize;%+50*[-1 -1;
                   % 1 1];
                   
                   %%%%%% INITIATE %%%%%%
% Threshold existence probability keep for next iteration
threshold = 1e-2;    % 0.01 ok1
% Threshold existence probability use estimate
thresholdEst = 0.4; % 0.6 ok1
% Threshold weight undetected targets keep for next iteration
poissThresh = 1e-5;
% Murty constant
Nhconst = 100;
% Number of births
nbrOfBirths = 200; % 600 ok1
% Max nbr of globals for each old global
maxKperGlobal = 20;
% Max nbr globals to pass to next iteration
maxNbrGlobal = 50;
% boarder width with higher probability of birth
boarderWidth = 0.1*FOVsize(2,1);
boarder = [0, FOVsize(2,1)-boarderWidth;
    boarderWidth, FOVsize(2,1)];
% Percentage of births within boarders
pctWithinBoarder = 0.2;
% Weight of the births
weightBirth = 1;

XmuUpd = cell(1);
XuUpd = cell(1);
% TODO: Should the weights be 1/nbrInitBirth?
if strcmp(motionModel,'cv')
    for i = 1:nbrInitBirth
        XmuUpd{1}(i).w = wInit;    % Pred weight
        XmuUpd{1}(i).state = [unifrnd(FOVinit(1,1), FOVinit(2,1)), ...
            unifrnd(FOVinit(1,2), FOVinit(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';      % Pred state
        XmuUpd{1}(i).P = covBirth*eye(4);      % Pred cov

        XuUpd{1}(i).w = wInit;    % Pred weight
        XuUpd{1}(i).state = [unifrnd(FOVinit(1,1), FOVinit(2,1)), ...
            unifrnd(FOVinit(1,2), FOVinit(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';      % Pred state
        XuUpd{1}(i).P = covBirth*eye(4);      % Pred cov
    end
elseif strcmp(motionModel,'cvBB')
    for i = 1:nbrInitBirth
        XmuUpd{1}(i).w = wInit;    % Pred weight
        XmuUpd{1}(i).state = [unifrnd(FOVinit(1,1), FOVinit(2,1)), ...
            unifrnd(FOVinit(1,2), FOVinit(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), 0, 0]';      % Pred state
        XmuUpd{1}(i).P = covBirth*eye(6);      % Pred cov

        XuUpd{1}(i).w = wInit;    % Pred weight
        XuUpd{1}(i).state = [unifrnd(FOVinit(1,1), FOVinit(2,1)), ...
            unifrnd(FOVinit(1,2), FOVinit(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), 0, 0]';      % Pred state
        XuUpd{1}(i).P = covBirth*eye(6);      % Pred cov
    end
end


% Save everything in simVariables and load at the begining of the filter
save('simVariables','R','T','FOVsize','R','F','Q','H','Pd','Ps','c','threshold',...
    'poissThresh','vinit','thresholdEst','covBirth','boarder','pctWithinBoarder',...
    'weightBirth','motionModel','posStates','nbrStates','nbrMeas');