%   Function to transform camera to pixel coords
%   input: camera coords X, Camera Matrix P2 from calibration
%   output: 2D coordinates in image plane
%
function x = camera2pixelcoords(X,P)
  % project in image
  x = P * [X; ones(1,size(pts_3D,2))];
  % scale projected points
  x(1,:) = x(1,:)./x(3,:);
  x(2,:) = x(2,:)./x(3,:);
  x(3,:) = [];
end