function [nbrInitBirth, wInit, FOVinit, vinit, covBirth, Z, nbrOfBirths, ...
    maxKperGlobal, maxNbrGlobal, Nhconst, XmuUpd, XuUpd, FOVsize] ...
    = declareVariables(mode, set, sequence, motionModel, nbrPosStates)

global egoMotionOn
global simMeas
global color;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Load Detections %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Training 0016 and testing 0001
if(strcmp(mode,'CNNnonlinear')) && ~simMeas
    datapath = strcat('../data/tracking_dist/',set,'/',sequence);
    filename = [datapath,'.txt'];
    formatSpec = '%f%f%f%f%f%f%f%f%f%f';
    f = fopen(filename);
    detections = textscan(f,formatSpec);
    fclose(f);
elseif(strcmp(mode,'GT')) || (strcmp(mode,'GTnonlinear')) || simMeas
    datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
end

%detections = textread(filename); % frame, size_x, size_y, class, cx, cy, w, h, conf
%Z = cell(size(detections,1),5);
Z = cell(1);
if (strcmp(mode,'CNNnonlinear')) && ~simMeas
    oldFrame = detections{1}(1)+1;
    count = 1;
    Z{1}(:,1) = [detections{5}(1);detections{6}(1);detections{10}(1);detections{7}(1);detections{8}(1);detections{4}(1)]; % cx
    for i = 2 : size(detections{1},1)
        frame = detections{1}(i)+1;
        %if detections{9}(i) > 0.85
            if(frame == oldFrame)
                Z{frame}(:,count+1) = [detections{5}(i);detections{6}(i);detections{10}(i);detections{7}(i);detections{8}(i);detections{4}(i)]; % cx
                count = count + 1;
            else
                Z{frame}(:,1) = [detections{5}(i);detections{6}(i);detections{10}(i);detections{7}(i);detections{8}(i);detections{4}(i)]; % cx
                count = 1;
            end
            oldFrame = frame;
        %end 
    end
elseif(strcmp(mode,'GT')) || (strcmp(mode,'GTnonlinear') && ~simMeas) 
    Z = generateGT(set,sequence,datapath, nbrPosStates);
