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
                = KFUpdUnd(XmuPred(i).state,H3dTo2d(1:2,1:nbrPosStates), XmuPred(i).P, R3dTo2d(1:2,1:2), Z(1:2,z));
            
            Rd = Rdistance(XmuUpd{z}(i).state);
            [XmuUpd{z}(i).state, XmuUpd{z}(i).P, XmuUpd{z}(i).S(3,3)]...
                = EKFupdate(XmuUpd{z}(i).state, XmuUpd{z}(i).P, Hdistance, Jh, Rd, Z(3,z));
            % TODO: DEFINE THESE AS FUNCTIONS AND JUST PASS DIFF z? 
            % Compute weight
            
            w(1,i) = XmuPred(i).w*mvnpdf(Z(1:3,z), [H3dTo2d(1:2,1:nbrPosStates)*XmuPred(i).state; Hdistance(XmuPred(i).state)], XmuUpd{z}(i).S);
            
            % TODO: temp solution
            Xmutmp(1:3,i) = [H3dTo2d(1:2,1:nbrPosStates)*XmuPred(i).state; Hdistance(XmuPred(i).state)];
            Stmp{i} = XmuUpd{z}(i).S;
        end
        % Normalize weight
        w = w/sum(w);
        % TODOTODO: ERROR HERE!!
        % Find posterior
        for i = 1:size(w,2)
            % TODO: Is the moment matching correct? 
            XpotNew{z}.state(1:nbrPosStates) = XpotNew{z}.state+w(1,i)*XmuUpd{z}(i).state; % (44)
            XpotNew{z}.P(1:nbrPosStates,1:nbrPosStates) = XpotNew{z}.P+w(1,i)*XmuUpd{z}(i).P; % (44)
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
        end
        XpotNew{z}.state(end+1) = 1;
        XpotNew{z}.P(end+1,end+1) = 0;
        %XmuUpd{k,z}.w = e+c; % rho
        %XmuUpd{k,z}.r = e/XmuUpd{k,z}.w;
    end
end