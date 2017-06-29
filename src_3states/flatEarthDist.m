function d = flatEarthDist(pixRow)

focalLen = 4e-3; % in m.
pixSizeinM = 4.65e-6; % in m
focalLenPix = 0.5*focalLen / pixSizeinM;
Beta = (35 * pi / 180)/375; % Camera pitch angle
h = 1.65; % Camera height in m
principalPoint = round(375/2);

if(pixRow == principalPoint)
    pixRow = pixRow + 10;
end
theta = atan2((pixRow-principalPoint),focalLenPix);

d = abs(h * tan(pi/2 - (Beta + theta)));
%lambda = h * focalLenPix/cos(Beta)^2;
%vh = principalPoint - focalLenPix*tan(Beta)
%d = lambda / (pixRow - vh);

end