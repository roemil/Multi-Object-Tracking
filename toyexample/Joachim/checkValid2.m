% Function to remove targets outside borders. INCLUDING Pd

function [X, labels, PdVec] = checkValid2(Xold,FOVsize,labelsOld,PdVecOld)
counter = 1;
X = [];
labels = [];
PdVec = [];
for i=1:size(Xold,2)
    if (abs(Xold(1,i)) < FOVsize(1)/2) && (Xold(2,i) < FOVsize(2) && (Xold(2,i) > 0))
        X(:,counter) = [Xold(:,i); labelsOld(i); PdVecOld(i)];
        labels(1,counter) = labelsOld(i);
        PdVec(1,counter) = PdVecOld(i);
        counter = counter+1;
    end
end