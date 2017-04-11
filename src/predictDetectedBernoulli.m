%   Function to predict detected targets with Kalman.
%   Input: Last updated posterior, Motion model F, Motion noise Q,
%   Probability of Survival Ps, time k
%   
%   Output: Predicted states
%
%
%
%
function Xpred = predictDetectedBernoulli(XupdPrev, F, Q, Ps)    
    if(isempty(XupdPrev))
        Xpred = [];
    else
        for j = 1:size(XupdPrev,2)
            for i = 1:size(XupdPrev{j},2)
                % Bernoulli
                Xpred{j}(i).w = XupdPrev{j}(i).w;      % Pred weight
                [Xpred{j}(i).state, Xpred{j}(i).P] = KFPred(XupdPrev{j}(i).state, F, XupdPrev{j}(i).P ,Q);    % Pred state
                Xpred{j}(i).r = Ps*XupdPrev{j}(i).r;   % Pred prob. of existence
            end
        end
    end
end