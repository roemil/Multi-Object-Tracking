function XmuPred = generateBirthHypo(XmuPred, nbrOfBirths, FOVsize, boarder, pctWithinBoarder, covBirth, vinit, weightBirth)
global nbrOfStates
for i = 1:ceil(pctWithinBoarder*nbrOfBirths/2)
    XmuPred(end+1).w = weightBirth;
    if(nbrOfStates == 6)
        XmuPred(end).state = [unifrnd(boarder(1,1), boarder(2,1)), ...
        unifrnd(FOVsize(1,2), FOVsize(2,2)),unifrnd(0,20), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit)]';
    elseif(nbrOfStates == 4)
        XmuPred(end).state = [unifrnd(boarder(1,1), boarder(2,1)), ...
        unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit)]';
    end
    XmuPred(end).P = covBirth*eye(nbrOfStates);
end

for i = 1:ceil(pctWithinBoarder*nbrOfBirths/2)
    XmuPred(end+1).w = weightBirth;
    if(nbrOfStates == 6)
        XmuPred(end).state = [unifrnd(boarder(1,1), boarder(2,1)), ...
        unifrnd(FOVsize(1,2), FOVsize(2,2)),unifrnd(0,20), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit)]';
    elseif(nbrOfStates == 4)
        XmuPred(end).state = [unifrnd(boarder(1,1), boarder(2,1)), ...
        unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
    end
    XmuPred(end).P = covBirth*eye(nbrOfStates);
end

for i = 1:ceil((1-pctWithinBoarder)*nbrOfBirths)
    XmuPred(end+1).w = weightBirth;
    if(nbrOfStates == 6)
        XmuPred(end).state = [unifrnd(boarder(1,1), boarder(2,1)), ...
        unifrnd(FOVsize(1,2), FOVsize(2,2)),unifrnd(0,20), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit)]';
    elseif(nbrOfStates == 4)
        XmuPred(end).state = [unifrnd(boarder(1,1), boarder(2,1)), ...
        unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit)]';
    end
    XmuPred(end).P = covBirth*eye(nbrOfStates);
end