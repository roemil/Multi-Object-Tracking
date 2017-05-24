function davg = colorcomp(red1, green1, blue1, red2, green2, blue2)

dred = chisdist(red1,red2);
dgreen = chisdist(green1,green2);
dblue = chisdist(blue1,blue2);
davg = mean([dred, dgreen, dblue]);
% if(davg < 10)
%     davg = 1;
% else
%     davg = 0.3;
% end
% 
% end