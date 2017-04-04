% Function to estimate states in PMBM
% Input: Xupd is global hypotheses at all times up to time k
%        Threshold is the parameter that determines which components is
%        alive. 
% Output: Most likely global hypothesis at time k
%
%
%
%
%


function Xest = est1(Xupd, threshold)
M = -1;
prod = 1;
    if(~isempty(Xupd{end}))
        for j = 1:size(Xupd,2)
            for i = 1 : size(Xupd{end,j},2) % find index of which global hyp is 
                prod= prod*Xupd{end,j}(i).w;% most likely
            end
            if(prod >= M)
                ind = j;
                M = prod;
            end 
        end
        index = 1;
        for i = 1 : size(Xupd{end,ind},2)
            if(Xupd{end,ind}(i).r > threshold) % if prob. of existence great enough
                Xest{index} = Xupd{end,ind}(i).state; % store mean (i.e states)
                index = index + 1;
            else
                Xest{index} = [];
            end
        end
    else
        Xest = [];
    end
end