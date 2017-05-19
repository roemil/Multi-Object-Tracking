% 
% 
% datapath = strcat('../../kittiTracking/','training','/','label_02/','0000');
% filename = [datapath,'.txt'];
% formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
% f = fopen(filename);
% GT = textscan(f,formatSpec);
% fclose(f);
% global P2;
% P2 =[7.215377e+02 0.000000e+00 6.095593e+02 4.485728e+01;
%     0.000000e+00 7.215377e+02 1.728540e+02 2.163791e-01; 
%     0.000000e+00 0.000000e+00 1.000000e+00 2.745884e-03];
% %%
% 
% 
% ind = 3;
% cx = mean([GT{7}(ind),GT{9}(ind)],2)';
% cy = mean([GT{8}(ind),GT{10}(ind)],2)';
% x = [cx;cy;sqrt(GT{14}(ind)'.^2 + (GT{15}(ind)-GT{11}(ind)/2)'.^2 + GT{16}(ind)'.^2)];
% x(3) = 1;
% 
% X = pinv(P2)*x;
% C=null(P2);
% C=C/C(4);
% L=joinPL(X,C)
% 
% 
% 
% 
% %%
% X_Pic_backtransform_1 = camera2pixelcoords([GT{14}(3)'; (GT{15}(3)-GT{11}(3)/2)'; GT{16}(3)'],P2);
%  M_Mat = P2(1:3,1:3);                 % Matrix M is the "top-front" 3x3 part 
%  p_4 = P2(1:3,4);                     % Vector p_4 is the "top-rear" 1x3 part 
%  C_tilde = - inv( M_Mat ) * p_4;     % calculate C_tilde 
% 
% % Invert Projection with Side-Condition ( Z = distance ) and Transform back to 
% % World-Coordinate-System 
%  X_Tilde_1 = inv( M_Mat ) * X_Pic_backtransform_1; 
% 
% 
%  mue_N_1 = (X_Pic_backtransform_1(3) -C_tilde(3)) / X_Tilde_1(3); 
% 
% % Do the inversion of above steps... 
%  X = mue_N_1 * inv( M_Mat ) * X_Pic_backtransform_1 + C_tilde;
% 
% figure('units','normalized','position',[.05 .05 .9 .9]);
% for k = 1:50
%     frameNbr = sprintf('%06d',k-1);
%     ind = find(GT{1} == k-1 & GT{2} ~= -1);
%     if(k > 1)
%         delete(p1);delete(p2);
%     end
%     cx = mean([GT{7}(ind),GT{9}(ind)],2)';
%     cy = mean([GT{8}(ind),GT{10}(ind)],2)';
%     GTpix = [cx;cy;sqrt(GT{14}(ind)'.^2 + (GT{15}(ind)-GT{11}(ind)/2)'.^2 + GT{16}(ind)'.^2)];
%     true = [GT{14}(ind)'; (GT{15}(ind)-GT{11}(ind)/2)'; GT{16}(ind)'];
%     X = zeros(size(true));
%     x = zeros(size(true));
%     for i = 1 : size(GTpix,2)
%         X(:,i) = camera2pixelcoords(true(:,i),P2);
%         %x(:,i) = pixel2cameracoords(X(1:2,i),X(3,i));
%         alpha = atan(GTpix(2,i)/GTpix(1,i));
%         x(:,i) = pixel2cameracoords(GTpix(1:2,i),GTpix(3,i));
%         %x(:,i) = mue_N_1 * inv( M_Mat ) * GTpix(:,i) + C_tilde;
%         %tmp = x(2,i);
%         %x(2,i) = x(3,i);
%         %x(3,i) = tmp;
%     end
%     %for i = 1 : size(x,2)
%     p1 = plot3(x(1,:),x(2,:),x(3,:),'rx','markersize',30);hold on
%     p2 = plot3(true(1,:),true(2,:),true(3,:),'g+','markersize',30);
%     xlabel('x')
%     ylabel('y')
%     zlabel('z')
%     title(['k = ', num2str(k)])
%     waitforbuttonpress 
%     %end
%     
%     %estGTdiff('0000','training',k,X,true,false);
% 
% 
%     %pause(1.5)
% end
% 
%%
function checkBirth(XmuPred,Z,P2)
    figure;
    for i = 1 : size(XmuPred,2)
        plot(camera2pixelcoords(XmuPred(i).state(1:3),P2),'+');hold on
        plot(Z(1,i),Z(2,i),'g*');
    end
end

