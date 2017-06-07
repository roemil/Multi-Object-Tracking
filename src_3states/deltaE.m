function dE = deltaE(L1,a1,b1, L2,a2,b2)

dE = sqrt((L1-L2).^2 + (a1-a2).^2 + (b1-b2).^2);

end