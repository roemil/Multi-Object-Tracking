function XuUpd = updatePoisson(XmuPred,k,Pd)    
    for i = 1:size(XmuPred{k},2)    
        % Update undetected targets (Poisson component)
        XuUpd{k}(i).w = (1-Pd)*XmuPred{k}(i).w;
        XuUpd{k}(i).state = XmuPred{k}(i).state;
        XuUpd{k}(i).P = XmuPred{k}(i).P;
    end
end