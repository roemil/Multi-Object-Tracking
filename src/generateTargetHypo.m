function Xhypo = generateTargetHypo(Xpred,nbrOfMeas,nbrOfGlobHyp,k, Pd, H, R, Z)
% Create missdetection hypo in index size(Z{k},2)+1
    if(~isempty(Xpred{k})) % If we don't have global hypotheses then we 
                          % don't have any prevously detected targets
        for j = 1:nbrOfGlobHyp
            for i = 1:size(Xpred{k,j},2)
                if Xpred{k,j}(i).w*(1-Xpred{k,j}(i).r+Xpred{k,j}(i).r*(1-Pd)) == 0
                    %keyboard
                end
                Xhypo{k,j,nbrOfMeas+1}(i).w = Xpred{k,j}(i).w*(1-Xpred{k,j}(i).r+Xpred{k,j}(i).r*(1-Pd));
                Xhypo{k,j,nbrOfMeas+1}(i).r = Xpred{k,j}(i).r*(1-Pd)/(1-Xpred{k,j}(i).r+Xpred{k,j}(i).r*(1-Pd));
                Xhypo{k,j,nbrOfMeas+1}(i).state = Xpred{k,j}(i).state;
                Xhypo{k,j,nbrOfMeas+1}(i).P = Xpred{k,j}(i).P;
                Xhypo{k,j,nbrOfMeas+1}(i).S = 0;
            end
        end
    end
         
    % Generate hypothesis for each single in each global for each measurement 
    if(~isempty(Xpred{k}))
        for z = 1:nbrOfMeas
            for j = 1:nbrOfGlobHyp
                for i = 1:size(Xpred{k,j},2)
                    [Xhypo{k,j,z}(i).state, Xhypo{k,j,z}(i).P, Xhypo{k,j,z}(i).S] = KFUpd(Xpred{k,j}(i).state, H, Xpred{k,j}(i).P, R, Z{k}(:,z));
                    Xhypo{k,j,z}(i).w = Xpred{k,j}(i).w*Xpred{k,j}(i).r*Pd*mvnpdf(Z{k}(:,z), H*Xpred{k,j}(i).state, Xhypo{k,j,z}(i).S);
                    if Xhypo{k,j,z}(i).w == 0
                        %keyboard
                    end
                    Xhypo{k,j,z}(i).r = 1;
                end
            end
        end
    end
end