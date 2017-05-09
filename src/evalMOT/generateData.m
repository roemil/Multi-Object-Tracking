%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%(c) Copyright 2013 - MICC - Media Integration and Communication Center,
%University of Florence.
%Iacopo Masi and Giusppe Lisanti <masi,lisanti> @dsi.unifi.it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Generate ground-truth data

gt = cell(1);
result = [];
for i = 1 : size(Xest,2)
    for j = 1 : size(Z{i},2)
        gt{i}(j,1) = Z{i}(end,j);             % label
        gt{i}(j,2) = Z{i}(1,j)-Z{i}(3,j)*0.5; % Top left corner
        gt{i}(j,3) = Z{i}(2,j)-Z{i}(4,j)*0.5; % Top right corner
        gt{i}(j,4) = Z{i}(3,j);               % width
        gt{i}(j,5) = Z{i}(4,j);               % height
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
elseif(strcmp(motionModen,'cvBB'))
    %THIS IS FOR CVBB
    for i = 1 : size(Xest,2)
        jInd = 1;
        for j = 1 : size(Xest{i},2)
            if(~isempty(Xest{i}{j}))
                result(i).trackerData.idxTracks(jInd) = Xest{i}{j}(end);%
                result(i).trackerData.target(jInd).bbox = [Xest{i}{j}(1)-Xest{i}{j}(5)*0.5 Xest{i}{j}(2)-Xest{i}{j}(6)*0.5 Xest{i}{j}(5:6)'];%[camera2pixelcoords(Xest{i}{j}(1:3),P)', Xest{i}{j}(7:8)'];
            end
        end
    end
end
