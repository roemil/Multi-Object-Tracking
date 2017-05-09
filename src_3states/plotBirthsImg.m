function nbrNotInFov = plotBirthsImg(seq,set,X)

global FOVsize
global H3dFunc
global H3dTo2d
global H
global egoMotionOn
global k
global pose

datapath = strcat('../../kittiTracking/',set,'/','label_02/',seq);
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);

frameNbr = sprintf('%06d',k-1);
imagePath = strcat('../../kittiTracking/',set,'/image_02/',seq,'/',frameNbr,'.png');

% Read and plot image
%figure;
img = imread(imagePath);
imagesc(img);
axis('image')
hold on
xlim([FOVsize(1,1) FOVsize(2,1)])
ylim([FOVsize(1,2) FOVsize(2,2)])

ind = find(GT{1} == k-1 & GT{2} ~= -1);

cx(1:size(ind,1)) = mean([GT{7}(ind),GT{9}(ind)],2);
cy(1:size(ind,1)) = mean([GT{8}(ind),GT{10}(ind)],2);

nbrNotInFov = zeros(2,1);
plot(cx,cy,'g*')
for i = 1:size(X,2)
    tmp = H(X(i).state,pose{k}(1:3,4));
    if tmp(1) > FOVsize(2,1) || tmp(1) < FOVsize(1,1)
        nbrNotInFov(1,1) = nbrNotInFov(1,1)+1;
    end
    if tmp(2) > FOVsize(2,2) || tmp(2) < FOVsize(1,2)
        nbrNotInFov(2,1) = nbrNotInFov(2,1)+1;
    end
    plot(tmp(1),tmp(2),'r+')
end
