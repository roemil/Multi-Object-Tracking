function XmuPred = generateUniformBirthHypo(Z, mode)

global nbrOfBirths, global FOV, global boarder, global pctWithinBoarder
global covBirth, global vinit, global weightBirth, global birthSpawn,
global pose, global egoMotionOn, global TcamToVelo
global T20, global TveloToImu, global k,
global maxX, global maxY, global Zinter, global TcamToVelo, global xAngle, global yAngle
global angles, global R, global Rdistance, global FOVsize, global color, global imgpath
global nbrMeasStates, global PinitVeloClose, global PinitVeloFar, global PbirthFunc,
global distThresh, global angleThresh, global T, global PinitBBsize, global distThresh2
global rescaleFact

% Find the corresponding 3D covariance

if(color)
    framenbr = sprintf('%06d',k-1);
    img = imread([imgpath,framenbr,'.png']);
end

if strcmp(birthSpawn, 'boarders')
    if strcmp(mode,'GTnonlinear') || strcmp(mode,'CNNnonlinear')
        disp('Not implemented')
    end
elseif strcmp(birthSpawn, 'uniform')
        for z = 1 : size(Z,2)
            XmuPred(z).state(1:2,1) = Z(1:2,z);
            XmuPred(z).state(3:4,1) = zeros(2,1);
            XmuPred(z).state(5:6,1) = Z(3:4,z);
            
            % Test 1. This works ok
%             Pbirth = diag([0.3*FOVsize(2,1) 0.3*FOVsize(2,2) Rdistance(Z(3,z))]); % TODO: Move to declareVariables
%             XmuPred(z).P = zeros(8,8);
%             [XmuPred(z).P(1:3,1:3), tmp] = CKFupdateNewTarget(Z(1:3,z), Pbirth, 3);
%             % TAG: Shall we do this?
%             angleThresh = 30*pi/180; % TODO: Move to declareVariables
%             distThresh = 10; % TODO: Move to declareVariables
%             if abs(theta) > angleThresh && Z(3,z) < distThresh
%                XmuPred(z).P(1:3,1:3) = 5*XmuPred(z).P(1:3,1:3);
%            %    XmuPred(z).P(1:3,1:3) = [10 10 10;10 20 10; 10 10 10].*XmuPred(z).P(1:3,1:3);
%             end
%             
%             XmuPred(z).P(4:6,4:6) = 5*XmuPred(z).P(1:3,1:3); % TODO: Move to declareVariables

            % TEST 2
%             Pbirth = diag([0.3*FOVsize(2,1) 0.3*FOVsize(2,2) Rdistance(Z(3,z))]); % TODO: Move to declareVariables
%             XmuPred(z).P = zeros(8,8);
%             [XmuPred(z).P(1:3,1:3), tmp] = CKFupdateNewTarget(Z(1:3,z), Pbirth, 3);
%             % TAG: Shall we do this?
%             angleThresh = 30*pi/180; % TODO: Move to declareVariables
%             distThresh = 10; % TODO: Move to declareVariables
%             if Z(3,z) < distThresh % && abs(theta) > angleThresh
%                XmuPred(z).P(1:3,1:3) = 1*XmuPred(z).P(1:3,1:3);
%            %    XmuPred(z).P(1:3,1:3) = [10 10 10;10 20 10; 10 10 10].*XmuPred(z).P(1:3,1:3);
%             end

            % TEST 3
            % TAG: Shall we do this?
            XmuPred(z).P = covBirth*eye(6);
