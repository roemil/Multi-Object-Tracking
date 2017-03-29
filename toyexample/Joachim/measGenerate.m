function h = measGenerate(X,R)
% Measure distance and angle

%h = [sqrt(X(1)^2+X(2)^2)+normrnd(0,sqrt(R(1)));
%    atan2(X(2),X(1))+normrnd(0,R(2))];
h = [X(1);X(2)] + mvnrnd([0;0],R)';