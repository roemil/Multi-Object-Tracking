function [XpotNew, rho, newLabel] = updateNewPotTargetsUniform(XmuPred, nbrOfMeas, ...
    Z, newLabel,motionModel, nbrPosStates, unifdist)
global Pd, global H3dFunc, global Hdistance, global R3dTo2d, global Rdistance, global Jh
global c, global nbrStates, global nbrMeasStates, global H, global R,
global pose, global k, global angles, global FOVsize

    rho = zeros(nbrOfMeas,1);
    
    for z = 1:nbrOfMeas
        
        % TAG: Shall we do this?
        theta = pi/2 / FOVsize(2,1)*(Z(1,z)-FOVsize(2,1)/2);
        Pbirth = diag([0.1*FOVsize(2,1) 0.3*FOVsize(2,2) Rdistance(Z(3,z))]);
        angleThresh = 30*pi/180; % TODO: Move to declareVariables
        distThresh = 10; % TODO: Move to declareVariables
        if abs(theta) > angleThresh && Z(3,z) < distThresh
           Pbirth = 5*Pbirth;
        end
        
        e = Pd*mvnpdf(Z(1:3,z), Z(1:3,z), Pbirth);
        rho(z) = e+c;
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
        XpotNew{z}.nbrMeasAss = 1; % TAGass Nbr meas assignments
    end
end