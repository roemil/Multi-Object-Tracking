clear mat
Atmp = A{1}(1:end-1,:);
idx = perms(1:size(Atmp,2));
ind = 1;
for ii = idx'
 mat{ind} = Atmp(:,ii);
 ind = ind+1;
end