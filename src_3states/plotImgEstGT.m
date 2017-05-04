function plotImgEstGT(seq,set,k,X)
global FOVsize
global H3dFunc
global H3dTo2d
global H

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
imagesc(img);
axis('image')
hold on
xlim([FOVsize(1,1) FOVsize(2,1)])
ylim([FOVsize(1,2) FOVsize(2,2)])

ind = find(GT{1} == k-1 & GT{2} ~= -1);
boxes = [GT{7}(ind), GT{8}(ind), GT{9}(ind)-GT{7}(ind) GT{10}(ind)-GT{8}(ind)];

for i = 1:size(boxes,1)
    rectangle('Position',boxes(i,:),'EdgeColor','g','LineWidth',1)
end

for i = 1:size(X,2)
    tmp = H(X{i}(1:end-1));
    box = [tmp(1)-X{i}(end-2)/2, tmp(2)-X{i}(end-1)/2, X{i}(end-2), X{i}(end-1)];
    rectangle('Position',box,'EdgeColor','r','LineWidth',1,'LineStyle','--')
    text(box(1), box(2), num2str(X{i}(end)),'Fontsize',18,'Color','red')
end