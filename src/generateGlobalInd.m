% Function to find all valid combinations of old potential targets and
% newly detected potential targets
% 
% Input:    m:              Number of measurements
%           nbrOldTargets   Number of old potential targets
%
% Output:   A:              Indeces for all combinations of targets
%
%

function [A, S, Amat] = generateGlobalInd(m,nbrOldTargets)

%
if nbrOldTargets >= m
    targets = 1:nbrOldTargets;
    combs = nchoosek(targets,m);
    pm = [];
    for i = 1:size(combs,1)
        pm = [pm; perms(combs(i,:))];
    end
else
    pm = 1:nbrOldTargets;
end

if nbrOldTargets >= m
    for i = 1:size(pm,1)
        A{i} = zeros(2^m,m);
        for z = 1:m
            old = repmat(pm(i,z),2^(z-1),1);
            new = repmat(z+nbrOldTargets,2^(z-1),1);
            A{i}(:,z) = repmat([old; new],2^m/2^(z),1);
        end
    end
else
    Amat = zeros(1,m,2^nbrOldTargets);
    A{1} = zeros(2^nbrOldTargets,m);
    for z = 1:nbrOldTargets
        old = repmat(pm(1,z),2^(z-1),1);
        new = repmat(z+nbrOldTargets,2^(z-1),1);
        Amat(1,z,:) = reshape(repmat([old; new],2^nbrOldTargets/2^(z),1), 1, 1, []);
        A{1}(:,z) = repmat([old; new],2^nbrOldTargets/2^(z),1);
    end
    for z = nbrOldTargets+1:m
        A{1}(:,z) = z+nbrOldTargets;
        Amat(1,z,:) = z+nbrOldTargets;
    end
end

for i = 1:size(A,2)
    A{i} = A{i}(1:end-1,:);
    Amat = Amat(1,:,1:end-1);
end

if nbrOldTargets < m
    Atmp = A{1};
    AmatTmp = Amat;
    idx = perms(1:size(Atmp,2));
    idxmat = perms(1:size(AmatTmp,2));
    ind = 1;
    clear A
    clear Amat
    for ii = idx'
        A{ind} = Atmp(:,ii);
        for z = 1:m
            for row = 1:size(A{ind},1)
                if ((A{ind}(row,z) > nbrOldTargets) && (A{ind}(row,z) ~= z+nbrOldTargets))
                    A{ind}(row,z) = z+nbrOldTargets;
                end
            end
        end
        ind = ind+1;
    end
    ind = 1;
    for ii = idxmat'
        indNew = ind+size(Atmp(:,ii),1)-1;
        %Amat(1,:,ind:indNew) = fliplr(reshape(Atmp(:,ii), 1, m, size(Atmp(:,ii),1)));
        Amat(1,:,ind:indNew) = reshape(Atmp(:,ii)', 1, m, size(Atmp(:,ii),1));
        for z = 1:m
            for row = ind:indNew
                if ((Amat(1,z,row) > nbrOldTargets) && (Amat(1,z,row) ~= z+nbrOldTargets))
                    Amat(1,z,row) = z+nbrOldTargets;
                end
            end
        end
        ind = indNew+1;
    end
end

A{end+1} = nbrOldTargets+1:nbrOldTargets+m;
Amat(1,:,end+1) = nbrOldTargets+1:nbrOldTargets+m;
ind = 1;

%%%% REMOVE THE SAME ONE
for i = 1:size(Amat,3)
    for j = i:size(Amat,3)
        if ((sum(Amat(1,:,i) == Amat(1,:,j)) == size(Amat,2)) && (i == j))
            AmatFinal(1,:,ind) = Amat(1,:,j);
            ind = ind+1;
            break
        end
    end
end

Amat2 = zeros(1,m,1);
S = zeros(m, nbrOldTargets+m,1);
ind = 1;
for i = 1:size(A,2)
    for row = 1:size(A{i},1)
        S(:,:,ind) = zeros(m, nbrOldTargets+m);
        for col = 1:m
            S(col, A{i}(row,col),ind) = 1;
        end
        Amat2(1,:,ind) = A{i}(row,:);
        ind = ind+1;
    end
end
keyboard