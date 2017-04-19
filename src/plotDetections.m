% Function to plot and image with its corresponding detections
%
% Input:    set:        Either training or testing
%           sequence:   Which sequence in the set, e.g. 0000
%           frameNbr:   The frame number in the sequence, e.g. 000000
%           Xest:       Estimate in one time instance.
%                       [x,y,vx,vy,width,height]^T
%

function plotDetections(set, sequence, frameNbr, Xest)

% Frame || Height || Width || Target id || center x || center y || Bounding
% width || Bounding height || Confidence

% Path for textfile with detection data
detectionPath = strcat('../data/tracking/',set,'/',sequence,'/inferResult.txt');
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

delimiter = ',';

% Format
formatSpec = '%f%f%f%f%f%f%f%f%f';

% Find file ID
fileID = fopen(detectionPath,'r');

% Fetch data
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

% Convert frameNbr to a number
frameNum = str2num(frameNbr);

fclose(fileID);

% Find indeces for the frame number of interest
ind = find(ismember(dataArray{1},frameNum,'rows') == 1);

% Find bounding box data
xcoord = dataArray{5}(ind);
ycoord = dataArray{6}(ind);
width = dataArray{7}(ind);
height = dataArray{8}(ind);

% Store data in format for rectangle-function
boxes = [xcoord-width/2, ycoord-height/2, width, height];

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

maxWidth = max(boxes(:,3));
maxHeight = max(boxes(:,4));

if ~isempty(Xest{1})
    for i = 1:size(Xest,2)
        if size(Xest{i},1) == 4
            Xest{i}(5) = maxWidth;
            Xest{i}(6) = maxHeight;
        end
        estBox = [Xest{i}(1)-Xest{i}(5)/2, Xest{i}(2)-Xest{i}(6)/2, Xest{i}(5), Xest{i}(6)];
        rectangle('Position',estBox,'EdgeColor','r','LineWidth',1)
    end
end
