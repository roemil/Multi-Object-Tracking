function map = generateHashmap(mode)

if(strcmp(mode,'CNNnonlinear') || strcmp(mode,'CNN'))
    keySet = {'Car','Cyclist','Pedestrian'};
    valueSet = {1, 2, 3};
elseif(strcmp(mode,'GTnonlinear') || strcmp(mode,'GT'))
    keySet = {'Car','Van','Cyclist','Pedestrian','Misc','Truck','Tram'};
    valueSet = {1, 2, 3 ,4, 5, 6, 7};
end

map = containers.Map(keySet,valueSet);


end