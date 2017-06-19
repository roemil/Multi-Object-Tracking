%%% Ellipsoidal gating
%%% Input: Measurement Z, Measurement Model H, Predicted states Xest
%%% Output: Subset Z
function [ind] = gatingv3(v, S)

% If within 3sigma
if sqrt(v'/S*v) < 3
    ind = 1;
else
    ind = 0;
end

end