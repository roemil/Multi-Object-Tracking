function [yRed, yGreen, yBlue] = colorhist(img, bbox)
%bbox contains corners of said box
subImage = imcrop(img, bbox);
[yRed,xRed] = imhist(subImage(:,:,1));
[yGreen, xGreen] = imhist(subImage(:,:,2));
[yBlue, xBlue] = imhist(subImage(:,:,3));
yRed = yRed./trapz(xRed,yRed);
yGreen = yGreen./trapz(xGreen,yGreen);
yBlue = yBlue./trapz(xBlue,yBlue);

end