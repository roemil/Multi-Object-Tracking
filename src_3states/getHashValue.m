function value = getHashValue(map,key)
keySet = {key};
value = values(map,keySet);
value = value{1};
end