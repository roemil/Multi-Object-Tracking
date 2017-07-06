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
%sequences = {'0004'};% quite good {'0004','0006'}
%sequences = {'0004','0006','0010','0018'};
sequences = {'0004','0006','0010'};
sequences = {'0019'};
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
totNbrFrames = 0;

err = cell(length(sequences),1);
errCNN = cell(length(sequences),1);
err = cell(21,1);
errCNN = cell(21,1);

startTotalTime = tic;
meanCNN = cell(1);
meanPMBM = cell(1);
dCNN= cell(1);
d = cell(1);
fpCNN = cell(1);
fnCNN = cell(1);
fpPMBM = cell(1);
fnPMBM = cell(1);
numGTobj = cell(1);
totalCNNGOSPA = 0;
totalPMBMGOSPA = 0;
totalFPCNN = 0;
totalFNCNN = 0;
totalFPPMBM = 0;
totalFNPMBM = 0;
totalGTobj = 0;

meanCNN3D = cell(1);
meanPMBM3D = cell(1);
totalCNNGOSPA3D = 0;
totalPMBMGOSPA3D = 0;
totalGTobj3D = 0;
numGTobj3D = cell(1);
fpCNN3D = cell(1);
fnCNN3D = cell(1);
fpPMBM3D = cell(1);
fnPMBM3D = cell(1);

%XestAllSim = cell(21,1);
%ZallSim = cell(21,1);

for sim = 1 : length(sequences)
    clear Xest;
    disp(['--------------------- ', 'SIM Number ','---------------------']) 
    disp(['--------------------- ', num2str(sim),' ---------------------'])
sequence = sprintf('%04d',sim-1);
sequence = sequences{sim};
[nbrInitBirth, wInit, FOVinit, vinit, covBirth, Z, nbrOfBirths, maxKperGlobal,...
    maxNbrGlobal, Nhconst, XmuUpd, XuUpd, FOVsize] ...
    = declareVariables(mode, set, sequence, motionModel, nbrPosStates);
global P2;
global k
k = 1;

Xupd = cell(1);

K = size(Z,2); % Length of sequence
nbrSim = 1; % Nbr of simulations

nbrMissmatch = zeros(1,nbrSim);
newLabel = 1;

% Remove dont care before filter
% datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
% GTdc = generateGTdc(set,sequence,datapath,nbrPosStates);
% Z2 = cell(size(Z));
% iInd = 1;
% for i = 1 : size(Z,2)
%     if(~isempty(Z{i}))
%         jInd = 1;
%         for j = 1 : size(Z{i},2)
%             if(~isinside(Z{i}(:,j),GTdc{i}))
%                 Z2{i}(:,jInd) = Z{i}(:,j);
%                 jInd = jInd + 1;
%             end
%         end
%     else
%         Z2{i} = [];
%     end
% end
% Z = Z2;

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
    %kInit = 1;
    initiated = false;
    for z = 1:size(Z,2)
        if ~isempty(Z{z}) && ~initiated
            kInit = z;
            initiated = true;
        end
    end
    if ~isempty(lastwarn())
        [a, MSGID] = lastwarn();
        warning('off', MSGID)
    end
    tic
    Nh = Nhconst;
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
    totNbrFrames = totNbrFrames+K;
    Nh = Nhconst;
    
    for k = kInit+1:K % For each time step
        disp(['--------------- k = ', num2str(k), '/',num2str(K), ' ---------------'])
        tic;
        if ~isempty(Z{k})
            Nh = Nhconst*size(Z{k},2);
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


writetofile(Xest,mode,['../../devkit_updated/python/results/tracker/data/',sequence,'.txt']);
writeCNNtofile(Z,['../../devkit_updated/python/results/cnn/data/',sequence]);
%writetofile(Xest,mode,['../../devkit_updated/python/results/sha_key/data/',sequence,'.txt']);

% Remove these if GOSPA
% end
% end
% totalTime = toc(startTotalTime);
% disp(['Total simulation time: ', num2str(totalTime)])
% disp(['Average time per frame: ', num2str(totalTime/totNbrFrames)])
% Remove these if GOSPA

% If err3D
% global TcamToVelo, global T20, global TveloToImu, global angles, global pose
% Z3D = cell(1);
% for k = 1:size(Z,2)
%     if ~isempty(Z{k})
%         heading = angles{k}.heading-angles{1}.heading;
%         iInd = 1;
%         for i = 1:size(Z{k},2)
%             [zApprox, ~] = pix2coordtest(Z{k}(1:2,i),Z{k}(3,i));
%             Z3D{k}{iInd}(1:3,1) = pixel2cameracoords(Z{k}(1:2,i),zApprox);
%             Z3D{k}{iInd}(1:3,1) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[Z3D{k}{iInd}(1:3);1]));
%             Z3D{k}{iInd}(1:2,1) = [cos(heading), -sin(heading); sin(heading) cos(heading)]*Z3D{k}{iInd}(1:2);
%             Z3D{k}{iInd}(1:3,1) = Z3D{k}{iInd}(1:3) + pose{k}(1:3,4);
%             iInd = iInd+1;
%         end
%     else
%         Z3D{k} = [];
%     end
% end
%errCNN{sim} = eval3D(false, false, set, sequence, Z3D);

