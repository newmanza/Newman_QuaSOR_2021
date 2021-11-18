function FigureStandardizer_FixTicks(axishand,FontSizes)

    %use this in code to set axes size/font and remove box
    % FigureStandardizer_FixTicks(gca,[22 20]);
    % axishand=gca;FontSizes=[22,20];

    if isempty(FontSizes)
        AxisLabelSize = 22;
        AxisTickSize = 20;
    else
        AxisLabelSize = FontSizes(1);
        AxisTickSize = FontSizes(2);
    end
    
    xscale=get(axishand,'xscale');
    
    yscale=get(axishand,'yscale');

    xlhand=get(axishand,'xlabel');
    
    ylhand=get(axishand,'ylabel');
    
    xaxis_exponent=axishand.XAxis.Exponent;
    
    XLabelText=xlhand.String;

    if xaxis_exponent~=0
        if iscell(XLabelText)
            TempText=XLabelText{size(XLabelText,1)};
            TempText=[TempText,' (\times10^{',num2str(xaxis_exponent),'})'];
            XLabelText{size(XLabelText,1)}=TempText;
            clear TempText
            xlabel(XLabelText)
        else
            XLabelText=[XLabelText,' (\times10^{',num2str(xaxis_exponent),'})'];
            xlabel(XLabelText)
        end
    end
    
    yaxis_exponent=axishand.YAxis.Exponent;
    
    YLabelText=ylhand.String;
    
    if yaxis_exponent~=0
        if iscell(YLabelText)
            TempText=YLabelText{size(YLabelText,1)};
            TempText=[TempText,' (\times10^{',num2str(yaxis_exponent),'})'];
            YLabelText{size(YLabelText,1)}=TempText;
            clear TempText
            ylabel(YLabelText)
        else
            YLabelText=[YLabelText,' (\times10^{',num2str(yaxis_exponent),'})'];
            ylabel(YLabelText)
        end
    end
    

    try
        zscale=get(axishand,'zscale');
        
        zlhand=get(axishand,'zlabel');
        
        Z_On=1;
        
    catch
        Z_On=0;
    end
    
    if Z_On
        
        zaxis_exponent=axishand.ZAxis.Exponent;
    
        ZLabelText=zlhand.String;

        if zaxis_exponent~=0
            if iscell(ZLabelText)
                TempText=ZLabelText{size(ZLabelText,1)};
                TempText=[TempText,' (\times10^{',num2str(zaxis_exponent),'})'];
                ZLabelText{size(ZLabelText,1)}=TempText;
                clear TempText
                zlabel(ZLabelText)
            else
                ZLabelText=[ZLabelText,' (\times10^{',num2str(zaxis_exponent),'})'];
                zlabel(ZLabelText)
            end

            if size(ZLabelText,1)>1
                ZLabelText{size(ZLabelText,1)}=[ZLabelText{size(ZLabelText,1)},' (\times10^{',num2str(zaxis_exponent),'})'];
                zlabel(ZLabelText)
            else
                ZLabelText=[ZLabelText,' (\times10^{',num2str(zaxis_exponent),'})'];
                zlabel(ZLabelText)
            end

        end    
            
        if strcmp(xscale,'log')||strcmp(yscale,'log')||strcmp(zscale,'log')
            set(axishand, 'fontsize',14,'FontName','Arial');
        else
            set(axishand, 'fontsize',AxisTickSize,'FontName','Arial');
        end
    else
        if strcmp(xscale,'log')||strcmp(yscale,'log')
            set(axishand, 'fontsize',14,'FontName','Arial');
        else
            set(axishand, 'fontsize',AxisTickSize,'FontName','Arial');
        end
    end
    
    set(xlhand,'fontsize',AxisLabelSize,'FontName','Arial','color',[0,0,0]);

    set(ylhand,'fontsize',AxisLabelSize,'FontName','Arial','color',[0,0,0]);
    
    if Z_On
        set(zlhand,'fontsize',AxisLabelSize,'FontName','Arial','color',[0,0,0]);
    end
    
    XLim=xlim;
    YLim=ylim;
    XTicks=get(gca,'XTick');
    YTicks=get(gca,'YTick');
    if XLim(1)==YLim(1)&&XLim(2)==YLim(2)
        if length(XTicks)<length(YTicks)
            set(gca,'YTick',XTicks)
        elseif length(XTicks)>length(YTicks)
            set(gca,'XTick',YTicks)
        end
    end
    if Z_On
        ZLim=zlim;
        ZTicks=get(gca,'ZTick');
        if XLim(1)==YLim(1)&&XLim(2)==YLim(2)&&XLim(1)==ZLim(1)&&XLim(2)==ZLim(2)
            if length(XTicks)<length(ZTicks)
                set(gca,'ZTick',XTicks)
            elseif length(XTicks)>length(ZTicks)
                set(gca,'XTick',ZTicks)
            end
            if length(YTicks)<length(ZTicks)
                set(gca,'ZTick',YTicks)
            elseif length(YTicks)>length(ZTicks)
                set(gca,'YTick',ZTicks)
            end
        end
    end
    
    
    set(axishand,'TickDir','out');

    set(axishand,'XColor',[0,0,0]);

    set(axishand,'YColor',[0,0,0]);
    
    if Z_On
        set(axishand,'ZColor',[0,0,0]);
    end
    
    try
        if ischar(axishand.XTickLabel)
        else
            for x=1:length(axishand.XTickLabel)
                axishand.XTickLabel{x} = sprintf('\\color[rgb]{%f,%f,%f}%s', [0,0,0], axishand.XTickLabel{x});
                %axishand.XTickLabel{x}='\color[rgb]{0,0,0}black';
            end
        end
    catch
        warning on
        warning('Problem adjusting x axis ticks')
    end
    try
        if ischar(axishand.YTickLabel)
        else
            for y=1:length(axishand.YTickLabel)
                axishand.YTickLabel{y} = sprintf('\\color[rgb]{%f,%f,%f}%s', [0,0,0], axishand.YTickLabel{y});
                %axishand.YTickLabel{y}='\color[rgb]{0,0,0}';
            end
        end
    catch
        warning on
        warning('Problem adjusting y axis ticks')
    end

    if Z_On
        
       try
           if ischar(axishand.ZTickLabel)
           else
               for z=1:length(axishand.ZTickLabel)
                    axishand.ZTickLabel{z} = sprintf('\\color[rgb]{%f,%f,%f}%s', [0,0,0], axishand.ZTickLabel{z});
                    %axishand.YTickLabel{y}='\color[rgb]{0,0,0}';
               end
           end
        catch
            warning on
            warning('Problem adjusting z axis ticks')
        end
 
    end
    
    
    box off

end