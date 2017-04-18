function plotPredUpd(set, sequence, frameNbr, Xpred, Xupd)

% Path for image
imagePath = strcat('../../kittiTracking/',set,'/image_02/',sequence,'/',frameNbr,'.png');

% Read and plot image
img = imread(imagePath);
%figure;
imagesc(img)
axis('image')
hold on

if ~isempty(Xpred{1})
    for i = 1:size(Xpred{1},2)
       predBox = [Xpred{1}(i).state(1)-Xpred{1}(i).box(1)/2, Xpred{1}(i).state(2)-Xpred{1}(i).box(2)/2, Xpred{1}(i).box(1), Xpred{1}(i).box(2)];
       rectangle('Position',predBox,'EdgeColor','r','LineWidth',1)
    end
else
    disp('Pred empty')
end

if ~isempty(Xupd{1})
    for i = 1:size(Xupd{1},2)
       predBox = [Xupd{1}(i).state(1)-Xupd{1}(i).box(1)/2, Xupd{1}(i).state(2)-Xupd{1}(i).box(2)/2, Xupd{1}(i).box(1), Xupd{1}(i).box(2)];
       rectangle('Position',predBox,'EdgeColor','g','LineWidth',0.5)
    end
end
