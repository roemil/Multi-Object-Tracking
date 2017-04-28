function p = likelihood(x,mu, sigma)

% Assume gaussian noise
% x = mu+v, 
% v~N(0,sigma)
% N(x;mu sigma)
p = normpdf(x,mu,sigma);