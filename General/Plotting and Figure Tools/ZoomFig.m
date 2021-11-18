function ZoomFig(FigHandle,ZoomFactor)

Position=get(FigHandle,'OuterPosition');
set(FigHandle,'OuterPosition',[Position(1),Position(2),Position(3)*ZoomFactor,Position(4)*ZoomFactor])
Ratio=Position(3)/Position(4);

set(FigHandle,'units','centimeters');
set(FigHandle,'papersize',[Position(3)*ZoomFactor/3,Position(4)*ZoomFactor/3]);
set(FigHandle,'paperposition',[0,0,Position(3)*ZoomFactor/3,Position(4)*ZoomFactor/3]);



end