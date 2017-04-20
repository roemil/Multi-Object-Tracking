function plotSinglePredUpd(set, sequence, frameNbr, Xpred, Xupd,i,FOVsize)

% Path for image
imagePath = strcat('../../kittiTracking/',set,'/image_02/',sequence,'/',frameNbr,'.png');

% Read and plot image
img = imread(imagePath);
%figure;
imagesc(img)
axis('image')
hold on
xlim([FOVsize(1,1) FOVsize(2,1)])
ylim([FOVsize(1,2) FOVsize(2,2)])

if ~isempty(Xpred{1})
   predBox = [Xpred{1}(i).state(1)-Xpred{1}(i).box(1)/2, Xpred{1}(i).state(2)-Xpred{1}(i).box(2)/2, Xpred{1}(i).box(1), Xpred{1}(i).box(2)];
   rectangle('Position',predBox,'EdgeColor','r','LineWidth',1.5)
   text(predBox(1), predBox(2), num2str(Xpred{1}(i).label),'color','red','fontsize',15)
else
    disp('Pred empty')
end

if ~isempty(Xupd{1})
   predBox = [Xupd{1}(i).state(1)-Xupd{1}(i).box(1)/2, Xupd{1}(i).state(2)-Xupd{1}(i).box(2)/2, Xupd{1}(i).box(1), Xupd{1}(i).box(2)];
   rectangle('Position',predBox,'EdgeColor','g','LineWidth',1,'LineStyle','--')
   text(predBox(1), predBox(2), num2str(Xupd{1}(i).label),'color','red','fontsize',15)
end
