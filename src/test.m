function A = test()
A = cell(1);
m = 4;
nbrOldTargets = 2;
indexVec = 1:nbrOldTargets+m;
const1 = 0;
for i = 0:nbrOldTargets-1
    A{i+1} = zeros(2^m,m);
    for z = 1:nbrOldTargets
        const2 = const1+z;
        if const2>nbrOldTargets
            const2 = abs(nbrOldTargets-const2);
        end
        old = repmat(const2,2^(z-1),1);
        new = repmat(z+nbrOldTargets,2^(z-1),1);
        A{i+1}(:,z) = repmat([old; new],2^m/2^(z),1);
    end
    while z+nbrOldTargets < max(indexVec)
        z = z+1;
        A{i+1}(:,z) = 2*m;
    end
    const1 = const1+1;
    if const1>nbrOldTargets
        const1 = 1;
    end
end