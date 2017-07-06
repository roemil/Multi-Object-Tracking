function [meanCNN, meanPMBM, dCNN, dPMBM, fpCNN, fpPMBM, fnCNN, fnPMBM, numGTobj,mean_loc_errCNN, mean_loc_errPMBM, mean_car_errCNN, mean_car_errPMBM]= ...
    evalGOSPA3D(Xest, Z, Z3D, sequence, motionModel, nbrPosStates, plotOn)
    global H, global angles, global pose
    mode = 'GTnonlinear';
    set = 'training';
    c_thresh = 20; %20;
    p = 2;
    numGTobj = 0;
%     [nbrInitBirth, wInit, FOVinit, vinit, covBirth, Z, nbrOfBirths, maxKperGlobal,...
%         maxNbrGlobal, Nhconst, XmuUpd, XuUpd, FOVsize] ...
%         = declareVariables(mode, set, sequence, motionModel, nbrPosStates);
%     GT = Z;
    datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
    %GTdc = generateGTdc(set,sequence,datapath,nbrPosStates);
    GTdc = generateGTdcTrunc(set,sequence,datapath,nbrPosStates);
    %GT = generateGT(set,sequence,datapath,nbrPosStates);
    GT = generateGTtrunc(set,sequence,datapath,nbrPosStates);
    
    dCNN = zeros(1,size(Z,1));
%     Z23D = cell(1);
%     Xest2 = cell(1);
%     iInd = 1;
%     for i = 1 : size(Z,2)
%         if(~isempty(Z{i}))
%             jInd = 1;
%             for j = 1 : size(Z{i},2)
%                 if(~isinside(Z{i}(:,j),GTdc{i}))
% %                    Z23D{i}(:,jInd) = Z3D{i}{:,j}; % Filtered
%                     jInd = jInd + 1;
%                 end
%                 Z33D{i}(:,j) = Z3D{i}{:,j}; % Unfiltered
%             end
%         else
%             Z23D{i} = []; % Filtered
%             Z33D{i} = []; % unfiltered
%         end
%     end
    
%     iInd = 1;
%     for i = 1 : size(Xest,2)
%         heading = angles{i}.heading-angles{1}.heading;
%         jInd = 1;
%         if ~isempty(Xest{i})
%             if(~isempty(Xest{i}{1}))
%                 for j = 1 : size(Xest{i},2)
%                     if(~isinside([H(Xest{i}{j},pose{i}(1:3,4),heading);Xest{i}{j}(7:8)],GTdc{i}))
%                         Xest2{i}(:,jInd) = Xest{i}{j}; % Filtered
%                         jInd = jInd + 1;
%                     end
%                     Xest3{i} = Xest{i}{j}; % Unfiltered
%                 end
%             else
%                 Xest2{i} = []; % Filtered
%                 Xest3{i} = []; % Unfiltered
%             end
%         else
%             Xest2{i} = []; % Filtered
%             Xest3{i} = []; % Unfiltered
%         end
%     end
    
    global TveloToImu, global TcamToVelo, global T20, global angles, global pose
    datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
    filename = [datapath,'.txt'];
    formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
    f = fopen(filename);
    GTraw = textscan(f,formatSpec);
    fclose(f);
    
    for k = 1:size(GT,2)
        ind = find(GTraw{1} == k-1 & GTraw{2} ~= -1);
        ind2 = find((~strcmp(GTraw{3}(ind),'Van')) & (~strcmp(GTraw{3}(ind),'Tram')) & (~strcmp(GTraw{3}(ind),'Truck')) & (~strcmp(GTraw{3}(ind),'Misc')) & (GTraw{4}(ind) == 0));
        ind = ind(ind2);
        if ~isempty(ind)
            Xt{k} = [GTraw{14}(ind)';
                    (GTraw{15}(ind)-GTraw{11}(ind)/2)';
                    GTraw{16}(ind)'];
            %XtCamCoords = Xt; Here?
            Xt{k} = TveloToImu(1:3,:)*(TcamToVelo*(T20*[Xt{k};ones(1,size(Xt{k},2))]));
            XtCamCoords{k} = Xt{k};
            heading = angles{k}.heading-angles{1}.heading;
            Xt{k}(1:2,:) = [cos(-heading), sin(-heading); -sin(-heading) cos(-heading)]*Xt{k}(1:2,:);
            Xt{k} = Xt{k}+pose{k}(1:3,4);
            Xt{k}(6,:) = GTraw{2}(ind)';
        else
            %if isempty(Xt{k})
                Xt{k} = [];
            %end
        end
    end
    iInd = 1;
    for i = 1 : size(GT,2)
        if(~isempty(GT{i}))
            jInd = 1;
            for j = 1 : size(GT{i},2)
                if(~isinside(GT{i}(:,j),GTdc{i}))
                    GT3D{i}(:,jInd) = Xt{i}(:,j);
                    jInd = jInd + 1;
                end
            end
        else
            GT3D{i} = [];
        end
    end
    %GT = GT3D; % Filtered
    %GT = Xt; % Unfiltered
    for i = 1 : size(GT,2)
        numGTobj = numGTobj + size(GT{i},2);
    end
%plotEstWithoutDC
    for k = 1 : size(Z3D,2)
        if(~isempty(Z3D{k}))
            %[dCNN(k),fpCNN(k), fnCNN(k)] = GOSPA3D(GT{k},Z23D{k},k,'CNN',c_thresh);
            [dCNN(k),fpCNN(k), fnCNN(k),loc_errCNN(k), car_errCNN(k)] = GOSPA23D(GT{k},Xt{k},Z{k},Z3D{k},k,'CNN',c_thresh,GTdc{k}); % Unfiltered
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
            fnCNN(k) = xL;
            dCNN(k) = (0.5*c_thresh^p*(xL))^(1/p);
        end
    end

    fpCNN = sum(fpCNN);
    fnCNN = sum(fnCNN);

    dPMBM = zeros(1,size(Xest,2));
    for k = 1 : min(size(Xest,2),size(GT3D,2))

        if(~isempty(Xest{k}{1}))
            for i = 1:size(Xest{k},2)
                X{k}(1:5,i) = [H(Xest{k}{i},pose{k}(1:3,4), angles{k}.heading-angles{1}.heading); Xest{k}{i}(7:8)];
                Xest2{k}(1:3,i) = Xest{k}{i}(1:3);
            end
            %[dPMBM(k),fpPMBM(k), fnPMBM(k)] = GOSPA3D(GT3D{k},Xest2{k},k,'PMBM',c_thresh);
            [dPMBM(k),fpPMBM(k), fnPMBM(k),loc_errPMBM(k), car_errPMBM(k)] = GOSPA23D(GT{k},Xt{k},X{k},Xest2{k},k,'CNN',c_thresh,GTdc{k}); % Unfiltered
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
            if(~isempty(GT3D{k}))
                xL = length(find(GT{k}(6,:) ~= -1));
                fnPMBM(k) = xL;
            else
                xL = 0;
            end
            dPMBM(k) = (0.5*c_thresh^p*(xL))^(1/p);
        end
    end
    
    fpPMBM = sum(fpPMBM);
    fnPMBM = sum(fnPMBM);
    
    mean_loc_errCNN = mean(loc_errCNN);
    mean_loc_errPMBM = mean(loc_errPMBM);
    mean_car_errCNN = mean(car_errCNN);
    mean_car_errPMBM = mean(car_errPMBM);
    
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