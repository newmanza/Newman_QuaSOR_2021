%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Making Figure: ',FigName])
figure('name',FigName)
set(gcf,'position',FigPosition)
set(gcf, 'color', 'white');
if ~exist('PlotConnecttheDots')
    PlotConnecttheDots=1;
end
if ~exist('Bin_Notes')
    for q=1:size(Bin_Percents,1)
        for r=1:size(Bin_Percents,2)
            Bin_Notes{q,r}=[];
        end
    end
end
if size(Bin_Colors,2)==size(XVals_Mean,2)
    ColorMode=1;
    AllColors=[];
    for r=1:size(XVals_Mean,2)
        for q=1:size(XVals_Mean,1)
            AllColors{q,r}=Bin_Colors{r};
        end
        LineColors{r}=Bin_Colors{r};
    end
else
    ColorMode=2;
    AllColors=[];
    for r=1:size(XVals_Mean,2)
        for q=1:size(XVals_Mean,1)
            AllColors{q,r}=Bin_Colors{q};
            LineColors{q}='k';
        end
    end
end
%%%%%%%%%%%%%%
AxisBuffer=0.1;
PlotZeroXAxis=1;
PlotZeroYAxis=1;
if ~exist('ExcludeSilentFit')
    Current_ExcludeSilentFit=1;
else
    Current_ExcludeSilentFit=ExcludeSilentFit;
end
if Current_ExcludeSilentFit
    warning('Excluding Silent Bins in Fit!')
end
%%%%%%%%%%%%%%
if any(isnan(XVals_Error(:)))
    XMax1=max(XVals_Mean(:));
    XMin1=min(XVals_Mean(:));
else
    XMax1=max(XVals_Mean(:))+...
        max(XVals_Error(:));
%     XMin1=min(XVals_Mean(:))-...
%         max(XVals_Error(:));
    XMin1=min(XVals_Mean(:))-...
        max(XVals_Error(:));
end
if any(isnan(YVals_Error(:)))
    YMax1=max(YVals_Mean(:));
    YMin1=min(YVals_Mean(:));
else
    YMax1=max(YVals_Mean(:))+...
        max(YVals_Error(:));
%     YMin1=min(YVals_Mean(:))-...
%         max(YVals_Error(:));
    YMin1=min(YVals_Mean(:))-...
        max(YVals_Error(:));
end
%%%%%%%%%%%%%%
XMax=0;
XMin=100000000000;
YMax=0;
YMin=100000000000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ax2=subtightplot(1,2,2);
%%%%%%%%%%%%%%
if PlotZeroXAxis
    hold on
    if ForceZeroY
        plot([0,0],[0,YMax1+AxisBuffer*abs(YMax1-YMin1)],...
            '-','color','k','linewidth',0.25);
    else
        plot([0,0],[YMin1-AxisBuffer*abs(YMax1-YMin1),YMax1+AxisBuffer*abs(YMax1-YMin1)],...
        	'-','color','k','linewidth',0.25);
    end
end
if PlotZeroYAxis
    hold on
    if ForceZeroX
        plot([0,XMax1+AxisBuffer*abs(XMax1-XMin1)],...
            [0,0],'-','color','k','linewidth',0.25);
    else
        plot([XMin1-AxisBuffer*abs(XMax1-XMin1),XMax1+AxisBuffer*abs(XMax1-XMin1)],...
            [0,0],'-','color','k','linewidth',0.25);
    end
end
%%%%%%%%%%%%%%
hold on
clear FitLabel
clear TempFit
for r1=1:size(XVals_Mean,2)
    hold on
    r=size(XVals_Mean,2)-(r1-1);
    for q=(SplitBin+1):size(XVals_Mean,1)
        if ~isempty(XVals_Mean)
