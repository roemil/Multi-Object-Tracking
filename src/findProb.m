function prob = findProb(Z, mu, P)

x = linspace(mu(1)-3*sqrt(P(1,1)), Z(1),100);
x = [x, linspace(Z(1),mu(1)+3*sqrt(P(1,1)),100)];
%y = linspace(mu(2)-3*sqrt(P(2,2)), mu(2)+3*sqrt(P(2,2)),100);
y = linspace(mu(2)-3*sqrt(P(2,2)), Z(2),100);
y = [y, linspace(Z(2),mu(2)+3*sqrt(P(2,2)),100)];

[X1,X2] = meshgrid(x,y);
probDist       = mvnpdf([X1(:) X2(:)],mu',P);

ind = find(ismember([X1(:), X2(:)], Z','rows') == 1);

probDist       = reshape(probDist,length(y),length(x));

prob = probDist(ind(1));
figure;
surf(X1,X2,probDist)