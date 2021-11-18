%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Making Figure: ',FigName])
figure('name',FigName)
set(gcf,'position',FigPosition)
set(gcf, 'color', 'white');
if ~exist('BinPercentText')
    BinPercentText=0;
end
if ~exist('PlotConnecttheDots')
    PlotConnecttheDots=1;
end
if ~exist('PlotZeroXAxis')
    PlotZeroXAxis=1;
end
if ~exist('PlotZeroYAxis')
    PlotZeroYAxis=1;
end
if ~exist('AxisBuffer')
    AxisBuffer=0.1;
end
if ~exist('StandardMarkerStyle')
    StandardMarkerStyle='.';
end
if ~exist('StandardLineStyle')
    StandardLineStyle='-';
end
if ~exist('StandardMarkerSize')
    StandardMarkerSize=16;
end
if ~exist('StandardLineWidth')
    StandardLineWidth=0.5;
end
if ~exist('StandardFontSize')
    StandardFontSize=10;
end
if ~exist('Bin_Notes')
    for q=1:size(Bin_Percents,1)
        for r=1:size(Bin_Percents,2)
            Bin_Notes{q,r}=[];
        end
    end
end
if size(Plot_Colors,1)==size(XVals_Mean,1)&&size(Plot_Colors,2)==size(XVals_Mean,2)
    ColorMode=3;
    AllColors=[];
    LineColors=[];
    for r=1:size(XVals_Mean,2)
        for q=1:size(XVals_Mean,1)
            AllColors{q,r}=Plot_Colors{q,r};
            LineColors{r}=Plot_Colors{1,r};
        end
    end
else
    if size(Plot_Colors,2)==size(XVals_Mean,2)
        ColorMode=1;
        AllColors=[];
        LineColors=[];
        for r=1:size(XVals_Mean,2)
            for q=1:size(XVals_Mean,1)
                AllColors{q,r}=Plot_Colors{r};
            end
            LineColors{r}=Plot_Colors{r};
        end
    else
        ColorMode=2;
        AllColors=[];
        LineColors=[];
        for r=1:size(XVals_Mean,2)
            for q=1:size(XVals_Mean,1)
                AllColors{q,r}=Plot_Colors{q};
                LineColors{q}='k';
            end
        end
    end
end
%%%%%%%%%%%%%%
if ~exist('ExcludeSilentFit')
    Current_ExcludeSilentFit=0;
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
if ~isempty(MatchX)
    XMax1=min([XMax1,max(MatchX)]);
    XMin1=min([XMin1,min(MatchX)]);
end
if ~isempty(MatchY)
    YMax1=min([YMax1,max(MatchY)]);
    YMin1=min([YMin1,min(MatchY)]);
end
%%%%%%%%%%%%%%
if PlotZeroYAxis
    hold on
    if ForceZeroY
        plot([0,0],[0,YMax1+AxisBuffer*abs(YMax1-YMin1)],...
            '-','color','k','linewidth',0.25);
    else
        plot([0,0],[YMin1-AxisBuffer*abs(YMax1-YMin1),YMax1+AxisBuffer*abs(YMax1-YMin1)],...
        	'-','color','k','linewidth',0.25);
    end
end
if PlotZeroXAxis
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
XMax=0;
XMin=100000000000;
YMax=0;
YMin=100000000000;
clear FitLabel
clear TempFit
for r=1:size(XVals_Mean,2)
    if ~isempty(XVals_Mean)
        if PlotFit&&(sum(~isnan(XVals_Mean(:,r)))>1&&sum(~isnan(YVals_Mean(:,r))))
            hold on
            if ColorMode==1
                FitLineColor=LineColors{r};
            elseif ColorMode==2
                FitLineColor='k';
            elseif ColorMode==3
                FitLineColor=LineColors{r};
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
                        if exist('FitParams')
                            if ~isempty(FitParams{f})
                                if Current_ExcludeSilentFit
                                    TempFit(r,f).FitStruct=FitSwitch2D(XVals_Mean((SplitBin+1):size(XVals_Mean,1),r),YVals_Mean((SplitBin+1):size(YVals_Mean,1),r),FitType{f},FitParams{f});
                                else
                                    TempFit(r,f).FitStruct=FitSwitch2D(XVals_Mean(:,r),YVals_Mean(:,r),FitType{f},FitParams{f});
                                end
                            else
                                if Current_ExcludeSilentFit
                                    TempFit(r,f).FitStruct=FitSwitch2D(XVals_Mean((SplitBin+1):size(XVals_Mean,1),r),YVals_Mean((SplitBin+1):size(YVals_Mean,1),r),FitType{f});
                                else
                                    TempFit(r,f).FitStruct=FitSwitch2D(XVals_Mean(:,r),YVals_Mean(:,r),FitType{f});
                                end
                            end
                        else
                             if Current_ExcludeSilentFit
                                TempFit(r,f).FitStruct=FitSwitch2D(XVals_Mean((SplitBin+1):size(XVals_Mean,1),r),YVals_Mean((SplitBin+1):size(YVals_Mean,1),r),FitType{f});
                             else
                                TempFit(r,f).FitStruct=FitSwitch2D(XVals_Mean(:,r),YVals_Mean(:,r),FitType{f});
                             end
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
                        elseif any(strfind(TempFit(r,f).FitStruct.FitType,'Log10x'))||any(strcmp(TempFit(r,f).FitStruct.FitType,'Exp'))||any(strcmp(TempFit(r,f).FitStruct.FitType,'Sigmoid'))
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
                        Struct2Txt(TempFit(r,f).FitStruct,[BinnedSaveDir,dc],[FigName,' ',FitType{f},' Fit Info Entry ',num2str(r)]);
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
                    TempFit(r).FitStruct=FitSwitch2D(XVals_Mean(1:size(XVals_Mean,1),r),YVals_Mean(1:size(YVals_Mean,1),r),FitType);
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
                plot(   XVals_Mean(1:size(XVals_Mean,1),r),...
                        YVals_Mean(1:size(YVals_Mean,1),r),...
                        StandardLineStyle,'LineWidth',StandardLineWidth,'color',LineColors{r})
                %FitLabel{r}=[];
            elseif ColorMode==2||ColorMode==3
                plot(   XVals_Mean(1:size(XVals_Mean,1),r),...
                        YVals_Mean(1:size(YVals_Mean,1),r),...
                        StandardLineStyle,'LineWidth',StandardLineWidth,'color','k')
                %FitLabel{r}=[];
            else
                plot(   XVals_Mean(1:size(XVals_Mean,1),r),...
                        YVals_Mean(1:size(YVals_Mean,1),r),...
                        StandardLineStyle,'LineWidth',StandardLineWidth,'color','k')
                %FitLabel{r}=[];
            end
        end
    else
        FitLabel{r}=[];
    end
    for q=1:size(XVals_Mean,1)
        if ~isempty(XVals_Mean)&&~isnan(XVals_Mean(q,r))&&~isnan(XVals_Mean(q,r))
            hold on
