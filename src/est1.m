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


function [Xest, Pest, rest, west] = est1(Xupd, threshold)
    M = -1;
    Xest = cell(1);
    Pest = cell(1);
    rest = [];
    west = [];
    
    if(~isempty(Xupd))
        for j = 1:size(Xupd,2)
            prod = 1;
            if size(Xupd{j},2) == 0
                prod = 0;
            else
                for i = 1 : size(Xupd{j},2) % find index of which global hyp is 
                    prod= prod*Xupd{j}(i).w;% most likely
                end
            end
            if(prod >= M)
                ind = j;
                M = prod;
            end 
        end
        index = 1;
        for i = 1 : size(Xupd{ind},2)
            if(Xupd{ind}(i).r > threshold) % if prob. of existence great enough
                Xest{index} = [Xupd{ind}(i).state; Xupd{ind}(i).box]; % store mean (i.e states)
                Pest{index} = Xupd{ind}(i).P;
                index = index + 1;
            %else
            %    Xest{index} = [];
            end
            rest = [rest, Xupd{ind}(i).r];
            west = [west, Xupd{ind}(i).w];
        end
    else
        Xest = [];
        Pest = [];
        rest = [];
        west = [];
    end
end