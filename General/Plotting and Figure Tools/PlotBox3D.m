function PlotBox3D(ZPosition,BoundingBox,LineStyle,LineColor,LineWidth,Text,TextFontSize,TextFontColor)

 plot3([BoundingBox(1),BoundingBox(1)+BoundingBox(3)],[BoundingBox(2),BoundingBox(2)],[ZPosition,ZPosition],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 plot3([BoundingBox(1),BoundingBox(1)+BoundingBox(3)],[BoundingBox(2)+BoundingBox(4),BoundingBox(2)+BoundingBox(4)],[ZPosition,ZPosition],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 plot3([BoundingBox(1),BoundingBox(1)],[BoundingBox(2),BoundingBox(2)+BoundingBox(4)],[ZPosition,ZPosition],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 plot3([BoundingBox(1)+BoundingBox(3),BoundingBox(1)+BoundingBox(3)],[BoundingBox(2),BoundingBox(2)+BoundingBox(4)],[ZPosition,ZPosition],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 
 if ~isempty(Text)
    text(BoundingBox(1)+BoundingBox(3)*0.25,BoundingBox(2)+BoundingBox(4)*0.25,Text,'fontsize',TextFontSize, 'color', TextFontColor);
 end
           