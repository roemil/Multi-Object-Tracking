fig1 = figure;
hold on
xlim([-FOVsize(1)/2,FOVsize(1)/2])
ylim([0, FOVsize(2)])

gtPlot = {};
estPlot = {};

for k = 2:9
    if k > 3
        delete(gtPlot)
        delete(estPlot)
    end
    for i = 1:size(X{k},2)
        gtPlot = [gtPlot, plot(X{k}(1,i),X{k}(2,i),'k*')];
    end
    for i = 1:size(est{k},2)
        estPlot = [estPlot plot(est{k}{i}(1),est{k}{i}(2),'r*')];
    end
    pause(0.5)
end