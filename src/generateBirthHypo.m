function XmuPred = generateBirthHypo(XmuPred, nbrOfBirths, FOVsize, boarder,...
    pctWithinBoarder, covBirth, vinit, weightBirth, motionModel, nbrPosStates, dInit, birthSpawn)

if strcmp(birthSpawn, 'boarders')
    if nbrPosStates == 4
        if strcmp(motionModel,'cv')
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
        elseif strcmp(motionModel,'cvBB')
            for i = 1:ceil(pctWithinBoarder*nbrOfBirths/2)
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(boarder(1,1), boarder(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit) 0 0]';
                XmuPred(end).P = covBirth*eye(6);
            end

            for i = 1:ceil(pctWithinBoarder*nbrOfBirths/2)
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(boarder(1,2), boarder(2,2)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit) 0 0]';
                XmuPred(end).P = covBirth*eye(6);
            end

            for i = 1:ceil((1-pctWithinBoarder)*nbrOfBirths)
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit) 0 0]';
                XmuPred(end).P = covBirth*eye(6);
            end
        end
    elseif nbrPosStates == 6
        if strcmp(motionModel,'cv')
            for i = 1:ceil(pctWithinBoarder*nbrOfBirths/2)
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(boarder(1,1), boarder(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(dInit(1), dInit(2)),...
                    unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
                XmuPred(end).P = covBirth*eye(6);
            end

            for i = 1:ceil(pctWithinBoarder*nbrOfBirths/2)
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(boarder(1,2), boarder(2,2)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(dInit(1), dInit(2)),...
                    unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
                XmuPred(end).P = covBirth*eye(6);
            end

            for i = 1:ceil((1-pctWithinBoarder)*nbrOfBirths)
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(dInit(1), dInit(2)),...
                    unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
                XmuPred(end).P = covBirth*eye(6);
            end
        elseif strcmp(motionModel,'cvBB')
            for i = 1:ceil(pctWithinBoarder*nbrOfBirths/2)
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(boarder(1,1), boarder(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(dInit(1), dInit(2)),...
                    unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit) 0 0]';
                XmuPred(end).P = covBirth*eye(8);
            end

            for i = 1:ceil(pctWithinBoarder*nbrOfBirths/2)
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(boarder(1,2), boarder(2,2)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(dInit(1), dInit(2)),...
                    unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit) 0 0]';
                XmuPred(end).P = covBirth*eye(8);
            end

            for i = 1:ceil((1-pctWithinBoarder)*nbrOfBirths)
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(dInit(1), dInit(2)),...
                    unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit) 0 0]';
                XmuPred(end).P = covBirth*eye(8);
            end
        end
    end
elseif strcmp(birthSpawn, 'uniform')
     if nbrPosStates == 4
        if strcmp(motionModel,'cv')
            for i = 1:nbrOfBirths
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
                XmuPred(end).P = covBirth*eye(4);
            end
        elseif strcmp(motionModel,'cvBB')
            for i = 1:nbrOfBirths
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit) 0 0]';
                XmuPred(end).P = covBirth*eye(6);
            end
        elseif strcmp(motionModel, 'ca')
            for i = 1:nbrOfBirths
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),...
                    unifrnd(-2,2), unifrnd(-2,2)]';
                XmuPred(end).P = covBirth*eye(6);
            end
elseif strcmp(motionModel, 'caBB')
            for i = 1:nbrOfBirths
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),...
                    unifrnd(-2,2), unifrnd(-2,2) 0 0]';
                XmuPred(end).P = covBirth*eye(8);
            end            
        end
     elseif nbrPosStates == 6
         if strcmp(motionModel,'cv')
            for i = 1:nbrOfBirths
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)),  unifrnd(dInit(1), dInit(2)),...
                    unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
                XmuPred(end).P = covBirth*eye(6);
            end
         elseif strcmp(motionModel, 'ca')
            for i = 1:nbrOfBirths
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),...
                    unifrnd(-2,2), unifrnd(-2,2)]';
                XmuPred(end).P = covBirth*eye(6);
            end
         elseif strcmp(motionModel, 'caBB')
            for i = 1:nbrOfBirths
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),...
                    unifrnd(-2,2), unifrnd(-2,2) 0 0]';
                XmuPred(end).P = covBirth*eye(8);
            end
        elseif strcmp(motionModel,'cvBB')
            for i = 1:nbrOfBirths
                XmuPred(end+1).w = weightBirth;
                XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
                    unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(dInit(1), dInit(2)),...
                    unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit) 0 0]';
                XmuPred(end).P = covBirth*eye(8);
            end
         end
     end
end
    