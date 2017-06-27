mode = 'GTnonlinear';
set = 'training';
[nbrInitBirth, wInit, FOVinit, vinit, covBirth, Z, nbrOfBirths, maxKperGlobal,...
    maxNbrGlobal, Nhconst, XmuUpd, XuUpd, FOVsize] ...
    = declareVariables(mode, set, sequence, motionModel, nbrPosStates);
GT = Z;

mode = 'CNNnonlinear';
set = 'training';
[nbrInitBirth, wInit, FOVinit, vinit, covBirth, Z, nbrOfBirths, maxKperGlobal,...
    maxNbrGlobal, Nhconst, XmuUpd, XuUpd, FOVsize] ...
    = declareVariables(mode, set, sequence, motionModel, nbrPosStates);

c_thresh = 10;%50;
p = 2;
dCNN = zeros(1,size(Z,1));
for k = 1 : size(Z,2)
    if(~isempty(Xest{k}{1}))
        dCNN(k) = GOSPA(GT{k},Z{k},k,'CNN');
    else
        dCNN(k) = (0.5*c_thresh^p*size(GT{k},2))^(1/p);
    end
end

d = zeros(1,size(Z,1));
for k = 1 : size(Z,2)
    if(~isempty(Xest{k}{1}))
        d(k) = GOSPA(GT{k},Xest{k},k,'PMBM');
    else
        d(k) = (0.5*c_thresh^p*size(GT{k},2))^(1/p);
    end
end

% PLOT
meanCNN = mean(dCNN);
meanPMBM = mean(d);
figure;
plot(1:length(dCNN),dCNN,'r.-',1:length(d),d,'k.-')
title({['Mean w/o tracker = ', num2str(meanCNN)] ,['Mean w/ tracker = ', num2str(meanPMBM)]});
ylabel('GOSPA')
xlabel('k')
legend('w/o tracker', 'w/ tracker')
fprintf('%s %f \n%s %f \n%s %f\n%s %f\n', 'Mean w/o tracker: ', mean(dCNN), 'Mean w/ tracker: ', mean(d), 'Total distance w/o tracker: ',sum(dCNN), 'Total distance w/ tracker: ',sum(d))