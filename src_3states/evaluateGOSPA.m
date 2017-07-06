addpath('IMU')
addpath('mtimesx')
addpath('evalMOT')
addpath('../../kittiTracking/')

mode = 'CNNnonlinear';
set = 'training';

global nbrPosStates
nbrPosStates = 6;
global motionModel
motionModel = 'cvBB'; % Choose 'cv' or 'cvBB'
global birthSpawn
birthSpawn = 'uniform'; % Choose 'boarders' or 'uniform'
global egoMotionOn
egoMotionOn = true; 
global uniformBirths
uniformBirths = true;
global simMeas
simMeas = false;

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

for sim = 1:size(XestAllSim,1)
    disp([num2str(sim)])
    if ~isempty(XestAllSim{sim})
        sequence = sprintf('%04d',sim-1);
        declareVariables(mode, set, sequence, motionModel, nbrPosStates);
        global TcamToVelo, global T20, global TveloToImu, global angles, global pose
        Z3D = cell(1);
        for k = 1:size(ZallSim{sim},2)
            if ~isempty(ZallSim{sim}{k})
                heading = angles{k}.heading-angles{1}.heading;
                iInd = 1;
                for i = 1:size(ZallSim{sim}{k},2)
                    [zApprox, ~] = pix2coordtest(ZallSim{sim}{k}(1:2,i),ZallSim{sim}{k}(3,i));
                    Z3D{k}(1:3,iInd) = pixel2cameracoords(ZallSim{sim}{k}(1:2,i),zApprox);
                    Z3D{k}(1:3,iInd) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[Z3D{k}(1:3,iInd);1]));
                    Z3D{k}(1:2,iInd) = [cos(heading), -sin(heading); sin(heading) cos(heading)]*Z3D{k}(1:2,iInd);
                    Z3D{k}(1:3,iInd) = Z3D{k}(1:3,iInd) + pose{k}(1:3,4);
                    iInd = iInd+1;
                end
            else
                Z3D{k} = [];
            end
        end
        %errCNN{sim} = eval3D(false, false, set, sequence, Z3D);

        % Evaluate 3D state. Distance between estimate and GT. Do GOSPA?
        %err{sim} = eval3D(false, false, set, sequence, Xest);

        % Evaluate GOSPA
        plotOn = false;
        [meanCNN{sim}, meanPMBM{sim}, dCNN{sim}, dPMBM{sim}, fpCNN{sim},...
            fpPMBM{sim}, fnCNN{sim}, fnPMBM{sim}, numGTobj{sim},loc_errCNN(sim),loc_errPMBM(sim), car_errCNN(sim), car_errPMBM(sim)] = ...
            evalGOSPA(XestAllSim{sim},...
            ZallSim{sim},sequence, motionModel, nbrPosStates,plotOn);
        totalCNNGOSPA = totalCNNGOSPA + meanCNN{sim};
        totalPMBMGOSPA = totalPMBMGOSPA + meanPMBM{sim};
        totalFPCNN = totalFPCNN + fpCNN{sim};
        totalFNCNN = totalFNCNN + fnCNN{sim};
        totalFPPMBM = totalFPPMBM + fpPMBM{sim};
        totalFNPMBM = totalFNPMBM + fnPMBM{sim};
        totalGTobj = totalGTobj + numGTobj{sim};

        [meanCNN3D{sim}, meanPMBM3D{sim}, ~, ~, fnCNN3D{sim},...
            fpPMBM3D{sim}, fnCNN3D{sim}, fnPMBM3D{sim}, numGTobj3D{sim},loc_err3DCNN(sim),loc_err3DPMBM(sim), car_errCNN3D(sim), car_errPMBM3D(sim)] = ...
            evalGOSPA3D(XestAllSim{sim},...
            ZallSim{sim}, Z3D,sequence, motionModel, nbrPosStates,plotOn);
        totalCNNGOSPA3D = totalCNNGOSPA3D + meanCNN3D{sim};
        totalPMBMGOSPA3D = totalPMBMGOSPA3D + meanPMBM3D{sim};
        totalGTobj3D = totalGTobj3D + numGTobj3D{sim};
    end
end

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