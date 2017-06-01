function [Xhypo] = generateTargetHypov3(Xpred,nbrOfMeas,nbrOfGlobHyp, Pd, H, R, Z, motionModel, nbrPosStates, nbrMeasStates)
 global Pd, global R, global nbrMeasStates, global H3dTo2d, global H3dFunc, ...
 global Hdistance, global R3dTo2d, global Rdistance, global H, global R,
 global pose, global k, global plotHypoConf, global angles, global imgpath,...
 global color, global rescaleFact

% Create missdetection hypo in index size(Z{k},2)+1
if(isempty(Xpred)) % If we have no predicted targets, we cannot 
                      % generate hypotheses
    Xhypo{1} = [];
    return;
end

if(color)
    framenbr = sprintf('%06d',k-1);
    img = imread([imgpath,framenbr,'.png']);
end
Xhypo{1,1} = initiateStruct(color); 
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
        Xhypo{j,nbrOfMeas+1}(i).class = NaN;
        if color
            Xhypo{j,nbrOfMeas+1}(i).red = Xpred{j}(i).red;
            Xhypo{j,nbrOfMeas+1}(i).green = Xpred{j}(i).green;
            Xhypo{j,nbrOfMeas+1}(i).blue = Xpred{j}(i).blue;
        end
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
            if strcmp(motionModel,'cvBB')
                % Bounding box center
                [Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Xhypo{j,z}(i).S(1:nbrMeasStates,1:nbrMeasStates), v]...
                    = UKFupdate(Xpred{j}(i).state,Xpred{j}(i).P, H, Z(1:nbrMeasStates,z), R, 6);
            end
            % Enable if gating
            % Check within threshold
            %if(gatingv2(v,Xhypo{j,z}(i).S(1:nbrMeasStates,1:nbrMeasStates),70)) % 100
            % Check within 3sigma
            if(gatingv3(v,Xhypo{j,z}(i).S(1:nbrMeasStates,1:nbrMeasStates))) % 100
                if strcmp(motionModel,'cvBB')
                    % Bound box size
                    [Xhypo{j,z}(i).state, Xhypo{j,z}(i).P, Xhypo{j,z}(i).S(nbrMeasStates+1:5,nbrMeasStates+1:5)] = ...
                        KFUpd(Xhypo{j,z}(i).state, H3dTo2d(nbrMeasStates+1:end,1:end-1), Xhypo{j,z}(i).P, R3dTo2d(nbrMeasStates+1:end,nbrMeasStates+1:end), Z(4:5,z));

                    % Only yaw
                    Xhypo{j,z}(i).w = Xpred{j}(i).w + log(Xpred{j}(i).r*Pd) + ...
                        log_mvnpdf(Z(1:nbrMeasStates,z), H(Xpred{j}(i).state,pose{k}(1:3,4),angles{k}.heading-angles{1}.heading), Xhypo{j,z}(i).S(1:nbrMeasStates,1:nbrMeasStates));
                    if(color)
                        rescaleFact = 0.6;
                        Zbox = [Z(1,z) - rescaleFact*Z(nbrMeasStates+1,z)*0.5, Z(2,z)-rescaleFact*Z(nbrMeasStates+2,z)*0.5,...
                            rescaleFact*Z(nbrMeasStates+1,z),rescaleFact*Z(nbrMeasStates+2,z)]; % Corners of Z box
                        [ZRed, ZGreen, ZBlue] = colorhist(img,Zbox);
                        %log(colorcomp(ZRed,ZGreen,ZBlue,Xpred{j}(i).red,Xpred{j}(i).green,Xpred{j}(i).blue))
                        %Xhypo{j,z}(i).w
                        %waitforbuttonpress
                        Xhypo{j,z}(i).w = Xhypo{j,z}(i).w - log(colorcomp(ZRed,ZGreen,ZBlue,Xpred{j}(i).red,Xpred{j}(i).green,Xpred{j}(i).blue));
                        Xhypo{j,z}(i).red = ZRed;
                        Xhypo{j,z}(i).green = ZGreen;
                        Xhypo{j,z}(i).blue = ZBlue;
                    end
                end
                Xhypo{j,z}(i).r = 1;
                Xhypo{j,z}(i).label = Xpred{j}(i).label;
                Xhypo{j,z}(i).nbrMeasAss = Xpred{j}(i).nbrMeasAss+1; % TAGass
                Xhypo{j,z}(i).box = Xhypo{j,z}(i).state(7:8);
                Xhypo{j,z}(i).class = Z(end,z);
                %Stmp{z,j}(ind,1:nbrMeasObj) = 0;
                %Stmp{z,j}(ind,i) = 1;
                ind = ind+1;
           else % Enable if gating
               Xhypo{j,z}(i).state = [];%ones(size(Xpred{1}(1).state));
               Xhypo{j,z}(i).P = 0; %eye(size(Xpred{1}(1).P));
               Xhypo{j,z}(i).S = 0; %eye(size(Xpred{1}(1).P));
               Xhypo{j,z}(i).w = -1000;
               Xhypo{j,z}(i).box = [313;313];
               Xhypo{j,z}(i).r = 0; %TODO: should this really be 1??
               Xhypo{j,z}(i).label = 313313;
               Xhypo{j,z}(i).nbrMeasAss = 0; % TAGass
               Xhypo{j,z}(i).class = NaN;
               if color
                   Xhypo{j,z}(i).red = 0;
                   Xhypo{j,z}(i).green = 0;
                   Xhypo{j,z}(i).blue = 0;
               end
            end % Enable if gating
            
        end
        %Stmp{z,j}(end+1,1:nbrMeasObj) = 0;
        %Stmp{z,j}(end,size(Xpred{j},2)+z) = 1;
    end
end

% S = zeros(nbrOfMeas,nbrOfMeas+size(Xpred{1},2),1,nbrOfGlobHyp);
% indvInd = zeros(nbrOfMeas,2);
% for j = 1:nbrOfGlobHyp
%     for z = 1:nbrOfMeas
%         indvInd(z,:) = [1, size(Stmp{z,j},1)];
%     end
%     ind = 1;
%     nbrObj = size(Xhypo{j,1},2);
%     while indvInd(1,1) <= indvInd(1,2)
%         for z = 1:size(Stmp,1)
%             S(z,1:(nbrObj+nbrOfMeas),ind,j) = Stmp{z,j}(indvInd(z,1),:);
%         end
%         indvInd(nbrOfMeas,1) = indvInd(nbrOfMeas,1)+1;
%         for indI = nbrOfMeas:-1:2
%             if indvInd(indI,1) > indvInd(indI,2)
%                 indvInd(indI,1) = 1;
%                 indvInd(indI-1,1) = indvInd(indI-1,1)+1;
%             end
%         end
%         %sumCol = sum(S(:,:,ind,j));
%         if sum(sum(S(:,:,ind,j))) == 0
%             keyboard
%         end
%         if isempty(find(sum(S(:,:,ind,j)) > 1,1))
%             ind = ind+1;
%         end
%     end
% end

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