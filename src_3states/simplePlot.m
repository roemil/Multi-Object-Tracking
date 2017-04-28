close all;

laneWidth = 3;
dToInter = 3;
legFlag = 0;

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

K = min(size(Xest,2), size(X,2));

gtPlot = {};
estPlot = {};
%
for k = 2:K
    if k > 3
        delete(gtPlot)
        gtPlot = {};
        if ~isempty(estPlot)
            delete(estPlot)
            estPlot = {};
        end
    end
    for i = 1:size(X{k},2)
        gtPlot = [gtPlot, plot(X{k}(1,i),X{k}(2,i),'k+','Markersize',10)];
        %plot(X{k}(1,i),X{k}(2,i),'k+','Markersize',10);
        hold on;
    end
    if ~isempty(Xest{k}{1})
        for i = 1:size(Xest{k},2)
            estPlot = [estPlot plot(Xest{k}{i}(1),Xest{k}{i}(2),'r*','Markersize',10)];
             %plot(est{k}{i}(1),est{k}{i}(2),'r*','Markersize',10); hold on;
        end
    end
    if ((legFlag == 0) && ~isempty(Xest{k}{1}))
        legend([gtPlot(1), estPlot(1)],'GT','Estimate')
        legFlag = 1;
    end
    pause(0.1)
end