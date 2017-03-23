% Function to generate birth state
function [Xbirths, labels] = birthState(nbrBirths, FOVsize, labelsOld, model, maxNbrTargets)

Pmid = 0.05;
Ptop = 0.225;
Pbot = (1-2*Ptop-Pmid)/4;
Pside = (1-2*Ptop-Pmid)/4;
Pvec = [Ptop, 2*Ptop, 2*Ptop+Pbot, 2*Ptop+2*Pbot, 2*Ptop+2*Pbot+Pside, 2*Ptop+2*Pbot+2*Pside];

distanceFromCar = 2; % Targets appear further than 2m away from car
upperWidth = 4;
lowerWidth = 2;
sideWidth = 2;
percOwnSide = 0.7;

% Initate state vector
if strcmp(model,'cv')
    Xbirths = zeros(4,nbrBirths);
else
    disp('ERROR: Model not implemented!')
end

for i = 1:nbrBirths
    cmp = unifrnd(0,1);
    if cmp < Pvec(1)
        Xbirths(:,i) = [unifrnd(-FOVsize(1)/2,-percOwnSide*FOVsize(1)+FOVsize(1)/2);
                          unifrnd(FOVsize(2)-upperWidth,FOVsize(2));
                          unifrnd(-0.1,0.1);
                          unifrnd(-2,-0.5)];
    elseif cmp < Pvec(2)
        Xbirths(:,i) = [unifrnd(-percOwnSide*FOVsize(1)+FOVsize(1)/2,FOVsize(1)/2);
                          unifrnd(FOVsize(2)-upperWidth,FOVsize(2));
                          unifrnd(-0.1,0.1);
                          unifrnd(0.5,2)];
    elseif cmp < Pvec(3)
        Xbirths(:,i) = [unifrnd(-FOVsize(1)/2,-distanceFromCar);
                          unifrnd(0,lowerWidth);
                          unifrnd(-0.1,0.1);
                          unifrnd(0.5,2)];
    elseif cmp < Pvec(4)
        Xbirths(:,i) = [unifrnd(distanceFromCar,FOVsize(1)/2);
                          unifrnd(0,lowerWidth);
                          unifrnd(-0.1,0.1);
                          unifrnd(0.5,2)];
    elseif cmp < Pvec(5)
        Xbirths(:,i) = [unifrnd(-FOVsize(1)/2,-FOVsize(1)/2+sideWidth);
                          unifrnd(lowerWidth,FOVsize(2)-upperWidth);
                          unifrnd(0.5,2);
                          unifrnd(-0.1,0.1)];
    elseif cmp < Pvec(6)
        Xbirths(:,i) = [unifrnd(FOVsize(1)/2-sideWidth,FOVsize(1)/2);
                          unifrnd(lowerWidth,FOVsize(2)-upperWidth);
                          unifrnd(-2,-0.5);
                          unifrnd(-0.1,0.1)];
    else
        Xbirths(:,i) = [unifrnd(-FOVsize(1)/2+sideWidth,FOVsize(1)/2-sideWidth);
                          unifrnd(lowerWidth,FOVsize(2)-upperWidth);
                          unifrnd(-0.5,0.5);
                          unifrnd(-0.5,0.5)];
    end
    if max(labelsOld) < maxNbrTargets
        labels = [labelsOld, max(labelsOld)+1];
    elseif min(labelsOld) > 2
        labels = [labelsOld, min(labelsOld)-1];
    else
        tmp = unifrnd(2,6);
        while sum(tmp == labelsOld) > 0
            tmp = unifrnd(2,6);
        end
        labels = [labelsOld, tmp];
    end
    Xbirths(5,i) = labels(end);
end

        
        