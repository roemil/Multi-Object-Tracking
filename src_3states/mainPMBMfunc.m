% Estimates leaving FOV will make the evaluation bad. Since they exist in
% the filter but not in the GT. Add Ps state dependent.

clear Xest
clear Pest
close all
dbstop error
addpath('IMU')
addpath('mtimesx')
addpath('evalMOT')
addpath('../../kittiTracking/')
clc
mode = 'CNNnonlinear';
set = 'training';
sequences = {'0007'};%,'0002','0003','0012','0017'};
global motionModel
motionModel = 'cvBB'; % Choose 'cv' or 'cvBB'
global birthSpawn
birthSpawn = 'uniform'; % Choose 'boarders' or 'uniform'
global egoMotionOn
egoMotionOn = true; 
global uniformBirths
uniformBirths = true;

% Simulate measurement from GT. Set simMeas = true. Use variables from
% GTnonlinear or CNNnonlinear by setting mode
global simMeas
simMeas = false;

global plotHypoConf
plotHypoConf = false;

global gatingOn
gatingOn = true;

global color;
color = true;

% TODO: cars to the right in 0016 is not estimated, why? Why such large
% difference in prob of exi?
% TODO: Random object spawning. Something wrong in the births? Clutter?

XmuUpd = cell(1,1);
XuUpd = cell(1,1);

global nbrPosStates
nbrPosStates = 6; % Nbr of position states, pos and velo, choose 4 or 6
ClearMOT = cell(1);
for sim = 1 : length(sequences)
    clear Xest;
    disp(['--------------------- ', 'SIM Number ','---------------------']) 
    disp(['--------------------- ', num2str(sim),' ---------------------'])
%sequence = sprintf('%04d',sim-1);
sequence = sequences{sim};
[nbrInitBirth, wInit, FOVinit, vinit, covBirth, Z, nbrOfBirths, maxKperGlobal,...
    maxNbrGlobal, Nhconst, XmuUpd, XuUpd, FOVsize] ...
    = declareVariables(mode, set, sequence, motionModel, nbrPosStates);
global P2;
global k
k = 1;

Xupd = cell(1);

K = min(1000,size(Z,2)); % Length of sequence
nbrSim = 1; % Nbr of simulations

nbrMissmatch = zeros(1,nbrSim);
newLabel = 1;

jEst = zeros(1,K);
normGlobWeights = cell(K,1);

plotOn = 'false';
startTime = tic;

for t = 1:nbrSim

    disp('-------------------------------------')
    disp(['--------------- t = ', num2str(t), ' ---------------'])
    disp('-------------------------------------')
    
    disp(['--------------- k = ', num2str(1), '/',num2str(K), '---------------'])
    global k
    global kInit
    kInit = 1;
