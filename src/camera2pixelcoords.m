%   Function to transform camera to pixel coords
%   input: camera coords X, Camera Matrix P2 from calibration
%   output: 2D coordinates in image plane
%
function x = camera2pixelcoords(X,P)
  % project in image
  if(~isempty(X{1}))
      for i = 1 : size(X,2)
        x{i} = P * [X{i}(1:3); 1];
      % scale projected points
        x{i}(1,:) = x{i}(1,:)./x{i}(3,:);
        x{i}(2,:) = x{i}(2,:)./x{i}(3,:);
        %x{i}(3,:) = [];
        x{i}(4:6) = X{i}(4:end);
      end
  else
      x = cell(1);
  end
end