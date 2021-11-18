%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Making Figure: ',FigName])
figure('name',FigName)
set(gcf,'position',FigPosition)
set(gcf, 'color', 'white');
if ~exist('PlotConnecttheDots3D')&&exist('PlotConnecttheDots')
    PlotConnecttheDots3D=PlotConnecttheDots;
elseif ~exist('PlotConnecttheDots3D')
    PlotConnecttheDots3D=1;
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
XMax=0;
XMin=100000000000;
YMax=0;
YMin=100000000000;
ZMax=0;
ZMin=100000000000;
clear FitLabel
clear TempFit
clear p p1
FitLabel=[];
for r=1:size(XVals_Mean,2)
    for q=1:size(XVals_Mean,1)
        if ~isempty(XVals_Mean)
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
                p(q,r)=plot3(XVals_Mean(q,r),YVals_Mean(q,r),ZVals_Mean(q,r),...
                            SilentMarkerLines{q},'MarkerSize',SilentMarkerSizes(q),'LineWidth',0.5,'color',AllColors{q,r});
            else
                p(q,r)=plot3(XVals_Mean(q,r),YVals_Mean(q,r),ZVals_Mean(q,r),...
                            '.','MarkerSize',16,'LineWidth',0.5,'color',AllColors{q,r});
            end
            if ~isnan(XVals_Error(q,r))
                XMax=max([XMax,max(XVals_Mean(q,r))+...
                    max(XVals_Error(q,r))]);
%                 XMin=min([XMin,min(XVals_Mean(q,r))-...
%                     max(YVals_Error(q,r))]);
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
            if ~isnan(ZVals_Error(q,r))
                ZMax=max([ZMax,max(ZVals_Mean(q,r))+...
                    max(ZVals_Error(q,r))]);
