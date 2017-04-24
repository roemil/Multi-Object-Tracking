% Function to plot and image with its corresponding detections
%
% Input:    set:        Either training or testing
%           sequence:   Which sequence in the set, e.g. 0000
%           frameNbr:   The frame number in the sequence, e.g. 000000
%           Xest:       Estimate in one time instance.
%                       [x,y,vx,vy,width,height]^T
%

function plotGT(set, sequence, frameNbr, GT)

% Frame || Height || Width || Target id || center x || center y || Bounding
% width || Bounding height || Confidence

% Path for textfile with detection data
detectionPath = strcat('../../kittiTracking/',set,'/label_02/',sequence,'.txt');
% Joachim
% detectionPath = strcat('/Users/JoachimBenjaminsson/Documents/Chalmers/Master thesis'...
%    ,'/Matlab/Git/Multi-Object-Tracking/data/tracking/',set,'/',sequence,'/inferResult.txt');
% Emil
% detectionPath = strcat('/Users/JoachimBenjaminsson/Documents/Chalmers/Master thesis'...
%     ,'/Matlab/Git/Multi-Object-Tracking/data/tracking/',set,'/',sequence,'/inferResult.txt');

% Path for image
imagePath = strcat('../../kittiTracking/',set,'/image_02/',sequence,'/',frameNbr,'.png');
% Joachim
% imagePath = strcat('/Users/JoachimBenjaminsson/Documents/Chalmers/Master thesis'...
%    ,'/Matlab/Git/kittiTracking/',set,'/image_02/',sequence,'/',frameNbr,'.png');
% Emil
% imagePath = strcat('/Users/JoachimBenjaminsson/Documents/Chalmers/Master thesis'...
%     ,'/Matlab/Git/kittiTracking/',set,'/image_02/',sequence,'/',frameNbr,'.png');

formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(detectionPath);
dataArray = textscan(f,formatSpec);
frameNum = str2num(frameNbr);
fclose(f);

% Find indices for the frame number of interest
ind = find(ismember(dataArray{1},frameNum,'rows') == 1 & ismember(dataArray{2},-1,'rows') == 0);

xInd = 14;
yInd = 15;
zInd = 16;
% Find bounding box data
pixcoords = zeros(2,length(ind));
for i = 1 : length(ind)
    %xcoord1 = dataArray{xInd}(ind(i));
    %ycoord1 = dataArray{yInd}(ind(i));
    %zcoord1 = dataArray{zInd}(ind(i));
    %pixcoords(:,i) = camera2pixelcoords([xcoord1;ycoord1;zcoord1],P);
    %xcoord(i) = pixcoords(1,i);
    %ycoord(i) = pixcoords(2,i);
    width(i) = dataArray{9}(ind(i))-dataArray{7}(ind(i))+1;
    height(i) = dataArray{10}(ind(i))-dataArray{8}(ind(i))+1;
    %boxes(i,:) = [xcoord(i)-width(i)/2, ycoord(i)-height(i), width(i), height(i)]';
    boxes(i,:) = [dataArray{7}(ind(i)),dataArray{8}(ind(i)), width(i), height(i)]';
end
    % Store data in format for rectangle-function

for i = 1 : size(GT,2)
    xcoord(i) = GT(1,i);
    ycoord(i) = GT(2,i);
end
% Read and plot image
img = imread(imagePath);
%figure;
imagesc(img)
axis('image')
hold on

% Plot bounding boxes
for i = 1:size(ind,1)
    rectangle('Position',boxes(i,:),'EdgeColor','g','LineWidth',1)
end
plot(xcoord,ycoord,'rx')

% maxWidth = max(boxes(:,3));
% maxHeight = max(boxes(:,4));
% 
% if ~isempty(Xest{1})
%     for i = 1:size(Xest,2)
%         if size(Xest{i},1) == 4
%             Xest{i}(5) = maxWidth;
%             Xest{i}(6) = maxHeight;
%         end
%         estBox = [Xest{i}(1)-Xest{i}(5)/2, Xest{i}(2)-Xest{i}(6)/2, Xest{i}(5), Xest{i}(6)];
%         rectangle('Position',estBox,'EdgeColor','r','LineWidth',1)
%     end
% end
