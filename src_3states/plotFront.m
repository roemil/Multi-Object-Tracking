function a = plotImgEst(seq,set,k,X,indeces)
global FOVsize
global H3dFunc
global H3dTo2d
global H
global egoMotionOn
global pose, global angles

frameNbr = sprintf('%06d',k-1);
imagePath = strcat('../../kittiTracking/',set,'/image_02/',seq,'/',frameNbr,'.png');

% Read and plot image
img = imread(imagePath);
figure('units','normalized','position',[.05 .05 .9 .9]);
a = subplot('position', [0.02 0 0.98 1]);
imagesc(img);
axis('image');
hold on
%xlim([FOVsize(1,1)+150 FOVsize(2,1)*0.51])
%ylim([FOVsize(1,2) + 110 FOVsize(2,2)*0.7])

xlim([FOVsize(1,1) FOVsize(2,1)])
ylim([FOVsize(1,2) FOVsize(2,2)])

if ~isempty(X{k})
    for i = 1:size(X{k},2)
        tmp = H(X{k}{i}(1:end-2),pose{k}(1:3,4), angles{k}.heading-angles{1}.heading);
        box = [tmp(1)-X{k}{i}(end-3)/2, tmp(2)-X{k}{i}(end-2)/2, X{k}{i}(end-3), X{k}{i}(end-2)];
        rectangle('Position',box,'EdgeColor','r','LineWidth',1,'LineStyle','--')
        text(box(1), box(2)-10, num2str(X{k}{i}(end-1)),'Fontsize',18,'Color','red')
    end
end

for ii = 1:size(indeces,2)
    if ~isempty(X{k+indeces(ii)})
        for i = 1:size(X{k+indeces(ii)},2)
            tmp = H(X{k+indeces(ii)}{i}(1:end-2),pose{k+indeces(ii)}(1:3,4), angles{k+indeces(ii)}.heading-angles{1}.heading);
            box = [tmp(1)-X{k+indeces(ii)}{i}(end-3)/2, tmp(2)-X{k+indeces(ii)}{i}(end-2)/2, X{k+indeces(ii)}{i}(end-3), X{k+indeces(ii)}{i}(end-2)];
            rectangle('Position',box,'EdgeColor','g','LineWidth',1,'LineStyle','--')
            text(box(1), box(2)-10, num2str(X{k+indeces(ii)}{i}(end-1)),'Fontsize',18,'Color','green')
        end
    end
end