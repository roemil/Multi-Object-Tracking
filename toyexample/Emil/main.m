clear all; clc;clf; close all;
plotOn = 1;
xlim = 5;
ylim = 10; % box where we can see targets
FOV = [xlim, ylim];
lambda_b = 200; % Probability of birth
%birth_threshold = poisspdf(1,lambda_b);
birth_threshold = random('Poisson', lambda_b);
flag = 1;
t = 0;
targets = cell(1);
nbrOftargets = 0;
maxNbrofTargets = 5;
colors = {'bo','go','ro','co','mo','yo','ko'};
labels = [1,2,3,4,5];
laneWidth = 1;
dToInter = 1.5;
sigma = [0.1 0.01];

%for i = 2 : 20000 %time is running, move targets     
nbrOfTimeSteps = 1000;
for i = 2 : nbrOfTimeSteps
    birth_threshold = random('exp', lambda_b);
    t = t + 0.05;
    targets{i} = targets{i-1};
    if(size(targets{i},2) ~= 0)
        for m = 1 : size(targets{i},2)
            targets{i}(:,m) = [motionGenerate(targets{i}(1:4,m),0,0.05,'cv');targets{i}(5:6,m)];
            
        end
    end
    targets{i} = checkValid(targets{i}, FOV);
    nbrOftargets = size(targets{i},2);
    if((t >= birth_threshold))
        if(nbrOftargets < maxNbrofTargets)
            free_lab = freeLabel(targets{i},labels); % check which labels that are free
            mode = randi(3); % which car do we generate?
            object = generateNewObject(mode);
            if(~isempty(object))
                targets{i} = [targets{i},[object;free_lab]];
            end
            nbrOftargets = size(targets{i},2);
        end
    end
    %i = i + 1;
end
%
[z, zclutter] = generateMeasurements(targets, sigma,'KF');
%
if(plotOn)
    map = generateMap(laneWidth, FOV,dToInter);
    hold on;
    for t = 1 : nbrOfTimeSteps
        if(size(targets{t},2) ~= 0)
            for tar = 1 : size(targets{t},2)
                h(t,tar) = plot(targets{t}(1,tar),targets{t}(2,tar),colors{targets{t}(6,tar)});
                pause(0.01)
                hold on
                if(t > 20)
                    %if (ishandle(h(1:i-10,tar))) 
                        delete(h(1:t-1,tar)); 
                    %end;
                end
            end
        end
        
        if(~isempty(z{t}))
            for n = 1 : size(z{t},1)
                h2(t,n) = plot(z{t}(n,1)*cos(z{t}(n,2)),z{t}(n,1)*sin(z{t}(n,2)),'o','color',[0.2 0.5 0]);
                hold on;
                delete(h2(1:t-1,n));
                hc(t) = plot(zclutter{t}(1,1)*cos(zclutter{t}(1,2)),zclutter{t}(1,1)*sin(zclutter{t}(1,2)),'o','color',[0.7 0.5 0]);
                hold on
                delete(hc(1:t-50));
                pause(0.01);
                end
        end
    end
end

