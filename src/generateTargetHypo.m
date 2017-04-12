function Xhypo = generateTargetHypo(Xpred,nbrOfMeas,nbrOfGlobHyp, Pd, H, R, Z)
% Create missdetection hypo in index size(Z{k},2)+1
    if(isempty(Xpred)) % If we have no predicted targets, we cannot 
                          % generate hypotheses
        Xhypo{1} = [];
        return;
    end
    for j = 1:nbrOfGlobHyp
        for i = 1:size(Xpred{j},2)
            Xhypo{j,nbrOfMeas+1}(i).w = Xpred{j}(i).w*(1-Xpred{j}(i).r+Xpred{j}(i).r*(1-Pd));
            Xhypo{j,nbrOfMeas+1}(i).r = Xpred{j}(i).r*(1-Pd)/(1-Xpred{j}(i).r+Xpred{j}(i).r*(1-Pd));
            Xhypo{j,nbrOfMeas+1}(i).state = Xpred{j}(i).state;
            Xhypo{j,nbrOfMeas+1}(i).P = Xpred{j}(i).P;
            Xhypo{j,nbrOfMeas+1}(i).S = 0;
        end
    end
         
    % Generate hypothesis for each single in each global for each measurement 
    for z = 1:nbrOfMeas
        for j = 1:nbrOfGlobHyp
            for i = 1:size(Xpred{j},2)
                [Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Xhypo{j,z}(i).S] = KFUpd(Xpred{j}(i).state, H, Xpred{j}(i).P, R, Z(:,z));
                Xhypo{j,z}(i).w = Xpred{j}(i).w*Xpred{j}(i).r*Pd*mvnpdf(Z(:,z), H*Xpred{j}(i).state, Xhypo{j,z}(i).S); 
                Xhypo{j,z}(i).r = 1;
            end
        end
    end
end