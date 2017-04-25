clear Xest
clear Pest
close all
dbstop error
clc
mode = 'linear';
set = 'training';
sequence = '0000';
motionModel = 'cv'; % Choose 'cv' or 'cvBB'

[nbrInitBirth, wInit, FOVinit, vinit, covBirth, Z, nbrOfBirths, maxKperGlobal, maxNbrGlobal, Nhconst] ...
    = declareVariables(mode,set,sequence,motionModel);

% TODO: Should the weights be 1/nbrInitBirth?
if strcmp(motionModel,'cv')
    for i = 1:nbrInitBirth
        XmuUpd{1}(i).w = wInit;    % Pred weight
        XmuUpd{1}(i).state = [unifrnd(FOVinit(1,1), FOVinit(2,1)), ...
            unifrnd(FOVinit(1,2), FOVinit(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';      % Pred state
        XmuUpd{1}(i).P = covBirth*eye(4);      % Pred cov

        XuUpd{1}(i).w = wInit;    % Pred weight
        XuUpd{1}(i).state = [unifrnd(FOVinit(1,1), FOVinit(2,1)), ...
            unifrnd(FOVinit(1,2), FOVinit(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';      % Pred state
        XuUpd{1}(i).P = covBirth*eye(4);      % Pred cov
    end
elseif strcmp(motionModel,'cvBB')
    for i = 1:nbrInitBirth
        XmuUpd{1}(i).w = wInit;    % Pred weight
        XmuUpd{1}(i).state = [unifrnd(FOVinit(1,1), FOVinit(2,1)), ...
            unifrnd(FOVinit(1,2), FOVinit(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), 0, 0]';      % Pred state
        XmuUpd{1}(i).P = covBirth*eye(6);      % Pred cov

        XuUpd{1}(i).w = wInit;    % Pred weight
        XuUpd{1}(i).state = [unifrnd(FOVinit(1,1), FOVinit(2,1)), ...
            unifrnd(FOVinit(1,2), FOVinit(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), 0, 0]';      % Pred state
        XuUpd{1}(i).P = covBirth*eye(6);      % Pred cov
    end
end

Xupd = cell(1);

% For birth case
% ind = 1;
% for i = 1 : size(z,2)
%     if(~isempty(z{i}))
%         Z{ind} = z{i};
%         ind = ind + 1;
%     end
% end

K = 100; %size(Z,2); % Length of sequence

nbrSim = 1; % Nbr of simulations

nbrMissmatch = zeros(1,nbrSim);
newLabel = 1;

jEst = zeros(1,K);

plotOn = 'false';
startTime = tic;
for t = 1:nbrSim
    disp('-------------------------------------')
    disp(['--------------- t = ', num2str(t), ' ---------------'])
    disp('-------------------------------------')
    
    %Z = measGenerateCase2(X, R, FOVsize, K);
    [XuUpd{t,1}, Xupd{t,1}, Xest{t,1}, Pest{t,1}, rest{t,1}, west{t,1}, labelsEst{t,1}, newLabel, jEst(1)] = ...
        PMBMinitFunc(Z{t,1}, XmuUpd{t,1}, XuUpd{t,1}, nbrOfBirths, maxKperGlobal, maxNbrGlobal, newLabel);

    if strcmp(plotOn,'true')
        frameNbr = '000000';
        if ~strcmp(mode,'GT')
            plotDetections(set, sequence, frameNbr, Xest{1}, FOVsize)
            %plotUndetected(XmuUpd{1,1}, figHandle)
        else
            plotDetectionsGT(set, sequence, frameNbr, Xest{1}, FOVsize, Z{1})
        end
        title('k = 1')
        pause(0.1)
        %keyboard
    end
    
    % Only keep births
    tmp = XuUpd;
    clear XuUpd;
    XuUpd{1,1}(1:nbrOfBirths) = tmp{1,1}(end-nbrOfBirths+1:end);
    
    for k = 2:K % For each time step
        disp(['--------------- k = ', num2str(k), ' ---------------'])
        Nh = Nhconst*size(Z{k},2);    %Murty
%         if k == 25
%             keyboard
%         end
        % TODO: Should perform prediction but not update!
        tic;
        if ~isempty(Z{k})
            [XuUpd{t,k}, Xpred{t,k}, Xupd{t,k}, Xest{t,k}, Pest{t,k}, rest{t,k}, west{t,k}, labelsEst{t,k}, newLabel, jEst(k)] = ...
                PMBMfunc(Z{t,k}, XuUpd{t,k-1}, Xupd{t,k-1}, Nh, nbrOfBirths, maxKperGlobal, maxNbrGlobal, newLabel, k);
        else
            [XuUpd{t,k}, Xpred{t,k}, Xupd{t,k}, Xest{t,k}, Pest{t,k}, rest{t,k}, west{t,k}, labelsEst{t,k}, newLabel, jEst(k)] = ...
                PMBMpredFunc(Z{t,k}, XuUpd{t,k-1}, Xupd{t,k-1}, Nh, nbrOfBirths, maxKperGlobal, maxNbrGlobal, newLabel, k);
        end
        disp(['Iteration time: ', num2str(toc)])
        %disp(['Nbr targets: ', num2str(size(X{t,k},2))])
        %disp(['Nbr estimates: ', num2str(size(Xest{t,k},2))])
        %disp(['Nbr prop targets: ', num2str(sum(rest{t,k} == 1))])
        %disp(['Nbr clutter points: ', num2str(size(Z{k},2)-size(X{k},2))])
        %if size(X{t,k},2) ~= size(Xest{t,k},2)
        %    nbrMissmatch(t) = nbrMissmatch(t)+1;
        %end

        if strcmp(plotOn, 'true')
            frameNbr = sprintf('%06d',k-1);
            if ~strcmp(mode,'GT')
                plotDetections(set, sequence, frameNbr, Xest{k}, FOVsize)
            else
                plotDetectionsGT(set, sequence, frameNbr, Xest{k}, FOVsize, Z{k})
            end
            title(['k = ', num2str(k)])
            pause(0.1)
        end
    end
    
end
simTime = toc(startTime);

disp('--------------- Simulation Complete ---------------')
disp(['Total simulation time: ', num2str(simTime)])
    

% Plot estimates

figure;
for k = 1:size(Xest,2)
    frameNbr = sprintf('%06d',k-1);
    if ~strcmp(mode,'GT')
        plotDetections(set, sequence, frameNbr, Xest{k}, FOVsize)
    else
        plotDetectionsGT(set, sequence, frameNbr, Xest{k}, FOVsize, Z{k})
    end
    title(['k = ', num2str(k)])
    waitforbuttonpress
    %pause(1.5)
end

%% Plot estimates

figure;
for k = 1:size(Xest,2)
    frameNbr = sprintf('%06d',k-1);
    if ~strcmp(mode,'GT')
        plotDetections(set, sequence, frameNbr, Xest{k}, FOVsize)
    else
        plotDetectionsGT(set, sequence, frameNbr, Xest{k}, FOVsize, Z{k})
    end
    title(['k = ', num2str(k)])
    waitforbuttonpress
    %pause(1.5)
end

%% Plot pred and upd
figure;
for k = 2:size(Xest,2)
    frameNbr = sprintf('%06d',k-1);
    plotPredUpd(set, sequence, frameNbr, Xpred{1,k}, Xupd{1,k-1},FOVsize)
    title(['k = ', num2str(k)])
    waitforbuttonpress
end

%% Plot single pred and upd
i = 1;

for k = 2:size(Xest,2)
    k
    frameNbr = sprintf('%06d',k-1);
    plotSinglePredUpd(set, sequence, frameNbr, Xpred{1,k}{jEst(k-1)}, Xupd{1,k}{jEst(k)},i,FOVsize)
    title(['k = ', num2str(k)])
    waitforbuttonpress
end

%% Estimated velocities

veloEst = zeros(2,5,size(Xest,2));
labels = zeros(1,5,size(Xest,2));
for k = 2:size(Xest,2)
    for i = 1:size(Xest{1,k},2)
        if ~isempty(Xest{1,k}{i})
            veloEst(1:2,i,k) = Xest{1,k}{i}(3:4);
            labels(1,i,k) = Xest{1,k}{i}(7);
        end
    end
end

%% Stack rest, labelsEst and west

rlabelsw = cell(1);
for k = 1:size(Xest,2)
    rlabelsw{k} = [rest{1,k}; labelsEst{1,k}; west{1,k}];
end

%% Plot rest for specific label

label = 10;

figure(label);
hold on
for k = 1:K
    ind = find(label == labelsEst{k});
    if ~isempty(ind)
        plot(k, rest{k}(ind),'*r')
    end
end

%% Estimated pos and lables

est = zeros(5,5,size(Xest,2));
for k = 1:size(Xest,2)
    for i = 1:size(Xest{1,k},2)
        if ~isempty(Xest{1,k}{i})
            est(:,i,k) = [Xest{1,k}{i}(1:4); Xest{1,k}{i}(7)];
        end
    end
end

