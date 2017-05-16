function [XpotNew, rho, newLabel] = updateNewPotTargets(XmuPred, nbrOfMeas, Pd, H, R, Z, c, newLabel,motionModel,nbrPosStates,nbrStates,nbrMeasStates)

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
            [XmuUpd{z}(i).state(1:nbrPosStates,1), XmuUpd{z}(i).P(1:nbrPosStates,1:nbrPosStates), XmuUpd{z}(i).S(1:nbrMeasStates,1:nbrMeasStates)]...
                = KFUpd(XmuPred(i).state(1:nbrPosStates),H(1:nbrMeasStates,1:nbrPosStates), XmuPred(i).P(1:nbrPosStates,1:nbrPosStates), R(1:nbrMeasStates,1:nbrMeasStates), Z(1:nbrMeasStates,z));
            % TODO: DEFINE THESE AS FUNCTIONS AND JUST PASS DIFF z? 
            % Compute weight
            w(1,i) = XmuPred(i).w*mvnpdf(Z(1:nbrMeasStates,z), H(1:nbrMeasStates,1:nbrPosStates)*XmuPred(i).state(1:nbrPosStates), XmuUpd{z}(i).S(1:nbrMeasStates,1:nbrMeasStates));
            
            % TODO: temp solution
            Xmutmp(1:nbrPosStates,i) = XmuPred(i).state(1:nbrPosStates);
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
        %XpotNew{z}.P(1:nbrPosStates,1:nbrPosStates) = XpotNew{z}.P(1:nbrPosStates,1:nbrPosStates)+20*eye(4);
        e = Pd*generateGaussianMix(Z(1:nbrMeasStates,z), ones(1,size(Xmutmp,2)), H(1:nbrMeasStates,1:nbrPosStates)*Xmutmp(1:nbrPosStates,:), Stmp);

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
            XpotNew{z}.P(nbrPosStates+1:nbrPosStates+2,nbrPosStates+1:nbrPosStates+2) = R(end-1:end,end-1:end);
        elseif strcmp(motionModel,'caBB')
            XpotNew{z}.state(nbrPosStates+3:nbrPosStates+4) = Z(nbrMeasStates+1:nbrMeasStates+2,z);
            XpotNew{z}.P(nbrPosStates+1:nbrPosStates+2,nbrPosStates+1:nbrPosStates+2) = R(end-1:end,end-1:end);
        end
        %XmuUpd{k,z}.w = e+c; % rho
        %XmuUpd{k,z}.r = e/XmuUpd{k,z}.w;
    end
end