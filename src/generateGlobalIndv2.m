function [S, Amat] = generateGlobalIndv2(m, nbrOldTargets)
disp(['Nbr of meas: ', num2str(m)])
disp(['Nbr of old targets: ', num2str(nbrOldTargets)])

vec = [1:nbrOldTargets, (nbrOldTargets+1)*ones(1,m)];
t1 = nchoosek(vec, m);
t2 = unique(t1,'rows');

oldTargets = 1:nbrOldTargets;

AmatLength = zeros(size(t2,1),1);
for i = 1:size(t2,1)
    nbrTargets = sum(ismember(oldTargets,t2(i,:)));
    % TODO: Could use factorial(n)/factorial(k) instead, however it is
    % already fast
    AmatLength(i) = nchoosek(m,nbrTargets)*factorial(nbrTargets);
end
indices = cumsum(AmatLength);

nbrHypo = sum(AmatLength);
Amat = zeros(nbrHypo,m);
oldInd = [1; indices(1:end-1)+1];
for i = 1:size(t2,1)
    tmp2 = uniqperm(t2(i,:));
    [~, cols] = find(tmp2 == (nbrOldTargets+1));
    ind = find(tmp2 == (nbrOldTargets+1));
    if ~isempty(cols)
        tmp2(ind) = cols+nbrOldTargets;
    end
    Amat(oldInd(i):indices(i),:) = tmp2;
end

S = zeros(m, m+nbrOldTargets, nbrHypo);
measVec = (1:m)';
AmatSize = size(Amat);

%indNbr = reshape(1:prod(AmatSize),m,nbrHypo)';
indNbr = reshape(1:numel(Amat),nbrHypo,m)'; % Numel faster?

indVec = sub2ind(size(S(:,:,1)),repmat(measVec,1,nbrHypo),Amat(indNbr));
nbrElementsS = m*(m+nbrOldTargets);
addVec = 1:nbrHypo-1;
indVec = [indVec(:,1), nbrElementsS*addVec+indVec(:,2:end)];

S(indVec) = 1;