% Evaluate 3D state. Distance between estimate and GT. Do GOSPA?
%err{sim} = eval3D(false, false, set, sequence, Xest);
end
% Evaluate GOSPA
plotOn = false;
[meanCNN{sim}, meanPMBM{sim}, dCNN{sim}, dPMBM{sim}, fpCNN{sim},...
            fpPMBM{sim}, fnCNN{sim}, fnPMBM{sim}, numGTobj{sim},loc_errCNN(sim),loc_errPMBM(sim), car_errCNN(sim), car_errPMBM(sim)] = ...
            evalGOSPA(Xest,...
            Z,sequence, motionModel, nbrPosStates,plotOn);
totalCNNGOSPA = totalCNNGOSPA + meanCNN{sim};
totalPMBMGOSPA = totalPMBMGOSPA + meanPMBM{sim};
totalFPCNN = totalFPCNN + fpCNN{sim};
totalFNCNN = totalFNCNN + fnCNN{sim};
totalFPPMBM = totalFPPMBM + fpPMBM{sim};
totalFNPMBM = totalFNPMBM + fnPMBM{sim};
totalGTobj = totalGTobj + numGTobj{sim};


global TcamToVelo, global T20, global TveloToImu, global angles, global pose
Z3D = cell(1);
for k = 1:size(Z,2)
    if ~isempty(Z{k})
        heading = angles{k}.heading-angles{1}.heading;
        iInd = 1;
        for i = 1:size(Z{k},2)
            [zApprox, ~] = pix2coordtest(Z{k}(1:2,i),Z{k}(3,i));
            Z3D{k}(1:3,iInd) = pixel2cameracoords(Z{k}(1:2,i),zApprox);
            Z3D{k}(1:3,iInd) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[Z3D{k}(1:3,iInd);1]));
            Z3D{k}(1:2,iInd) = [cos(heading), -sin(heading); sin(heading) cos(heading)]*Z3D{k}(1:2,iInd);
            Z3D{k}(1:3,iInd) = Z3D{k}(1:3,iInd) + pose{k}(1:3,4);
            iInd = iInd+1;
        end
    else
        Z3D{k} = [];
    end
end
[meanCNN3D{sim}, meanPMBM3D{sim}, ~, ~, fnCNN3D{sim},...
fpPMBM3D{sim}, fnCNN3D{sim}, fnPMBM3D{sim}, numGTobj3D{sim},loc_err3DCNN(sim),loc_err3DPMBM(sim), car_errCNN3D(sim), car_errPMBM3D(sim)] = ...
    evalGOSPA3D(Xest,...
    Z, Z3D,sequence, motionModel, nbrPosStates,plotOn);
    totalCNNGOSPA3D = totalCNNGOSPA3D + meanCNN3D{sim};
    totalPMBMGOSPA3D = totalPMBMGOSPA3D + meanPMBM3D{sim};
    totalGTobj3D = totalGTobj3D + numGTobj3D{sim};

%XestAllSim{sim} = Xest;
%ZallSim{sim} = Z;

end
totalTime = toc(startTotalTime);
disp(['Total simulation time: ', num2str(totalTime)])
disp(['Average time per frame: ', num2str(totalTime/totNbrFrames)])

fprintf('\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f', ...
    'Mean GOSPA w/o tracker: ', mean(cell2mat(meanCNN)), ...
    'Mean GOSPA w/ tracker: ', mean(cell2mat(meanPMBM)),...
    'FP CNN ',totalFPCNN,'FN CNN ', totalFNCNN, ...
    'FP PMBM ',totalFPPMBM,'FN PMBM ', totalFNPMBM, ...
    'Total GT obj: ', totalGTobj,...
    'Mean loc error CNN: ', mean(loc_errCNN),...
    'Mean loc error PMBM: ', mean(loc_errPMBM),...
    'Mean car error CNN: ', mean(car_errCNN),...
    'Mean car error PMBM: ', mean(car_errPMBM))

