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


pos = X(1:2)-pose{k}(1:2,4);
heading = angles{k}.heading-angles{1}.heading;
angle = 45;
d = 30;
p = [cos(heading), -sin(heading); sin(heading) cos(heading)]*d*[1 1;tand(angle), -tand(angle)];%+pose{k}(1:2,4);
if ~(sum(sign(pos) == sign(p(:,1))) == 2 || sum(sign(pos) == sign(p(:,2))) == 2)
    withinFOV = false;
end 


% if sum(sign(pos) == sign(p(:,1))) == 2
%     
% elseif sum(sign(pos) == sign(p(:,2))) == 2
%     
% else
%     withinFOV = false;
% end

% figure;
% plot([0 p(1,1)], [0 p(2,1)],'k')
% hold on
% plot([0 p(1,2)], [0 p(2,2)],'k')
% plot(pos(1),pos(2),'b*')
% disp(withinFOV)
% keyboard