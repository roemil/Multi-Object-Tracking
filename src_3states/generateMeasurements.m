function Z = generateMeasurements(set,sequence,datapath,mode)
global nbrOfStates;
    if(strcmp(mode,'linear'))
        filename = [datapath,'inferResult.txt'];
        formatSpec = '%f%f%f%f%f%f%f%f%f';
        f = fopen(filename);
        detections = textscan(f,formatSpec);
        fclose(f);
    end
Z = cell(1);
if(strcmp(mode,'linear'))
    if(nbrOfStates == 4)
        oldFrame = detections{1}(1)+1;
        count = 1;
            Z{1}(:,1) = [detections{5}(1);detections{6}(1);detections{7}(1);detections{8}(1);detections{9}(1)]; % cx
            for i = 2 : size(detections{1},1)
                frame = detections{1}(i)+1;
                if(frame == oldFrame)
                    Z{frame}(:,count+1) = [detections{5}(i);detections{6}(i);detections{7}(i);detections{8}(i);detections{9}(i)]; % cx
                    count = count + 1;
                    oldFrame = frame;
                else
                    Z{frame}(:,1) = [detections{5}(i);detections{6}(i);detections{7}(i);detections{8}(i);detections{9}(i)]; % cx
                    count = 1;
                    oldFrame = frame;  
                end
            end
        elseif(strcmp(mode,'nonlinear'))
            oldFrame = detections{1}(1)+1;
            count = 1;
            Z{1}(:,1) = [detections{5}(1);detections{6}(1);detections{7}(1);detections{8}(1);detections{9}(1);detections{end}(1)]; % cx
            for i = 2 : size(detections{1},1)
                frame = detections{1}(i)+1;
                if(frame == oldFrame)
                    Z{frame}(:,count+1) = [detections{5}(i);detections{6}(i);detections{7}(i);detections{8}(i);detections{9}(i);detections{end}(i)]; % cx
                    count = count + 1;
                    oldFrame = frame;
                else
                    Z{frame}(:,1) = [detections{5}(i);detections{6}(i);detections{7}(i);detections{8}(i);detections{9}(i);detections{end}(i)]; % cx
                    count = 1;
                    oldFrame = frame;  
                end
            end
    elseif(nbrOfStates == 6)
        oldFrame = detections{1}(1)+1;
        count = 1;
        Z{1}(:,1) = [detections{5}(1);detections{6}(1);detections{end}(1);detections{7}(1);detections{8}(1);detections{9}(1)]; % cx
        for i = 2 : size(detections{1},1)
            frame = detections{1}(i)+1;
            if(frame == oldFrame)
                Z{frame}(:,count+1) = [detections{5}(i);detections{6}(i);detections{end}(i);detections{7}(i);detections{8}(i);detections{9}(i)]; % cx
                count = count + 1;
                oldFrame = frame;
            else
                Z{frame}(:,1) = [detections{5}(i);detections{6}(i);detections{end}(i);detections{7}(i);detections{8}(i);detections{9}(i)]; % cx
                count = 1;
                oldFrame = frame;  
            end
        end
    end
elseif(strcmp(mode,'GT'))
    Z = generateGT(set,sequence,datapath,nbrOfStates);
end

end