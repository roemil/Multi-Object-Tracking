function A = test3(m,nbrOldTargets)
% MOST RECENT
A = cell(1);

tmp = nbrOldTargets;
indexVec = 1:nbrOldTargets+m;
const1 = 0;

for i = 0:nbrOldTargets-1
    A{i+1} = zeros(2^m,m);
    for z = 1:m %nbrOldTargets
        const2 = const1+z;
        if const2>nbrOldTargets
            const2 = abs(nbrOldTargets-const2);
        end
        old = repmat(const2,2^(z-1),1);
        new = repmat(z+nbrOldTargets,2^(z-1),1);
        A{i+1}(:,z) = repmat([old; new],2^m/2^(z),1);
    end
    while tmp < m
        tmp = tmp+1;
        A{i+1}(:,tmp) = tmp+nbrOldTargets;
    end
    const1 = const1+1;
    if const1>nbrOldTargets
        const1 = 1;
    end
end

for i = 1:nbrOldTargets
    A{i} = A{i}(1:end-1,:);
end

if nbrOldTargets < m
    A{1} = A{1}(1:2^nbrOldTargets,:);
    Atmp = A{1}(1:end-1,:);
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
% elseif nbrOldTargets > m
%     for i = 1:size(A,2)
%         for z = 1:m
%             for row = 1:size(A{i},1)
%                 if ((A{i}(row,z) <= nbrOldTargets) && ())
end
