function [err] = eval3DCNNsingleTime2(X,X3,Y,Y3,k,mode,c_thresh,GTdc, XtCamCoords)
global H, global angles, global pose
fp = 0;
fn = 0;
count_dontcare = 0;
loc_err = 0;
threshAss = 0.5;
threshDC = 0.5;

err = zeros(2,1);

% if~(strcmp(mode,'CNN'))
%     tmp = Y;
%     Y = zeros(5,size(Y,2));
%     for i = 1 : size(tmp,2)
%         Y(:,i) = [H(tmp{i},pose{k}(1:3,4), angles{k}.heading-angles{1}.heading); tmp{i}(7:8)];
%     end
% end

if(isempty(X))
    return;
end
xL = size(X,2); % GT
yL = size(Y,2); % Estimated trajectories

%c_thresh = 10;%50;
min_overlap = 1e9;%0.5;
c = 0;
C = [];
count_ctresh = 0;

nbrAss = 0;
if(xL > yL) % nonnegative symmetry
    tmp = X;
    X = Y;
    Y = tmp;
    tmp3 = X3;
    X3 = Y3;
    Y3 = tmp3;
    tmp = xL;
    xL = yL;
    yL = tmp;
    ol = zeros(1,xL);
    max_cost = 1e9;
    %min_overlap = 50;
    % cost matrix
    xL = size(X,2); % Estimated trajectories
    yL = size(Y,2); % GT
    for i = 1 : xL
        for j = 1 : yL
            %C(i,j) =  boxoverlap(Y(:,j),X(:,i),mode); % if ol = 1 then c = 0
            [~, C(i,j)] = isinside2(X(:,i), Y(:,j), threshAss, 'dontcare');
        end
    end
    assignment = murty(C,1);
    lAss = length(assignment);
    d = 0;
    alpha = 2;
    p = 2;
    ind = 1;
    for i = 1 : xL
        distance = (min(c_thresh, norm(Y3(1:3,assignment(i))-X3(1:3,i)))).^p;
        if distance ~= c_thresh^p
            err(1:2,ind) = [distance; sqrt(XtCamCoords(1,i)^2+XtCamCoords(2,i)^2+XtCamCoords(3,i)^2)];%sqrt(GT{i}(1)^2+GT{i}(2)^2+GT{i}(3)^2)];
            loc_err = loc_err+distance^(1/p);
            d =d + distance;
            nbrAss = nbrAss+1;
            ind = ind+1;
        end
        %d =d + distance;
    end
else
    ol = zeros(1,xL);
    max_cost = 1e9;
    %min_overlap = 0.5;
    % cost matrix
    xL = size(X,2); % GT
    yL = size(Y,2); % Estimated trajectories
    for i = 1 : xL
        for j = 1 : yL
            %C(i,j) =  boxoverlap(Y(:,j),X(:,i),mode); % if ol = 1 then c = 0
            [~, C(i,j)] = isinside2(Y(:,j), X(:,i), threshAss, 'dontcare');
        end
    end
    assignment = murty(C,1);
    lAss = length(assignment);
    d = 0;
    alpha = 2;
    p = 2;
    ind = 1;
    for i = 1 : xL
        %distance = (min(c_thresh,sqrt((X(1,i)-Y(1,assignment(i))).^2+(X(2,i)-Y(2,assignment(i))).^2))).^p;
        distance = (min(c_thresh,norm(Y3(1:3,assignment(i))-X3(1:3,i)))).^p;
        if distance ~= c_thresh^p
            err(1:2,ind) = [distance; sqrt(XtCamCoords(1,i)^2+XtCamCoords(2,i)^2+XtCamCoords(3,i)^2)];
            loc_err = loc_err+distance^(1/p);
            d =d + distance;
            nbrAss = nbrAss+1;
            ind = ind+1;
        end
%         d =d + distance;
    end
end

% if count_dontcare ~= 0
%     [k, count_dontcare]
% end
    


    