% converts a list of oxts measurements into metric poses,
% starting at (0,0,0) meters, OXTS coordinates are defined as
% x = forward, y = right, z = down (see OXTS RT3000 user manual)
% afterwards, pose{i} contains the transformation which takes a
% 3D point in the i'th frame and projects it into the oxts
% coordinates of the first frame.

function [varargout] = egoPosition(varargin)

%oxts, k,Tr_0_inv
if nargin == 3 
    oxts = varargin{1};
    k = varargin{2};
    Tr_0_inv = varargin{3};
elseif nargin == 2 
    oxts = varargin{1};
    k = varargin{2};
    Tr_0_inv = [];
elseif nargin == 1
    oxts = varargin{1};
    Tr_0_inv = [];
else
    disp('Wrong number of input arguments. Should be 2 or 3');
    return;
end

% compute scale from first lat value
scale = latToScale(oxts{1}(1));

% init pose
pose     = [];
heading = [];
posAcc = [];
%Tr_0_inv = [];

% for all oxts packets do
for i=1:size(oxts{1},1)
%for i = 1 : 1
%    i = k;
  % if there is no data => no pose
  if isempty(oxts{1}(i,1))
    pose{i} = [];
    heading{i} = [];
    continue;
  end

  % translation vector
  [t(1,1) t(2,1)] = latlonToMercator(oxts{1}(i,1),oxts{1}(i,2),scale);
  t(3,1) = oxts{1}(i,3);

  % rotation matrix (OXTS RT3000 user manual, page 71/92)
  rx = oxts{1}(i,4); % roll
  ry = oxts{1}(i,5); % pitch
  rz = oxts{1}(i,6); % heading 
  Rx = [1 0 0; 0 cos(rx) -sin(rx); 0 sin(rx) cos(rx)]; % base => nav  (level oxts => rotated oxts)
  Ry = [cos(ry) 0 sin(ry); 0 1 0; -sin(ry) 0 cos(ry)]; % base => nav  (level oxts => rotated oxts)
  Rz = [cos(rz) -sin(rz) 0; sin(rz) cos(rz) 0; 0 0 1]; % base => nav  (level oxts => rotated oxts)
  R  = Rz*Ry*Rx;
  angles{i}.roll = rx;
  angles{i}.pitch = ry;
  angles{i}.heading = rz;
  %normalize translation and rotation (start at 0/0/0)
  if isempty(Tr_0_inv) %&& k == 1
   Tr_0_inv = inv([R t;0 0 0 1]);
  end
      
  % add pose
  pose{i} = Tr_0_inv*[R t;0 0 0 1];
  %varargout{1} = pose%Tr_0_inv*[R t;0 0 0 1];
  %if(k==1)
      %varargout{2} = Tr_0_inv;
  %end
    posAcc{i} = oxts{1}(i,24);
end
varargout{1} = pose;
varargout{2} = angles;
varargout{3} = posAcc;