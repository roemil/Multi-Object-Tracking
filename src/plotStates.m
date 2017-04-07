function plotStates(Z, Xtrue, Xest, Xpred)

% Find shortest variable
N = min(size(Z,2), size(Xtrue,2), size(Xest,2));

for k = 2:N
    dist = zeros(size(Xest{k},2), size(Xtrue{k},2));
    for estTarget = 1:size(Xest{k},2)
        for trueTarget = 1:size(Xtrue{k},2)
            xdiff = Xest{k}{estTarget}(1)-Xtrue{k}(trueTarget,1);
            ydiff = Xest{k}{estTarget}(2)-Xtrue{k}(trueTarget,2);
            dist(estTarget,trueTarget) = sqrt(xdiff^2+ydiff^2);
        end
    end
    
    [asso, ~] = murty(dist,1);
    
    if size(dist,1) < size(dist,2)
        for i = size(dist,1)+1:size(dist,2)
            asso(1,i) = NaN;
        end
        disp(['Nbr of estimates < nbr of true targets, k = ', num2str(k)])
    elseif size(dist,1) > size(dist,2) 
        disp(['Nbr of estimates > nbr of true targets, k = ', num2str(k)])
    end
    
    for trueTarget = 1:size(asso,2)
        if sum(asso(:,trueTarget) ~= 0) ~= 0
            figure(trueTarget);
            hold on
            plot(Xtrue{k}(1,trueTarget), Xtrue{k}(2,trueTarget),'k*')
            if asso(1,trueTarget)
        
    

t1 = zeros(4,N);
t2 = zeros(4,N);
p1 = zeros(4,N);
p2 = zeros(4,N);
Xtrue1 = zeros(4,N);
Xtrue2 = zeros(4,N);
Z1 = zeros(2,N);
Z2 = zeros(2,N);
for k = 2:N %size(Z,2)
    x1diff = Xest{k}{1}(1)-Xtrue{k}(1,1);
    y1diff = Xest{k}{1}(2)-Xtrue{k}(2,1);
    x2diff = Xest{k}{2}(1)-Xtrue{k}(1,1);
    y2diff = Xest{k}{2}(2)-Xtrue{k}(2,1);
    d1 = sqrt(x1diff^2+y1diff^2);
    d2 = sqrt(x2diff^2+y2diff^2);
    if d1 < d2
        t1(:,k) = Xest{k}{1};
        t2(:,k) = Xest{k}{2};
        if ~isempty(Xpred{k})
            p1(:,k) = Xpred{k}(1).state;
            p2(:,k) = Xpred{k}(2).state;
        else
            p1(:,k) = 50;
            p2(:,k) = 50;
        end
    else
        t1(:,k) = Xest{k}{2};
        t2(:,k) = Xest{k}{1};
        if ~isempty(Xpred{k})
            p1(:,k) = Xpred{k}(2).state;
            p2(:,k) = Xpred{k}(1).state;
        else
            p1(:,k) = 50;
            p2(:,k) = 50;
        end
    end
    Xtrue1(:,k) = Xtrue{k}(1:4,1);
    Xtrue2(:,k) = Xtrue{k}(1:4,2);
    Z1(:,k) = Z{k}(:,1);
    Z2(:,k) = Z{k}(:,2);
end

K = 2:N;

%%%%% Plot target 1 %%%%%
fig1 = figure;
figure(fig1)
subplot(4,1,1)
plot(K,Xtrue1(1,2:end),'*k')
hold on
plot(K,t1(1,2:end),'*r')
plot(K,p1(1,2:end),'+r')
plot(K,Z1(1,2:end),'ob')
ylabel('x')
ylim([min(Xtrue1(1,2:end))-0.3 max(Xtrue1(1,2:end)+0.3)])
legend('GT','Est','Pred','Meas')

figure(fig1)
subplot(4,1,2)
plot(K,Xtrue1(2,2:end),'*k')
hold on
plot(K,t1(2,2:end),'*r')
plot(K,p1(2,2:end),'+r')
plot(K,Z1(2,2:end),'ob')
ylabel('y')
ylim([min(Xtrue1(2,2:end))-0.3 max(Xtrue1(2,2:end)+0.3)])

figure(fig1)
subplot(4,1,3)
plot(K,Xtrue1(3,2:end),'*k')
hold on
plot(K,t1(3,2:end),'*r')
plot(K,p1(3,2:end),'+r')
ylabel('vx')
ylim([min(Xtrue1(3,2:end))-0.8 max(Xtrue1(3,2:end)+0.8)])

figure(fig1)
subplot(4,1,4)
plot(K,Xtrue1(4,2:end),'*k')
hold on
plot(K,t1(4,2:end),'*r')
plot(K,p1(4,2:end),'+r')
ylabel('vy')
ylim([min(Xtrue1(4,2:end))-0.8 max(Xtrue1(4,2:end)+0.8)])

%%%%% Plot target 2 %%%%%
fig2 = figure;
figure(fig2)
subplot(4,1,1)
plot(K,Xtrue2(1,2:end),'*k')
hold on
plot(K,t2(1,2:end),'*r')
plot(K,p2(1,2:end),'+r')
plot(K,Z2(1,2:end),'ob')
ylabel('x')
ylim([min(Xtrue2(1,2:end))-0.3 max(Xtrue2(1,2:end)+0.3)])
legend('GT','Est','Pred','Meas')

figure(fig2)
subplot(4,1,2)
plot(K,Xtrue2(2,2:end),'*k')
hold on
plot(K,t2(2,2:end),'*r')
plot(K,p2(2,2:end),'+r')
plot(K,Z2(2,2:end),'ob')
ylabel('y')
ylim([min(Xtrue2(2,2:end))-0.3 max(Xtrue2(2,2:end)+0.3)])

figure(fig2)
subplot(4,1,3)
plot(K,Xtrue2(3,2:end),'*k')
hold on
plot(K,t2(3,2:end),'*r')
plot(K,p2(3,2:end),'+r')
ylabel('vx')
ylim([min(Xtrue2(3,2:end))-0.8 max(Xtrue2(3,2:end)+0.8)])

figure(fig2)
subplot(4,1,4)
plot(K,Xtrue2(4,2:end),'*k')
hold on
plot(K,t2(4,2:end),'*r')
plot(K,p2(4,2:end),'+r')
ylabel('vy')
ylim([min(Xtrue2(4,2:end))-0.8 max(Xtrue2(4,2:end)+0.8)])
