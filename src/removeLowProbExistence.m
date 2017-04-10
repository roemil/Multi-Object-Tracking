function Xupd = removeLowProbExistence(Xtmp2,threshold,wSum, k)

    for j = 1:size(Xtmp2,2)
        iInd = 1;
        for i = 1:size(Xtmp2{k,j},2)
            if Xtmp2{k,j}(i).r > threshold
                Xupd{k,j}(iInd) = Xtmp2{k,j}(i);
                Xupd{k,j}(iInd).w = Xtmp2{k,j}(i).w/wSum(j);
                iInd = iInd+1;
            end
        end
    end
end