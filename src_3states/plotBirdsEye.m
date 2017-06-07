function labels = plotBirdsEye(seq,set,X,P,step, auto,labels,plotConf)

global egoMotionOn, global pose, global R20, global T20, global RcamToVelo,
global TcamToVelo, global RimuToVelo, global TimuToVelo,
global RveloToImu, global TveloToImu, global angles

legGTOn = true;
legEstOn = true;
legEgoOn = true;

legFOVOn = true;
FOVon = true;
angle = 45;
d = 30;

if ~auto
    figure('units','normalized','position',[.05 .05 .9 .9]);
end
hold on
%labels = [];
if ~step
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
            GT = TveloToImu(1:3,:)*(TcamToVelo*(T20*[GT;ones(1,size(GT,2))]));
            heading = angles{k}.heading-angles{1}.heading;
            GT(1:2,:) = [cos(-heading), sin(-heading); -sin(-heading) cos(-heading)]*GT(1:2,:);
            GT = GT+pose{k}(1:3,4);
        end
        if legGTOn
            if ~egoMotionOn
                gt = plot(GT{14}(ind),GT{15}(ind),'g*');
            else
                gt = plot(GT(1,:),GT(2,:),'g*');
            end
            legGTOn = false;
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
                if legEstOn
                   est = plot(X{k}{i}(1),X{k}{i}(2),'r*'); %sum(ismember(X{k}{i}(9),labels)) == 0
                   if isempty(find(labels == X{k}{i}(9)))
                       text(X{k}{i}(1),X{k}{i}(2),num2str(X{k}{i}(9)),'Fontsize',18,'Color','red')
                       labels = [labels, X{k}{i}(9)];
                   end
                   legEstOn = false;
                else
                    plot(X{k}{i}(1),X{k}{i}(2),'r*')
                    if isempty(find(labels == X{k}{i}(9)))
                       text(X{k}{i}(1),X{k}{i}(2),num2str(X{k}{i}(9)),'Fontsize',18,'Color','red')
                       labels = [labels, X{k}{i}(9)];
                   end
                end
            end
        end
        if egoMotionOn
            if legEgoOn
                ego = plot(pose{k}(1,4),pose{k}(2,4),'+k');
                legEgoOn = false;
            else
                plot(pose{k}(1,4),pose{k}(2,4),'+k');
            end
        end
        title('Birds-eye view')
        xlabel('x')
        ylabel('y')
    end
elseif ~auto
    global kInit
    k = kInit;
    %xlim([0 250])
    %ylim([-15 15])
    while 1
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
            GT = TveloToImu(1:3,:)*(TcamToVelo*(T20*[GT;ones(1,size(GT,2))]));
            heading = angles{k}.heading-angles{1}.heading;
            GT(1:2,:) = [cos(-heading), sin(-heading); -sin(-heading) cos(-heading)]*GT(1:2,:);
            %GT(1:2,:) = sqrt(GT(1,:).^2+GT(2,:).^2).*[cos(heading+atan(GT(2,:)./GT(1,:))); ...
            %            sin(heading+atan(GT(2,:)./GT(1,:)))];
            GT = GT+pose{k}(1:3,4);
        end
        if legGTOn
            if ~egoMotionOn
                gt = plot(GT{14}(ind),GT{15}(ind),'g*');
            else
                gt = plot(GT(1,:),GT(2,:),'g*');
            end
            legGTon = false;
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
                if legEstOn
                   est = plot(X{k}{i}(1),X{k}{i}(2),'r*'); %sum(ismember(X{k}{i}(9),labels)) == 0
                   if isempty(find(labels == X{k}{i}(9)))
                       text(X{k}{i}(1),X{k}{i}(2),num2str(X{k}{i}(9)),'Fontsize',18,'Color','red')
                       labels = [labels, X{k}{i}(9)];
                   end
                   legEstOn = false;
                else
                    plot(X{k}{i}(1),X{k}{i}(2),'r*')
                    if isempty(find(labels == X{k}{i}(9)))
                       text(X{k}{i}(1),X{k}{i}(2),num2str(X{k}{i}(9)),'Fontsize',18,'Color','red')
                       labels = [labels, X{k}{i}(9)];
                   end
                end
            end
        end
        if egoMotionOn
            if legEgoOn
                ego = plot(pose{k}(1,4),pose{k}(2,4),'+k');
                legEgoOn = false;
            else
                plot(pose{k}(1,4),pose{k}(2,4),'+k');
            end
        end
        title(['Birds-eye view, k = ',num2str(k)])
        xlabel('x')
        ylabel('y')
        try
            waitforbuttonpress; 
        catch
            fprintf('Window closed. Exiting...\n');
            break
        end
        key = get(gcf,'CurrentCharacter');
        switch lower(key)  
            case 'a'
                k = k - 1;
                if k <= 0
                    fprintf('Window closed. Exiting...\n');
                    break
                end
            case 'l'
                k = k + 1;
                if k > size(X,2)
                    fprintf('Window closed. Exiting...\n');
                    break
                end
        end
    end
