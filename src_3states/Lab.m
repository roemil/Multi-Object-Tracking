function [L,a,b] = Lab(img,bbox)
subImage = imcrop(img, bbox);

lab = rgb2lab(subImage);
L = lab(:,:,1);
a = lab(:,:,2);
b = lab(:,:,3);


end