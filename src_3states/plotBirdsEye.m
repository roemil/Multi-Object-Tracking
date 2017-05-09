function plotEach3Dstate(seq,set,X,P,plotConf)
global egoMotionOn, global pose, global R20, global T20, global RcamToVelo,
global TcamToVelo, global RimuToVelo, global TimuToVelo,
global RveloToImu, global TveloToImu

figure('units','normalized','position',[.05 .05 .9 .9]);
hold on
labels = [];
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
            (GT{15}(ind)-GT{11}(ind)/2)';
            GT{16}(ind)'];
        GT = TveloToImu(1:3,:)*(TcamToVelo*(T20*[GT;ones(1,size(GT,2))]))+...
            + pose{k}(1:3,4);
    end
    if k == 1
        if ~egoMotionOn
            gt = plot(GT{14}(ind),GT{15}(ind),'g*');
        else
            gt = plot(GT(1,:),GT(2,:),'g*');
        end
    else
        if ~egoMotionOn
            plot(ktmp,GT{14}(ind),'g*');
        else
            plot(GT(1,:),GT(2,:),'g*')
        end
    end
    hold on
    if ~isempty(X{k}{1})
        for i = 1:size(X{k},2)
            if k == 1
               est = plot(X{k}{i}(1),X{k}{i}(2),'r*'); %sum(ismember(X{k}{i}(9),labels)) == 0
               if isempty(find(labels == X{k}{i}(9)))
                   text(X{k}{i}(1),X{k}{i}(2),num2str(X{k}{i}(9)),'Fontsize',18,'Color','red')
                   labels = [labels, num2str(X{k}{i}(9))];
               end
            else
                plot(X{k}{i}(1),X{k}{i}(2),'r*')
                if isempty(find(labels == X{k}{i}(9)))
                   text(X{k}{i}(1),X{k}{i}(2),num2str(X{k}{i}(9)),'Fontsize',18,'Color','red')
                   labels = [labels, num2str(X{k}{i}(9))];
               end
            end
        end
    end
    if egoMotionOn
        if k == 1
            ego = plot(pose{k}(1,4),pose{k}(2,4),'+k');
        else
            plot(pose{k}(1,4),pose{k}(2,4),'+k');
        end
    end
    title('Birds-eye view')
    xlabel('x')
    ylabel('y')
end

if egoMotionOn
    legend([gt, est, ego],'GT','Est','Ego')
else
    legend([gt, est],'GT','Est')
end
