function s = initiateStruct(color)
    if ~color
        s = struct('state',[],'P',[],'w',0,'r',0,'S',0,'box',[],'label',0,'nbrMeasAss',0,'class',NaN);
    else
        s = struct('state',[],'P',[],'w',0,'r',0,'S',0,'box',[],'label',0,'nbrMeasAss',0,'red',0,'green',0,'blue',0,'class',NaN);
    end
end