%             if (LogX&&XVals_Mean(q,r)==LogXZero)||(LogY&&YVals_Mean(q,r)==LogYZero)
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
                            SilentMarkerLines{q},'MarkerSize',SilentMarkerSizes(q),'LineWidth',StandardLineWidth,'color',AllColors{q,r})
            else
                errorbar(   XVals_Mean(q,r),...
                            YVals_Mean(q,r),...
                            YVals_Error(q,r),...
                            YVals_Error(q,r),...
                            XVals_Error(q,r),...
                            XVals_Error(q,r),...
                            [StandardMarkerStyle,'-'],'MarkerSize',StandardMarkerSize,'LineWidth',StandardLineWidth,'color',AllColors{q,r})
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
                if ~isnan(YVals_Error(q,r))
                    text(double(XVals_Mean(q,r)),...
                        double(YVals_Mean(q,r)*1.05+YVals_Error(q,r)),...
                        [num2str(Bin_Percents(q,r)),'%',Bin_Notes{q,r}],...
                        'color',AllColors{q,r},'fontname','arial','fontsize',StandardFontSize,'horizontalalignment','center')
                else
                    text(double(XVals_Mean(q,r)),...
                        double(YVals_Mean(q,r)*1.05),...
                        [num2str(Bin_Percents(q,r)),'%',Bin_Notes{q,r}],...
                        'color',AllColors{q,r},'fontname','arial','fontsize',StandardFontSize,'horizontalalignment','center')
                end
            end
        end
    end
end
%%%%%%%%%%
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
%%%%%%%%%%
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
%%%%%%%%%%
xlabel(XLabel)
ylabel(YLabel)
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
    elseif ColorMode==3
        text(double(XLimits(1)+XLimits(2)*0.02),double(YLimits(2)-YAdjust*r),...
            [BinClassLabel{r},' ',...
            num2str(sum(Bin_Counts(:,r))),' ',FitLabel{r}],...
            'fontsize',6,'color',LineColors{r})
    else
        text(double(XLimits(1)+XLimits(2)*0.02),double(YLimits(2)-YAdjust*r),...
            [BinClassLabel{r},' ',...
            num2str(sum(Bin_Counts(:,r))),' ',FitLabel{r}],...
            'fontsize',6,'color','k')
    end
end
%%%%%%%%%%
if exist('SilentCollar')&&exist('Silent2D_Axes')
    if ~isempty(SilentCollar)&&any(strfind(Silent2D_Axes,'y'))
        hold on%*(1+AxisBuffer)
        plot([XLimits(1),XLimits(2)],[SilentCollarPos_Y,SilentCollarPos_Y],':','linewidth',0.5,'color',SilentColor)
        text(XLimits(1)*1.02,SilentCollarPos_Y*1.02,...
            ['Silent'],'color',SilentColor,'fontname','arial','fontsize',12)
    end
    if ~isempty(SilentCollar)&&any(strfind(Silent2D_Axes,'x'))
        hold on%*(1+AxisBuffer)
        plot([SilentCollarPos_X,SilentCollarPos_X],[YLimits(1),YLimits(2)],':','linewidth',0.5,'color',SilentColor)
        text(XLimits(1)*1.02,SilentCollarPos_X*1.02,...
            ['Silent'],'color',SilentColor,'fontname','arial','fontsize',12)
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
%%%%%%%%%%
set(gca,'units','normalized','position',FigAxesPosition)
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
FigureStandardizer_FixTicks(gca,[22 20]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    Full_Export_Fig(gcf,gca,Check_Dir_and_File(BinnedSaveDir,FigName,[],1),3)
catch
    Full_Export_Fig(gcf,gca,Check_Dir_and_File(BinnedSaveDir,FigName,[],1),3)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%