%     for z = 1:size(Z,2)
%         if ~isempty(Z{z})
%             kInit = z;
%             break
%         end
%     end
    if ~isempty(lastwarn())
        [a, MSGID] = lastwarn();
        warning('off', MSGID)
    end
    tic
    [XuUpd{t,kInit}, Xupd{t,kInit}, Xest{t,kInit}, Pest{t,kInit}, rest{t,kInit}, west{t,kInit}, labelsEst{t,kInit}, newLabel, jEst(kInit), normGlobWeights{kInit}] = ...
        PMBMinitFunc(Z{kInit}, XmuUpd{t,1}, XuUpd{t,1}, nbrOfBirths, maxKperGlobal, maxNbrGlobal, newLabel, birthSpawn, mode);
    disp(['Iteration time: ', num2str(toc)])
    %rest{1}
    if strcmp(plotOn,'true')
        frameNbr = '000000';
        if ~strcmp(mode,'GT')
            plotDetections(set, sequence, frameNbr, Xest{1}, FOVsize)
            %plotUndetected(XmuUpd{1,1}, figHandle)
        else
            plotDetectionsGT(set, sequence, frameNbr, Xest{1}, FOVsize, Z{1})
        end
        title('k = 1')
        pause(0.1)
        %keyboard
    end
    
    % Only keep births
    %tmp = XuUpd;
    %clear XuUpd;
    %XuUpd{1,1}(1:nbrOfBirths) = tmp{1,1}(end-nbrOfBirths+1:end);
    
    for k = kInit+1:K % For each time step
        disp(['--------------- k = ', num2str(k), '/',num2str(K), ' ---------------'])
        Nh = Nhconst*size(Z{k},2);    %Murty
        tic;
        if ~isempty(Z{k})
            [XuUpd{t,k}, Xpred{t,k}, Xupd{t,k}, Xest{t,k}, Pest{t,k}, rest{t,k}, west{t,k}, labelsEst{t,k}, newLabel, jEst(k), normGlobWeights{k}] = ...
                PMBMfunc(Z{k}, XuUpd{t,k-1}, Xupd{t,k-1}, Nh, nbrOfBirths, maxKperGlobal, maxNbrGlobal, newLabel, birthSpawn, mode, normGlobWeights{k-1}, k);
        else
            disp('No measurement')
            [XuUpd{t,k}, Xpred{t,k}, Xupd{t,k}, Xest{t,k}, Pest{t,k}, rest{t,k}, west{t,k}, labelsEst{t,k}, newLabel, jEst(k), normGlobWeights{k}] = ...
                PMBMpredFunc(Z{k}, XuUpd{t,k-1}, Xupd{t,k-1}, Nh, nbrOfBirths, maxKperGlobal, maxNbrGlobal, newLabel, birthSpawn, mode, normGlobWeights{k-1}, k);
        end
        disp(['Iteration time: ', num2str(toc)])
        %disp(['Nbr targets: ', num2str(size(X{t,k},2))])
        %disp(['Nbr estimates: ', num2str(size(Xest{t,k},2))])
        %disp(['Nbr prop targets: ', num2str(sum(rest{t,k} == 1))])
        %disp(['Nbr clutter points: ', num2str(size(Z{k},2)-size(X{k},2))])

        if strcmp(plotOn, 'true')
            frameNbr = sprintf('%06d',k-1);
            if ~strcmp(mode,'GT')
                plotDetections(set, sequence, frameNbr, Xest{k}, FOVsize)
            else
                plotDetectionsGT(set, sequence, frameNbr, Xest{k}, FOVsize, Z{k})
            end
            title(['k = ', num2str(k)])
            pause(0.1)
        end
    end

simTime = toc(startTime);


disp('--------------- Simulation Complete ---------------')
disp(['Total simulation time: ', num2str(simTime)])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Post Processing %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

writetofile(Xest,mode,['../../devkit_updated/python/results/sha_key/data/',sequence,'.txt']);

clear gt, clear result, clear resultZ
generateData

VOCscore = 0.5;
dispON  = true;
ClearMOT{sim} = evaluateMOT(gt,result,VOCscore,dispON);
if ~strcmp(mode,'GTnonlinear') || simMeas
    ClearMOTZ = evaluateMOT(gt,resultZ,VOCscore,false);
    disp('----------------------------')
    disp('CNN output')
    disp(['MOTP = ', num2str(ClearMOTZ.MOTP)])
    disp('----------------------------')
end
end
end
%% Plot birds-eye view pred conf
step = true;
if strcmp(mode,'GTnonlinear') || strcmp(mode,'CNNnonlinear')
    plotBirdsConf(sequence,set,Xpred,step,jEst);
else
    disp('Not implemented')
end
%% Evaluate
clear gt, clear result, clear resultZ
generateData

VOCscore = 0.5;
dispON  = true;
ClearMOT = evaluateMOT(gt,result,VOCscore,dispON);
if ~strcmp(mode,'GTnonlinear') || simMeas
    ClearMOTZ = evaluateMOT(gt,resultZ,VOCscore,false);
    disp('----------------------------')
    disp('CNN output')
    disp(['MOTP = ', num2str(ClearMOTZ.MOTP)])
    disp('----------------------------')
end
%% Plot estimates Img-plane

