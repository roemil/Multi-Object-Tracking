%% Plot estimates Img-plane

plotConf = true;
step = true;
auto = true;
global k
labels = [];
a = [];

global TcamToVelo, global T20, global TveloToImu, global angles, global pose
Z3D = cell(1,size(Z,2));
for k = 1:size(Z,2)
    if ~isempty(Z{k})
        heading = angles{k}.heading-angles{1}.heading;
        iInd = 1;
        for i = 1:size(Z{k},2)
            [zApprox, ~] = pix2coordtest(Z{k}(1:2,i),Z{k}(3,i));
            Z3D{k}(1:3,iInd) = pixel2cameracoords(Z{k}(1:2,i),zApprox);
            Z3D{k}(1:3,iInd) = TveloToImu(1:3,:)*(TcamToVelo*(T20*[Z3D{k}(1:3,iInd);1]));
            Z3D{k}(1:2,iInd) = [cos(heading), -sin(heading); sin(heading) cos(heading)]*Z3D{k}(1:2,iInd);
            Z3D{k}(1:3,iInd) = Z3D{k}(1:3,iInd) + pose{k}(1:3,4);
            iInd = iInd+1;
        end
    end
end

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
    labels = plotBirdsEye(sequence,set,Xest,Pest,step,auto,labels,plotConf,Z3D);
    pause(1)
    %print(fig,['img',num2str(k)],'-djpeg')
end
%%
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