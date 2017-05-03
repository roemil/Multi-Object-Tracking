function count = checkWithinFOVsize(X,FOVsize,H3dFunc)
countX = 0;
countY = 0;
if isstruct(X)
    for i = 1:size(X,2)
        Xpix = H3dFunc(X(i).state);
        if ((Xpix(1) < FOVsize(1,1)) || (Xpix(2) > FOVsize(2,1)))
            countX = countX+1;
        elseif ((Xpix(2) < FOVsize(1,2)) || (Xpix(2) > FOVsize(2,2)))
            countY = countY+1;
        end
    end
end
count = [countX, countY];