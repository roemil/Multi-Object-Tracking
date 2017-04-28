%   Function to transform camera to pixel coords
%   input: camera coords X, Camera Matrix P2 from calibration
%   output: 2D coordinates in image plane
%
function x = camera2pixelcoords(X,P)
% project in image
    if(size(X,2) ~= 1)
        X = X';
    end
  %for i = 1 : size(X,2)
    x = P * [X(1:3); 1];
  % scale projected points
    x(1,:) = x(1,:)./x(3,:);
    x(2,:) = x(2,:)./x(3,:);
    x(3,:) = [];
  %end
end