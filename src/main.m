clear all;clf;close all;clc;
load('case3');
ind = 1;
for i = 1 : size(Z,2)
    if(~isempty(Z{i}))
        Z{i} = Z{i};
        ind = ind + 1;
    end
end

[pred,upd,est]=PMBM(Z);

