function [FigureHandle] = ImageSCMapBeautifier(FigureHandle,ImageData,ColorLimits,ImageTitle,AllBoutonsRegion,ScaleBar,UseColorBar,SaveDir,StackSaveName)

% use [] for no region or scale bar and 0 for no colorbar
% ImageSCMapBeautifier(OneImage_DeltaGFP_norm_Mean,[],'Mean Response',AllBoutonsRegion,ScaleBar,1,SaveDir,StackSaveName,{'.fig','.tif'});
% ImageSCMapBeautifier(OneImage_DeltaGFP_norm_Mean,[],'Mean Response',AllBoutonsRegion,ScaleBar,1,SaveDir,StackSaveName,{'.fig','.tif','.eps'});
% SaveFormats={'.fig','.tif','.eps'};

ScreenSize=get(0,'ScreenSize');

sigDig=3;

EnlargeFactor=1;
ZoomFactor=10;
colormap('jet')

iptsetpref('ImshowBorder','tight');
subtightplot(1,1,1);
%plot figure
%FigureHandle=figure();
if isempty(ColorLimits)
    EmptyColorLim=1;
    imagesc(ImageData);
    ColorLimits(1)=max(max(ImageData));
    ColorLimits(2)=min(min(ImageData));
else
    if isnan(ColorLimits(1))
        warning('NaN Lower Colorlimit! Fixing!')
        ColorLimits(1)=0;
    end
    if isnan(ColorLimits(2))
        warning('NaN Upper Colorlimit! Fixing!')
        ColorLimits(2)=1;
    end
    if ColorLimits(2)~=ColorLimits(1)
        imagesc(ImageData,[ColorLimits(1) ColorLimits(2)]);
    else
        imagesc(ImageData);
    end
    EmptyColorLim=0;
end

%Manipulate Basic Display properties
hold on
axis equal tight;
title(strcat(StackSaveName,' ',ImageTitle),'Interpreter','none');
if UseColorBar~=0
    hcb=colorbar;
    if EmptyColorLim==1
        [ColorBarMin,ColorBarMax]=ColorBarMaxMin(ImageData,sigDig);
        if ColorBarMax~=ColorBarMin
            if abs(ColorLimits(1))==abs(ColorLimits(2))&&ColorBarMax~=0
                set(hcb,'YTick',[-1*ColorBarMax ColorBarMax]);
            else
                set(hcb,'YTick',[ColorBarMin ColorBarMax]);
            end
        end
    else
        ColorBarMin=ColorLimits(1);ColorBarMax=ColorLimits(2);
        if ColorBarMax~=ColorBarMin
            if abs(ColorLimits(1))==abs(ColorLimits(2))&&ColorBarMax~=0
                set(hcb,'YTick',[-1*ColorBarMax ColorBarMax]);
            else
                set(hcb,'YTick',[ColorBarMin ColorBarMax]);
            end
        end
    end
end
set(gcf, 'color', 'white');
set(gca,'XTick', []); 
set(gca,'YTick', []);
if ~isempty(AllBoutonsRegion)
    AllBoutonsRegionPerim = bwperim(AllBoutonsRegion);
    [BorderY BorderX] = find(AllBoutonsRegionPerim);
    plot(BorderX, BorderY,['s',ScaleBar.Color], 'MarkerFaceColor', ScaleBar.Color, 'MarkerSize', 2);
end
if ~isempty(ScaleBar)
    plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',ScaleBar.Width);
end

    %Resize properties
    TempFigPosition=get(gcf,'OuterPosition');
    ImageWidth=size(ImageData,2);
    ImageHeight=size(ImageData,1);
    ScaleFactor=ImageWidth/ImageHeight;

        ScaledWidth=ScaleFactor*EnlargeFactor;
        ScaledHeight=1*EnlargeFactor;

    %Resposition
    %set(gca,'units','normalized','position',[0,0,1,1])
    set(gcf,'units','centimeters');
    set(gcf, 'Position', [0,ScreenSize(4),ScaledWidth*ZoomFactor,ScaledHeight*ZoomFactor]);
    %Resize
    set(gcf,'units','centimeters');
    set(gcf,'papersize',[ScaledWidth,ScaledHeight]);
    set(gcf,'paperposition',[0.1,0.1,ScaledWidth,ScaledHeight]);

hold off
iptsetpref('ImshowBorder','loose');







%Here is a condensed version to use in scripts
% 
% SaveFormats={'.fig','.tif','.eps'};
% ScreenSize=get(0,'ScreenSize');iptsetpref('ImshowBorder','tight');TempFig=figure();hold on;
% %%%%%%%%%%%%%%%%
% ImageTitle='';
% 
% imagesc(ImageData);
% 
% %%%%%%%%%%%%%%%%
% axis equal tight;title(strcat(StackSaveName,' ',ImageTitle),'Interpreter','none');colorbar; set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
% %Plot borders
% if ~isempty(AllBoutonsRegion)
%     AllBoutonsRegionPerim = bwperim(AllBoutonsRegion);[BorderY BorderX] = find(AllBoutonsRegionPerim);plot(BorderX, BorderY,'sw', 'MarkerFaceColor', 'w', 'MarkerSize', 2);
% end
% %plot scale bar
% if ~isempty(ScaleBar)
%     plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',ScaleBar.Width);
% end
% TempFigPosition=get(gcf,'OuterPosition');ImageWidth=size(ImageData,2);ImageHeight=size(ImageData,1);ScaleFactor=ImageWidth/ImageHeight;ScaledWidth=ScaleFactor*2;ScaledHeight=1*2;set(gcf, 'Position', [0,ScreenSize(4),ScaledWidth*100,ScaledHeight*100]);set(gcf,'units','centimeters');set(gcf,'papersize',[ScaledWidth,ScaledHeight]);set(gcf,'paperposition',[0,0,ScaledWidth,ScaledHeight]);hold off;iptsetpref('ImshowBorder','loose');
% for i=1:length(SaveFormats); if strcmp(SaveFormats{i},'.eps'); saveas(gcf, [SaveDir , dc , StackSaveName , ' ',ImageTitle , SaveFormats{i}],'epsc');else saveas(gcf, [SaveDir , dc , StackSaveName , ' ',ImageTitle , SaveFormats{i}]); end; end;
% 






end

