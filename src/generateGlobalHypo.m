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
            if ((i == pm(j,z)) && (sum(i == pm(j,:)) == 1))
                newGlob{j}(i).w = Xhypo{z}(i).w;
                newGlob{j}(i).r = Xhypo{z}(i).r;
                newGlob{j}(i).state = Xhypo{z}(i).state;
                newGlob{j}(i).P = Xhypo{z}(i).P;
            elseif (sum(i == pm(j,:)) == 0)
                newGlob{j}(i).w = Xhypo{end}(i).w;
                newGlob{j}(i).r = Xhypo{end}(i).r;
                newGlob{j}(i).state = Xhypo{end}(i).state;
                newGlob{j}(i).P = Xhypo{end}(i).P;
            end
        end
        % Update all pot new detected targets
        for i = size(Xhypo{1},2)+1:size(Xhypo{1},2)+size(Xnew{1},2)
            if ((i == pm(j,z)) && (sum(i == pm(j,:)) == 1)) % TODO: WAS Xhypo here before. Should be Xnew right?
                newGlob{j}(i).w = Xnew{z}(i-size(Xhypo{1},2)).w;
                newGlob{j}(i).r = Xnew{z}(i-size(Xhypo{1},2)).r;
                newGlob{j}(i).state = Xnew{z}(i-size(Xhypo{1},2)).state;
                newGlob{j}(i).P = Xnew{z}(i-size(Xhypo{1},2)).P;
            elseif (sum(i == pm(j,:)) == 0)
                newGlob{j}(i).state = Xnew{z}(i-size(Xhypo{1},2)).state;
                newGlob{j}(i).P = Xnew{z}(i-size(Xhypo{1},2)).P;
                newGlob{j}(i).w = 1;
                newGlob{j}(i).r = 0;
            end
        end
    end
end

newInd = oldInd+size(pm,1);