%             if (LogX&&XVals_Mean(q,r)==LogXZero)||((LogY&&YVals_Mean(q,r)==LogYZero))
%                 errorbar(   XVals_Mean(q,r),...
%                             YVals_Mean(q,r),...
%                             YVals_Error(q,r),...
%                             YVals_Error(q,r),...
%                             XVals_Error(q,r),...
%                             XVals_Error(q,r),...
%                             SilentMarkerLines{q},'MarkerSize',SilentMarkerSizes(q),'LineWidth',0.5,'color',AllColors{q,r})
            if any(q==SilentBins)
                errorbar(   XVals_Mean(q,r),...
                            YVals_Mean(q,r),...
                            YVals_Error(q,r),...
                            YVals_Error(q,r),...
                            XVals_Error(q,r),...
                            XVals_Error(q,r),...
                            SilentMarkerLines{q},'MarkerSize',SilentMarkerSizes(q),'LineWidth',0.5,'color',AllColors{q,r})
            else
                errorbar(   XVals_Mean(q,r),...
                            YVals_Mean(q,r),...
                            YVals_Error(q,r),...
                            YVals_Error(q,r),...
                            XVals_Error(q,r),...
                            XVals_Error(q,r),...
                            '.-','MarkerSize',16,'LineWidth',0.5,'color',AllColors{q,r})
            end
            if ~isnan(XVals_Error(q,r))
                XMax=max([XMax,max(XVals_Mean(q,r))+...
                    max(XVals_Error(q,r))]);
%                 XMin=min([XMin,min(XVals_Mean(q,r))-...
%                     max(XVals_Error(q,r))]);
                XMin=min([XMin,min(XVals_Mean(q,r))-...
                    max(XVals_Error(q,r))]);
            else
                XMax=max([XMax,max(XVals_Mean(q,r))]);
                XMin=min([XMin,min(XVals_Mean(q,r))]);
            end
            if ~isnan(YVals_Error(q,r))
                YMax=max([YMax,max(YVals_Mean(q,r))+...
                    max(YVals_Error(q,r))]);
