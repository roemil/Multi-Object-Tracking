% Test cases for plotStates
load('case3')
[pred, upd, est] = PMBM(Z);

%%
% To test "plotStates" with more targets than estimates
Xtrue2 = X;
for k = 2:40
    Xtrue2{k}(:,end+1) = X{k}(:,1);
    Xtrue2{k}(:,end+1) = X{k}(:,2);
end

%%
% To test "plotStates" with more estimates than targets
est2 = est;
for k = 2:size(est,2)
    est2{k}{end+1} = est{k}{1};
    est2{k}{end+1} = est{k}{2};
end