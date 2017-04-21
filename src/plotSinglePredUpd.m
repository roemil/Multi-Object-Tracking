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

if ~isempty(Xpred)
   predBox = [Xpred(i).state(1)-Xpred(i).box(1)/2, Xpred(i).state(2)-Xpred(i).box(2)/2, Xpred(i).box(1), Xpred(i).box(2)];
   rectangle('Position',predBox,'EdgeColor','r','LineWidth',1.5)
   text(predBox(1), predBox(2), num2str(Xpred(i).label),'color','red','fontsize',15)
else
    disp('Pred empty')
end

if ~isempty(Xupd)
   predBox = [Xupd(i).state(1)-Xupd(i).box(1)/2, Xupd(i).state(2)-Xupd(i).box(2)/2, Xupd(i).box(1), Xupd(i).box(2)];
   rectangle('Position',predBox,'EdgeColor','g','LineWidth',1,'LineStyle','--')
   text(predBox(1), predBox(2), num2str(Xupd(i).label),'color','red','fontsize',15)
end
