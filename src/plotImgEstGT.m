function plotImgEstGT(seq,set,k,X)
global FOVsize
global H
global k
global pose, global angles, global rescaleFact

datapath = strcat('../../kittiTracking/',set,'/','label_02/',seq);
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
%imagesc(img);
subimage(img);
axis('image')
hold on
xlim([FOVsize(1,1) FOVsize(2,1)])
ylim([FOVsize(1,2) FOVsize(2,2)])

ind = find(GT{1} == k-1 & GT{2} ~= -1);
boxes = [GT{7}(ind), GT{8}(ind), GT{9}(ind)-GT{7}(ind) GT{10}(ind)-GT{8}(ind)];

cx(1:size(ind,1)) = mean([GT{7}(ind),GT{9}(ind)],2);
cy(1:size(ind,1)) = mean([GT{8}(ind),GT{10}(ind)],2);

for i = 1:size(boxes,1)
    rectangle('Position',boxes(i,:),'EdgeColor','g','LineWidth',1)
    plot(cx(i),cy(i),'g*')
end

if ~isempty(X{1})
    for i = 1:size(X,2)
        box = [X{i}(1)-X{i}(end-3)/2, X{i}(2)-X{i}(end-2)/2, X{i}(end-3), X{i}(end-2)];
        rectangle('Position',box,'EdgeColor','r','LineWidth',1,'LineStyle','--')
        text(box(1), box(2)-10, num2str(X{i}(end-1)),'Fontsize',18,'Color','red')
        
        % color box
        %box = [tmp(1)-rescaleFact*X{i}(end-2)/2, tmp(2)-rescaleFact*X{i}(end-1)/2, rescaleFact*X{i}(end-2), rescaleFact*X{i}(end-1)];
        %rectangle('Position',box,'EdgeColor','r','LineWidth',1,'LineStyle','--')
    end
end
