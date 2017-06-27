function [nbrInitBirth, wInit, FOVinit, vinit, covBirth, Z, nbrOfBirths, ...
    maxKperGlobal, maxNbrGlobal, Nhconst, XmuUpd, XuUpd, FOVsize] ...
    = declareVariables(mode, set, sequence, motionModel, nbrPosStates)
global uniformBirths
global imgpath
global rescaleFact
global wInit
rescaleFact = 1;
global T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Load Detections %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Training 0016 and testing 0001
if(strcmp(mode,'CNN'))
    datapath = strcat('../data/tracking/',set,'/',sequence,'/');
    filename = [datapath,'inferResult.txt'];
    formatSpec = '%f%f%f%f%f%f%f%f%f';
    f = fopen(filename);
    detections = textscan(f,formatSpec);
    fclose(f);
elseif strcmp(mode,'CNNc')
    datapath = strcat('../data/network_C/',set,'/',sequence,'/');
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
imgpath = strcat('../../kittiTracking/',set,'/','image_02/',sequence,'/');
%detections = textread(filename); % frame, size_x, size_y, class, cx, cy, w, h, conf
%Z = cell(size(detections,1),5);
Z = cell(1);
if(strcmp(mode,'CNN'))
oldFrame = detections{1}(1)+1;
count = 1;
    Z{1}(:,1) = [detections{5}(1);detections{6}(1);detections{7}(1);detections{8}(1);detections{9}(1);detections{4}(1)]; % cx
    for i = 2 : size(detections{1},1)
        frame = detections{1}(i)+1;
        if(frame == oldFrame)
            Z{frame}(:,count+1) = [detections{5}(i);detections{6}(i);detections{7}(i);detections{8}(i);detections{9}(i);detections{4}(i)]; % cx
            count = count + 1;
            oldFrame = frame;
        else
            Z{frame}(:,1) = [detections{5}(i);detections{6}(i);detections{7}(i);detections{8}(i);detections{9}(i);detections{4}(i)]; % cx
            count = 1;
            oldFrame = frame;  
        end
    end
elseif strcmp(mode,'CNNc') 
    oldFrame = detections{1}(1)+1;
    count = 1;
    Z{1}(:,1) = [mean([detections{5}(1) detections{7}(1)]);mean([detections{6}(1) detections{8}(1)]);...
        detections{7}(1)-detections{5}(1);detections{8}(1)-detections{6}(1);detections{9}(1);detections{4}(1)]; % cx
    for i = 2 : size(detections{1},1)
        frame = detections{1}(i)+1;
        if(frame == oldFrame)
            Z{frame}(:,count+1) = [mean([detections{5}(i) detections{7}(i)]);mean([detections{6}(i) detections{8}(i)]);...
                                    detections{7}(i)-detections{5}(i);detections{8}(i)-detections{6}(i);detections{9}(i);detections{4}(i)];
            count = count + 1;
            oldFrame = frame;
        else
            Z{frame}(:,1) = [mean([detections{5}(i) detections{7}(i)]);mean([detections{6}(i) detections{8}(i)]);...
                            detections{7}(i)-detections{5}(i);detections{8}(i)-detections{6}(i);detections{9}(i);detections{4}(i)];
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
    if(strcmp(motionModel,'ca'))
        Z = generateGT(set,sequence,datapath, 4);
    else
        Z = generateGT(set,sequence,datapath, nbrPosStates);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Initiate cells %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Motion model and covariance matrix %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(mode,'GT')
    FOVsize = [0,0;1242,375]; % in m
else
    FOVsize = [0,0;detections{3}(1),detections{2}(1)]; % in m
end

if strcmp(motionModel,'cv')
        nbrStates = 4; % Total number of states
        if nbrPosStates == 4
            nbrMeasStates = 2; % Number of measurements used for weighting
        elseif nbrPosStates == 6
            nbrMeasStates = 3;
        end
elseif strcmp(motionModel,'ca')
        nbrStates = 6; % Total number of states
        nbrMeasStates = 2;
elseif strcmp(motionModel,'caBB')
    nbrStates = 8; % Total number of states
    nbrMeasStates = 2;
elseif strcmp(motionModel,'cvBB')
    nbrStates = 6;
    if nbrPosStates == 4
        nbrMeasStates = 2; % Number of measurements used for weighting
    elseif nbrPosStates == 6
        nbrMeasStates = 3;
    end
end

