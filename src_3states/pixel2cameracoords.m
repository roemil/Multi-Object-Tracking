%   Function to transform pixel to camera coords
%   input: pixel coords X, Camera Matrix (P2(1:3,1:3) from calibration
%   and distance to object in m
%   output: 3D coordinates in camera coordinate system
%
%
%
%
%
% R = [9.999758e-01 -5.267463e-03 -4.552439e-03;
%     5.251945e-03 9.999804e-01 -3.413835e-03;
%     4.570332e-03 3.389843e-03 9.999838e-01];

% K = [9.597910e+02 0.000000e+00 6.960217e+02; NOT USED
%     0.000000e+00 9.569251e+02 2.241806e+02;
%     0.000000e+00 0.000000e+00 1.000000e+00];
% P = [7.215377e+02 0.000000e+00 6.095593e+02 4.485728e+01;
%         0.000000e+00 7.215377e+02 1.728540e+02 2.163791e-01;
%         0.000000e+00 0.000000e+00 1.000000e+00 2.745884e-03];
function X = pixel2cameracoords(x,dist)
% R = [9.999758e-01 -5.267463e-03 -4.552439e-03;
%     5.251945e-03 9.999804e-01 -3.413835e-03;
%     4.570332e-03 3.389843e-03 9.999838e-01];
% 
% P = [7.215377e+02 0.000000e+00 6.095593e+02 4.485728e+01;
%         0.000000e+00 7.215377e+02 1.728540e+02 2.163791e-01;
%         0.000000e+00 0.000000e+00 1.000000e+00 2.745884e-03];
% K = P(1:3,1:3);
% %Ki = inv(K);
% %R_World_to_Cam = Ki*P;
% %P = K * R_World_to_Cam; 
% %t = Prect(1:3,4);
% u = x(1);
% v = x(2);
% P_camera = K \ [u, v, 1]';
% 
% t = [5.956621e-02 2.900141e-04 2.577209e-03]';
% Rt_camera_to_world = [R,t];
% C_world = Rt_camera_to_world * [0, 0, 0, 1]';
% P_world = Rt_camera_to_world * [P_camera; 1];
% lambda = dist-C_world(3)/P_world(3);
% P = C_world + lambda * P_world;

P=[7.215377000000e+02, 0.000000000000e+00, 6.095593000000e+02, 4.485728000000e+01;
    0.000000000000e+00, 7.215377000000e+02, 1.728540000000e+02, 2.163791000000e-01;
    0.000000000000e+00, 0.000000000000e+00, 1.000000000000e+00, 2.745884000000e-03];

%X_World_1 = pts_3D
% Transform and Project from 3D-World -> 2D-Picture 
%X_Pic_1 = P * [X_World_1;1]; 
X_Pic_1 = [x;1];

% normalize homogenous Coordinates (3rd Element has to be 1!) 
X_Pic_1(1,:) = X_Pic_1(1,:) / X_Pic_1(3,:);
X_Pic_1(2,:) = X_Pic_1(2,:) / X_Pic_1(3,:);
X_Pic_1(3,:) = X_Pic_1(3,:) / X_Pic_1(3,:);



% Now for reverse procedure take arbitrary points in Camera-Picture... 
% (for simplicity, take points from above and "go" 30px to the right and 40px down) 
 X_Pic_backtransform_1 = X_Pic_1(1:3);% + [30; 40; 0]; 


% ... and transform back following the formula from the Master Thesis (in German):
% Ilker Savas, "Entwicklung eines Systems zur visuellen Positionsbestimmung von Interaktionspartnern" 
 M_Mat = P(1:3,1:3);                 % Matrix M is the "top-front" 3x3 part 
 p_4 = P(1:3,4);                     % Vector p_4 is the "top-rear" 1x3 part 
 C_tilde = - inv( M_Mat ) * p_4;     % calculate C_tilde 

% Invert Projection with Side-Condition ( Z = distance ) and Transform back to 
% World-Coordinate-System 
 X_Tilde_1 = inv( M_Mat ) * X_Pic_backtransform_1; 


 mue_N_1 = dist -C_tilde(3) / X_Tilde_1(3); 


% Do the inversion of above steps... 
 X = mue_N_1 * inv( M_Mat ) * X_Pic_backtransform_1 + C_tilde;




end