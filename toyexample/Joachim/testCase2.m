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
Pd = 0.95;
sigmaR = 0.01;
R = sigmaR*[1 0;0 1];

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
% leg = legend([roadBoarder,midRoad],'roadBoarder','midRoad');
% set(leg,'Fontsize',15,'Interpreter','Latex')

object = plot(-10,-10,'k*');
meas = plot(-10,-10,'+','Color',[.7 .5 0]);

leg = legend([roadBoarder,midRoad,object,meas],'roadBoarder','midRoad','Objects','Measurements');
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

% Measurement initiate
Z = cell(1);

initPlot = {};
for i = 1:nbrInitTargets
    figure(1);
    initPlot = [initPlot plot(X{1}(1,i), X{1}(2,i),['-*', num2str(colors(labels(i)))])];
end

turn1 = 0;
turn2 = 0;
turn3 = 0;
turn4 = 0;
turn5 = 0;

activeCurve1 = 0;
activeCurve2 = 0;
activeCurve3 = 0;
activeCurve4 = 0;
activeCurve5 = 0;

v1 = 10;
v2 = 10;
v3 = 10;
v4 = 10;
v5 = 10;
counter2 = 0;

emptyFlag = 0;
measPlot = {};
objPlot = {};

% Go through the whole time serie
for k = 2:nbrTimeSteps
    % If we got previous targets
    if ((~isempty(X{k-1})) && (emptyFlag == 0))
        X{k} = motionGenerateControlled(X{k-1}(1:end-2,:),sigmaQ,T,'cv'); % Take step
        
        % Ugly fix
        [X{k}, labels, PdVec] = checkValid2(X{k},FOVsize,labels,PdVec); % Check if within FOV
        
        if isempty(X{k})
            emptyFlag = 1;
            break
        end
        
        %%%%% Make car 2 turn %%%%%
        if turn2 == 1
            for i = 1:size(X{k},2)
                if X{k}(5,i) == 2
                    for j = 1:size(X{k-1},2)
                        if X{k-1}(5,j) == 1
                            X{k}(1:4,i) = motionCurve(X{k-1}(1:4,i),0,T,'cv',10);
                        end
                    end
                end
            end
            counter2 = counter2+1;
        end
        
        %%%%% Make car 1 turn %%%%%
        if turn1 == 1
            for i = 1:size(X{k},2)
                if X{k}(5,i) == 1
                    for j = 1:size(X{k-1},2)
                        if X{k-1}(5,j) == 1
                            X{k}(1:4,i) = motionCurve(X{k-1}(1:4,j),0,T,'cv',-10);
                        end
                    end
                end
            end
        end
        
        %%%%% Make car 3 turn %%%%%
        if turn3 == 1
            for i = 1:size(X{k},2)
                if X{k}(5,i) == 3
                    for j = 1:size(X{k-1},2)
                        if X{k-1}(5,j) == 3
                            X{k}(1:4,i) = motionCurve(X{k-1}(1:4,j),0,T,'cv',-10);
                        end
                    end
                end
            end
        end
        
        %%%%% Make car 5 turn %%%%%
        if turn5 == 1
            for i = 1:size(X{k},2)
                if X{k}(5,i) == 5
                    for j = 1:size(X{k-1},2)
                        if X{k-1}(5,j) == 5
                            X{k}(1:4,i) = motionCurve(X{k-1}(1:4,j),0,T,'cv',-5);
                        end
                    end
                end
            end
        end
        
        % Ugly fix
        X{k} = X{k}(1:4,:);
        [X{k}, labels, PdVec] = checkValid2(X{k},FOVsize,labels,PdVec); % Check if within FOV
        
        if isempty(X{k})
            emptyFlag = 1;
            break
        end
        
        %%%%% Make car 3 detectable %%%%%
        if counter2 == 5
            for i = 1:size(X{k},2)
                if X{k}(5,i) == 3
                    PdVec(3) = Pd;
                    X{k}(end,3) = Pd;
                end
            end
        end

        %%%%% Start turn %%%%%
        for i = 1:size(X{k},2)
            % Car 2
            if X{k}(5,i) == 2
                if ((abs(abs(X{k}(1,i))-1.2*laneWidth) < 0.2) && (activeCurve2 == 0))
                    turn2 = 1;
                    v2 = sqrt(X{k}(3,i)^2+X{k}(4,i)^2);
                elseif abs(abs(X{k}(4,i))-v2) < 0.0002
                    turn2 = 0;
                    X{k}(3:4,i) = [0; -v2];
                end
            end
            % Car 1
            if X{k}(5,i) == 1
                if ((abs(abs(X{k}(2,i))-dToInter-0.7*laneWidth) < 0.2) && (activeCurve1 == 0) )
                    turn1 = 1;
                    v1 = sqrt(X{k}(3,i)^2+X{k}(4,i)^2);
                    activeCurve1 = 1;
                elseif abs(abs(X{k}(3,i))-v1) < 0.2
                    turn1 = 0;
                    X{k}(3:4,i) = [v1;0];
                end
            end
            % Car 3
            if X{k}(5,i) == 3
                if ((abs(abs(X{k}(1,i))-0.2*laneWidth) < 0.2) && (activeCurve3 == 0))
                    turn3 = 1;
                    v3 = sqrt(X{k}(3,i)^2+X{k}(4,i)^2);
                    activeCurve3 = 1;
                elseif abs(abs(X{k}(4,i))-v3) < 0.000002
                    turn3 = 0;
                    X{k}(3:4,i) = [0;v3];
                end
            end
            % Car 5
            if X{k}(5,i) == 5
               if ((abs(abs(X{k}(2,i))-dToInter-1.5*laneWidth) < 0.2) && (activeCurve5 == 0))
                   turn5 = 1;
                   v5 = sqrt(X{k}(3,i)^2+X{k}(4,i)^2);
                   activeCurve5 = 1;
               elseif ((abs(abs(X{k}(4,i))-v5) < 0.02) && (X{k}(4,i) > 0))
                   turn5 = 0;
                   X{k}(3:4,i) = [0;v5];
                   for j = 1:size(X{k},2)
                       if X{k}(5,j) == 3
                           PdVec(j) = 0;
                           X{k}(6,j) = 0;
                       end
                   end
               end
            end
        end
        
        if k == 10
           x4 = [FOVsize(1)/2; dToInter+1.5*laneWidth; -2; 0; 4; Pd];
           labels = [labels, 4];
           PdVec = [PdVec, Pd];
           X{k} = [X{k}, x4];
        end
        
        if k == 2
           x5 = [-laneWidth; FOVsize(2); 0; -1.3; 5; Pd];
           labels = [labels, 5];
           PdVec = [PdVec, Pd];
           X{k} = [X{k}, x5];
        end
        
        % Remove init plot
        if k == 2
            delete(initPlot)
        end
        
        % Plot each target
        
        if k > 2
            delete(objPlot)
        end
        for i = 1:size(X{k},2)
            figure(map);
            objPlot = [objPlot plot(X{k}(1,i), X{k}(2,i),['-*', num2str(colors(labels(i)))])];
        end
        pause(0.001)
    end
    
    Z{k} = [];
    % Generate measurement if detected
    for i = 1:size(X{k},2)
        detObject = unifrnd(0,1);
        if detObject < X{k}(6,i)
            Z{k} = [Z{k}, measGenerate(X{k}(:,i),R)];
        end
    end
    
    if isempty(Z{k})
        ind = randi(size(X{k},2));
        Z{k} = measGenerate(X{k}(:,ind),R);
    end
    
    % Number of clutter measurements, 0,1,2
    nbrClutter = randi(2)-1;
    for i = 1:nbrClutter
       %Z{k} = [Z{k}, [unifrnd(1,20); unifrnd(-pi,pi)]]; % For distance and
       %angle
       Z{k} = [Z{k}, [unifrnd(-FOVsize(1)/2, FOVsize(1)/2); unifrnd(0, FOVsize(2))]];
    end
    
    %Rearrenge measurement order
    Z{k} = Z{k}(:,randperm(size(Z{k},2)));
    if k > 2
        delete(measPlot)
    end
    
    for i = 1:size(Z{k},2)
        figure(map)
        measPlot = [measPlot, plot(Z{k}(1,i),Z{k}(2,i),'+','Color',[.7 .5 0])];
        %measPlot = [measPlot, plot(Z{k}(1,i)*cos(Z{k}(2,i)),Z{k}(1,i)*sin(Z{k}(2,i)),'+','Color',[.7 .5 0])];
    end
end
