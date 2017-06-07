datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
ZGT = generateGT(set,sequence,datapath, nbrPosStates);

dist = cell(1,K);
for k = 1:size(Z,2)
    dist{k} = zeros(2,max(size(Z{k},2),size(ZGT{k},2)));
    for i = 1:size(Z{k},2)
        dist{k}(1,i) = Z{k}(3,i);
    end
    dist{k}(1,:) = sort(dist{k}(1,:));
    ind = find(dist{k}(1,:) == 0);
    if size(ind,2) > 1
        ind = ind(1);
    end
    dist{k}(1,1:size(dist{k},2)-ind) = dist{k}(1,ind+1:end);
    
    for i = 1:size(ZGT{k},2)
        dist{k}(2,i) = ZGT{k}(3,i);
    end
    dist{k}(2,:) = sort(dist{k}(2,:));
    ind = find(dist{k}(2,:) == 0);
    if size(ind,2) > 1
        ind = ind(1);
    end
    dist{k}(2,1:size(dist{k},2)-ind) = dist{k}(2,ind+1:end);
end