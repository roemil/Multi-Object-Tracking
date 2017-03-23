function plotobject = plotObjects(targets,i,colors, tar)

for time = i-20:i
    if(~isempty(targets{time}))
        if(~isempty(targets{time}(5,tar)))
            plotobject = plot(targets{time}(1,tar),targets{time}(2,tar),colors{targets{time}(5,tar)});
            pause(0)
            hold on
        end

    end
end