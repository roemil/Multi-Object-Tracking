% Controlled movement and spawn
clear all; close all;
% Initate adjustable variables
nbrTimeSteps = 1000;
FOVsize = [20,30];  % FOV [x y]
sigmaQ = 0.01;  % covariance for change in movement
T = 0.1;
nbrInitTargets = 3;
labels = 1:1:nbrInitTargets;
veloRange = 5;
colors = ['r','b','k','c','g','y','m'];
maxNbrTargets = length(colors);
Pb = 0.05;
Pd = 0.9;

laneWidth = 3;
dToInter = 3;

% Setup map
map = figure;
roadBoarder = plot([laneWidth/2 laneWidth/2],[0 dToInter],'k');
hold on
plot([laneWidth/2 FOVsize(1)/2],[dToInter dToInter],'k')
plot([laneWidth/2 FOVsize(1)/2],[2*laneWidth+dToInter, 2*laneWidth+dToInter],'k')
plot([laneWidth/2 laneWidth/2], [2*laneWidth+dToInter, FOVsize(2)],'k')
plot([-1.5*laneWidth -1.5*laneWidth],[0 dToInter],'k')
plot([-1.5*laneWidth -1.5*FOVsize(1)],[dToInter dToInter],'k')
plot([-1.5*laneWidth -1.5*FOVsize(1)],[2*laneWidth+dToInter 2*laneWidth+dToInter],'k')
plot([-1.5*laneWidth -1.5*laneWidth], [2*laneWidth+dToInter, FOVsize(2)],'k')
midRoad = plot([-laneWidth/2 -laneWidth/2],[0 FOVsize(2)],'k--');
plot([-FOVsize(1)/2, FOVsize(1)/2],[laneWidth+dToInter, laneWidth+dToInter],'k--')
xlim([-FOVsize(1)/2,FOVsize(1)/2])
ylim([0, FOVsize(2)])
leg = legend([roadBoarder,midRoad],'roadBoarder','midRoad');
set(leg,'Fontsize',15,'Interpreter','Latex')

% Initate states
X = cell(1);

% CV initate each object
x1 = [-laneWidth; 15; 0; -1;labels(1); Pd];
x2 = [-1.5*laneWidth-1; dToInter+laneWidth/2; 1; 0; labels(2);Pd];
x3 = x2+[-1; 0; 0; 0; 0; -Pd];

PdVec = [x1(end), x2(end), x3(end)];

% CV initiate
X{1} = [x1,x2,x3];
      
for i = 1:nbrInitTargets
    figure(1);
    plot(X{1}(1,i), X{1}(2,i),['-*', num2str(colors(labels(i)))])
end

turn1 = 0;
turn2 = 0;
turn4 = 0;
turn5 = 0;

v1 = 10;

v2 = 10;
counter2 = 0;

% Go through the whole time serie
for k = 2:nbrTimeSteps
    % If we got previous targets
    if ~isempty(X{k-1})
        X{k} = motionGenerateControlled(X{k-1}(1:end-2,:),sigmaQ,T,'cv'); % Take step
        
        % Ugly fix
        [X{k}, labels, PdVec] = checkValid2(X{k},FOVsize,labels,PdVec); % Check if within FOV
        
        % Make car 2 turn
        if turn2 == 1
            for i = 1:size(X{k},2)
                if X{k}(5,i) == 2
                    X{k}(1:4,i) = motionCurve(X{k-1}(1:4,i),0,T,'cv',10);
                end
            end
            counter2 = counter2+1;
        end
        
        % Make car 1 turn
        if turn1 == 1
            for i = 1:size(X{k},2)
                if X{k}(5,i) == 1
                    X{k}(1:4,i) = motionCurve(X{k}(1:4,i),0,T,'cv',-10);
                end
            end
        end
        
        % Ugly fix
        X{k} = X{k}(1:4,:);
        
        [X{k}, labels, PdVec] = checkValid2(X{k},FOVsize,labels,PdVec); % Check if within FOV
        
        % Make car 3 detectable
        if counter2 == 5
            PdVec(3) = Pd;
            X{k}(end,3) = Pd;
        end
        
        % Start turn
        for i = 1:size(X{k},2)
            if X{k}(5,i) == 2
                if abs(abs(X{k}(1,i))-1.2*laneWidth) < 0.2
                    turn2 = 1;
                    v2 = sqrt(X{k}(3,i)^2+X{k}(4,i)^2);
                elseif abs(abs(X{k}(4,i))-v2) < 0.0002
                    turn2 = 0;
                    X{k}(3:4,i) = [0; -v2];
                end
            end
            if X{k}(5,i) == 1
                if abs(abs(X{k}(2,i))-dToInter-0.8*laneWidth) < 0.2
                    turn1 = 1;
                    v1 = sqrt(X{k}(3,i)^2+X{k}(4,i)^2);
                elseif abs(abs(X{k}(3,i))-v1) < 0.2
                    turn1 = 0;
                    X{k}(3:4,i) = [v1;0];
                end
            end
        end
        
        % TODO: MAKE MORE CARS TURN!!
        if k == 10
           x4 = [FOVsize(1)/2; dToInter+1.5*laneWidth; -2; 0; 4; Pd];
           labels = [labels, 4];
           PdVec = [PdVec, Pd];
           X{k} = [X{k}, x4];
        end
        
        if k == 15
           x5 = [-laneWidth; FOVsize(2); 0; -2; 5; Pd];
           labels = [labels, 5];
           PdVec = [PdVec, Pd];
           X{k} = [X{k}, x5];
        end
        
        % Plot each target
        for i = 1:size(X{k},2)
            figure(map);
            plot(X{k}(1,i), X{k}(2,i),['-*', num2str(colors(labels(i)))])
        end
        pause(0.01)
    end
end
        
