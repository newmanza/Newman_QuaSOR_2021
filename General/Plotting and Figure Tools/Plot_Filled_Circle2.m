function h = Plot_Filled_Circle2(x,y,r,Color,BorderOn,LineStyle,LineWidth,LineColor)

hold on
th = linspace(0,2*pi);
x = r * cos(th) + x;
y = r * sin(th) + y;
patch(x,y,Color);
if BorderOn
    th1 = 0:pi/50:2*pi;
    xunit = r * cos(th1) + x;
    yunit = r * sin(th1) + y;
    h = plot(xunit, yunit,LineStyle,'color',LineColor,'LineWidth',LineWidth);
end
hold off

