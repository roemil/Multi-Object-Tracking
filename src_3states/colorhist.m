function [yRed, yGreen, yBlue] = colorhist(img, bbox)
%bbox contains corners of said box
subImage = imcrop(img, bbox);
[yRed,xRed] = imhist(subImage(:,:,1));
[yGreen, xGreen] = imhist(subImage(:,:,2));
[yBlue, xBlue] = imhist(subImage(:,:,3));
%yTot = yRed + yGreen + yBlue;
yRed = yRed./trapz(xRed,yRed);
%yRed = yRed ./ sum(yRed);
%yGreen = yGreen ./ sum(yGreen);
%yBlue = yBlue ./ sum(yBlue);
yGreen = yGreen./trapz(xGreen,yGreen);
yBlue = yBlue./trapz(xBlue,yBlue);
%yTotNorm = yRed + yGreen + yBlue;

%subImageGray = mean(subImage,3);
%yTot = subImage(:,:,1)+subImage(:,:,2)+subImage(:,:,3);
%yTot = subImage(:);
%yTot = yTot./max(yTot);
%[yGray,x] = imhist(yTot,256);
%yGray = yGray./trapz(x,yGray);

end