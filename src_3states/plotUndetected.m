function plotUndetected(Xmu, plotCurrent)

if nargin == 2
    fig = get(groot,'CurrentFigure');
    figure(fig);
else
    figure;
end
hold on
for i = 1:size(Xmu,2)
    plot(Xmu(i).state(1), Xmu(i).state(2),'c*')
end