%                 YMin=min([YMin,min(YVals_Mean(q,r))-...
%                     max(YVals_Error(q,r))]);
                YMin=min([YMin,min(YVals_Mean(q,r))-...
                    max(YVals_Error(q,r))]);
            else
                YMax=max([YMax,max(YVals_Mean(q,r))]);
                YMin=min([YMin,min(YVals_Mean(q,r))]);
            end
            if BinPercentTextOn
                hold on
                if ~isnan(YVals_Error(q,r))
                    text(double(XVals_Mean(q,r)),...
                        double(YVals_Mean(q,r)*1.05+YVals_Error(q,r)),...
                        [num2str(Bin_Percents(q,r)),'%'],...
                        'color',AllColors{q,r},'fontname','arial','fontsize',10,'horizontalalignment','center')
                else
                    text(double(XVals_Mean(q,r)),...
                        double(YVals_Mean(q,r)*1.05),...
                        [num2str(Bin_Percents(q,r)),'%'],...
                        'color',AllColors{q,r},'fontname','arial','fontsize',10,'horizontalalignment','center')
                end
            end
        end
    end
    if ~isempty(XVals_Mean)
        if PlotFit
            if ColorMode==1
                FitLineColor=LineColors{r};
            elseif ColorMode==2
                FitLineColor='k';
            else
                FitLineColor='k';
            end
            if iscell(FitType)
                if Current_ExcludeSilentFit
                    FitLabel{r}=['(EXCLUDED SILENT'];
                else
                    FitLabel{r}=['('];
                end
                for f=1:length(FitType)
                    try
                        if Current_ExcludeSilentFit
                            TempFit(r,f).FitStruct=FitSwitch2D(XVals_Mean((SplitBin+1):size(XVals_Mean,1),r),YVals_Mean((SplitBin+1):size(YVals_Mean,1),r),FitType{f});
                        else
                            TempFit(r,f).FitStruct=FitSwitch2D(XVals_Mean(:,r),YVals_Mean(:,r),FitType{f});
                        end
                        hold on
                        if any(strfind(TempFit(r,f).FitStruct.FitType,'Linear'))
                            plot(   TempFit(r,f).FitStruct.FitXValues,...
                                    TempFit(r,f).FitStruct.FitYValues,...
                                    '-','LineWidth',0.5,'color',FitLineColor)
                        elseif any(strfind(TempFit(r,f).FitStruct.FitType,'Power-0'))
                            plot(   TempFit(r,f).FitStruct.FitXValues,...
                                    TempFit(r,f).FitStruct.FitYValues,...
                                    '--','LineWidth',0.5,'color',FitLineColor)
                        elseif any(strfind(TempFit(r,f).FitStruct.FitType,'Power'))
                            plot(   TempFit(r,f).FitStruct.FitXValues,...
                                    TempFit(r,f).FitStruct.FitYValues,...
                                    ':','LineWidth',0.5,'color',FitLineColor)
                        elseif any(strfind(TempFit(r,f).FitStruct.FitType,'Log10x'))||any(strcmp(TempFit(r,f).FitStruct.FitType,'Exp'))
                            plot(   TempFit(r,f).FitStruct.FitXValues,...
                                    TempFit(r,f).FitStruct.FitYValues,...
                                    '--','LineWidth',0.5,'color',FitLineColor)
                        else
                            plot(   TempFit(r,f).FitStruct.FitXValues,...
                                    TempFit(r,f).FitStruct.FitYValues,...
                                    '-.','LineWidth',0.5,'color',FitLineColor)
                        end
                        if length(TempFit(r).FitStruct.CorrCoef_PValue_Text)>2
                            FitLabel{r}=[FitLabel{r},' ',FitType{f},' ',TempFit(r,f).FitStruct.RSquared_Text,' ',TempFit(r,f).FitStruct.CorrCoef_PValue_Text];
                        else
                            FitLabel{r}=[FitLabel{r},' ',FitType{f},' ',TempFit(r,f).FitStruct.RSquared_Text];
                        end
                        Struct2Txt(TempFit(r,f).FitStruct,[BinnedSaveDir,dc],[FigName,' ',FitType{f},' Fit Info']);
                    catch
                        warning on
                        warning('Problem Fitting!')
                        FitLabel{r}=[FitLabel{r},' ',FitType{f},' ERROR)'];
                    end
                end
                FitLabel{r}=[FitLabel{r},')'];
            else
                FitLabel{r}=['(',FitType,' ERROR)'];
                try
                    TempFit(r).FitStruct=FitSwitch2D(XVals_Mean((SplitBin+1):size(XVals_Mean,1),r),YVals_Mean((SplitBin+1):size(YVals_Mean,1),r),FitType);
                    hold on
                    if any(strfind(TempFit(r).FitStruct.FitType,'Linear'))
                        plot(   TempFit(r).FitStruct.FitXValues,...
                                TempFit(r).FitStruct.FitYValues,...
                                '-','LineWidth',0.5,'color',FitLineColor)
                    elseif any(strfind(TempFit(r).FitStruct.FitType,'Power'))
                        plot(   TempFit(r).FitStruct.FitXValues,...
                                TempFit(r).FitStruct.FitYValues,...
                                ':','LineWidth',0.5,'color',FitLineColor)
                    elseif any(strfind(TempFit(r).FitStruct.FitType,'Log10x'))||any(strcmp(TempFit(r).FitStruct.FitType,'Exp'))
                        plot(   TempFit(r).FitStruct.FitXValues,...
                                TempFit(r).FitStruct.FitYValues,...
                                '--','LineWidth',0.5,'color',FitLineColor)
                    else
                        plot(   TempFit(r).FitStruct.FitXValues,...
                                TempFit(r).FitStruct.FitYValues,...
                                '-.','LineWidth',0.5,'color',FitLineColor)
                    end
                    if length(TempFit(r).FitStruct.CorrCoef_PValue_Text)>2
                        FitLabel{r}=['(',FitType,' ',TempFit(r).FitStruct.RSquared_Text,' ',TempFit(r).FitStruct.CorrCoef_PValue_Text,')'];
                    else
                        FitLabel{r}=['(',FitType,' ',TempFit(r).FitStruct.RSquared_Text,')'];
                    end
                    Struct2Txt(TempFit(r).FitStruct,[BinnedSaveDir,dc],[FigName,' ',FitType,' Fit Info']);
                catch
                    warning on
                    warning('Problem Fitting!')
                end
            end
        else
            FitLabel{r}=[];
        end
        if PlotConnecttheDots
            if ColorMode==1
                plot(   XVals_Mean((SplitBin+1):size(XVals_Mean,1),r),...
                        YVals_Mean((SplitBin+1):size(YVals_Mean,1),r),...
                        '-','LineWidth',0.5,'color',LineColors{r})
            elseif ColorMode==2
                plot(   XVals_Mean((SplitBin+1):size(XVals_Mean,1),r),...
                        YVals_Mean((SplitBin+1):size(YVals_Mean,1),r),...
                        '-','LineWidth',0.5,'color','k')
            else
                plot(   XVals_Mean((SplitBin+1):size(XVals_Mean,1),r),...
                        YVals_Mean((SplitBin+1):size(YVals_Mean,1),r),...
                        '-','LineWidth',0.5,'color','k')
            end
            %FitLabel{r}=[];
        end
    else
        FitLabel{r}=[];
    end
