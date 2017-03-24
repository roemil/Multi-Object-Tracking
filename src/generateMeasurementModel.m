% Function to generate measurement models
% Input:    measModels:     Cell with strings of wanted measurement models
%           mode:           Linear or nonlinear measurement model
% Output:   h:              Measurement models
function h = generateMeasurementModel(measModels,mode)

if strcmp(mode,'linear')
    % Measure position
    h = kron([1 0],eye(2));
elseif strcmp(mode,'nonlinear')
    % Initiate nonlinear measurement model
    h = @(x,y) {};

    % Generate nonlinear measurement models
    for i = 1:size(measModels,2)
        if strcmp(measModels{i},'distance')
            h = @(x,y) [h(x,y); sqrt(x.^2+y.^2)];
        elseif strcmp(measModels{i},'angle')
            h = @(x,y) [h(x,y); atan2(y,x)];
        else
            disp('ERROR: Model not defined')
        end
    end
else
    disp('ERROR: Mode not defined')
end