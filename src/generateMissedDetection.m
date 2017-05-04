function Xmiss = generateMissedDetection(Xpred, Pd)
    for i = 1:size(Xpred,2)
        Xmiss(i).w = Xpred(i).w + log(1-Xpred(i).r+Xpred(i).r*(1-Pd));
        Xmiss(i).r = Xpred(i).r*(1-Pd)/(1-Xpred(i).r+Xpred(i).r*(1-Pd));
        Xmiss(i).state = Xpred(i).state;
        Xmiss(i).P = Xpred(i).P;
        Xmiss(i).box = Xpred(i).box;
        Xmiss(i).label = Xpred(i).label;
        Xmiss(i).S = 0;
        Xmiss(i).nbrMeasAss = Xpred(i).nbrMeasAss; % TAGass
    end
end