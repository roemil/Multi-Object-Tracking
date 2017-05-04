function [p1, p2, l, h] = plot3DestGT(seq,set,k,X,P,plotConf)
h = [];
if nargin == 5
    plotConf = false;
end

datapath = strcat('../../kittiTracking/',set,'/','label_02/',seq);
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);

ind = find(GT{1} == k-1 & GT{2} ~= -1);

true = [GT{14}(ind)'; (GT{15}(ind)-GT{11}(ind)/2)'; GT{16}(ind)'];

for i = 1:size(X,2)
    est(:,i) = X{i}(1:end-1);
    labels(1,i) = X{i}(end);
end

p2 = plot3(true(1,:),true(3,:),true(2,:),'g*','markersize',10);
hold on
p1 = [];
l = [];
for i = 1:size(est,2)
    p1 = [p1, plot3(est(1,i),est(3,i),est(2,i),'r+','markersize',10)];
    l = [l, text(est(1,i), est(3,i), est(2,i), num2str(labels(1,i)),'Fontsize',18,'Color','red')];
    
    if plotConf
        Ptmp = zeros(3,3);
        Ptmp(1,1) = P{i}(1,1);
        Ptmp(2:3,2:3) = diag([P{i}(3,3), P{i}(2,2)]);
        Ptmp(2,3) = P{i}(2,3);
        Ptmp(3,2) = P{i}(3,2);
        Ptmp(1,2:3) = fliplr(P{i}(1,2:3));
        Ptmp(2:3,1) = Ptmp(1,2:3)';
        h = [h, error_ellipse(Ptmp, [est(1,i), est(3,i), est(2,i)],'conf',0.9973)]; % Enable h4 if ellipsoid
    end
end
legend([p1(1), p2],'Estimate','GT')
xlabel('x')
zlabel('y')
ylabel('z')
