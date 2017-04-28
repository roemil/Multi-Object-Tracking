c = 0;
jmax = 0;
wmat = zeros(28,10);
for k = 2:size(Xupd,1)
    for j = 1:size(Xupd,2)
        if ~isempty(Xupd{k,j})
            for i = 1:size(Xupd{k,j},2)
                if j >jmax
                    jmax = j;
                end
                if ~isempty(Xupd{k,j}(i).w)
                    wmat(j,k) = wmat(j,k)+Xupd{k,j}(i).w;
                    end
                if Xupd{k,j}(i).w == 0
                    Xupd{k,j}(i).state
                    c = c+1;
                end
            end
        end
    end
end
c