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


% Find bounding box data
width = zeros(1,length(ind));
height = zeros(1,length(ind));
boxes = zeros(length(ind),4);
for i = 1 : length(ind)
    width(i) = dataArray{9}(ind(i))-dataArray{7}(ind(i))+1;
    height(i) = dataArray{10}(ind(i))-dataArray{8}(ind(i))+1;
    boxes(i,:) = [dataArray{7}(ind(i)),dataArray{8}(ind(i)), width(i), height(i)]';
    label(i) = dataArray{2}(ind(i));
end
    % Store data in format for rectangle-function
% xcoord = zeros(1,size(GT,2));
% ycoord = zeros(1,size(GT,2));
% for i = 1 : size(GT,2)
%     xcoord(i) = GT(1,i);
%     ycoord(i) = GT(2,i);
% end
% Read and plot image
figure('units','normalized','position',[.05 .05 .9 .9]);
img = imread(imagePath);
%figure;
imagesc(img)
axis('image')
hold on

% Plot bounding boxes
for i = 1:size(ind,1)
    rectangle('Position',boxes(i,:),'EdgeColor','g','LineWidth',1)
    text(boxes(i,1),boxes(i,2),num2str(label(i)),'Color','r','FontSize',18);
end
%plot(xcoord,ycoord,'rx')