end
xlabel(XLabel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ax1=subtightplot(1,2,1);
%%%%%%%%%%%%%%
if PlotZeroXAxis
    hold on
    plot([0,0],[0.9,1.1],...
        '-','color','k','linewidth',0.25);
end
%%%%%%%%%%%%%%
hold on
for r1=1:size(XVals_Mean,2)
    hold on
    r=size(XVals_Mean,2)-(r1-1);
    for q=1:(SplitBin)
        if Bin_Counts(q,r)>1
            errorbar(   1,...
                        YVals_Mean(q,r),...
                        YVals_Error(q,r),...
                        YVals_Error(q,r),...
                        0,...
                        0,...
                        SplitMarkerLines{q},'MarkerSize',SplitMarkerSizes(q),'LineWidth',0.5,'color',AllColors{q,r})
            if ~isnan(XVals_Error(q,r))
                XMax=max([XMax,max(XVals_Mean(q,r))+...
                    max(XVals_Error(q,r))]);
%                 XMin=min([XMin,min(XVals_Mean(q,r))-...
%                     max(XVals_Error(q,r))]);
                XMin=min([XMin,min(XVals_Mean(q,r))-...
                    max(XVals_Error(q,r))]);
            else
                XMax=max([XMax,max(XVals_Mean(q,r))]);
                XMin=min([XMin,min(XVals_Mean(q,r))]);
            end
            if ~isnan(YVals_Error(q,r))
                YMax=max([YMax,max(YVals_Mean(q,r))+...
                    max(YVals_Error(q,r))]);
%                 YMin=min([YMin,min(YVals_Mean(q,r))-...
%                     max(YVals_Error(q,r))]);
                YMin=min([YMin,min(YVals_Mean(q,r))-...
                    max(YVals_Error(q,r))]);
            else
                YMax=max([YMax,max(YVals_Mean(q,r))]);
                YMin=min([YMin,min(YVals_Mean(q,r))]);
            end
            hold on
            if BinPercentTextOn
                if ~isnan(YVals_Error(q,r))
                    text(1,...
                        double(YVals_Mean(q,r)*1.05+YVals_Error(q,r)),...
                        [num2str(Bin_Percents(q,r)),'%',Bin_Notes{q,r}],...],...
                        'color',AllColors{q,r},'fontname','arial','fontsize',10,'horizontalalignment','center')
                else
                    text(1,...
                        double(YVals_Mean(q,r)*1.05),...
                        [num2str(Bin_Percents(q,r)),'%',Bin_Notes{q,r}],...],...
                        'color',AllColors{q,r},'fontname','arial','fontsize',10,'horizontalalignment','center')
                end
            end
        end
    end
end
xticks([1])
xticklabels({SplitLabel})
xtickangle(30)
xlim([0.9,1.1])
if LogY
    set(gca,'yscale','log')
    YLimits=ylim;
    try
        if YMax~=YMin&&ForceZeroY&&~isempty(LogYZero)
            ylim([LogYZero,YMax+AxisBuffer*abs(YMax-YMin)])
        elseif YMax~=YMin
            ylim([YMin-AxisBuffer*abs(YMax-YMin),YMax+AxisBuffer*abs(YMax-YMin)])
        end
    catch
        warning('Problem setting YLim')
    end
else
    YLimits=ylim;
    try
        if ForceZeroY&&YMin>=0
            ylim([0,YMax+AxisBuffer*abs(YMax-YMin)])
        elseif ForceZeroY&&YMin<0&&YMax<=0
            ylim([YMin-AxisBuffer*abs(YMax-YMin),0])
        elseif YMax~=YMin
            ylim([YMin-AxisBuffer*abs(YMax-YMin),YMax+AxisBuffer*abs(YMax-YMin)])
        else

        end
    catch
        warning('Problem setting YLim')
    end
end
if ~isempty(MatchY)
    ylim([MatchY(1),MatchY(2)])
end
ylabel([YLabel])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(Ax2)
if LogX
    set(gca,'xscale','log')
    XLimits=xlim;
    try
        if XMax~=XMin&&ForceZeroX&&~isempty(LogXZero)
            xlim([LogXZero,XMax+AxisBuffer*abs(XMax-XMin)])
        elseif XMax~=XMin
            xlim([XMin-AxisBuffer*abs(XMax-XMin),XMax+AxisBuffer*abs(XMax-XMin)])
        end
    catch
        warning('Problem setting XLim')
    end
