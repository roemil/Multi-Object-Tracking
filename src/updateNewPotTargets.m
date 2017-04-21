function [XpotNew, rho, newLabel] = updateNewPotTargets(XmuPred, nbrOfMeas, Pd, H, R, Z, c, newLabel)
    rho = zeros(nbrOfMeas,1);
    for z = 1:nbrOfMeas
        % TODO: Fixed?
        %w = zeros(1,size(Z{k},2));
        w = zeros(1,size(XmuPred,2));
        %Xmutmp = zeros(4,size(XmuPred{k,2},2));
        %Stmp = cell(size(XmuPred{k,2},2));
        XpotNew{z}.state = zeros(4,1);
        XpotNew{z}.P = zeros(4,4);
        for i = 1:size(XmuPred,2)
            % Pass through Kalman
            [XmuUpd{z}(i).state, XmuUpd{z}(i).P, XmuUpd{z}(i).S] = KFUpd(XmuPred(i).state,H, XmuPred(i).P, R, Z(1:2,z));
            
            % TODO: DEFINE THESE AS FUNCTIONS AND JUST PASS DIFF z? 
            % Compute weight
            w(1,i) = XmuPred(i).w*mvnpdf(Z(1:2,z), H*XmuPred(i).state, XmuUpd{z}(i).S);
            
            % TODO: temp solution
            Xmutmp(1:4,i) = XmuPred(i).state;
            Stmp{i} = XmuUpd{z}(i).S;
        end
        % Normalize weight
        w = w/sum(w);
        % TODOTODO: ERROR HERE!!
        % Find posterior
        for i = 1:size(w,2)
            % TODO: Is the moment matching correct? 
            XpotNew{z}.state = XpotNew{z}.state+w(1,i)*XmuUpd{z}(i).state; % (44)
            XpotNew{z}.P = XpotNew{z}.P+w(1,i)*XmuUpd{z}(i).P; % (44)
        end
        
        e = Pd*generateGaussianMix(Z(1:2,z), ones(1,size(Xmutmp,2)), H*Xmutmp, Stmp);
        rho(z) = e+c;
        XpotNew{z}.w = log(e+c); % rho (45) (44)
        XpotNew{z}.r = e/rho(z); % (43) (44)
        XpotNew{z}.S = 0;
        XpotNew{z}.box = Z(3:4,z);
        XpotNew{z}.label = newLabel;
        newLabel = newLabel+1;
        %XmuUpd{k,z}.w = e+c; % rho
        %XmuUpd{k,z}.r = e/XmuUpd{k,z}.w;
    end
end