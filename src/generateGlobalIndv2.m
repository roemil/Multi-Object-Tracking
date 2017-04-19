function [S, Amat] = generateGlobalIndv2(m, nbrOldTargets)

vec = [1:nbrOldTargets, (nbrOldTargets+1)*ones(1,m)];
t1 = nchoosek(vec, m);
t2 = unique(t1,'rows');

Amat = [];
for i = 1:size(t2,1)
    tmp1 = perms(t2(i,:));
    tmp2 = unique(tmp1,'rows');
    [~, cols] = find(tmp2 == (nbrOldTargets+1));
    ind = find(tmp2 == (nbrOldTargets+1));
    if ~isempty(cols)
        tmp2(ind) = cols+nbrOldTargets;
        %tmp2(sub2ind(size(tmp2),rows,cols)) = cols+nbrOldTargets;
        %for j = 1:max(size(rows,1),size(rows,2))
        %    tmp2(rows(j),cols(j)) = cols(j)+nbrOldTargets;
        %end
    end
    Amat = [Amat; tmp2];
end

nbrHypo = size(Amat,1);
S = zeros(m, m+nbrOldTargets, nbrHypo);
for i = 1:nbrHypo
    for z = 1:m
        S(z, Amat(i,z), i) = 1;
    end
end

% indOld = 1;
% nbrHypo = size(Amat2,1);
% indVec = zeros(nbrHypo,m);
% for i = 1:m
%     indNew = indOld+1;
%     indVec(:,i) = sub2ind([m, m+nbrOldTargets],i*ones(nbrHypo,1),Amat2(:,i));
%     indOld = indNew+1;
% end 
% 
% S = zeros(m, m+nbrOldTargets, nbrHypo);
% S(indVec,:) = 1;

% Atest = [ones(7,1),Amat2(:,1), 2*ones(7,1),Amat2(:,2)];
% sub2ind([2, 4],[Atest(:,1) Atest(:,3)], [Atest(:,2), Atest(:,4)]);
