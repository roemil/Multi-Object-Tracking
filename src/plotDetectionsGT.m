% Function to plot and image with its corresponding detections
%
% Input:    set:        Either training or testing
%           sequence:   Which sequence in the set, e.g. 0000
%           frameNbr:   The frame number in the sequence, e.g. 000000
%           Xest:       Estimate in one time instance.
%                       [x,y,vx,vy,width,height]^T
%

function plotDetectionsGT(set, sequence, frameNbr, Xest, FOVsize, Z)

% Frame || Height || Width || Target id || center x || center y || Bounding
% width || Bounding height || Confidence


% Path for image
imagePath = strcat('../../kittiTracking/',set,'/image_02/',sequence,'/',frameNbr,'.png');

boxes = zeros(size(Z,2),4);

for z = 1:size(Z,2)
    boxes(z,:) = Z(1:4,z)' - [Z(3,z)/2, Z(4,z)/2, 0, 0];
end

% Read and plot image
img = imread(imagePath);
%figure;
imagesc(img);
axis('image')
hold on
xlim([FOVsize(1,1) FOVsize(2,1)])
ylim([FOVsize(1,2) FOVsize(2,2)])

% Plot bounding boxes
for i = 1:size(Z,2)
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
        rectangle('Position',estBox,'EdgeColor','r','LineWidth',1,'LineStyle','--')
        text(estBox(1), estBox(2), num2str(Xest{i}(7)),'Fontsize',18,'Color','red')
    end
end
