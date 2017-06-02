%% Plot estimates Img-plane

plotConf = false;
step = true;
auto = true;
global k
labels = [];
a = [];

%seq = '0000';
%meas = 'GT'; %% GT or CNN
%attempt = '2';
%path = strcat('/MAT-files/Jsim',meas,'_Tr',seq,'_',attempt,'/img/');

fig = figure('units','normalized','position',[.05 .05 .9 .9]);
hold on
subplot('position', [0.02 0 0.98 1])
for k = 1:size(Xest,2)
    frameNbr = sprintf('%06d',k-1);
    if strcmp(mode,'GTnonlinear') && ~simMeas
        if k > 1
            cla(a)
        end
        a = subplot(2,1,1);
        plotImgEstGT(sequence,set,k,Xest{k});
    elseif strcmp(mode,'CNNnonlinear') || simMeas
        if k > 1
            cla(a)
        end
        a = subplot(2,1,1); 
        plotImgEst(sequence,set,k,Xest{k},Z{k})
    end
    title(['k = ', num2str(k)])
    
    b = subplot(2,1,2);
    if k > 1
        cla(b)
    end
    labels = plotBirdsEye(sequence,set,Xest,Pest,step,auto,labels,plotConf);
    pause(0.1)
    print(fig,['img',num2str(k)],'-djpeg')
end

outputVideo = VideoWriter('video1.avi');
outputVideo.FrameRate = 10;
open(outputVideo)

for ii = 1:size(Xest,2)
   img = imread(['img',num2str(ii),'.jpg']);
   writeVideo(outputVideo,img)
   delete(['img',num2str(ii),'.jpg']);
end
close(outputVideo)
disp('Video complete')
close all;