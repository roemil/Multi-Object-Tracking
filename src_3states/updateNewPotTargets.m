function [XpotNew, rho, newLabel] = updateNewPotTargets(XmuPred, nbrOfMeas, ...
    Z, newLabel,motionModel, nbrPosStates)
global Pd, global H3dFunc, global Hdistance, global R3dTo2d, global Rdistance, global Jh
global c, global nbrStates, global nbrMeasStates, global H, global R

    rho = zeros(nbrOfMeas,1);
    
    for z = 1:nbrOfMeas
        % TODO: Fixed?
        %w = zeros(1,size(Z{k},2));
        w = zeros(1,size(XmuPred,2));
        %Xmutmp = zeros(4,size(XmuPred{k,2},2));
        %Stmp = cell(size(XmuPred{k,2},2));
        XpotNew{z}.state = zeros(nbrStates,1);
        XpotNew{z}.P = zeros(nbrStates,nbrStates);
        
        XpotNew2{z}.state = zeros(nbrStates,1);
        XpotNew2{z}.P = zeros(nbrStates,nbrStates);
        for i = 1:size(XmuPred,2)
            % Pass through Kalman
            
%              [XmuUpd{z}(i).state, XmuUpd{z}(i).P, XmuUpd{z}(i).S(1:2,1:2)]...
%                  = KFUpd3dTo2d(XmuPred(i).state,H3dTo2d, XmuPred(i).P, R3dTo2d(1:2,1:2), Z(1:2,z));
            
            % Test 2!!!!
            [XmuUpd2{z}(i).state, XmuUpd2{z}(i).P, XmuUpd2{z}(i).S(1:2,1:2)]...
                 = CKFupdate(XmuPred(i).state, XmuPred(i).P, H3dFunc, Z(1:2,z), R3dTo2d(1:2,1:2),8);
            % FOR CHECK
            %tmp = distanceToMeas(XmuUpd2{z}(i).state,Z(1:2,z),'0000','training',1);
            %[distanceToMeas(XmuPred(i).state,Z(1:2,z),'0000','training',1), tmp]
            Rd = 1;%Rdistance(XmuUpd{z}(i).state)/10;
%             [XmuUpd{z}(i).state, XmuUpd{z}(i).P, XmuUpd{z}(i).S(3,3)]...
%                 = EKFupdate(XmuUpd{z}(i).state, XmuUpd{z}(i).P, Hdistance, Jh, Rd, Z(3,z));

            [XmuUpd2{z}(i).state, XmuUpd2{z}(i).P, XmuUpd2{z}(i).S(3,3)]...
                = CKFupdate(XmuUpd2{z}(i).state, XmuUpd2{z}(i).P, Hdistance, Z(3,z), Rd, 8);
            %tmp2 = distanceToMeas(XmuUpd2{z}(i).state,Z(1:2,z),'0000','training',1);
            
            % Test combine
            %H = @(x) [H3dFunc(x); Hdistance(x)];
            %R = [R3dTo2d(1:2,1:2), zeros(2,1); zeros(1,2), Rd];
            [XmuUpd{z}(i).state, XmuUpd{z}(i).P, XmuUpd{z}(i).S]...
                 = CKFupdate(XmuPred(i).state, XmuPred(i).P, H, Z(1:3,z), R, 8);
            
            % FOR CHECK
            %[distanceToMeas(XmuPred(i).state,Z(1:2,z),'0000','training',1);tmp; tmp2; distanceToMeas(XmuUpd{z}(i).state,Z(1:2,z),'0000','training',1)]
            % TODO: DEFINE THESE AS FUNCTIONS AND JUST PASS DIFF z? 
            % Compute weight
            
            w(1,i) = XmuPred(i).w*mvnpdf(Z(1:3,z), [H3dFunc(XmuPred(i).state); Hdistance(XmuPred(i).state)], XmuUpd{z}(i).S);
            
            % TODO: temp solution
            Xmutmp(1:3,i) = [H3dFunc(XmuPred(i).state); Hdistance(XmuPred(i).state)];
            Stmp{i} = XmuUpd{z}(i).S;
            
            w2(1,i) = XmuPred(i).w*mvnpdf(Z(1:3,z), [H3dFunc(XmuPred(i).state); Hdistance(XmuPred(i).state)], XmuUpd2{z}(i).S);
            Xmutmp2(1:3,i) = [H3dFunc(XmuPred(i).state); Hdistance(XmuPred(i).state)];
            Stmp2{i} = XmuUpd{z}(i).S;
        end
        % Normalize weight
        w = w/sum(w);
        w2 = w2/sum(w2);
        % TODOTODO: ERROR HERE!!
        % Find posterior
        for i = 1:size(w,2)
            % TODO: Is the moment matching correct? 
            XpotNew{z}.state(1:nbrPosStates) = XpotNew{z}.state(1:nbrPosStates)+w(1,i)*XmuUpd{z}(i).state(1:nbrPosStates); % (44)
            XpotNew{z}.P(1:nbrPosStates,1:nbrPosStates) = XpotNew{z}.P(1:nbrPosStates,1:nbrPosStates)+w(1,i)*XmuUpd{z}(i).P(1:nbrPosStates,1:nbrPosStates); % (44)
        
            XpotNew2{z}.state(1:nbrPosStates) = XpotNew2{z}.state(1:nbrPosStates)+w2(1,i)*XmuUpd2{z}(i).state(1:nbrPosStates); % (44)
            XpotNew2{z}.P(1:nbrPosStates,1:nbrPosStates) = XpotNew2{z}.P(1:nbrPosStates,1:nbrPosStates)+w2(1,i)*XmuUpd2{z}(i).P(1:nbrPosStates,1:nbrPosStates); % (44)
        end
        e = Pd*generateGaussianMix(Z(1:3,z), ones(1,size(Xmutmp,2)), Xmutmp, Stmp);
        rho(z) = e+c;
        XpotNew{z}.w = log(e+c); % rho (45) (44)
        XpotNew{z}.r = e/rho(z); % (43) (44)
        XpotNew{z}.S = 0;
        XpotNew{z}.box = Z(nbrMeasStates+1:nbrMeasStates+2,z);
        XpotNew{z}.label = newLabel;
        newLabel = newLabel+1;
        XpotNew{z}.nbrMeasAss = 1; % TAGass Nbr meas assignments
        if strcmp(motionModel,'cvBB')
            XpotNew{z}.state(nbrPosStates+1:nbrPosStates+2) = Z(nbrMeasStates+1:nbrMeasStates+2,z);
            XpotNew{z}.P(nbrPosStates+1:nbrPosStates+2,nbrPosStates+1:nbrPosStates+2) = R3dTo2d(end-1:end,end-1:end);
            %XpotNew{z}.state(nbrPosStates+3) = 1; % If 1 at end of states
            %XpotNew{z}.P(nbrPosStates+3,nbrPosStates+3) = 0;
        end
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