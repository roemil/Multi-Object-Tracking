clear all;clf;close all;clc;
load('data');

Z = cell(1);
Z2 = cell(1);
GT = cell(1);
for i = 1 : size(z,2)
    Z{i} = [z{i} meas2{i}];
    Z2{i} = Z{i} + mvnrnd([0;0], 0.2*[1 0;0 1],2)';
end

for i = 1 : size(targets,2)
    for j = 1 : size(targets{i},2)
        GT{i} = [targets{i}(1:2,j) targets2{i}(1:2,j)];
    end
end
%%
% figure;
% for i = 1 : size(GT,2)
%     for j = 1 : size(GT{i},2)
%         plot(GT{i}(1,j),GT{i}(2,j),'bo');
%         hold on;
%         plot(Z{i}(1,j),Z{i}(2,j),'kx')
%     end
% end

[pred,upd,est]=PMBM(GT);

%%
figure
for k = 1:size(Z,2)
    if(~isempty(est{k}))
        for i = 1:size(est{k},2)
%             size(est{k},2)
%             isempty(est{k})
%             est{k}
%             est{k}{i}
            est{k}{1}(3:4)
            plot(est{k}{i}(1),est{k}{i}(2),'-or')
            hold on
            plot(GT{k}(1,i),GT{k}(2,i),'-ok')
            plot(Z2{k}(1,i),Z2{k}(2,i),'-ob')
        end
    end
end