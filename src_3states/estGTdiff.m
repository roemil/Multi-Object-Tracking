function [est, true] = estGTdiff(seq,set,k,X,plotOn3D,plotOnImg)

if nargin == 4
    plotOn3D = false;
    plotOnImg = false;
end

datapath = strcat('../../kittiTracking/',set,'/','label_02/',seq);
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);

ind = find(GT{1} == k-1 & GT{2} ~= -1);

true = [GT{14}(ind)'; (GT{15}(ind)-GT{11}(ind)/2)'; GT{16}(ind)'];
%true = [GT{14}(ind)'; GT{15}(ind)'; GT{16}(ind)'];

if plotOnImg
    est = zeros(9,size(X,2));
else
    est = zeros(8,size(X,2));
end

if iscell(X)
    if isstruct(X{1})
        for i = 1:size(X,2)
            est(:,i) = X{i}.state;
        end
    else
        for i = 1:size(X,2)
            est(:,i) = X{i};
        end
    end
else
    if isstruct(X)
        for i = 1:size(X,2)
            est(:,i) = X(i).state;
        end
    else
        for i = 1:size(X,2)
            est(:,i) = X;
        end
    end
end

if plotOn3D
    figure;
    if size(est,2) <= 10
        p1 = plot3(est(1,:),est(3,:),est(2,:),'b+','markersize',20);
    else
        p1 = plot3(est(1,:),est(3,:),est(2,:),'b+');
    end
    hold on
    p2 = plot3(true(1,:),true(3,:),true(2,:),'r*','markersize',20);
    legend([p1, p2],'Estimate','GT')
    xlabel('x')
    zlabel('y')
    ylabel('z')
end

if plotOnImg
    FOVsize = [0 0; 1242, 375];
    
    P2path = strcat('../../data_tracking_calib/',set,'/','calib/',seq,'.txt');
    P2 = readCalibration(P2path,2);
    
    frameNbr = sprintf('%06d',k-1);
    imagePath = strcat('../../kittiTracking/',set,'/image_02/',seq,'/',frameNbr,'.png');
    
    % Read and plot image
    figure;
    img = imread(imagePath);
    imagesc(img);
    axis('image')
    hold on
    xlim([FOVsize(1,1) FOVsize(2,1)])
    ylim([FOVsize(1,2) FOVsize(2,2)])
    
    boxes = [GT{7}(ind), GT{8}(ind), GT{9}(ind)-GT{7}(ind) GT{10}(ind)-GT{8}(ind)];

    for i = 1:size(boxes,1)
        rectangle('Position',boxes(i,:),'EdgeColor','g','LineWidth',1)
    end
    
    for i = 1:size(est,2)
        tmp = P2*[est(1:3,i); 1];
        tmp = tmp(1:2)/tmp(3);
        box = [tmp(1)-est(end-2,i)/2, tmp(2)-est(end-1,i)/2, est(end-2,i), est(end-1,i)];
        rectangle('Position',box,'EdgeColor','r','LineWidth',1,'LineStyle','--')
        text(box(1), box(2), num2str(est(end,i)),'Fontsize',18,'Color','red')
    end
end