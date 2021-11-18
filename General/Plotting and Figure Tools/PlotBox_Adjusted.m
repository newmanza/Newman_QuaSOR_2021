function PlotBox_Adjusted(BoundingBox,LineStyle,LineColor,LineWidth,Text,TextFontSize,TextFontColor)

BoundingBox(1)=BoundingBox(1)-0.5;
BoundingBox(2)=BoundingBox(2)-0.5;
BoundingBox(3)=BoundingBox(3);
BoundingBox(4)=BoundingBox(4);

 plot([BoundingBox(1),BoundingBox(1)+BoundingBox(3)],[BoundingBox(2),BoundingBox(2)],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 plot([BoundingBox(1),BoundingBox(1)+BoundingBox(3)],[BoundingBox(2)+BoundingBox(4),BoundingBox(2)+BoundingBox(4)],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 plot([BoundingBox(1),BoundingBox(1)],[BoundingBox(2),BoundingBox(2)+BoundingBox(4)],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 plot([BoundingBox(1)+BoundingBox(3),BoundingBox(1)+BoundingBox(3)],[BoundingBox(2),BoundingBox(2)+BoundingBox(4)],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 
 if ~isempty(Text)
    text(BoundingBox(1)+BoundingBox(3)*0.25,BoundingBox(2)+BoundingBox(4)*0.25,Text,'fontsize',TextFontSize, 'color', TextFontColor);
 end
           