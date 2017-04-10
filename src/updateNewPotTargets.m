function [XpotNew, rho] = updateNewPotTargets(XmuPred,XmuUpd, nbrOfMeas, Pd, H, R, Z, k,c)
    rho = zeros(nbrOfMeas,1);
    for z = 1:nbrOfMeas
        % TODO: Fixed?
        %w = zeros(1,size(Z{k},2));
        w = zeros(1,size(XmuPred{k},2));
        %Xmutmp = zeros(4,size(XmuPred{k,2},2));
        %Stmp = cell(size(XmuPred{k,2},2));
        XpotNew{k,z}.state = zeros(4,1);
        XpotNew{k,z}.P = zeros(4,4);
        for i = 1:size(XmuPred{k},2)
            % Pass through Kalman
            [XmuUpd{k,z}(i).state, XmuUpd{k,z}(i).P, XmuUpd{k,z}(i).S] = KFUpd(XmuPred{k}(i).state,H, XmuPred{k}(i).P, R, Z{k}(:,z));
            
            % TODO: DEFINE THESE AS FUNCTIONS AND JUST PASS DIFF z? 
            % Compute weight
            w(1,i) = XmuPred{k}(i).w*mvnpdf(Z{k}(:,z), H*XmuPred{k}(i).state, XmuUpd{k,z}(i).S);
            
            % TODO: temp solution
            Xmutmp(1:4,i) = XmuPred{k}(i).state;
            Stmp{i} = XmuUpd{k,z}(i).S;
        end
        % Normalize weight
        w = w/sum(w);
        % TODOTODO: ERROR HERE!!
        % Find posterior
        for i = 1:size(w,2)
            % TODO: Is the moment matching correct? 
            XpotNew{k,z}.state = XpotNew{k,z}.state+w(1,i)*XmuUpd{k,z}(i).state; % (44)
            XpotNew{k,z}.P = XpotNew{k,z}.P+w(1,i)*XmuUpd{k,z}(i).P; % (44)
        end
        
        e = Pd*generateGaussianMix(Z{k}(:,z), ones(1,size(Xmutmp,2)), H*Xmutmp, Stmp);
        rho(z) = e;
        XpotNew{k,z}.w = e+c; % rho (45) (44)
        XpotNew{k,z}.r = e/XpotNew{k,z}.w; % (43) (44)
        XpotNew{k,z}.S = 0;
        %XmuUpd{k,z}.w = e+c; % rho
        %XmuUpd{k,z}.r = e/XmuUpd{k,z}.w;
    end
end