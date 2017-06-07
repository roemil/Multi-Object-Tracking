imgpath = strcat('../../kittiTracking/','training','/','image_02/','0020/');

d = [];
frame1 = sprintf('%06d',0);
imgfilename1 = [imgpath,frame1,'.png'];
bbox1 = [Z{1}(1,1)-Z{1}(4,1)*0.5,Z{1}(2,1)-Z{1}(5,1)*0.5,Z{1}(4,1),Z{1}(5,1)];
h1 = colorhist(imread(imgfilename1), bbox1);
for i = 1 : size(Z,2)
    frame = sprintf('%06d',i-1);
    imgfilename = [imgpath,frame,'.png'];
    for j = 1 : size(Z{i},2)
        bbox = [Z{i}(1,j)-Z{i}(4,j)*0.5,Z{i}(2,j)-Z{i}(5,j)*0.5,Z{i}(4,j),Z{i}(5,j)];
        h = colorhist(imread(imgfilename), bbox);
        d = [d, chisdist(h1,h)];
    end
end