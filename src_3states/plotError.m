function [quant95, nRelErr] = plotError(plot1,plot2,err)
nRelErr = 0;

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
                for i = 1:size(err{sim}{k},2)
                    relErr = [relErr, err{sim}{k}(1,i)/err{sim}{k}(2,i)];
                end
            end
        end
    end

    nRelErr = size(relErr,2);
    quant95 = quantile(relErr,0.95);
    figure;
    histogram(relErr,20)
    hold on
    qua = plot([quant95,quant95],ylim,'r--');
    xlabel('Relative error')
    legend([qua],['quant95 = ', num2str(quant95)])
end