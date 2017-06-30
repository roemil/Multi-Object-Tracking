function [meanCNN, meanPMBM, dCNN, dPMBM, fpCNN, fpPMBM, fnCNN, fnPMBM, numGTobj]= evalGOSPA(Xest, Z, sequence, motionModel, nbrPosStates, plotOn)
    global H, global angles, global pose
    mode = 'GTnonlinear';
    set = 'training';
    c_thresh = 400;%50;
    p = 2;
    numGTobj = 0;
%     [nbrInitBirth, wInit, FOVinit, vinit, covBirth, Z, nbrOfBirths, maxKperGlobal,...
%         maxNbrGlobal, Nhconst, XmuUpd, XuUpd, FOVsize] ...
%         = declareVariables(mode, set, sequence, motionModel, nbrPosStates);
%     GT = Z;
    datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
    GTdc = generateGTdc(set,sequence,datapath,nbrPosStates);
    GT = generateGT(set,sequence,datapath,nbrPosStates);
    for i = 1 : size(GT,2)
        numGTobj = numGTobj + size(GT{i},2);
    end
%     mode = 'CNNnonlinear';
%     set = 'training';
%     [nbrInitBirth, wInit, FOVinit, vinit, covBirth, Z, nbrOfBirths, maxKperGlobal,...
%         maxNbrGlobal, Nhconst, XmuUpd, XuUpd, FOVsize] ...
%         = declareVariables(mode, set, sequence, motionModel, nbrPosStates);
    dCNN = zeros(1,size(Z,1));
    Z2 = cell(1);
    Xest2 = cell(1);
    iInd = 1;
    for i = 1 : size(Z,2)
        if(~isempty(Z{i}))
            jInd = 1;
            for j = 1 : size(Z{i},2)
                if(~isinside(Z{i}(:,j),GTdc{i}))
                    Z2{i}(:,jInd) = Z{i}(:,j);
                    jInd = jInd + 1;
                end
            end
        else
            Z2{i} = [];
        end
    end
    
    iInd = 1;
    for i = 1 : size(Xest,2)
        heading = angles{i}.heading-angles{1}.heading;
        jInd = 1;
        if(~isempty(Xest{i}{1}))
            for j = 1 : size(Xest{i},2)
                if(~isinside([H(Xest{i}{j},pose{i}(1:3,4),heading);Xest{i}{j}(7:8)],GTdc{i}))
                    Xest2{i}{jInd} = Xest{i}{j};
                    jInd = jInd + 1;
                end
            end
        else
            Xest2{i} = [];
        end
    end
    
    iInd = 1;
    for i = 1 : size(GT,2)
        if(~isempty(GT{i}))
            jInd = 1;
            for j = 1 : size(GT{i},2)
                if(~isinside(GT{i}(:,j),GTdc{i}))
                    GT2{i}(:,jInd) = GT{i}(:,j);
                    jInd = jInd + 1;
                end
            end
        else
            GT2{i} = [];
        end
    end
    GT = GT2;
%plotEstWithoutDC
    for k = 1 : size(Z2,2)
        if(~isempty(Z2{k}))
            [dCNN(k),fpCNN(k), fnCNN(k)] = GOSPA(GT{k},Z2{k},k,'CNN',c_thresh);
        else
%             if(size(Z,2) > size(GT,2) && (k > size(GT,2)))
%                 xL = size(Z{k},2);
%             else
                %xL = size(GT{k},2);
            if(~isempty(GT{k}))
                xL = length(find(GT{k}(6,:) ~= -1));
            else
                %xL = size(Z{k},2);
                xL = 0;
            end
        
            dCNN(k) = (0.5*c_thresh^p*(xL))^(1/p);
        end
    end

    fpCNN = sum(fpCNN);
    fnCNN = sum(fnCNN);

    dPMBM = zeros(1,size(Xest2,2));

    for k = 1 : min(size(Xest2,2),size(GT,2))
        if(~isempty(Xest2{k}))
            [dPMBM(k),fpPMBM(k), fnPMBM(k)] = GOSPA(GT{k},Xest2{k},k,'PMBM',c_thresh);
        else
%             if(size(Xest,2) > size(GT,2) && (k > size(GT,2)))
%                 xL = size(Xest{k},2);
%             else
%                 if(~isempty(GT{k}))
%                     xL = length(find(GT{k}(6) ~= -1));
%                 else
%                     xL = 0;
%                 end
%             end
                if(~isempty(GT{k}))
                    xL = length(find(GT{k}(6,:) ~= -1));
                else
                    xL = size(Xest2{k},2);
                end
            dPMBM(k) = (0.5*c_thresh^p*(xL))^(1/p);
        end
    end
    fpPMBM = sum(fpPMBM);
    fnPMBM = sum(fnPMBM);

    % PLOT
    meanCNN = mean(dCNN);
    meanPMBM = mean(dPMBM);
    if(plotOn)
        figure;
        plot(1:length(dCNN),dCNN,'r+');hold on;
        plot(1:length(dPMBM),dPMBM,'k.-')
        title({['Mean w/o tracker = ', num2str(meanCNN)] ,['Mean w/ tracker = ', num2str(meanPMBM)]});
        ylabel('GOSPA')
        xlabel('k')
        legend('w/o tracker', 'w/ tracker')
        fprintf('%s %f \n%s %f \n%s %f\n%s %f\n', 'Mean w/o tracker: ', mean(dCNN), 'Mean w/ tracker: ', mean(dPMBM), 'Total distance w/o tracker: ',sum(dCNN), 'Total distance w/ tracker: ',sum(dPMBM))
    end
end