function diff = calcdiff(Xest,Xtrue,mode)

if(strcmp(mode,'x'))
    diff = Xest(1)-Xtrue(1,1);
elseif(strcmp(mode,'y'))
    diff = Xest(2)-Xtrue(2,1);
else
    error('wrong mode. Please choose x or y');
end