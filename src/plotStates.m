function plotStates(Z, Xtrue, Xest)

% Find shortest variable
N = min(size(Z,2), size(Xtrue,2), size(Xest,2));

for k = 2:N
    dist = zeros(size(Xest{k},2), size(Xtrue{k},2));
    for estTarget = 1:size(Xest{k},2)
        for trueTarget = 1:size(Xtrue{k},2)
            xdiff = Xest{k}{estTarget}(1)-Xtrue{k}(trueTarget,1);
            ydiff = Xest{k}{estTarget}(2)-Xtrue{k}(trueTarget,2);
            dist(estTarget,trueTarget) = sqrt(xdiff^2+ydiff^2);
        end
    end
    
    [asso, ~] = murty(dist,1);
    
    if size(dist,1) < size(dist,2)
        for i = size(dist,1)+1:size(dist,2)
            asso(1,i) = NaN;
        end
        disp(['Nbr of estimates < nbr of true targets, k = ', num2str(k)])
    elseif size(dist,1) > size(dist,2) 
        disp(['Nbr of estimates > nbr of true targets, k = ', num2str(k)])
    end
    
    for trueTarget = 1:size(asso,2)
        if sum(asso(:,trueTarget) ~= 0) ~= 0
            figure(trueTarget);
            hold on
            for i = min(4, size(Xtrue{k},1))
                subplot(4,1,i)
                hold on
                plot(k, Xtrue{k}(i,trueTarget),'k*')
            end
            if ~isnan(asso(1,trueTarget))
                for i = min(4, size(Xest{k}{asso(1,trueTarget)},1))
                    subplot(4,1,i)
                    hold on
                    plot(k, Xest{k}{asso(1,trueTarget)}(i),'k*')
                end
            end
        else
            for estTarget = 1:size(Xest{k},2)
                if sum(estTarget == asso) == 0
                    figure(estNotAssigned);
                    hold on
                    for i = min(4, size(Xest{k}{asso(1,trueTarget)},1))
                        subplot(4,1,i)
                        hold on
                        plot(k, Xest{k}{estTarget}(i),'k*')
                    end
                end
            end
        end
    end
end