%                 ZMin=min([ZMin,min(ZVals_Mean(q,r))-...
%                     max(ZVals_Error(q,r))]);
                ZMin=min([ZMin,min(ZVals_Mean(q,r))-...
                    max(ZVals_Error(q,r))]);
            else
                ZMax=max([ZMax,max(ZVals_Mean(q,r))]);
                ZMin=min([ZMin,min(ZVals_Mean(q,r))]);
            end
            if BinPercentTextOn
                if ~isnan(YVals_Error(q,r))
                    text(double(XVals_Mean(q,r)),...
                        double(YVals_Mean(q,r)),...
                        double(ZVals_Mean(q,r)*1.05+ZVals_Error(q,r)),...
                        [num2str(Bin_Percents(q,r)),'%',Bin_Notes{q,r}],...
                        'color',AllColors{q,r},'fontname','arial','fontsize',10,'horizontalalignment','center')
                else
                    text(double(XVals_Mean(q,r)),...
                        double(YVals_Mean(q,r)),...
                        double(ZVals_Mean(q,r)*1.05),...
                        [num2str(Bin_Percents(q,r)),'%',Bin_Notes{q,r}],...
                        'color',AllColors{q,r},'fontname','arial','fontsize',10,'horizontalalignment','center')
                end
            end
        end
    end
    if ~isempty(XVals_Mean)
        if PlotConnecttheDots3D
            if ColorMode==1
                plot3(  XVals_Mean(1:size(XVals_Mean,1),r),...
                        YVals_Mean(1:size(YVals_Mean,1),r),...
                        ZVals_Mean(1:size(ZVals_Mean,1),r),...
                        '-','LineWidth',0.5,'color',LineColors{r})
            elseif ColorMode==2
                plot3(  XVals_Mean(1:size(XVals_Mean,1),r),...
                        YVals_Mean(1:size(YVals_Mean,1),r),...
                        ZVals_Mean(1:size(ZVals_Mean,1),r),...
                        '-','LineWidth',0.5,'color','k')
            else
                plot3(  XVals_Mean(1:size(XVals_Mean,1),r),...
                        YVals_Mean(1:size(YVals_Mean,1),r),...
                        ZVals_Mean(1:size(ZVals_Mean,1),r),...
                        '-','LineWidth',0.5,'color','k')
            end
        end
        if Plot3DTracers
            for q=1:size(XVals_Mean,1)
                if ColorMode==1
                    if LogZ
                        p1(q,r)=plot3([XVals_Mean(q,r),XVals_Mean(q,r)],[YVals_Mean(q,r),YVals_Mean(q,r)],[LogZZero,ZVals_Mean(q,r)],...
                            LineStyle_3D,'color',LineColors{r},'LineWidth',LineWidth_3D);
                    elseif any(ZVals_Mean<0)
                        p1(q,r)=plot3([XVals_Mean(q,r),XVals_Mean(q,r)],[YVals_Mean(q,r),YVals_Mean(q,r)],[min(ZVals_Mean(:)),ZVals_Mean(q,r)],...
                            LineStyle_3D,'color',LineColors{r},'LineWidth',LineWidth_3D);
                    else
                        p1(q,r)=plot3([XVals_Mean(q,r),XVals_Mean(q,r)],[YVals_Mean(q,r),YVals_Mean(q,r)],[0,ZVals_Mean(q,r)],...
                            LineStyle_3D,'color',LineColors{r},'LineWidth',LineWidth_3D);
                    end
                elseif ColorMode==2
                    if LogZ
                        p1(q,r)=plot3([XVals_Mean(q,r),XVals_Mean(q,r)],[YVals_Mean(q,r),YVals_Mean(q,r)],[LogZZero,ZVals_Mean(q,r)],...
                            LineStyle_3D,'color',Bin_Colors{q},'LineWidth',LineWidth_3D);
                    elseif any(ZVals_Mean<0)
                        p1(q,r)=plot3([XVals_Mean(q,r),XVals_Mean(q,r)],[YVals_Mean(q,r),YVals_Mean(q,r)],[min(ZVals_Mean(:)),ZVals_Mean(q,r)],...
                            LineStyle_3D,'color',Bin_Colors{q},'LineWidth',LineWidth_3D);
                    else
                        p1(q,r)=plot3([XVals_Mean(q,r),XVals_Mean(q,r)],[YVals_Mean(q,r),YVals_Mean(q,r)],[0,ZVals_Mean(q,r)],...
                            LineStyle_3D,'color',Bin_Colors{q},'LineWidth',LineWidth_3D);
                    end
                else
                    if LogZ
                        p1(q,r)=plot3([XVals_Mean(q,r),XVals_Mean(q,r)],[YVals_Mean(q,r),YVals_Mean(q,r)],[LogZZero,ZVals_Mean(q,r)],...
                            LineStyle_3D,'color','k','LineWidth',LineWidth_3D);
                    elseif any(ZVals_Mean<0)
                        p1(q,r)=plot3([XVals_Mean(q,r),XVals_Mean(q,r)],[YVals_Mean(q,r),YVals_Mean(q,r)],[min(ZVals_Mean(:)),ZVals_Mean(q,r)],...
                            LineStyle_3D,'color','k','LineWidth',LineWidth_3D);
                    else
                        p1(q,r)=plot3([XVals_Mean(q,r),XVals_Mean(q,r)],[YVals_Mean(q,r),YVals_Mean(q,r)],[0,ZVals_Mean(q,r)],...
                            LineStyle_3D,'color','k','LineWidth',LineWidth_3D);
                    end
                end
            end
        end
    else
    end
end
xlabel(XLabel,'rotation',XRotation,'horizontalalignment','left')
ylabel(YLabel,'rotation',YRotation,'horizontalalignment','right')
zlabel(ZLabel,'rotation',ZRotation,'horizontalalignment','center')
view(Azimuth,Elevation)
grid on
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
            ylim([YMin-AxisBuffer*abs(YMin),0])
        elseif YMax~=YMin
            ylim([YMin-AxisBuffer*abs(YMin),YMax+AxisBuffer*abs(YMax-YMin)])
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
if LogZ
    set(gca,'zscale','log')
    ZLimits=zlim;
    try
        if ZMax~=ZMin&&ForceZeroZ&&~isempty(LogZZero)
            zlim([LogZZero,ZMax+AxisBuffer*abs(ZMax-ZMin)])
        elseif ZMax~=ZMin
            zlim([ZMin-AxisBuffer*abs(ZMax-ZMin),ZMax+AxisBuffer*abs(ZMax-ZMin)])
        end
    catch
        warning('Problem setting ZLim')
    end
