function [d, fp, fn, loc_err, car_err] = GOSPA2(X,Y,k,mode,c_thresh,GTdc)
global H, global angles, global pose
fp = 0;
fn = 0;
count_dontcare = 0;
loc_err = 0;
nbrAss = 0;

threshAss = 0.5;
threshDC = 0.5;

if(iscell(X))
    X = cell2mat(X);
end
if(iscell(Y))
    Y = cell2mat(Y);
end

% if~(strcmp(mode,'CNN'))
%     tmp = Y;
%     Y = zeros(5,size(Y,2));
%     for i = 1 : size(tmp,2)
%         Y(:,i) = [H(tmp{i},pose{k}(1:3,4), angles{k}.heading-angles{1}.heading); tmp{i}(7:8)];
%     end
% end

if(isempty(X))
    p = 2;
    if ~isempty(Y)
        count_dontcare = 0;
        for i = 1:size(Y,2)
            if ~isempty(GTdc)
                count_dontcare = count_dontcare + isinside2(Y(:,i),GTdc,threshDC,'dontcare');
            end
        end
    end
    d = 0.5*c_thresh^p*(size(Y,2)-count_dontcare);
    d = d^(1/p);
    car_err = d;
    fp = size(Y,2)-count_dontcare;
    %disp(['k = ', num2str(k),' fp = ', num2str(fp)])
    return;
end
xL = size(X,2); % GT
yL = size(Y,2); % Estimated trajectories

%c_thresh = 10;%50;
min_overlap = 1e9;%0.5;
c = 0;
C = [];
count_ctresh = 0;

if(xL > yL) % nonnegative symmetry
    tmp = X;
    X = Y;
    Y = tmp;
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
    for i = 1 : xL
        % If center dist
        distance = (min(c_thresh,sqrt((X(1,i)-Y(1,assignment(i))).^2+(X(2,i)-Y(2,assignment(i))).^2))).^p;
        %distance = (min(c_thresh,C(i,assignment(i)))).^p; % If overlap
        if distance == c_thresh^p
            if ~isempty(GTdc)
                count_dontcare = count_dontcare + isinside2(X(:,i),GTdc,threshDC,'dontcare');
            end
            count_ctresh = count_ctresh+1;
        else
            loc_err = loc_err+distance^(1/p);
        end
        d =d + distance;
    end
    d = mean(d);
    d = d +0.5*c_thresh^p*(xL+yL-2*nbrAss-count_dontcare); % xL-count_dontcare + yL - 2*nbrAss + 2*count_dontcare
    d = d^(1/p);
    car_err = (0.5*c_thresh^p*(xL+yL-2*(lAss)-count_dontcare))^1/p;
    fp = (count_ctresh-count_dontcare);
    %fn = (yL-xL)+(count_ctresh-count_dontcare);
    fn = (yL-xL)+(count_ctresh);
%         if(xL+yL-2*(lAss) < 0)
%             fp = xL+yL-2*(lAss);
%         elseif(xL+yL-2*(lAss) > 0)
%             fn = xL+yL-2*(lAss);
%         end
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
    for i = 1 : xL
        % If center dist
        distance = (min(c_thresh,sqrt((X(1,i)-Y(1,assignment(i))).^2+(X(2,i)-Y(2,assignment(i))).^2))).^p;
        %distance = (min(c_thresh,C(i,assignment(i)))).^p; % If overlap
        if distance == c_thresh^p
            if ~isempty(GTdc)
                count_dontcare = count_dontcare + isinside2(Y(:,assignment(i)),GTdc,threshDC,'dontcare');
            end
            count_ctresh = count_ctresh+1;
        else
            loc_err = loc_err+distance^(1/p);
        end
        d =d + distance;
    end
    tmp = count_dontcare;
    for i = 1:yL
        if isempty(find(assignment == i))
            count_dontcare = count_dontcare + isinside2(Y(:,i),GTdc,threshDC,'dontcare');
        end
    end
            
    d = mean(d);
    d = d +0.5*c_thresh^p*(xL+yL-2*lAss-count_dontcare);
    d = d^(1/p);
    car_err = (0.5*c_thresh^p*(xL+yL-2*(lAss)-count_dontcare))^1/p;
    fp = (yL-xL)+(count_ctresh-count_dontcare);
    fn = (count_ctresh-tmp);
%         if(xL+yL-2*(lAss) < 0)
%             fp = xL+yL-2*(lAss);
%         elseif(xL+yL-2*(lAss) > 0)
%             fn = xL+yL-2*(lAss);
%         end
end

% if count_dontcare ~= 0
%     [k, count_dontcare]
% end
    


    