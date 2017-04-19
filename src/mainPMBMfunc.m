clear Xest
clear Pest
clc

%%%%%% Load Detections %%%%%%
% Training 0016 and testing 0001
set = 'training';
sequence = '0000';
datapath = strcat('../data/tracking/',set,'/',sequence,'/');
filename = [datapath,'inferResult.txt'];
formatSpec = '%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
detections = textscan(f,formatSpec);
fclose(f);

%detections = textread(filename); % frame, size_x, size_y, class, cx, cy, w, h, conf
%Z = cell(size(detections,1),5);
Z = cell(1);
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

%%%%%% Inititate %%%%%%
sigmaQ = 70;         % Process (motion) noise
R = 0.01*[1 0;0 1];    % Measurement noise
T = 0.1; % sampling time, 1/fps
FOVsize = [0,0;detections{3}(1),detections{2}(1)]; % in m
 
% Assume constant
Pd = 0.7;   % Detection probability
Ps = 0.99;   % Survival probability
c = 0.005;    % clutter intensity
 
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
nbrInitBirth = 400;
covBirth = 20;
 
% TODO: Should the weights be 1/nbrInitBirth?
for i = 1:nbrInitBirth
    XmuUpd{1}(i).w = 1/nbrInitBirth;    % Pred weight
    XmuUpd{1}(i).state = [unifrnd(-FOVsize(1,1), FOVsize(2,1)), ...
        unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';      % Pred state
    XmuUpd{1}(i).P = covBirth*eye(4);      % Pred cov
    
    XuUpd{1}(i).w = 1;    % Pred weight
    XuUpd{1}(i).state = [unifrnd(-FOVsize(1,1), FOVsize(2,1)), ...
        unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';      % Pred state
    XuUpd{1}(i).P = covBirth*eye(4);      % Pred cov
end

Xupd = cell(1);

%%%%%% INITIATE %%%%%%

threshold = 0.01;    % CHANGED 0.1
thresholdEst = 0.45;
poissThresh = 1e-5;

Nhconst = 100;
nbrOfBirths = 400;
maxKperGlobal = 20;
maxNbrGlobal = 100;

% Save everything in simVariables and load at the begining of the filter

save('simVariables','R','T','FOVsize','R','F','Q','H','Pd','Ps','c','threshold','poissThresh','vinit','thresholdEst','covBirth');

% For birth case
% ind = 1;
% for i = 1 : size(z,2)
%     if(~isempty(z{i}))
%         Z{ind} = z{i};
%         ind = ind + 1;
%     end
% end

K = 20; %size(Z,2); % Length of sequence

T = 1; % Nbr of simulations

nbrMissmatch = zeros(1,T);

startTime = tic;
for t = 1:T
    disp('-------------------------------------')
    disp(['--------------- t = ', num2str(t), ' ---------------'])
    disp('-------------------------------------')
    
    %Z = measGenerateCase2(X, R, FOVsize, K);
    [XuUpd{t,1}, Xupd{t,1}, Xest{t,1}, Pest{t,1}, rest{t,1}, west{t,1}] = ...
        PMBMinitFunc(Z{t,1}, XmuUpd{t,1}, XuUpd{t,1}, nbrOfBirths, maxKperGlobal, maxNbrGlobal);
    for k = 2:K % For each time step
        disp(['--------------- k = ', num2str(k), ' ---------------'])
        Nh = Nhconst*size(Z{k},2);    %Murty
%         if k == 25
%             keyboard
%         end
        [XuUpd{t,k}, Xpred{t,k}, Xupd{t,k}, Xest{t,k}, Pest{t,k}, rest{t,k}, west{t,k}] = ...
            PMBMfunc(Z{t,k}, XuUpd{t,k-1}, Xupd{t,k-1}, Nh, nbrOfBirths, maxKperGlobal, maxNbrGlobal,k);

%        disp(['Nbr targets: ', num2str(size(X{t,k},2))])
        disp(['Nbr measurements: ', num2str(size(Z{k},2))])
        disp(['Nbr estimates: ', num2str(size(Xest{t,k},2))])
        disp(['Nbr prop targets: ', num2str(sum(rest{t,k} == 1))])
%        disp(['Nbr clutter points: ', num2str(size(Z{k},2)-size(X{k},2))])
        frameNbr = sprintf('%06d',k-1);
        plotDetections(set, sequence, frameNbr, Xest{k})
        pause(0.5)
    end
    
end
simTime = toc(startTime);

disp('--------------- Simulation Complete ---------------')
disp(['Total simulation time: ', num2str(simTime)])
    
%% Plot

figure;
for k = 1:K
    frameNbr = sprintf('%06d',k-1);
    plotDetections(set, sequence, frameNbr, Xest{k})
    pause(0.5)
end


    