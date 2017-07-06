function plotGOSPA(meanCNN, meanPMBM,fpCNN, fpPMBM, fnCNN, fnPMBM)

figure;
%for i = 1 : size(meanCNN,2)
    plot(0:size(meanCNN,2)-1,cell2mat(meanCNN),'r+','Markersize',15,'linewidth',1); hold on;
    plot(0:size(meanPMBM,2)-1,cell2mat(meanPMBM),'k.-','Markersize',15);
%end
title('GOSPA per Sequence','Interpreter','Latex','Fontsize',20)
xlabel('Sequence','Fontsize',20,'Interpreter','Latex')
ylabel('Average GOSPA','Fontsize',20,'Interpreter','Latex')
legend({'CNN','PMBM'},'Fontsize',20,'Interpreter','Latex','Location','Northwest')
figure;
%for i = 1 : size(meanCNN,2)
    plot(0:size(meanCNN,2)-1,cell2mat(fpCNN),'r+','Markersize',15,'linewidth',1); hold on;
    plot(0:size(meanPMBM,2)-1, cell2mat(fpPMBM),'k.-','Markersize',15);
%end
title('FP per Sequence','Interpreter','Latex','Fontsize',20)
xlabel('Sequence','Fontsize',20,'Interpreter','Latex')
ylabel('Number of False Positives','Fontsize',20,'Interpreter','Latex')
legend({'CNN','PMBM'},'Fontsize',20,'Interpreter','Latex','Location','Northwest')
figure;
%for i = 1 : size(meanCNN,2)
    plot(0:size(meanCNN,2)-1, cell2mat(fnCNN),'r+','Markersize',15,'linewidth',1); hold on;
    plot(0:size(meanPMBM,2)-1, cell2mat(fnPMBM),'k.-','Markersize',15);
%end
title('FN  per Sequence','Interpreter','Latex','Fontsize',20)
xlabel('Sequence','Fontsize',20,'Interpreter','Latex')
ylabel('Number of False Negatives','Fontsize',20,'Interpreter','Latex')
legend({'CNN','PMBM'},'Fontsize',20,'Interpreter','Latex','Location','Northwest')
end