function Xhypo = generateTargetHypo(Xpred,nbrOfMeas,nbrOfGlobHyp, Z, ...
    motionModel, nbrPosStates)
 global Pd, global R, global nbrMeasStates, global H3dTo2d, global H3dFunc, ...
 global Hdistance, global R3dTo2d, global Rdistance, global H, global R,
 global pose, global k, global plotHypoConf, global angles

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
            Xhypo{j,nbrOfMeas+1}(i).nbrMeasAss = Xpred{j}(i).nbrMeasAss; % TAGass
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
                    % Bounding box center
                    %[Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Xhypo{j,z}(i).S] = KFUpd3dTo2d(Xpred{j}(i).state, H3dTo2d, Xpred{j}(i).P, R3dTo2d(1:2,1:2), Z(1:2,z));
                    [Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Xhypo{j,z}(i).S(1:nbrMeasStates,1:nbrMeasStates)]...
                        = CKFupdate(Xpred{j}(i).state,Xpred{j}(i).P, H, Z(1:nbrMeasStates,z), R, 6);
                    
                    % Bound box size
                    [Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Xhypo{j,z}(i).S(nbrMeasStates+1:5,nbrMeasStates+1:5)] = ...
                        KFUpd(Xhypo{j,z}(i).state, H3dTo2d(nbrMeasStates+1:end,1:end-1), Xhypo{j,z}(i).P, R3dTo2d(nbrMeasStates+1:end,nbrMeasStates+1:end), Z(4:5,z));
                    
                    % Distance
                    %[Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Xhypo{j,z}(i).S(3,3)]...
                    %    = CKFupdate(Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Hdistance, Rd, Z(3,z), 8);
                    
                    Xhypo{j,z}(i).w = Xpred{j}(i).w + log(Xpred{j}(i).r*Pd) + ...
                        log_mvnpdf(Z(1:nbrMeasStates,z), H(Xpred{j}(i).state,pose{k}(1:3,4),angles{k}.heading-angles{1}.heading), Xhypo{j,z}(i).S(1:nbrMeasStates,1:nbrMeasStates));
                    
                    Xhypo{j,z}(i).box = Xhypo{j,z}(i).state(nbrPosStates+1:nbrPosStates+2);
                end
                %Xhypo{j,z}(i).w = Xpred{j}(i).w + log(Xpred{j}(i).r*Pd) + log_mvnpdf(Z(1:2,z), H*Xhypo{j,z}(i).state, Xhypo{j,z}(i).S);
                %[Xhypo{j,z}(i).w Xhypo{j,end}(i).w log_mvnpdf(Z(1:2,z), H*Xhypo{j,z}(i).state, Xhypo{j,z}(i).S)]
                %[Xhypo{j,z}(i).w Xhypo{j,end}(i).w log_mvnpdf(Z(1:2,z), H*Xpred{j}(i).state, Xhypo{j,z}(i).S)]
                %Xpred{j}(i).label
%                 Xhypo{j,z}(i).S(1:3,1:3)
                if plotHypoConf
                    [Xhypo{j,z}(i).w Xhypo{j,end}(i).w log_mvnpdf(Z(1:3,z), H(Xpred{j}(i).state,pose{k}(1:3,4), angles{k}.heading-angles{1}.heading), Xhypo{j,z}(i).S(1:3,1:3))]
                    [Z(1:3,z), H(Xpred{j}(i).state,pose{k}(1:3,4)), abs(Z(1:3,z)-H(Xpred{j}(i).state,pose{k}(1:3,4),angles{k}.heading-angles{1}.heading))]
                    [Z(1:3,z), H(Xhypo{j,z}(i).state,pose{k}(1:3,4)), abs(Z(1:3,z)-H(Xhypo{j,z}(i).state,pose{k}(1:3,4),angles{k}.heading-angles{1}.heading))]
                     tmp = H(Xpred{j}(i).state,pose{k}(1:3,4),angles{k}.heading-angles{1}.heading);
                     tmp2 = H(Xhypo{j,z}(i).state,pose{k}(1:3,4),angles{k}.heading-angles{1}.heading);
                     figure;
                     plot(Z(1,z),Z(2,z),'+r','markersize',10)
                     hold on 
                     plot(tmp(1), tmp(2),'*b')
                     plot(tmp2(1), tmp2(2),'*g')
                    n = 100;
                    phi = linspace(0,2*pi,n);
                    tmp2 = tmp;
                    x = repmat(tmp2(1:2),1,n)+3*sqrtm(Xhypo{j,z}(i).S(1:2,1:2))*[cos(phi);sin(phi)];
                    plot(x(1,:),x(2,:),'-k','LineWidth',2)
                    x = repmat(tmp2(1:2),1,n)+sqrtm(Xhypo{j,z}(i).S(1:2,1:2))*[cos(phi);sin(phi)];
                    plot(x(1,:),x(2,:),'-c','LineWidth',2)
                    legend('Z','Pred','Upd','3\sigma','\sigma')
                    title(['z = ', num2str(z), ' i = ', num2str(i), ' j = ', num2str(j)])
                    waitforbuttonpress
                end
%                  estGTdiff('0000','training',2,Xpred{j}(i).state,true,true);
%                  estGTdiff('0000','training',2,Xhypo{j,z}(i).state,true,true);
%                  distanceToMeas(Xpred{j}(i).state,Z(1:2,z),'0000','training',2)
%                  distanceToMeas(Xhypo{j,z}(i).state,Z(1:2,z),'0000','training',2)
                Xhypo{j,z}(i).r = 1;
                Xhypo{j,z}(i).label = Xpred{j}(i).label;
                Xhypo{j,z}(i).nbrMeasAss = Xpred{j}(i).nbrMeasAss+1; % TAGass
            end
        end
    end
end