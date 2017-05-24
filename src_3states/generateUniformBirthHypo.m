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
             zApprox = pix2coordtest(Z(1:2,z),Z(3,z));
             XmuPred(z).state(1:3,1) = pixel2cameracoords(Z(1:2,z),zApprox);
             XmuPred(z).state(4:6,1) = zeros(3,1);
             XmuPred(z).state(7:8,1) = Z(4:5,z);
             XmuPred(z).P = covBirth;%(Z(3,z));      % Pred cov
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

% global R
% global pose
% global c
% global H
% global Pd
% %Rtmp = @(x) R(x)*3;
% for i = 1:size(Z,2)
%     tmp = H(XmuPred(i).state,pose{1}(1:3,4),angles{k}.heading-angles{1}.heading);
%     [~, ~,S] = CKFupdate(XmuPred(i).state, XmuPred(i).P, H, Z(1:3,i), R, 8);
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