elseif simMeas
    Ztmp = generateGT(set,sequence,datapath, nbrPosStates);
    %Z = cell(size(Ztmp,2));
    % This uses a distance uncertainty similar to Autoliv system
    %measP = @(d) diag([3 3 (0.161*d/1.959964)^2 5 5]); % Set cov of measurements here
    % This uses a lower distance uncertainty
    measP = @(d) diag([5 5 (0.161*d/1.959964)^2 40 40]); % Set cov of measurements here
    for k = 1:size(Ztmp,2)
        ind = 1;
        if ~isempty(Ztmp{k})
            for i = 1:size(Ztmp{k},2)
                detectRnd = unifrnd(0,1);
                if detectRnd < 1 % Set missdetection rate here
                    Z{k}(1:5,ind) = max(0, Ztmp{k}(1:5,i) + mvnrnd(zeros(5,1),measP(Ztmp{k}(3,i)))');
                    Z{k}(6,ind) = Ztmp{k}(6,i);
                    ind = ind+1;
                end
            end
        else
            Z{k} = [];
        end
    end
end

P2path = strcat('../../data_tracking_calib/',set,'/','calib/',sequence,'.txt');

global P2;
P2 = readCalibration(P2path,2);
% P2 =[7.215377e+02 0.000000e+00 6.095593e+02 4.485728e+01;
%     0.000000e+00 7.215377e+02 1.728540e+02 2.163791e-01; 
%     0.000000e+00 0.000000e+00 1.000000e+00 2.745884e-03];

if egoMotionOn
    base_dir = strcat('../../kittiTracking/data_tracking_oxts/',set);
    filenameIMU = [base_dir,sequence,'.txt'];
    seq = str2num(sequence)+1;
    oxts = loadOxtsliteData(base_dir,seq:seq);
    global pose
    global angles
    [pose, angles, posAcc] = egoPosition(oxts);
    
    % imu to velo
%     imu_velo = strcat('../../data_tracking_calib/calib2/calib_imu_to_velo.txt');
%     fid = fopen(imu_velo);
%     C = textscan(fid,'%s %f %f %f %f %f %f %f %f %f %f %f %f');
%     for i=0:11
%     tr_imu_velo(floor(i/4)+1,mod(i,4)+1) = C{i+2}(6);
%     end
%     fclose(fid);
    RimuToVelo = [9.999976e-01 7.553071e-04 -2.035826e-03;
        -7.854027e-04 9.998898e-01 -1.482298e-02;
        2.024406e-03 1.482454e-02 9.998881e-01];
    tImuToVelo = [-8.086759e-01 3.195559e-01 -7.997231e-01]';
    global TimuToVelo
    TimuToVelo = [RimuToVelo, tImuToVelo; 0 0 0 1];
    global TveloToImu
    TveloToImu = inv(TimuToVelo);
    
    RveloToCam = [6.927964e-03 -9.999722e-01 -2.757829e-03;
        -1.162982e-03 2.749836e-03 -9.999955e-01;
        9.999753e-01 6.931141e-03 -1.143899e-03];
    tVeloToCam = [-2.457729e-02 -6.127237e-02 -3.321029e-01]';
    global TveloToCam
    TveloToCam = [RveloToCam, tVeloToCam; 0 0 0 1];
    global TcamToVelo
    TcamToVelo = inv(TveloToCam);
    
    R02 = [9.999838e-01 -5.012736e-03 -2.710741e-03;
        5.002007e-03 9.999797e-01 -3.950381e-03;
        2.730489e-03 3.936758e-03 9.999885e-01];
    t02 = [5.989688e-02 -1.367835e-03 4.637624e-03]';
    global T02
    T02 = [R02, t02; 0 0 0 1];
    global T20
    T20 = inv(T02);
end

if(color)
    global imgpath;
    imgpath = strcat('../../kittiTracking/',set,'/','image_02/',sequence,'/');
end;

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

global FOVsize
if strcmp(mode,'GT') || (strcmp(mode,'GTnonlinear')) || simMeas
    FOVsize = [0,0;1242,375]; % in m
elseif strcmp(mode,'CNNnonlinear')
    FOVsize = [0,0;detections{3}(1),detections{2}(1)]; % in m
end

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

global T
T = 0.1; % sampling time, 1 fps
if strcmp(mode,'GTnonlinear')
    global sigmaQ
    sigmaQ = 7; % 2 seems ok, 19/23may! % 5!        % Process (motion) noise % 20 ok1 || 24 apr 10
    global sigmaBB
    sigmaBB = 10;
elseif strcmp(mode,'CNNnonlinear')
    global sigmaQ
    sigmaQ = 5; % 5!        % Process (motion) noise % 20 ok1 || 24 apr 10
    global sigmaBB
    sigmaBB = 10;
else
    disp('Not implemented')
end
dInit = [0 20];
global F
global Q
[F, Q] = generateMotionModel(sigmaQ, T, motionModel, nbrPosStates, sigmaBB);

% if strcmp(motionModel, 'cvBB')
%     if nbrPosStates == 4
%         Q = Q + 0.05*diag([FOVsize(2,1), FOVsize(2,2), 0 0 0 0]); % 0.1 seems good! 0.15
%     elseif nbrPosStates == 6
%         %Q = Q + diag([0.3, 0.3, 0.5 0 0 0 0 0]);
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Measurement model and covariance matrix %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global R
global H
global H3dTo2d
global H3dFunc
global R3dTo2d
global Hdistance
global Rdistance
global Jh

if strcmp(mode,'GTnonlinear') || strcmp(mode,'CNNnonlinear')    
    % Including BB
    H3dTo2d = [P2(:,1:3), zeros(3,5), P2(:,4); zeros(2,6), eye(2), zeros(2,1)];
    H3dFunc = @(x) (H3dTo2d(1:2,1:8)*x + H3dTo2d(1:2,9))./(x(3,:)+H3dTo2d(3,9));
    
    Hdistance = @(x) sqrt(x(1,:).^2+x(2,:).^2+x(3,:).^2);
    %Rdistance = @(x) (0.161*sqrt(x(1)^2+x(2)^2+x(3)^2)/1.959964)^2;
    % If EKF
    %Jh = @(x) [x(1)/sqrt(x(1)^2 + x(2)^2 + x(3)^2), x(2)/sqrt(x(1)^2 + x(2)^2 + x(3)^2), x(3)/sqrt(x(1)^2 + x(2)^2 + x(3)^2), zeros(1,3)];
    
    if egoMotionOn
        Hcam = @(x) [H3dFunc(x); Hdistance(x)];
        
        % global IMU -> local IMU -> local velo -> local cam0 -> local cam2
        %H = @(x,egoPos) Hcam([R02*(RveloToCam*(RimuToVelo*(x(1:3,:) - egoPos)+TimuToVelo)+TveloToCam) + T02;
        %    -x(5,:); -x(6,:); x(4,:); x(7:8,:)]);
        
        % Without ego-rotation
%         H = @(x,egoPos) Hcam([T02(1:3,:)*(TveloToCam*(TimuToVelo*[(x(1:3,:) - egoPos);ones(1,size(x,2))]));
%             -x(5,:); -x(6,:); x(4,:); x(7:8,:)]);
        
        % From local IMU to rotated camera 2 coordinates. Rotate velo
        % according to rotation matrices
        % MOST RECENT ONE!!! only yaw!
        HtoRotCamCoords = @(x,heading) Hcam([T02(1:3,:)*(TveloToCam*(TimuToVelo*...
                  [[cos(heading), sin(heading); -sin(heading) cos(heading)]*x(1:2,:); ...
                  x(3,:); ones(1,size(x,2))]));
                  [-sin(heading), cos(heading)]*(-x(4:5,:));...
                  -x(6,:);
                  [cos(heading), sin(heading)]*(x(4:5,:));...
                  x(7:8,:)]);
        
%         HtoRotCamCoords = @(x,heading) Hcam([T02(1:3,:)*(TveloToCam*(TimuToVelo*...
%               [[cos(heading), sin(heading); -sin(heading) cos(heading)]*x(1:2,:); ...
%               x(3,:); ones(1,size(x,2))]));
%               cos(heading)*(-x(5,:));...
%               -x(6,:);
%               cos(heading)*(x(4,:));...
%               x(7:8,:)]);
        H = @(x,egoPos,heading) HtoRotCamCoords([x(1:3,:)-egoPos; x(4:end,:)], heading);
        
        % FULL ROTATION MATRIX. Might be slightly more accurate, but more
        % tedious. However pitch and roll are small
%         Rx = @(roll) [1 0 0; 0 cos(roll) sin(roll); 0 -sin(roll) cos(roll)];
%         Ry = @(pitch) [cos(pitch) 0 -sin(pitch); 0 1 0; sin(pitch) 0 cos(pitch)]; 
%         Rz = @(yaw)[cos(yaw) sin(yaw) 0; -sin(yaw) cos(yaw) 0; 0 0 1];
%         Rrot = @(roll, pitch, yaw) Rz(yaw)*Ry(pitch)*Rx(roll);
%         RrotRow = @(Rrot,i) Rrot(i,:);
%         HtoRotCamCoords = @(x,angles,k) Hcam([T02(1:3,:)*(TveloToCam*(TimuToVelo*...
%                         [Rrot(angles{k}.roll-angles{1}.roll, angles{k}.pitch-angles{1}.pitch, ...
%                         angles{k}.heading-angles{1}.heading)*x(1:3,:); ones(1,size(x,2))]));
%                         -RrotRow(Rrot(angles{k}.roll-angles{1}.roll, angles{k}.pitch-angles{1}.pitch, ...
%                         angles{k}.heading-angles{1}.heading),2)*(x(4:6,:));...
%                         -RrotRow(Rrot(angles{k}.roll-angles{1}.roll, angles{k}.pitch-angles{1}.pitch, ...
%                         angles{k}.heading-angles{1}.heading),3)*(x(4:6,:));
%                         RrotRow(Rrot(angles{k}.roll-angles{1}.roll, angles{k}.pitch-angles{1}.pitch, ...
%                         angles{k}.heading-angles{1}.heading),1)*(x(4:6,:));...
%                         x(7:8,:)]);
%         H = @(x,egoPos,angles,k) HtoRotCamCoords([x(1:3,:)-egoPos; x(4:end,:)], angles,k);
    else
        H = @(x) [H3dFunc(x); Hdistance(x)];
    end
end

if strcmp(mode,'GTnonlinear')
    %R3dTo2d = diag([15 15 15 5 5]);
    R3dTo2d = diag([25 25 15 15 15]); %*2
    Rdistance = @(x) (0.161*x/1.959964)^2; % *2
    %R3dTo2d = diag([0.1*1242 0.3*375 15 50 25]); %*2
    %Rdistance = @(x) max(4,(0.161*x/1.959964)^2); % *2
    if egoMotionOn
        Rcam = @(x)[R3dTo2d(1:2,1:2), zeros(2,1); zeros(1,2), Rdistance(x)];
        R = @(x) Rcam(x);
        
        % If Rdist is dep. on object state instead of dist. measurement
        %RtoRotCamCoords = @(x,heading) Rcam([T02(1:3,:)*(TveloToCam*(TimuToVelo*...
        %   [([sqrt(x(1,:).^2+x(2,:).^2).*[cos(-heading+atan(x(2,:)./x(1,:))); ...
        %   sin(-heading+atan(x(2,:)./x(1,:)))]; x(3,:)]); ones(1,size(x,2))]));
        %   -sqrt(x(5,:).^2+x(6,:).^2).*[cos(heading+atan(x(2,:)./x(1,:))); ...
        %   sin(heading+atan(x(2,:)./x(1,:)))]; ...
        %            x(4,:); x(7:8,:)]);
        %R = @(x,egoPos,heading) RtoRotCamCoords([x(1:3,:)-egoPos; x(4:end,:)], heading);
    else
        R = @(x)[R3dTo2d(1:2,1:2), zeros(2,1); zeros(1,2), Rdistance(x)];
    end
elseif strcmp(mode,'CNNnonlinear')
    R3dTo2d = diag([170 120 25 40 40]);
    %Rdistance = @(x) (0.161*sqrt(x(1)^2+x(2)^2+x(3)^2)/1.959964)^2;
    Rdistance = @(x) (0.161.*x./1.959964).^2;
    %Rdistance = @(x) 5;
    if egoMotionOn
        Rcam = @(x)[R3dTo2d(1:2,1:2), zeros(2,1); zeros(1,2), Rdistance(x)];
        R = @(x) Rcam(x);
    else
        R = @(x)[R3dTo2d(1:2,1:2), zeros(2,1); zeros(1,2), Rdistance(x)];
    end
end

if strcmp(mode,'GTnonlinear')
    global Pd
    Pd = 0.95;   % Detection probability % 0.7 ok1
    global Ps
    Ps = 0.99;   % Survival probability % 0.98 ok1
    global c
    c = 1e-7;    % clutter intensity % 0.00001
elseif strcmp(mode,'CNNnonlinear')
    global Pd
    Pd = 0.95;   % Detection probability % 0.7 ok1
    global Ps
    Ps = 0.99;   % Survival probability % 0.98 ok1
    global c
    c = 1e-7;    % clutter intensity % 0.00001
else
    disp('Pd not implemented for this mode')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Thresholds and Murty %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Threshold existence probability keep for next iteration
threshold = 1e-3;    % 0.01 ok1
% Threshold existence probability use estimate
thresholdEst = 0.4; % 0.6 ok1
% Threshold weight undetected targets keep for next iteration
poissThresh = 1e-5;
% Murty constant
Nhconst = 4;
% Max nbr of globals for each old global
maxKperGlobal = 20;
% Max nbr globals to pass to next iteration
maxNbrGlobal = 50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Births %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Tuned for GT
if strcmp(mode,'GTnonlinear')
    global angleThresh
    angleThresh = 30*pi/180;
    global distThresh
    distThresh = 10;
    global distThresh2
    distThresh2 = 7;
    global PbirthFunc
    PbirthFunc = @(x) diag([0.4*FOVsize(2,1) 0.4*FOVsize(2,2) Rdistance(x)]);
    global PinitVeloClose
    PinitVeloClose = 200;
    global PinitVeloFar
    PinitVeloFar = 1;
    global PinitBBsize
    PinitBBsize = diag([20 20]);
    global rescaleFact
    rescaleFact = 1;
elseif strcmp(mode,'CNNnonlinear')
    % Old values 
%     global angleThresh
%     angleThresh = 30*pi/180;
%     global distThresh
%     distThresh = 10;
%     global distThresh2
%     distThresh2 = 7;
%     global PbirthFunc
%     PbirthFunc = @(x) 2.6*diag([0.4*FOVsize(2,1) 0.4*FOVsize(2,2) 0.6*Rdistance(x)]);
%     global PinitVeloClose
%     PinitVeloClose = 350;
%     global PinitVeloFar
%     PinitVeloFar = 2;
%     global PinitBBsize
%     PinitBBsize = diag([20 20]);
%     global rescaleFact
%     rescaleFact = 1;
    
    % Test
    global angleThresh
    angleThresh = 30*pi/180;
    global distThresh
    distThresh = 10;
    global distThresh2
    distThresh2 = 7;
    global PbirthFunc
    PbirthFunc = @(x) diag([0.4*FOVsize(2,1) 0.4*FOVsize(2,2) Rdistance(x)]);
    global PinitVeloClose
    PinitVeloClose = 350;
    global PinitVeloFar
    PinitVeloFar = 2;
    global PinitBBsize
    PinitBBsize = diag([20 20]);
    global rescaleFact
    rescaleFact = 1;
    
    % Use function instead of just 2 values? 
    %global Ptest
    %slope = -10;
    %startInd = 10;
    %Ptest = @(x) max(1,min(PinitVeloClose,slope*(x-startInd)+PinitVeloClose));
end


% boarder width with higher probability of birth
boarderWidth = 0.1*FOVsize(2,1);
boarder = [0, FOVsize(2,1)-boarderWidth;
    boarderWidth, FOVsize(2,1)];
% Percentage of births within boarders
pctWithinBoarder = 0.2;
% Weight of the births
global weightBirth
weightBirth = 1;
% Number of births
if strcmp(mode,'GTnonlinear')
    global nbrOfBirths
    nbrOfBirths = 300; % 200
elseif strcmp(mode,'CNNnonlinear')
    global nbrOfBirths
    nbrOfBirths = 300; % 400
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Initial births %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global vinit
vinit = 0;
global covBirth
if strcmp(motionModel,'cvBB') && strcmp(mode,'GTnonlinear')
    nbrInitBirth = 400; % 800
    if ~egoMotionOn
        covBirth = 0.5*diag([1 0.5 1 2 1 2 20 20]); %*0.5
    else
        %covBirth = 1*diag([1 1 0.5 2 2 1 20 20]); %0.1
        covBirth = 2*diag([1 1 1 4 4 4 20 20]); %0.1 2*Q
        covBirth(7:8,7:8) = diag([20 20]);
        %covMax = diag([2 2 2 4 4 4 20 20]);
        %dMax = 20;
        %covBirth = @(d) covMax./(max(1,dMax-d));
    end
    
elseif strcmp(motionModel,'cvBB') && strcmp(mode,'CNNnonlinear')
    nbrInitBirth = 400; % 800
    if ~egoMotionOn
        covBirth = 0.5*diag([1 0.5 1 2 1 2 20 20]); %*0.5
    else
        %covBirth = 1*diag([1 1 0.5 2 2 1 20 20]); %0.1
        covBirth = 4*diag([0.8 0.8 1 50 50 50 20 20]); %0.1 2*Q
        covBirth(7:8,7:8) = diag([20 20]);
    end
end
global wInit
wInit = 0.001;%0.005, 0.001 even better

FOVinit = FOVsize;+50*[-1 -1;
                    1 1];

global FOV
                % from findFOV
% FOV = [-45 -2 -5;
%     45 3 150];

FOV = [-45 -2 0;
    45 2.6 150];
%FOV = [-45 -2 0;
%    45 2.6 20];

global maxX
maxX = 1e6; % 50
global maxY
maxY = 1e6; %3.5
global Zinter
Zinter = 16;
global xAngle
xAngle = 41; %43 50-55, 65. 75
global yAngle
yAngle = 14; % 16
                
XmuUpd = cell(1);
XuUpd = cell(1);
% TODO: Should the weights be 1/nbrInitBirth?

if strcmp(motionModel,'cvBB') && (strcmp(mode,'GTnonlinear') || strcmp(mode,'CNNnonlinear'))
    global uniformBirths
    if uniformBirths
        XmuUpd{1} = [];
        XuUpd{1} = [];
    else
        if egoMotionOn
            heading = angles{1}.heading-angles{1}.heading;
        end
        for i = 1:ceil(nbrInitBirth/5)
            Zrnd = unifrnd(FOV(1,3), Zinter); % TODO: True angle of view?
            Xrange = min(maxX, Zrnd*tand(xAngle)); % 45? 40.6
            Yrange = min(maxY, Zrnd*tand(yAngle)); % 13
            XmuUpd{1}(i).w = wInit;    % Pred weight
            XmuUpd{1}(i).state = [unifrnd(-Xrange, Xrange), ...
                unifrnd(-Yrange, Yrange), Zrnd, ...
                unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit), 0, 0]';      % Pred state
            XmuUpd{1}(i).P = covBirth;%*eye(8);      % Pred cov
            %XmuUpd{1}(i).P(end,end) = 0;   % If 1 at end of states

            Zrnd = unifrnd(FOV(1,3), Zinter);
            Xrange = min(maxX, Zrnd*tand(xAngle));
            Yrange = min(maxY, Zrnd*tand(yAngle));
            XuUpd{1}(i).w = wInit;    % Pred weight
            XuUpd{1}(i).state = [unifrnd(-Xrange, Xrange), ...
                unifrnd(-Yrange, Yrange), Zrnd, ...
                unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit), 0, 0]';      % Pred state
            XuUpd{1}(i).P = covBirth;%*eye(8);      % Pred cov
            %XuUpd{1}(i).P(end,end) = 0; % If 1 at end of states
            if egoMotionOn
                % Local cam2 -> local cam0 -> local velo -> global velo
                XmuUpd{1}(i).state(1:3) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[XmuUpd{1}(i).state(1:3);1]));
                XmuUpd{1}(i).state(1:2) = sqrt(XmuUpd{1}(i).state(1,:).^2+XmuUpd{1}(i).state(2,:).^2).*...
                                            [cos(heading+atan(XmuUpd{1}(i).state(2,:)./XmuUpd{1}(i).state(1,:))); ...
                                            sin(heading+atan(XmuUpd{1}(i).state(2,:)./XmuUpd{1}(i).state(1,:)))];
                XmuUpd{1}(i).state(1:3) = XmuUpd{1}(i).state(1:3) + pose{1}(1:3,4);

                XuUpd{1}(i).state(1:3) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[XuUpd{1}(i).state(1:3);1]));
                XuUpd{1}(i).state(1:2) = sqrt(XuUpd{1}(i).state(1,:).^2+XuUpd{1}(i).state(2,:).^2).*...
                                            [cos(heading+atan(XuUpd{1}(i).state(2,:)./XuUpd{1}(i).state(1,:))); ...
                                            sin(heading+atan(XuUpd{1}(i).state(2,:)./XuUpd{1}(i).state(1,:)))];
                XuUpd{1}(i).state(1:3) = XuUpd{1}(i).state(1:3) + pose{1}(1:3,4);
            end
        end
        for i = ceil(nbrInitBirth/5)+1:nbrInitBirth
            Zrnd = unifrnd(Zinter, FOV(2,3)); % TODO: True angle of view?
            Xrange = min(maxX, Zrnd*tand(xAngle)); % 45? 40.6
            Yrange = min(maxY, Zrnd*tand(yAngle)); % 13
            XmuUpd{1}(i).w = wInit;    % Pred weight
            XmuUpd{1}(i).state = [unifrnd(-Xrange, Xrange), ...
                unifrnd(-Yrange, Yrange), Zrnd, ...
                unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit), 0, 0]';      % Pred state
            XmuUpd{1}(i).P = covBirth;%*eye(8);      % Pred cov
            %XmuUpd{1}(i).P(end,end) = 0;   % If 1 at end of states

            Zrnd = unifrnd(Zinter, FOV(2,3));
            Xrange = min(maxX, Zrnd*tand(xAngle));
            Yrange = min(maxY, Zrnd*tand(yAngle));
            XuUpd{1}(i).w = wInit;    % Pred weight
            XuUpd{1}(i).state = [unifrnd(-Xrange, Xrange), ...
                unifrnd(-Yrange, Yrange), Zrnd, ...
                unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit), 0, 0]';      % Pred state
            XuUpd{1}(i).P = covBirth;%*eye(8);      % Pred cov
            %XuUpd{1}(i).P(end,end) = 0; % If 1 at end of states
            if egoMotionOn
                % Local cam2 -> local cam0 -> local velo -> global velo
                XmuUpd{1}(i).state(1:3) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[XmuUpd{1}(i).state(1:3);1]));
                XmuUpd{1}(i).state(1:2) = sqrt(XmuUpd{1}(i).state(1,:).^2+XmuUpd{1}(i).state(2,:).^2).*...
                                            [cos(heading+atan(XmuUpd{1}(i).state(2,:)./XmuUpd{1}(i).state(1,:))); ...
                                            sin(heading+atan(XmuUpd{1}(i).state(2,:)./XmuUpd{1}(i).state(1,:)))];
                XmuUpd{1}(i).state(1:3) = XmuUpd{1}(i).state(1:3) + pose{1}(1:3,4);

                XuUpd{1}(i).state(1:3) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[XuUpd{1}(i).state(1:3);1]));
                XuUpd{1}(i).state(1:2) = sqrt(XuUpd{1}(i).state(1,:).^2+XuUpd{1}(i).state(2,:).^2).*...
                                            [cos(heading+atan(XuUpd{1}(i).state(2,:)./XuUpd{1}(i).state(1,:))); ...
                                            sin(heading+atan(XuUpd{1}(i).state(2,:)./XuUpd{1}(i).state(1,:)))];
                XuUpd{1}(i).state(1:3) = XuUpd{1}(i).state(1:3) + pose{1}(1:3,4);
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save everything in simVariables and load at the begining of the filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(mode,'GTnonlinear') || strcmp(mode,'CNNnonlinear')
    save('simVariables','R','T','FOVsize','R','F','Q','Pd','Ps','c','threshold',...
        'poissThresh','vinit','thresholdEst','covBirth','boarder','pctWithinBoarder',...
        'weightBirth','motionModel','nbrPosStates','nbrStates','nbrMeasStates','H3dTo2d','H3dFunc','Hdistance',...
        'R3dTo2d','Rdistance','Jh','FOV','H','R');
else 
    save('simVariables','R','T','FOVsize','R','F','Q','H','Pd','Ps','c','threshold',...
        'poissThresh','vinit','thresholdEst','covBirth','boarder','pctWithinBoarder',...
        'weightBirth','motionModel','nbrPosStates','nbrStates','nbrMeasStates','dInit');
end