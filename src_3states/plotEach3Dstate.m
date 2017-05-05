function plotEach3Dstate(seq,set,X,P,plotConf)

figure('units','normalized','position',[.05 .05 .9 .9]);
hold on
for k = 1:size(X,2)
    datapath = strcat('../../kittiTracking/',set,'/','label_02/',seq);
    filename = [datapath,'.txt'];
    formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
    f = fopen(filename);
    GT = textscan(f,formatSpec);
    fclose(f);

    ind = find(GT{1} == k-1 & GT{2} ~= -1);
    ktmp = k*ones(size(ind));
    subplot(3,1,1)
    if k == 1
        gt = plot(ktmp,GT{14}(ind),'g*');
    else
        plot(ktmp,GT{14}(ind),'g*')
    end
    hold on
    for i = 1:size(X{k},2)
        if k == 1
           est = plot(k,X{k}{i}(1),'r*');
        else
            plot(k,X{k}{i}(1),'r*')
        end
    end
    title('x')
    
    subplot(3,1,2)
    plot(ktmp,GT{15}(ind)-GT{11}(ind)/2,'g*')
    hold on
    for i = 1:size(X{k},2)
        plot(k,X{k}{i}(2),'r*')
    end
    title('y')
    
    subplot(3,1,3)
    plot(ktmp,GT{16}(ind),'g*')
    hold on
    for i = 1:size(X{k},2)
        plot(k,X{k}{i}(3),'r*')
    end
    title('z')
end
legend([gt, est],'GT','Est')
