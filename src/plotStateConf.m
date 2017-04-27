% Function to plot and image with its corresponding detections
%
% Input:    set:        Either training or testing
%           sequence:   Which sequence in the set, e.g. 0000
%           frameNbr:   The frame number in the sequence, e.g. 000000
%           Xest:       Estimate in one time instance.
%                       [x,y,vx,vy,width,height]^T
%

function plotStateConf(set, sequence, frameNbr, X, P, FOVsize, Z)

% Path for image
imagePath = strcat('../../kittiTracking/',set,'/image_02/',sequence,'/',frameNbr,'.png');

% Read and plot image
img = imread(imagePath);
%figure;
imagesc(img);
axis('image')
hold on
xlim([FOVsize(1,1) FOVsize(2,1)])
ylim([FOVsize(1,2) FOVsize(2,2)])

n = 100;
phi = linspace(0,2*pi,n);


for i = 1:size(X,2)
    % If dots wanted, uncomment below
    plot(X{i}(1), X{i}(2), '*r')
    text(X{i}(1), X{i}(2), num2str(X{i}(end)),'Fontsize',18,'Color','red')
    
    % If boxes wanted, uncomment below
    %estBox = [X{i}(1)-X{i}(end-2)/2, X{i}(2)-X{i}(end-1)/2, X{i}(end-2), X{i}(end-1)];
    %rectangle('Position',estBox,'EdgeColor','r','LineWidth',1,'LineStyle','--')
    %text(estBox(1), estBox(2), num2str(X{i}(end)),'Fontsize',18,'Color','red')

    x = repmat(X{i}(1:2),1,n)+3*sqrtm(P{i}(1:2,1:2))*[cos(phi);sin(phi)];
    plot(x(1,:),x(2,:),'-y','LineWidth',1)
end

for z = 1:size(Z,2)
    plot(Z(1,z),Z(2,z),'g*')
end



