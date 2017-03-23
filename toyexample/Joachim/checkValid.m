% Function to remove targets outside borders

function [X, labels] = checkValid(Xold,FOVsize,labelsOld)
counter = 1;
X = [];
labels = [];
for i=1:size(Xold,2)
    if (abs(Xold(1,i)) < FOVsize(1)/2) && (Xold(2,i) < FOVsize(2) && (Xold(2,i) > 0))
        X(:,counter) = [Xold(:,i); labelsOld(i)];
        labels(1,counter) = labelsOld(i);
        counter = counter+1;
    end
end