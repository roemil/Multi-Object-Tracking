global RimuToVelo
RimuToVelo = [9.999976e-01 7.553071e-04 -2.035826e-03;
    -7.854027e-04 9.998898e-01 -1.482298e-02;
    2.024406e-03 1.482454e-02 9.998881e-01];
global TimuToVelo
TimuToVelo = [-8.086759e-01 3.195559e-01 -7.997231e-01]';

% TODO: use \ instead? R\1'??
global RveloToImu
RveloToImu = inv(RimuToVelo);
global TveloToImu
TveloToImu = -TimuToVelo;

global RveloToCam
RveloToCam = [6.927964e-03 -9.999722e-01 -2.757829e-03;
    -1.162982e-03 2.749836e-03 -9.999955e-01;
    9.999753e-01 6.931141e-03 -1.143899e-03];
global TveloToCam
TveloToCam = [-2.457729e-02 -6.127237e-02 -3.321029e-01]';

global RcamToVelo
RcamToVelo = inv(RveloToCam);
global TcamToVelo
TcamToVelo = -TveloToCam;

global R02
R02 = [9.999838e-01 -5.012736e-03 -2.710741e-03;
    5.002007e-03 9.999797e-01 -3.950381e-03;
    2.730489e-03 3.936758e-03 9.999885e-01];
global T02
T02 = [5.989688e-02 -1.367835e-03 4.637624e-03]';

global R20
R20 = inv(R02);
global T20
T20 = -T02;

set = 'training';
sequence = '0000';
P2path = strcat('../../data_tracking_calib/',set,'/','calib/',sequence,'.txt');

P2 = readCalibration(P2path,2);

%xt = [6.534793079224563
%   2.141342753362427
%  -0.127488531480550];
xt = RcamToVelo*[-4.552284000000000   0.858523000000000  13.410494999999999]'+TcamToVelo;
px = 1.0e+02 * [3.759854990000000;
   2.270624755000000];

R0_rect = zeros(4,4);
% From calib
R0_rect = [9.999239000000e-01 9.837760000000e-03 -7.445048000000e-03;
    -9.869795000000e-03 9.999421000000e-01 -4.278459000000e-03;
    7.402527000000e-03 4.351614000000e-03 9.999631000000e-01];

% From 0000
R0_rect(1:3,1:3) = [9.999128e-01 1.009263e-02 -8.511932e-03;
    -1.012729e-02 9.999406e-01 -4.037671e-03;
    8.470675e-03 4.123522e-03 9.999556e-01];
R0_rect(4,4) = 1;

Tr_velo_to_cam = [7.533745000000e-03 -9.999714000000e-01 -6.166020000000e-04 -4.069766000000e-03;
    1.480249000000e-02 7.280733000000e-04 -9.998902000000e-01 -7.631618000000e-02;
    9.998621000000e-01 7.523790000000e-03 1.480755000000e-02 -2.717806000000e-01];
Tr_velo_to_cam(4,:) = [0 0 0 1];

R_rect02 = [9.998691e-01 1.512763e-02 -5.741851e-03;
    -1.512861e-02 9.998855e-01 -1.287536e-04;
    5.739247e-03 2.156030e-04 9.999835e-01];
R_rect02(4,:) = [0 0 1];
%R0_rect = R_rect02;
% According to read me
xtpixP2 = P2 * R0_rect * Tr_velo_to_cam * [xt; 1];
xtpixP2 = xtpixP2(1:2)/xtpixP2(3)

% According to papper
P2rect = [7.070493e+02 0.000000e+00 6.040814e+02 4.575831e+01;
    0.000000e+00 7.070493e+02 1.805066e+02 -3.454157e-01;
    0.000000e+00 0.000000e+00 1.000000e+00 4.981016e-03];

% From calib
R0_rect = [9.999239000000e-01 9.837760000000e-03 -7.445048000000e-03;
    -9.869795000000e-03 9.999421000000e-01 -4.278459000000e-03;
    7.402527000000e-03 4.351614000000e-03 9.999631000000e-01];

% From 0000
R0_rect = [9.999128e-01 1.009263e-02 -8.511932e-03;
    -1.012729e-02 9.999406e-01 -4.037671e-03;
    8.470675e-03 4.123522e-03 9.999556e-01];
