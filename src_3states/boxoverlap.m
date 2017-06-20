function ol = boxoverlap(a,b,mode)
% if(strcmp(mode,'CNN'))
%     x1a = max(0,a(1)-a(4)*0.5);
%     y1a = max(0,a(2)-a(5)*0.5);
%     x2a = max(0,x1a + a(4));
%     y2a = max(0,y1a + a(5));
%     x1b = max(0,b(1)-b(4)*0.5);
%     y1b = max(0,b(2)-b(5)*0.5);
%     x2b = max(0,x1b + b(4));
%     y2b = max(0,y1b + b(5));
% else
%     x1a = max(0,a(1)-a(4)*0.5);
%     y1a = max(0,a(2)-a(5)*0.5);
%     x2a = max(0,x1a + a(4));
%     y2a = max(0,y1a + a(5));
%     x1b = max(0,b(1)-b(7)*0.5);
%     y1b = max(0,b(2)-b(8)*0.5);
%     x2b = max(0,x1b + b(7));
%     y2b = max(0,y1b + b(8));
% end
% x1 = max(x1a,x1b);
% y1 = max(y1a,y1b);
% x2 = min(x2a,x2b);
% y2 = min(y2a,y2b);
% 
% w = x2-x1;
% h = y2-y1;
% 
% if w<=0 || h<=0
%     ol = 0; 
% else
% inter = w*h;
% aarea = (x2a-x1a)*(y2a-y1a);
% barea = (x2b-x1b)*(y2b-y1b);
% % intersection over union overlap
% ol = inter / (aarea+barea-inter);
ol = sqrt((a(1)-b(1)).^2+(a(2)-b(2)).^2);
end