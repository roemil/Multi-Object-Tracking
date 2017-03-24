clear all; clc;clf; close all;
plotOn = 1;
t = 0;
targets = {1};
targets{1} = [rand(1);rand(1);rand(1);rand(1);1;1];
nbrOftargets = 0;
maxNbrofTargets =1;
colors = {'bo','go','ro','co','mo','yo','ko'};

sigma = [0.3 0;0 0.3];

%for i = 2 : 20000 %time is running, move targets     
nbrOfTimeSteps = 200;
for i = 2 : nbrOfTimeSteps
    t = t + 0.05;
    targets{i} = targets{i-1};
    targets{i} = [motionGenerate(targets{i}(1:4),0,0.05,'cv');targets{i}(5:6)];
    %i = i + 1;
end
%
    [z, ~] = generateMeasurements(targets, sigma,'KF');
%
if(plotOn)
    figure;
    hold on;
    for t = 1 : nbrOfTimeSteps
        if(size(targets{t},2) ~= 0)
            h(t) = plot(targets{t}(1),targets{t}(2),colors{targets{t}(6)});
            hold on
%                 if(t > 20)
%                     %if (ishandle(h(1:i-10,tar))) 
%                         delete(h(1:t-1)); 
%                     %end;
%                 end
        end
    %
        if(~isempty(z{t}))
            for n = 1 : size(z{t},1)
                h2(t,n) = plot(z{t}(1),z{t}(2),'o','color',[0.2 0.5 0]);
                hold on;
            end
        end
    end
    
end

%%
R = [0.3 0;0 0.3];
P = kron(eye(2),[0.1 0;0 0.1]);
X = cell(1);
X{1} = [z{1}(1);z{1}(2);0;0];
H = [1 0 0 0;0 1 0 0];
T = 0.05;
F = [1 0 T 0;0 1 0 T;0 0 1 0;0 0 0 1];
Q = [T^3/3 0 T^2/2 0;
     0 T^3/3 0 T^2/2;
     T^2/2 0 T 0;
     0 T^2/2 0 T];
for t = 2 : size(z,2)
    [X{t},P] = kalmanfilterPred(X{t-1}, T, P, F, Q);
    [X{t},P] = kalmanfilterUpd(X{t-1}, P, T, H, R,z{t});
end

figure;
hold on;
for t = 1 : nbrOfTimeSteps
    if(size(targets{t},2) ~= 0)
        gt(t) = plot(targets{t}(1),targets{t}(2),colors{targets{t}(6)});
        hold on
        pred(t) = plot(X{t}(1),X{t}(2),'ok');
        meas(t) = plot(z{t}(1),z{t}(2),'or');
    end
end
legend('Ground truth','pred','meas')
