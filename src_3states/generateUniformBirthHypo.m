function XmuPred = generateUniformBirthHypo(Z, mode)
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
         if egoMotionOn
            heading = angles{k}.heading-angles{1}.heading;
         end
         for z = 1 : size(Z,2)
             XmuPred(z).state(1:3,1) = Z(1:3,z);
             XmuPred(z).state(1:3) = pixel2cameracoords(XmuPred(z).state(1:2),XmuPred(z).state(3));
             XmuPred(z).state(4:6) = zeros(3,1);
             XmuPred(z).state(7:8) = Z(4:5,z);
             XmuPred(z).P = covBirth;      % Pred cov
             XmuPred(z).w = weightBirth;
                if egoMotionOn
                    % Local cam2 -> local cam0 -> local velo -> local IMU ->
                    % global IMU
                    XmuPred(z).state(1:3) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[XmuPred(z).state(1:3);1]));
                    XmuPred(z).state(1:2) = sqrt(XmuPred(z).state(1,:).^2+XmuPred(z).state(2,:).^2).*...
                                                [cos(heading+atan(XmuPred(z).state(2,:)./XmuPred(z).state(1,:))); ...
                                                sin(heading+atan(XmuPred(z).state(2,:)./XmuPred(z).state(1,:)))];
                    XmuPred(z).state(1:3) = XmuPred(z).state(1:3) + pose{k}(1:3,4);
                end
         end
     end
end
    