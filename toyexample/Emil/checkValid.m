function [targets] = checkValid(targets, xlim, ylim)
    pos = [];
    for m = 1 : size(targets,2)
        if(targets(1,m) >= xlim || targets(1,m) < 0 || targets(2,m) >= ylim || targets(2,m) < 0)
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
    