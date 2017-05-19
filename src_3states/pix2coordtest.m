function z = pix2coordtest(x,d)
global FOVsize

% True distance, but this is worse?
%phi = 35*pi/180 / FOVsize(2,2)*(FOVsize(2,2)/2-x(2));
%c = d*cos(phi);
%theta = pi/2 / FOVsize(2,1)*(x(1)-FOVsize(2,1)/2);
%z = c*cos(theta);


% Approx distance in xz-plane
theta = pi/2 ./ FOVsize(2,1).*(x(1,:)-FOVsize(2,1)/2);

z = d.*cos(theta);