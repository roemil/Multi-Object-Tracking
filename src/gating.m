%%% Ellipsoidal gating
%%% Input: Measurement Z, Measurement Model H, Predicted states Xest
%%% Output: Subset Z
function [ind] = gating(Z, H, X, R, threshold)
eps = zeros(2,size(X,2));
d = zeros(1,size(X,2));
for i = 1 : size(X,2)
    eps(:,i) = Z(1:2) - H*X(i).state(1:4); % Innovation
    S = H*X(i).P*H'+R; % create inovation variance matrix S
    d(i) = eps(:,i)'/S*eps(:,i); % Mahalanobis distance
end

ind = find(d < threshold); % Find indices of which measurements fits close
                           % to X
end