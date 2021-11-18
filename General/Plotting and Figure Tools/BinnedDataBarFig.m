%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('BarMode')
    warning('Using default bar mode!')
    BarMode=1;
end
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
    Current_ExcludeSilentFit=0;
else
    Current_ExcludeSilentFit=ExcludeSilentFit;
end
if Current_ExcludeSilentFit
    warning('Excluding Silent Bins in Fit!')
end
if ~exist('BarSpacing')
    BarSpacing=1;
end
if ~exist('BarWidth')
    BarWidth=1;
end
if ~exist('BarGroupSpacing')
    BarGroupSpacing=0.25;
end
if ~exist('StandardBarFigPosition')
    StandardBarFigPosition=[0 50 1600 800];
end
if ~exist('AdaptiveGCA')
    AdaptiveGCA=1;
end
%%%%%%%%%%%%%%
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
NumIterations=0;
if isempty(ExcludeBins)||any(ExcludeBins==0)
    NumIterations=0;
else
    NumIterations=length(ExcludeBins);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for RemovalNum=0:NumIterations
    if RemovalNum==0
        RemovalLabel=[];
        RemovalLabela=[];
        count=0;
        Groups=[];
        for q=1:NumGroups
            count=count+1;
            Groups(count)=q;
        end
    else
        RemovalLabel=[' MINUS_'];
        RemovalLabela=[' M_'];
        for r=1:length(ExcludeBins(1:RemovalNum))
            RemovalLabel=[RemovalLabel,num2str(ExcludeBins(r))];
            RemovalLabela=[RemovalLabela,num2str(ExcludeBins(r))];
            if length(ExcludeBins(1:RemovalNum))>1&&r<length(ExcludeBins(1:RemovalNum))
                RemovalLabel=[RemovalLabel,'_'];
                RemovalLabela=[RemovalLabela,'_'];
            end
        end
        count=0;
        Groups=[];
        for q=1:NumGroups
            if any(q==ExcludeBins(1:RemovalNum))
            else
                count=count+1;
                Groups(count)=q;
            end
        end
    end
    if ~isempty(Groups)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FigName1=[FigName,RemovalLabel];
        FigName1a=[FigName,RemovalLabela];
        fprintf(['Making: ',FigName1,'...'])

        disp(['Making Figure: ',FigName1a])
        figure('name',FigName1a)
        set(gcf, 'color', 'white');

        XMax=0;
        XMin=1000000;
        YMax=0;
        YMin=1000000;
        clear FitLabel
        clear TempFit
        HorzPos=0;
        BarPlacements=[];
        for r=1:size(XVals_Mean,2)
            for q=1:size(XVals_Mean,1)
                if ~any(q==ExcludeBins(1:RemovalNum))
                    HorzPos=HorzPos+BarSpacing;
                    BarPlacements=[BarPlacements,HorzPos];
                    hold on
                    if BarMode==1
                        bar(HorzPos,YVals_Mean(q,r), BarWidth,'edgecolor','k','facecolor',AllColors{q,r},'linewidth', 0.5);
                        if ~isnan(YVals_Error(q,r))
                            errorbar(   HorzPos,...
                                        YVals_Mean(q,r),...
                                        YVals_Error(q,r),...
                                        YVals_Error(q,r),...
                                        NaN,...
                                        NaN,...
                                        'marker','none','LineWidth',0.5,'color','k')
                        end
                    elseif BarMode==2
                        bar(HorzPos,YVals_Mean(q,r), BarWidth,'edgecolor',AllColors{q,r},'facecolor','w','linewidth', 2);
                        if ~isnan(YVals_Error(q,r))
                            errorbar(   HorzPos,...
                                        YVals_Mean(q,r),...
                                        YVals_Error(q,r),...
                                        YVals_Error(q,r),...
                                        NaN,...
                                        NaN,...
                                        'marker','none','LineWidth',1,'color',AllColors{q,r})
                        end
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
                end
            end
            HorzPo=HorzPos+BarGroupSpacing;
        end
        xlim([BarPlacements(1)-BarWidth,BarPlacements(length(BarPlacements))+BarWidth])
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
        xlabel([])
        set(gca,'xtick',[])
        h=gca;
        h.XAxis.Visible='off';
        %%%%%%%%%%%%%%
        plot([BarPlacements(1)-BarWidth,BarPlacements(length(BarPlacements))+BarWidth],...
                    [0,0],'-','color','k','linewidth',0.25);
        %%%%%%%%%%
        ylabel([YLabel])
        XLimits=xlim;
        YLimits=ylim;
        for r1=1:size(XVals_Mean,2)
            hold on
            r=size(XVals_Mean,2)-(r1-1);
            YAdjust=double((YLimits(2)-YLimits(1))*0.05);
            if ColorMode==1
                text(double(XLimits(1)+XLimits(2)*0.02),double(YLimits(2)-YAdjust*r),...
                    [BinClassLabel{r},' ',...
                    num2str(sum(Bin_Counts(:,r)))],...
                    'fontsize',8,'color',LineColors{r})
            elseif ColorMode==2
                text(double(XLimits(1)+XLimits(2)*0.02),double(YLimits(2)-YAdjust*r),...
                    [BinClassLabel{r},' ',...
                    num2str(sum(Bin_Counts(:,r)))],...
                    'fontsize',8,'color','k')
            else
                text(double(XLimits(1)+XLimits(2)*0.02),double(YLimits(2)-YAdjust*r),...
                    [BinClassLabel{r},' ',...
                    num2str(sum(Bin_Counts(:,r)))],...
                    'fontsize',8,'color','k')
            end
        end
        %%%%%%%%%%
        if exist('SilentCollar')&&exist('Silent2D_Axes')
            if ~isempty(SilentCollar)&&any(strfind(Silent2D_Axes,'y'))
                hold on%*(1+AxisBuffer)
                plot([XLimits(1),XLimits(2)],[SilentCollarPos_Y,SilentCollarPos_Y],':','linewidth',0.5,'color',SilentColor)
                text(XLimits(1)*1.02,SilentCollarPos_Y*1.02,...
                    ['Silent'],'color',SilentColor,'fontname','arial','fontsize',10)
            end
            if ~isempty(SilentCollar)&&any(strfind(Silent2D_Axes,'x'))
                hold on%*(1+AxisBuffer)
                plot([SilentCollarPos_X,SilentCollarPos_X],[YLimits(1),YLimits(2)],':','linewidth',0.5,'color',SilentColor)
                text(XLimits(1)*1.02,SilentCollarPos_X*1.02,...
                    ['Silent'],'color',SilentColor,'fontname','arial','fontsize',10)
            end
        end
        %%%%%%%%%%
        if size(XVals_Mean,1)>1
            if YLimits(1)==0
                TextYPos=abs(YLimits(2)-YLimits(1))*-0.1;
            elseif YLimits(1)>0
                TextYPos=YLimits(1)+abs(YLimits(2)-YLimits(1))*-0.1;
            else
                TextYPos=YLimits(1);
            end
        else
            if YLimits(1)==0
                TextYPos=abs(YLimits(2)-YLimits(1))*-0.05;
            elseif YLimits(1)>0
                TextYPos=YLimits(1)+abs(YLimits(2)-YLimits(1))*-0.05;
            else
                TextYPos=YLimits(1);
            end
        end
        HorzCount=0;
        for r=1:size(XVals_Mean,2)
            for q=1:size(XVals_Mean,1)
                if ~any(q==ExcludeBins(1:RemovalNum))
                    HorzCount=HorzCount+1;
                    if size(XVals_Mean,1)>1
                        text(BarPlacements(HorzCount),TextYPos,{BinClassLabel{r};['Bin',num2str(q)]},...
                            'HorizontalAlignment','center','verticalalignment','bottom',...
                            'fontname','arial','fontsize',12,'color','k');
                    else
                        text(BarPlacements(HorzCount),TextYPos,BinClassLabel{r},...
                            'HorizontalAlignment','center','verticalalignment','bottom',...
                            'fontname','arial','fontsize',12,'color','k');
                    end

                    if BinPercentTextOn
                        if ~isnan(YVals_Error(q,r))
                            text(BarPlacements(HorzCount),...
                                double(YVals_Mean(q,r)+YVals_Error(q,r)+abs(YLimits(2)-YLimits(1))*0.02),...
                                [num2str(Bin_Percents(q,r)),'%',Bin_Notes{q,r}],...
                                'color',AllColors{q,r},'fontname','arial','fontsize',10,'horizontalalignment','center')
                        else
                            text(BarPlacements(HorzCount),...
                                double(YVals_Mean(q,r)+abs(YLimits(2)-YLimits(1))*0.02),...
                                [num2str(Bin_Percents(q,r)),'%',Bin_Notes{q,r}],...
                                'color',AllColors{q,r},'fontname','arial','fontsize',10,'horizontalalignment','center')
                        end
                    end
                end
            end
        end        
        %%%%%%%%%%
        FigName1b=[FigName1a];
        if LogX&&~LogY
            FigName1b=[FigName1a,' LogX'];
        elseif LogY&&~LogX
            FigName1b=[FigName1a,' LogY'];
        elseif LogX&&LogY
            FigName1b=[FigName1a,' LogXY'];
        end
        if ~isempty(MatchX)||~isempty(MatchY)
            FigName1b=[FigName1a,' Match'];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~AdaptiveGCA
            set(gca,'units','normalized','position',[0.3 0.2 0.6 0.6])
            set(gcf,'position',[FigPosition(1),FigPosition(2),FigPosition(3)/3*length(BarPlacements),FigPosition(4)])
        else
            if length(BarPlacements)<10
                HorzGCAScalar=0.07;
            elseif length(BarPlacements)<20&&length(BarPlacements)>=10
                HorzGCAScalar=0.05;
            else
                HorzGCAScalar=0.02;
            end
            set(gca,'units','normalized','position',[0.1 0.2 HorzGCAScalar*length(BarPlacements) 0.6])
            set(gcf,'position',StandardBarFigPosition);
        end
        FigureStandardizer_FixTicks(gca,[22 20]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Full_Export_Fig(gcf,gca,Check_Dir_and_File(BinnedSaveDir,FigName1b,[],1),3)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
