clear all;clf;close all;clc;
load('case3');
% ind = 1;
% for i = 1 : size(z,2)
%     if(~isempty(z{i}))
%         Z{ind} = z{i};
%         ind = ind + 1;
%     end
% end

[pred,upd,est,Pest]=PMBM(Z);

%%
plotStates(Z,X,est,Pest)
