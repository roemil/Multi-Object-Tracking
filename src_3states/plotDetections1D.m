% function plotDetections1D(GT, Xest)
% 
% for i = 1 : size(GT,2)
%     for j = 1 : size(GT{i},2)
%         figure(GT{i}(end,j)+1)
%         subplot(2,1,1)
%         plot(i,GT{i}(1,j),'r*');hold on;
%         subplot(2,1,2)
%         plot(i,GT{i}(2,j),'k*');hold on;
%         
%     end
% end
% 
% for i = 1 : size(Xest,2)
%     for j = 1 : size(Xest{i},2)
%         figure(Xest{i}{j}(end))
%         subplot(2,1,1)
%         plot(i,Xest{i}{j}(1),'r*')
%         subplot(2,1,2)
%         plot(i,Xest{i}{j}(2),'k*')
%     end
% end
% 
% 
% 
% 
% 

% Function to generate figures with estimates and true data for each state
% 
% Input:    Z:      Measurements
%           Xtrue:  Ground truth
%           Xest:   Estimates from PMBM
%
%

function [squareError] = plotDetections1D(Z, Xtrue, Xest, plotSE)

% Find shortest variable
N = min(size(Z,2), size(Xtrue,2));
N = min(N,size(Xest,2));

% Create plot if for estimates not assigned to true data
notAssignedFlag = 0;

maxObj = 0;
for k = 2:N
    if size(Xtrue{k},2) > maxObj
        maxObj = size(Xtrue{k},2);
    end
end

maxEst = 0;
for k = 2:N
    if size(Xtrue{k},2) > maxEst
        maxEst = size(Xest{k},2);
    end
end

squareError = zeros(2,N,maxObj);

% For each time instance
for k = 2:N
    if ~isempty(Xest{k}{1})
        % Find closest match of estimates and true states
        dist = zeros(size(Xest{k},2), size(Xtrue{k},2));
        for estTarget = 1:size(Xest{k},2)
            for trueTarget = 1:size(Xtrue{k},2)
                xdiff = Xest{k}{estTarget}(1)-Xtrue{k}(1,trueTarget);
                ydiff = Xest{k}{estTarget}(2)-Xtrue{k}(2,trueTarget);
                dist(estTarget,trueTarget) = sqrt(xdiff^2+ydiff^2);
            end
        end

        [asso, ~] = murty(dist',1);

        % Display if the number of target and estimates are not the same and
        % create a figure for unassigned estimates
        if size(dist,1) < size(dist,2)
            %for i = size(dist,1)+1:size(dist,2)
            %    asso(1,i) = NaN;
            %end
            disp(['Nbr of estimates < nbr of true targets, k = ', num2str(k)])
        elseif size(dist,1) > size(dist,2) 
            disp(['Nbr of estimates > nbr of true targets, k = ', num2str(k)])
            if notAssignedFlag == 0
                estNotAssigned = figure(1000);
                notAssignedFlag = 1;
                %asso(asso == 0) = find(asso == 1);
            end
        end

        % Plot the result
        for trueTarget = 1:size(dist,2)
            figure(Xtrue{k}(end,trueTarget)+1);
            hold on
            for i = 1:min(2, size(Xtrue{k},1))
                subplot(2,1,i)
                hold on
                plot(k, Xtrue{k}(i,trueTarget),'k+')
            end
            if asso(1,trueTarget) ~= 0
                for i = 1:min(2, size(Xest{k}{asso(1,trueTarget)},1))
                    subplot(2,1,i)
                    hold on
                    plot(k, Xest{k}{asso(1,trueTarget)}(i),'r*')
                end
                squareError(:,k,trueTarget) = (Xest{k}{asso(1,trueTarget)}(1:2)-Xtrue{k}(1:2,trueTarget)).^2;
            else
                disp(['Missed estimation, k = ', num2str(k)])
            end
            for estTarget = 1:size(Xest{k},2)
                if sum(estTarget == asso) == 0
                    figure(estNotAssigned);
                    hold on
                    for i = 1:min(2, size(Xest{k}{estTarget},1))
                        subplot(2,1,i)
                        hold on
                        plot(k, Xest{k}{estTarget}(i),'r*')
                    end
                end
            end
        end
    end
end

% Add labels and titles
labels = {'$x$','$y$','$v_x$','$v_y$'};

for fig = 1:size(findobj(0,'type','figure'),1)
    if ((notAssignedFlag == 0) || fig < (size(findobj(0,'type','figure'),1)))
        for i = 1:2
            figure(fig);
            subplot(2,1,i)
            ylabel(labels{i},'Fontsize',15,'Interpreter','Latex')
            xlabel('$k$','Fontsize',15,'Interpreter','Latex')
        end
        suptitle(['Target ', num2str(fig)])
    else
        for i = 1:2
            figure(1000);
            subplot(2,1,i)
            ylabel(labels{i},'Fontsize',15,'Interpreter','Latex')
            xlabel('$k$','Fontsize',15,'Interpreter','Latex')
        end
        suptitle('Estimates with no association to true data')
    end
end

if strcmp(plotSE,'true')
    for est = 1:maxEst
        figure(size(findobj(0,'type','figure'),1)+1)
        for i = 1:2
            subplot(2,1,i)
            hold on
            plot(1:N,squareError(i,:,est))
            ylabel(labels{i},'Fontsize',15,'Interpreter','Latex')
            xlabel('$k$','Fontsize',15,'Interpreter','Latex')
        end
        suptitle(['Estimate ', num2str(est)])
    end
end
end

