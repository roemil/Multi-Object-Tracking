function free_lab = freeLabel(targets, labels)
    if(isempty(targets))
        free_lab = 1;
        return;
    end
    for lab = 1 : length(labels)%%%% FIND WHICH LABEL IS FREE
        for used_lab = 1 : size(targets,2)
            if(any(labels(lab) == targets(5,:)))
                    %label is used
            else
                free_lab = labels(lab);
                return;
            end
        end
    end
end