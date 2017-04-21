seq = '0000';
path = ['../../training/label_02/',seq,'.txt'];
fid = fopen(path);
labels = textscan(fid,'%d%d%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f');
fclose(fid);

P2=[7.215377000000e+02, 0.000000000000e+00, 6.095593000000e+02, 4.485728000000e+01;
    0.000000000000e+00, 7.215377000000e+02, 1.728540000000e+02, 2.163791000000e-01;
    0.000000000000e+00, 0.000000000000e+00, 1.000000000000e+00, 2.745884000000e-03];
R = [9.999239000000e-01, 9.837760000000e-03, -7.445048000000e-03, 0;
    -9.869795000000e-03, 9.999421000000e-01, -4.278459000000e-03, 0;
    7.402527000000e-03, 4.351614000000e-03, 9.999631000000e-01, 0;
    0                       0                   0               1];
y_pixel = [376.567; 230.234;1];
pts_3D = [labels{14}(8),labels{15}(8),labels{16}(8)]';
P = P2*R;
pts_2Drect = projectToImage(pts_3D, P2)
pts_2D = projectToImage(pts_3D, P)
bx = -P2(1,4)/P2(1,1);
t = [bx;0;0];
R1 = R(1:3,1:3);
K = P2(1:3,1:3);
Ptest = K*[R1,-R1*t];
x = camera2pixelcoords(pts_3D,Ptest);
pix_size = 4.65*1e-6;


%%
pix_size = 4.65*1e-6;
pts_2D2 = P2 * R * [pts_3D; ones(1,size(pts_3D,2))];
pts_2D2(1,:) = pts_2D2(1,:)./pts_2D2(3,:);
pts_2D2(2,:) = pts_2D2(2,:)./pts_2D2(3,:);
pts_2D2(3,:) = [];
pts_2D2 = [pts_2D2;1];

K = P2(1:3,1:3);
P = P2*R;
Kinv = [1 0 -P(1,3);0 1 -P(2,3);0 0 P(1,1)/pix_size]
%K = P(1:3,1:3);
dist = 13.5;
%angle=tan(pts_2D(2)/pts_2D(1));
angle = asin(pts_2D2(1)/dist);
%angle = 0;
%%
X = K\[pts_2D;1]
X2 = Kinv * pts_2D2

A = K*pts_3D;
A(1) = A(1)/A(3);
A(2) = A(2)/A(3);