fprintf('\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f',...
    'Mean 3D GOSPA w/o tracker: ', mean(cell2mat(meanCNN3D)), ...
    'Mean 3D GOSPA w/ tracker: ', mean(cell2mat(meanPMBM3D)), ...
    'FP CNN ',totalFPCNN,'FN CNN ', totalFNCNN, ...
    'FP PMBM ',totalFPPMBM,'FN PMBM ', totalFNPMBM, ...
    'Total GT obj: ', totalGTobj3D,...
    'Mean loc error CNN: ', mean(loc_err3DCNN),...
    'Mean loc error PMBM: ', mean(loc_err3DPMBM),...
    'Mean car error CNN: ', mean(car_errCNN3D),...
    'Mean car error PMBM: ', mean(car_errPMBM3D))

%plotGOSPA(meanCNN, meanPMBM,fpCNN,fpPMBM,fnCNN,fnPMBM)

% fprintf('\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f', ...
%     'Mean GOSPA w/o tracker: ', mean(cell2mat(meanCNN)), ...
%     'Mean GOSPA w/ tracker: ', mean(cell2mat(meanPMBM)),...
%     'FP CNN ',totalFPCNN,'FN CNN ', totalFNCNN, ...
%     'FP PMBM ',totalFPPMBM,'FN PMBM ', totalFNPMBM, ...
%     'Total GT obj: ', totalGTobj)
% fprintf('\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f',...
%     'Mean 3D GOSPA w/o tracker: ', mean(cell2mat(meanCNN3D)), ...
%     'Mean 3D GOSPA w/ tracker: ', mean(cell2mat(meanPMBM3D)), ...
%     'Total GT obj: ', totalGTobj3D)

% Plot error in 3D space. First input plots error vs distance [m]. Second
% plots rel error dep on distance
%[quant95CNN, nCNN] = plotError(false,true,errCNN);
%[quant95, nErr] = plotError(false,true,err);
%disp(['95% rel error PMBM: ', num2str(quant95)])
%disp(['95% rel error CNN: ', num2str(quant95CNN)])

%%
[meanCNN{sim}, meanPMBM{sim}, dCNN{sim}, dPMBM{sim}, fpCNN{sim},...
    fpPMBM{sim}, fnCNN{sim}, fnPMBM{sim}, numGTobj{sim}] = evalGOSPA(Xest,...
    Z,sequence, motionModel, nbrPosStates,plotOn);
totalCNNGOSPA = meanCNN{sim};
totalPMBMGOSPA = meanPMBM{sim};
totalFPCNN = fpCNN{sim};
totalFNCNN = fnCNN{sim};
totalFPPMBM = fpPMBM{sim};
totalFNPMBM = fnPMBM{sim};
totalGTobj = numGTobj{sim};

fprintf('\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f\n%s%f', ...
    'Mean GOSPA w/o tracker: ', mean(totalCNNGOSPA), ...
    'Mean GOSPA w/ tracker: ', mean(totalPMBMGOSPA),...
    'FP CNN ',totalFPCNN,'FN CNN ', totalFNCNN, ...
    'FP PMBM ',totalFPPMBM,'FN PMBM ', totalFNPMBM, ...
    'Total GT obj: ', totalGTobj)

%% Eval CNN
mode = 'CNNnonlinear';
set = 'training';
for sim = 1 : 21
    clear Xest;
    disp(['--------------------- ', 'SIM Number ','---------------------']) 
    disp(['--------------------- ', num2str(sim),' ---------------------'])
sequence = sprintf('%04d',sim-1);
%sequence = sequences{sim};
[nbrInitBirth, wInit, FOVinit, vinit, covBirth, Z, nbrOfBirths, maxKperGlobal,...
    maxNbrGlobal, Nhconst, XmuUpd, XuUpd, FOVsize] ...
    = declareVariables(mode, set, sequence, motionModel, nbrPosStates);
writeCNNtofile(Z,['../../devkit_updated/python/results/cnn/data/',sequence]);
end


%%

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
a = subplot('position', [0.02 0 0.98 1]);
k = kInit;
flag = 'true';
while 1
    frameNbr = sprintf('%06d',k-1);
    if strcmp(mode,'GTnonlinear') && ~simMeas
        plotImgEstGT(sequence,set,k,Xest{k});
    elseif strcmp(mode,'CNNnonlinear') || simMeas
        plotImgEst(sequence,set,k,Xest{k},Z{k});
    end
    title(['k = ', num2str(k-1)],'Interpreter','Latex','Fontsize',20)
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
            else
                cla(a)
            end
        case 'l'
            k = k + 1;
            if k > size(Xest,2)
                fprintf('Window closed. Exiting...\n');
                break
            else
                cla(a)
            end
        case 'o'
            k = k + 10;
            if k > size(Xest,2)
                fprintf('Window closed. Exiting...\n');
                break
            else
                cla(a)
            end
        case 'q'
            k = k - 10;
            if k <= 0
                fprintf('Window closed. Exiting...\n');
                break
            else
                cla(a)
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

