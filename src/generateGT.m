set = 'training';
sequence = '0000';
datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
filename = [datapath,'.txt'];
formatSpec = '%u%d%s%d%d%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);

P2=[7.215377000000e+02, 0.000000000000e+00, 6.095593000000e+02, 4.485728000000e+01;
0.000000000000e+00, 7.215377000000e+02, 1.728540000000e+02, 2.163791000000e-01;
0.000000000000e+00, 0.000000000000e+00, 1.000000000000e+00, 2.745884000000e-03];
R = [9.999239000000e-01, 9.837760000000e-03, -7.445048000000e-03, 0;
-9.869795000000e-03, 9.999421000000e-01, -4.278459000000e-03, 0;
7.402527000000e-03, 4.351614000000e-03, 9.999631000000e-01, 0;
0                       0                   0               1];

P = P2*R;

Z = cell(1);
frameInd = 1;
classInd = 2;
xInd = 14;
yInd = 15;
zInd = 16;
bbsize = [GT{7}(3) - GT{9}(3),GT{8}(3)-GT{10}(3)];
pxCoords = camera2pixelcoords([GT{xInd}(3);GT{yInd}(3);GT{zInd}(3)],P);
Z{1}(:,1) = [pxCoords(1);pxCoords(2);bbsize(1);bbsize(2)]; % cx
count = 0;
oldFrame = GT{1}(3)+1;
for i = 3 : size(GT{1},1)
    frame = GT{1}(i)+1;
    if(frame == oldFrame && (GT{classInd}(i) ~= -1))
        pxCoords = camera2pixelcoords([GT{xInd}(i);GT{yInd}(1);GT{zInd}(i)],P);
        bbsize = [GT{7}(i) - GT{9}(i),GT{8}(i)-GT{10}(i)];
        Z{frame}(:,count+1) = [pxCoords(1);pxCoords(2);bbsize(1);bbsize(2)]; % cx
        count = count + 1;
        oldFrame = frame;
    else
        pxCoords = camera2pixelcoords([GT{xInd}(i);GT{yInd}(1);GT{zInd}(i)],P);
        bbsize = [GT{7}(i) - GT{9}(i),GT{8}(i)-GT{10}(i)];
        Z{frame}(:,1) = [pxCoords(1);pxCoords(2);bbsize(1);bbsize(2)]; % cx
        count = 1;
        oldFrame = frame;  
    end
end