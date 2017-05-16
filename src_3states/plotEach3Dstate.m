function plotEach3Dstate(seq,set,Xest,Pest,plotConf)

global egoMotionOn, global pose, global R20, global T20, global RcamToVelo,
global TcamToVelo, global RimuToVelo, global TimuToVelo,
global RveloToImu, global TveloToImu, global angles, global T

pos = figure('units','normalized','position',[.05 .05 .9 .9]);
hold on
vel = figure('units','normalized','position',[.05 .05 .9 .9]);
hold on
for k = 1:size(Xest,2)
    datapath = strcat('../../kittiTracking/',set,'/','label_02/',seq);
    filename = [datapath,'.txt'];
    formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
    f = fopen(filename);
    GT = textscan(f,formatSpec);
    fclose(f);

    ind = find(GT{1} == k-1 & GT{2} ~= -1);
    
    if egoMotionOn
        Xt = [GT{14}(ind)';
            (GT{15}(ind)-GT{11}(ind)/2)';
            GT{16}(ind)'];
        Xt = TveloToImu(1:3,:)*(TcamToVelo*(T20*[Xt;ones(1,size(Xt,2))]));
        heading = angles{k}.heading-angles{1}.heading;
        Xt(1:2,:) = [cos(-heading), sin(-heading); -sin(-heading) cos(-heading)]*Xt(1:2,:);
        Xt = Xt+pose{k}(1:3,4);
        Xt(7,:) = GT{2}(ind)';
        
        if k == 1
            Xt(4:6,:) = NaN;
            XtOld = Xt;
        else
            for i = 1:size(Xt,2)
                iInd = find(Xt(7,i) == XtOld(7,:));
                if ~isempty(iInd)
                    Xt(4:6,i) = (Xt(1:3,i)-XtOld(1:3,iInd))/T;
                else
                    Xt(4:6,i) = NaN;
                end
            end
            XtOld = Xt;
        end
        %GT = TveloToImu(1:3,:)*(TcamToVelo*(T20*[GT;ones(1,size(GT,2))]))+...
        %    + pose{k}(1:3,4);
    end
    ktmp = k*ones(size(ind));
    figure(pos);
    subplot(3,1,1)
    if k == 1
        if ~egoMotionOn
            gt = plot(ktmp,Xt{14}(ind),'g*');
        else
            gt = plot(ktmp,Xt(1,:),'g*');
        end
    else
        if ~egoMotionOn
            plot(ktmp,Xt{14}(ind),'g*');
        else
            plot(ktmp,Xt(1,:),'g*')
        end
    end
    hold on
    if ~isempty(Xest{k}{1})
        for i = 1:size(Xest{k},2)
            if k == 1
               est = plot(k,Xest{k}{i}(1),'r*');
            else
                plot(k,Xest{k}{i}(1),'r*')
            end
        end
    end
    title('x')
    
    figure(pos)
    subplot(3,1,2)
    if ~egoMotionOn
        plot(ktmp,Xt{15}(ind)-Xt{11}(ind)/2,'g*')
    else
        plot(ktmp,Xt(2,:),'g*')
    end
    hold on
    if ~isempty(Xest{k}{1})
        for i = 1:size(Xest{k},2)
            plot(k,Xest{k}{i}(2),'r*')
        end
    end
    title('y')
    
    figure(pos)
    subplot(3,1,3)
    if ~egoMotionOn
        plot(ktmp,Xt{16}(ind),'g*')
    else
        plot(ktmp,Xt(3,:),'g*')
    end
    hold on
    if ~isempty(Xest{k}{1})
        for i = 1:size(Xest{k},2)
            plot(k,Xest{k}{i}(3),'r*')
        end
    end
    title('z')
    
    
    %%%% Velocity %%%%
    figure(vel);
    subplot(3,1,1)
    if egoMotionOn
        plot(ktmp,Xt(4,:),'g*')
    end
    hold on
    if ~isempty(Xest{k}{1})
        for i = 1:size(Xest{k},2)
            if ~isnan(Xest{k}{i}(4))
                plot(k,Xest{k}{i}(4),'r*')
            end
        end
    end
    title('vx')
    
    figure(vel)
    subplot(3,1,2)
    if egoMotionOn
        plot(ktmp,Xt(5,:),'g*')
    end
    hold on
    if ~isempty(Xest{k}{1})
        for i = 1:size(Xest{k},2)
            if ~isnan(Xest{k}{i}(5))
                plot(k,Xest{k}{i}(5),'r*')
            end
        end
    end
    title('vy')
    
    figure(vel)
    subplot(3,1,3)
    if egoMotionOn
        plot(ktmp,Xt(6,:),'g*')
    end
    hold on
    if ~isempty(Xest{k}{1})
        for i = 1:size(Xest{k},2)
            if ~isnan(Xest{k}{i}(6))
                plot(k,Xest{k}{i}(6),'r*')
            end
        end
    end
    title('vz')
end
legend([gt, est],'GT','Est')
