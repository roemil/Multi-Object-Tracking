function plotfunc3(Xest,Z,Xtrue)
% ONLY 2 targets
N = 65; %size(Z,2);
%t = cell(1,2);
t1 = zeros(4,N);
t2 = zeros(4,N);
tvec = cell(1);
tvec{1} = t1;
tvec{2} = t2;
Xtrue1 = zeros(4,N);
Xtrue2 = zeros(4,N);
Z1 = zeros(2,N);
Z2 = zeros(2,N);
for k = 2:N %size(Z,2)
    
    
    for i = 1 : size(Xest{k},2)
        xdiff(i) = calcdiff(Xest{k}{i},Xtrue{k}(:,i),'x');
        ydiff(i) = calcdiff(Xest{k}{i},Xtrue{k}(:,i),'y');
        d(i) = calcdist(xdiff(i),ydiff(i)); 
    end
    dtmp = d;
    [~,ind] = min(dtmp);
    indvec = ind;
    for i = 1 : size(Xest{k},2)
        dtmp(ind) = 100;
        [~,ind]= min(dtmp);
        indvec = [indvec, ind];
    end
%     d_sorted = sort(d);
%     for i = 1 : size(Xest{k},2)
%         tvec{i}(:,k) = Xest{k}{indvec(i)};
%             
%     end
%     if d1 < d2
%         t1(:,k) = Xest{k}{1};
%         t2(:,k) = Xest{k}{2};
%         
%     else
%         t1(:,k) = Xest{k}{2};
%         t2(:,k) = Xest{k}{1};
%     end
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
plot(K,tvec{1}(1,2:end),'*r')
plot(K,Z1(1,2:end),'ob')
title('Position')
ylabel('')

figure(fig1)
subplot(4,1,2)
plot(K,Xtrue1(2,2:end),'*k')
hold on
plot(K,tvec{1}(2,2:end),'*r')
plot(K,Z1(2,2:end),'ob')

figure(fig1)
subplot(4,1,3)
plot(K,Xtrue1(3,2:end),'*k')
hold on
plot(K,tvec{1}(3,2:end),'*r')
title('Velocity')
figure(fig1)
subplot(4,1,4)
plot(K,Xtrue1(4,2:end),'*k')
hold on
plot(K,tvec{1}(4,2:end),'*r')

fig2 = figure;

figure(fig2)
subplot(4,1,1)
plot(K,Xtrue2(1,2:end),'-*k')
hold on
plot(K,t2(1,2:end),'*r')
plot(K,Z2(1,2:end),'ob')
ylabel('')
title('Position')
figure(fig2)
subplot(4,1,2)
plot(K,Xtrue2(2,2:end),'*k')
hold on
plot(K,t2(2,2:end),'*r')
plot(K,Z2(2,2:end),'ob')

figure(fig2)
subplot(4,1,3)
plot(K,Xtrue2(3,2:end),'*k')
hold on
plot(K,t2(3,2:end),'*r')
title('Velocity')
figure(fig2)
subplot(4,1,4)
plot(K,Xtrue2(4,2:end),'*k')
hold on
plot(K,t2(4,2:end),'*r')

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
legend('True','Est','Meas','True Vel','Est Vel')