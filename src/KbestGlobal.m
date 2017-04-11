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

% trace_vec = zeros(1,size(S,3));
% for jnew = 1:size(S,3)
%     trace_vec(jnew) = trace(S(:,:,jnew)'*C);
% end

bfTrace = permute(S,[2 1 3]); %For each index in 3D, Transpose S 
bfTracesTimesC = mtimesx(bfTrace,C); %For each index in 3D, multiply with C
% Calculate trace of matrix bfTracesTimesC for each index in 3D
d=bfTracesTimesC(bsxfun(@plus,(0:size(bfTracesTimesC,3)-1)*size(S,1)*size(S,2),(1:size(S,2):size(S,1)*size(S,2)).'));
minTmp = min(size(bfTrace,2), maxKperGlobal);

[ass, ~] = murty(d,min(minTmp,K_hyp));
ind = find(ass==0);
if ~isempty(ind)
    ass = ass(1:ind-1);
end