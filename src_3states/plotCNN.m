function plotCNN(seq,set,k,Z)
global k

datapath = strcat('../../kittiTracking/',set,'/','label_02/',seq);
%datapath = strcat('../data/tracking_dist/',set,'/',seq);
%filename = [datapath,'/inferResult.txt'];
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);

frameNbr = sprintf('%06d',k-1);
imagePath = strcat('../../kittiTracking/',set,'/image_02/',seq,'/',frameNbr,'.png');

% Read and plot image
%figure;
img = imread(imagePath);
imagesc(img);
axis('image')
hold on
%xlim([FOVsize(1,1) FOVsize(2,1)])
%ylim([FOVsize(1,2) FOVsize(2,2)])

ind = find(GT{1} == k-1 & GT{2} ~= -1);
boxes = [GT{7}(ind), GT{8}(ind), GT{9}(ind)-GT{7}(ind) GT{10}(ind)-GT{8}(ind)];

cx(1:size(ind,1)) = mean([GT{7}(ind),GT{9}(ind)],2);
cy(1:size(ind,1)) = mean([GT{8}(ind),GT{10}(ind)],2);
trunc = GT{4}(ind);
occl = GT{5}(ind);
for i = 1:size(boxes,1)
    rectangle('Position',boxes(i,:),'EdgeColor','g','LineWidth',1)
    if(trunc(i) ~= 0)
        text(boxes(i,1),boxes(i,2)-10,num2str(trunc(i)));
    end
    if(occl(i) ~= 0)
        text(boxes(i,1)+boxes(i,3),boxes(i,2),num2str(occl(i)),'Fontsize',18,'Color','red');
    end
    %plot(cx(i),cy(i),'g*')
end

if ~isempty(Z)
    for i = 1:size(Z,2)
        box = [Z(1,i)-Z(4,i)/2, Z(2,i)-Z(5,i)/2, Z(4,i), Z(5,i)];
        rectangle('Position',box,'EdgeColor','c','LineWidth',1,'LineStyle','--')
        plot(Z(1,i),Z(2,i),'c*')
    end
end