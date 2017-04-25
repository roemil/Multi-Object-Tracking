function [XpotNew, rho, newLabel] = updateNewPotTargets(XmuPred, nbrOfMeas, Pd, H, R, Z, c, newLabel,motionModel,posStates,nbrStates,nbrMeas)
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
            [XmuUpd{z}(i).state(1:posStates,1), XmuUpd{z}(i).P(1:posStates,1:posStates), XmuUpd{z}(i).S(1:nbrMeas,1:nbrMeas)]...
                = KFUpd(XmuPred(i).state(1:posStates),H(1:nbrMeas,1:posStates), XmuPred(i).P(1:posStates,1:posStates), R(1:nbrMeas,1:nbrMeas), Z(1:nbrMeas,z));
            % TODO: DEFINE THESE AS FUNCTIONS AND JUST PASS DIFF z? 
            % Compute weight
            w(1,i) = XmuPred(i).w*mvnpdf(Z(1:nbrMeas,z), H(1:nbrMeas,1:posStates)*XmuPred(i).state(1:posStates), XmuUpd{z}(i).S(1:nbrMeas,1:nbrMeas));
            
            % TODO: temp solution
            Xmutmp(:,i) = XmuPred(i).state;
            Stmp{i} = XmuUpd{z}(i).S;
        end
        % Normalize weight
        w = w/sum(w);
        % TODOTODO: ERROR HERE!!
        % Find posterior
        for i = 1:size(w,2)
            % TODO: Is the moment matching correct? 
            XpotNew{z}.state(1:posStates) = XpotNew{z}.state(1:posStates)+w(1,i)*XmuUpd{z}(i).state(1:posStates); % (44)
            XpotNew{z}.P(1:posStates,1:posStates) = XpotNew{z}.P(1:posStates,1:posStates)+w(1,i)*XmuUpd{z}(i).P(1:posStates,1:posStates); % (44)
        end
        
        e = Pd*generateGaussianMix(Z(1:nbrMeas,z), ones(1,size(Xmutmp,2)), H(1:nbrMeas,1:posStates)*Xmutmp(1:posStates,:), Stmp);
        rho(z) = e+c;
        XpotNew{z}.w = log(e+c); % rho (45) (44)
        XpotNew{z}.r = e/rho(z); % (43) (44)
        XpotNew{z}.S = 0;
        XpotNew{z}.box = Z(3:4,z);
        XpotNew{z}.label = newLabel;
        newLabel = newLabel+1;
        if strcmp(motionModel,'cvBB')
            XpotNew{z}.state(5:6) = Z(3:4,z);
        end
        %XmuUpd{k,z}.w = e+c; % rho
        %XmuUpd{k,z}.r = e/XmuUpd{k,z}.w;
    end
end