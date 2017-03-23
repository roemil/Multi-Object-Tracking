function [targets] = checkValid(targets, FOV)
    xlim = FOV(1);
    ylim = FOV(2);
    pos = [];
    for m = 1 : size(targets,2)
        if((abs(targets(1,m)) > xlim) || abs(targets(2,m)) > ylim)
            pos = [pos,m];
            %flag = 0;
%             %targets{i}
%             %nbrOftargets = nbrOftargets - 1
%             %nbrOftargets = size(X,2);
%         else 
%             flag = 1;
        end 
    end
    targets(:,pos) = [];
end
    