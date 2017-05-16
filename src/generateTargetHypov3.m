function [Xhypo, S] = generateTargetHypov3(Xpred,nbrOfMeas,nbrOfGlobHyp, Pd, H, R, Z, motionModel, nbrPosStates, nbrMeasStates,fr1,fr2)
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
%          
    % Generate hypothesis for each single in each global for each measurement 
    %zInd = 1;
    Stmp = cell(nbrOfMeas,nbrOfGlobHyp);
    for z = 1:nbrOfMeas
        for j = 1:nbrOfGlobHyp
            nbrMeasObj = nbrOfMeas+size(Xpred{j},2);
            ind = 1;
            for i = 1:size(Xpred{j},2)
                if(gating(Z(:,z),H(1:2,1:6),Xpred{j}(i),R,100)) % 100
                    if strcmp(motionModel,'cv')
                        %[Xhypo(i).state, Xhypo(i).P, Xhypo(i).S] = KFUpd(Xpred(i).state, H, Xpred(i).P, R, Z(1:nbrMeasStates,z));
                        [Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Xhypo{j,z}(i).S] = KFUpd(Xpred(i).state, H, Xpred(i).P, R, Z(1:nbrMeasStates));
                        Xhypo{j,z}(i).w = Xpred(i).w + log(Xpred(i).r*Pd) + log_mvnpdf(Z(1:nbrMeasStates), H*Xpred(i).state, Xhypo{j}(i).S);
                        Xhypo{j,z}(i).box = 0.4.*Xpred(i).box + 0.6.*Z(nbrMeasStates+1:nbrMeasStates+1); % Take mean bounding box?
                        %Xhypo{j,z}(i).box = Z(3:4,z);
                    elseif strcmp(motionModel,'ca')
                        %[Xhypo(i).state, Xhypo(i).P, Xhypo(i).S] = KFUpd(Xpred(i).state, H, Xpred(i).P, R, Z(1:nbrMeasStates,z));
                        %[u,v] = calcOptFlow(Xpred{j}(i).state(1:2),fr1,fr2,10);
                        %meas = [Z(1:nbrMeasStates,z);u;v];
                        [Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Xhypo{j,z}(i).S] = KFUpd(Xpred{j}(i).state, H, Xpred{j}(i).P, R, Z(1:nbrMeasStates,z));
                        Xhypo{j,z}(i).w = Xpred{j}(i).w + log(Xpred{j}(i).r*Pd) + log_mvnpdf(Z(1:nbrMeasStates,z), H(1:2,1:6)*Xpred{j}(i).state, Xhypo{j,z}(i).S(1:2,1:2));
                        Xhypo{j,z}(i).box = 0.4.*Xpred{j}(i).box + 0.6.*Z(nbrMeasStates+1:nbrMeasStates+2,z); % Take mean bounding box?
                        %Xhypo{j,z}(i).box = Z(3:4,z);
                        %Xhypo{j,z}(i).box = Xhypo{j,z}(i).state(nbrPosStates+3:nbrPosStates+4);
                    elseif strcmp(motionModel,'caBB')
                        %[Xhypo(i).state, Xhypo(i).P, Xhypo(i).S] = KFUpd(Xpred(i).state, H, Xpred(i).P, R, Z(1:nbrMeasStates,z));
                        %[u,v] = calcOptFlow(Xpred{j}(i).state(1:2),fr1,fr2,10);
                        %meas = [Z(1:nbrMeasStates,z);u;v];
                        [Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Xhypo{j,z}(i).S] = KFUpd(Xpred{j}(i).state, H, Xpred{j}(i).P, R, Z(1:nbrMeasStates+2,z));
                        Xhypo{j,z}(i).w = Xpred{j}(i).w + log(Xpred{j}(i).r*Pd) + log_mvnpdf(Z(1:nbrMeasStates,z),  H(1:nbrMeasStates,1:nbrMeasStates)*Xpred{j}(i).state(1:nbrMeasStates), Xhypo{j,z}(i).S(1:nbrMeasStates,1:nbrMeasStates));
                        %Xhypo{j,z}(i).box = 0.4.*Xpred{j}(i).box + 0.6.*Z(nbrMeasStates+1:nbrMeasStates+2,z); % Take mean bounding box?
                        %Xhypo{j,z}(i).box = Z(3:4,z);
                        Xhypo{j,z}(i).box = Xhypo{j,z}(i).state(nbrPosStates+3:nbrPosStates+4);
                    elseif strcmp(motionModel,'cvBB')
                        [Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Xhypo{j,z}(i).S] = KFUpd(Xpred{j}(i).state, H, Xpred{j}(i).P, R, Z(1:nbrMeasStates+2,z));
                        Xhypo{j,z}(i).w = Xpred{j}(i).w + log(Xpred{j}(i).r*Pd) + log_mvnpdf(Z(1:nbrMeasStates,z), H(1:nbrMeasStates,1:nbrMeasStates)*Xpred{j}(i).state(1:nbrMeasStates), Xhypo{j,z}(i).S(1:nbrMeasStates,1:nbrMeasStates));
                        Xhypo{j,z}(i).box = Xhypo{j,z}(i).state(nbrPosStates+1:nbrPosStates+2);
                    end
                    Xhypo{j,z}(i).r = 1;
                    Xhypo{j,z}(i).label = Xpred{j}(i).label;
                    Xhypo{j,z}(i).nbrMeasAss = Xpred{j}(i).nbrMeasAss+1; % TAGass
                    Stmp{z,j}(ind,1:nbrMeasObj) = 0;
                    Stmp{z,j}(ind,i) = 1;
                    ind = ind+1;
               else
                   Xhypo{j,z}(i).state = [];%ones(size(Xpred{1}(1).state));
                    Xhypo{j,z}(i).P = 0; %eye(size(Xpred{1}(1).P));
                    Xhypo{j,z}(i).S = 0; %eye(size(Xpred{1}(1).P));
                    Xhypo{j,z}(i).w = -1000;
                    Xhypo{j,z}(i).box = [313;313];
                    Xhypo{j,z}(i).r = 1;
                    Xhypo{j,z}(i).label = 313313;
                    Xhypo{j,z}(i).nbrMeasAss = 0; % TAGass
                end
            end
            Stmp{z,j}(end+1,1:nbrMeasObj) = 0;
            Stmp{z,j}(end,size(Xpred{j},2)+z) = 1;
        end
    end

