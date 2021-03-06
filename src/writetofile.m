function writetofile(Xest,mode,filename)
global pose, global angles, global H, 
fid = fopen(filename,'wt+');
%formatSpec = '%06d %d %s %d %d %d %f %f %f %f %d %d %d %f %f %f %d %d \n';
formatSpec = '%06d %d %s %d %d %d %06f %06f %06f %06f %d %d %d %06f %06f %06f %d %d\n';
for i = 1 : size(Xest,2)
    for j = 1 : size(Xest{i},2)
        if(~isempty(Xest{i}{j}))
            pos = Xest{i}{j}(1:2);
            bbox = [Xest{i}{j}(5),Xest{i}{j}(6)];
            if(strcmp(mode,'CNN')) || strcmp(mode,'CNNc')
                if(Xest{i}{j}(8) == 999)
                    continue;
                end
                if(Xest{i}{j}(8) == 1)
                    type = 'Car';
                    %formatSpec = '%06d %d %s %d %d %d %06f %06f %06f %06f %d %d %d %06f %06f %06f %d %d\n';
                elseif(Xest{i}{j}(8) == 2)
                    type = 'Pedestrian';
                    %formatSpec = '%06d %d %s %d %d %d %06f %06f %06f %06f %d %d %d %06f %06f %06f %d %d\n';
                elseif(Xest{i}{j}(8) == 3)
                    type = 'Cyclist';
                    %formatSpec = '%06d %d %s %d %d %d %06f %06f %06f %06f %d %d %d %06f %06f %06f %d %d\n';
                end
            elseif(strcmp(mode,'GT'))
                if(Xest{i}{j}(8) == 1)
                    type = 'Car';
                    formatSpec = '%06d %d %c%c%c %d %d %d %06f %06f %06f %06f %d %d %d %06f %06f %06f %d %d \n';
                elseif(Xest{i}{j}(8) == 2)
                    type = 'Van';
                    formatSpec = '%06d %d %c%c%c %d %d %d %06f %06f %06f %06f %d %d %d %06f %06f %06f %d %d \n';
                elseif(Xest{i}{j}(8) == 3)
                    type = 'Cyclist';
                    formatSpec = '%06d %d %c%c%c%c%c%c%c %d %d %d %06f %06f %06f %06f %d %d %d %06f %06f %06f %d %d \n';
                elseif(Xest{i}{j}(8) == 4)
                    type = 'Pedestrian';
                    formatSpec = '%06d %d %c%c%c%c%c%c%c%c%c%c %d %d %d %06f %06f %06f %06f %d %d %d %06f %06f %06f %d %d \n';
                end
            else
                disp('not implemented for linear case');
                break;
            end
            x1 = pos(1) - bbox(1)*0.5;
            y1 = pos(2) - bbox(2)*0.5;
            x2 = x1 + bbox(1);
            y2 = y1 + bbox(2);
             %fprintf(fid, formatSpec,i-1,Xest{i}{j}(9),type,-1,-1,-10,x1,y1,x2,y2,-1,-1,-1,Xest{i}{j}(1),Xest{i}{j}(2),Xest{i}{j}(3),-10,-1000);
             fprintf(fid, formatSpec,i-1,Xest{i}{j}(7),type,-1,-1,-10,x1,y1,x2,y2,-1,-1,-1,-1000,-1000,-1000,-10,-1000);
            % might not be correct data format
        end
    end
end
fclose(fid);