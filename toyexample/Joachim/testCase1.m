% Random spawn and movements
clear all; close all;
% Initate adjustable variables
nbrTimeSteps = 1000;
birthRate = 0.5;
FOVsize = [20,50];  % FOV [x y]
sigmaQ = 0.5;
T = 0.1;
nbrInitTargets = 3;
labels = 1:1:nbrInitTargets;
veloRange = 5;
colors = ['r','b','k','c','g','y','m'];
maxNbrTargets = length(colors);
Pb = 0.05;

% Initate states
X = cell(1);

% CV initiate
X{1} = [unifrnd(-FOVsize(1)/2, FOVsize(1)/2, 1, nbrInitTargets);
          unifrnd(0, FOVsize(2), 1, nbrInitTargets);
          unifrnd(-veloRange, veloRange, 1, nbrInitTargets);
          unifrnd(-veloRange, veloRange, 1, nbrInitTargets);
          labels];

% Generate birth vector
birthVec = birthGeneration(Pb, nbrTimeSteps);
      
% Initate figure
figure(1);
hold on
xlim([-FOVsize(1)/2,FOVsize(1)/2])
ylim([0, FOVsize(2)])
for i = 1:nbrInitTargets
    plot(X{1}(1,i), X{1}(2,i),['-o', num2str(colors(labels(i)))])
end

% Go through the whole time serie
for k = 2:nbrTimeSteps
    % If we got previous targets
    if ~isempty(X{k-1})
        X{k} = motionGenerate(X{k-1}(1:end-1,:),sigmaQ,T,'cv'); % Take step
        [X{k}, labels] = checkValid(X{k},FOVsize,labels); % Check if within FOV
        
        % If birth, generate new object
        if ((birthVec(k) > birthVec(k-1)) && (length(labels)+birthVec(k)-birthVec(k-1) < maxNbrTargets))
            [Xbirths, labels] = birthState(birthVec(k)-birthVec(k-1),FOVsize, labels, 'cv',maxNbrTargets);
            X{k} = [X{k}, Xbirths];
        end
            
        
        % Plot each target
        for i = 1:size(X{k},2)
            plot(X{k}(1,i), X{k}(2,i),['-o', num2str(colors(labels(i)))])
        end
        pause(0.1)
    end
end
        
