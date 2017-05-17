%%% Ellipsoidal gating
%%% Input: Measurement Z, Measurement Model H, Predicted states Xest
%%% Output: Subset Z
function [ind] = gatingv2(v, S,threshold)

d = v'/S*v; % Mahalanobis distance

ind = find(d < threshold); % Find indices of which measurements fits close
                           % to X
end