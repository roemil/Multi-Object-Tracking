% Function to generate new global hypotheses from previous global
% hypothesis j.
% 
% Input:    Xhypo:      Single target hypotheses from previous potential targets
%           Xnew:       Single target hypotheses of newly potentially detected
%                       targets
%           Z:          Measurement at the current time
%           oldInd:     Index for earlier total of global hypotheses
%
% Output:   newGlob:    New global hypotheses
%           newInd:     New number of total global hypotheses
%
%

function [newGlob, newInd] = generateGlobalHypo6(Xhypo, Xnew, Z, oldInd, S, nbrOldTargets)
global color
% Number of measurements
m = size(Z,2);

% If we have hypotheses from previously potential targets, find all
% combinations. Else the only global hypothesis consists of newly detected
% potential targets

% Store old hypotheses and new hypotheses in a common variable
if ~isempty(Xhypo{1})
    for i = 1:m
        Xtmp{i} = Xhypo{i};
    end
    for z = 1:m
        Xtmp{z}(end+z) = Xnew{z};
    end
else
    if ~color
        Xtmp{1} = struct('state',[],'P',[],'w',0,'r',0,'S',0,'box',[],'label',0,'nbrMeasAss',0);
    else
        Xtmp{1} = struct('state',[],'P',[],'w',0,'r',0,'S',0,'box',[],'label',0,'nbrMeasAss',0,'red',0,'green',0,'blue',0);
    end
    for z = 1:m
        Xtmp{z}(z) = Xnew{z};
    end
end

% Insert all target according to A. Also add hypotheses for missed
% detections and that the global hypothesis does not consider the newly
% detected potential target

for j = 1:size(S,3)
    % Initiate
    if ~color
        newGlob{j}(1:nbrOldTargets+m) = struct('state',[],'P',[],'w',0,'r',0,'S',0,'box',[],'label',0,'nbrMeasAss',0);
    else
        newGlob{j}(1:nbrOldTargets+m) = struct('state',[],'P',[],'w',0,'r',0,'S',0,'box',[],'label',0,'nbrMeasAss',0,'red',0,...,
        'green',0,'blue',0); % TAGass
    end
    for col = 1:size(S,1)
        % Find combination
        newGlob{j}(find(S(col,:,j) == 1)) = Xtmp{col}(find(S(col,:,j) == 1));
    end
    for target = 1:size(newGlob{j},2)
        if isempty(newGlob{j}(target).state)
            if target <= nbrOldTargets
                % Missed detection
                newGlob{j}(target) = Xhypo{end}(target);
            else
                % Does not consider newly detected potential target
                newGlob{j}(target).state = Xnew{target-nbrOldTargets}.state;
                newGlob{j}(target).P = Xnew{target-nbrOldTargets}.P;
                newGlob{j}(target).label = Xnew{target-nbrOldTargets}.label;
            end
        end
    end
end

% Update total number of global hypotheses
newInd = oldInd+j;