R0_rect(4,:) = [0 0 1];

T = [RveloToCam TveloToCam;0 0 0 1];
R0_rect2 = zeros(4,4);
R0_rect2(1:3,1:3) = R0_rect(1:3,1:3);
R0_rect2(4,4) = 1;
R0_rect = R_rect02;
%R0_rect2(1:3,1:3) = R_rect02(1:3,1:3);
xtpixP2rect = P2rect*R0_rect*(RveloToCam*xt + TveloToCam);
%xtpixP2rect = P2rect * R0_rect * Tr_velo_to_cam * [xt; 1];
xtpixP2rect = xtpixP2rect(1:2)/xtpixP2rect(3)

xtpixP2rect2 = P2rect*R0_rect2*T*[xt;1];
xtpixP2rect2 = xtpixP2rect2(1:2)/xtpixP2rect2(3)
%%

datapath = strcat('../../kittiTracking/','training','/','label_02/','0000');
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);
k = 1;
frameNbr = sprintf('%06d',k-1);
imagePath = strcat('../../kittiTracking/','training','/image_02/','0000','/',frameNbr,'.png');

% Read and plot image
%figure;
img = imread(imagePath);
imagesc(img);
axis('image')
hold on
xlim([FOVsize(1,1) FOVsize(2,1)])
ylim([FOVsize(1,2) FOVsize(2,2)])

ind = find(GT{1} == k-1 & GT{2} ~= -1);
boxes = [GT{7}(ind), GT{8}(ind), GT{9}(ind)-GT{7}(ind) GT{10}(ind)-GT{8}(ind)];

cx(1:3) = mean([GT{7}(ind),GT{9}(ind)],2);
cy(1:3) = mean([GT{8}(ind),GT{10}(ind)],2);

%(GT{15}(ind)-GT{11}(ind)/2)
x = [GT{14}(ind)';
        (GT{15}(ind)-GT{11}(ind)/2)';
        GT{16}(ind)'];

global H3dFunc
P2rect = [7.070493e+02 0.000000e+00 6.040814e+02 4.575831e+01;
    0.000000e+00 7.070493e+02 1.805066e+02 -3.454157e-01;
    0.000000e+00 0.000000e+00 1.000000e+00 4.981016e-03];
% from 0000
R0_rect = zeros(4,4);
R0_rect(1:3,1:3) = [9.999128e-01 1.009263e-02 -8.511932e-03;
    -1.012729e-02 9.999406e-01 -4.037671e-03;
    8.470675e-03 4.123522e-03 9.999556e-01];
R0_rect(4,4) = 1;

%From calib
R0_rect2 = [9.999239000000e-01 9.837760000000e-03 -7.445048000000e-03;
    -9.869795000000e-03 9.999421000000e-01 -4.278459000000e-03;
    7.402527000000e-03 4.351614000000e-03 9.999631000000e-01];
R0_rect2(1:3,1:3) = [9.999128e-01 1.009263e-02 -8.511932e-03;
    -1.012729e-02 9.999406e-01 -4.037671e-03;
    8.470675e-03 4.123522e-03 9.999556e-01];
R0_rect2(4,4) = 1;

P2path = strcat('../../data_tracking_calib/',set,'/','calib/',sequence,'.txt');

P2 = readCalibration(P2path,2);

for i = 1:size(boxes,1)
    rectangle('Position',boxes(i,:),'EdgeColor','g','LineWidth',1)
    plot(cx(i),cy(i),'g*')
    tmp = H3dFunc([x(:,i); zeros(5,1)]);
    tmp2 = P2rect*[x(:,i);1];
    tmp3 = P2*R0_rect*[x(:,i);1]; % ord P2rect
    tmp4 = P2rect*R0_rect2*[x(:,i);1];
    plot(tmp(1),tmp(2),'r*')
    plot(tmp2(1)/tmp2(3),tmp2(2)/tmp2(3),'b*')
    plot(tmp3(1)/tmp3(3),tmp3(2)/tmp3(3),'co','linewidth',1)
    plot(tmp4(1)/tmp4(3),tmp4(2)/tmp4(3),'y*')
end


    
    