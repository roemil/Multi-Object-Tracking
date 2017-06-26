function err = eval3DsingleTime(X,GT,XtCamCoords)

err = zeros(2,1);

GTL = size(GT,2); % GT
XL = size(X,2); % Estimated trajectories

max_cost = 20;
min_overlap = 1e9;%0.5;

if(GTL > XL) % nonnegative symmetry
    tmp = GT;
    GT = X;
    X = tmp;
    tmp = GTL;
    GTL = XL;
    XL = tmp;
    %min_overlap = 0.5;
    C = zeros(GTL,XL); % cost matrix
    for i = 1 : GTL
        for j = 1 : XL
            c_tmp = sqrt((X(1,j)-GT{i}(1))^2 + (X(2,j)-GT{i}(2))^2 + (X(3,j)-GT{i}(3))^2);
            if(c_tmp <= min_overlap)
                C(i,j) = c_tmp;
            else
                C(i,j) = max_cost;
            end
        end
    end
    assignment = murty(C,1);
    lAss = length(assignment);
    ind = 1;
    for i = 1 : GTL
        if C(i,assignment(i)) < max_cost
            err(1:2,ind) = [C(i,assignment(i)); sqrt(XtCamCoords(1,i)^2+XtCamCoords(2,i)^2+XtCamCoords(3,i)^2)];%sqrt(GT{i}(1)^2+GT{i}(2)^2+GT{i}(3)^2)];
            ind = ind+1;
        end
    end
else
    C = zeros(GTL,XL); % cost matrix
    for i = 1 : GTL
        for j = 1 : XL
            c_tmp = sqrt((X{j}(1)-GT(1,i))^2 + (X{j}(2)-GT(2,i))^2 + (X{j}(3)-GT(3,i))^2);
            if(c_tmp <= min_overlap)
                C(i,j) = c_tmp;
            else
                C(i,j) = max_cost;
            end
        end
    end
    assignment = murty(C,1);
    lAss = length(assignment);
    ind = 1;
    for i = 1 : GTL
        if C(i,assignment(i)) < max_cost
            err(1:2,ind) = [C(i,assignment(i)); sqrt(XtCamCoords(1,i)^2+XtCamCoords(2,i)^2+XtCamCoords(3,i)^2)];
            ind = ind+1;
        end
    end
end