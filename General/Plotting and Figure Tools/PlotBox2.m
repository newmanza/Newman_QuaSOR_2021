function [P1,P2,P3,P4,T1]=PlotBox2(BoundingBox,LineStyle,LineColor,LineWidth,Text,TextFontSize,TextFontColor)

 P1=plot([BoundingBox(1),BoundingBox(1)+BoundingBox(3)],[BoundingBox(2),BoundingBox(2)],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 P2=plot([BoundingBox(1),BoundingBox(1)+BoundingBox(3)],[BoundingBox(2)+BoundingBox(4),BoundingBox(2)+BoundingBox(4)],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 P3=plot([BoundingBox(1),BoundingBox(1)],[BoundingBox(2),BoundingBox(2)+BoundingBox(4)],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 P4=plot([BoundingBox(1)+BoundingBox(3),BoundingBox(1)+BoundingBox(3)],[BoundingBox(2),BoundingBox(2)+BoundingBox(4)],LineStyle,'color',LineColor,'LineWidth',LineWidth);
 
 if ~isempty(Text)
    T1=text(BoundingBox(1)+BoundingBox(3)*0.25,BoundingBox(2)+BoundingBox(4)*0.25,Text,'fontsize',TextFontSize, 'color', TextFontColor);
 else
     T1=[];
 end
           