clear all; clc;clf; close all;
xlim = 10;
ylim = 10; % box where we can see targets
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
    targets{i} = checkValid(targets{i}, xlim, ylim);
    nbrOftargets = size(targets{i},2);
    %size(targets{i})
    if((t >= birth_threshold))
        if(nbrOftargets < maxNbrofTargets)
            %nbrOftargets = nbrOftargets + 1;
            nbrOftargets = size(targets{i},2) + 1;
            new_target_vx = randi(7)-4;
            new_target_vy = randi(7)-4;
            new_target_x = 10*rand(1); % spawn new target gaussian
            if(new_target_x > 10)
                new_target_x = 10;
                new_target_vx = -1*abs(new_target_vx);
            elseif(new_target_x < 0)
                new_target_x = 0;
                new_target_vx = abs(new_target_vx);
            end
            new_target_y = 10*rand(1); % spawn new target gaussian
            if(new_target_y > 10)
                new_target_y = 10;
                new_target_vy = -1*abs(new_target_vy);
            elseif(new_target_y < 0)
                new_target_y = 0;
                new_target_vy = abs(new_target_vy);
            end
%             for lab = 1 : length(labels)%%%% FIND WHICH LABEL IS FREE
%                for used_lab = 1 : size(targets{i},2)
%                    if(any(labels(lab) == targets{i}(5,used_lab)))
%                     %label is used
%                    else
%                        free_lab = labels(lab);
%                        break;
%                    end
%                end
%             end
            free_lab = freeLabel(targets{i},labels);
            targets{i} = [targets{i},[new_target_x; new_target_y;new_target_vx;new_target_vy;free_lab]];
            %nbrOftargets = size(targets{i},2);
        end
    end
    if(size(targets{i-1},2) ~= 0)
        for tar = 1 : size(targets{i},2)
            plot(targets{i}(1,tar),targets{i}(2,tar),colors{targets{i}(5,tar)});
            pause(0.01)
            hold on
        end
    end
    i = i + 1;
end


