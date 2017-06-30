function a = plotImgEst2(seq,set,k,X,Z,GT,GTdc)
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
imagesc(img);
axis('image')
hold on
%xlim([FOVsize(1,1)+150 FOVsize(2,1)*0.51])
%ylim([FOVsize(1,2) + 110 FOVsize(2,2)*0.7])

xlim([FOVsize(1,1) FOVsize(2,1)])
ylim([FOVsize(1,2) FOVsize(2,2)])

if ~isempty(GT)
    boxes = [GT(1,:)'-GT(4,:)'/2 GT(2,:)'-GT(5,:)'/2 GT(4,:)', GT(5,:)'];
    for i = 1:size(boxes,1)
        rectangle('Position',boxes(i,:),'EdgeColor','g','LineWidth',1)
    end
end

if ~isempty(GTdc)
    boxesdc = [GTdc(1,:)'-GTdc(4,:)'/2, GTdc(2,:)'-GTdc(5,:)'/2, GTdc(4,:)', GTdc(5,:)'];

    for i = 1:size(boxesdc,1)
        rectangle('Position',boxesdc(i,:),'EdgeColor','m','LineWidth',1)
    end
end

if ~isempty(X)
    for i = 1:size(X,2) % CONT HERE
        tmp = H(X{i}(1:end-2),pose{k}(1:3,4), angles{k}.heading-angles{1}.heading);
        box = [tmp(1)-X{i}(end-3)/2, tmp(2)-X{i}(end-2)/2, X{i}(end-3), X{i}(end-2)];
        rectangle('Position',box,'EdgeColor','r','LineWidth',1,'LineStyle','--')
        text(box(1), box(2)-10, num2str(X{i}(end-1)),'Fontsize',18,'Color','red')
    end
end

if ~isempty(Z)
    for i = 1:size(Z,2)
        box = [Z(1,i)-Z(4,i)/2, Z(2,i)-Z(5,i)/2, Z(4,i), Z(5,i)];
        rectangle('Position',box,'EdgeColor','c','LineWidth',1,'LineStyle','-')
        %plot(Z(1,i),Z(2,i),'c*')
    end
end