R = [9.999976e-01 7.553071e-04 -2.035826e-03;
    -7.854027e-04 9.998898e-01 -1.482298e-02;
    2.024406e-03 1.482454e-02 9.998881e-01];
t = [-8.086759e-01; 3.195559e-01; -7.997231e-01];
pose = cell(1);
pos = cell(1);
for i = 1 : size(oxts{1},1)
    %pose = egoPosition(oxts,size(oxts{1},1));
    [pose{i},Tr_0_inv] = egoPosition(oxts,i,Tr_0_inv);
    pos{i} = pose{i}(1:3,4);
end
%%
figure;
for i = 1 : size(pose,2)
    subplot(2,1,1)
    plot(i,pose{i}(1,4),'-k*'); hold on;
    xlabel('time')
    ylabel('x')
    subplot(2,1,2)
    plot(i,pose{i}(2,4),'k*'); hold on
    xlabel('time')
    ylabel('y')
end