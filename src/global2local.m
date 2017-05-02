% Function to transform global coordinates to local
% Input: global position x, Rotation Matrix R (imu-velo), 
% translation t (imu-velo)
% x and y has to be on the form [forward, left, up] (velodyn coordinate
% system)
function y = global2local(x,R,t)
    y = R*x+t;
end