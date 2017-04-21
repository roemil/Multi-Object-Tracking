% set = 'training';
% sequence = '0000';
% datapath = strcat('../data/tracking/',set,'/',sequence,'/');
% filenameDet = [datapath,'inferResult.txt'];
% formatSpec = '%f%f%f%f%f%f%f%f%f';
% f = fopen(filenameDet);
% detections = textscan(f,formatSpec);
% fclose(f);
% base_dir = strcat('../../kittiTracking/data_tracking_oxts/',set);
% filenameIMU = [base_dir,sequence,'.txt'];
% 
% oxts = loadOxtsliteData(base_dir,1:1);
% 
% % transform to poses
% pose = convertOxtsToPose(oxts);
% cx = cell(1,1);
% cy = cell(1,1);
% %run_demoVehiclePath(datapath)
% for i = 1 : size(pose,2)
%     for j = 1 : size(detections{5},1)
%         cx{i,j} = detections{5}(j);
%         cy{i,j} = detections{6}(j);
%         position{i,j} = pose{i}*[cx{i,j};cy{i,j};0;0];
%     end
% end
% %%
% figure(1)
% i = 1 : size(oxts{1},1);
% %for i = 1 : size(oxts{1},1)
%     %plot(position{1,1}(1),position{1,1}(2),'*');hold on
%     %plot(position{2,1}(1),position{2,1}(2),'r*')
%     subplot(2,1,1)
%     plot(i,oxts{1}(i,7),'r*');hold on;
%     subplot(2,1,2)
%     plot(i,oxts{1}(i,8),'b*');hold on;
% %end
% figure(2)
%     subplot(2,1,1)
%     plot(i,oxts{1}(i,9),'r*');hold on;
%     subplot(2,1,2)
%     plot(i,oxts{1}(i,10),'b*');hold on;
% figure(3)
%     subplot(2,1,1)
%     plot(i,oxts{1}(i,12),'r*');hold on;
%     subplot(2,1,2)
%     plot(i,oxts{1}(i,13),'b*');hold on;
% figure(4)
% subplot(2,1,1)
% plot(i,oxts{1}(i,15),'r*');hold on;
% subplot(2,1,2)
% plot(i,oxts{1}(i,16),'b*');hold on;

%% KALMAN TEST

set = 'training';
sequence = '0000';
datapath = strcat('../data/tracking/',set,'/',sequence,'/');
filenameDet = [datapath,'inferResult.txt'];
formatSpec = '%f%f%f%f%f%f%f%f%f';
f = fopen(filenameDet);
detections = textscan(f,formatSpec);
fclose(f);

ind = 1;
cx = [];
cy = [];
for i = 2 : size(detections{1},1)
    if((detections{4}(i) == 1))% && (detections{5}(i)-detections{5}(i-1)) < 100)
        if(i > 100 && i < 115)
            cx(ind) = detections{5}(i);
            cy(ind) = detections{6}(i);
            ind = ind + 1;
        end
    end
end
% ind = 1;
% oldFrame = detections{1}(1);
% cx2 = [];
% cy2 = [];
% for i = 2 : length(cx)
%     if(cx(i) - cx(i-1) < 10)
%         cx2(ind) = cx(i);
%         cy2(ind) = cy(i);
%         ind = ind + 1;
%     end
% end
% cx = cx2;
% cy = cy2;
T = 0.1;
sigmaQ = 1;
H = generateMeasurementModel([],'linear');
[F, Q] = generateMotionModel(sigmaQ, T, 'cv');
Xupd = [0;0;0;0];
P = 0.3*eye(4);
R = 0.01*eye(2);
for i = 2 : length(cx)
    [Xpred(:,i),P] = KFPred(Xupd(:,i-1),F, P, Q);
    [Xupd(:,i),P,S] = KFUpd(Xpred(:,i),H, P, R, [cx(i); cy(i)]);
end

%%
t = 1:length(Xupd);
figure;
for t = 1 : length(Xpred)
    t
    h1 = plot(Xupd(1,t),Xupd(2,t),'r*');hold on;
    h2 = plot(cx(t),cy(t),'k*');
    pause(1)
    xlabel('x')
    ylabel('y')
    if t == 1
        legend('est','gt')
    end
    delete(h1);
    delete(h2);
    xlim([0 1000])
    ylim([100 800])
end

%%
%%%%%%%%%%
set = 'training';
sequence = '0000';
datapath = strcat('../data/tracking/',set,'/',sequence,'/');
filenameDet = [datapath,'inferResult.txt'];
formatSpec = '%f%f%f%f%f%f%f%f%f';
f = fopen(filenameDet);
detections = textscan(f,formatSpec);
fclose(f);
base_dir = strcat('../../kittiTracking/data_tracking_oxts/',set);
filenameIMU = [base_dir,sequence,'.txt'];

oxts = loadOxtsliteData(base_dir,1:1);

run_demoVehiclePath(base_dir)