else
    XLimits=xlim;
    try
        if ForceZeroX&&XMin>=0
            xlim([0,XMax+AxisBuffer*abs(XMax-XMin)])
        elseif ForceZeroX&&XMin<0
            xlim([XMin-AxisBuffer*abs(XMax-XMin),0])
        elseif XMax~=XMin
            xlim([XMin-AxisBuffer*abs(XMax-XMin),XMax+AxisBuffer*abs(XMax-XMin)])
        else

        end
    catch
        warning('Problem setting XLim')
    end
end
if ~isempty(MatchX)
    xlim([MatchX(1),MatchX(2)])
end
if LogY
    set(gca,'yscale','log')
    YLimits=ylim;
    try
        if YMax~=YMin&&ForceZeroY&&~isempty(LogYZero)
            ylim([LogYZero,YMax+AxisBuffer*abs(YMax-YMin)])
        elseif YMax~=YMin
            ylim([YMin-AxisBuffer*abs(YMax-YMin),YMax+AxisBuffer*abs(YMax-YMin)])
        end
        set(gca,'yticklabels',[])
    catch
        warning('Problem setting YLim')
    end
else
    YLimits=ylim;
    try
        if ForceZeroY&&YMin>=0
            ylim([0,YMax+AxisBuffer*abs(YMax-YMin)])
        elseif ForceZeroY&&YMin<0&&YMax<=0
            ylim([YMin-AxisBuffer*abs(YMax-YMin),0])
        elseif YMax~=YMin
            ylim([YMin-AxisBuffer*abs(YMax-YMin),YMax+AxisBuffer*abs(YMax-YMin)])
        else

        end
        set(gca,'yticklabels',[])
    catch
        warning('Problem setting YLim')
    end
end
if ~isempty(MatchY)
    ylim([MatchY(1),MatchY(2)])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(Ax2)
XLimits=xlim;
YLimits=ylim;
for r1=1:size(XVals_Mean,2)
    hold on
    r=size(XVals_Mean,2)-(r1-1);
    YAdjust=double((YLimits(2)-YLimits(1))*0.05);
    if ColorMode==1
        text(double(XLimits(1)+XLimits(2)*0.02),double(YLimits(2)-YAdjust*r),...
            [BinClassLabel{r},' ',...
            num2str(sum(Bin_Counts(:,r))),' ',FitLabel{r}],...
            'fontsize',6,'color',LineColors{r})
    elseif ColorMode==2
        text(double(XLimits(1)+XLimits(2)*0.02),double(YLimits(2)-YAdjust*r),...
            [BinClassLabel{r},' ',...
            num2str(sum(Bin_Counts(:,r))),' ',FitLabel{r}],...
            'fontsize',6,'color','k')
    else
        text(double(XLimits(1)+XLimits(2)*0.02),double(YLimits(2)-YAdjust*r),...
            [BinClassLabel{r},' ',...
            num2str(sum(Bin_Counts(:,r))),' ',FitLabel{r}],...
            'fontsize',6,'color','k')
    end

end
if ~isempty(MatchX)&&~isempty(MatchY)
    if MatchX(1)==MatchY(1)&&MatchX(2)==MatchY(2)
        XTicks=get(gca,'XTick');
        YTicks=get(gca,'YTick');
        if length(XTicks)<length(YTicks)
            set(gca,'YTick',XTicks)
        elseif length(XTicks)>length(YTicks)
            set(gca,'XTick',YTicks)
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(Ax1)
set(Ax1,'units','normalized','position',FigSplitAxes1Position)
axes(Ax2)
set(Ax2,'units','normalized','position',FigSplitAxes2Position)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if LogX
%     FigName=[FigName,' LogX'];
% end
% if LogY
%     FigName=[FigName,'LogY'];
% end
if LogX&&~LogY
    FigName=[FigName,' LogX'];
elseif LogY&&~LogX
    FigName=[FigName,' LogY'];
elseif LogX&&LogY
    FigName=[FigName,' LogXY'];
end

if ~isempty(MatchX)||~isempty(MatchY)
    FigName=[FigName,' Match'];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(Ax1);FigureStandardizer_FixTicks(gca,[22 20]);
axes(Ax2);FigureStandardizer_FixTicks(gca,[22 20]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Full_Export_Fig(gcf,[Ax1;Ax2],Check_Dir_and_File(BinnedSaveDir,FigName,[],1),3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%