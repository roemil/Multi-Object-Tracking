function err = eval3Dcnn(plot1, plot2, set, sequence, Xest)
% Script for evaluating distance between estimate and GT in a 3D world

global TveloToImu, global TcamToVelo, global T20, global angles, global pose
datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);

err = cell(size(Xest,2),1);

for k = 1:size(Xest,2)
    ind = find(GT{1} == k-1 & GT{2} ~= -1);
    ind2 = find((~strcmp(GT{3}(ind),'Van')) & (~strcmp(GT{3}(ind),'Tram')) & (~strcmp(GT{3}(ind),'Truck')) & (~strcmp(GT{3}(ind),'Misc')));
    ind = ind(ind2);
    if ~isempty(ind)
        Xt = [GT{14}(ind)';
                (GT{15}(ind)-GT{11}(ind)/2)';
                GT{16}(ind)'];
        %XtCamCoords = Xt; Here?
        Xt = TveloToImu(1:3,:)*(TcamToVelo*(T20*[Xt;ones(1,size(Xt,2))]));
        XtCamCoords = Xt;
        heading = angles{k}.heading-angles{1}.heading;
        Xt(1:2,:) = [cos(-heading), sin(-heading); -sin(-heading) cos(-heading)]*Xt(1:2,:);
        Xt = Xt+pose{k}(1:3,4);
        Xt(7,:) = GT{2}(ind)';
    else
        Xt = [];
        XtCamCoords = [];
    end

    if ~isempty(Xest{k})
        if ~isempty(Xest{k}{1})
            err{k} = eval3DsingleTime(Xest{k},Xt,XtCamCoords);
        else
            err{k} = {};
        end
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
