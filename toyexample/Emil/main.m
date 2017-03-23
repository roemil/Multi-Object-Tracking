clear all; clc;clf; close all;
xlim = 10;
ylim = 10; % box where we can see targets
FOV = [xlim, ylim];
lambda_b = 200; % Probability of birth
%birth_threshold = poisspdf(1,lambda_b);
birth_threshold = random('Poisson', lambda_b);
flag = 1;
t = 0;
targets = cell(1);
nbrOftargets = 1;
maxNbrofTargets = 5;
colors = {'bo','go','ro','co','mo','yo','ko'};
labels = [1,2,3,4,5];

figure;
hold on;
%for i = 2 : 20000 %time is running, move targets     
i = 2;
while(true)
    birth_threshold = random('exp', lambda_b);
    t = t + 0.05;
    targets{i} = targets{i-1};
    if(size(targets{i},2) ~= 0)
        for m = 1 : size(targets{i},2)
            targets{i}(:,m) = [motionGenerate(targets{i}(1:4,m),0.5,0.05,'cv');targets{i}(5,m)];
            
        end
    end
    targets{i} = checkValid(targets{i}, FOV);
    nbrOftargets = size(targets{i},2);
    if((t >= birth_threshold))
        if(nbrOftargets < maxNbrofTargets)
            free_lab = freeLabel(targets{i},labels);
            object = generateNewObject('random');
            if(~isempty(object))
                targets{i} = [targets{i},[object;free_lab]];
            end
            nbrOftargets = size(targets{i},2);
        end
    end
    if(size(targets{i},2) ~= 0)
        for tar = 1 : size(targets{i},2)
            plot(targets{i}(1,tar),targets{i}(2,tar),colors{targets{i}(5,tar)});
            pause(0.01)
            hold on
        end
    end
    i = i + 1;
end


