%   Function to predict detected targets with Kalman.
%   Input: Last updated posterior, Motion model F, Motion noise Q,
%   Probability of Survival Ps, time k
%   
%   Output: Predicted states
%
%
%
%
function Xpred = predictDetectedBernoulli(XupdPrev, F, Q, Ps, egoPos,fr1,fr2)
    %egoMotion = [0;0;egoPos*155;0;0;0];
    %egoMotion = zeros(6,1);
    if(isempty(XupdPrev))
        Xpred = [];
    else
        % TODO: Temporary to solve initiate problems with velocity
        %vSize = 10;
        %vGuess = [vSize -vSize vSize -vSize;
        %    vSize vSize -vSize -vSize];
%         vGuess = [57; -2];
%         for j = 1:size(XupdPrev,2)
%             for i = 1:size(XupdPrev{j},2)
%                 if sum([XupdPrev{j}(i).state(3) XupdPrev{j}(i).state(4)]) == 0
%                     disp('0 velo')
%                     for ii = 1:1 % Add new velo hypotheses
%                         XupdPrev{j}(end+1) = XupdPrev{j}(i);
%                         XupdPrev{j}(end).state(3:4) = vGuess(:,ii);
%                     end
%                 end
%             end
%         end
        for j = 1:size(XupdPrev,2)
            for i = 1:size(XupdPrev{j},2)
                %[Fnew, Qnew] = updateMotionModel(F,Q,XupdPrev{j}(i));
                % Bernoulli
                %XupdPrev{j}(i).state = XupdPrev{j}(i).state - egoMotion;
                Xpred{j}(i).w = XupdPrev{j}(i).w;      % Pred weight
                %XupdPrev{j}(i).state(3:4) = calcOptFlow(XupdPrev{j}(i).state(1:2),fr1,fr2,20);
                [Xpred{j}(i).state, Xpred{j}(i).P] = KFPred(XupdPrev{j}(i).state, F, XupdPrev{j}(i).P ,Q);    % Pred state
                %Xpred{j}(i).state(3:4) = calcOptFlow(XupdPrev{j}(i).state(1:2),fr1,fr2,XupdPrev{j}(i).box);
                Xpred{j}(i).r = Ps*XupdPrev{j}(i).r;   % Pred prob. of existence
                Xpred{j}(i).box = XupdPrev{j}(i).box;
                Xpred{j}(i).label = XupdPrev{j}(i).label;
                Xpred{j}(i).nbrMeasAss = XupdPrev{j}(i).nbrMeasAss; % TAGass
            end
        end
    end
end