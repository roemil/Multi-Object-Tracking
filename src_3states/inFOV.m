function withinFOV = inFOV(X)
global H, global pose, global angles, global k

%global FOVsize
%FOVsize = [-40,-10;1242+10,375]; 
FOVsize = [0,0;1242,375]; 

tmp = H(X,pose{k}(1:3,4), angles{k}.heading-angles{1}.heading);
withinFOV = true;

if tmp(1) < FOVsize(1,1) || tmp(1) > FOVsize(2,1) || ...
        tmp(2) < FOVsize(1,2) || tmp(2) > FOVsize(2,2)
    withinFOV = false;
end