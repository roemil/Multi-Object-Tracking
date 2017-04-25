function [nbrInitBirth, wInit, FOVinit, vinit, covBirth, Z, nbrOfBirths, maxKperGlobal, maxNbrGlobal, Nhconst] ...
    = declareVariables(mode, set, sequence)

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

%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Inititate %%%%%%
sigmaQ = 25;         % Process (motion) noise % 20 ok1 || 24 apr 10
R = 0.1*[1 0;0 1];    % Measurement noise % 0.01 ok1 || 0.001

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
[F, Q] = generateMotionModel(sigmaQ, T, 'cv');

if(strcmp(mode,'nonlinear'))
    h = {'distance','angle'};
    H = generateMeasurementModel(h,'nonlinear');
elseif(strcmp(mode,'linear'))
    H = generateMeasurementModel({},'linear');
elseif(strcmp(mode,'GT'))
    H = generateMeasurementModel({},'linear');
end

% Add cov on pos?? 
%Q = Q + 25*diag([1.2 1 0 0]); % 10
Q = Q + 0.1*diag([FOVsize(2,1), FOVsize(2,2), 0, 0]);

vinit = 0;
nbrInitBirth = 2000; % 600 ok1
covBirth = 20; % 20 ok1
wInit = 1;%0.2;

FOVinit = FOVsize;%+50*[-1 -1;
                   % 1 1];
                   
                   %%%%%% INITIATE %%%%%%
% Threshold existence probability keep for next iteration
threshold = 1e-3;    % 0.01 ok1
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
pctWithinBoarder = 0.3;
% Weight of the births
weightBirth = 1;

% Save everything in simVariables and load at the begining of the filter
save('simVariables','R','T','FOVsize','R','F','Q','H','Pd','Ps','c','threshold',...
    'poissThresh','vinit','thresholdEst','covBirth','boarder','pctWithinBoarder',...
    'weightBirth');