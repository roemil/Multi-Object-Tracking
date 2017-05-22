%function hist = colorhistogram(Z)

imgpath = strcat('../../kittiTracking/','training','/','image_02/','0000/');
imgfilename = [imgpath,'000000.png'];

datapath = strcat('../../kittiTracking/','training','/','label_02/','0000');
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);


meanpixVal = [];
for i = 1 : 50
    ind = find(GT{1} == i-1 & GT{2} ~= -1);
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
    hold on;
    %rectangle('Position',boxes(1,:),'EdgeColor','g','LineWidth',1)
    %plot(pixcoords(1),pixcoords(2),'r*')

    % Extract sub-image using imcrop():
    for ind = 1 : size(boxes,1)
        subImage = imcrop(img, floor(boxes(ind,:)));
        meanpixVal(i,label(ind)+1) = mean(mean(mean(subImage,3),2));
    end
end
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