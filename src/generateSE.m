function [PestVec, squareError] = generateSE(Xtrue,Xest,Pest,K)

maxObj = 0;
for k = 2:K
    if size(Xtrue{k},2) > maxObj
        maxObj = size(Xtrue{k},2);
    end
end

maxEst = 0;
for k = 2:K
    if size(Xtrue{k},2) > maxEst
        maxEst = size(Xest{k},2);
    end
end

squareError = zeros(4,K,maxObj);
PestVec = zeros(4,K,maxEst);

% For each time instance
for k = 2:K
    % Find closest match of estimates and true states
    dist = zeros(size(Xest{k},2), size(Xtrue{k},2));
    for estTarget = 1:size(Xest{k},2)
        for trueTarget = 1:size(Xtrue{k},2)
            xdiff = Xest{k}{estTarget}(1)-Xtrue{k}(1,trueTarget);
            ydiff = Xest{k}{estTarget}(2)-Xtrue{k}(2,trueTarget);
            dist(estTarget,trueTarget) = sqrt(xdiff^2+ydiff^2);
        end
    end
    
    [asso, ~] = murty(dist,1);
    
    % Display if the number of target and estimates are not the same and
    % create a figure for unassigned estimates
    if size(dist,1) < size(dist,2)
        % Problem with murty if nbr of est is one
        if size(dist,1) == 1
            if asso(1,1) == 2
                asso(asso(1,1)) = 1;
                asso(1,1) = NaN;
            else
                asso(asso(1,1)) = 1;
            end
        end
        for i = size(dist,1)+1:size(dist,2)
            asso(1,i) = NaN;
        end
        disp(['Nbr of estimates < nbr of true targets, k = ', num2str(k)])
    elseif size(dist,1) > size(dist,2) 
        disp(['Nbr of estimates > nbr of true targets, k = ', num2str(k)])
    end
    
    for trueTarget = 1:size(asso,2)
        if sum(asso(:,trueTarget) ~= 0) ~= 0
            if ~isnan(asso(1,trueTarget))
                squareError(:,k,trueTarget) = (Xest{k}{asso(1,trueTarget)}-Xtrue{k}(1:4,trueTarget)).^2;
            else
                squareError(:,k,trueTarget) = 10;
            end
        end
    end
    
    if isempty(Pest{k})
        PestVec(:,k,:) = 0;
    else
        for i = 1:size(Pest{k},2)
            PestVec(:,k,i) = diag(Pest{k}{i});
        end
    end 
end