S = zeros(nbrOfMeas,1,1,nbrOfGlobHyp);
indvInd = zeros(nbrOfMeas,2);
for j = 1:nbrOfGlobHyp
    for z = 1:nbrOfMeas
        indvInd(z,:) = [1, size(Stmp{z,j},1)];
    end
    ind = 1;
    nbrObj = size(Xhypo{j,1},2);
    while indvInd(1,1) <= indvInd(1,2)
        for z = 1:size(Stmp,1)
            S(z,1:(nbrObj+nbrOfMeas),ind,j) = Stmp{z,j}(indvInd(z,1),:);
        end
        indvInd(nbrOfMeas,1) = indvInd(nbrOfMeas,1)+1;
        for indI = nbrOfMeas:-1:2
            if indvInd(indI,1) > indvInd(indI,2)
                indvInd(indI,1) = 1;
                indvInd(indI-1,1) = indvInd(indI-1,1)+1;
            end
        end
        %sumCol = sum(S(:,:,ind,j));
        if sum(sum(S(:,:,ind,j))) == 0
            keyboard
        end
        if isempty(find(sum(S(:,:,ind,j)) > 1,1))
            ind = ind+1;
        end
    end
end

% OLD TRY
% j = 1;
% Amat = zeros(1,nbrOfMeas);
% for z = 1:nbrOfMeas
%     ind = 1;
%     nbrObj = size(Stmp{z,j},1);
%     newInd = ind+nbrObj-1;
%     [~, Amat(ind:newInd,z)] = find(Stmp{z,j} == 1); 
%     ind = newInd+1;
% end
% %
% % Create missdetection hypo in index size(Z{k},2)+1
%     if(isempty(Xpred)) % If we have no predicted targets, we cannot 
%                           % generate hypotheses
%         Xhypo{1} = [];
%         return;
%     end
% %     for j = 1:nbrOfGlobHyp
% %         for i = 1:size(Xpred{j},2)
% %             Xhypo{j,nbrOfMeas+1}(i).w = Xpred{j}(i).w + log(1-Xpred{j}(i).r+Xpred{j}(i).r*(1-Pd));
% %             Xhypo{j,nbrOfMeas+1}(i).r = Xpred{j}(i).r*(1-Pd)/(1-Xpred{j}(i).r+Xpred{j}(i).r*(1-Pd));
% %             Xhypo{j,nbrOfMeas+1}(i).state = Xpred{j}(i).state;
% %             Xhypo{j,nbrOfMeas+1}(i).P = Xpred{j}(i).P;
% %             Xhypo{j,nbrOfMeas+1}(i).box = Xpred{j}(i).box;
% %             Xhypo{j,nbrOfMeas+1}(i).label = Xpred{j}(i).label;
% %             Xhypo{j,nbrOfMeas+1}(i).S = 0;
% %             Xhypo{j,nbrOfMeas+1}(i).nbrMeasAss = Xpred{j}(i).nbrMeasAss; % TAGass
% %         end
% %     end
% %          
%     % Generate hypothesis for each single in each global for each measurement 
%     %zInd = 1;
%     %for z = 1:nbrOfMeas
%         %for j = 1:nbrOfGlobHyp
%             for i = 1:size(Xpred,2)
%                 %if(gating(Z(:,z),H,Xpred{j}(i),R,500))
%                     if strcmp(motionModel,'cv')
%                         %[Xhypo(i).state, Xhypo(i).P, Xhypo(i).S] = KFUpd(Xpred(i).state, H, Xpred(i).P, R, Z(1:nbrMeasStates,z));
%                         [Xhypo(i).state, Xhypo(i).P, Xhypo(i).S] = KFUpd(Xpred(i).state, H, Xpred(i).P, R, Z(1:nbrMeasStates));
%                         [R,err] = cholcov(Xhypo(i).S,0);
%                         if err ~= 0
%                             %error(message('stats:mvnpdf:BadMatrixSigma'));
%                             keyboard;
%                         end
%                         Xhypo(i).w = Xpred(i).w + log(Xpred(i).r*Pd) + log_mvnpdf(Z(1:nbrMeasStates), H*Xpred(i).state, Xhypo{j}(i).S);
%                         Xhypo(i).box = 0.4.*Xpred(i).box + 0.6.*Z(nbrMeasStates+1:nbrMeasStates+1); % Take mean bounding box?
%                         %Xhypo{j,z}(i).box = Z(3:4,z);
%                     elseif strcmp(motionModel,'cvBB')
%                         [Xhypo(i).state, Xhypo(i).P, Xhypo(i).S] = KFUpd(Xpred(i).state, H, Xpred(i).P, R, Z(1:nbrMeasStates+2));
%                         Xhypo(i).w = Xpred(i).w + log(Xpred(i).r*Pd) + log_mvnpdf(Z(1:nbrMeasStates), H(1:nbrMeasStates,1:nbrMeasStates)*Xpred(i).state(1:nbrMeasStates), Xhypo(i).S(1:nbrMeasStates,1:nbrMeasStates));
%                         Xhypo(i).box = Xhypo(i).state(nbrPosStates+1:nbrPosStates+2);
%                     end
%                     Xhypo(i).r = 1;
%                     Xhypo(i).label = Xpred(i).label;
%                     Xhypo(i).nbrMeasAss = Xpred(i).nbrMeasAss+1; % TAGass
% %                     iInd = iInd + 1;
% %                     jInd = jInd + 1;
% %                 else
% %                     zInd = max(1,zInd - 1);
% %                 end
% %                 zInd = zInd + 1;
%             end
%         %end
%     %end
% end
                %Xhypo{j,z}(i).w = Xpred{j}(i).w + log(Xpred{j}(i).r*Pd) + log_mvnpdf(Z(1:2,z), H*Xhypo{j,z}(i).state, Xhypo{j,z}(i).S);
                %[Xhypo{j,z}(i).w Xhypo{j,end}(i).w log_mvnpdf(Z(1:2,z), H*Xhypo{j,z}(i).state, Xhypo{j,z}(i).S)]
                %[Xhypo{j,z}(i).w Xhypo{j,end}(i).w log_mvnpdf(Z(1:2,z), H*Xpred{j}(i).state, Xhypo{j,z}(i).S)]
                %Xpred{j}(i).label
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
%                 if isnan(Xhypo{j,z}(i).w)
%                    keyboard
%                 end