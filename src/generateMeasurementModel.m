% Function to generate measurement models
% Input:    measModels:     Cell with strings of wanted measurement models
%           mode:           Linear or nonlinear measurement model
% Output:   H:              Measurement models
function H = generateMeasurementModel(measModels,mode)

if strcmp(num2str(mode),'4')
    % Measure position
    H = kron([1 0],eye(2));
elseif(strcmp(num2str(mode),'6'))
    H = kron([1 0],eye(3));
elseif strcmp(mode,'nonlinear')
    % Initiate nonlinear measurement model
    H = @(x,y,z) [];

    % Generate nonlinear measurement models
    for i = 1:size(measModels,2)
        if strcmp(measModels{i},'distance')
            H = @(x,y,z) [H(x,y,z); sqrt(x.^2+y.^2+z.^2)];
        elseif strcmp(measModels{i},'angle')
            H = @(x,y) [H(x,y); atan2(y,x)];
        else
            disp('ERROR: Model not defined')
        end
    end
else
    disp('ERROR: Mode not defined')
end