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

function [newGlob, newInd] = generateGlobalHypo5(Xhypo, Xnew, Z, oldInd, Amat, hypoInd)

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
    Xtmp{1} = struct('state',[],'P',[],'w',1,'r',0,'S',0);
    for z = 1:m
        Xtmp{z}(z) = Xnew{z};
    end
end

% Insert all target according to A. Also add hypotheses for missed
% detections and that the global hypothesis does not consider the newly
% detected potential target

for j = 1:size(hypoInd,1)
    for i = 1:size(hypoInd,2)
        % Initiate
        newGlob{j}(1:nbrOldTargets+m) = struct('state',[],'P',[],'w',1,'r',0,'S',0);
        for col = 1:size(Amat,2)
            % Find combination
            newGlob{jInd}(Amat(1,col,i)) = Xtmp{col}(Amat(1,col,i));
        end
        for target = 1:size(newGlob{jInd},2)
            if isempty(newGlob{jInd}(target).state)
                if target <= nbrOldTargets
                    % Missed detection
                    newGlob{jInd}(target) = Xhypo{end}(target);
                else
                    % Does not consider newly detected potential target
                    newGlob{jInd}(target).state = Xnew{target-nbrOldTargets}.state;
                    newGlob{jInd}(target).P = Xnew{target-nbrOldTargets}.P;
                end
            end
        end
        jInd = jInd+1;
    end
end

% Update total number of global hypotheses
newInd = oldInd+jInd-1;