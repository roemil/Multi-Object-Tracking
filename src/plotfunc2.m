function plotfunc2(Xest,Z,Xtrue)
% ONLY 2 targets

for k = 2:10
    for i = 1:2
        figure(i);
        subplot(2,1,1)
        plot(k,Xest{k}{i}(1),'-or')
        hold on
        plot(k,Xtrue{k}(1,i),'-ok')
        
        figure(i)
        subplot(2,1,2)
        plot(k,Xest{k}{i}(2),'-or')
        hold on
        plot(k,Xtrue{k}(2,i),'-ok')
    end
end