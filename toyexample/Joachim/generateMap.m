function map = generateMap()

map = figure;
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
leg = legend([roadBoarder,midRoad],'roadBoarder','midRoad');
set(leg,'Fontsize',15,'Interpreter','Latex')