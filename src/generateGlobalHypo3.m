function [newGlob, newInd] = generateGlobalHypo3(Xhypo, Xnew, Z, oldInd,k)

% TODO: Is this correct?
targetsOld = 1:size(Xhypo{1},2);

combsOld = nchoosek(targetsOld,size(Z,2));

pmOld = [];
for i = 1:size(combsOld,1)
    pmOld = [pmOld; perms(combsOld(i,:))];
end

jInd = 1;
for j = 1:size(pmOld,1)
    iInd = 1;
    % Update all previously detected targets
    for i = 1:size(Xhypo{1},2)
        % If target is not associated to any measurement set it to MD
        if ((sum(i == pmOld(j,:)) == 0) && ((Xhypo{end}(i).r ~= 0) && (Xhypo{end}(i).w ~= 0)))
            newGlob{jInd}(iInd).w = Xhypo{end}(i).w;
            newGlob{jInd}(iInd).r = Xhypo{end}(i).r;
            newGlob{jInd}(iInd).state = Xhypo{end}(i).state;
            newGlob{jInd}(iInd).P = Xhypo{end}(i).P;
            iInd = iInd+1;
        % Else find which measurement it is associated to
        else
            for z = 1:size(Z,2)
                if ((i == pmOld(j,z)) && (Xhypo{z}(i).r ~= 0) && (Xhypo{z}(i).w ~= 0))
                    newGlob{jInd}(iInd).w = Xhypo{z}(i).w;
                    newGlob{jInd}(iInd).r = Xhypo{z}(i).r;
                    newGlob{jInd}(iInd).state = Xhypo{z}(i).state;
                    newGlob{jInd}(iInd).P = Xhypo{z}(i).P;
                    iInd = iInd+1;
                end
            end
        end
    end
    jInd = jInd+1;
end

% Update all pot new detected targets
for z = 1:size(Z,2)
    for i = 
for i = size(Xhypo{1},2)+1:size(Xhypo{1},2)+size(Xnew,2)
    for z = 1:size(Z,2)
        if ((i == pmOld(j,z)) && (Xnew{z}.r ~= 0) && (Xnew{z}.w ~= 0))
            newGlob{jInd}(iInd).w = Xnew{z}.w;
            newGlob{jInd}(iInd).r = Xnew{z}.r;
            newGlob{jInd}(iInd).state = Xnew{z}.state;
            newGlob{jInd}(iInd).P = Xnew{z}.P;
            iInd = iInd+1;
        end
    end
end
jInd = jInd+1;


newInd = oldInd+jInd-1;