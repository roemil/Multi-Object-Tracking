figure('units','normalized','position',[.05 .05 .9 .9]);
a = subplot('position', [0.02 0 0.98 1]);
k = 1;
flag = 'true';
while 1
    frameNbr = sprintf('%06d',k-1);
    plotImgEst2(sequence,set,k,Xest2{k},Z2{k},GT{k},GTdc{k});
    title(['k = ', num2str(k-1)],'Interpreter','Latex','Fontsize',20)
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
            else
                cla(a)
            end
        case 'l'
            k = k + 1;
            if k > size(Xest,2)
                fprintf('Window closed. Exiting...\n');
                break
            else
                cla(a)
            end
        case 'o'
            k = k + 10;
            if k > size(Xest,2)
                fprintf('Window closed. Exiting...\n');
                break
            else
                cla(a)
            end
        case 'q'
            k = k - 10;
            if k <= 0
                fprintf('Window closed. Exiting...\n');
                break
            else
                cla(a)
            end
    end
    %pause(1.5)
%end
end