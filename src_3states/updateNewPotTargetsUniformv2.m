function [XpotNew, rho, newLabel] = updateNewPotTargetsUniformv2(XmuPred, nbrOfMeas, ...
    Z, newLabel,motionModel, nbrPosStates, unifdist)

global Pd, global H3dFunc, global Hdistance, global R3dTo2d, global Rdistance, global Jh
global c, global nbrStates, global nbrMeasStates, global H, global R,
global pose, global k, global angles, global FOVsize, global egoMotionOn, global TcamToVelo
global T20, global TveloToImu, global covBirth

% Spawn births in image plane and compute weights and prob of exi there.
% Then transform to 3D coords

    rho = zeros(nbrOfMeas,1);
    heading = angles{k}.heading - angles{1}.heading;
    
    for z = 1:nbrOfMeas
        Pnew = diag([500 500 25]);
        
        S = eye(3)*Pnew*eye(3)'+R(Z(3)); % create inovation variance matrix S
            
        e = Pd*mvnpdf(Z(1:3,z), Z(1:3,z), S);
        rho(z) = e+c;
        XpotNew{z}.w = log(e+c); % rho (45) (44)
        XpotNew{z}.r = e/rho(z); % (43) (44)
        %[XpotNew{z}.w XpotNew{z}.r e]
        XpotNew{z}.S = 0;
        XpotNew{z}.box = Z(nbrMeasStates+1:nbrMeasStates+2,z);
        XpotNew{z}.label = newLabel;
        
        zApprox = pix2coordtest(Z(1:2,z),Z(3,z));
        XpotNew{z}.state = zeros(8,1);
        XpotNew{z}.state(1:3,1) = pixel2cameracoords(Z(1:2,z),zApprox);
        XpotNew{z}.state(4:6,1) = zeros(3,1);
        XpotNew{z}.state(7:8,1) = Z(4:5,z);
        
        if egoMotionOn
            % Local cam2 -> local cam0 -> local velo -> local IMU ->
            % global IMU
            XpotNew{z}.state(1:3) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[XpotNew{z}.state(1:3);1]));
            XpotNew{z}.state(1:2) = sqrt(XpotNew{z}.state(1,:).^2+XpotNew{z}.state(2,:).^2).*...
                                        [cos(heading+atan(XpotNew{z}.state(2,:)./XpotNew{z}.state(1,:))); ...
                                        sin(heading+atan(XpotNew{z}.state(2,:)./XpotNew{z}.state(1,:)))];
            XpotNew{z}.state(1:3) = XpotNew{z}.state(1:3) + pose{k}(1:3,4);
        end
        
        XpotNew{z}.P = covBirth;
        
        
        newLabel = newLabel+1;
        XpotNew{z}.nbrMeasAss = 1; % TAGass Nbr meas assignments
        
        
        
        
        %--alt 2--
        %w2 = w2/sum(w2);
        %--alt 2--
        % TODOTODO: ERROR HERE!!
        % Find posterior
%         for i = 1:size(w,2)
%             % TODO: Is the moment matching correct? 
%             XpotNew{z}.state(1:nbrPosStates) = XpotNew{z}.state(1:nbrPosStates)+w(1,i)*XmuUpd{z}(i).state(1:nbrPosStates); % (44)
%             XpotNew{z}.P(1:nbrPosStates,1:nbrPosStates) = XpotNew{z}.P(1:nbrPosStates,1:nbrPosStates)+w(1,i)*XmuUpd{z}(i).P(1:nbrPosStates,1:nbrPosStates); % (44)
%         
%             %--alt 2--
%             %XpotNew2{z}.state(1:nbrPosStates) = XpotNew2{z}.state(1:nbrPosStates)+w2(1,i)*XmuUpd2{z}(i).state(1:nbrPosStates); % (44)
%             %XpotNew2{z}.P(1:nbrPosStates,1:nbrPosStates) = XpotNew2{z}.P(1:nbrPosStates,1:nbrPosStates)+w2(1,i)*XmuUpd2{z}(i).P(1:nbrPosStates,1:nbrPosStates); % (44)
%             %--alt 2--
%         end
%         e = Pd*generateGaussianMix(Z(1:3,z), ones(1,size(Xmutmp,2)), Xmutmp, Stmp);
%         rho(z) = e+c;
%         XpotNew{z}.w = log(e+c); % rho (45) (44)
%         XpotNew{z}.r = e/rho(z); % (43) (44)
%         %[XpotNew{z}.w XpotNew{z}.r e]
%         XpotNew{z}.S = 0;
%         XpotNew{z}.box = Z(nbrMeasStates+1:nbrMeasStates+2,z);
%         XpotNew{z}.label = newLabel;
%         newLabel = newLabel+1;
%         XpotNew{z}.nbrMeasAss = 1; % TAGass Nbr meas assignments
%         if strcmp(motionModel,'cvBB')
%             XpotNew{z}.state(nbrPosStates+1:nbrPosStates+2) = Z(nbrMeasStates+1:nbrMeasStates+2,z);
%             XpotNew{z}.P(nbrPosStates+1:nbrPosStates+2,nbrPosStates+1:nbrPosStates+2) = R3dTo2d(end-1:end,end-1:end);
%             %XpotNew{z}.state(nbrPosStates+3) = 1; % If 1 at end of states
%             %XpotNew{z}.P(nbrPosStates+3,nbrPosStates+3) = 0;
%         end
        %XpotNew{z}.state(end+1) = XpotNew{z}.label;
        %distanceToMeas(XpotNew{z}.state,Z(1:2,z),'0000','training',1)
        %distanceToMeas(XpotNew2{z}.state,Z(1:2,z),'0000','training',1)
        % TODO: Add 1 as the last state?
%         XpotNew{z}.state(end+1) = 1;
%         XpotNew{z}.P(end+1,end+1) = 0;
        %XmuUpd{k,z}.w = e+c; % rho
        %XmuUpd{k,z}.r = e/XmuUpd{k,z}.w;
    end
end