figure('units','normalized','position',[.05 .05 .9 .9]);
subplot('position', [0.02 0 0.98 1])
k = kInit;
while 1
    frameNbr = sprintf('%06d',k-1);
    if strcmp(mode,'GTnonlinear') && ~simMeas
        plotImgEstGT(sequence,set,k,Xest{k});
    elseif strcmp(mode,'CNNnonlinear') || simMeas
        plotImgEst(sequence,set,k,Xest{k},Z{k})
    end
    title(['k = ', num2str(k-1)])
    try
        waitforbuttonpress; 
    catch
        fprintf('Window closed. Exiting...\n');
        break
    end
    key = get(gcf,'CurrentCharacter');
    switch lower(key)  
        case 'a'
            k = k - 1;
            if k <= 0
                fprintf('Window closed. Exiting...\n');
                break
            end
        case 'l'
            k = k + 1;
            if k > size(Xest,2)
                fprintf('Window closed. Exiting...\n');
                break
            end
        case 'o'
            k = k + 10;
            if k > size(Xest,2)
                fprintf('Window closed. Exiting...\n');
                break
            end
        case 'q'
            k = k - 10;
            if k <= 0
                fprintf('Window closed. Exiting...\n');
                break
            end
    end
    %pause(1.5)
%end
end

%% Plot each 3D state

plotConf = false;
%subplot('position', [0.02 0 0.98 1])
if strcmp(mode,'GTnonlinear') || strcmp(mode,'CNNnonlinear')
    plotEach3Dstate(sequence,set,Xest,Pest,plotConf);
else
    disp('Not implemented')
end

%% Plot birds-eye view
labels = [];
plotConf = false;
step = true;
auto = false;
if strcmp(mode,'GTnonlinear') || strcmp(mode,'CNNnonlinear')
    plotBirdsEye(sequence,set,Xest,Pest,step,auto, labels, plotConf);
else
    disp('Not implemented')
end

%% Plot birds-eye view pred conf

step = true;
if strcmp(mode,'GTnonlinear') || strcmp(mode,'CNNnonlinear')
    plotBirdsConf(sequence,set,Xpred,step,jEst);
else
    disp('Not implemented')
end


%% Plot estimates

figure('units','normalized','position',[.05 .05 .9 .9]);
subplot('position', [0.02 0 0.98 1])
for k = 1:size(Xest,2)
    frameNbr = sprintf('%06d',k-1);
    if ~strcmp(mode,'GT')
        plotImgEstGT(sequence,set,k,Xest{k});
    else
        plotImgEstGT(sequence,set,k,Xest{k});
    end
    title(['k = ', num2str(k)])
    waitforbuttonpress
    %pause(1.5)
end

%% Plot estimates 3D

plotConf = false;
figure('units','normalized','position',[.05 .05 .9 .9]);
%subplot('position', [0.02 0 0.98 1])
k = 1;
while 1
    frameNbr = sprintf('%06d',k-1);
    if strcmp(mode,'GTnonlinear')
        [p1, p2, l, h] = plot3DestGT(sequence,set,k,Xest{k},Pest{k},plotConf);
    elseif ~strcmp(mode,'GTnonlinear')
        % Not implemented
    end
    title(['k = ', num2str(k)])
    try
        waitforbuttonpress; 
    catch
        fprintf('Window closed. Exiting...\n');
        break
    end
    key = get(gcf,'CurrentCharacter');
    switch lower(key)  
        case 'a'
            k = k - 1;
            delete(p1)
            delete(p2)
            delete(l)
            if plotConf
                delete(h)
            end
        case 'l'
            k = k + 1;
            delete(p1)
            delete(p2)
            delete(l)
            if plotConf
                delete(h)
            end
    end
    %pause(1.5)
%end
end
%% Compare 3d estimate and GT

k = 1;
j = 1;

%[est, true] = estGTdiff(sequence,set,k,Xupd{1,k}{j},true,true);

[est, true] = estGTdiff(sequence,set,k,Xest{k},true,true);

%% 3D to 2D

clear X2d
load simVariables.mat
type = 'upd';
X = Xupd;

if strcmp(type,'upd')
    for k = 1:K
        for j = 1:size(Xupd{1,k},2)
            iInd = 1;
            for i = 1:size(Xupd{1,k}{j},2)
                if ~isempty(Xupd{1,k}{j}(i))
                    X2d{k,j}{:,iInd} = H3dFunc(Xupd{1,k}{j}(i).state);
                    P2d{k,j}{:,iInd}
                    iInd = iInd+1;
                end
            end
        end
    end
end


%% Plot estimates

