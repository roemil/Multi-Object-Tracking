close all;

laneWidth = 3;
dToInter = 3;

fig1 = figure;
hold on
FOVsize = [20,30];
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

for i = 1 : size(X,2)
    if(~isempty(X{i}))
        X2{ind} = X{i};
        ind = ind + 1;
    end
end
ind = 1;
for i = 1 : size(X2,2)
    if(~isempty(X2{i}))
        X{ind} = X2{i};
        ind = ind + 1;
    end
end
%
K = min(size(est,2), size(X,2));

gtPlot = {};
estPlot = {};
%
for k = 2:150
    if k > 3
        delete(gtPlot)
        delete(estPlot)
    end
    for i = 1:size(X{k},2)
        gtPlot = [gtPlot, plot(X{k}(1,i),X{k}(2,i),'k+','Markersize',10)];
        %plot(X{k}(1,i),X{k}(2,i),'k+','Markersize',10);
        hold on;
    end
    for i = 1:size(est{k},2)
        estPlot = [estPlot plot(est{k}{i}(1),est{k}{i}(2),'r*','Markersize',10)];
         %plot(est{k}{i}(1),est{k}{i}(2),'r*','Markersize',10); hold on;
    end
    if k == 2
        legend([gtPlot(1), estPlot(1)],'GT','Estimate')
    end
    pause(0.1)
end