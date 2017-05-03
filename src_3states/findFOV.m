% Find min and max in each 3d direction

limX = [1e6 0];
limY = [1e6 0];
limZ = [1e6 0];

set = 'training';


for k = 0:20
    seq = sprintf('%04d',k);
    datapath = strcat('../../kittiTracking/',set,'/','label_02/',seq);
    filename = [datapath,'.txt'];
    formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
    f = fopen(filename);
    GT = textscan(f,formatSpec);
    fclose(f);
    for i = 1:size(GT{1},1)
        if GT{2}(i) ~= -1
            limX(1) = min(limX(1), GT{14}(i));
            limX(2) = max(limX(2), GT{14}(i));
            
            limY(1) = min(limY(1), GT{15}(i)-GT{11}(i)/2);
            limY(2) = max(limY(2), GT{15}(i)-GT{11}(i)/2);
            
            limZ(1) = min(limZ(1), GT{16}(i));
            limZ(2) = max(limZ(2), GT{16}(i));
        end
    end
end