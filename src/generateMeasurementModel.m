% Function to generate measurement models
% Input:    measModels:     Cell with strings of wanted measurement models
%           mode:           Linear or nonlinear measurement model
% Output:   H:              Measurement models
function H = generateMeasurementModel(measModels, mode, motionModel)

if strcmp(mode,'linear')
    if strcmp(motionModel, 'cv')
        % Measure position
        H = kron([1 0],eye(2));
    elseif strcmp(motionModel, 'cvBB')
        H = kron([1 0],eye(2));
        H(3:4,1:6) = [zeros(2,4) eye(2)];
    end
elseif strcmp(mode,'nonlinear')
    % Initiate nonlinear measurement model
    H = @(x,y) [];

    % Generate nonlinear measurement models
    for i = 1:size(measModels,2)
        if strcmp(measModels{i},'distance')
            H = @(x,y) [H(x,y); sqrt(x.^2+y.^2)];
        elseif strcmp(measModels{i},'angle')
            H = @(x,y) [H(x,y); atan2(y,x)];
        else
            disp('ERROR: Model not defined')
        end
    end
else
    disp('ERROR: Mode not defined')
end