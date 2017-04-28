function XuUpd = updatePoisson(XmuPred,Pd)    
    for i = 1:size(XmuPred,2)    
        % Update undetected targets (Poisson component)
        XuUpd(i).w = (1-Pd)*XmuPred(i).w;
        XuUpd(i).state = XmuPred(i).state;
        XuUpd(i).P = XmuPred(i).P;
    end
end