T = 0.1; % sampling time, 1 fps
sigmaQ = 35;         % Process (motion) noise % 20 ok1 || 24 apr 10
sigmaBB = 2;
if strcmp(mode,'GT')
    global sigmaQ
    sigmaQ = 35; % 2 seems ok, 19/23may! % 5!        % Process (motion) noise % 20 ok1 || 24 apr 10
    global sigmaBB
    sigmaBB = 2;
elseif strcmp(mode,'CNN')
    global sigmaQ
    sigmaQ = 35; % 5!        % Process (motion) noise % 20 ok1 || 24 apr 10
    global sigmaBB
    sigmaBB = 2;
elseif strcmp(mode,'CNNc')
    global sigmaQ
    sigmaQ = 35; % 5!        % Process (motion) noise % 20 ok1 || 24 apr 10
    global sigmaBB
    sigmaBB = 2;
else
    disp('Not implemented')
end

dInit = [0 20];
[F, Q] = generateMotionModel(sigmaQ, T, motionModel, nbrPosStates, sigmaBB);
if strcmp(motionModel,'cv')
    %Q = Q + 25*diag([1.2 1 0 0]); % 10
    if nbrPosStates == 4
        Q = Q + 0.15*diag([FOVsize(2,1), 1.2*FOVsize(2,2), 0 0]);
        %F(3,3) = 1.5*F(3,3);
        %F(4,4) = 1.5*F(4,4);
    elseif nbrPosStates == 6
        Q = Q + 0.1*diag([FOVsize(2,1), FOVsize(2,2), 10*dInit(2) 0 0 0]);
    end
elseif strcmp(motionModel,'ca')
    %Q = Q + 25*diag([1.2 1 0 0]); % 10
        %Q = Q + 0.1*diag([FOVsize(2,1), FOVsize(2,2), 10*dInit(2) 0 0 0]);
    %Q = Q + 100*diag([1.3 1.2 0 0 0 0])
    Q = Q + 100*diag([1.3 1.1 0.1 0.1 0 0])
elseif strcmp(motionModel,'caBB')
    %Q = Q + 25*diag([1.2 1 0 0]); % 10
        %Q = Q + 0.1*diag([FOVsize(2,1), FOVsize(2,2), 10*dInit(2) 0 0 0]);
    %Q = Q + 100*diag([1.3 1.2 0 0 0 0])
    Q = Q + 100*diag([1.3 1.1 0.1 0.1 0 0 0 0])
elseif strcmp(motionModel, 'cvBB')
    %Q = Q + 25*diag([1.2 1 0 0 0 0]); % 10
    if nbrPosStates == 4
        Q = Q + 0.1*diag([FOVsize(2,1), FOVsize(2,2), 0 0 0 0]);
        %Q = Q + 0.05*diag([FOVsize(2,1), FOVsize(2,2), 0 0 0 0]); % 0.1 seems good! 0.15
        %F(3,3) = 1.1*F(3,3);
        %F(4,4) = 1.1*F(4,4);
    elseif nbrPosStates == 6
        Q = Q + 0.1*diag([FOVsize(2,1), FOVsize(2,2), 10*dInit(2) 0 0 0 0 0]);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Measurement model and covariance matrix %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global R
if ((strcmp(motionModel,'cv')) && (nbrPosStates == 4))
    R = 0.1*eye(2);
elseif((strcmp(motionModel,'ca')) && (nbrPosStates == 4))
    R = 0.1*eye(2);
    %R(3,3) = 70;
    %R(4,4) = 70;
elseif((strcmp(motionModel,'caBB')))
    R = 0.1*eye(4);
elseif ((strcmp(motionModel,'cvBB')) && (nbrPosStates == 4))
    R = 0.1*eye(4);    % Measurement noise % 0.01 ok1 || 0.001
elseif ((strcmp(motionModel,'cv')) && (nbrPosStates == 6))
    R = 0.1*eye(3);    % Measurement noise % 0.01 ok1 || 0.001
    %R(3,3) = 5;
elseif ((strcmp(motionModel,'cvBB')) && (nbrPosStates == 6))
    R = 0.1*eye(5);    % Measurement noise % 0.01 ok1 || 0.001
    %R(3,3) = 5;
end
%R = 4*R;
if(strcmp(mode,'nonlinear'))
    h = {'distance','angle'};
    H = generateMeasurementModel(h,'nonlinear',nbrPosStates, motionModel);
elseif(strcmp(mode,'CNN')) || strcmp(mode,'CNNc')
    H = generateMeasurementModel({},'linear',nbrPosStates, motionModel);
elseif(strcmp(mode,'GT'))
    if(strcmp(motionModel,'ca'))
        H = generateMeasurementModel({},'linear',6, motionModel);
    else
        H = generateMeasurementModel({},'linear',nbrPosStates, motionModel);
    end