else
    ZLimits=zlim;
    try
        if ForceZeroZ&&ZMin>=0
            zlim([0,ZMax+AxisBuffer*abs(ZMax-ZMin)])
        elseif ForceZeroZ&&ZMin<0
            zlim([ZMin-AxisBuffer*abs(ZMax-ZMin),0])
        elseif ZMax~=ZMin
            zlim([ZMin-AxisBuffer*abs(ZMax-ZMin),ZMax+AxisBuffer*abs(ZMax-ZMin)])
        else

        end
    catch
        warning('Problem setting ZLim')
    end
end
%%%%%%%%%%
XLimits=xlim;
YLimits=ylim;
ZLimits=zlim;
for r1=1:size(XVals_Mean,2)
    hold on
    r=size(XVals_Mean,2)-(r1-1);
    XAdjust=double((XLimits(2)-XLimits(1))*0.05);
    YAdjust=double((YLimits(2)-YLimits(1))*0.05);
    ZAdjust=double((ZLimits(2)-ZLimits(1))*0.05);
    text(double(XLimits(1)+XLimits(2)*0.02),double(YLimits(2)-YAdjust),double(ZLimits(2)-ZAdjust*r),...
        [BinClassLabel{r},' ',...
        num2str(sum(Bin_Counts(:,r)))],...
        'fontsize',10,'color',LineColors{r})
end
%%%%%%%%%%
if exist('SilentCollar')&&exist('Silent3D_Axes')
    if ~isempty(SilentCollar)&&any(strfind(Silent3D_Axes,'z'))
        if SilentCollar
            hold on%*(1+AxisBuffer)
            XLimits=xlim;
            YLimits=ylim;
            ZLimits=zlim;
            plot3([XLimits(1),XLimits(2)],[YLimits(1),YLimits(1)],[SilentCollarPos_Z,SilentCollarPos_Z],':','linewidth',0.5,'color',SilentColor)
            plot3([XLimits(1),XLimits(2)],[YLimits(2),YLimits(2)],[SilentCollarPos_Z,SilentCollarPos_Z],':','linewidth',0.5,'color',SilentColor)
            plot3([XLimits(1),XLimits(1)],[YLimits(1),YLimits(2)],[SilentCollarPos_Z,SilentCollarPos_Z],':','linewidth',0.5,'color',SilentColor)
            plot3([XLimits(2),XLimits(2)],[YLimits(1),YLimits(2)],[SilentCollarPos_Z,SilentCollarPos_Z],':','linewidth',0.5,'color',SilentColor)
            text(XLimits(1)*1.02,YLimits(2)*1.02,SilentCollarPos_Z,...
                ['Silent'],'color',SilentColor,'fontname','arial','fontsize',12,'rotation',XRotation,'horizontalalignment','left')
        end
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
% if LogZ
%     FigName=[FigName,'LogZ'];
% end
if LogX&&~LogY&&~LogZ
    FigName=[FigName,' LogX'];
elseif ~LogX&&LogY&&~LogZ
    FigName=[FigName,' LogY'];
elseif ~LogX&&~LogY&&LogZ
    FigName=[FigName,' LogZ'];
elseif LogX&&LogY&&~LogZ
    FigName=[FigName,' LogXY'];
elseif ~LogX&&LogY&&LogZ
    FigName=[FigName,' LogYZ'];
elseif LogX&&~LogY&&LogZ
    FigName=[FigName,' LogXZ'];
elseif LogX&&LogY&&LogZ
    FigName=[FigName,' LogXYZ'];
end
if ~isempty(MatchX)||~isempty(MatchY)||~isempty(MatchZ)
    FigName=[FigName,' Match'];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FigureStandardizer_FixTicks(gca,[22 20]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Full_Export_Fig(gcf,gca,Check_Dir_and_File(BinnedSaveDir,FigName,[],1),13)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%