function plotEllips(Z,X,R,H,threshold)

figure;
n = 100;
phi = linspace(0,2*pi,n);
eps = [];
figure;
for j = 1 : size(Z,2)
    for i = 1 : size(X,2)
        eps = Z(j,1:2) - H(1:2,1:4)*X(i).state(1:4); % Innovation
        S = H(1:2,1:4)*X(i).P(1:4,1:4)*H(1:2,1:4)'+R(1:2,1:2); % create inovation variance matrix S
        d = eps'/S*eps; % Mahalanobis distance

        x = repmat(X(i).state(1:2),1,n)+3*sqrtm(S(1:2,1:2))*[cos(phi);sin(phi)];
        plot(x(1,:),x(2,:),'-y','LineWidth',1);
        hold on;
        text(max(x(1,:)),max(x(2,:)),num2str(d))
        plot(X(i).state(1),X(i).state(2),'rx');
        plot(Z(j,1),Z(j,2),'k+')

    end
end

end