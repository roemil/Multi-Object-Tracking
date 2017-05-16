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
    cla(fig)
    frameNbr = sprintf('%06d',k-1);
    plotDetectionsGT(set, sequence, frameNbr, Xest{k}, FOVsize, Z{k},nbrPosStates)
    title(['k = ', num2str(k)])
    %pause(0.1)
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