figure('units','normalized','position',[.05 .05 .9 .9]);
subplot('position', [0.02 0 0.98 1])
%for k = 1:size(Xest,2)
k = 1;
while 1
    frameNbr = sprintf('%06d',k-1);
    if ~strcmp(mode,'GT')
        plotDetections(set, sequence, frameNbr, Xest{k}, FOVsize)
    else
        plotDetectionsGT(set, sequence, frameNbr, Xest{k}, FOVsize, Z{k},nbrPosStates)
    end
    title(['k = ', num2str(k)])
    try
        waitforbuttonpress; 
    catch
        fprintf('Window closed. Exiting...\n');
        break
    end
    key = get(gcf,'CurrentCharacter');
    switch lower(key)  
        case 'a'
            k = k - 1;
        case 'l'
            k = k + 1;
    end
    %pause(1.5)
%end
end

%% Plot confidence

type = 'pred';
j = 1;
figure('units','normalized','position',[.05 .05 .9 .9]);
subplot('position', [0.02 0 0.98 1])
for k = 1:K
    frameNbr = sprintf('%06d',k-1);
    if ((strcmp(type,'est')) && (~isempty(Xest{k}{1})))
        plotStateConf(set, sequence, frameNbr, Xest{k}, Pest{k}, FOVsize, Z{k})
    elseif strcmp(type,'pred')
        clear Xtmp
        clear Ptmp
        if k == 1
            k = 2;
            frameNbr = sprintf('%06d',k-1);
        end
        for i = 1:size(Xpred{k}{jEst(k-1)},2)
            Xtmp{i} = H3dFunc(Xpred{k}{jEst(k-1)}(i).state);
            Xtmp{i}(end+1) = Xpred{k}{jEst(k-1)}(i).label;
            Ptmp{i} = Xpred{k}{jEst(k-1)}(i).P;
        end
        plotStateConf(set, sequence, frameNbr, Xtmp, Ptmp, FOVsize, Z{k})
    end
    title(['k = ', num2str(k)])
    waitforbuttonpress
end


%% Plot pred and upd
figure;
%for k = 2:size(Xest,2)
k = 2;
while 1
    frameNbr = sprintf('%06d',k-1);
    plotPredUpd(set, sequence, frameNbr, Xpred{1,k}, Xupd{1,k-1},FOVsize)
    title(['k = ', num2str(k)])
    %waitforbuttonpress
    try
        waitforbuttonpress; 
    catch
        fprintf('Window closed. Exiting...\n');
        break
    end
    key = get(gcf,'CurrentCharacter');
    switch lower(key)  
        case 'a'
            k = k - 1;
        case 'l'
            k = k + 1;
    end
end

%% Plot single pred and upd
i = 1;

for k = 2:size(Xest,2)
    k
    frameNbr = sprintf('%06d',k-1);
    plotSinglePredUpd(set, sequence, frameNbr, Xpred{1,k}{jEst(k-1)}, Xupd{1,k}{jEst(k)},i,FOVsize)
    title(['k = ', num2str(k)])
    waitforbuttonpress
end

%% Estimated velocities

veloEst = zeros(2,5,size(Xest,2));
labels = zeros(1,5,size(Xest,2));
for k = 2:size(Xest,2)
    for i = 1:size(Xest{1,k},2)
        if ~isempty(Xest{1,k}{i})
            veloEst(1:2,i,k) = Xest{1,k}{i}(3:4);
            labels(1,i,k) = Xest{1,k}{i}(7);
        end
    end
end

%% Stack rest, labelsEst and west

rlabelsw = cell(1);
for k = 1:size(Xest,2)
    rlabelsw{k} = [rest{1,k}; labelsEst{1,k}; west{1,k}];
end

%% Plot rest for specific label

label = 10;

figure(label);
hold on
for k = 1:K
    ind = find(label == labelsEst{k});
    if ~isempty(ind)
        plot(k, rest{k}(ind),'*r')
    end
end

%% Estimated pos and lables

est = zeros(5,5,size(Xest,2));
for k = 1:size(Xest,2)
    for i = 1:size(Xest{1,k},2)
        if ~isempty(Xest{1,k}{i})
            est(:,i,k) = [Xest{1,k}{i}(1:4); Xest{1,k}{i}(7)];
        end
    end
end

