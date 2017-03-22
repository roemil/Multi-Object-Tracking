clear all; clc;clf; close all;
xlim = 10;
ylim = 10; % box where we can see targets

Nu = 3;
targets = [];
k = 0;
lambda_b = 2; % Probability of birth
%birth_threshold = poisspdf(1,lambda_b);
birth_threshold = random('Poisson', lambda_b);
flag = 1;
t = 0;
targets = cell(1);
nbrOftargets = 1;
maxNbrofTargets = 5;
colors = {'bo','go','ro','co','mo','yo','ko'};
new_target_x = 1/sqrt(2)*randn(1,1); % spawn new target uniformly
new_target_y = 1/sqrt(2)*randn(1,1); % spawn new target uniformly
new_target_vx = 1;
new_target_vy = 1;

targets{1} = [new_target_x;new_target_y;new_target_vx;new_target_vy];
figure;
hold on;
%for i = 2 : 20000 %time is running, move targets     
i = 2;
while(true)
    t = t + 0.05;
    for m = 1 : size(targets{i-1},2)
            targets{i}(:,m) = motionGenerate(targets{i-1}(:,m),0.5,0.05,'cv');
            if(abs(targets{i}(1,m)) >= xlim || abs(targets{i}(2,m)) >= ylim)
                targets{i}(:,m) = [];
                nbrOftargets = nbrOftargets - 1;
            end 
    end
    size(targets{i})
    if(t >= birth_threshold && flag == 1)
        if(nbrOftargets > maxNbrofTargets)
            flag = 0;
        end
        new_target_x = 5*randn(1,1); % spawn new target uniformly
        new_target_y = 5*randn(1,1); % spawn new target uniformly
        new_target_vx = randi(7)-4;
        new_target_vy = randi(7)-4;
        targets{i} = horzcat(targets{i},[new_target_x; new_target_y;new_target_vx;new_target_vy]);
        nbrOftargets = nbrOftargets + 1;
    end
    
    for tar = 1 : size(targets{i},2)
        plot(targets{i}(1,tar),targets{i}(2,tar),colors{tar});
        pause(0.01)
        hold on
        %a = [a,targets{time}(:,tar)]
    end
    if(size(targets,2) > 1000)
        tmp = targets; % remove old data so I don't store too much of it
        targets = cell(1);
        targets = tmp{1:2};
    end
    i = i + 1;
end

%
% hold on;
% a = [];
% %
% figure;
% hold on;
% for time = 1:length(targets)
%     for tar = 1 : size(targets{time},2)
%         plot(targets{time}(1,tar),targets{time}(2,tar),colors{tar});
%         pause(0.1)
%         hold on
%         %a = [a,targets{time}(:,tar)]
%     end
% end
% xlim([-10 10]);
% ylim([-10 10])

%%
% for b = 1 : length(a)
%         plot(a(1,b),a(2,b),'-*b')
%         pause(0.1)
%         hold on;
%     %end
% end
