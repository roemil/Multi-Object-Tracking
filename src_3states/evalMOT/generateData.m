%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Copyright 2013 - MICC - Media Integration and Communication Center,
%University of Florence.
%Iacopo Masi and Giusppe Lisanti <masi,lisanti> @dsi.unifi.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Generate ground-truth data
global H
global pose
global angles
global simMeas
gt = cell(1);
result = [];

if simMeas
    datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
    Ztmp = generateGT(set,sequence,datapath, nbrPosStates);

    iInd = 1;
    for i = 1 : size(Xest,2)
        jInd = 1;
        for j = 1 : size(Z{i},2)
            if(~isempty(Z{i}))
                resultZ(iInd).trackerData.idxTracks(jInd) = Z{i}(6,j);%
                resultZ(iInd).trackerData.target(jInd).bbox = [Z{i}(1,j)-Z{i}(4,j)*0.5 Z{i}(2,j)-Z{i}(5,j)*0.5, Z{i}(4:5,j)'];
                jInd = jInd + 1;
            else
                iInd = iInd - 1;
                continue;
            end
        end
        iInd = iInd+1;
    end
elseif strcmp(mode,'CNNnonlinear')
    datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
    Ztmp = generateGT(set,sequence,datapath, nbrPosStates);

    iInd = 1;
    for i = 1 : size(Xest,2)
        jInd = 1;
        for j = 1 : size(Z{i},2)
            if(~isempty(Z{i}))
                resultZ(iInd).trackerData.idxTracks(jInd) = j;%
                resultZ(iInd).trackerData.target(jInd).bbox = [Z{i}(1,j)-Z{i}(4,j)*0.5 Z{i}(2,j)-Z{i}(5,j)*0.5, Z{i}(4:5,j)'];
                jInd = jInd + 1;
            else
                iInd = iInd - 1;
                continue;
            end
        end
        iInd = iInd+1;
    end
else
    Ztmp = Z;
end

for i = 1 : size(Xest,2)
    for j = 1 : size(Ztmp{i},2)
        gt{i}(j,1) = Ztmp{i}(end,j);             % label
        gt{i}(j,2) = Ztmp{i}(1,j)-Ztmp{i}(4,j)*0.5; % Top left corner
        gt{i}(j,3) = Ztmp{i}(2,j)-Ztmp{i}(5,j)*0.5; % Top right corner
        gt{i}(j,4) = Ztmp{i}(4,j);               % width
        gt{i}(j,5) = Ztmp{i}(5,j);               % height
    end
end

% Generate tracking data
% THIS IS FOR CA
if(strcmp(motionModel,'ca'))
    iInd = 1;
    for i = 1 : size(Xest,2)
        jInd = 1;
        for j = 1 : size(Xest{i},2)
            if(~isempty(Xest{i}{j}))
                result(iInd).trackerData.idxTracks(jInd) = Xest{i}{j}(end); % label
                result(iInd).trackerData.target(jInd).bbox = [Xest{i}{j}(1)-Xest{i}{j}(7)*0.5 Xest{i}{j}(2)-Xest{i}{j}(8)*0.5 Xest{i}{j}(7:8)'];%[camera2pixelcoords(Xest{i}{j}(1:3),P)', Xest{i}{j}(7:8)'];
                jInd = jInd + 1;
            else
                iInd = iInd - 1;
                continue;
            end
        end
        iInd = iInd + 1;
    end
elseif(strcmp(motionModel,'cvBB'))
    iInd = 1;
    %THIS IS FOR CVBB
    for i = 1 : size(Xest,2)
        jInd = 1;
        for j = 1 : size(Xest{i},2)
            if(~isempty(Xest{i}{j}))
                result(iInd).trackerData.idxTracks(jInd) = Xest{i}{j}(end);%
                heading = angles{i}.heading-angles{1}.heading;
                tmp = H(Xest{i}{j}(1:8),pose{i}(1:3,4),heading);
                result(iInd).trackerData.target(jInd).bbox = [tmp(1)-Xest{i}{j}(7)*0.5 tmp(2)-Xest{i}{j}(8)*0.5 Xest{i}{j}(7:8)'];%[camera2pixelcoords(Xest{i}{j}(1:3),P)', Xest{i}{j}(7:8)'];
                jInd = jInd + 1;
            else
                iInd = iInd - 1;
                continue;
            end
        end
        iInd = iInd+1;
    end
end
