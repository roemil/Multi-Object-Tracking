function plotfunc(varargin)

if nargin == 2
    Xest = varargin{1}; 
    Z = varargin{2}; 
%     X = varargin{3};
% else
%     disp('Number of argument is different from 3')
%     return;
end

figure;
for i = 1:size(Xest,2)
    for j = 1 : size(Xest{i},2)
        plot(Xest{i}{j}(1),Xest{i}{j}(2),'o');
        hold on;
    end
end

for i = 1 : size(Z,2)
    for j = 1 : size(Z{i},2)
        plot(Z{i}(1,j),Z{i}(2,j),'*')
        hold on;
    end
end

% for i = 1 : size(X,2)
%     for j = 1 : size(X{i},2)
%         plot(X{i}(1,j),X{i}(2,j),'kx')
%         hold on;
%     end
% end

legend('Estimated','Measurements','True states')