function plotGOSPA(meanCNNwS, meanPMBMwS, meanPMBMwoS)
x = 0 : 20;
figure;
%for i = 1 : size(meanCNN,2)
plot(x,cell2mat(meanCNNwS),'r+','Markersize',15); hold on;
plot(x,cell2mat(meanPMBMwS),'k.-','Markersize',15);
plot(x,cell2mat(meanPMBMwoS),'c.-','Markersize',15);
%plot(x,cell2mat(meanPMBM5),'m.-','Markersize',15);
%end
title('Average \texttt{GOSPA} Score per Sequence','Interpreter','Latex','Fontsize',20)
xlabel('Sequence','Interpreter','Latex','Fontsize',20)
ylabel('Average \texttt{GOSPA}','Interpreter','Latex','Fontsize',20)
legend({'CNN','PMBM with SimScore','PMBM without SimScore'},'Fontsize',20,'Location','NorthWest')
% figure;
% %for i = 1 : size(meanCNN,2)
% plot(x,cell2mat(fpCNN),'r+','Markersize',15); hold on;
% plot(x,cell2mat(fpPMBM),'k.-','Markersize',15);
% %end
% title('FP per Sequence','Interpreter','Latex','Fontsize',20)
% xlabel('Sequence','Fontsize',20)
% ylabel('Number of False Positives','Fontsize',20)
% legend({'CNN','PMBM'},'Fontsize',20)
% figure;
% %for i = 1 : size(meanCNN,2)
% plot(x,cell2mat(fnCNN),'r+','Markersize',15); hold on;
% plot(x,cell2mat(fnPMBM),'k.-','Markersize',15);
% %end
% title('FN  per Sequence','Interpreter','Latex','Fontsize',20)
% xlabel('Sequence','Fontsize',20)
% ylabel('Number of False Negatives','Fontsize',20)
% % legend({'CNN','PMBM'},'Fontsize',20)
% =======
%     plot(0:size(meanCNN,2)-1,cell2mat(meanCNN),'r+','Markersize',15,'linewidth',1); hold on;
%     plot(0:size(meanPMBM,2)-1,cell2mat(meanPMBM),'k.-','Markersize',15);
% %end
% title('GOSPA per Sequence','Interpreter','Latex','Fontsize',20)
% xlabel('Sequence','Fontsize',20,'Interpreter','Latex')
% ylabel('Average GOSPA','Fontsize',20,'Interpreter','Latex')
% legend({'CNN','PMBM'},'Fontsize',20,'Interpreter','Latex','Location','Northwest')
% figure;
% %for i = 1 : size(meanCNN,2)
%     plot(0:size(meanCNN,2)-1,cell2mat(fpCNN),'r+','Markersize',15,'linewidth',1); hold on;
%     plot(0:size(meanPMBM,2)-1, cell2mat(fpPMBM),'k.-','Markersize',15);
% %end
% title('FP per Sequence','Interpreter','Latex','Fontsize',20)
% xlabel('Sequence','Fontsize',20,'Interpreter','Latex')
% ylabel('Number of False Positives','Fontsize',20,'Interpreter','Latex')
% legend({'CNN','PMBM'},'Fontsize',20,'Interpreter','Latex','Location','Northwest')
% figure;
% %for i = 1 : size(meanCNN,2)
%     plot(0:size(meanCNN,2)-1, cell2mat(fnCNN),'r+','Markersize',15,'linewidth',1); hold on;
%     plot(0:size(meanPMBM,2)-1, cell2mat(fnPMBM),'k.-','Markersize',15);
% %end
% title('FN  per Sequence','Interpreter','Latex','Fontsize',20)
% xlabel('Sequence','Fontsize',20,'Interpreter','Latex')
% ylabel('Number of False Negatives','Fontsize',20,'Interpreter','Latex')
% legend({'CNN','PMBM'},'Fontsize',20,'Interpreter','Latex','Location','Northwest')
% >>>>>>> master
end