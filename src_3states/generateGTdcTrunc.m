function ZGT = generateGTdc(set,sequence,datapath,nbrOfStates)
% set = 'training';
% sequence = '0000';
% datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);

P2 =[7.215377e+02 0.000000e+00 6.095593e+02 4.485728e+01;
    0.000000e+00 7.215377e+02 1.728540e+02 2.163791e-01; 
    0.000000e+00 0.000000e+00 1.000000e+00 2.745884e-03];

R = [9.999758e-01 -5.267463e-03 -4.552439e-03 0;
    5.251945e-03 9.999804e-01 -3.413835e-03 0;
    4.570332e-03 3.389843e-03 9.999838e-01 0;
    0 0 0 1];

%P2=[7.215377000000e+02, 0.000000000000e+00, 6.095593000000e+02, 4.485728000000e+01;
%0.000000000000e+00, 7.215377000000e+02, 1.728540000000e+02, 2.163791000000e-01;
%0.000000000000e+00, 0.000000000000e+00, 1.000000000000e+00, 2.745884000000e-03];
%R = [9.999239000000e-01, 9.837760000000e-03, -7.445048000000e-03, 0;
%-9.869795000000e-03, 9.999421000000e-01, -4.278459000000e-03, 0;
%7.402527000000e-03, 4.351614000000e-03, 9.999631000000e-01, 0;
%0                       0                   0               1];

% P = P2*R;
% Ry = @(x)[cos(GT{ryInd}(x)),  0, sin(GT{ryInd}(x));
%      0,               1,              0;
%      -sin(GT{ryInd}(x)), 0, cos(GT{ryInd}(x))];
ZGT = cell(1);
frameInd = 1;
trackID = 2;
xInd = 14;
yInd = 15;
zInd = 16;
%ryInd = 17;
%bbsize = [GT{9}(3) - GT{7}(3),GT{10}(3)-GT{8}(3)];

if(nbrOfStates == 4)

    cx(1) = mean([GT{7}(3),GT{9}(3)]);
    cy(1) = mean([GT{8}(3),GT{10}(3)]);
    pxCoords = [cx,cy];
    ZGT{1}(:,1) = [pxCoords(1);pxCoords(2);bbsize(1);bbsize(2);GT{trackID}(3)];
    count = 1;
    oldFrame = GT{1}(3)+1;
    for i = 4 : size(GT{1},1)
        frame = GT{1}(i)+1;
        if(frame == oldFrame && (GT{trackID}(i) == -1) && (~strcmp(GT{3}(i),'Tram')) && (~strcmp(GT{3}(i),'Truck')) && (~strcmp(GT{3}(i),'Misc ')))
            %R1(1:3,1:3) = Ry(i);
            %P = P2*R1;
            %pxCoords = camera2pixelcoords([GT{xInd}(i);GT{yInd}(i);GT{zInd}(i)],P);
            cx = mean([GT{7}(i),GT{9}(i)]);
            cy = mean([GT{8}(i),GT{10}(i)]);
            pxCoords = [cx,cy];
            bbsize = [GT{9}(i) - GT{7}(i),GT{10}(i)-GT{8}(i)];
            ZGT{frame}(:,count+1) = [pxCoords(1);pxCoords(2);bbsize(1);bbsize(2);GT{trackID}(i)]; % cx
            count = count + 1;
            oldFrame = frame;
        elseif(GT{trackID}(i) == -1 && (~strcmp(GT{3}(i),'Tram')) && (~strcmp(GT{3}(i),'Truck')) && (~strcmp(GT{3}(i),'Misc'))) % TODO: only difference is the count?
            %R1(1:3,1:3) = Ry(i);
            %P = P2*R1;
            %pxCoords = camera2pixelcoords([GT{xInd}(i);GT{yInd}(i);GT{zInd}(i)],P);
            cx = mean([GT{7}(i),GT{9}(i)]);
            cy = mean([GT{8}(i),GT{10}(i)]);
            cy = GT{10}(i);
            pxCoords = [cx,cy];
            bbsize = [GT{9}(i) - GT{7}(i),GT{10}(i)-GT{8}(i)];
            ZGT{frame}(:,1) = [pxCoords(1);pxCoords(2);bbsize(1);bbsize(2);GT{trackID}(i)]; % cx
            count = 1;
            oldFrame = frame;  
        end
    end
