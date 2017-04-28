% Function to remove components with low probability of existence
% Input:Global hypo j at time k, index of keepGlobs of hypo j, threshold
% and sum
% Output: Pruned tree
%
%%
function Xupd = removeLowProbExistence(Xtmp, keepGlobs, threshold, wSum)
    iInd = 1;
    for i = 1:size(Xtmp,2)
        if Xtmp(i).r > threshold
            Xupd(iInd) = Xtmp(i);
            Xupd(iInd).w = Xtmp(i).w/wSum(keepGlobs);
            iInd = iInd+1;
        end
    end
end