% Function to find all valid combinations of old potential targets and
% newly detected potential targets
% 
% Input:    m:              Number of measurements
%           nbrOldTargets   Number of old potential targets
%
% Output:   A:              Indeces for all combinations of targets
%
%

function [S, Amat] = generateGlobalIndTest(m,nbrOldTargets)

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
    A{1} = zeros(2^nbrOldTargets,m);
    for z = 1:nbrOldTargets
        old = repmat(pm(1,z),2^(z-1),1);
        new = repmat(z+nbrOldTargets,2^(z-1),1);
        A{1}(:,z) = repmat([old; new],2^nbrOldTargets/2^(z),1);
    end
    for z = nbrOldTargets+1:m
        A{1}(:,z) = z+nbrOldTargets;
    end
end

for i = 1:size(A,2)
    A{i} = A{i}(1:end-1,:);
end

if nbrOldTargets < m
    Atmp = A{1};
    idx = perms(1:size(Atmp,2));
    ind = 1;
    clear A
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
end

A{end+1} = nbrOldTargets+1:nbrOldTargets+m;

Atmp = [];
for i = 1:size(A,2)
    Atmp = [Atmp; A{i}];
end

Amat = unique(Atmp,'rows');

S = zeros(m, nbrOldTargets+m,1);
for j = 1:size(Amat,1)
    S(:,:,j) = zeros(m, nbrOldTargets+m);
    for z = 1:size(Amat,2)
        S(z, Amat(j,z),j) = 1;
    end
end
