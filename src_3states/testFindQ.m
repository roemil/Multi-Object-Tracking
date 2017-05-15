function [vx, vy] = testFindQ

set = 'training';

clear vx
clear vy
RimuToVelo = [9.999976e-01 7.553071e-04 -2.035826e-03;
        -7.854027e-04 9.998898e-01 -1.482298e-02;
        2.024406e-03 1.482454e-02 9.998881e-01];
tImuToVelo = [-8.086759e-01 3.195559e-01 -7.997231e-01]';
TimuToVelo = [RimuToVelo, tImuToVelo; 0 0 0 1];
TveloToImu = inv(TimuToVelo);

RveloToCam = [6.927964e-03 -9.999722e-01 -2.757829e-03;
    -1.162982e-03 2.749836e-03 -9.999955e-01;
    9.999753e-01 6.931141e-03 -1.143899e-03];
tVeloToCam = [-2.457729e-02 -6.127237e-02 -3.321029e-01]';
TveloToCam = [RveloToCam, tVeloToCam; 0 0 0 1];
TcamToVelo = inv(TveloToCam);

R02 = [9.999838e-01 -5.012736e-03 -2.710741e-03;
    5.002007e-03 9.999797e-01 -3.950381e-03;
    2.730489e-03 3.936758e-03 9.999885e-01];
t02 = [5.989688e-02 -1.367835e-03 4.637624e-03]';
T02 = [R02, t02; 0 0 0 1];
T20 = inv(T02);

T = 0.1;

for s = 0:20
    seq = sprintf('%04d',s);

    base_dir = strcat('../../kittiTracking/data_tracking_oxts/',set);
    filenameIMU = [base_dir,seq,'.txt'];
    sequence = str2num(seq)+1;
    oxts = loadOxtsliteData(base_dir,sequence:sequence);
    [pose, angles, posAcc] = egoPosition(oxts);

    datapath = strcat('../../kittiTracking/',set,'/','label_02/',seq);
    filename = [datapath,'.txt'];
    formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
    f = fopen(filename);
    GT = textscan(f,formatSpec);
    fclose(f);
    startK = 2;

    ind = find(GT{1} == 0 & GT{2} ~= -1);
    while isempty(ind)
        ind = find(GT{1} == startK-1 & GT{2} ~= -1);
        startK = startK+1;
    end
    
    oldLabels = GT{2}(ind);
    oldStates = [GT{14}(ind)';
            (GT{15}(ind)-GT{11}(ind)/2)';
            GT{16}(ind)'];
    oldStates = TveloToImu(1:3,:)*(TcamToVelo*(T20*[oldStates;ones(1,size(oldStates,2))]));
    heading = angles{1}.heading-angles{1}.heading;
    oldStates(1:2,:) = [cos(-heading), sin(-heading); -sin(-heading) cos(-heading)]*oldStates(1:2,:);
    oldStates = oldStates+pose{1}(1:3,4);

    for i = 1:size(ind,1)
        vx{str2num(seq)+1,oldLabels(i)+1} = [];
        vy{str2num(seq)+1,oldLabels(i)+1} = [];
    end
    %vx{str2num(seq)+1,size(ind,1)} = [];
    %vy{str2num(seq)+1,size(ind,1)} = [];

    for k = startK:max(GT{1})+1

        ind = find(GT{1} == k-1 & GT{2} ~= -1);

        newLabels = GT{2}(ind);

        newStates = [GT{14}(ind)';
        (GT{15}(ind)-GT{11}(ind)/2)';
        GT{16}(ind)'];
        newStates = TveloToImu(1:3,:)*(TcamToVelo*(T20*[newStates;ones(1,size(newStates,2))]));
        heading = angles{k}.heading-angles{1}.heading;
        newStates(1:2,:) = [cos(-heading), sin(-heading); -sin(-heading) cos(-heading)]*newStates(1:2,:);
        newStates = newStates+pose{k}(1:3,4);

        for i = 1:size(oldLabels,1)
            labelInd = find(oldLabels(i) == newLabels);
            if ~isempty(labelInd)
                vx{str2num(seq)+1,oldLabels(i)+1} = [vx{str2num(seq)+1,oldLabels(i)+1}, ...
                    (newStates(1,labelInd))/T];
                vy{str2num(seq)+1,oldLabels(i)+1} = [vy{str2num(seq)+1,oldLabels(i)+1}, ...
                    (newStates(2,labelInd))/T];
            end
        end
        for i = 1:size(newLabels,1)
            if isempty(find(newLabels(i) == oldLabels))
                vx{str2num(seq)+1,newLabels(i)+1} = [];
                vy{str2num(seq)+1,newLabels(i)+1} = [];
            end
        end

        oldLabels = newLabels;
        oldStates = newStates;
    end
end