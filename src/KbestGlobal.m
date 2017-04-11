function ass = KbestGlobal(nbrOfMeas, Xhypo, Z, Xpred, Wnew, Nh, S, Pd, H, j, maxKperGlobal)

wHyp = 1;
wHypSum = 0;
Wold = zeros(nbrOfMeas,size(Xhypo{j},2));
for m = 1 : nbrOfMeas
    for nj = 1 : size(Xhypo{j},2)
        % Normalize weights for cost matrix
        Wold(m,nj) = Xhypo{j,m}(nj).w*Xhypo{j,m}(nj).r*Pd*mvnpdf(Z(:,m)...
            ,H*Xpred{j}(nj).state,Xhypo{j,m}(nj).S)...
            /(Xhypo{j,m}(nj).w*(1-Xhypo{j,m}(nj).r+Xhypo{j,m}(nj).r*(1-Pd))); 
        Wold(m,nj) = Xhypo{j,m}(nj).w; 
        wHyp = wHyp * Xpred{j}(nj).w;
        wHypSum = wHypSum + Xpred{j}(nj).w;
    end
end
if(wHypSum == 0)
    wHypSum = 1;
end
wHyp = wHyp / wHypSum; % shall I normalize?
if sum(sum(Wold)) ~= 0
    C = -[log(Wold), log(Wnew)];
else
    C = -log(Wnew);
end

[rows,cols] = find(C == inf);
if ~isempty(rows)
    for i = 1 : size(rows,1)
        C(rows(i),cols(i)) = 1e20;
    end
end

K_hyp = max(1,ceil(Nh * wHyp));

trace_vec = zeros(1,size(S,3));
for jnew = 1:size(S,3)
    trace_vec(jnew) = trace(S(:,:,jnew)'*C);
end

minTmp = min(size(trace_vec,2), maxKperGlobal);

[ass, ~] = murty(trace_vec,min(minTmp,K_hyp));
ind = find(ass==0);
if ~isempty(ind)
    ass = ass(1:ind-1);
end