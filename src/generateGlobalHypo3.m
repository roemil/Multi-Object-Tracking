function [newGlob, newInd] = generateGlobalHypo3(Xhypo, Xnew, Z, oldInd)

m = size(Z,2);

indexVec = 1:2*m;
for i = 1:2*m
    if i <= m
        Xtmp{i} = Xhypo{i};
    else
        Xtmp{i} = Xnew{i-m};
    end
end

%A = zeros(2^m,m);
%for z = 1:m
%    old = repmat(z,2^(z-1),1);
%    new = repmat(z+m,2^(z-1),1);
%    A(:,z) = repmat([old; new],2^m/2^(z),1);
%end

nbrOldTargets = size(Xhypo{1,1,1},2);
A = cell(1);

const1 = 0;
for i = 0:nbrOldTargets-1
    A{i+1} = zeros(2^m,m);
    for z = 1:m
        const2 = const1+z;
        if const2>nbrOldTargets
            const2 = abs(nbrOldTargets-const2);
        end
        old = repmat(const2,2^(z-1),1);
        new = repmat(z+m,2^(z-1),1);
        A{i+1}(:,z) = repmat([old; new],2^m/2^(z),1);
    end
    const1 = const1+1;
    if const1>nbrOldTargets
        const1 = 1;
    end
end

% minSum = sum((m+2):2*m)+1;
% iInd = 1;
% for i = 1:2^m
%     if sum(Atmp(i,:)) >= minSum
%         A(iInd,:) = Atmp(i,:);
%         iInd = iInd+1;
%     end
% end

iInd = 1;
for j = 1:2^m
    for z = 1:m
        newGlob{j}(iInd) = Xtmp{z}(A(j,z));
    end
end

% for j = 1:nbrOldTargets*2^m
%     for i = 1:nbrOldTargets
%         for z = 1:m
%             if z == 1
%                 old = repmat(Xhypo{z}(i),2^(z-1),[]);


newInd = oldInd+jInd-1;