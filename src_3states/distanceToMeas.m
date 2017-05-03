function distance = distanceToMeas(X,Z,seq,set,k)

datapath = strcat('../../kittiTracking/',set,'/','label_02/',seq);
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);

ind = find(GT{1} == k-1 & GT{2} ~= -1);

for i = 1:size(ind,1)
    cx = mean([GT{7}(ind(i)),GT{9}(ind(i))]);
    cy = mean([GT{8}(ind(i)),GT{10}(ind(i))]);
    pix = [cx, cy]';
    if sum(pix == Z) == 2
        dx = GT{14}(ind(i))-X(1);
        dy = (GT{15}(ind(i))-GT{11}(ind(i))/2)-X(2);
        dz = GT{16}(ind(i))-X(3);
        distance = [abs(dx), abs(dy), abs(dz), sqrt(dx^2+dy^2+dz^2)];
    end
end
        