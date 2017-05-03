function XmuPred = generateBirthHypo(XmuPred, nbrOfBirths, FOVsize, boarder,...
    pctWithinBoarder, covBirth, vinit, weightBirth, motionModel, nbrPosStates, birthSpawn,mode)

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
    elseif strcmp(mode,'GTnonlinear')
        disp('Not implemented')
    end
elseif strcmp(birthSpawn, 'uniform')
     if nbrPosStates == 4
%         if strcmp(motionModel,'cv')
%             for i = 1:nbrOfBirths
%                 XmuPred(end+1).w = weightBirth;
%                 XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
%                     unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
%                 XmuPred(end).P = covBirth*eye(4);
%             end
%         elseif strcmp(motionModel,'cvBB')
%             for i = 1:nbrOfBirths
%                 XmuPred(end+1).w = weightBirth;
%                 XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
%                     unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit) 0 0]';
%                 XmuPred(end).P = covBirth*eye(6);
%             end
%         end
%      elseif nbrPosStates == 6
%          if strcmp(motionModel,'cv')
%             for i = 1:nbrOfBirths
%                 XmuPred(end+1).w = weightBirth;
%                 XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
%                     unifrnd(FOVsize(1,2), FOVsize(2,2)),  unifrnd(dInit(1), dInit(2)),...
%                     unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit)]';
%                 XmuPred(end).P = covBirth*eye(6);
%             end
%         elseif strcmp(motionModel,'cvBB')
%             for i = 1:nbrOfBirths
%                 XmuPred(end+1).w = weightBirth;
%                 XmuPred(end).state = [unifrnd(FOVsize(1,1), FOVsize(2,1)), ...
%                     unifrnd(FOVsize(1,2), FOVsize(2,2)), unifrnd(dInit(1), dInit(2)),...
%                     unifrnd(-vinit,vinit), unifrnd(-vinit,vinit), unifrnd(-vinit,vinit) 0 0]';
%                 XmuPred(end).P = covBirth*eye(8);
%             end
%          end
     elseif strcmp(mode,'GTnonlinear')
         % This generates uniformly over Z, however it is not very uniform in
            % the 3D space
%          for i = 1:nbrOfBirths
%             Zrnd = unifrnd(FOVsize(1,3), FOVsize(2,3));
%             Xrange = Zrnd*tand(43);
%             Yrange = Zrnd*tand(16);
%             XmuPred(end+1).w = weightBirth;
%             XmuPred(end).state = [unifrnd(-Xrange, Xrange), ...
%                 unifrnd(-Yrange, Yrange), Zrnd, ...
%                 unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit), 0, 0]';
%             XmuPred(end).P = covBirth*eye(8);
%             %XmuPred(end).P(end,end) = 0; % If 1 at end of states
%          end
         for i = 1:nbrOfBirths/5
            Zrnd = unifrnd(FOVsize(1,3), 8); % TODO: True angle of view?
            Xrange = Zrnd*tand(43); % 45? 40.6
            Yrange = Zrnd*tand(16); % 13
            XmuPred(end+1).w = weightBirth;    % Pred weight
            XmuPred(end).state = [unifrnd(-Xrange, Xrange), ...
                unifrnd(-Yrange, Yrange), Zrnd, ...
                unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit), 0, 0]';      % Pred state
            XmuPred(end).P = covBirth;%*eye(8);      % Pred cov
            %XmuUpd{1}(i).P(end,end) = 0;   % If 1 at end of states
        end
        for i = nbrOfBirths/5+1:nbrOfBirths
            Zrnd = unifrnd(8, FOVsize(2,3)); % TODO: True angle of view?
            Xrange = Zrnd*tand(43); % 45? 40.6
            Yrange = Zrnd*tand(16); % 13
            XmuPred(end+1).w = weightBirth;    % Pred weight
            XmuPred(end).state = [unifrnd(-Xrange, Xrange), ...
                unifrnd(-Yrange, Yrange), Zrnd, ...
                unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit), 0, 0]';      % Pred state
            XmuPred(end).P = covBirth;%*eye(8);      % Pred cov
            %XmuUpd{1}(i).P(end,end) = 0;   % If 1 at end of states
        end
     end
end
    