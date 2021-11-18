function h = Plot_Circle(x,y,r,LineStyle,Width,LineColor)

hold on

th = 0:pi/50:2*pi;

xunit = r * cos(th) + x;

yunit = r * sin(th) + y;

h = plot(xunit, yunit,LineStyle,'color',LineColor,'LineWidth',Width);

hold off
