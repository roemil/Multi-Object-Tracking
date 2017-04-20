function [S, Amat] = generateGlobalIndv2(m, nbrOldTargets)
disp(['Nbr of meas: ', num2str(m)])
disp(['Nbr of old targets: ', num2str(nbrOldTargets)])

vec = [1:nbrOldTargets, (nbrOldTargets+1)*ones(1,m)];
t1 = nchoosek(vec, m);
t2 = unique(t1,'rows');

% t2length = 0;
% for i = 0:min(m,nbrOldTargets)
%     t2length = t2length + nchoosek(nbrOldTargets,i);
% end

% AmatLength = zeros(min(m,nbrOldTargets),1);
% for i = 0:min(m,nbrOldTargets)
%     AmatLength(i+1) = nchoosek(m,i)*factorial(i)*nchoosek(nbrOldTargets,i);
% end

oldTargets = 1:nbrOldTargets;

AmatLength = zeros(size(t2,1),1);
for i = 1:size(t2,1)
    nbrTargets = sum(ismember(oldTargets,t2(i,:)));
    AmatLength(i) = nchoosek(m,nbrTargets)*factorial(nbrTargets);
end
indeces = cumsum(AmatLength);

nbrHypo = sum(AmatLength);
Amat = zeros(nbrHypo,m);
oldInd = [1; indeces(1:end-1)+1];
for i = 1:size(t2,1)
    tmp2 = uniqperm(t2(i,:));
%     tmp1 = perms(t2(i,:));
%     tmp2 = unique(tmp1,'rows');
    % FOR CHECK, why perms give multiple of the same?
    %sum(ismember(tmp1,tmp2,'rows')) == size(tmp1,1);
%     if size(tmp1,1) ~= size(tmp2,1)
%         keyboard
%     end
    % FOR CHECK
    [~, cols] = find(tmp2 == (nbrOldTargets+1));
    ind = find(tmp2 == (nbrOldTargets+1));
    if ~isempty(cols)
        tmp2(ind) = cols+nbrOldTargets;
    end
    Amat(oldInd(i):indeces(i),:) = tmp2;
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

%%%%% OLD %%%%%
% for i = 1:nbrHypo
%     for z = 1:m
%        S(z, Amat(i,z), i) = 1;
%     end
% end

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
