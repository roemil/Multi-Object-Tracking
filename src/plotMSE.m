function plotMSE(PestVec, squareError,K)

maxEst = size(PestVec,3);

labels = {'$x$','$y$','$v_x$','$v_y$'};

for est = 1:maxEst
    figure;
    for i = 1:4
        subplot(4,1,i)
        plot(1:K,PestVec(i,:,est))
        hold on
        plot(1:K,squareError(i,:,est))
        if i == 1
            leg = legend('Pest','Square error');
            set(leg,'Fontsize',15,'Interpreter','Latex')
        end
        ylabel(labels{i},'Fontsize',15,'Interpreter','Latex')
        xlabel('$k$','Fontsize',15,'Interpreter','Latex')
    end
    suptitle(['MSE, estimate ', num2str(est)])
end