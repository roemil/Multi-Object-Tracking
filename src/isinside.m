function ans = isinside(Xest,GT)
ans = 0;
a = Xest;
%thresh = 0.55; if alt1
thresh = 0.6;%0.65; % if alt2
eps = 1e-1;

x1a = max(0,a(1)-a(3)*0.5);
y1a = max(0,a(2)-a(4)*0.5);
x2a = max(0,x1a + a(3));
y2a = max(0,y1a + a(4));

for z = 1:size(GT,2)
    b = [GT(1:2,z); GT(3:4,z)];
    x1b = max(0,b(1)-b(3)*0.5);
    y1b = max(0,b(2)-b(4)*0.5);
    x2b = max(0,x1b + b(3));
    y2b = max(0,y1b + b(4));
    x1 = max(x1a,x1b);
    y1 = max(y1a,y1b);
    x2 = min(x2a,x2b);
    y2 = min(y2a,y2b);

    w = x2-x1;
    h = y2-y1;

    if w<=0 || h<=0
        ol = 0; 
    elseif abs((w*h) - (Xest(3)*Xest(4))) < eps
        ol = 1;
    elseif abs((w*h)-(b(3)*b(4))) < eps
        ol = 1;
    else
        inter = w*h;
        aarea = (x2a-x1a)*(y2a-y1a);
        barea = (x2b-x1b)*(y2b-y1b);
        % intersection over union overlap
        %ol = inter / (aarea+barea-inter); % alt1
        ol = inter/aarea;%min(aarea,barea); % alt2
    end
    
    if ol > thresh
        ans = 1;
        return
    end
end
    

%% Old, check if center is within Dont care BB
% for i = 1 : size(GT,2)
%     x1 = GT(1,i) - GT(4,i)*0.5;
%     y1 = GT(2,i) - GT(5,i)*0.5;
%     x2 = x1 + GT(4,i);
%     y2 = y1 + GT(5,i);
% 
%     if(((Xest(1) > x1) && (Xest(1) < x2)) && ((Xest(2) > y1) && (Xest(2) < y2)))% && GT(6,i) == -1)
%         ans = 1;
%         return
%     else
%         ans = 0;
%     end
% end

end