function plotVelocities(Xest,GT)

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
T = 0.1;
for k = 1 : size(GT,2)
        Xt = GT{k};
        if k == 1
            Xt(3:4,:) = NaN;
            XtOld = Xt;
        else
            for i = 1:size(Xt,2)
                iInd = find(Xt(5,i) == XtOld(5,:));
                if ~isempty(iInd)
                    Xt(3:4,i) = (Xt(1:2,i)-XtOld(1:2,iInd))/T;
                else
                    Xt(3:4,i) = NaN;
                end
            end
            XtOld = Xt;
        end
        X{k} = Xt;
end


Color = {'r--*','b--*','k--*','y--*','c--*','m--*'};
figure;
for t = 1:size(Xest,2)-1
    for i = 1 : size(Xest{t},2)
        subplot(2,1,1)
        plot(t,veloEst(1,i,t),Color{1});hold on;
        xlabel('t')
        ylabel('x velo')
        subplot(2,1,2)
        plot(t,veloEst(2,i,t),Color{2}); hold on;
        xlabel('t')
        ylabel('y velo')
    end
end

for t = 2 : size(Xest,2)
    for m = 1 : size(X{t},2)
        subplot(2,1,1)
        plot(t,X{t}(3,m),'g*');
        subplot(2,1,2)
        plot(t,X{t}(4,m),'g*');
    end
end
end
% 
% 