end
global Pd, global Ps, global c
Pd = 0.95;   % Detection probability 
Ps = 0.99;   % Survival probability % 0.98 ok1
c = 0.001;    % clutter intensity 

global nbrStates
global nbrMeasStates
if strcmp(motionModel,'cv')
        nbrStates = 4; % Total number of states
        if nbrPosStates == 4
            nbrMeasStates = 2; % Number of measurements used for weighting
        elseif nbrPosStates == 6
            nbrMeasStates = 3;
        end
            
    elseif strcmp(motionModel,'cvBB')
        nbrStates = 6;
        if nbrPosStates == 4
            nbrMeasStates = 2; % Number of measurements used for weighting
        elseif nbrPosStates == 6
            nbrMeasStates = 3;
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Thresholds and Murty %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Threshold existence probability keep for next iteration
global threshold
threshold = 1e-3;    % 0.01 ok1
% Threshold existence probability use estimate
global thresholdEst
thresholdEst = 0.4; % 0.6 ok1
% Threshold weight undetected targets keep for next iteration
global poissThresh
poissThresh = 1e-5;
% Murty constant
global Nhconst
Nhconst = 100; 
% Max nbr of globals for each old global
maxKperGlobal = 20;
% Max nbr globals to pass to next iteration
maxNbrGlobal = 50; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Births %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% boarder width with higher probability of birth
boarderWidth = 0.1*FOVsize(2,1);
boarder = [0, FOVsize(2,1)-boarderWidth;
    boarderWidth, FOVsize(2,1)];
% Percentage of births within boarders
pctWithinBoarder = 0.2;
% Weight of the births
weightBirth = 1;
% Number of births
nbrOfBirths = 200; % 600 ok1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Initial births %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PbirthFunc
PbirthFunc = diag([0.2*FOVsize(2,1) 0.2*FOVsize(2,2)]);
vinit = 0;
nbrInitBirth = 3000; % 600 ok1
global covBirth;
covBirth = 20; % 20 ok1
wInit = 1e-2;%0.7;%0.2;  

FOVinit = FOVsize;+50*[-1 -1;
                    1 1];
XmuUpd = cell(1);
XuUpd = cell(1);
% TODO: Should the weights be 1/nbrInitBirth?
if ~uniformBirths
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
elseif strcmp(motionModel,'ca')
    for i = 1:nbrInitBirth
        XmuUpd{1}(i).w = wInit;    % Pred weight
        XmuUpd{1}(i).state = [unifrnd(FOVinit(1,1), FOVinit(2,1)), ...
            unifrnd(FOVinit(1,2), FOVinit(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),...
            unifrnd(-2,2), unifrnd(2,2)]';      % Pred state
        XmuUpd{1}(i).P = covBirth*eye(6);      % Pred cov

        XuUpd{1}(i).w = wInit;    % Pred weight
        XuUpd{1}(i).state = [unifrnd(FOVinit(1,1), FOVinit(2,1)), ...
            unifrnd(FOVinit(1,2), FOVinit(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),...
            unifrnd(-2,2), unifrnd(2,2)]';      % Pred state
        XuUpd{1}(i).P = covBirth*eye(6);      % Pred cov
    end
elseif strcmp(motionModel,'caBB')
    for i = 1:nbrInitBirth
        XmuUpd{1}(i).w = wInit;    % Pred weight
        XmuUpd{1}(i).state = [unifrnd(FOVinit(1,1), FOVinit(2,1)), ...
            unifrnd(FOVinit(1,2), FOVinit(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),...
            unifrnd(-2,2), unifrnd(2,2) 0 0]';      % Pred state
        XmuUpd{1}(i).P = covBirth*eye(8);      % Pred cov

        XuUpd{1}(i).w = wInit;    % Pred weight
        XuUpd{1}(i).state = [unifrnd(FOVinit(1,1), FOVinit(2,1)), ...
            unifrnd(FOVinit(1,2), FOVinit(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),...
            unifrnd(-2,2), unifrnd(2,2) 0 0]';      % Pred state
        XuUpd{1}(i).P = covBirth*eye(8);      % Pred cov
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
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save everything in simVariables and load at the begining of the filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save('simVariables','R','T','FOVsize','R','F','Q','H','Pd','Ps','c','threshold',...
    'poissThresh','vinit','thresholdEst','covBirth','boarder','pctWithinBoarder',...
    'weightBirth','motionModel','nbrPosStates','nbrStates','nbrMeasStates','dInit');