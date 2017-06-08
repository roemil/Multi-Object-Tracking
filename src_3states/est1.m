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


function [Xest, Pest, rest, west, labelsEst, jEst] = est1(Xupd, threshold, motionModel)
    M = -1e10;
    Xest = cell(1);
    Pest = cell(1);
    rest = [];
    west = [];
    labelsEst = [];
    ind = -1;
    
    if(~isempty(Xupd))
        for j = 1:size(Xupd,2)
            wGlob = 0;
            if size(Xupd{j},2) == 0
                wGlob = 0;
            else
                for i = 1 : size(Xupd{j},2) % find index of which global hyp is
                    wGlob = wGlob + Xupd{j}(i).w;% most likely
                end
            end
            if(wGlob >= M)
                ind = j;
                M = wGlob;
            end 
        end
        index = 1;
        jEst = ind;
        if strcmp(motionModel,'cv')
            for i = 1 : size(Xupd{ind},2)
                if(Xupd{ind}(i).r > threshold) % if prob. of existence great enough
                    Xest{index} = [Xupd{ind}(i).state; Xupd{ind}(i).box; Xupd{ind}(i).label]; % store mean (i.e states)
                    Pest{index} = Xupd{ind}(i).P;
                    index = index + 1;
                %else
                %    Xest{index} = [];
                end
                rest = [rest, Xupd{ind}(i).r];
                west = [west, Xupd{ind}(i).w];
                labelsEst = [labelsEst, Xupd{ind}(i).label];
            end
        elseif strcmp(motionModel,'cvBB')
            for i = 1 : size(Xupd{ind},2)
                if(Xupd{ind}(i).r > threshold && Xupd{ind}(i).nbrMeasAss >= 2) % if prob. of existence great enough
                    Xest{index} = [Xupd{ind}(i).state; Xupd{ind}(i).label;Xupd{ind}(i).class]; % store mean (i.e states)
                    Pest{index} = Xupd{ind}(i).P;
                    index = index + 1;
                %else
                %    Xest{index} = [];
%                 elseif((Xupd{ind}(i).r > threshold))
%                     Xest{index} = [Xupd{ind}(i).state; 999;Xupd{ind}(i).class]; % store mean (i.e states)
%                     Pest{index} = Xupd{ind}(i).P;
%                     index = index + 1;
                end
                rest = [rest, Xupd{ind}(i).r];
                west = [west, Xupd{ind}(i).w];
                labelsEst = [labelsEst, Xupd{ind}(i).label];
            end
        end
    else
        Xest = [];
        Pest = [];
        rest = [];
        west = [];
    end
end