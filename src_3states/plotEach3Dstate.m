function plotEach3Dstate(seq,set,X,P,plotConf)
global egoMotionOn, global pose, global R20, global T20, global RcamToVelo,
global TcamToVelo

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
    
    if egoMotionOn
        GT = [GT{14}(ind)';
            (GT{15}(ind)-GT{11}(ind)/2)'
            GT{16}(ind)'];
        GT = RcamToVelo*(R20*GT+repmat(T20,1,size(GT,2)))+repmat(TcamToVelo,1,size(GT,2))+pose{k}(1:3,4);
    end
    ktmp = k*ones(size(ind));
    subplot(3,1,1)
    if k == 1
        if ~egoMotionOn
            gt = plot(ktmp,GT{14}(ind),'g*');
        else
            gt = plot(ktmp,GT(1,:),'g*');
        end
    else
        if ~egoMotionOn
            plot(ktmp,GT{14}(ind),'g*');
        else
            plot(ktmp,GT(1,:),'g*')
        end
    end
    hold on
    if ~isempty(X{k}{1})
        for i = 1:size(X{k},2)
            if k == 1
               est = plot(k,X{k}{i}(1),'r*');
            else
                plot(k,X{k}{i}(1),'r*')
            end
        end
    end
    title('x')
    
    subplot(3,1,2)
    if ~egoMotionOn
        plot(ktmp,GT{15}(ind)-GT{11}(ind)/2,'g*')
    else
        plot(ktmp,GT(2,:),'g*')
    end
    hold on
    if ~isempty(X{k}{1})
        for i = 1:size(X{k},2)
            plot(k,X{k}{i}(2),'r*')
        end
    end
    title('y')
    
    subplot(3,1,3)
    if ~egoMotionOn
        plot(ktmp,GT{16}(ind),'g*')
    else
        plot(ktmp,GT(3,:),'g*')
    end
    hold on
    if ~isempty(X{k}{1})
        for i = 1:size(X{k},2)
            plot(k,X{k}{i}(3),'r*')
        end
    end
    title('z')
end
legend([gt, est],'GT','Est')
