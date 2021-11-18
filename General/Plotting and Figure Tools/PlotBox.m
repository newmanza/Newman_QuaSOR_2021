function  PlotBox(BoundingBox,LineStyle,LineColor,LineWidth,Text,TextFontSize,TextFontColor)

 plot([BoundingBox(1),BoundingBox(1)+BoundingBox(3)],[BoundingBox(2),BoundingBox(2)],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 plot([BoundingBox(1),BoundingBox(1)+BoundingBox(3)],[BoundingBox(2)+BoundingBox(4),BoundingBox(2)+BoundingBox(4)],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 plot([BoundingBox(1),BoundingBox(1)],[BoundingBox(2),BoundingBox(2)+BoundingBox(4)],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 plot([BoundingBox(1)+BoundingBox(3),BoundingBox(1)+BoundingBox(3)],[BoundingBox(2),BoundingBox(2)+BoundingBox(4)],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 
 if ~isempty(Text)
    text(BoundingBox(1)+BoundingBox(3)*0.5,BoundingBox(2)+BoundingBox(4)*025,Text,'fontsize',TextFontSize, 'color', TextFontColor,...
        'horizontalAlignment','center','verticalalignment','middle');
 end
           