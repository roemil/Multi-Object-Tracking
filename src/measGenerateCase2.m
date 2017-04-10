function Z = measGenerateCase2(X, R, FOVsize, K)

for k = 1:K
    Z{k} = [];
    % Generate measurement if detected
    for i = 1:size(X{k},2)
        detObject = unifrnd(0,1);
        if detObject < X{k}(6,i)
            Z{k} = [Z{k}, measGenerate(X{k}(:,i),R)];
        end
    end

    if isempty(Z{k})
        ind = randi(size(X{k},2));
        Z{k} = measGenerate(X{k}(:,ind),R);
    end

    % Number of clutter measurements, 0,1,2
    nbrClutter = randi(2)-1;
    for i = 1:nbrClutter
       %Z{k} = [Z{k}, [unifrnd(1,20); unifrnd(-pi,pi)]]; % For distance and
       %angle
       Z{k} = [Z{k}, [unifrnd(-FOVsize(1)/2, FOVsize(1)/2); unifrnd(0, FOVsize(2))]];
    end

    %Rearrenge measurement order
    Z{k} = Z{k}(:,randperm(size(Z{k},2)));
end