function XmuPred = generateBirthHypo(XmuPred, motionModel, nbrPosStates, mode,k)
global nbrOfBirths, global FOV, global boarder, global pctWithinBoarder
global covBirth, global vinit, global weightBirth, global birthSpawn,
global pose, global egoMotionOn, global TcamToVelo
global T20, global TveloToImu, global k,
global maxX, global maxY, global Zinter, global TcamToVelo, global xAngle, global yAngle
global angles

if strcmp(birthSpawn, 'boarders')
    if strcmp(mode,'GTnonlinear') || strcmp(mode,'CNNnonlinear')
        disp('Not implemented')
    end
elseif strcmp(birthSpawn, 'uniform')
     if strcmp(mode,'GTnonlinear') || strcmp(mode,'CNNnonlinear')
         FOVsize = FOV;
         if egoMotionOn
            heading = angles{k}.heading-angles{1}.heading;
         end
         for i = 1:ceil(nbrOfBirths/10)
            Zrnd = unifrnd(FOVsize(1,3), Zinter); % TODO: True angle of view?
            Xrange = min(maxX, Zrnd*tand(xAngle)); % 45? 40.6
            Yrange = min(maxY, Zrnd*tand(yAngle)); % 13
            XmuPred(end+1).w = weightBirth;    % Pred weight
            XmuPred(end).state = [unifrnd(-Xrange, Xrange), ...
                unifrnd(-Yrange, Yrange), Zrnd, ...
                unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit), 0, 0]';      % Pred state
            XmuPred(end).P = covBirth;      % Pred cov
            if egoMotionOn
                % Local cam2 -> local cam0 -> local velo -> local IMU ->
                % global IMU
                XmuPred(end).state(1:3) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[XmuPred(end).state(1:3);1]));
                XmuPred(end).state(1:2) = sqrt(XmuPred(end).state(1,:).^2+XmuPred(end).state(2,:).^2).*...
                                            [cos(heading+atan(XmuPred(end).state(2,:)./XmuPred(end).state(1,:))); ...
                                            sin(heading+atan(XmuPred(end).state(2,:)./XmuPred(end).state(1,:)))];
                XmuPred(end).state(1:3) = XmuPred(end).state(1:3) + pose{k}(1:3,4);
                
                
                %XmuPred(end).state(1:3) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[XmuPred(end).state(1:3);1]))...
                %    + pose{k}(1:3,4);
            end
        end
        for i = ceil(nbrOfBirths/10)+1:nbrOfBirths
            Zrnd = unifrnd(Zinter, FOVsize(2,3)); % TODO: True angle of view?
            Xrange = min(maxX, Zrnd*tand(xAngle)); % 45? 40.6
            Yrange = min(maxY, Zrnd*tand(yAngle)); % 13
            XmuPred(end+1).w = weightBirth;    % Pred weight
            XmuPred(end).state = [unifrnd(-Xrange, Xrange), ...
                unifrnd(-Yrange, Yrange), Zrnd, ...
                unifrnd(-vinit,vinit), unifrnd(-vinit,vinit),unifrnd(-vinit,vinit), 0, 0]';      % Pred state
            XmuPred(end).P = covBirth;%*eye(8);      % Pred cov
            %XmuUpd{1}(i).P(end,end) = 0;   % If 1 at end of states
            if egoMotionOn
                % Local cam2 -> local cam0 -> local velo -> local IMU ->
                % global IMU
                XmuPred(end).state(1:3) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[XmuPred(end).state(1:3);1]));
                XmuPred(end).state(1:2) = sqrt(XmuPred(end).state(1,:).^2+XmuPred(end).state(2,:).^2).*...
                                            [cos(heading+atan(XmuPred(end).state(2,:)./XmuPred(end).state(1,:))); ...
                                            sin(heading+atan(XmuPred(end).state(2,:)./XmuPred(end).state(1,:)))];
                XmuPred(end).state(1:3) = XmuPred(end).state(1:3) + pose{k}(1:3,4);
                
                %XmuPred(end).state(1:3) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[XmuPred(end).state(1:3);1]))...
                %    + pose{k}(1:3,4);
            end
        end
     end
end
    