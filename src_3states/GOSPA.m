function d = GOSPA(X,Y,k,mode)
global H, global angles, global pose
xL = size(X,2); % GT
yL = size(Y,2); % Estimated trajectories
c_thresh = 10;%50;
min_overlap = 1e9;%0.5;
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
        C = zeros(xL,yL); % cost matrix
        for i = 1 : xL
            for j = 1 : yL
                c_tmp =  boxoverlap(Y(:,j),X(:,i),mode); % if ol = 1 then c = 0
                if(c_tmp <= min_overlap)
                    C(i,j) = c_tmp;
                else
                    C(i,j) = max_cost;
                end
            end
            if c_tmp < 0 
                keyboard
            end
        end
        assignment = murty(C,1);
        lAss = length(assignment);
        d = 0;
        alpha = 2;
        p = 2;
        for i = 1 : xL
            distance = (min(c_thresh,sqrt((Y(1,assignment(i))-X(1,i)).^2+(Y(2,assignment(i))-X(2,i)).^2))).^p;
            d =d + distance;
        end
        d = d +0.5*c_thresh^p*(xL+yL-2*lAss);
        d = d^(1/p);
    else
        ol = zeros(1,xL);
        max_cost = 1e9;
        %min_overlap = 0.5;
        C = zeros(xL,yL); % cost matrix
        for i = 1 : xL
            for j = 1 : yL
                c_tmp = boxoverlap(X(:,i),Y(:,j),mode); % if ol = 1 then c = 0
                if(c_tmp <= min_overlap)
                    C(i,j) = c_tmp;
                else
                    C(i,j) = max_cost;
                end
            end
        end
        assignment = murty(C,1);
        lAss = length(assignment);
        d = 0;
        alpha = 2;
        p = 2;
        for i = 1 : xL
            distance = (min(c_thresh,sqrt((X(1,i)-Y(1,assignment(i))).^2+(X(2,i)-Y(2,assignment(i))).^2))).^p;
            d =d + distance;
        end
        d = d +0.5*c_thresh^p*(xL+yL-2*lAss);
        d = d^(1/p);
    end
else
    for i = 1 : yL
        Y{i}(1:3) = H(Y{i},pose{k}(1:3,4), angles{k}.heading-angles{1}.heading);
    end
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
        C = zeros(xL,yL); % cost matrix
        for i = 1 : xL
            for j = 1 : yL
                c_tmp = boxoverlap(Y(:,j),X{i},mode); % if ol = 1 then c = 0
                if(c_tmp <= min_overlap)
                    C(i,j) = c_tmp;
                else
                    C(i,j) = max_cost;
                end
            end
        end
        assignment = murty(C,1);
        lAss = length(assignment);
        d = 0;
        alpha = 2;
        p = 2;
        for i = 1 : xL
            distance = (min(c_thresh,sqrt((Y(1,assignment(i))-X{i}(1)).^2+(Y(2,assignment(i))-X{i}(2)).^2))).^p;
            d =d + distance;
        end
        d = d +0.5*c_thresh^p*(xL+yL-2*lAss);
        d = d^(1/p);
    else
        ol = zeros(1,xL);
        max_cost = 1e9;
        C = zeros(xL,yL); % cost matrix
        for i = 1 : xL
            for j = 1 : yL
                c_tmp = boxoverlap(X(:,i),Y{j},mode); % if ol = 1 then c = 0
                if(c_tmp <= min_overlap)
                    C(i,j) = c_tmp;
                else
                    C(i,j) = max_cost;
                end
            end
        end
        assignment = murty(C,1);
        lAss = length(assignment);
        d = 0;
        alpha = 2;
        p = 2;
        for i = 1 : xL
            distance = (min(c_thresh,sqrt((X(1,i)-Y{assignment(i)}(1)).^2+(X(2,i)-Y{assignment(i)}(2)).^2))).^p;
            d =d + distance;
        end
        d = d +0.5*c_thresh^p*(xL+yL-2*lAss);
        d = d^(1/p);
    end 
end

    

    


    