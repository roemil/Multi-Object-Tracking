function err = eval3D(plot1, plot2, set, sequence, Xest, err)
% Script for evaluating distance between estimate and GT in a 3D world

if nargin < 6
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

        Xt = [GT{14}(ind)';
                (GT{15}(ind)-GT{11}(ind)/2)';
                GT{16}(ind)'];
        XtCamCoords = Xt;
        Xt = TveloToImu(1:3,:)*(TcamToVelo*(T20*[Xt;ones(1,size(Xt,2))]));
        heading = angles{k}.heading-angles{1}.heading;
        Xt(1:2,:) = [cos(-heading), sin(-heading); -sin(-heading) cos(-heading)]*Xt(1:2,:);
        Xt = Xt+pose{k}(1:3,4);
        Xt(7,:) = GT{2}(ind)';

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

    figure
    histogram(relErr,20)
    xlabel('Relative error')
end
