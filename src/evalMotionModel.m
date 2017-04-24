set = 'training';
sequence = '0000';
datapath = strcat('../../kittiTracking/',set,'/','label_02/',sequence);
filename = [datapath,'.txt'];
formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
f = fopen(filename);
GT = textscan(f,formatSpec);
fclose(f);

P2 =[7.215377e+02 0.000000e+00 6.095593e+02 4.485728e+01;
    0.000000e+00 7.215377e+02 1.728540e+02 2.163791e-01; 
    0.000000e+00 0.000000e+00 1.000000e+00 2.745884e-03];

R = [9.999758e-01 -5.267463e-03 -4.552439e-03 0;
    5.251945e-03 9.999804e-01 -3.413835e-03 0;
    4.570332e-03 3.389843e-03 9.999838e-01 0;
    0 0 0 1];

ind = 1;
cx = [];
cy = [];

for i = 2 : size(GT{2},1)
    if((GT{2}(i) == 0))% && (detections{5}(i)-detections{5}(i-1)) < 100)
        %if(i > 100 && i < 115)
            cx(ind) = mean([GT{7}(i),GT{9}(i)]);
            cy(ind) = mean([GT{8}(i),GT{10}(i)]);
            ind = ind + 1;
        %end
    end
end

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
    h1 = plot(Xupd(1,t),Xupd(2,t),'r*');hold on;
    if(t>1)
        h4 = plot(Xupd(1,t-1),Xupd(2,t-1),'r+');hold on;
    end
    h2 = plot(cx(t),cy(t),'k*');
    h3 = plot(Xpred(1,t),Xpred(2,t),'g*');hold on;
    %pause(1.5)
    xlabel('x')
    ylabel('y')
    if t == 1
        legend('est','gt','pred')
    end
    waitforbuttonpress
    delete(h1);
    delete(h2);
    delete(h3);
    if(t>1)
        delete(h4);
    end
    xlim([300 400])
    ylim([200 400])
    
end