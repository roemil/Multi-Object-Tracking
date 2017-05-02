function [XpotNew, rho, newLabel] = updateNewPotTargets(XmuPred, nbrOfMeas, ...
    Pd, H3dTo2d, Hdistance, R3dTo2d, Rdistance, Jh, Z, c, newLabel,motionModel,nbrPosStates,nbrStates,nbrMeasStates)

    rho = zeros(nbrOfMeas,1);
    
    for z = 1:nbrOfMeas
        % TODO: Fixed?
        %w = zeros(1,size(Z{k},2));
        w = zeros(1,size(XmuPred,2));
        %Xmutmp = zeros(4,size(XmuPred{k,2},2));
        %Stmp = cell(size(XmuPred{k,2},2));
        XpotNew{z}.state = zeros(nbrStates,1);
        XpotNew{z}.P = zeros(nbrStates,nbrStates);
        for i = 1:size(XmuPred,2)
            % Pass through Kalman
             [XmuUpd{z}(i).state, XmuUpd{z}(i).P, XmuUpd{z}(i).S(1:2,1:2)]...
                 = KFUpd3dTo2d(XmuPred(i).state,H3dTo2d, XmuPred(i).P, R3dTo2d(1:2,1:2), Z(1:2,z));
            
            % Test!!!!!
            %tmp1 = H3dTo2d*XmuPred(i).state;
            %tmp2 = tmp1(1:2)/tmp1(3);
            %tmp2(3:9) = 0;
            %[XmuUpd{z}(i).state, XmuUpd{z}(i).P, XmuUpd{z}(i).S(1:2,1:2)]...
            %    = KFUpd3dTo2d(tmp2, diag([1,1,zeros(1,7)]), XmuPred(i).P, R3dTo2d(1:2,1:2), Z(1:2,z));

            % FOR CHECK
            %tmp = distanceToMeas(XmuUpd{z}(i).state,Z(1:2,z),'0000','training',1);
            
            Rd = 0.1;%Rdistance(XmuUpd{z}(i).state)/10;
%             [XmuUpd{z}(i).state, XmuUpd{z}(i).P, XmuUpd{z}(i).S(3,3)]...
%                 = EKFupdate(XmuUpd{z}(i).state, XmuUpd{z}(i).P, Hdistance, Jh, Rd, Z(3,z));

            [XmuUpd{z}(i).state(1:end-1), XmuUpd{z}(i).P(1:end-1,1:end-1), XmuUpd{z}(i).S(3,3)]...
                = CKFupdate(XmuUpd{z}(i).state(1:end-1), XmuUpd{z}(i).P(1:end-1,1:end-1), Hdistance, Rd, Z(3,z), 4);

            % FOR CHECK
            %[distanceToMeas(XmuPred(i).state,Z(1:2,z),'0000','training',1),tmp, distanceToMeas(XmuUpd{z}(i).state,Z(1:2,z),'0000','training',1)]
            % TODO: DEFINE THESE AS FUNCTIONS AND JUST PASS DIFF z? 
            % Compute weight
            
            w(1,i) = XmuPred(i).w*mvnpdf(Z(1:3,z), [H3dTo2d(1:2,:)*XmuPred(i).state; Hdistance(XmuPred(i).state)], XmuUpd{z}(i).S);
            
            % TODO: temp solution
            Xmutmp(1:3,i) = [H3dTo2d(1:2,:)*XmuPred(i).state; Hdistance(XmuPred(i).state)];
            Stmp{i} = XmuUpd{z}(i).S;
        end
        % Normalize weight
        w = w/sum(w);
        % TODOTODO: ERROR HERE!!
        % Find posterior
        for i = 1:size(w,2)
            % TODO: Is the moment matching correct? 
            XpotNew{z}.state(1:nbrPosStates) = XpotNew{z}.state(1:nbrPosStates)+w(1,i)*XmuUpd{z}(i).state(1:nbrPosStates); % (44)
            XpotNew{z}.P(1:nbrPosStates,1:nbrPosStates) = XpotNew{z}.P(1:nbrPosStates,1:nbrPosStates)+w(1,i)*XmuUpd{z}(i).P(1:nbrPosStates,1:nbrPosStates); % (44)
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
            XpotNew{z}.state(nbrPosStates+3) = 1;
            XpotNew{z}.P(nbrPosStates+3,nbrPosStates+3) = 0;
        end
        % TODO: Add 1 as the last state?
%         XpotNew{z}.state(end+1) = 1;
%         XpotNew{z}.P(end+1,end+1) = 0;
        %XmuUpd{k,z}.w = e+c; % rho
        %XmuUpd{k,z}.r = e/XmuUpd{k,z}.w;
    end
end