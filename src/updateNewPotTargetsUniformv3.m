function [XpotNew, rho, newLabel] = updateNewPotTargetsUniform(XmuPred, nbrOfMeas, ...
    Z, newLabel,motionModel, nbrPosStates, unifdist)
global Pd, global H3dFunc, global Hdistance, global R3dTo2d, global Rdistance, global Jh
global c, global nbrStates, global nbrMeasStates, global H, global R,
global pose, global k, global angles, global FOVsize, global color, global imgpath
global wInit, global angleThresh, global distThresh, global PbirthFunc, global thresholdEst,


rho = zeros(nbrOfMeas,1);
if(color)
    framenbr = sprintf('%06d',k-1);
    img = imread([imgpath,framenbr,'.png']);
end
XpotNew{1} = initiateStruct(color);
for z = 1:nbrOfMeas
      % Test 1! This works ok
%         % TAG: Shall we do this?
%         theta = pi/2 / FOVsize(2,1)*(Z(1,z)-FOVsize(2,1)/2);
%         Pbirth = diag([0.3*FOVsize(2,1) 0.3*FOVsize(2,2) Rdistance(Z(3,z))]);
%         angleThresh = 30*pi/180; % TODO: Move to declareVariables
%         distThresh = 10; % TODO: Move to declareVariables
%         if abs(theta) > angleThresh && Z(3,z) < distThresh
%            Pbirth = 5*Pbirth;
%         end

    % TEST 2
%         theta = pi/2 / FOVsize(2,1)*(Z(1,z)-FOVsize(2,1)/2);
%         Pbirth = diag([0.3*FOVsize(2,1) 0.3*FOVsize(2,2) Rdistance(Z(3,z))]);
%         angleThresh = 30*pi/180; % TODO: Move to declareVariables
%         distThresh = 10; % TODO: Move to declareVariables
%         if Z(3,z) < distThresh % && abs(theta) > angleThresh
%            Pbirth = 1*Pbirth;
%         end

    e = wInit*Pd*mvnpdf(Z(1:2,z), Z(1:2,z), PbirthFunc);
    rho(z) = e+c;
    %log(e+c)
    XpotNew{z}.w = log(e+c); % rho (45) (44)
    XpotNew{z}.r = e/rho(z); % (43) (44)
    %[XpotNew{z}.w XpotNew{z}.r e]
    XpotNew{z}.S = 0;
    XpotNew{z}.box = Z(nbrMeasStates+1:nbrMeasStates+2,z);
    XpotNew{z}.label = newLabel;
    %XpotNew{z}.state = XmuUpd{z}.state;
    XpotNew{z}.state = XmuPred(z).state;
    XpotNew{z}.P = XmuPred(z).P;
    newLabel = newLabel+1;
    if XpotNew{z}.r > thresholdEst
        XpotNew{z}.nbrMeasAss = 1; % TAGass Nbr meas assignments
    else
        XpotNew{z}.nbrMeasAss = 0;
    end
    XpotNew{z}.class = Z(end,z);
    if color
        XpotNew{z}.red = XmuPred(z).red;
        XpotNew{z}.green =  XmuPred(z).green;
        XpotNew{z}.blue =  XmuPred(z).blue;
    end
end
