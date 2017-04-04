function [newGlob, newInd] = generateGlobalHypo3(Xhypo, Xnew, Z, oldInd)

m = size(Z,2);
nbrOldTargets = size(Xhypo{1,1,1},2);

A = generateGlobalInd(m, nbrOldTargets);

for i = 1:m
    Xtmp{i} = Xhypo{i};
end
for z = 1:m
    Xtmp{z}(end+z) = Xnew{z};
end

jInd = 1;
for i = 1:size(A,2)
    for row = 1:size(A{i},1)
        newGlob{jInd}(1:nbrOldTargets+m) = struct('state',[],'P',[],'w',1,'r',0,'S',0);
        for col = 1:size(A{i},2)
            newGlob{jInd}(A{i}(row,col)) = Xtmp{col}(A{i}(row,col));
        end
        for target = 1:size(newGlob{jInd},2)
            if isempty(newGlob{jInd}(target).state)
                if target <= nbrOldTargets
                    newGlob{jInd}(target) = Xhypo{end}(target);
                else
                    newGlob{jInd}(target).state = Xnew{target-nbrOldTargets}.state;
                    newGlob{jInd}(target).P = Xnew{target-nbrOldTargets}.P;
                end
            end
        end
        jInd = jInd+1;
    end
end

newInd = oldInd+jInd-1;