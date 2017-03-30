function [newGlob, newInd] = generateGlobalHypo2(Xhypo, Xnew, Z, oldInd,k)

% TODO: Is this correct?
targets = 1:(size(Xhypo{1},2)+size(Xnew,2)+size(Z,2));

combs = nchoosek(targets,size(Z,2));

pm = [];
for i = 1:size(combs,1)
    pm = [pm; perms(combs(i,:))];
end
%if k == 3
%    keyboard
%end
jInd = 1;
for j = 1:size(pm,1)
    iInd = 1;
    % Update all previously detected targets
    for i = 1:size(Xhypo{1},2)
        % If target is not associated to any measurement set it to MD
        if ((sum(i == pm(j,:)) == 0) && ((Xhypo{end}(i).r ~= 0) && (Xhypo{end}(i).w ~= 0)))
            newGlob{jInd}(iInd).w = Xhypo{end}(i).w;
            newGlob{jInd}(iInd).r = Xhypo{end}(i).r;
            newGlob{jInd}(iInd).state = Xhypo{end}(i).state;
            newGlob{jInd}(iInd).P = Xhypo{end}(i).P;
            iInd = iInd+1;
        % Else find which measurement it is associated to
        else
            for z = 1:size(Z,2)
                if ((i == pm(j,z)) && (Xhypo{z}(i).r ~= 0) && (Xhypo{z}(i).w ~= 0))
                    newGlob{jInd}(iInd).w = Xhypo{z}(i).w;
                    newGlob{jInd}(iInd).r = Xhypo{z}(i).r;
                    newGlob{jInd}(iInd).state = Xhypo{z}(i).state;
                    newGlob{jInd}(iInd).P = Xhypo{z}(i).P;
                    iInd = iInd+1;
                end
            end
        end
    end
    % Update all pot new detected targets
    for i = size(Xhypo{1},2)+1:size(Xhypo{1},2)+size(Xnew{1},2)
        % If target is not associated to any measurement set it to MD
        if (sum(i == pm(j,:)) == 0)
            %newGlob{j}(i).state = Xnew{z}(i-size(Xhypo{1},2)).state;
            %newGlob{j}(i).P = Xnew{z}(i-size(Xhypo{1},2)).P;
            %newGlob{j}(i).w = 1;
            %newGlob{j}(i).r = 0;
        % Else find which measurement it is associated to
        else
            for z = 1:size(Z,2)
                if ((i == pm(j,z)) && (Xnew{z}(i-size(Xhypo{1},2)).r ~= 0) && (Xnew{z}(i-size(Xhypo{1},2)).w ~= 0))
                    newGlob{jInd}(iInd).w = Xnew{z}(i-size(Xhypo{1},2)).w;
                    newGlob{jInd}(iInd).r = Xnew{z}(i-size(Xhypo{1},2)).r;
                    newGlob{jInd}(iInd).state = Xnew{z}(i-size(Xhypo{1},2)).state;
                    newGlob{jInd}(iInd).P = Xnew{z}(i-size(Xhypo{1},2)).P;
                    iInd = iInd+1;
                end
            end 
        end
    end
    jInd = jInd+1;
end

newInd = oldInd+jInd-1;