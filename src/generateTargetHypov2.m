function Xhypo = generateTargetHypo(Xpred,nbrOfMeas,nbrOfGlobHyp, Pd, H, R, Z, motionModel, nbrPosStates, nbrMeasStates)
% Create missdetection hypo in index size(Z{k},2)+1
    if(isempty(Xpred)) % If we have no predicted targets, we cannot 
                          % generate hypotheses
        Xhypo{1} = [];
        return;
    end
%     for j = 1:nbrOfGlobHyp
%         for i = 1:size(Xpred{j},2)
%             Xhypo{j,nbrOfMeas+1}(i).w = Xpred{j}(i).w + log(1-Xpred{j}(i).r+Xpred{j}(i).r*(1-Pd));
%             Xhypo{j,nbrOfMeas+1}(i).r = Xpred{j}(i).r*(1-Pd)/(1-Xpred{j}(i).r+Xpred{j}(i).r*(1-Pd));
%             Xhypo{j,nbrOfMeas+1}(i).state = Xpred{j}(i).state;
%             Xhypo{j,nbrOfMeas+1}(i).P = Xpred{j}(i).P;
%             Xhypo{j,nbrOfMeas+1}(i).box = Xpred{j}(i).box;
%             Xhypo{j,nbrOfMeas+1}(i).label = Xpred{j}(i).label;
%             Xhypo{j,nbrOfMeas+1}(i).S = 0;
%             Xhypo{j,nbrOfMeas+1}(i).nbrMeasAss = Xpred{j}(i).nbrMeasAss; % TAGass
%         end
%     end
%          
    % Generate hypothesis for each single in each global for each measurement 
    %zInd = 1;
    

    
    for j = 1:nbrOfGlobHyp
        for i = 1:size(Xpred{j},2) % Old targets
        %for m = 1 : li % number of single hypo for target i
            Xhypo{j,i}(1).w = Xpred{j}(i).w + log(1-Xpred{j}(i).r+Xpred{j}(i).r*(1-Pd));
            Xhypo{j,i}(1).r = Xpred{j}(i).r*(1-Pd)/(1-Xpred{j}(i).r+Xpred{j}(i).r*(1-Pd));
            Xhypo{j,i}(1).state = Xpred{j}(i).state;
            Xhypo{j,i}(1).P = Xpred{j}(i).P;
            Xhypo{j,i}(1).box = Xpred{j}(i).box;
            Xhypo{j,i}(1).label = Xpred{j}(i).label;
            Xhypo{j,i}(1).S = 0;
            Xhypo{j,i}(1).nbrMeasAss = Xpred{j}(i).nbrMeasAss; % TAGass
            zInd = 2;
            for z = 1:nbrOfMeas
                if(gating(Z(:,z),H,Xpred{j}(i),R,100))
                    if strcmp(motionModel,'cv')
                        %[Xhypo(i).state, Xhypo(i).P, Xhypo(i).S] = KFUpd(Xpred(i).state, H, Xpred(i).P, R, Z(1:nbrMeasStates,z));
                        [Xhypo{j,i}(m).state, Xhypo{j,i}(m).P, Xhypo{j,z}(i).S] = KFUpd(Xpred(i).state, H, Xpred(i).P, R, Z(1:nbrMeasStates));
                        [R,err] = cholcov(Xhypo{j,z}(i).S,0);
                        if err ~= 0
                            %error(message('stats:mvnpdf:BadMatrixSigma'));
                            keyboard;
                        end
                        Xhypo{j,i}(m).w = Xpred(i).w + log(Xpred(i).r*Pd) + log_mvnpdf(Z(1:nbrMeasStates), H*Xpred(i).state, Xhypo{j}(i).S);
                        Xhypo{j,i}(m).box = 0.4.*Xpred(i).box + 0.6.*Z(nbrMeasStates+1:nbrMeasStates+1); % Take mean bounding box?
                        %Xhypo{j,i}(m).box = Z(3:4,z);
                    elseif strcmp(motionModel,'cvBB')
                        [Xhypo{j,i}(zInd).state, Xhypo{j,i}(zInd).P, Xhypo{j,i}(zInd).S] = KFUpd(Xpred{j}(i).state, H, Xpred{j}(i).P, R, Z(1:nbrMeasStates+2,z));
                        Xhypo{j,i}(zInd).w = Xpred{j}(i).w + log(Xpred{j}(i).r*Pd) + log_mvnpdf(Z(1:nbrMeasStates,z), H(1:nbrMeasStates,1:nbrMeasStates)*Xpred{j}(i).state(1:nbrMeasStates), Xhypo{j,i}(zInd).S(1:nbrMeasStates,1:nbrMeasStates));
                        Xhypo{j,i}(zInd).box = Xhypo{j,i}(zInd).state(nbrPosStates+1:nbrPosStates+2);
                    end
                    Xhypo{j,i}(zInd).r = 1;
                    Xhypo{j,i}(zInd).label = Xpred{j}(i).label;
                    Xhypo{j,i}(zInd).nbrMeasAss = Xpred{j}(i).nbrMeasAss+1; % TAGass
                    zInd = zInd + 1;
%                 else
%                     zInd = max(2,zInd - 1);
%                     jInd = jInd + 1;
%                 else
%                     zInd = max(1,zInd - 1);
%                     else
%                         Xhypo{j,z}(i).state = [];%ones(size(Xpred{1}(1).state));
%                         Xhypo{j,z}(i).P = eye(size(Xpred{1}(1).P));
%                         Xhypo{j,z}(i).S = eye(size(Xpred{1}(1).P));
%                         Xhypo{j,z}(i).w = -1000;
%                         Xhypo{j,z}(i).box = [313;313];
%                         Xhypo{j,z}(i).r = 1;
%                         Xhypo{j,z}(i).label = 313313;
%                         Xhypo{j,z}(i).nbrMeasAss = 0; % TAGass
                 end
%                 zInd = zInd + 1;
            end
        end
    end
end