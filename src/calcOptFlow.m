function [u,v] = calcOptFlow(C, fr1, fr2,sz)
%w = round(290/2)-1;
%wx = round(sz(1));
%wy = round(sz(2));
%w = (min(wx,wy)/2);
w = sz;
%C = round([376.567 230.234;372.203 226.33]);%;371.272 215.718;368.796 210.409];
C = round(C);
%fr1 = imread(['00000',num2str(1),'.png']);
%fr2 = imread(['00000',num2str(2),'.png']);
im1 = im2double(rgb2gray(fr1));
im2 = im2double(rgb2gray(fr2));
Ix_m = conv2(im1,[-1 1; -1 1], 'valid'); % partial on x
Iy_m = conv2(im1, [-1 -1; 1 1], 'valid'); % partial on y
It_m = conv2(im1, ones(2), 'valid') + conv2(im2, -ones(2), 'valid'); % partial on t

% within window ww * ww
    i = C(2);
    j = C(1);
    if((i-w < 1))
        i = w + 1;
    elseif((i + w > 374))
        i = 373 - w;
    end
    if((j-w < 1))
        j = w + 1;
    elseif((j + w > 1241))
        j = 1240 - w;
    end
    Ix = Ix_m(i-w:i+w, j-w:j+w);
    Iy = Iy_m(i-w:i+w, j-w:j+w);
    It = It_m(i-w:i+w, j-w:j+w);

    Ix = Ix(:);
    Iy = Iy(:);
    It = It(:);
    %b = -It(:); % get b here

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
    nu = pinv(A)*b;

    u = nu(1)/0.1;
    v = nu(2)/0.1;