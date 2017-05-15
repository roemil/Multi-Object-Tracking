function writetofile(Xest,filename)

fid = fopen(filename,'w');
formatSpec = '%f %f %f %f %f\n';
for i = 1 : size(Xest,2)
    for j = 1 : size(Xest{i},2)
        fprintf(fid, formatSpec,[Xest{i}{j}(1),Xest{i}{j}(2),Xest{i}{j}(7)...
            ,Xest{i}{j}(8), Xest{i}{j}(9)]);
        % might not be correct data format
    end
end
fclose(fid);