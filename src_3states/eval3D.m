function [errCNN, errPMBM] = eval3D(plot1, plot2, set, sequence, Xest, Z, Z3D)
% Script for evaluating distance between estimate and GT in a 3D world

global TveloToImu, global TcamToVelo, global T20, global angles, global pose
global nbrPosStates
datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GTdc = generateGTdcTrunc(set,sequence,datapath,nbrPosStates);
GT = generateGTtrunc(set,sequence,datapath,nbrPosStates);
fclose(f);

c_thresh = 20;
errCNN = zeros(size(Xest,2),1);
errPMBM = zeros(size(Xest,2),1);

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
    
    if(~isempty(Z3D{k}))
        errCNN(k) = eval3DCNNsingleTime2(GT{k},Xt{k},Z{k},Z3D{k},k,'CNN',c_thresh,GTdc{k}, XtCamCoords{k}); % Unfiltered
    else
        errCNN(k) = [];
    end
    
    if(~isempty(Xest{k}{1}))
        for i = 1:size(Xest{k},2)
            X{k}(1:5,i) = [H(Xest{k}{i},pose{k}(1:3,4), angles{k}.heading-angles{1}.heading); Xest{k}{i}(7:8)];
            Xest2{k}(1:3,i) = Xest{k}{i}(1:3);
        end
        errPMBM(k) = eval3DCNNsingleTime2(GT{k},Xt{k},X{k},Zest2{k},k,'CNN',c_thresh,GTdc{k}, XtCamCoords);
    else
        errPMBM(k) = [];
    end
end


%% Plot err vs distance
if plot1
    figure;
    hold on
    %maxErr = zeros(2,1);
    for k = 1:size(Xest,2)
        if ~isempty(err{k})
            for i = 1:size(err{k},2)
                %if err{k}(1,i) > maxErr(1)
                %    maxErr = [err{k}(1,i);k];
                %end
                plot(err{k}(2,i),err{k}(1,i),'b+')
            end
        end
    end
    xlabel('Distance [m]')
    ylabel('Error [m]')
end

%% Plot relative to distance

if plot2
    relErr = [];
    for k = 1:size(Xest,2)
        if ~isempty(err{k})
            for i = 1:size(err{k},2)
                relErr = [relErr, err{k}(1,i)/err{k}(2,i)];
            end
        end
    end

    nRelErr = size(relErr,2);
    quant95 = quantile(relErr,0.95);
    figure
    histogram(relErr,20)
    hold on
    qua = plot([quant95,quant95],ylim,'r--');
    xlabel('Relative error')
    legend([qua],['quant95 = ', num2str(quant95)])
end
