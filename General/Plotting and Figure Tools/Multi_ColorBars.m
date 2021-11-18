function Multi_ColorBars(Channel_Labels,Channel_Colors,ColorScalar,YScalar,Contrast_Data,SaveDir,dc,ExportName)

    MetricLabelFontSize=18;
    MetricScaleFontSize=14;

    figure
    set(gcf,'position',[0,50,800,500])
    for c=1:length(Channel_Labels)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subtightplot(1,length(Channel_Labels),c)
        hold on
        box off
        axis off
        if ischar(Channel_Colors{c})
            if length(Channel_Colors{c})==1
                Temp_cMap=makeColorMap([0 0 0],ColorDefinitions(Channel_Colors{c}),ColorScalar);
            else
                if any(contains(Channel_Colors{c},'jet'))
                    Temp_cMap=jet(ColorScalar);
                elseif any(contains(Channel_Colors{c},'parula'))
                    Temp_cMap=parula(ColorScalar);
                elseif any(contains(Channel_Colors{c},'hot'))
                    Temp_cMap=hot(ColorScalar);
                elseif any(contains(Channel_Colors{c},'cool'))
                    Temp_cMap=cool(ColorScalar);
                elseif any(contains(Channel_Colors{c},'spring'))
                    Temp_cMap=spring(ColorScalar);
                elseif any(contains(Channel_Colors{c},'summer'))
                    Temp_cMap=summer(ColorScalar);
                elseif any(contains(Channel_Colors{c},'autumn'))
                    Temp_cMap=autumn(ColorScalar);
                elseif any(contains(Channel_Colors{c},'winter'))
                    Temp_cMap=winter(ColorScalar);
                elseif any(contains(Channel_Colors{c},'gray'))||any(contains(Channel_Colors{c},'grays'))
                    Temp_cMap=gray(ColorScalar);
                else
                    warning('Missing Color Code Needs to be [0,1,1], r or jet/parula/hot/gray')
                    error('Fix Color Code...')
                end
            end
        elseif length(Channel_Colors{c})==3
            Temp_cMap=makeColorMap([0 0 0],Channel_Colors{c},ColorScalar);
        else
            warning('Missing Color Code Needs to be [0,1,1], r or jet/parula/hot/gray')
            error('Fix Color Code...')
        end
        ColorScarlarWidth=ColorScalar/5;
        ColorMapImage=zeros(ColorScalar,ColorScarlarWidth,3);
        for yy=1:ColorScalar
            ColorMapImage(yy,1,:)=Temp_cMap(yy,:);
        end
        for xx=2:ColorScarlarWidth
            ColorMapImage(:,xx,:)=ColorMapImage(:,1,:);
        end
        ColorMapImage=flipud(ColorMapImage);
        imshow(double(ColorMapImage),...
            'border','tight');
        set(gca,'xtick',[]),set(gca,'ytick',[])
        text(-1*ColorScarlarWidth, ColorScalar/2,Channel_Labels{c},...
            'verticalalignment','middle',...
            'horizontalalignment','right',...
            'color','k','fontname','arial','fontsize',MetricLabelFontSize,'Interpreter','none')
        text(-0.1*ColorScarlarWidth, ColorScalar, num2str(Contrast_Data(c).MinVal),...
            'verticalalignment','middle',...
            'horizontalalignment','right',...
            'color','k','fontname','arial','fontsize',MetricScaleFontSize,'Interpreter','none')
        text(-0.1*ColorScarlarWidth, 0, num2str(round(Contrast_Data(c).MaxVal*YScalar)/YScalar),...
            'verticalalignment','middle',...
            'horizontalalignment','right',...
            'color','k','fontname','arial','fontsize',MetricScaleFontSize,'Interpreter','none')
        clear ColorMapImage
        freezeColors
        TempPos=get(gca,'position');
        set(gca,'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);

    end
    Full_Export_Fig(gcf,gca,[SaveDir,dc,ExportName,' ','ColorBars'],0)
end