elseif(nbrOfStates == 6)
    map = generateHashmap('GTnonlinear');
    %ind = find(GT{2} == -1);
    %ind = ind(1);
    %cx(1) = mean([GT{7}(ind),GT{9}(ind)]);
    %cy(1) = mean([GT{8}(ind),GT{10}(ind)]);
    %pxCoords = [cx,cy];
    %bbsize = [GT{9}(ind) - GT{7}(ind),GT{10}(ind)-GT{8}(ind)];
    % This is [px py, z]??
    % ZGT{1}(:,1) = [pxCoords(1);pxCoords(2);GT{zInd}(3);bbsize(1);bbsize(2);GT{trackID}(3)]; % cx
    % This is [px py d]
    %d = sqrt(GT{14}(ind)^2+(GT{15}(ind)-GT{11}(ind)/2)^2+GT{16}(ind)^2);
    %oldFrame = GT{1}(ind)+1;
    %ZGT{oldFrame}(:,1) = [pxCoords(1);pxCoords(2);d;bbsize(1);bbsize(2);GT{trackID}(ind);map(cell2mat(GT{3}(ind)))]; % cx
    oldFrame = 1;
    count = 1;
    for i = 1 : size(GT{1},1)
        frame = GT{1}(i)+1;
        if frame ~= oldFrame 
            count = 1;
        end
        if(frame == oldFrame && (GT{trackID}(i) == -1) || (strcmp(GT{3}(i),'Tram')) || (strcmp(GT{3}(i),'Truck')) || (strcmp(GT{3}(i),'Misc')) || (strcmp(GT{3}(i),'Van')) || (GT{4}(i) ~= 0))
            %R1(1:3,1:3) = Ry(i);
            %P = P2*R1;
            %pxCoords = camera2pixelcoords([GT{xInd}(i);GT{yInd}(i);GT{zInd}(i)],P);
            cx = mean([GT{7}(i),GT{9}(i)]);
            cy = mean([GT{8}(i),GT{10}(i)]);
            pxCoords = [cx,cy];
            bbsize = [GT{9}(i) - GT{7}(i),GT{10}(i)-GT{8}(i)];
            %ZGT{frame}(:,count+1) = [pxCoords(1);pxCoords(2);GT{zInd}(i);bbsize(1);bbsize(2);GT{trackID}(i)]; % cx
            d = sqrt(GT{14}(i)^2+(GT{15}(i)-GT{11}(i)/2)^2+GT{16}(i)^2);
            ZGT{frame}(:,count) = [pxCoords(1);pxCoords(2);d;bbsize(1);bbsize(2);GT{trackID}(i);map(cell2mat(GT{3}(i)))]; % cx
            count = count + 1;
            oldFrame = frame;
        elseif(GT{trackID}(i) == -1 ||(strcmp(GT{3}(i),'Tram')) || (strcmp(GT{3}(i),'Truck')) || (strcmp(GT{3}(i),'Misc')) || (strcmp(GT{3}(i),'Van')) || (GT{4}(i) ~= 0)) % TODO: only difference is the count?
            %R1(1:3,1:3) = Ry(i);
            %P = P2*R1;
            %pxCoords = camera2pixelcoords([GT{xInd}(i);GT{yInd}(i);GT{zInd}(i)],P);
            count = 1;
            cx = mean([GT{7}(i),GT{9}(i)]);
            cy = mean([GT{8}(i),GT{10}(i)]);
            pxCoords = [cx,cy];
            bbsize = [GT{9}(i) - GT{7}(i),GT{10}(i)-GT{8}(i)];
            d = sqrt(GT{14}(i)^2+(GT{15}(i)-GT{11}(i)/2)^2+GT{16}(i)^2);
            ZGT{frame}(:,count) = [pxCoords(1);pxCoords(2);d;bbsize(1);bbsize(2);GT{trackID}(i);map(cell2mat(GT{3}(i)))]; % cx
            count = count+1;
            oldFrame = frame;
        %else
            %ZGT{frame} = [];
        end
    end
end