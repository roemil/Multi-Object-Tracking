%   Function to transform pixel to camera coords
%   input: pixel coords X, Camera Matrix (P2(1:3,1:3) from calibration
%   and distance to object in m
%   output: 3D coordinates in camera coordinate system%

function X = pixel2cameracoords(x,dist)
global P2;

Pp = pinv(P2);
lambda = P2(3,4);
C = -inv(P2(1:3,1:3))*P2(:,4);
X = Pp * (dist + lambda) * [x;1];
lambda2 = 1-X(4);
X = X + lambda2 * [C;1];
X = X(1:3);%
% X_Pic_1 = [x;1];
% 
% % Now for reverse procedure take arbitrary points in Camera-Picture... 
%  X_Pic_backtransform_1 = X_Pic_1(1:3);
% 
% 
% % ... and transform back following the formula from the Master Thesis (in German):
% % Ilker Savas, "Entwicklung eines Systems zur visuellen Positionsbestimmung von Interaktionspartnern" 
%  M_Mat = P2(1:3,1:3);                 % Matrix M is the "top-front" 3x3 part 
%  p_4 = P2(1:3,4);                     % Vector p_4 is the "top-rear" 1x3 part 
%  C_tilde = - inv( M_Mat ) * p_4;     % calculate C_tilde 
% 
% % Invert Projection with Side-Condition ( Z = distance ) and Transform back to 
% % World-Coordinate-System 
%  X_Tilde_1 = inv( M_Mat ) * X_Pic_backtransform_1; 
% 
% 
%  mue_N_1 = (dist -C_tilde(3)) / X_Tilde_1(3); 
% 
% % Do the inversion of above steps... 
%  X = mue_N_1 * inv( M_Mat ) * X_Pic_backtransform_1 + C_tilde;




end