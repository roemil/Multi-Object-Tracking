function distance = distanceToMeas(X,Z,seq,set,k)

datapath = strcat('../../kittiTracking/',set,'/','label_02/',seq);
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);

ind = find(GT{1} == k);

for i = 1:size(ind,1)
    cx = mean([GT{7}(i),GT{9}(i)]);
    cy = mean([GT{8}(i),GT{10}(i)]);
    pix = [cx, cy]';
    if sum(pix == Z) == 2
        dx = GT{14}(i)-X(1);
        dy = GT{15}(i)-X(2);
        dz = GT{16}(i)-X(3);
        distance = sqrt(dx^2+dy^2+dz^2);
    end
end
        