%function hist = colorhistogram(Z)

imgpath = strcat('../../kittiTracking/','training','/','image_02/','0004/');
imgfilename = [imgpath,'000026.png'];

datapath = strcat('../../kittiTracking/','training','/','label_02/','0004');
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);

%plotGT('training', '0004', '000026')

meanpixVal = [];
%for i = 1 : 1

%    ind = 4;
yRed = cell(1);
yGreen = cell(1);
yBlue = cell(1);
L = cell(1);
a = cell(1);
b = cell(1);
i = 26;
%%
ind = find(GT{1} == i-1 & GT{2} ~= -1);

for j = 1 : 1%length(index)
    %ind = index(j);
    pixcoords = [mean([GT{7}(ind),GT{9}(ind)],2) mean([GT{8}(ind),GT{10}(ind)],2)];
    bbsize = [GT{9}(ind) - GT{7}(ind),GT{10}(ind)-GT{8}(ind)];
    boxes = [pixcoords(:,1) - bbsize(:,1)*0.5, pixcoords(:,2) - bbsize(:,2)*0.5,...
            bbsize(:,1),bbsize(:,2)];
    label = GT{2}(ind);
    %
    %figure('units','normalized','position',[.05 .05 .9 .9]);
    img = imread(imgfilename);
    %imagesc(img);
    %axis('image')
%    hold on;
    %rectangle('Position',boxes(1,:),'EdgeColor','g','LineWidth',1)
    %plot(pixcoords(1),pixcoords(2),'r*')

    % Extract sub-image using imcrop():
    for ind1 = 1 : size(boxes,1)
        subImage = imcrop(img, floor(boxes(ind1,:)));
        figure;
        imagesc(subImage);
        title(['i = ', num2str(ind1), ' ', ''])
        %[subImage,num2str(ind1)] = subImage;
        [yRed{ind1+8*(i-26)}, yGreen{ind1+8*(i-26)},yBlue{ind1+8*(i-26)}] = colorhist(img, boxes(ind1,:));
        [L{ind1+8*(i-26)}, a{ind1+8*(i-26)}, b{ind1+8*(i-26)}] = Lab(img, boxes(ind1,:));
        %[yBlue,num2str(ind1)] = yBlue;
        %meanpixVal(i,label(ind1)+1) = mean(mean(mean(subImage,3),2));
    end
end
i = i + 1;
close all;
%%
figure;
imagesc(subImage);
axis('image')

figure;
[yRed, x] = imhist(subImage(:,:,1));
[yGreen, x] = imhist(subImage(:,:,2));
[yBlue, x] = imhist(subImage(:,:,3));
plot(x, yRed, 'Red', x, yGreen, 'Green', x, yBlue, 'Blue');
title(['i = ', num2str(i)])

figure;
imhist(mean(subImage,3));
title('gray scale imhist');

figure;
histogram(mean(subImage,3));
title('gray scale histogram')



%%
clear all
imgpath = strcat('../../kittiTracking/','training','/','image_02/','0000/');
imgfilename = [imgpath,'000000.png'];

datapath = strcat('../../kittiTracking/','training','/','label_02/','0000');
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);
i = 1;
pixcoords = [mean([GT{7}(i),GT{9}(i)]);
          mean([GT{8}(i),GT{10}(i)])];
bbsize = [GT{9}(i) - GT{7}(i),GT{10}(i)-GT{8}(i)];
boxes = [pixcoords(1) - bbsize(1)*0.5, pixcoords(2) - bbsize(2)*0.5,...
        bbsize(1),bbsize(2)];
figure('units','normalized','position',[.05 .05 .9 .9]);
img = imread(imgfilename);
imagesc(img);
axis('image')
hold on;
rectangle('Position',boxes(1,:),'EdgeColor','g','LineWidth',1)
plot(pixcoords(1),pixcoords(2),'r*')

% Extract sub-image using imcrop():
subImage = imcrop(img, floor(boxes));
figure;
imagesc(subImage);
axis('image')

figure;
[yRed, x] = imhist(subImage(:,:,1));
[yGreen, x] = imhist(subImage(:,:,2));
[yBlue, x] = imhist(subImage(:,:,3));
plot(x, yRed, 'Red', x, yGreen, 'Green', x, yBlue, 'Blue');
title(['i = ', num2str(i)])

figure;
imhist(mean(subImage,3));
title('gray scale imhist');

figure;
histogram(mean(subImage,3));
title('gray scale histogram')

%%
clear dred;clear dgreen;clear dblue;
for m = 1 : size(yRed,2)
    dred(m) = chisdist(yRed{1},yRed{m});
    dgreen(m) = chisdist(yGreen{1},yGreen{m});
    dblue(m) = chisdist(yBlue{1},yBlue{m});
    
    %davg(m) = (dred(m)+dgreen(m)+dblue(m));
    davg(m) = colorcomp(yRed{1}, yGreen{1}, yBlue{1}, yRed{m}, yGreen{m} ,yBlue{m})
end


%%
rednorm = norm(dred);
greennorm = norm(dgreen);
bluenorm = norm(dblue);
davg = davg ./ (rednorm + greennorm + bluenorm);
dred
dgreen
dblue
davg