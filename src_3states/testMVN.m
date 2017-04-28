t = [0;0];
mu = [0, 0];
P = 0.5*eye(2);

%x = linspace(mu(1)-3*sqrt(P(1,1)), mu(1)+3*sqrt(P(1,1)),100);
x = linspace(mu(1)-3*sqrt(P(1,1)), t(1),100);
x = [x, linspace(t(1),mu(1)+3*sqrt(P(1,1)),100)];
%y = linspace(mu(2)-3*sqrt(P(2,2)), mu(2)+3*sqrt(P(2,2)),100);
y = linspace(mu(2)-3*sqrt(P(2,2)), t(2),100);
y = [y, linspace(t(2),mu(2)+3*sqrt(P(2,2)),100)];

[X1,X2] = meshgrid(x,y);
Z       = mvnpdf([X1(:) X2(:)],mu,P);

%%
ind = find(ismember([X1(:), X2(:)], t','rows') == 1);

prob = Z(ind(1));
%%
Z       = reshape(Z,length(y),length(x));

% Plot
h = pcolor(x,y,Z);
set(h,'LineStyle','none')
hold on

figure;
surf(X1,X2,Z)