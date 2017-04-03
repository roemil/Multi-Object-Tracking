function Xpred = predictDetectedBernoulli(Xupd, F, Q, Ps, k)    
    if(isempty(Xupd{k-1}))
        Xpred{k} = [];
    else
        for j = 1:size(Xupd{k-1},2)
            for i = 1:size(Xupd{k-1,j},2)
                % Bernoulli
                Xpred{k,j}(i).w = Xupd{k-1,j}(i).w;      % Pred weight
                [Xpred{k,j}(i).state, Xpred{k,j}(i).P] = KFPred(Xupd{k-1,j}(i).state, F, Xupd{k-1,j}(i).P ,Q);    % Pred state
                Xpred{k,j}(i).r = Ps*Xupd{k-1,j}(i).r;   % Pred prob. of existence
            end
        end
    end
end