%             if Z(3,z) < distThresh % && abs(theta) > angleThresh
%                 Pbirth = PbirthFunc(Z(3,z)); % TODO: Move to declareVariables
%                 [XmuPred(z).P(1:3,1:3), tmp] = CKFupdateNewTarget(Z(1:3,z), Pbirth, 3);
%                 XmuPred(z).P(4:6,4:6) = PinitVeloClose*XmuPred(z).P(1:3,1:3);
%             else
%                 Pbirth = PbirthFunc(Z(3,z)); % TODO: Use different values close and far?
%                 [XmuPred(z).P(1:3,1:3), tmp] = CKFupdateNewTarget(Z(1:3,z), Pbirth, 3);
%                 XmuPred(z).P(4:6,4:6) = PinitVeloFar*XmuPred(z).P(1:3,1:3);
%             end
%             
%             global Ptest
%             XmuPred(z).P(4:6,4:6) = Ptest(Z(3,z))*XmuPred(z).P(1:3,1:3);
%             
%             % Initiate velo?
%             if ((Z(3,z) < distThresh2) && (abs(theta) > angleThresh))
%                 if k > 1
%                     XmuPred(z).state(4:6) = (pose{k}(1:3,4)-pose{k-1}(1:3,4))/T;
%                 elseif k == 1
%                     XmuPred(z).state(4:6) = (pose{k+1}(1:3,4)-pose{k}(1:3,4))/T;
%                 end
%             end
%             
%             XmuPred(z).P(7:8,7:8) = PinitBBsize;
%             XmuPred(z).w = weightBirth;
%             if egoMotionOn
%                 % Local cam2 -> local cam0 -> local velo -> local IMU ->
%                 % global IMU
%                 XmuPred(z).state(1:3) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[XmuPred(z).state(1:3);1]));
%                 XmuPred(z).state(1:2) = [cos(heading), -sin(heading); sin(heading) cos(heading)]*XmuPred(z).state(1:2);
%                 XmuPred(z).state(1:3) = XmuPred(z).state(1:3) + pose{k}(1:3,4);
%             end
            
            if color
                Zbox = [Z(1,z) - rescaleFact*Z(nbrMeasStates+1,z)*0.5, Z(2,z)-rescaleFact*Z(nbrMeasStates+2,z)*0.5,...
                        rescaleFact*Z(nbrMeasStates+1,z),rescaleFact*Z(nbrMeasStates+2,z)]; % Corners of Z box
                [ZRed, ZGreen, ZBlue] = colorhist(img,Zbox);
                XmuPred(z).red = ZRed;
                XmuPred(z).green = ZGreen;
                XmuPred(z).blue = ZBlue;
            end
        end
    end
end



%% Plot 3sigma for XY in 3D

% global R
% global pose
% global c
% global H
% global Pd
% for i = 1:size(Z,2)
%     n = 100;
%     phi = linspace(0,2*pi,n);
%     x = repmat(XmuPred(i).state(1:2),1,n)+3*sqrtm(XmuPred(i).P(1:2,1:2))*[cos(phi);sin(phi)];
%     figure;
%     hold on
%     plot(XmuPred(i).state(1),XmuPred(i).state(2),'r*')
%     plot(x(1,:),x(2,:),'-k','LineWidth',2)
% end
% keyboard

%% Plot 3sigma for pix and distance
% global R
% global pose
% global c
% global H
% global Pd
% %Rtmp = @(x) R(x)*3;
% for i = 1:size(Z,2)
%     tmp = H(XmuPred(i).state,pose{k}(1:3,4),angles{k}.heading-angles{1}.heading);
%     [~, ~,S] = CKFupdate(XmuPred(i).state, XmuPred(i).P, H, Z(1:3,i), R, 6);
%     n = 100;
%     phi = linspace(0,2*pi,n);
%     x = repmat(tmp(1:2),1,n)+3*sqrtm(S(1:2,1:2))*[cos(phi);sin(phi)];
%     figure;
%     plot(Z(1,i),Z(2,i),'g*','markersize',10)
%     hold on
%     plot(tmp(1),tmp(2),'r*')
%     plot(x(1,:),x(2,:),'-k','LineWidth',2)
%     
%     xdist(1) = tmp(3) + 3*sqrt(S(3,3));
%     xdist(2) = tmp(3) - 3*sqrt(S(3,3));
%     figure;
%     plot([Z(3,i) Z(3,i)],[-1 1],'g')
%     hold on
%     plot([tmp(3) tmp(3)],[-1 1],'r')
%     plot([xdist(1) xdist(1)],[-1 1],'k')
%     plot([xdist(2) xdist(2)],[-1 1],'k')
%     
%     e(i) = Pd*mvnpdf(Z(1:3,i), tmp, S);
%     rho(i) = e(i)+c;
%     w(i) = log(e(i)+c); % rho (45) (44)
%     r(i) = e(i)/rho(i);
%     
%     epix(i) = Pd*mvnpdf(Z(1:2,i), tmp(1:2), S(1:2,1:2));
%     rhopix(i) = epix(i)+c;
%     wpix(i) = log(epix(i)+c); % rho (45) (44)
%     rpix(i) = epix(i)/rhopix(i);
% end
% keyboard