function plot3DestGT(seq,set,k,X,P)

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

figure;
hold on
p2 = plot3(true(1,:),true(3,:),true(2,:),'g*','markersize',10);
for i = 1:size(est,2)
    p1 = plot3(est(1,i),est(3,i),est(2,i),'r+','markersize',10);
    text(est(1,i), est(3,i), est(2,i), num2str(labels(1,i)),'Fontsize',18,'Color','red')
    
    %error_ellipse() Wrong order, 3sigma
end
legend([p1, p2],'Estimate','GT')
xlabel('x')
zlabel('y')
ylabel('z')
