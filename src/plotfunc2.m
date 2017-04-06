function plotfunc2(Xest,Z,Xtrue)
% ONLY 2 targets
N = 40; %size(Z,2);
%t = cell(1,2);
t1 = zeros(4,N);
t2 = zeros(4,N);
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
        
    else
        t1(:,k) = Xest{k}{2};
        t2(:,k) = Xest{k}{1};
    end
    Xtrue1(:,k) = Xtrue{k}(1:4,1);
    Xtrue2(:,k) = Xtrue{k}(1:4,2);
    Z1(:,k) = Z{k}(:,1);
    Z2(:,k) = Z{k}(:,2);
end

K = 2:N;

fig1 = figure;

figure(fig1)
subplot(4,1,1)
plot(K,Xtrue1(1,2:end),'-*k')
hold on
plot(K,t1(1,2:end),'*r')
plot(K,Z1(1,2:end),'ob')
ylabel('')

figure(fig1)
subplot(4,1,2)
plot(K,Xtrue1(2,2:end),'*k')
hold on
plot(K,t1(2,2:end),'*r')
plot(K,Z1(2,2:end),'ob')

figure(fig1)
subplot(4,1,3)
plot(K,Xtrue1(3,2:end),'*k')
hold on
plot(K,t1(3,2:end),'*r')

figure(fig1)
subplot(4,1,4)
plot(K,Xtrue1(4,2:end),'*k')
hold on
plot(K,t1(4,2:end),'*r')

% for k = 2:200
%     for i = 1:2
%         figure(i);
%         subplot(2,1,1)
%         plot(k,Xtrue{k}(1,i),'-*k')
%         hold on
%         plot(k,t{k,i}(1),'*r')
%         plot(k,Z{k}(1,i),'ob')
%         
%         figure(i)
%         subplot(2,1,2)
%         plot(k,Xtrue{k}(2,i),'*k')
%         hold on
%         plot(k,t{k,i}(2),'*r')
%         plot(k,Z{k}(2,i),'ob')
%     end
% end
legend('True','Est','Meas')