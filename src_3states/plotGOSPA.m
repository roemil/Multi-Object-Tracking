function plotGOSPA(meanCNN, meanPMBM,fpCNN, fpPMBM, fnCNN, fnPMBM)

figure;
%for i = 1 : size(meanCNN,2)
    plot(cell2mat(meanCNN),'r+','Markersize',15); hold on;
    plot(cell2mat(meanPMBM),'k.-','Markersize',15);
%end
title('GOSPA per Sequence','Interpreter','Latex','Fontsize',20)
xlabel('Sequence i','Fontsize',20)
ylabel('Average GOSPA','Fontsize',20)
legend({'CNN','PMBM'},'Fontsize',20)
figure;
%for i = 1 : size(meanCNN,2)
    plot(cell2mat(fpCNN),'r+','Markersize',15); hold on;
    plot(cell2mat(fpPMBM),'k.-','Markersize',15);
%end
title('FP per Sequence','Interpreter','Latex','Fontsize',20)
xlabel('Sequence i','Fontsize',20)
ylabel('Number of False Positives','Fontsize',20)
legend({'CNN','PMBM'},'Fontsize',20)
figure;
%for i = 1 : size(meanCNN,2)
    plot(cell2mat(fnCNN),'r+','Markersize',15); hold on;
    plot(cell2mat(fnPMBM),'k.-','Markersize',15);
%end
title('FN  per Sequence','Interpreter','Latex','Fontsize',20)
xlabel('Sequence i','Fontsize',20)
ylabel('Number of False Negatives','Fontsize',20)
legend({'CNN','PMBM'},'Fontsize',20)
end