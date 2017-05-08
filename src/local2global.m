% Function to transform local coordinates to global
% Input: local position x (3x1), Rotation Matrix R (velo-imu)(3x3), 
% translation t (velo-imu)(3x1), ego-position egoPos
% x, y and egoPos has to be on the form [forward, left, up] (velodyn coordinate
% system)

function y = local2global(x,R,t, egoPos)
    y = R*(x+egoPos-t);
end