function [est, true] = estGTdiff(seq,set,k,X,plotOn)

if nargin == 4
    plotOn = 'false';
end

datapath = strcat('../../kittiTracking/',set,'/','label_02/',seq);
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);

ind = find(GT{1} == k & GT{2} ~= -1);

true = [GT{14}(ind)'; GT{15}(ind)'; GT{16}(ind)'];
est = zeros(3,size(X,2));

if isstruct(X(1))
    for i = 1:size(X,2)
        est(1:3,i) = X(i).state(1:3);
    end
else
    for i = 1:size(X,2)
        est(1:3,i) = X(1:3,i);
    end
end

if plotOn
    figure;
    plot3(est(1,:),est(2,:),est(3,:),'b+')
    hold on
    plot3(true(1,:),true(2,:),true(3,:),'r*','markersize',20)
end
    
    