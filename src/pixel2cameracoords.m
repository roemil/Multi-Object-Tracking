%   Function to transform pixel to camera coords
%   input: pixel coords X, Camera Matrix (P2(1:3,1:3) from calibration
%   and distance to object in m
%   output: 3D coordinates in camera coordinate system
%
%
%
%
%

function X = pixel2cameracoords(x, K,distance)
    X = K\[x;1]*distance;
end