function ass = KbestGlobal(nbrOfMeas, Xhypo, Z, Xpred, Wnew, Nh, S, Pd, H, j, maxKperGlobal)

wHyp = 1;
wHypSum = 0;
Wold = zeros(nbrOfMeas,size(Xhypo{j},2));
whypo = zeros(nbrOfMeas,size(Xhypo{j},2));
for m = 1 : nbrOfMeas
    for nj = 1 : size(Xhypo{j},2)
        % Normalize weights for cost matrix
        %Wold(m,nj) = Xhypo{j,m}(nj).w*Xhypo{j,m}(nj).r*Pd*mvnpdf(Z(:,m)...
        %    ,H*Xpred{j}(nj).state,Xhypo{j,m}(nj).S)...
        %    /(Xhypo{j,m}(nj).w*(1-Xhypo{j,m}(nj).r+Xhypo{j,m}(nj).r*(1-Pd)));  % TODO: IS THIS CORRECT??
        %Wold(m,nj) = min(1,Xhypo{j,m}(nj).w); % TODO: This is not proper
        %Wold(m,nj) = min(1,Xhypo{j,m}(nj).w/Xhypo{j,end}(nj).w); % TODO: SHOULDNT IT BE LIKE THIS?
        %[Xhypo{j,m}(nj).w Xhypo{j,end}(nj).w]
        Wold(m,nj) = Xhypo{j,m}(nj).w - Xhypo{j,end}(nj).w;
        wHyp = wHyp + Xpred{j}(nj).w;
        %wHypSum = wHypSum + Xpred{j}(nj).w;
        %whypo(m,nj) = Xhypo{j,m}(nj).w;
    end
end

%if(wHypSum == 0)
%    wHypSum = 1;
%end
if ~isempty(Xhypo{j})
    [~, wHypSum] = normalizeLogWeights(Wold);
    wHyp = exp(wHyp - wHypSum); % shall I normalize?
    C = -[Wold, log(Wnew)];
else
    C = -log(Wnew);
end

[rows,cols] = find(C == inf);
if ~isempty(rows)
    for i = 1 : size(rows,1)
        C(rows(i),cols(i)) = 1e20;
    end
end

% TODO: max(2, ...)?? 
K_hyp = max(1,ceil(Nh * wHyp));

% trace_vec = zeros(1,size(S,3));
% for jnew = 1:size(S,3)
%     trace_vec(jnew) = trace(S(:,:,jnew)'*C);
% end
ind = find(sum(sum(S,2),1) ~= 0);
%bfTrace = permute(S,[2 1 3]); %For each index in 3D, Transpose S 
bfTracesTimesC = mtimesx(S(:,:,ind),'T',C); %For each index in 3D, multiply with C
%d = trace((bfTracesTimesC));
% Calculate trace of matrix bfTracesTimesC for each index in 3D
d=bfTracesTimesC(bsxfun(@plus,(0:size(bfTracesTimesC,3)-1)*size(bfTracesTimesC,1)*size(bfTracesTimesC,2),(1:size(bfTracesTimesC,2)+1:size(bfTracesTimesC,1)*size(bfTracesTimesC,2)).'));
[rowNaN, colNaN] = find(isnan(d));
d(rowNaN, colNaN) = 0;
d = sum(d,1);
minTmp = min(size(S,3), maxKperGlobal);
[ass, cost] = murty(d,min(minTmp,K_hyp));
ind = find(ass==0);
if ~isempty(ind)
    ass = ass(1:ind-1);
end
