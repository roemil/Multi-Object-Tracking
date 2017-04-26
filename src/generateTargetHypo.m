function Xhypo = generateTargetHypo(Xpred,nbrOfMeas,nbrOfGlobHyp, Pd, H, R, Z, motionModel, nbrPosStates, nbrMeasStates)

% Create missdetection hypo in index size(Z{k},2)+1
    if(isempty(Xpred)) % If we have no predicted targets, we cannot 
                          % generate hypotheses
        Xhypo{1} = [];
        return;
    end
    for j = 1:nbrOfGlobHyp
        for i = 1:size(Xpred{j},2)
            Xhypo{j,nbrOfMeas+1}(i).w = Xpred{j}(i).w + log(1-Xpred{j}(i).r+Xpred{j}(i).r*(1-Pd));
            Xhypo{j,nbrOfMeas+1}(i).r = Xpred{j}(i).r*(1-Pd)/(1-Xpred{j}(i).r+Xpred{j}(i).r*(1-Pd));
            Xhypo{j,nbrOfMeas+1}(i).state = Xpred{j}(i).state;
            Xhypo{j,nbrOfMeas+1}(i).P = Xpred{j}(i).P;
            Xhypo{j,nbrOfMeas+1}(i).box = Xpred{j}(i).box;
            Xhypo{j,nbrOfMeas+1}(i).label = Xpred{j}(i).label;
            Xhypo{j,nbrOfMeas+1}(i).S = 0;
        end
    end
         
    % Generate hypothesis for each single in each global for each measurement 
    for z = 1:nbrOfMeas
        for j = 1:nbrOfGlobHyp
            for i = 1:size(Xpred{j},2)
                if strcmp(motionModel,'cv')
                    [Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Xhypo{j,z}(i).S] = KFUpd(Xpred{j}(i).state, H, Xpred{j}(i).P, R, Z(1:nbrMeasStates,z));
                    Xhypo{j,z}(i).w = Xpred{j}(i).w + log(Xpred{j}(i).r*Pd) + log_mvnpdf(Z(1:nbrMeasStates,z), H*Xpred{j}(i).state, Xhypo{j,z}(i).S);
                    Xhypo{j,z}(i).box = 0.4.*Xpred{j}(i).box + 0.6.*Z(nbrMeasStates+1:nbrMeasStates+1,z); % Take mean bounding box?
                    %Xhypo{j,z}(i).box = Z(3:4,z);
                elseif strcmp(motionModel,'cvBB')
                    [Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Xhypo{j,z}(i).S] = KFUpd(Xpred{j}(i).state, H, Xpred{j}(i).P, R, Z(1:nbrMeasStates+2,z));
                    Xhypo{j,z}(i).w = Xpred{j}(i).w + log(Xpred{j}(i).r*Pd) + log_mvnpdf(Z(1:nbrMeasStates,z), H(1:nbrMeasStates,1:nbrMeasStates)*Xpred{j}(i).state(1:nbrMeasStates), Xhypo{j,z}(i).S(1:nbrMeasStates,1:nbrMeasStates));
                    Xhypo{j,z}(i).box = Xhypo{j,z}(i).state(nbrPosStates+1:nbrPosStates+2);
                end
                %Xhypo{j,z}(i).w = Xpred{j}(i).w + log(Xpred{j}(i).r*Pd) + log_mvnpdf(Z(1:2,z), H*Xhypo{j,z}(i).state, Xhypo{j,z}(i).S);
                %[Xhypo{j,z}(i).w Xhypo{j,end}(i).w log_mvnpdf(Z(1:2,z), H*Xhypo{j,z}(i).state, Xhypo{j,z}(i).S)]
                %[Xhypo{j,z}(i).w Xhypo{j,end}(i).w log_mvnpdf(Z(1:2,z), H*Xpred{j}(i).state, Xhypo{j,z}(i).S)]
                %[Xhypo{j,z}(i).w Xhypo{j,end}(i).w log_mvnpdf(Z(1:2,z), H(1:2,1:2)*Xpred{j}(i).state(1:2), Xhypo{j,z}(i).S(1:2,1:2))]
                %Xhypo{j,z}(i).w
                %[Z(1:2,z), H*Xpred{j}(i).state]
                %[Z(1:2,z), H*Xhypo{j,z}(i).state]
                %Xhypo{j,end}(i).w
                %Xhypo{j,z}(i).w = Xhypo{j,z}(i).w+0.2;
                %if c == 13
                %    keyboard
                %end
%                 tmp = H(1:2,1:4)*Xpred{j}(i).state(1:4);
%                 tmp2 = H(1:2,1:4)*Xhypo{j,z}(i).state(1:4);
%                 figure;
%                 plot(Z(1,z),Z(2,z),'+r','markersize',10)
%                 hold on 
%                 plot(tmp(1), tmp(2),'*b')
%                 plot(tmp2(1), tmp2(2),'*g')
%                 n = 100;
%                 phi = linspace(0,2*pi,n);
%                 tmp2 = tmp;
%                 x = repmat(tmp2,1,n)+3*sqrtm(Xhypo{j,z}(i).S(1:2,1:2))*[cos(phi);sin(phi)];
%                 plot(x(1,:),x(2,:),'-k','LineWidth',2)
%                 x = repmat(tmp2,1,n)+sqrtm(Xhypo{j,z}(i).S(1:2,1:2))*[cos(phi);sin(phi)];
%                 plot(x(1,:),x(2,:),'-c','LineWidth',2)
%                 legend('Z','Pred','Upd','3\sigma','\sigma')
%                 waitforbuttonpress
                if isnan(Xhypo{j,z}(i).w)
                   keyboard
                end
                Xhypo{j,z}(i).r = 1;
                Xhypo{j,z}(i).label = Xpred{j}(i).label;
            end
        end
    end
end