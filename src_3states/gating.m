%%% Ellipsoidal gating
%%% Input: Measurement Z, Measurement Model H, Predicted states Xest
%%% Output: Subset Z
function [ind] = gating(Z, H, P, X,threshold)
eps = [];
for i = 1 : size(X,2)
    eps(:,i) = Z - H*X(i).state(1:4,i); % Innovation
    S = H*P*H'+R; % create inovation variance matrix S
    d(i) = eps(:,i)'/S*eps(:,i); % Mahalanobis distance
end

ind = find(d < threshold); % Find indices of which measurements fits close
                           % to X
end