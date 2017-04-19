function XmuPred = generateBirthHypo(XmuPred, nbrOfBirths, FOVsize, boarder, pctWithinBoarder, covBirth, vinit, weightBirth)

for i = 1:ceil(pctWithinBoarder*nbrOfBirths/2)
    XmuPred(end+1).w = weightBirth;
    XmuPred(end).state = [unifrnd(boarder(1,1), boarder(2,1)), ...
        unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
    XmuPred(end).P = covBirth*eye(4);
end

for i = 1:ceil(pctWithinBoarder*nbrOfBirths/2)
    XmuPred(end+1).w = weightBirth;
    XmuPred(end).state = [unifrnd(boarder(1,2), boarder(2,2)), ...
        unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
    XmuPred(end).P = covBirth*eye(4);
end

for i = 1:ceil((1-pctWithinBoarder)*nbrOfBirths)
    XmuPred(end+1).w = weightBirth;
    XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
        unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
    XmuPred(end).P = covBirth*eye(4);
end