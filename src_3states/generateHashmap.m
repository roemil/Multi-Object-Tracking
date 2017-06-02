function map = generateHashmap(mode)

if(strcmp(mode,'CNNnonlinear'))
    keySet = {'Car','Cyclist','Pedestrian'};
    valueSet = {1, 2, 3};
elseif(strcmp(mode,'GTnonlinear'))
    keySet = {'Car','Van','Cyclist','Pedestrian','Misc','Truck'};
    valueSet = {1, 2, 3 ,4,5,6};
end

map = containers.Map(keySet,valueSet);


end