% opticFlow = opticalFlowLK('NoiseThreshold',0.009);
% 
for i = 0 : 153
    if i < 10
        frameName = ['00000',num2str(i),'.png'];
    elseif i < 100
        frameName = ['0000',num2str(i),'.png'];
    else
        frameName = ['000',num2str(i),'.png'];
    end
    img = imread(frameName);
    imgGray = rgb2gray(img);
    
    flow = estimateFlow(opticFlow,imgGray);
    
    imshow(img);
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    hold off;
    waitforbuttonpress;
end

%%
w = round(40/2);

%C = round([376.567 230.234]);%;372.203 226.33]);%;371.272 215.718;368.796 210.409]
%C = round([368.796 210.409]);
%C = C'

%figure('units','normalized','position',[.05 .05 .9 .9]);
%for i = 2 : size(Z,2)
k = 2;
while 1
    C(1) = Z{k}(1,1);
    C(2) = Z{k}(2,1);
    if(k < 10)
        fr1 = imread(['../../kittiTracking/training/image_02/',sequence,'/','00000',num2str(k-1),'.png']);
        fr2 = imread(['../../kittiTracking/training/image_02/',sequence,'/','00000',num2str(k),'.png']);
    elseif(k == 10)
        fr1 = imread(['../../kittiTracking/training/image_02/',sequence,'/','00000',num2str(k-1),'.png']);
        fr2 = imread(['../../kittiTracking/training/image_02/',sequence,'/','0000',num2str(k),'.png']);
    elseif(k < 100)
        fr1 = imread(['../../kittiTracking/training/image_02/',sequence,'/','0000',num2str(k-1),'.png']);
        fr2 = imread(['../../kittiTracking/training/image_02/',sequence,'/','0000',num2str(k),'.png']);
    end
        for ind = 1 : 5
            im1 = im2double(rgb2gray(fr1));
            im2 = im2double(rgb2gray(fr2));
            Ix_m = conv2(im1,[-1 1; -1 1], 'valid'); % partial on x
            Iy_m = conv2(im1, [-1 -1; 1 1], 'valid'); % partial on y
            It_m = conv2(im1, ones(2), 'valid') + conv2(im2, -ones(2), 'valid'); % partial on t
        %u = zeros(length(C),1);
        %v = zeros(length(C),1);
        %
        % within window ww * ww
        %for k = 1:1%length(C(:,2))
            %i = C(k,2);
            %j = C(k,1);
            i = C(2);
            j = C(1);
            if((i-w < -0 || i + w > 374))
                i = 373 - w;
            end
            if((j-w < -0 || j + w > 1241))
                j = 1240 - w;
            end
            Ix = Ix_m(i-w:i+w, j-w:j+w);
            Iy = Iy_m(i-w:i+w, j-w:j+w);
            It = It_m(i-w:i+w, j-w:j+w);

            Ix = Ix(:);
            Iy = Iy(:);
            %b = -It(:); % get b here
            It = It(:);

            %A = [Ix Iy]; % get A here
            A = [];
            A(1,1) = sum(Ix.*Ix);
            A(1,2) = sum(Ix.*Iy);
            A(2,1) = sum(Ix.*Iy);
            A(2,2) = sum(Iy.*Iy);
            b = [];
            b(1,1) = sum(Ix.*It);
            b(2,1) = sum(Iy.*It);
            b = -b;
            nu = pinv(A)*b;

           %u(k)=nu(1);
           %v(k)=nu(2);
            u = nu(1)/0.1;
            v = nu(2)/0.1;
            im1 = im1 + repmat([u,v],size(im1,1),size(im1,2)/2);

        end
    %end;
%
    %
    imshow(fr2);
    hold on;
    %quiver(C(:,1), C(:,2), u,v, 1,'r')
    quiver(C(1), C(2), u,v, 1,'r');hold on;
    Z{k}(1,1) - Z{k-1}(1,1)
    Z{k}(2,1) - Z{k-1}(2,1)
    title(['k = ', num2str(k)])
    try
        waitforbuttonpress; 
    catch
        fprintf('Window closed. Exiting...\n');
        break
    end
    key = get(gcf,'CurrentCharacter');
    switch lower(key)  
        case 'a'
            k = k - 1;
        case 'l'
            k = k + 1;
    end
end