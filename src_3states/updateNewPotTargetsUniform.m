function [XpotNew, rho, newLabel] = updateNewPotTargetsUniform(XmuPred, nbrOfMeas, ...
    Z, newLabel,motionModel, nbrPosStates, unifdist)
global Pd, global H3dFunc, global Hdistance, global R3dTo2d, global Rdistance, global Jh
global c, global nbrStates, global nbrMeasStates, global H, global R,
global pose, global k, global angles, global FOVsize

    rho = zeros(nbrOfMeas,1);
    
    for z = 1:nbrOfMeas
        % TODO: Fixed?
        %w = zeros(1,size(Z{k},2));
        %w = zeros(1,size(XmuPred,2));
        %Xmutmp = zeros(4,size(XmuPred{k,2},2));
        %Stmp = cell(size(XmuPred{k,2},2));
        XpotNew{z}.state = zeros(4,1);
        XpotNew{z}.P = zeros(nbrStates,nbrStates);
        
        XpotNew2{z}.state = zeros(nbrStates,1);
        XpotNew2{z}.P = zeros(nbrStates,nbrStates);
        %for i = 1:size(XmuPred,2)
            % Pass through Kalman
            
            %  [XmuUpd{z}(i).state, XmuUpd{z}(i).P, XmuUpd{z}(i).S(1:2,1:2)]...
            %      = KFUpd3dTo2d(XmuPred(i).state,H3dTo2d, XmuPred(i).P, R3dTo2d(1:2,1:2), Z(1:2,z));
            
            % --alt 2-- Can do the update of pix center and distance in 2 steps
            %[XmuUpd2{z}(i).state, XmuUpd2{z}(i).P, XmuUpd2{z}(i).S(1:2,1:2)]...
            %     = CKFupdate(XmuPred(i).state, XmuPred(i).P, H3dFunc, Z(1:2,z), R3dTo2d(1:2,1:2),8);
            % FOR CHECK
            %tmp = distanceToMeas(XmuUpd2{z}(i).state,Z(1:2,z),'0000','training',1);
            %[distanceToMeas(XmuPred(i).state,Z(1:2,z),'0000','training',1), tmp]
            
            %Rd = Rdistance(XmuUpd{z}(i).state);
            %[XmuUpd2{z}(i).state, XmuUpd2{z}(i).P, XmuUpd2{z}(i).S(3,3)]...
            %    = CKFupdate(XmuUpd2{z}(i).state, XmuUpd2{z}(i).P, Hdistance, Z(3,z), Rd, 8);
            %tmp2 = distanceToMeas(XmuUpd2{z}(i).state,Z(1:2,z),'0000','training',1);
            % --alt 2--
            
            % Current, do update on pix center and distance simultaneously
            [XmuUpd{z}.state, XmuUpd{z}.P, XmuUpd{z}.S]...
                 = CKFupdate(XmuPred(z).state, XmuPred(z).P, H, Z(1:3,z), R, 6);
            
            % FOR CHECK
            %[distanceToMeas(XmuPred(i).state,Z(1:2,z),'0000','training',1);tmp; tmp2; distanceToMeas(XmuUpd{z}(i).state,Z(1:2,z),'0000','training',1)]
            % TODO: DEFINE THESE AS FUNCTIONS AND JUST PASS DIFF z? 
            % Compute weight
            
            % Only yaw
            %w(1,i) = XmuPred(i).w*mvnpdf(Z(1:3,z), H(XmuPred(i).state,pose{k}(1:3,4), angles{k}.heading-angles{1}.heading), XmuUpd{z}(i).S);
            % Full Rotation matrix
            %w(1,i) = XmuPred(i).w*mvnpdf(Z(1:3,z), H(XmuPred(i).state,pose{k}(1:3,4), angles,k), XmuUpd{z}(i).S);
            
            % TODO: temp solution
            % Only yaw
            Xmutmp(1:3,z) = H(XmuPred(z).state,pose{k}(1:3,4), angles{k}.heading-angles{1}.heading);
            % Full rotation matrix
            %Xmutmp(1:3,i) = H(XmuPred(i).state,pose{k}(1:3,4), angles,k);
            Stmp{z} = XmuUpd{z}.S;
            
            % --alt 2--
            %w2(1,i) = XmuPred(i).w*mvnpdf(Z(1:3,z), [H3dFunc(XmuPred(i).state); Hdistance(XmuPred(i).state)], XmuUpd2{z}(i).S);
            %Xmutmp2(1:3,i) = [H3dFunc(XmuPred(i).state); Hdistance(XmuPred(i).state)];
            %Stmp2{i} = XmuUpd{z}(i).S;
            % --alt 2--
        %end
        % Normalize weight
        %w = w/sum(w);
        %e = Pd*generateGaussianMix(Z(1:3,z), ones(1,size(Xmutmp,2)), Xmutmp, Stmp);
        e = Pd*mvnpdf(Z(1:3,z), Xmutmp(1:3,z), Stmp{z});
        rho(z) = e+c;
        XpotNew{z}.w = log(e+c); % rho (45) (44)
        XpotNew{z}.r = e/rho(z); % (43) (44)
        %[XpotNew{z}.w XpotNew{z}.r e]
        XpotNew{z}.S = 0;
        XpotNew{z}.box = Z(nbrMeasStates+1:nbrMeasStates+2,z);
        XpotNew{z}.label = newLabel;
        XpotNew{z}.state = XmuUpd{z}.state;
        XpotNew{z}.P = XmuUpd{z}.P;
        newLabel = newLabel+1;
        XpotNew{z}.nbrMeasAss = 1; % TAGass Nbr meas assignments
        if strcmp(motionModel,'cvBB')
            XpotNew{z}.state(nbrPosStates+1:nbrPosStates+2) = Z(nbrMeasStates+1:nbrMeasStates+2,z);
            XpotNew{z}.P(nbrPosStates+1:nbrPosStates+2,nbrPosStates+1:nbrPosStates+2) = R3dTo2d(end-1:end,end-1:end);
            %XpotNew{z}.state(nbrPosStates+3) = 1; % If 1 at end of states
            %XpotNew{z}.P(nbrPosStates+3,nbrPosStates+3) = 0;
        end
        
        
        
        
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