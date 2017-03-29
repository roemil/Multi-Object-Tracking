function [newGlob, newInd] = generateGlobalHypo(Xhypo, Xnew, Z, oldInd)

% TODO: Is this correct?
targets = 1:(size(Xhypo{1},2)+size(Xnew{1},2)+size(Z,2));

combs = nchoosek(targets,size(Z,2));

pm = [];
for i = 1:size(combs,1)
    pm = [pm; perms(combs(i,:))];
end

for j = 1:size(pm,1)
    for z = 1:size(Z,2)
        % Update all previously detected targets
        for i = 1:size(Xhypo{1},2)
            if i == pm(j,z)
                newGlob{j}(i) = Xhypo{z}(i);
            else
                newGlob{j}(i) = Xypo{end}(i);
            end
        end
        % Update all pot new detected targets
        for i = size(Xhypo{1},2)+1:size(Xhypo{1},2)+size(Xnew{1},2)
            if i == pm(j,z)
                newGlob{j}(i) = Xhypo{z}(i-size(Xhypo{1},2));
            else
                newGlob{j}(i) = Xhypo{z}(i-size(Xhypo{1},2));
                newGlob{j}(i).w = 1;
                newGlob{j}(i).r = 0;
            end
        end
    end
end

newInd = oldInd+size(pm,1);