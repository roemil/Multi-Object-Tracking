function writeCNNtofile(Xest, filename)
global pose, global angles, global H, 
%formatSpec = '%06d %d %s %d %d %d %f %f %f %f %d %d %d %f %f %f %d %d \n';
formatSpec = '%06d %d %s %d %d %d %06f %06f %06f %06f %d %d %d %06f %06f %06f %d %d\n';
label = 0;
%fid_org = fopen([filename_org,'.txt'],'r');
%formatSpec = '%f%f%f%f%f%f%f%f%f%f';
%detections = textscan(fid_org,formatSpec);
fid = fopen([filename,'.txt'],'wt+');
for i = 1 : size(Xest,2)
%    frame = sprintf('%06d',i-1);
%    fid = fopen([filename,'.txt'],'wt+');
    for j = 1 : size(Xest{i},2)
%        score = detections{9}(i+j-1);
        pos = [Xest{i}(1,j), Xest{i}(2,j), Xest{i}(3,j)];
        bbox = [Xest{i}(4,j),Xest{i}(5,j)];
        if(Xest{i}(6,j) == 1)
            type = 'Car';
            %formatSpec = '%06d %d %s %d %d %d %06f %06f %06f %06f %d %d %d %06f %06f %06f %d %d\n';
        elseif(Xest{i}(6,j) == 2)
            type = 'Pedestrian';
            %formatSpec = '%06d %d %s %d %d %d %06f %06f %06f %06f %d %d %d %06f %06f %06f %d %d\n';
        elseif(Xest{i}(6,j) == 3)
            type = 'Cyclist';
            %formatSpec = '%06d %d %s %d %d %d %06f %06f %06f %06f %d %d %d %06f %06f %06f %d %d\n';
        end
        x1 = pos(1) - bbox(1)*0.5;
        y1 = pos(2) - bbox(2)*0.5;
        x2 = x1 + bbox(1);
        y2 = y1 + bbox(2);
        %fprintf(fid, formatSpec,type,-1,-1,-10,x1,y1,x2,y2,-1,-1,-1,-1000,-1000,-1000,-10,score);
        fprintf(fid, formatSpec,i-1,label,type,-1,-1,-10,x1,y1,x2,y2,-1,-1,-1,-1000,-1000,-1000,-10,-1000);
        label = label + 1;
        % might not be correct data format
    end
end
fclose(fid);