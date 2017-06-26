function plotError(plot1,plot2,err)

%% Plot err vs distance
if plot1
    figure;
    hold on
    %maxErr = zeros(2,1);
    for sim = 1:size(err,1)
        for k = 1:size(err{sim},1)
            if ~isempty(err{sim}{k})
                for i = 1:size(err{sim}{k},2)
                    %if err{k}(1,i) > maxErr(1)
                    %    maxErr = [err{k}(1,i);k];
                    %end
                    plot(err{sim}{k}(2,i),err{sim}{k}(1,i),'b+')
                end
            end
        end
    end
    xlabel('Distance [m]')
    ylabel('Error [m]')
end

%% Plot relative to distance

if plot2
    relErr = [];
    for sim = 1:size(err,1)
        for k = 1:size(err{sim},1)
            if ~isempty(err{sim}{k})
                relErr = [relErr, err{sim}{k}(1,i)/err{sim}{k}(2,i)];
            end
        end
    end

    quant95 = quantile(relErr,0.95);
    figure;
    histogram(relErr,20)
    hold on
    plot([quant95,quant95],ylim,'r--')
    xlabel('Relative error')
end