function [d, fp, fn] = GOSPA3D(X,Y,k,mode,c_thresh)
global H, global angles, global pose
fp = 0;
fn = 0;
if(isempty(X))
    p = 2;
    d = 0.5*c_thresh^p*(size(Y,2));
    d = d^(1/p);
    fp = size(Y,2);
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

if(strcmp(mode,'CNN'))
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
                C(i,j) = norm(Y(1:3,j)-X(1:3,i)); % if ol = 1 then c = 0
            end
        end
        assignment = murty(C,1);
        lAss = length(assignment);
        d = 0;
        alpha = 2;
        p = 2;
        for i = 1 : xL
            distance = (min(c_thresh,norm(Y(1:3,assignment(i))-X(1:3,i)))).^p;
            if distance == c_thresh
                count_ctresh = count_ctresh+1;
            end
            d =d + distance;
        end
        d = mean(d);
        d = d +0.5*c_thresh^p*(xL+yL-2*(lAss));
        d = d^(1/p);
        fp = count_ctresh;
        fn = (yL-xL)+count_ctresh;
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
                C(i,j) =  norm(Y(1:3,j)-X(1:3,i)); % if ol = 1 then c = 0
            end
        end
        assignment = murty(C,1);
        lAss = length(assignment);
        d = 0;
        alpha = 2;
        p = 2;
        for i = 1 : xL
            %sqrt((X(1,i)-Y(1,assignment(i))).^2+(X(2,i)-Y(2,assignment(i))).^2)^2
            distance = (min(c_thresh,norm(Y(1:3,assignment(i))-X(1:3,i)))).^p;
            if distance == c_thresh
                count_ctresh = count_ctresh+1;
            end
            d =d + distance;
        end
        d = mean(d);
        d = d +0.5*c_thresh^p*(xL+yL-2*(lAss));
        d = d^(1/p);
        fp = (yL-xL)+count_ctresh;
        fn = count_ctresh;
%         if(xL+yL-2*(lAss) < 0)
%             fp = xL+yL-2*(lAss);
%         elseif(xL+yL-2*(lAss) > 0)
%             fn = xL+yL-2*(lAss);
%         end
    end
else
    if(xL > yL) % nonnegative symmetry
        tmp = X;
        X = Y;
        Y = tmp;
        tmp = xL;
        xL = yL;
        yL = tmp;
        ol = zeros(1,xL);
        max_cost = 1e9;
        %min_overlap = 0.5;
        % cost matrix
        for i = 1 : xL
            for j = 1 : yL
                C(i,j) =  norm(Y(1:3,j)-X(1:3,i)); % if ol = 1 then c = 0
            end
        end
        assignment = murty(C,1);
        lAss = length(assignment);
        d = 0;
        alpha = 2;
        p = 2;
        for i = 1 : xL
            %sqrt((Y(1,assignment(i))-X{i}(1)).^2+(Y(2,assignment(i))-X{i}(2)).^2)^2
                distance = (min(c_thresh,norm(Y(1:3,assignment(i))-X(1:3,i)))).^p;
                if distance == c_thresh
                    count_ctresh = count_ctresh+1;
                end
                d =d + distance;
        end
        d = mean(d);
        d = d +0.5*c_thresh^p*(xL+yL-2*(lAss));
        d = d^(1/p);
        fp = count_ctresh;
        fn = (yL-xL)+count_ctresh;
%         if(xL+yL-2*(lAss) < 0)
%             fp = xL+yL-2*(lAss);
%         elseif(xL+yL-2*(lAss) > 0)
%             fn = xL+yL-2*(lAss);
%         end
    else
        ol = zeros(1,xL);
        max_cost = 1e9;
        % cost matrix
        xL = size(X,2); % GT
        yL = size(Y,2); % Estimated trajectories
        for i = 1 : xL
            for j = 1 : yL
                C(i,j) =  norm(Y(1:3,j)-X(1:3,i)); % if ol = 1 then c = 0
            end
        end
        assignment = murty(C,1);
        lAss = length(assignment);
        d = 0;
        alpha = 2;
        p = 2;
        for i = 1 : xL
                distance = (min(c_thresh,norm(Y(1:3,assignment(i))-X(1:3,i)))).^p;
                if distance == c_thresh
                    count_ctresh = count_ctresh+1;
                end
                d = d + distance;
        end
        d = mean(d); % Mean average error
        d = d +0.5*c_thresh^p*(xL+yL-2*(lAss));
        d = d^(1/p);
        fp = (yL-xL)+count_ctresh;
        fn = count_ctresh;
%         if(xL+yL-2*(lAss) < 0)
%             fp = xL+yL-2*(lAss);
%         elseif(xL+yL-2*(lAss) > 0)
%             fn = xL+yL-2*(lAss);
%         end
    end 
end

% if fp ~= 0
%    disp(['k = ', num2str(k),' fp = ', num2str(fp)])
% end

    

    


    