else
    %xlim([0 80])
    %ylim([-10 30])
    global k
%     xlim([pose{k}(1,4) pose{k}(1,4)+120])
%     ylim([pose{k}(2,4)-35 pose{k}(2,4)+35])
    xlim([pose{k}(1,4)-40 pose{k}(1,4)+40])
    ylim([pose{k}(2,4)-35 pose{k}(2,4)+35])
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
        GT = TveloToImu(1:3,:)*(TcamToVelo*(T20*[GT;ones(1,size(GT,2))]));
        heading = angles{k}.heading-angles{1}.heading;
        GT(1:2,:) = [cos(-heading), sin(-heading); -sin(-heading) cos(-heading)]*GT(1:2,:);
        %GT(1:2,:) = sqrt(GT(1,:).^2+GT(2,:).^2).*[cos(heading+atan(GT(2,:)./GT(1,:))); ...
        %            sin(heading+atan(GT(2,:)./GT(1,:)))];
        GT = GT+pose{k}(1:3,4);

    end
    if legGTOn
        if ~egoMotionOn
            gt = plot(GT{14}(ind),GT{15}(ind),'g*','Markersize',8,'linewidth',1);
        else
            gt = plot(GT(1,:),GT(2,:),'g*','Markersize',8,'linewidth',1);
        end
        legGTon = false;
    else
        if ~egoMotionOn
            plot(ktmp,GT{14}(ind),'g*','Markersize',8,'linewidth',1);
        else
            plot(GT(1,:),GT(2,:),'g*','Markersize',8,'linewidth',1)
        end
    end
    hold on
    if ~isempty(X{k}{1})
        for i = 1:size(X{k},2)
            if legEstOn
               est = plot(X{k}{i}(1),X{k}{i}(2),'r*','Markersize',8,'linewidth',1); %sum(ismember(X{k}{i}(9),labels)) == 0
               %if isempty(find(labels == X{k}{i}(9)))
                   text(X{k}{i}(1)-1,X{k}{i}(2)+3,num2str(X{k}{i}(9)),'Fontsize',18,'Color','red')
               %    labels = [labels, X{k}{i}(9)];
               %end
               legEstOn = false;
            else
                plot(X{k}{i}(1),X{k}{i}(2),'r*','Markersize',8,'linewidth',1)
               % if isempty(find(labels == X{k}{i}(9)))
                   text(X{k}{i}(1)-1,X{k}{i}(2)+3,num2str(X{k}{i}(9)),'Fontsize',18,'Color','red')
               %    labels = [labels, X{k}{i}(9)];
               % end
            end
        end
    end
    if egoMotionOn
        if legEgoOn
            ego = plot(pose{k}(1,4),pose{k}(2,4),'+k','Markersize',8,'linewidth',1);
            legEgoOn = false;
            if FOVon && legFOVOn
                p = [cos(heading), -sin(heading); sin(heading) cos(heading)]*d*[1 1;tand(angle), -tand(angle)]+pose{k}(1:2,4);
                legFOV = plot([pose{k}(1,4) p(1,1)], [pose{k}(2,4) p(2,1)],'k');
                plot([pose{k}(1,4) p(1,2)], [pose{k}(2,4) p(2,2)],'k')
                legFOVOn = false;
            end
        else
            plot(pose{k}(1,4),pose{k}(2,4),'+k','Markersize',8,'linewidth',1);
            if FOVon
                p = [cos(heading), -sin(heading); sin(heading) cos(heading)]*d*[1 1;tand(angle), -tand(angle)]+pose{k}(1:2,4);
                plot([pose{k}(1,4) p(1,1)], [pose{k}(2,4) p(2,1)],'k')
                plot([pose{k}(1,4) p(1,2)], [pose{k}(2,4) p(2,2)],'k')
            end
        end
    end
    title(['Birds-eye view, k = ',num2str(k)])
    xlabel('x')
    ylabel('y')
end
    
if egoMotionOn
    legend([gt, est, ego],'GT','Est','Ego','Location','SouthEast')
elseif FOVon
    legend([gt, est, ego, legFOV],'GT','Est','Ego','FOV','Location','SouthEast')
else
    legend([gt, est],'GT','Est')
end
