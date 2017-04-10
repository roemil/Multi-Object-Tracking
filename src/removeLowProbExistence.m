function Xupd = removeLowProbExistence(Xtmp, keepGlobs, threshold, wSum, k, j)

    %for j = 1:size(keepGlobs,1)
        iInd = 1;
        for i = 1:size(Xtmp,2)
            if Xtmp(i).r > threshold
                Xupd(iInd) = Xtmp(i);
                Xupd(iInd).w = Xtmp(i).w/wSum(keepGlobs(j));
                iInd = iInd+1;
            end
        end
    %end
end