clear all; clc;clf; close all;
plotOn = 0;
xlim = 5;
ylim = 10; % box where we can see targets
FOV = [xlim, ylim];
lambda_b = 200; % Probability of birth
%birth_threshold = poisspdf(1,lambda_b);
birth_threshold = random('Poisson', lambda_b);
flag = 1;
t = 0;
targets = cell(1);
nbrOftargets = 5;
maxNbrofTargets = 1;
colors = {'bo','go','ro','co','mo','yo','ko'};
labels = [1,2,3,4,5];
laneWidth = 1;
dToInter = 1.5;

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
            free_lab = freeLabel(targets{i},labels);
            mode = randi(3);
            object = generateNewObject(mode);
            if(~isempty(object))
                targets{i} = [targets{i},[object;free_lab]];
            end
            nbrOftargets = size(targets{i},2);
        end
    end
    if(plotOn)
        map = generateMap(laneWidth, FOV,dToInter);
        hold on;
        if(size(targets{i},2) ~= 0)
            for tar = 1 : size(targets{i},2)
                h(i,tar) = plot(targets{i}(1,tar),targets{i}(2,tar),colors{targets{i}(6,tar)});
                pause(0.01)
                hold on
                if(i > 20)
                    %if (ishandle(h(1:i-10,tar))) 
                        delete(h(1:i-10,tar)); 
                    %end;
                end
            end
        end
    end
    %i = i + 1;
end
%
z = generateMeasurements(targets, 0.5);
%%
if(plotOn)
    figure;
    for t = 1 : size(z,2)
        for i = 1 : size(z{t},2)
            plot(t,z{t}(i),'o')
            hold on;
            pause(0.1);
        end
    end
end

