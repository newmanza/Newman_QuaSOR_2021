function AZ_Histogram_Figure(FigName,FigSaveDir,dc,ModBins,...
    ProfileError,ProfileXTicks,ProfileXLabel,ProfileYLabel,CalculationLabel,...
    NumMods,NumGroups,RemovalIndex,MatchedModMax,MatchProfileXIndices,MatchProfileXTicks,MatchProfileXLim,CenteredPlot,PlotMarkers,IncludeAligned,FlipHist)

    %NumMods=3;NumGroups=5;RemovalIndex=[];
    %NumMods=2;NumGroups=5;RemovalIndex=[];
    
    %NumMods=2;NumGroups=2;RemovalIndex=[];PlotMarkers=[];IncludeAligned=1;FlipHist=1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    FoundEnoughData=0;
    for Mod=1:length(ModBins)
        for q=1:length(ModBins(Mod).Bins)
            if length(ModBins(Mod).Bins(q).Profile_XData)>1&&any(~isnan(ModBins(Mod).Bins(q).Profile_XData))
                FoundEnoughData=1;
            end
        end
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if FoundEnoughData
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isfield(ModBins,'MatchProfileXIndices')
        for Mod=1:NumMods
            ModBins(Mod).MatchProfileXIndices=MatchProfileXIndices;
        end    
    end
    DetailMarkersOn=0;
    for Mod=1:NumMods
        if isfield(ModBins(Mod).Bins,'PlotMarkers')
            DetailMarkersOn=1;
            warning('DetailMarkersOn!, will exclude some plots where markers are not helpful!')
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    YScalar=1e5;
    ControlYTick=0;
    MetricLabelFontSize=16;
    MetricScaleFontSize=12;
    if ProfileError
        %Muse use Full_Export_Fig MODE 2
        %warning('The exporting for this takes a crazy long time so might not want to turn ProfileError on as of right now without adjusting renderer')
        %error('The exporting for this takes a crazy long time so might not want to turn ProfileError on as of right now without adjusting renderer')
    end
    if MatchedModMax==1
        warning on
        warning('Using global max...')
    elseif MatchedModMax==2
        warning on
        warning('Using DEFINED max...')
    end
    ScreenSize=get(0,'ScreenSize');
    CalculationLabelPos=[0.01,0.79,0.12,0.2];
    CalculationLabelPos2=[0.01,0.79,0.2,0.2];
    NumIterations=0;
    if isempty(RemovalIndex)
        NumIterations=0;
    else
        NumIterations=length(RemovalIndex);
    end
    
    NumGroupsSubPlot=NumGroups;
    if NumMods<2
        NumModsSubPlot=2;
    else
        NumModsSubPlot=NumMods;
    end
    
    if FlipHist
        XTickAngle=0;
        XLabelRotation=90;
        XLabelVertAlign='bottom';
        XLabelHorzAlign='center';
        
        YTickAngle=30;
        YLabelRotation=0;
        YLabelVertAlign='top';
        YLabelHorzAlign='center';
    else
        XTickAngle=30;
        XLabelRotation=0;
        XLabelVertAlign='middle';
        XLabelHorzAlign='center';
        
        YTickAngle=0;
        YLabelRotation=0;
        YLabelVertAlign='middle';
        YLabelHorzAlign='right';
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
            for r=1:length(RemovalIndex(1:RemovalNum))
                RemovalLabel=[RemovalLabel,num2str(RemovalIndex(r))];
                RemovalLabela=[RemovalLabela,num2str(RemovalIndex(r))];
                if length(RemovalIndex(1:RemovalNum))>1&&r<length(RemovalIndex(1:RemovalNum))
                    RemovalLabel=[RemovalLabel,'_'];
                    RemovalLabela=[RemovalLabela,'_'];
                end
            end
            count=0;
            Groups=[];
            for q=1:NumGroups
                if any(q==RemovalIndex(1:RemovalNum))
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
            %Split Mod
            for zzz=1:1
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FigName1=[FigName,' SplitMod',RemovalLabela];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['Making: ',FigName1,'...'])
                AZFig=figure('name',FigName1);
                if length(Groups)>3
                    set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                elseif length(Groups)==1
                    MetricLabelFontSize=12;
                    MetricScaleFontSize=10;
                    set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                else
                    set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                end
                set(gcf,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                clear PlotPanels LabelPanels GroupLabels
                NumPanels=(length(Groups)+1)*(NumMods);
                PanelCount=1;
                PlotPanels=[];
                PlotPanelCount=1;
                LabelPanels=[];
                LabelPanelCount=1;
                GlobalVertAdjust=0.15;
                LineWidth=0.5;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for Mod=1:NumMods
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if MatchedModMax==1
                        TempMax=0;
                        for Mod1=1:length(ModBins)
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                    if ProfileError
                                        TempMean=ModBins(Mod).Bins(q2).Profile_Mean(:);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempError=ModBins(Mod).Bins(q2).Profile_Error(:);
                                        TempError(isinf(TempError))=NaN;
                                        TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                    else
                                        TempMean=ModBins(Mod).Bins(q2).Profile_Mean(:);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempMax=max([TempMax,max(TempMean)]);
                                    end
                                end
                                clear TempMean TempError

                            end
                        end
                    elseif MatchedModMax==2
                        TempMax=ModBins(Mod).Profile_Max;
                    else
                        TempMax=0;
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                if ProfileError
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(:);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempError=ModBins(Mod).Bins(q2).Profile_Error(:);
                                    TempError(isinf(TempError))=NaN;
                                    TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                else
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(:);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempMax=max([TempMax,max(TempMean)]);
                                end
                            end
                            clear TempMean TempError
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                    box off
                    axis off
                    TempPos=get(LabelPanels(LabelPanelCount),'position');
                    set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                    PanelCount=PanelCount+1;
                    LabelPanelCount=LabelPanelCount+1;
                    for q1=1:length(Groups)
                        q=Groups(q1);
                        PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        hold on
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                        if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
                            if ProfileError
                                lineProps.col{1}=ModBins(Mod).Color;
                                lineProps.style='-';
                                lineProps.width=LineWidth;
                                mseb(ModBins(Mod).Profile_XData,...
                                    ModBins(Mod).Bins(q).Profile_Mean,...
                                    ModBins(Mod).Bins(q).Profile_Error,...
                                    lineProps,0);
                %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
                %                     ModBins(Mod).Bins(q).Profile_Mean,...
                %                     ModBins(Mod).Bins(q).Profile_Error,...
                %                     ['-',ModBins(Mod).Color]);
                            else
                                plot(ModBins(Mod).Profile_XData,...
                                    ModBins(Mod).Bins(q).Profile_Mean,...
                                    '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
                            end
                        end
                        if ~isempty(PlotMarkers)
                            hold on
                            for ii=1:length(PlotMarkers)
                                if isempty(PlotMarkers(ii).MarkerStyle)
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth,...
                                        'markersize',PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(PlotMarkers,'Text')
                                    text(PlotMarkers(ii).Text_X,...
                                        PlotMarkers(ii).Text_Y,...
                                        PlotMarkers(ii).Text,...
                                        'FontName',PlotMarkers(ii).FontName,...
                                        'FontSize',PlotMarkers(ii).FontSize,...
                                        'color',PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                        if isfield(ModBins(Mod).Bins,'PlotMarkers')
                            hold on
                            for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                        'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                    text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                        'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                        'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                        if TempMax>0
                            ylim([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                        end
                        if ControlYTick
                            yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                            yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                            ytickangle(YTickAngle)
                        else
                            ytickangle(YTickAngle)
                        end
                        if any(~isnan(ModBins(Mod).Profile_XData))
                            xlim([0,ModBins(Mod).Profile_XData(length(ModBins(Mod).Profile_XData))])
                        end
                        if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                            if FlipHist
                            else
                                set(gca,'yticklabels',[])
                            end
                        else
                            if FlipHist
                                ylabel(vertcat(ProfileYLabel),...
                                    'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                    'horizontalalignment',YLabelHorzAlign,...
                                    'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            else
                                ylabel(vertcat(ModBins(Mod).Label,ProfileYLabel),...
                                    'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                    'horizontalalignment',YLabelHorzAlign,...
                                    'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            end
                        end
                        xticks(ProfileXTicks)
                        if (Mod~=NumMods&&~FlipHist)||(q~=Groups(1)&&FlipHist)
                            set(gca,'xticklabels',[])
                        else
                            xlabel([ProfileXLabel],...
                                'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                                'horizontalalignment',XLabelHorzAlign,...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            tempxticklabels=[];
                            for i=1:length(ProfileXTicks)
                                tempxticklabels{i}=num2str(ProfileXTicks(i));
                            end
                            xticklabels(tempxticklabels)
                            xtickangle(XTickAngle)
                        end
                        FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                        if FlipHist
                            YScaleInfo=get(gca,'ylabel');
                            YScaleModifier=[];
                            if ischar(YScaleInfo.String)
                                YScaleModifier=YScaleInfo.String;
                            elseif iscell(YScaleInfo.String)
                                for s=1:length(YScaleInfo.String)
                                    if any(strfind(YScaleInfo.String{s},'\times'))
                                        YScaleModifier=YScaleInfo.String{s};
                                    end
                                end
                            end
                            if any(strfind(YScaleModifier,'\times'))
                                TextAddition=YScaleModifier;
                            else
                                TextAddition=[];
                            end
                            XLimits=xlim;YLimits=ylim;
                            text(XLimits(1)+(XLimits(2)-XLimits(1))*0.1,...
                                YLimits(1)+(YLimits(2)-YLimits(1))*0.1,...
                                [ModBins(Mod).Label,TextAddition],...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                        end
                        PanelCount=PanelCount+1;
                        PlotPanelCount=PlotPanelCount+1;
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                TempModCount=0;
                for PlotPanelCount1=1:length(PlotPanels)
                    TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    %if PlotPanelCount1<=length(Groups)
                    %    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.5,TempPos(3),TempPos(4)*0.5])
                    %else
                    %    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.9,TempPos(3),TempPos(4)*0.5])
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.5+(TempModCount*TempPos(4)*0.4),TempPos(3),TempPos(4)*0.5])
                    %end
                    set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                    if rem(PlotPanelCount1,length(Groups))==0
                        TempModCount=TempModCount+1;
                    end
                end
                for PlotPanelCount1=1:length(PlotPanels)
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for LabelPanelCount1=1:length(LabelPanels)
                    TempPos=get(LabelPanels(LabelPanelCount1),'position');
                    set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for q1=1:length(Groups)
                    q=Groups(q1);
                    TempPos=get(PlotPanels(q1),'position');
                    GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
                        'string',ModBins(1).Bins(q).Label,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                end
                q=1;
                TempPos=get(PlotPanels(q),'position');
                GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                    'string',CalculationLabel,...
                    'verticalalignment','middle',...
                    'horizontalalignment','center',...
                    'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ProfileError
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
                else
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf('Finished!\n')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                close(AZFig)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Mod Overlay
            if NumMods>1&&~FlipHist
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FigName1=[FigName,' ModOver',RemovalLabela];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['Making: ',FigName1,'...'])
                AZFig=figure('name',FigName1);
                if length(Groups)>3
                    set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                elseif length(Groups)==1
                    MetricLabelFontSize=12;
                    MetricScaleFontSize=10;
                    set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                else
                    set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                end
                set(gcf,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                clear PlotPanels LabelPanels GroupLabels
                NumPanels=(length(Groups)+1)*(NumMods);
                PanelCount=1;
                PlotPanels=[];
                PlotPanelCount=1;
                LabelPanels=[];
                LabelPanelCount=1;
                GlobalVertAdjust=0.15;
                LineWidth=0.5;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                box off
                axis off
                TempPos=get(LabelPanels(LabelPanelCount),'position');
                set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                PanelCount=PanelCount+1;
                LabelPanelCount=LabelPanelCount+1;
                for q1=1:length(Groups)
                    q=Groups(q1);
                    PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        for Mod1=1:length(ModBins)
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                if any(~isnan(ModBins(Mod1).Bins(q2).Profile_Mean))&&length(ModBins(Mod1).Bins(q2).Profile_Mean)>=length(ModBins(Mod1).MatchProfileXIndices)
                                    if ProfileError
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(:);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempError=ModBins(Mod1).Bins(q2).Profile_Error(:);
                                        TempError(isinf(TempError))=NaN;
                                        TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                    else
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(:);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempMax=max([TempMax,max(TempMean)]);
                                    end
                                end
                                clear TempMean TempError
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        hold on
                        if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
                            if ProfileError
                                lineProps.col{1}=ModBins(Mod).Color;
                                lineProps.style='-';
                                lineProps.width=LineWidth;
                                mseb(ModBins(Mod).Profile_XData,...
                                    ModBins(Mod).Bins(q).Profile_Mean,...
                                    ModBins(Mod).Bins(q).Profile_Error,...
                                    lineProps,0);
                %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
                %                     ModBins(Mod).Bins(q).Profile_Mean,...
                %                     ModBins(Mod).Bins(q).Profile_Error,...
                %                     ['-',ModBins(Mod).Color]);
                            else
                                plot(ModBins(Mod).Profile_XData,...
                                    ModBins(Mod).Bins(q).Profile_Mean,...
                                    '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
                            end
                        end
                    end
                    if ~isempty(PlotMarkers)
                        hold on
                        for ii=1:length(PlotMarkers)
                            if isempty(PlotMarkers(ii).MarkerStyle)
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth);                    
                            else
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth,...
                                    'markersize',PlotMarkers(ii).MarkerSize);
                            end
                            if isfield(PlotMarkers,'Text')
                                text(PlotMarkers(ii).Text_X,...
                                    PlotMarkers(ii).Text_Y,...
                                    PlotMarkers(ii).Text,...
                                    'FontName',PlotMarkers(ii).FontName,...
                                    'FontSize',PlotMarkers(ii).FontSize,...
                                    'color',PlotMarkers(ii).FontColor);
                            end
                        end
                    end
                    for Mod=1:NumMods
                        if isfield(ModBins(Mod).Bins,'PlotMarkers')
                            hold on
                            for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                        'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                    text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                        'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                        'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                    end
                    if TempMax>0
                        ylim([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                    end
                    if ControlYTick
                        yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                        yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                        ytickangle(YTickAngle)
                    else
                        ytickangle(YTickAngle)
                    end
                    if any(~isnan(ModBins(Mod).Profile_XData))
                        xlim([0,ModBins(Mod).Profile_XData(length(ModBins(Mod).Profile_XData))])
                    end
                    if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                        set(gca,'yticklabels',[])
                    else
                        ylabel(ProfileYLabel,...
                            'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                            'horizontalalignment',YLabelHorzAlign,...
                            'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    end
                    xticks(ProfileXTicks)
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                        tempxticklabels=[];
                        for i=1:length(ProfileXTicks)
                            tempxticklabels{i}=num2str(ProfileXTicks(i));
                        end
                        xticklabels(tempxticklabels)
                        xtickangle(XTickAngle)
                    FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                    PanelCount=PanelCount+1;
                    PlotPanelCount=PlotPanelCount+1;

                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for PlotPanelCount1=1:length(PlotPanels)
                    TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    if PlotPanelCount1<=length(Groups)
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)/2,TempPos(3),TempPos(4)/2])
                    else
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.9,TempPos(3),TempPos(4)/2])
                    end
                    set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                end
                for PlotPanelCount1=1:length(PlotPanels)
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for LabelPanelCount1=1:length(LabelPanels)
                    TempPos=get(LabelPanels(LabelPanelCount1),'position');
                    set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for q1=1:length(Groups)
                    q=Groups(q1);
                    TempPos=get(PlotPanels(q1),'position');
                    GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
                        'string',ModBins(1).Bins(q).Label,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                end
                q=1;
                TempPos=get(PlotPanels(q),'position');
                GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                    'string',CalculationLabel,...
                    'verticalalignment','middle',...
                    'horizontalalignment','center',...
                    'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ProfileError
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
                else
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf('Finished!\n')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                close(AZFig)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Split Mod MatchX
            if ~FlipHist
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FigName1=[FigName,' SplitModMatchX',RemovalLabela];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['Making: ',FigName1,'...'])
                AZFig=figure('name',FigName1);
                if length(Groups)>3
                    set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                elseif length(Groups)==1
                    MetricLabelFontSize=12;
                    MetricScaleFontSize=10;
                    set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                else
                    set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                end
                set(gcf,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                clear PlotPanels LabelPanels GroupLabels
                NumPanels=(length(Groups)+1)*(NumMods);
                PanelCount=1;
                PlotPanels=[];
                PlotPanelCount=1;
                LabelPanels=[];
                LabelPanelCount=1;
                GlobalVertAdjust=0.15;
                LineWidth=0.5;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for Mod=1:NumMods
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if MatchedModMax==1
                        TempMax=0;
                        for Mod1=1:length(ModBins)
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                if any(~isnan(ModBins(Mod1).Bins(q2).Profile_Mean))&&length(ModBins(Mod1).Bins(q2).Profile_Mean)>=length(ModBins(Mod1).MatchProfileXIndices)
                                    if ProfileError
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempError=ModBins(Mod1).Bins(q2).Profile_Error(ModBins(Mod1).MatchProfileXIndices);
                                        TempError(isinf(TempError))=NaN;
                                        TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                    else
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempMax=max([TempMax,max(TempMean)]);
                                    end
                                end
                                clear TempMean TempError
                            end
                        end
                    elseif MatchedModMax==2
                        TempMax=ModBins(Mod).Profile_Max;
                    else    
                        TempMax=0;
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                if ProfileError
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                    TempError(isinf(TempError))=NaN;
                                    TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                else
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempMax=max([TempMax,max(TempMean)]);
                                end
                            end
                            clear TempMean TempError
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                    box off
                    axis off
                    TempPos=get(LabelPanels(LabelPanelCount),'position');
                    set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                    PanelCount=PanelCount+1;
                    LabelPanelCount=LabelPanelCount+1;
                    for q1=1:length(Groups)
                        q=Groups(q1);
                        PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                        hold on
                        if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
                            if ProfileError
                                lineProps.col{1}=ModBins(Mod).Color;
                                lineProps.style='-';
                                lineProps.width=LineWidth;
                                mseb(ModBins(Mod).Profile_XData,...
                                    ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                                    ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
                                    lineProps,0);
                %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
                %                     ModBins(Mod).Bins(q).Profile_Mean,...
                %                     ModBins(Mod).Bins(q).Profile_Error,...
                %                     ['-',ModBins(Mod).Color]);
                            else
                                plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                    ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                                    '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
                            end
                        end
                        if ~isempty(PlotMarkers)
                            hold on
                            for ii=1:length(PlotMarkers)
                                if isempty(PlotMarkers(ii).MarkerStyle)
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth,...
                                        'markersize',PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(PlotMarkers,'Text')
                                    text(PlotMarkers(ii).Text_X,...
                                        PlotMarkers(ii).Text_Y,...
                                        PlotMarkers(ii).Text,...
                                        'FontName',PlotMarkers(ii).FontName,...
                                        'FontSize',PlotMarkers(ii).FontSize,...
                                        'color',PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                        if isfield(ModBins(Mod).Bins,'PlotMarkers')
                            hold on
                            for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                        'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                    text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                        'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                        'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                        if TempMax>0
                            ylim([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                        end
                        if ControlYTick
                            yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                            yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                        ytickangle(YTickAngle)
                        else
                        ytickangle(YTickAngle)

                        end
                        if ~isempty(MatchProfileXLim)
                            xlim(MatchProfileXLim)
                        else
                            if any(~isnan(ModBins(Mod).Profile_XData))
                                xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                            end
                        end
                        if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                            if FlipHist
                            else
                                set(gca,'yticklabels',[])
                            end
                        else
                            if FlipHist
                            ylabel(vertcat(ProfileYLabel),...
                                'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                'horizontalalignment',YLabelHorzAlign,...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            else
                            ylabel(vertcat(ModBins(Mod).Label,ProfileYLabel),...
                                'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                'horizontalalignment',YLabelHorzAlign,...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            end
                        end
                        xticks(MatchProfileXTicks)
                        if (Mod~=NumMods&&~FlipHist)||(q~=Groups(1)&&FlipHist)
                            set(gca,'xticklabels',[])
                        else
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            tempxticklabels=[];
                            for i=1:length(MatchProfileXTicks)
                                tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                            end
                            xticklabels(tempxticklabels)
                            xtickangle(XTickAngle)
                        end
                        FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                        if FlipHist
                            YScaleInfo=get(gca,'ylabel');
                            YScaleModifier=[];
                            if ischar(YScaleInfo.String)
                                YScaleModifier=YScaleInfo.String;
                            elseif iscell(YScaleInfo.String)
                                for s=1:length(YScaleInfo.String)
                                    if any(strfind(YScaleInfo.String{s},'\times'))
                                        YScaleModifier=YScaleInfo.String{s};
                                    end
                                end
                            end
                            if any(strfind(YScaleModifier,'\times'))
                                TextAddition=YScaleModifier;
                            else
                                TextAddition=[];
                            end
                            XLimits=xlim;YLimits=ylim;
                            text(XLimits(1)+(XLimits(2)-XLimits(1))*0.1,...
                                YLimits(1)+(YLimits(2)-YLimits(1))*0.1,...
                                [ModBins(Mod).Label,TextAddition],...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                        end
                        PanelCount=PanelCount+1;
                        PlotPanelCount=PlotPanelCount+1;
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                TempModCount=0;
                for PlotPanelCount1=1:length(PlotPanels)
                    TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    %if PlotPanelCount1<=length(Groups)
                    %    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.5,TempPos(3),TempPos(4)*0.5])
                    %else
                    %    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.9,TempPos(3),TempPos(4)*0.5])
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.5+(TempModCount*TempPos(4)*0.4),TempPos(3),TempPos(4)*0.5])
                    %end
                    set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                    if rem(PlotPanelCount1,length(Groups))==0
                        TempModCount=TempModCount+1;
                    end
                end
                for PlotPanelCount1=1:length(PlotPanels)
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for LabelPanelCount1=1:length(LabelPanels)
                    TempPos=get(LabelPanels(LabelPanelCount1),'position');
                    set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for q1=1:length(Groups)
                    q=Groups(q1);
                    TempPos=get(PlotPanels(q1),'position');
                    GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
                        'string',ModBins(1).Bins(q).Label,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                end
                q=1;
                TempPos=get(PlotPanels(q),'position');
                GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                    'string',CalculationLabel,...
                    'verticalalignment','middle',...
                    'horizontalalignment','center',...
                    'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ProfileError
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
                else
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf('Finished!\n')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                close(AZFig)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Mod Overlay MatchX
            if NumMods>1&&~FlipHist
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FigName1=[FigName,' ModOverMatchX',RemovalLabela];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['Making: ',FigName1,'...'])
                AZFig=figure('name',FigName1);
                if length(Groups)>3
                    set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                elseif length(Groups)==1
                    MetricLabelFontSize=12;
                    MetricScaleFontSize=10;
                    set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                else
                    set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                end
                set(gcf,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                clear PlotPanels LabelPanels GroupLabels
                NumPanels=(length(Groups)+1)*(NumMods);
                PanelCount=1;
                PlotPanels=[];
                PlotPanelCount=1;
                LabelPanels=[];
                LabelPanelCount=1;
                GlobalVertAdjust=0.15;
                LineWidth=0.5;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                box off
                axis off
                TempPos=get(LabelPanels(LabelPanelCount),'position');
                set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                PanelCount=PanelCount+1;
                LabelPanelCount=LabelPanelCount+1;
                for q1=1:length(Groups)
                    q=Groups(q1);
                    PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        for Mod1=1:length(ModBins)
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                if any(~isnan(ModBins(Mod1).Bins(q2).Profile_Mean))&&length(ModBins(Mod1).Bins(q2).Profile_Mean)>=length(ModBins(Mod1).MatchProfileXIndices)
                                    if ProfileError
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempError=ModBins(Mod1).Bins(q2).Profile_Error(ModBins(Mod1).MatchProfileXIndices);
                                        TempError(isinf(TempError))=NaN;
                                        TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                    else
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempMax=max([TempMax,max(TempMean)]);
                                    end
                                end
                                clear TempMean TempError
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        hold on
                        if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
                            if ProfileError
                                lineProps.col{1}=ModBins(Mod).Color;
                                lineProps.style='-';
                                lineProps.width=LineWidth;
                                mseb(ModBins(Mod).Profile_XData,...
                                    ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                                    ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
                                    lineProps,0);
                %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
                %                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                %                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
                %                     ['-',ModBins(Mod).Color]);
                            else
                                plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                    ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                                    '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
                            end
                        end
                    end
                    if ~isempty(PlotMarkers)
                        hold on
                        for ii=1:length(PlotMarkers)
                            if isempty(PlotMarkers(ii).MarkerStyle)
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth);                    
                            else
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth,...
                                    'markersize',PlotMarkers(ii).MarkerSize);
                            end
                            if isfield(PlotMarkers,'Text')
                                text(PlotMarkers(ii).Text_X,...
                                    PlotMarkers(ii).Text_Y,...
                                    PlotMarkers(ii).Text,...
                                    'FontName',PlotMarkers(ii).FontName,...
                                    'FontSize',PlotMarkers(ii).FontSize,...
                                    'color',PlotMarkers(ii).FontColor);
                            end
                        end
                    end
                    for Mod=1:NumMods
                        if isfield(ModBins(Mod).Bins,'PlotMarkers')
                            hold on
                            for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                        'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                    text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                        'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                        'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                    end
                    if TempMax>0
                        ylim([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                    end
                    if ControlYTick
                        yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                        yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                        ytickangle(YTickAngle)
                    else
                        ytickangle(YTickAngle)

                    end
                    if ~isempty(MatchProfileXLim)
                        xlim(MatchProfileXLim)
                    else
                        if any(~isnan(ModBins(Mod).Profile_XData))
                            xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                        end
                    end
                    if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                        set(gca,'yticklabels',[])
                    else
                        ylabel(ProfileYLabel,...
                            'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                            'horizontalalignment',YLabelHorzAlign,...
                            'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    end
                    xticks(MatchProfileXTicks)
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    tempxticklabels=[];
                    for i=1:length(MatchProfileXTicks)
                        tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                    end
                    xticklabels(tempxticklabels)
                    xtickangle(XTickAngle)
                    FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                    PanelCount=PanelCount+1;
                    PlotPanelCount=PlotPanelCount+1;

                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for PlotPanelCount1=1:length(PlotPanels)
                    TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    if PlotPanelCount1<=length(Groups)
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)/2,TempPos(3),TempPos(4)/2])
                    else
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.9,TempPos(3),TempPos(4)/2])
                    end
                    set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                end
                for PlotPanelCount1=1:length(PlotPanels)
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for LabelPanelCount1=1:length(LabelPanels)
                    TempPos=get(LabelPanels(LabelPanelCount1),'position');
                    set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for q1=1:length(Groups)
                    q=Groups(q1);
                    TempPos=get(PlotPanels(q1),'position');
                    GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
                        'string',ModBins(1).Bins(q).Label,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                end
                q=1;
                TempPos=get(PlotPanels(q),'position');
                GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                    'string',CalculationLabel,...
                    'verticalalignment','middle',...
                    'horizontalalignment','center',...
                    'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ProfileError
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
                else
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf('Finished!\n')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                close(AZFig)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %BinNorm Mod Overlay MatchX
            if NumMods>1&&~FlipHist
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FigName1=[FigName,' BinNormModOverMatchX',RemovalLabela];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['Making: ',FigName1,'...'])
                AZFig=figure('name',FigName1);
                if length(Groups)>3
                    set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                elseif length(Groups)==1
                    MetricLabelFontSize=12;
                    MetricScaleFontSize=10;
                    set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                else
                    set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                end
                set(gcf,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                clear PlotPanels LabelPanels GroupLabels
                NumPanels=(length(Groups)+1)*(NumMods);
                PanelCount=1;
                PlotPanels=[];
                PlotPanelCount=1;
                LabelPanels=[];
                LabelPanelCount=1;
                GlobalVertAdjust=0.15;
                LineWidth=0.5;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                box off
                axis off
                TempPos=get(LabelPanels(LabelPanelCount),'position');
                set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                PanelCount=PanelCount+1;
                LabelPanelCount=LabelPanelCount+1;
                for q1=1:length(Groups)
                    q=Groups(q1);
                    PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        for Mod1=1:length(ModBins)
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                if any(~isnan(ModBins(Mod1).Bins(q2).Profile_Mean))&&length(ModBins(Mod1).Bins(q2).Profile_Mean)>=length(ModBins(Mod1).MatchProfileXIndices)
                                    if ProfileError
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempError=ModBins(Mod1).Bins(q2).Profile_Error(ModBins(Mod1).MatchProfileXIndices);
                                        TempError(isinf(TempError))=NaN;
                                        TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                    else
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempMax=max([TempMax,max(TempMean)]);
                                    end
                                end
                                clear TempMean TempError
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        hold on
                        if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
%                             if ProfileError
%                                 lineProps.col{1}=ModBins(Mod).Color;
%                                 lineProps.style='-';
%                                 lineProps.width=LineWidth;
%                                 mseb(ModBins(Mod).Profile_XData,...
%                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
%                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
%                                     lineProps,0);
%                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
%                 %                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
%                 %                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
%                 %                     ['-',ModBins(Mod).Color]);
%                             else
                                plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                    ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
                                    '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
%                             end
                            if isfield(ModBins(Mod).Bins,'PlotMarkers')
%                                     if isfield(ModBins,'Bin_Colors')
%                                         TempColor=ModBins(Mod).Bin_Colors{q};
%                                         TempColor1=ModBins(Mod).Bin_Colors{q};
%                                     else
%                                         TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
%                                         TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
%                                     end
%                                     hold on
%                                     for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
%                                         if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
%                                         else
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
%                                                 'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
%                                         end
%                                             if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
%                                                 text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
%                                                     'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
%                                                     'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
%                                                     'color',TempColor1);
%                                             end
%                                     end
                            end
                        end
                    end
                    ylim([0 1.05])
                    if ~isempty(PlotMarkers)
                        hold on
                        for ii=1:length(PlotMarkers)
                            if isempty(PlotMarkers(ii).MarkerStyle)
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth);                    
                            else
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth,...
                                    'markersize',PlotMarkers(ii).MarkerSize);
                            end
                            if isfield(PlotMarkers,'Text')
                                text(PlotMarkers(ii).Text_X,...
                                    PlotMarkers(ii).Text_Y,...
                                    PlotMarkers(ii).Text,...
                                    'FontName',PlotMarkers(ii).FontName,...
                                    'FontSize',PlotMarkers(ii).FontSize,...
                                    'color',PlotMarkers(ii).FontColor);
                            end
                        end
                    end
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                            if ProfileError
                                TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                TempMean(isinf(TempMean))=NaN;
                                TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                TempError(isinf(TempError))=NaN;
                                TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                            else
                                TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                TempMean(isinf(TempMean))=NaN;
                                TempMax=max([TempMax,max(TempMean)]);
                            end
                        end
                        clear TempMean TempError
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if isfield(ModBins(Mod).Bins,'PlotMarkers')
                            hold on
                            for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData/TempMax,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData/TempMax,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                        'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                    text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y/TempMax,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                        'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                        'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                    end
                    if ControlYTick
                        yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                        yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                        ytickangle(YTickAngle)
                    else
                        ytickangle(YTickAngle)

                    end
                    if ~isempty(MatchProfileXLim)
                        xlim(MatchProfileXLim)
                    else
                        if any(~isnan(ModBins(Mod).Profile_XData))
                            xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                        end
                    end
                    if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                        set(gca,'yticklabels',[])
                    else
                        ylim([0 1.05])
                        ylabel({'Globally';'Normalized'},...
                            'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                            'horizontalalignment',YLabelHorzAlign,...
                            'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    end
                    ylim([0 1.05])
                    xticks(MatchProfileXTicks)
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    tempxticklabels=[];
                    for i=1:length(MatchProfileXTicks)
                        tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                    end
                    xticklabels(tempxticklabels)
                    xtickangle(XTickAngle)
                    FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                    PanelCount=PanelCount+1;
                    PlotPanelCount=PlotPanelCount+1;

                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for PlotPanelCount1=1:length(PlotPanels)
                    TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    if PlotPanelCount1<=length(Groups)
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)/2,TempPos(3),TempPos(4)/2])
                    else
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.9,TempPos(3),TempPos(4)/2])
                    end
                    set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                end
                for PlotPanelCount1=1:length(PlotPanels)
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for LabelPanelCount1=1:length(LabelPanels)
                    TempPos=get(LabelPanels(LabelPanelCount1),'position');
                    set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for q1=1:length(Groups)
                    q=Groups(q1);
                    TempPos=get(PlotPanels(q1),'position');
                    GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
                        'string',ModBins(1).Bins(q).Label,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                end
                q=1;
                TempPos=get(PlotPanels(q),'position');
                GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                    'string',CalculationLabel,...
                    'verticalalignment','middle',...
                    'horizontalalignment','center',...
                    'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ProfileError
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
                else
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf('Finished!\n')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                close(AZFig)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %GroupNorm Mod Overlay MatchX
            if NumMods>1&&~FlipHist
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FigName1=[FigName,' GroupNormModOverMatchX',RemovalLabela];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['Making: ',FigName1,'...'])
                AZFig=figure('name',FigName1);
                if length(Groups)>3
                    set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                elseif length(Groups)==1
                    MetricLabelFontSize=12;
                    MetricScaleFontSize=10;
                    set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                else
                    set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                end
                set(gcf,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                clear PlotPanels LabelPanels GroupLabels
                NumPanels=(length(Groups)+1)*(NumMods);
                PanelCount=1;
                PlotPanels=[];
                PlotPanelCount=1;
                LabelPanels=[];
                LabelPanelCount=1;
                GlobalVertAdjust=0.15;
                LineWidth=0.5;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                box off
                axis off
                TempPos=get(LabelPanels(LabelPanelCount),'position');
                set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                PanelCount=PanelCount+1;
                LabelPanelCount=LabelPanelCount+1;
                for q1=1:length(Groups)
                    q=Groups(q1);
                    PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                if ProfileError
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                    TempError(isinf(TempError))=NaN;
                                    TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                else
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempMax=max([TempMax,max(TempMean)]);
                                end
                            end
                            clear TempMean TempError
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        hold on
                        if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
%                             if ProfileError
%                                 lineProps.col{1}=ModBins(Mod).Color;
%                                 lineProps.style='-';
%                                 lineProps.width=LineWidth;
%                                 mseb(ModBins(Mod).Profile_XData,...
%                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
%                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
%                                     lineProps,0);
%                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
%                 %                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
%                 %                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
%                 %                     ['-',ModBins(Mod).Color]);
%                             else
                                plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                    ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/TempMax,...
                                    '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
%                             end
                            if isfield(ModBins(Mod).Bins,'PlotMarkers')
%                                     if isfield(ModBins,'Bin_Colors')
%                                         TempColor=ModBins(Mod).Bin_Colors{q};
%                                         TempColor1=ModBins(Mod).Bin_Colors{q};
%                                     else
%                                         TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
%                                         TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
%                                     end
%                                     hold on
%                                     for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
%                                         if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
%                                         else
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
%                                                 'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
%                                         end
%                                             if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
%                                                 text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
%                                                     'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
%                                                     'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
%                                                     'color',TempColor1);
%                                             end
%                                     end
                            end
                        end
                    end
                    ylim([0 1.05])
                    if ~isempty(PlotMarkers)
                        hold on
                        for ii=1:length(PlotMarkers)
                            if isempty(PlotMarkers(ii).MarkerStyle)
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth);                    
                            else
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth,...
                                    'markersize',PlotMarkers(ii).MarkerSize);
                            end
                            if isfield(PlotMarkers,'Text')
                                text(PlotMarkers(ii).Text_X,...
                                    PlotMarkers(ii).Text_Y,...
                                    PlotMarkers(ii).Text,...
                                    'FontName',PlotMarkers(ii).FontName,...
                                    'FontSize',PlotMarkers(ii).FontSize,...
                                    'color',PlotMarkers(ii).FontColor);
                            end
                        end
                    end
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                if ProfileError
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                    TempError(isinf(TempError))=NaN;
                                    TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                else
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempMax=max([TempMax,max(TempMean)]);
                                end
                            end
                            clear TempMean TempError
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if isfield(ModBins(Mod).Bins,'PlotMarkers')
                            hold on
                            for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData/TempMax,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData/TempMax,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                        'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                    text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y/TempMax,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                        'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                        'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                    end
                    if ControlYTick
                        yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                        yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                        ytickangle(YTickAngle)
                    else
                        ytickangle(YTickAngle)

                    end
                    if ~isempty(MatchProfileXLim)
                        xlim(MatchProfileXLim)
                    else
                        if any(~isnan(ModBins(Mod).Profile_XData))
                            xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                        end
                    end
                    if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                        set(gca,'yticklabels',[])
                    else
                        ylim([0 1.05])
                        ylabel({'Group';'Normalized'},...
                            'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                            'horizontalalignment',YLabelHorzAlign,...
                            'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    end
                    ylim([0 1.05])
                    xticks(MatchProfileXTicks)
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    tempxticklabels=[];
                    for i=1:length(MatchProfileXTicks)
                        tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                    end
                    xticklabels(tempxticklabels)
                    xtickangle(XTickAngle)
                    FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                    PanelCount=PanelCount+1;
                    PlotPanelCount=PlotPanelCount+1;

                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for PlotPanelCount1=1:length(PlotPanels)
                    TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    if PlotPanelCount1<=length(Groups)
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)/2,TempPos(3),TempPos(4)/2])
                    else
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.9,TempPos(3),TempPos(4)/2])
                    end
                    set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                end
                for PlotPanelCount1=1:length(PlotPanels)
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for LabelPanelCount1=1:length(LabelPanels)
                    TempPos=get(LabelPanels(LabelPanelCount1),'position');
                    set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for q1=1:length(Groups)
                    q=Groups(q1);
                    TempPos=get(PlotPanels(q1),'position');
                    GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
                        'string',ModBins(1).Bins(q).Label,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                end
                q=1;
                TempPos=get(PlotPanels(q),'position');
                GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                    'string',CalculationLabel,...
                    'verticalalignment','middle',...
                    'horizontalalignment','center',...
                    'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ProfileError
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
                else
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf('Finished!\n')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                close(AZFig)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Split Mod MatchX Centered
            if CenteredPlot
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FigName1=[FigName,' SplitModMatchXCentered',RemovalLabela];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['Making: ',FigName1,'...'])
                AZFig=figure('name',FigName1);
                if length(Groups)>3
                    set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                elseif length(Groups)==1
                    MetricLabelFontSize=12;
                    MetricScaleFontSize=10;
                    set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                else
                    set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                end
                set(gcf,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                clear PlotPanels LabelPanels GroupLabels
                NumPanels=(length(Groups)+1)*(NumMods);
                PanelCount=1;
                PlotPanels=[];
                PlotPanelCount=1;
                LabelPanels=[];
                LabelPanelCount=1;
                GlobalVertAdjust=0.15;
                LineWidth=0.5;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for Mod=1:NumMods
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if MatchedModMax==1
                        TempMax=0;
                        for Mod1=1:length(ModBins)
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                if any(~isnan(ModBins(Mod1).Bins(q2).Profile_Mean))&&length(ModBins(Mod1).Bins(q2).Profile_Mean)>=length(ModBins(Mod1).MatchProfileXIndices)
                                    if ProfileError
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempError=ModBins(Mod1).Bins(q2).Profile_Error(ModBins(Mod1).MatchProfileXIndices);
                                        TempError(isinf(TempError))=NaN;
                                        TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                    else
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempMax=max([TempMax,max(TempMean)]);
                                    end
                                end
                                clear TempMean TempError
                            end
                        end
                    elseif MatchedModMax==2
                        TempMax=ModBins(Mod).Profile_Max;
                    else    
                        TempMax=0;
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                if ProfileError
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                    TempError(isinf(TempError))=NaN;
                                    TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                else
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempMax=max([TempMax,max(TempMean)]);
                                end
                            end
                            clear TempMean TempError
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                    box off
                    axis off
                    TempPos=get(LabelPanels(LabelPanelCount),'position');
                    set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                    PanelCount=PanelCount+1;
                    LabelPanelCount=LabelPanelCount+1;
                    for q1=1:length(Groups)
                        q=Groups(q1);
                        PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                        hold on
                        if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
                            if ProfileError
                                lineProps.col{1}=ModBins(Mod).Color;
                                lineProps.style='-';
                                lineProps.width=LineWidth;
                                mseb(ModBins(Mod).Profile_XData,...
                                    ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                                    ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
                                    lineProps,0);
                %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
                %                     ModBins(Mod).Bins(q).Profile_Mean,...
                %                     ModBins(Mod).Bins(q).Profile_Error,...
                %                     ['-',ModBins(Mod).Color]);
                            else
                                plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                    ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                                    '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
                            end
                        end
                        if ~isempty(PlotMarkers)
                            hold on
                            for ii=1:length(PlotMarkers)
                                if isempty(PlotMarkers(ii).MarkerStyle)
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth,...
                                        'markersize',PlotMarkers(ii).MarkerSize);
                                end
                            end
                            if isfield(PlotMarkers,'Text')
                                text(PlotMarkers(ii).Text_X,...
                                    PlotMarkers(ii).Text_Y,...
                                    PlotMarkers(ii).Text,...
                                    'FontName',PlotMarkers(ii).FontName,...
                                    'FontSize',PlotMarkers(ii).FontSize,...
                                    'color',PlotMarkers(ii).FontColor);
                            end
                        end
                        if isfield(ModBins(Mod).Bins,'PlotMarkers')
                            hold on
                            for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                        'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                    text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
                                        ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                        'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                        'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                        if TempMax>0
                            ylim([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                        end
                        if ControlYTick
                            yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                            yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                        ytickangle(YTickAngle)
                        else
                        ytickangle(YTickAngle)

                        end
                        if ~isempty(MatchProfileXLim)
                            xlim(MatchProfileXLim)
                        else
                            if any(~isnan(ModBins(Mod).Profile_XData))
                                xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                            end
                        end
                        if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                            %set(gca,'yticklabels',[])
                        else
                            if FlipHist
                            ylabel(vertcat(ProfileYLabel),...
                                'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                'horizontalalignment',YLabelHorzAlign,...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            else
                            ylabel(vertcat(ModBins(Mod).Label,ProfileYLabel),...
                                'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                'horizontalalignment',YLabelHorzAlign,...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            end
                        end
                        xticks(MatchProfileXTicks)
                        if (Mod~=NumMods&&~FlipHist)||(q~=Groups(1)&&FlipHist)
                            set(gca,'xticklabels',[])
                        else
                            xlabel([ProfileXLabel],...
                                'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                                'horizontalalignment',XLabelHorzAlign,...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            tempxticklabels=[];
                            for i=1:length(MatchProfileXTicks)
                                tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                            end
                            xticklabels(tempxticklabels)
                            xtickangle(XTickAngle)
                        end
                        FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                        if FlipHist
                            YScaleInfo=get(gca,'ylabel');
                            YScaleModifier=[];
                            if ischar(YScaleInfo.String)
                                YScaleModifier=YScaleInfo.String;
                            elseif iscell(YScaleInfo.String)
                                for s=1:length(YScaleInfo.String)
                                    if any(strfind(YScaleInfo.String{s},'\times'))
                                        YScaleModifier=YScaleInfo.String{s};
                                    end
                                end
                            end
                            if any(strfind(YScaleModifier,'\times'))
                                TextAddition=YScaleModifier;
                            else
                                TextAddition=[];
                            end
                            XLimits=xlim;YLimits=ylim;
                            text(XLimits(1)+(XLimits(2)-XLimits(1))*0.1,...
                                YLimits(1)+(YLimits(2)-YLimits(1))*0.1,...
                                [ModBins(Mod).Label,TextAddition],...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                        end
                        PanelCount=PanelCount+1;
                        PlotPanelCount=PlotPanelCount+1;
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                TempModCount=0;
                for PlotPanelCount1=1:length(PlotPanels)
                    TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    %if PlotPanelCount1<=length(Groups)
                    %    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.5,TempPos(3),TempPos(4)*0.5])
                    %else
                    %    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.9,TempPos(3),TempPos(4)*0.5])
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1)+TempPos(3)/2,TempPos(2)+TempPos(4)*0.5+(TempModCount*TempPos(4)*0.4),TempPos(3)/2,TempPos(4)*0.5])
                    %end
                    set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                    if rem(PlotPanelCount1,length(Groups))==0
                        TempModCount=TempModCount+1;
                    end
                end
                for PlotPanelCount1=1:length(PlotPanels)
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for LabelPanelCount1=1:length(LabelPanels)
                    TempPos=get(LabelPanels(LabelPanelCount1),'position');
                    set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for q1=1:length(Groups)
                    q=Groups(q1);
                    TempPos=get(PlotPanels(q1),'position');
                    GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
                        'string',ModBins(1).Bins(q).Label,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                end
                q=1;
                TempPos=get(PlotPanels(q),'position');
                GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                    'string',CalculationLabel,...
                    'verticalalignment','middle',...
                    'horizontalalignment','center',...
                    'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ProfileError
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
                else
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf('Finished!\n')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                close(AZFig)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Mod Overlay MatchX Centered
            if NumMods>1&&CenteredPlot
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FigName1=[FigName,' ModOverMatchXCentered',RemovalLabela];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['Making: ',FigName1,'...'])
                AZFig=figure('name',FigName1);
                if length(Groups)>3
                    set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                elseif length(Groups)==1
                    MetricLabelFontSize=12;
                    MetricScaleFontSize=10;
                    set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                else
                    set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                end
                set(gcf,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                clear PlotPanels LabelPanels GroupLabels
                NumPanels=(length(Groups)+1)*(NumMods);
                PanelCount=1;
                PlotPanels=[];
                PlotPanelCount=1;
                LabelPanels=[];
                LabelPanelCount=1;
                GlobalVertAdjust=0.15;
                LineWidth=0.5;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                box off
                axis off
                TempPos=get(LabelPanels(LabelPanelCount),'position');
                set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                PanelCount=PanelCount+1;
                LabelPanelCount=LabelPanelCount+1;
                for q1=1:length(Groups)
                    q=Groups(q1);
                    PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        for Mod1=1:length(ModBins)
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                if any(~isnan(ModBins(Mod1).Bins(q2).Profile_Mean))&&length(ModBins(Mod1).Bins(q2).Profile_Mean)>=length(ModBins(Mod1).MatchProfileXIndices)
                                    if ProfileError
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempError=ModBins(Mod1).Bins(q2).Profile_Error(ModBins(Mod1).MatchProfileXIndices);
                                        TempError(isinf(TempError))=NaN;
                                        TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                    else
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempMax=max([TempMax,max(TempMean)]);
                                    end
                                end
                                clear TempMean TempError
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        hold on
                        if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
                            if ProfileError
                                lineProps.col{1}=ModBins(Mod).Color;
                                lineProps.style='-';
                                lineProps.width=LineWidth;
                                mseb(ModBins(Mod).Profile_XData,...
                                    ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                                    ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
                                    lineProps,0);
                %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
                %                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                %                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
                %                     ['-',ModBins(Mod).Color]);
                            else
                                plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                    ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                                    '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
                            end
                        end
                    end
                    if ~isempty(PlotMarkers)
                        hold on
                        for ii=1:length(PlotMarkers)
                            if isempty(PlotMarkers(ii).MarkerStyle)
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth);                    
                            else
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth,...
                                    'markersize',PlotMarkers(ii).MarkerSize);
                            end
                            if isfield(PlotMarkers,'Text')
                                text(PlotMarkers(ii).Text_X,...
                                    PlotMarkers(ii).Text_Y,...
                                    PlotMarkers(ii).Text,...
                                    'FontName',PlotMarkers(ii).FontName,...
                                    'FontSize',PlotMarkers(ii).FontSize,...
                                    'color',PlotMarkers(ii).FontColor);
                            end
                        end
                    end
                    for Mod=1:NumMods
                        if isfield(ModBins(Mod).Bins,'PlotMarkers')
                            hold on
                            for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                        'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                end
                                    if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                        text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                            ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
                                            ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                            'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                            'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                            'color',ModBins(Mod).Bins(q).PlotMarkers(ii).FontColor);
                                    end
                            end
                        end
                    end
                    if TempMax>0
                        ylim([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                    end
                    if ControlYTick
                        yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                        yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                        ytickangle(YTickAngle)
                    else
                        ytickangle(YTickAngle)

                    end
                    if ~isempty(MatchProfileXLim)
                        xlim(MatchProfileXLim)
                    else
                        if any(~isnan(ModBins(Mod).Profile_XData))
                            xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                        end
                    end
                    if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                        %set(gca,'yticklabels',[])
                    else
                        ylabel(ProfileYLabel,...
                            'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                            'horizontalalignment',YLabelHorzAlign,...
                            'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    end
                    xticks(MatchProfileXTicks)
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    tempxticklabels=[];
                    for i=1:length(MatchProfileXTicks)
                        tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                    end
                    xticklabels(tempxticklabels)
                    xtickangle(XTickAngle)
                    FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                    PanelCount=PanelCount+1;
                    PlotPanelCount=PlotPanelCount+1;

                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for PlotPanelCount1=1:length(PlotPanels)
                    TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    if PlotPanelCount1<=length(Groups)
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1)+TempPos(3)/2,TempPos(2)+TempPos(4)/2,TempPos(3)/2,TempPos(4)/2])
                    else
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1)+TempPos(3)/2,TempPos(2)+TempPos(4)*0.9,TempPos(3)/2,TempPos(4)/2])
                    end
                    set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                end
                for PlotPanelCount1=1:length(PlotPanels)
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for LabelPanelCount1=1:length(LabelPanels)
                    TempPos=get(LabelPanels(LabelPanelCount1),'position');
                    set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for q1=1:length(Groups)
                    q=Groups(q1);
                    TempPos=get(PlotPanels(q1),'position');
                    GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
                        'string',ModBins(1).Bins(q).Label,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                end
                q=1;
                TempPos=get(PlotPanels(q),'position');
                GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                    'string',CalculationLabel,...
                    'verticalalignment','middle',...
                    'horizontalalignment','center',...
                    'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ProfileError
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
                else
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf('Finished!\n')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                close(AZFig)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %BinNorm Mod Overlay MatchX Centered
            if NumMods>1&&CenteredPlot
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FigName1=[FigName,' BinNormModOverMatchXCenter',RemovalLabela];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['Making: ',FigName1,'...'])
                AZFig=figure('name',FigName1);
                if length(Groups)>3
                    set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                elseif length(Groups)==1
                    MetricLabelFontSize=12;
                    MetricScaleFontSize=10;
                    set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                else
                    set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                end
                set(gcf,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                clear PlotPanels LabelPanels GroupLabels
                NumPanels=(length(Groups)+1)*(NumMods);
                PanelCount=1;
                PlotPanels=[];
                PlotPanelCount=1;
                LabelPanels=[];
                LabelPanelCount=1;
                GlobalVertAdjust=0.15;
                LineWidth=0.5;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                box off
                axis off
                TempPos=get(LabelPanels(LabelPanelCount),'position');
                set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                PanelCount=PanelCount+1;
                LabelPanelCount=LabelPanelCount+1;
                for q1=1:length(Groups)
                    q=Groups(q1);
                    PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        for Mod1=1:length(ModBins)
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                if any(~isnan(ModBins(Mod1).Bins(q2).Profile_Mean))&&length(ModBins(Mod1).Bins(q2).Profile_Mean)>=length(ModBins(Mod1).MatchProfileXIndices)
                                    if ProfileError
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempError=ModBins(Mod1).Bins(q2).Profile_Error(ModBins(Mod1).MatchProfileXIndices);
                                        TempError(isinf(TempError))=NaN;
                                        TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                    else
                                        TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempMax=max([TempMax,max(TempMean)]);
                                    end
                                end
                                clear TempMean TempError
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        hold on
                        if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
%                             if ProfileError
%                                 lineProps.col{1}=ModBins(Mod).Color;
%                                 lineProps.style='-';
%                                 lineProps.width=LineWidth;
%                                 mseb(ModBins(Mod).Profile_XData,...
%                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
%                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
%                                     lineProps,0);
%                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
%                 %                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
%                 %                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
%                 %                     ['-',ModBins(Mod).Color]);
%                             else
                                plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                    ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
                                    '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
%                             end
                            if isfield(ModBins(Mod).Bins,'PlotMarkers')
%                                     if isfield(ModBins,'Bin_Colors')
%                                         TempColor=ModBins(Mod).Bin_Colors{q};
%                                         TempColor1=ModBins(Mod).Bin_Colors{q};
%                                     else
%                                         TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
%                                         TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
%                                     end
%                                     hold on
%                                     for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
%                                         if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
%                                         else
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
%                                                 'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
%                                         end
%                                             if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
%                                                 text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
%                                                     'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
%                                                     'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
%                                                     'color',TempColor1);
%                                             end
%                                     end
                            end
                        end
                    end
                    ylim([0 1.05])
                    if ~isempty(PlotMarkers)
                        hold on
                        for ii=1:length(PlotMarkers)
                            if isempty(PlotMarkers(ii).MarkerStyle)
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth);                    
                            else
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth,...
                                    'markersize',PlotMarkers(ii).MarkerSize);
                            end
                            if isfield(PlotMarkers,'Text')
                                text(PlotMarkers(ii).Text_X,...
                                    PlotMarkers(ii).Text_Y,...
                                    PlotMarkers(ii).Text,...
                                    'FontName',PlotMarkers(ii).FontName,...
                                    'FontSize',PlotMarkers(ii).FontSize,...
                                    'color',PlotMarkers(ii).FontColor);
                            end
                        end
                    end
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                            if ProfileError
                                TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                TempMean(isinf(TempMean))=NaN;
                                TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                TempError(isinf(TempError))=NaN;
                                TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                            else
                                TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                TempMean(isinf(TempMean))=NaN;
                                TempMax=max([TempMax,max(TempMean)]);
                            end
                        end
                        clear TempMean TempError
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if isfield(ModBins(Mod).Bins,'PlotMarkers')
                            hold on
                            for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData/TempMax,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData/TempMax,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                        'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                end
                                    if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                        text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                            ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y/TempMax,...
                                            ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                            'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                            'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                            'color',ModBins(Mod).Bins(q).PlotMarkers(ii).FontColor);
                                    end
                            end
                        end
                    end
                    if ControlYTick
                        yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                        yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                        ytickangle(YTickAngle)
                    else
                        ytickangle(YTickAngle)

                    end
                    if ~isempty(MatchProfileXLim)
                        xlim(MatchProfileXLim)
                    else
                        if any(~isnan(ModBins(Mod).Profile_XData))
                            xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                        end
                    end
                    if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                        %set(gca,'yticklabels',[])
                    else
                    ylim([0 1.05])
                    ylabel({'Globally';'Normalized'},...
                        'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                        'horizontalalignment',YLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    end
                    ylim([0 1.05])
                    xticks(MatchProfileXTicks)
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    tempxticklabels=[];
                    for i=1:length(MatchProfileXTicks)
                        tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                    end
                    xticklabels(tempxticklabels)
                    xtickangle(XTickAngle)
                    FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                    PanelCount=PanelCount+1;
                    PlotPanelCount=PlotPanelCount+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for PlotPanelCount1=1:length(PlotPanels)
                    TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    if PlotPanelCount1<=length(Groups)
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1)+TempPos(3)/2,TempPos(2)+TempPos(4)/2,TempPos(3)/2,TempPos(4)/2])
                    else
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1)+TempPos(3)/2,TempPos(2)+TempPos(4)*0.9,TempPos(3)/2,TempPos(4)/2])
                    end
                    set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                end
                for PlotPanelCount1=1:length(PlotPanels)
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for LabelPanelCount1=1:length(LabelPanels)
                    TempPos=get(LabelPanels(LabelPanelCount1),'position');
                    set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for q1=1:length(Groups)
                    q=Groups(q1);
                    TempPos=get(PlotPanels(q1),'position');
                    GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
                        'string',ModBins(1).Bins(q).Label,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                end
                q=1;
                TempPos=get(PlotPanels(q),'position');
                GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                    'string',CalculationLabel,...
                    'verticalalignment','middle',...
                    'horizontalalignment','center',...
                    'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ProfileError
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
                else
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf('Finished!\n')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                close(AZFig)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %GroupNorm Mod Overlay MatchX Centered
            if NumMods>1&&CenteredPlot
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FigName1=[FigName,' GroupNormModOverMatchXCenter',RemovalLabela];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(['Making: ',FigName1,'...'])
                AZFig=figure('name',FigName1);
                if length(Groups)>3
                    set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                elseif length(Groups)==1
                    MetricLabelFontSize=12;
                    MetricScaleFontSize=10;
                    set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                else
                    set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                end
                set(gcf,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                clear PlotPanels LabelPanels GroupLabels
                NumPanels=(length(Groups)+1)*(NumMods);
                PanelCount=1;
                PlotPanels=[];
                PlotPanelCount=1;
                LabelPanels=[];
                LabelPanelCount=1;
                GlobalVertAdjust=0.15;
                LineWidth=0.5;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                box off
                axis off
                TempPos=get(LabelPanels(LabelPanelCount),'position');
                set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                PanelCount=PanelCount+1;
                LabelPanelCount=LabelPanelCount+1;
                for q1=1:length(Groups)
                    q=Groups(q1);
                    PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                if ProfileError
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                    TempError(isinf(TempError))=NaN;
                                    TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                else
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempMax=max([TempMax,max(TempMean)]);
                                end
                            end
                            clear TempMean TempError
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        hold on
                        if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
%                             if ProfileError
%                                 lineProps.col{1}=ModBins(Mod).Color;
%                                 lineProps.style='-';
%                                 lineProps.width=LineWidth;
%                                 mseb(ModBins(Mod).Profile_XData,...
%                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
%                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
%                                     lineProps,0);
%                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
%                 %                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
%                 %                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
%                 %                     ['-',ModBins(Mod).Color]);
%                             else
                                plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                    ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/TempMax,...
                                    '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
%                             end
                            if isfield(ModBins(Mod).Bins,'PlotMarkers')
%                                     if isfield(ModBins,'Bin_Colors')
%                                         TempColor=ModBins(Mod).Bin_Colors{q};
%                                         TempColor1=ModBins(Mod).Bin_Colors{q};
%                                     else
%                                         TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
%                                         TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
%                                     end
%                                     hold on
%                                     for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
%                                         if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
%                                         else
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
%                                                 'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
%                                         end
%                                             if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
%                                                 text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
%                                                     'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
%                                                     'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
%                                                     'color',TempColor1);
%                                             end
%                                     end
                            end
                        end
                    end
                    ylim([0 1.05])
                    if ~isempty(PlotMarkers)
                        hold on
                        for ii=1:length(PlotMarkers)
                            if isempty(PlotMarkers(ii).MarkerStyle)
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth);                    
                            else
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth,...
                                    'markersize',PlotMarkers(ii).MarkerSize);
                            end
                            if isfield(PlotMarkers,'Text')
                                text(PlotMarkers(ii).Text_X,...
                                    PlotMarkers(ii).Text_Y,...
                                    PlotMarkers(ii).Text,...
                                    'FontName',PlotMarkers(ii).FontName,...
                                    'FontSize',PlotMarkers(ii).FontSize,...
                                    'color',PlotMarkers(ii).FontColor);
                            end
                        end
                    end
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                if ProfileError
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                    TempError(isinf(TempError))=NaN;
                                    TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                else
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempMax=max([TempMax,max(TempMean)]);
                                end
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if isfield(ModBins(Mod).Bins,'PlotMarkers')
                            hold on
                            for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData/TempMax,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',ModBins(Mod).Bins(q).PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData/TempMax,...
                                        [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                        'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                end
                                    if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                        text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                            ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y/TempMax,...
                                            ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                            'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                            'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                            'color',ModBins(Mod).Bins(q).PlotMarkers(ii).FontColor);
                                    end
                            end
                        end
                    end
                    if ControlYTick
                        yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                        yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                        ytickangle(YTickAngle)
                    else
                        ytickangle(YTickAngle)

                    end
                    if ~isempty(MatchProfileXLim)
                        xlim(MatchProfileXLim)
                    else
                        if any(~isnan(ModBins(Mod).Profile_XData))
                            xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                        end
                    end
                    if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                        %set(gca,'yticklabels',[])
                    else
                    ylim([0 1.05])
                    ylabel({'Group';'Normalized'},...
                        'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                        'horizontalalignment',YLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    end
                    ylim([0 1.05])
                    xticks(MatchProfileXTicks)
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    tempxticklabels=[];
                    for i=1:length(MatchProfileXTicks)
                        tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                    end
                    xticklabels(tempxticklabels)
                    xtickangle(XTickAngle)
                    FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                    PanelCount=PanelCount+1;
                    PlotPanelCount=PlotPanelCount+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for PlotPanelCount1=1:length(PlotPanels)
                    TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    if PlotPanelCount1<=length(Groups)
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1)+TempPos(3)/2,TempPos(2)+TempPos(4)/2,TempPos(3)/2,TempPos(4)/2])
                    else
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1)+TempPos(3)/2,TempPos(2)+TempPos(4)*0.9,TempPos(3)/2,TempPos(4)/2])
                    end
                    set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                end
                for PlotPanelCount1=1:length(PlotPanels)
                    TempPos=get(PlotPanels(PlotPanelCount1),'position');
                    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for LabelPanelCount1=1:length(LabelPanels)
                    TempPos=get(LabelPanels(LabelPanelCount1),'position');
                    set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                end
                for q1=1:length(Groups)
                    q=Groups(q1);
                    TempPos=get(PlotPanels(q1),'position');
                    GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
                        'string',ModBins(1).Bins(q).Label,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                end
                q=1;
                TempPos=get(PlotPanels(q),'position');
                GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                    'string',CalculationLabel,...
                    'verticalalignment','middle',...
                    'horizontalalignment','center',...
                    'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ProfileError
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
                else
                    Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf('Finished!\n')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                close(AZFig)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if IncludeAligned&&length(Groups)>1
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %ALIGNED Split Mod MatchX
                if ~FlipHist
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    FigName1=[FigName,' ALIGNSplitModMatchX',RemovalLabela];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf(['Making: ',FigName1,'...'])
                    AZFig=figure('name',FigName1);
                    if length(Groups)>3
                        set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                    elseif length(Groups)==1
                        MetricLabelFontSize=12;
                        MetricScaleFontSize=10;
                        set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                    else
                        set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                    end
                    set(gcf,'color','w')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    clear PlotPanels LabelPanels GroupLabels
                    NumPanels=(length(Groups)+1)*(NumMods);
                    PanelCount=1;
                    PlotPanels=[];
                    PlotPanelCount=1;
                    LabelPanels=[];
                    LabelPanelCount=1;
                    GlobalVertAdjust=0.15;
                    LineWidth=0.5;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if MatchedModMax==1
                            TempMax=0;
                            for Mod1=1:length(ModBins)
                                for q3=1:length(Groups)
                                    q2=Groups(q3);
                                    if any(~isnan(ModBins(Mod1).Bins(q2).Profile_Mean))&&length(ModBins(Mod1).Bins(q2).Profile_Mean)>=length(ModBins(Mod1).MatchProfileXIndices)
                                        if ProfileError
                                            TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                            TempMean(isinf(TempMean))=NaN;
                                            TempError=ModBins(Mod1).Bins(q2).Profile_Error(ModBins(Mod1).MatchProfileXIndices);
                                            TempError(isinf(TempError))=NaN;
                                            TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                        else
                                            TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                            TempMean(isinf(TempMean))=NaN;
                                            TempMax=max([TempMax,max(TempMean)]);
                                        end
                                    end
                                    clear TempMean TempError
                                end
                            end
                        elseif MatchedModMax==2
                            TempMax=ModBins(Mod).Profile_Max;
                        else    
                            TempMax=0;
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                    if ProfileError
                                        TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                        TempError(isinf(TempError))=NaN;
                                        TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                    else
                                        TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempMax=max([TempMax,max(TempMean)]);
                                    end
                                end
                                clear TempMean TempError
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        box off
                        axis off
                        TempPos=get(LabelPanels(LabelPanelCount),'position');
                        set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                        PanelCount=PanelCount+1;
                        LabelPanelCount=LabelPanelCount+1;
                        PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                        hold on
                        for q1=1:length(Groups)
                            q=Groups(q1);
                            if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
    %                             if ProfileError
    %                                 lineProps.col{1}=ModBins(Mod).Color;
    %                                 lineProps.style='-';
    %                                 lineProps.width=LineWidth;
    %                                 mseb(ModBins(Mod).Profile_XData,...
    %                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
    %                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
    %                                     lineProps,0);
    %                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Mean,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Error,...
    %                 %                     ['-',ModBins(Mod).Color]);
    %                             else
                                if isfield(ModBins,'Bin_Colors')
                                    TempColor=ModBins(Mod).Bin_Colors{q};
                                else
                                    TempColor=ModBins(Mod).Color;
                                end
                            
                                    plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                        ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                                        '-','color',TempColor,'linewidth',LineWidth);
    %                             end
                                if isfield(ModBins(Mod).Bins,'PlotMarkers')
                                    if isfield(ModBins,'Bin_Colors')
                                        TempColor=ModBins(Mod).Bin_Colors{q};
                                        TempColor1=ModBins(Mod).Bin_Colors{q};
                                    else
                                        TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
                                        TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
                                    end
                                    hold on
                                    for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                        if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                            plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                                [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                                'color',TempColor,...
                                                'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                        else
                                            plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                                [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                                'color',TempColor,...
                                                'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                                'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                        end
                                            if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                                text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                                    ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
                                                    ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                                    'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                                    'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                                    'color',TempColor1);
                                            end
                                    end
                                end
                            end
                            if TempMax>0
                                ylim([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                            end
                            if ControlYTick
                                yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                                yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                        ytickangle(YTickAngle)
                            else
                        ytickangle(YTickAngle)

                            end
                            if ~isempty(MatchProfileXLim)
                                xlim(MatchProfileXLim)
                            else
                                if any(~isnan(ModBins(Mod).Profile_XData))
                                    xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                                end
                            end
                            if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                                %set(gca,'yticklabels',[])
                            else
                            if FlipHist
                                ylabel(vertcat(ProfileYLabel),...
                                    'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                    'horizontalalignment',YLabelHorzAlign,...
                                    'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            else
                                ylabel(vertcat(ModBins(Mod).Label,ProfileYLabel),...
                                    'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                    'horizontalalignment',YLabelHorzAlign,...
                                    'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            end
                            end
                            xticks(MatchProfileXTicks)
                            if (Mod~=NumMods&&~FlipHist)%||(q~=Groups(1)&&FlipHist)
                                set(gca,'xticklabels',[])
                            else
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                                tempxticklabels=[];
                                for i=1:length(MatchProfileXTicks)
                                    tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                                end
                                xticklabels(tempxticklabels)
                                xtickangle(XTickAngle)
                            end
                        end
                        if ~isempty(PlotMarkers)
                            hold on
                            for ii=1:length(PlotMarkers)
                                if isempty(PlotMarkers(ii).MarkerStyle)
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth,...
                                        'markersize',PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(PlotMarkers,'Text')
                                    text(PlotMarkers(ii).Text_X,...
                                        PlotMarkers(ii).Text_Y,...
                                        PlotMarkers(ii).Text,...
                                        'FontName',PlotMarkers(ii).FontName,...
                                        'FontSize',PlotMarkers(ii).FontSize,...
                                        'color',PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                        FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                        if FlipHist
                            YScaleInfo=get(gca,'ylabel');
                            YScaleModifier=[];
                            if ischar(YScaleInfo.String)
                                YScaleModifier=YScaleInfo.String;
                            elseif iscell(YScaleInfo.String)
                                for s=1:length(YScaleInfo.String)
                                    if any(strfind(YScaleInfo.String{s},'\times'))
                                        YScaleModifier=YScaleInfo.String{s};
                                    end
                                end
                            end
                            if any(strfind(YScaleModifier,'\times'))
                                TextAddition=YScaleModifier;
                            else
                                TextAddition=[];
                            end
                            XLimits=xlim;YLimits=ylim;
                            text(XLimits(1)+(XLimits(2)-XLimits(1))*0.1,...
                                YLimits(1)+(YLimits(2)-YLimits(1))*0.1,...
                                [ModBins(Mod).Label,TextAddition],...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                        end
                        PanelCount=(Mod)*(length(Groups)+1)+1;
                        PlotPanelCount=PlotPanelCount+1;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    TempModCount=0;
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.5+(TempModCount*TempPos(4)*0.4),TempPos(3),TempPos(4)*0.5])
                        set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                        TempModCount=TempModCount+1;
                    end
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
                    for LabelPanelCount1=1:length(LabelPanels)
                        TempPos=get(LabelPanels(LabelPanelCount1),'position');
                        set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
    %                 for q1=1:length(Groups)
    %                     q=Groups(q1);
    %                     TempPos=get(PlotPanels(q1),'position');
    %                     GroupLabels(q)=annotation('textbox',[TempPos(1),0.88,0,0],...
    %                         'string',ModBins(1).Bins(q).Label,...
    %                         'verticalalignment','middle',...
    %                         'horizontalalignment','center',...
    %                         'color','k','fontname','arial','fontsize',MetricLabelFontSize);
    %                 end
                    q=1;
                    TempPos=get(PlotPanels(q),'position');
                    GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                        'string',CalculationLabel,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 if ProfileError
    %                     Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
    %                 else
                        Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
    %                 end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf('Finished!\n')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    close(AZFig)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                %ALIGNED Mod Overlay MatchX
                if NumMods>1&&~DetailMarkersOn&&~FlipHist
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    FigName1=[FigName,' ALIGNModOverMatchX',RemovalLabela];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf(['Making: ',FigName1,'...'])
                    AZFig=figure('name',FigName1);
                    if length(Groups)>3
                        set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                    elseif length(Groups)==1
                        MetricLabelFontSize=12;
                        MetricScaleFontSize=10;
                        set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                    else
                        set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                    end
                    set(gcf,'color','w')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    clear PlotPanels LabelPanels GroupLabels
                    NumPanels=(length(Groups)+1)*(NumMods);
                    PanelCount=1;
                    PlotPanels=[];
                    PlotPanelCount=1;
                    LabelPanels=[];
                    LabelPanelCount=1;
                    GlobalVertAdjust=0.15;
                    LineWidth=0.5;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                    box off
                    axis off
                    TempPos=get(LabelPanels(LabelPanelCount),'position');
                    set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                    PanelCount=PanelCount+1;
                    LabelPanelCount=LabelPanelCount+1;
                    PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                    for q1=1:length(Groups)
                        q=Groups(q1);
                        for Mod=1:NumMods
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            TempMax=0;
                            for Mod1=1:length(ModBins)
                                for q3=1:length(Groups)
                                    q2=Groups(q3);
                                    if any(~isnan(ModBins(Mod1).Bins(q2).Profile_Mean))&&length(ModBins(Mod1).Bins(q2).Profile_Mean)>=length(ModBins(Mod1).MatchProfileXIndices)
                                        if ProfileError
                                            TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                            TempMean(isinf(TempMean))=NaN;
                                            TempError=ModBins(Mod1).Bins(q2).Profile_Error(ModBins(Mod1).MatchProfileXIndices);
                                            TempError(isinf(TempError))=NaN;
                                            TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                        else
                                            TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                            TempMean(isinf(TempMean))=NaN;
                                            TempMax=max([TempMax,max(TempMean)]);
                                        end
                                    end
                                    clear TempMean TempError
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            hold on
                            if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
    %                             if ProfileError
    %                                 lineProps.col{1}=ModBins(Mod).Color;
    %                                 lineProps.style='-';
    %                                 lineProps.width=LineWidth;
    %                                 mseb(ModBins(Mod).Profile_XData,...
    %                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
    %                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
    %                                     lineProps,0);
    %                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
    %                 %                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
    %                 %                     ['-',ModBins(Mod).Color]);
    %                             else
                                    plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                        ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                                        '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
    %                             end
                                if isfield(ModBins(Mod).Bins,'PlotMarkers')
%                                     if isfield(ModBins,'Bin_Colors')
%                                         TempColor=ModBins(Mod).Bin_Colors{q};
%                                         TempColor1=ModBins(Mod).Bin_Colors{q};
%                                     else
%                                         TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
%                                         TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
%                                     end
%                                     hold on
%                                     for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
%                                         if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
%                                         else
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
%                                                 'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
%                                         end
%                                             if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
%                                                 text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
%                                                     'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
%                                                     'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
%                                                     'color',TempColor1);
%                                             end
%                                     end
                                end
                            end
                        end
                        if TempMax>0
                            ylim([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                        end
                        if ControlYTick
                            yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                            yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                        ytickangle(YTickAngle)
                        else
                        ytickangle(YTickAngle)

                        end
                        if ~isempty(MatchProfileXLim)
                            xlim(MatchProfileXLim)
                        else
                            if any(~isnan(ModBins(Mod).Profile_XData))
                                xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                            end
                        end
                        if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                            %set(gca,'yticklabels',[])
                        else
                            ylabel(ProfileYLabel,...
                                'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                'horizontalalignment',YLabelHorzAlign,...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                        end

                    end
                    if ~isempty(PlotMarkers)
                        hold on
                        for ii=1:length(PlotMarkers)
                            if isempty(PlotMarkers(ii).MarkerStyle)
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth);                    
                            else
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth,...
                                    'markersize',PlotMarkers(ii).MarkerSize);
                            end
                            if isfield(PlotMarkers,'Text')
                                text(PlotMarkers(ii).Text_X,...
                                    PlotMarkers(ii).Text_Y,...
                                    PlotMarkers(ii).Text,...
                                    'FontName',PlotMarkers(ii).FontName,...
                                    'FontSize',PlotMarkers(ii).FontSize,...
                                    'color',PlotMarkers(ii).FontColor);
                            end
                        end
                    end
                    xticks(MatchProfileXTicks)
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    tempxticklabels=[];
                    for i=1:length(MatchProfileXTicks)
                        tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                    end
                    xticklabels(tempxticklabels)
                    xtickangle(XTickAngle)
                    FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                    PanelCount=PanelCount+1;
                    PlotPanelCount=PlotPanelCount+1;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.5,TempPos(3),TempPos(4)*0.5])
                        set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                    end
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
                    for LabelPanelCount1=1:length(LabelPanels)
                        TempPos=get(LabelPanels(LabelPanelCount1),'position');
                        set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
    %                 for q1=1:length(Groups)
    %                     q=Groups(q1);
    %                     TempPos=get(PlotPanels(q1),'position');
    %                     GroupLabels(q)=annotation('textbox',[TempPos(1),0.88,0,0],...
    %                         'string',ModBins(1).Bins(q).Label,...
    %                         'verticalalignment','middle',...
    %                         'horizontalalignment','center',...
    %                         'color','k','fontname','arial','fontsize',MetricLabelFontSize);
    %                 end
                    q=1;
                    TempPos=get(PlotPanels(q),'position');
                    GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                        'string',CalculationLabel,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 if ProfileError
    %                     Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
    %                 else
                        Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
    %                 end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf('Finished!\n')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    close(AZFig)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                %ALIGNED BinNorm Split Mod MatchX
                if ~FlipHist
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    FigName1=[FigName,' ALIGNBinNormSplitModMatchX',RemovalLabela];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf(['Making: ',FigName1,'...'])
                    AZFig=figure('name',FigName1);
                    if length(Groups)>3
                        set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                    elseif length(Groups)==1
                        MetricLabelFontSize=12;
                        MetricScaleFontSize=10;
                        set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                    else
                        set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                    end
                    set(gcf,'color','w')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    clear PlotPanels LabelPanels GroupLabels
                    NumPanels=(length(Groups)+1)*(NumMods);
                    PanelCount=1;
                    PlotPanels=[];
                    PlotPanelCount=1;
                    LabelPanels=[];
                    LabelPanelCount=1;
                    GlobalVertAdjust=0.15;
                    LineWidth=0.5;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                if ProfileError
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                    TempError(isinf(TempError))=NaN;
                                    TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                else
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempMax=max([TempMax,max(TempMean)]);
                                end
                            end
                            clear TempMean TempError
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        box off
                        axis off
                        TempPos=get(LabelPanels(LabelPanelCount),'position');
                        set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                        PanelCount=PanelCount+1;
                        LabelPanelCount=LabelPanelCount+1;
                        PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                        hold on
                        for q1=1:length(Groups)
                            q=Groups(q1);
                            if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
    %                             if ProfileError
    %                                 lineProps.col{1}=ModBins(Mod).Color;
    %                                 lineProps.style='-';
    %                                 lineProps.width=LineWidth;
    %                                 mseb(ModBins(Mod).Profile_XData,...
    %                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
    %                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
    %                                     lineProps,0);
    %                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Mean,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Error,...
    %                 %                     ['-',ModBins(Mod).Color]);
    %                             else
                                if isfield(ModBins,'Bin_Colors')
                                    TempColor=ModBins(Mod).Bin_Colors{q};
                                else
                                    TempColor=ModBins(Mod).Color;
                                end
                                    plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                        ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
                                        '-','color',TempColor,'linewidth',LineWidth);
    %                             end
                                if isfield(ModBins(Mod).Bins,'PlotMarkers')
                                    if isfield(ModBins,'Bin_Colors')
                                        TempColor=ModBins(Mod).Bin_Colors{q};
                                        TempColor1=ModBins(Mod).Bin_Colors{q};
                                    else
                                        TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
                                        TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
                                    end
                                    hold on
                                    for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                        if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                            plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
                                                [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                                'color',TempColor,...
                                                'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                        else
                                            plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
                                                [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                                'color',TempColor,...
                                                'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                                'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                        end
                                            if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                                text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                                    ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
                                                    ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                                    'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                                    'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                                    'color',TempColor1);
                                            end
                                    end
                                end
                            end
                            ylim([0 1.05])
                            if ~isempty(MatchProfileXLim)
                                xlim(MatchProfileXLim)
                            else
                                if any(~isnan(ModBins(Mod).Profile_XData))
                                    xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                                end
                            end
                            if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                                %set(gca,'yticklabels',[])
                            else
                            if FlipHist
                                ylabel(vertcat({'Normalized'}),...
                                    'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                    'horizontalalignment',YLabelHorzAlign,...
                                    'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            else
                                ylabel(vertcat(ModBins(Mod).Label,{'Normalized'}),...
                                    'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                    'horizontalalignment',YLabelHorzAlign,...
                                    'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            end
                            end
                            xticks(MatchProfileXTicks)
                            if (Mod~=NumMods&&~FlipHist)%||(q~=Groups(1)&&FlipHist)
                                set(gca,'xticklabels',[])
                            else
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                                tempxticklabels=[];
                                for i=1:length(MatchProfileXTicks)
                                    tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                                end
                                xticklabels(tempxticklabels)
                                xtickangle(XTickAngle)
                            end
                        end
                        if ~isempty(PlotMarkers)
                            hold on
                            for ii=1:length(PlotMarkers)
                                if isempty(PlotMarkers(ii).MarkerStyle)
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth,...
                                        'markersize',PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(PlotMarkers,'Text')
                                    text(PlotMarkers(ii).Text_X,...
                                        PlotMarkers(ii).Text_Y,...
                                        PlotMarkers(ii).Text,...
                                        'FontName',PlotMarkers(ii).FontName,...
                                        'FontSize',PlotMarkers(ii).FontSize,...
                                        'color',PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                        ylim([0 1.05])
                        FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                        if FlipHist
                            YScaleInfo=get(gca,'ylabel');
                            YScaleModifier=[];
                            if ischar(YScaleInfo.String)
                                YScaleModifier=YScaleInfo.String;
                            elseif iscell(YScaleInfo.String)
                                for s=1:length(YScaleInfo.String)
                                    if any(strfind(YScaleInfo.String{s},'\times'))
                                        YScaleModifier=YScaleInfo.String{s};
                                    end
                                end
                            end
                            if any(strfind(YScaleModifier,'\times'))
                                TextAddition=YScaleModifier;
                            else
                                TextAddition=[];
                            end
                            XLimits=xlim;YLimits=ylim;
                            text(XLimits(1)+(XLimits(2)-XLimits(1))*0.1,...
                                YLimits(1)+(YLimits(2)-YLimits(1))*0.1,...
                                [ModBins(Mod).Label,TextAddition],...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                        end
                        PanelCount=(Mod)*(length(Groups)+1)+1;
                        PlotPanelCount=PlotPanelCount+1;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    TempModCount=0;
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.5+(TempModCount*TempPos(4)*0.4),TempPos(3),TempPos(4)*0.5])
                        set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                        TempModCount=TempModCount+1;
                    end
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
                    for LabelPanelCount1=1:length(LabelPanels)
                        TempPos=get(LabelPanels(LabelPanelCount1),'position');
                        set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
    %                 for q1=1:length(Groups)
    %                     q=Groups(q1);
    %                     TempPos=get(PlotPanels(q1),'position');
    %                     GroupLabels(q)=annotation('textbox',[TempPos(1),0.88,0,0],...
    %                         'string',ModBins(1).Bins(q).Label,...
    %                         'verticalalignment','middle',...
    %                         'horizontalalignment','center',...
    %                         'color','k','fontname','arial','fontsize',MetricLabelFontSize);
    %                 end
                    q=1;
                    TempPos=get(PlotPanels(q),'position');
                    GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                        'string',CalculationLabel,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 if ProfileError
    %                     Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
    %                 else
                        Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
    %                 end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf('Finished!\n')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    close(AZFig)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                %ALIGNED BinNorm Mod Overlay MatchX
                if NumMods>1&&~DetailMarkersOn&&~FlipHist
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    FigName1=[FigName,' ALIGNBinNormModOverMatchX',RemovalLabela];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf(['Making: ',FigName1,'...'])
                    AZFig=figure('name',FigName1);
                    if length(Groups)>3
                        set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                    elseif length(Groups)==1
                        MetricLabelFontSize=12;
                        MetricScaleFontSize=10;
                        set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                    else
                        set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                    end
                    set(gcf,'color','w')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    clear PlotPanels LabelPanels GroupLabels
                    NumPanels=(length(Groups)+1)*(NumMods);
                    PanelCount=1;
                    PlotPanels=[];
                    PlotPanelCount=1;
                    LabelPanels=[];
                    LabelPanelCount=1;
                    GlobalVertAdjust=0.15;
                    LineWidth=0.5;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                    box off
                    axis off
                    TempPos=get(LabelPanels(LabelPanelCount),'position');
                    set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                    PanelCount=PanelCount+1;
                    LabelPanelCount=LabelPanelCount+1;
                    PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                    if FlipHist
                        set(gca,'xdir','reverse')
                        view(90,90)
                    end
                    for q1=1:length(Groups)
                        q=Groups(q1);
                        for Mod=1:NumMods
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            TempMax=0;
                            for Mod1=1:length(ModBins)
                                for q3=1:length(Groups)
                                    q2=Groups(q3);
                                    if any(~isnan(ModBins(Mod1).Bins(q2).Profile_Mean))&&length(ModBins(Mod1).Bins(q2).Profile_Mean)>=length(ModBins(Mod1).MatchProfileXIndices)
                                        if ProfileError
                                            TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                            TempMean(isinf(TempMean))=NaN;
                                            TempError=ModBins(Mod1).Bins(q2).Profile_Error(ModBins(Mod1).MatchProfileXIndices);
                                            TempError(isinf(TempError))=NaN;
                                            TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                        else
                                            TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                            TempMean(isinf(TempMean))=NaN;
                                            TempMax=max([TempMax,max(TempMean)]);
                                        end
                                        clear TempMean TempError
                                    end
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            hold on
                            if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
    %                             if ProfileError
    %                                 lineProps.col{1}=ModBins(Mod).Color;
    %                                 lineProps.style='-';
    %                                 lineProps.width=LineWidth;
    %                                 mseb(ModBins(Mod).Profile_XData,...
    %                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
    %                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
    %                                     lineProps,0);
    %                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
    %                 %                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
    %                 %                     ['-',ModBins(Mod).Color]);
    %                             else
                                    plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                        ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
                                        '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
    %                             end
                                if isfield(ModBins(Mod).Bins,'PlotMarkers')
%                                     if isfield(ModBins,'Bin_Colors')
%                                         TempColor=ModBins(Mod).Bin_Colors{q};
%                                         TempColor1=ModBins(Mod).Bin_Colors{q};
%                                     else
%                                         TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
%                                         TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
%                                     end
%                                     hold on
%                                     for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
%                                         if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
%                                         else
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
%                                                 'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
%                                         end
%                                             if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
%                                                 text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
%                                                     'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
%                                                     'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
%                                                     'color',TempColor1);
%                                             end
%                                     end
                                end
                            end
                        end
                        ylim([0 1.05])
                        if ~isempty(MatchProfileXLim)
                            xlim(MatchProfileXLim)
                        else
                            if any(~isnan(ModBins(Mod).Profile_XData))
                                xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                            end
                        end
                    end
                    if ~isempty(PlotMarkers)
                        hold on
                        for ii=1:length(PlotMarkers)
                            if isempty(PlotMarkers(ii).MarkerStyle)
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth);                    
                            else
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth,...
                                    'markersize',PlotMarkers(ii).MarkerSize);
                            end
                            if isfield(PlotMarkers,'Text')
                                text(PlotMarkers(ii).Text_X,...
                                    PlotMarkers(ii).Text_Y,...
                                    PlotMarkers(ii).Text,...
                                    'FontName',PlotMarkers(ii).FontName,...
                                    'FontSize',PlotMarkers(ii).FontSize,...
                                    'color',PlotMarkers(ii).FontColor);
                            end
                        end
                    end
                    ylim([0 1.05])
                    ylabel({'Globally';'Normalized'},...
                        'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                        'horizontalalignment',YLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    xticks(MatchProfileXTicks)
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    tempxticklabels=[];
                    for i=1:length(MatchProfileXTicks)
                        tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                    end
                    xticklabels(tempxticklabels)
                    xtickangle(XTickAngle)
                    FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                    PanelCount=PanelCount+1;
                    PlotPanelCount=PlotPanelCount+1;
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.5,TempPos(3),TempPos(4)*0.5])
                        set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                    end
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
                    for LabelPanelCount1=1:length(LabelPanels)
                        TempPos=get(LabelPanels(LabelPanelCount1),'position');
                        set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
    %                 for q1=1:length(Groups)
    %                     q=Groups(q1);
    %                     TempPos=get(PlotPanels(q1),'position');
    %                     GroupLabels(q)=annotation('textbox',[TempPos(1),0.88,0,0],...
    %                         'string',ModBins(1).Bins(q).Label,...
    %                         'verticalalignment','middle',...
    %                         'horizontalalignment','center',...
    %                         'color','k','fontname','arial','fontsize',MetricLabelFontSize);
    %                 end
                    q=1;
                    TempPos=get(PlotPanels(q),'position');
                    GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                        'string',CalculationLabel,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 if ProfileError
    %                     Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
    %                 else
                        Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
    %                 end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf('Finished!\n')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    close(AZFig)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                %ALIGNED GroupNorm Mod Overlay MatchX
                if NumMods>1&&~DetailMarkersOn&&~FlipHist
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    FigName1=[FigName,' ALIGNGroupNormModOverMatchX',RemovalLabela];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf(['Making: ',FigName1,'...'])
                    AZFig=figure('name',FigName1);
                    if length(Groups)>3
                        set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                    elseif length(Groups)==1
                        MetricLabelFontSize=12;
                        MetricScaleFontSize=10;
                        set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                    else
                        set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                    end
                    set(gcf,'color','w')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    clear PlotPanels LabelPanels GroupLabels
                    NumPanels=(length(Groups)+1)*(NumMods);
                    PanelCount=1;
                    PlotPanels=[];
                    PlotPanelCount=1;
                    LabelPanels=[];
                    LabelPanelCount=1;
                    GlobalVertAdjust=0.15;
                    LineWidth=0.5;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                    box off
                    axis off
                    TempPos=get(LabelPanels(LabelPanelCount),'position');
                    set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                    PanelCount=PanelCount+1;
                    LabelPanelCount=LabelPanelCount+1;
                    PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                if ProfileError
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                    TempError(isinf(TempError))=NaN;
                                    TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                else
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempMax=max([TempMax,max(TempMean)]);
                                end
                            end
                            clear TempMean TempError
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        for q1=1:length(Groups)
                            q=Groups(q1);
                            hold on
                            if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
    %                             if ProfileError
    %                                 lineProps.col{1}=ModBins(Mod).Color;
    %                                 lineProps.style='-';
    %                                 lineProps.width=LineWidth;
    %                                 mseb(ModBins(Mod).Profile_XData,...
    %                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
    %                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
    %                                     lineProps,0);
    %                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
    %                 %                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
    %                 %                     ['-',ModBins(Mod).Color]);
    %                             else
                                    plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                        ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/TempMax,...
                                        '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
    %                             end
                                if isfield(ModBins(Mod).Bins,'PlotMarkers')
%                                     if isfield(ModBins,'Bin_Colors')
%                                         TempColor=ModBins(Mod).Bin_Colors{q};
%                                         TempColor1=ModBins(Mod).Bin_Colors{q};
%                                     else
%                                         TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
%                                         TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
%                                     end
%                                     hold on
%                                     for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
%                                         if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
%                                         else
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
%                                                 'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
%                                         end
%                                             if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
%                                                 text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
%                                                     'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
%                                                     'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
%                                                     'color',TempColor1);
%                                             end
%                                     end
                                end
                            end
                        end
                        if ~isempty(PlotMarkers)
                            hold on
                            for ii=1:length(PlotMarkers)
                                if isempty(PlotMarkers(ii).MarkerStyle)
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth,...
                                        'markersize',PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(PlotMarkers,'Text')
                                    text(PlotMarkers(ii).Text_X,...
                                        PlotMarkers(ii).Text_Y,...
                                        PlotMarkers(ii).Text,...
                                        'FontName',PlotMarkers(ii).FontName,...
                                        'FontSize',PlotMarkers(ii).FontSize,...
                                        'color',PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                        ylim([0 1.05])
                        if ~isempty(MatchProfileXLim)
                            xlim(MatchProfileXLim)
                        else
                            if any(~isnan(ModBins(Mod).Profile_XData))
                                xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                            end
                        end

                    end
                    ylabel({'Group';'Normalized'},...
                        'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                        'horizontalalignment',YLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    xticks(MatchProfileXTicks)
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    tempxticklabels=[];
                    for i=1:length(MatchProfileXTicks)
                        tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                    end
                    xticklabels(tempxticklabels)
                    xtickangle(XTickAngle)
                    FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                    PanelCount=PanelCount+1;
                    PlotPanelCount=PlotPanelCount+1;
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.5,TempPos(3),TempPos(4)*0.5])
                        set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                    end
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
                    for LabelPanelCount1=1:length(LabelPanels)
                        TempPos=get(LabelPanels(LabelPanelCount1),'position');
                        set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
    %                 for q1=1:length(Groups)
    %                     q=Groups(q1);
    %                     TempPos=get(PlotPanels(q1),'position');
    %                     GroupLabels(q)=annotation('textbox',[TempPos(1),0.88,0,0],...
    %                         'string',ModBins(1).Bins(q).Label,...
    %                         'verticalalignment','middle',...
    %                         'horizontalalignment','center',...
    %                         'color','k','fontname','arial','fontsize',MetricLabelFontSize);
    %                 end
                    q=1;
                    TempPos=get(PlotPanels(q),'position');
                    GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                        'string',CalculationLabel,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 if ProfileError
    %                     Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
    %                 else
                        Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
    %                 end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf('Finished!\n')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    close(AZFig)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %ALIGNED Split Mod MatchX Centered
                if CenteredPlot
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    FigName1=[FigName,' ALIGNSplitModMatchXCentered',RemovalLabela];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf(['Making: ',FigName1,'...'])
                    AZFig=figure('name',FigName1);
                    if length(Groups)>3
                        set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                    elseif length(Groups)==1
                        MetricLabelFontSize=12;
                        MetricScaleFontSize=10;
                        set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                    else
                        set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                    end
                    set(gcf,'color','w')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    clear PlotPanels LabelPanels GroupLabels
                    NumPanels=(length(Groups)+1)*(NumMods);
                    PanelCount=1;
                    PlotPanels=[];
                    PlotPanelCount=1;
                    LabelPanels=[];
                    LabelPanelCount=1;
                    GlobalVertAdjust=0.15;
                    LineWidth=0.5;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if MatchedModMax==1
                            TempMax=0;
                            for Mod1=1:length(ModBins)
                                for q3=1:length(Groups)
                                    q2=Groups(q3);
                                    if any(~isnan(ModBins(Mod1).Bins(q2).Profile_Mean))&&length(ModBins(Mod1).Bins(q2).Profile_Mean)>=length(ModBins(Mod1).MatchProfileXIndices)
                                        if ProfileError
                                            TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                            TempMean(isinf(TempMean))=NaN;
                                            TempError=ModBins(Mod1).Bins(q2).Profile_Error(ModBins(Mod1).MatchProfileXIndices);
                                            TempError(isinf(TempError))=NaN;
                                            TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                        else
                                            TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                            TempMean(isinf(TempMean))=NaN;
                                            TempMax=max([TempMax,max(TempMean)]);
                                        end
                                    end
                                    clear TempMean TempError
                                end
                            end
                        elseif MatchedModMax==2
                            TempMax=ModBins(Mod).Profile_Max;
                        else    
                            TempMax=0;
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                    if ProfileError
                                        TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                        TempError(isinf(TempError))=NaN;
                                        TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                    else
                                        TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                        TempMean(isinf(TempMean))=NaN;
                                        TempMax=max([TempMax,max(TempMean)]);
                                    end
                                end
                                clear TempMean TempError
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        LabelPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        box off
                        axis off
                        TempPos=get(LabelPanels(LabelPanelCount),'position');
                        set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                        PanelCount=PanelCount+1;
                        LabelPanelCount=LabelPanelCount+1;
                        PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                        hold on
                        for q1=1:length(Groups)
                            q=Groups(q1);
                            if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
    %                             if ProfileError
    %                                 lineProps.col{1}=ModBins(Mod).Color;
    %                                 lineProps.style='-';
    %                                 lineProps.width=LineWidth;
    %                                 mseb(ModBins(Mod).Profile_XData,...
    %                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
    %                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
    %                                     lineProps,0);
    %                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Mean,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Error,...
    %                 %                     ['-',ModBins(Mod).Color]);
    %                             else
                                if isfield(ModBins,'Bin_Colors')
                                    TempColor=ModBins(Mod).Bin_Colors{q};
                                else
                                    TempColor=ModBins(Mod).Color;
                                end
                                    plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                        ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                                        '-','color',TempColor,'linewidth',LineWidth);
    %                             end
                                if isfield(ModBins(Mod).Bins,'PlotMarkers')
                                    if isfield(ModBins,'Bin_Colors')
                                        TempColor=ModBins(Mod).Bin_Colors{q};
                                        TempColor1=ModBins(Mod).Bin_Colors{q};
                                    else
                                        TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
                                        TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
                                    end
                                    hold on
                                    for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                        if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                            plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                                [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                                'color',TempColor,...
                                                'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                        else
                                            plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
                                                [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                                'color',TempColor,...
                                                'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                                'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                        end
                                            if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                                text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                                    ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
                                                    ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                                    'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                                    'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                                    'color',TempColor1);
                                            end
                                    end
                                end
                            end
                            if TempMax>0
                                ylim([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                            end
                            if ControlYTick
                                yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                                yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                        ytickangle(YTickAngle)
                            else
                        ytickangle(YTickAngle)

                            end
                            if ~isempty(MatchProfileXLim)
                                xlim(MatchProfileXLim)
                            else
                                if any(~isnan(ModBins(Mod).Profile_XData))
                                    xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                                end
                            end
                            if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                                %set(gca,'yticklabels',[])
                            else
                            if FlipHist
                                ylabel(vertcat(ProfileYLabel),...
                                    'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                    'horizontalalignment',YLabelHorzAlign,...
                                    'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            else
                                ylabel(vertcat(ModBins(Mod).Label,ProfileYLabel),...
                                    'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                    'horizontalalignment',YLabelHorzAlign,...
                                    'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                            end
                            end
                            xticks(MatchProfileXTicks)
                            if (Mod~=NumMods&&~FlipHist)%||(q~=Groups(1)&&FlipHist)
                                set(gca,'xticklabels',[])
                            else
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                                tempxticklabels=[];
                                for i=1:length(MatchProfileXTicks)
                                    tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                                end
                                xticklabels(tempxticklabels)
                                xtickangle(XTickAngle)
                            end
                        end
                        if ~isempty(PlotMarkers)
                            hold on
                            for ii=1:length(PlotMarkers)
                                if isempty(PlotMarkers(ii).MarkerStyle)
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth,...
                                        'markersize',PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(PlotMarkers,'Text')
                                    text(PlotMarkers(ii).Text_X,...
                                        PlotMarkers(ii).Text_Y,...
                                        PlotMarkers(ii).Text,...
                                        'FontName',PlotMarkers(ii).FontName,...
                                        'FontSize',PlotMarkers(ii).FontSize,...
                                        'color',PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                        FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                        if FlipHist
                            YScaleInfo=get(gca,'ylabel');
                            YScaleModifier=[];
                            if ischar(YScaleInfo.String)
                                YScaleModifier=YScaleInfo.String;
                            elseif iscell(YScaleInfo.String)
                                for s=1:length(YScaleInfo.String)
                                    if any(strfind(YScaleInfo.String{s},'\times'))
                                        YScaleModifier=YScaleInfo.String{s};
                                    end
                                end
                            end
                            if any(strfind(YScaleModifier,'\times'))
                                TextAddition=YScaleModifier;
                            else
                                TextAddition=[];
                            end
                            XLimits=xlim;YLimits=ylim;
                            text(XLimits(1)+(XLimits(2)-XLimits(1))*0.1,...
                                YLimits(1)+(YLimits(2)-YLimits(1))*0.1,...
                                [ModBins(Mod).Label,TextAddition],...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                        end
                        PanelCount=(Mod)*(length(Groups)+1)+1;
                        PlotPanelCount=PlotPanelCount+1;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    TempModCount=0;
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1)+TempPos(3)/2,TempPos(2)+TempPos(4)*0.5+(TempModCount*TempPos(4)*0.4),TempPos(3)/2,TempPos(4)*0.5])
                        set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                        TempModCount=TempModCount+1;
                    end
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
                    for LabelPanelCount1=1:length(LabelPanels)
                        TempPos=get(LabelPanels(LabelPanelCount1),'position');
                        set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
    %                 for q1=1:length(Groups)
    %                     q=Groups(q1);
    %                     TempPos=get(PlotPanels(q1),'position');
    %                     GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
    %                         'string',ModBins(1).Bins(q).Label,...
    %                         'verticalalignment','middle',...
    %                         'horizontalalignment','center',...
    %                         'color','k','fontname','arial','fontsize',MetricLabelFontSize);
    %                 end
                    q=1;
                    TempPos=get(PlotPanels(q),'position');
                    GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                        'string',CalculationLabel,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 if ProfileError
    %                     Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
    %                 else
                        Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
    %                 end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf('Finished!\n')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    close(AZFig)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                %ALIGNED Mod Overlay MatchX Centered
                if NumMods>1&&CenteredPlot&&~DetailMarkersOn
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    FigName1=[FigName,' ALIGNModOverMatchXCentered',RemovalLabela];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf(['Making: ',FigName1,'...'])
                    AZFig=figure('name',FigName1);
                    if length(Groups)>3
                        set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                    elseif length(Groups)==1
                        MetricLabelFontSize=12;
                        MetricScaleFontSize=10;
                        set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                    else
                        set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                    end
                    set(gcf,'color','w')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    clear PlotPanels LabelPanels GroupLabels
                    NumPanels=(length(Groups)+1)*(NumMods);
                    PanelCount=1;
                    PlotPanels=[];
                    PlotPanelCount=1;
                    LabelPanels=[];
                    LabelPanelCount=1;
                    GlobalVertAdjust=0.15;
                    LineWidth=0.5;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                    box off
                    axis off
                    TempPos=get(LabelPanels(LabelPanelCount),'position');
                    set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                    PanelCount=PanelCount+1;
                    LabelPanelCount=LabelPanelCount+1;
                    PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                    for q1=1:length(Groups)
                        q=Groups(q1);
                        for Mod=1:NumMods
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            TempMax=0;
                            for Mod1=1:length(ModBins)
                                for q3=1:length(Groups)
                                    q2=Groups(q3);
                                    if any(~isnan(ModBins(Mod1).Bins(q2).Profile_Mean))&&length(ModBins(Mod1).Bins(q2).Profile_Mean)>=length(ModBins(Mod1).MatchProfileXIndices)
                                        if ProfileError
                                            TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                            TempMean(isinf(TempMean))=NaN;
                                            TempError=ModBins(Mod1).Bins(q2).Profile_Error(ModBins(Mod1).MatchProfileXIndices);
                                            TempError(isinf(TempError))=NaN;
                                            TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                        else
                                            TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                            TempMean(isinf(TempMean))=NaN;
                                            TempMax=max([TempMax,max(TempMean)]);
                                        end
                                end
                                    clear TempMean TempError
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            hold on
                            if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
    %                             if ProfileError
    %                                 lineProps.col{1}=ModBins(Mod).Color;
    %                                 lineProps.style='-';
    %                                 lineProps.width=LineWidth;
    %                                 mseb(ModBins(Mod).Profile_XData,...
    %                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
    %                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
    %                                     lineProps,0);
    %                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
    %                 %                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
    %                 %                     ['-',ModBins(Mod).Color]);
    %                             else
                                    plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                        ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
                                        '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
    %                             end
                                if isfield(ModBins(Mod).Bins,'PlotMarkers')
%                                     if isfield(ModBins,'Bin_Colors')
%                                         TempColor=ModBins(Mod).Bin_Colors{q};
%                                         TempColor1=ModBins(Mod).Bin_Colors{q};
%                                     else
%                                         TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
%                                         TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
%                                     end
%                                     hold on
%                                     for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
%                                         if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
%                                         else
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
%                                                 'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
%                                         end
%                                             if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
%                                                 text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
%                                                     'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
%                                                     'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
%                                                     'color',TempColor1);
%                                             end
%                                     end
                                end
                            end
                        end
                        if TempMax>0
                            ylim([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                        end
                        if ControlYTick
                            yticks([ModBins(Mod).Min,ceil(TempMax*YScalar)/YScalar])
                            yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempMax*YScalar)/YScalar)})
                        ytickangle(YTickAngle)
                        else
                        ytickangle(YTickAngle)

                        end
                        if ~isempty(MatchProfileXLim)
                            xlim(MatchProfileXLim)
                        else
                            if any(~isnan(ModBins(Mod).Profile_XData))
                                xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                            end
                        end
                        if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                            %set(gca,'yticklabels',[])
                        else
                            ylabel(ProfileYLabel,...
                                'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                'horizontalalignment',YLabelHorzAlign,...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                        end

                    end
                    if ~isempty(PlotMarkers)
                        hold on
                        for ii=1:length(PlotMarkers)
                            if isempty(PlotMarkers(ii).MarkerStyle)
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth);                    
                            else
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth,...
                                    'markersize',PlotMarkers(ii).MarkerSize);
                            end
                            if isfield(PlotMarkers,'Text')
                                text(PlotMarkers(ii).Text_X,...
                                    PlotMarkers(ii).Text_Y,...
                                    PlotMarkers(ii).Text,...
                                    'FontName',PlotMarkers(ii).FontName,...
                                    'FontSize',PlotMarkers(ii).FontSize,...
                                    'color',PlotMarkers(ii).FontColor);
                            end
                        end
                    end
                    xticks(MatchProfileXTicks)
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    tempxticklabels=[];
                    for i=1:length(MatchProfileXTicks)
                        tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                    end
                    xticklabels(tempxticklabels)
                    xtickangle(XTickAngle)
                    FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                    PanelCount=PanelCount+1;
                    PlotPanelCount=PlotPanelCount+1;
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1)+TempPos(3)/2,TempPos(2)+TempPos(4)*0.5,TempPos(3)/2,TempPos(4)*0.5])
                        set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                    end
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
                    for LabelPanelCount1=1:length(LabelPanels)
                        TempPos=get(LabelPanels(LabelPanelCount1),'position');
                        set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
    %                 for q1=1:length(Groups)
    %                     q=Groups(q1);
    %                     TempPos=get(PlotPanels(q1),'position');
    %                     GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
    %                         'string',ModBins(1).Bins(q).Label,...
    %                         'verticalalignment','middle',...
    %                         'horizontalalignment','center',...
    %                         'color','k','fontname','arial','fontsize',MetricLabelFontSize);
    %                 end
                    q=1;
                    TempPos=get(PlotPanels(q),'position');
                    GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                        'string',CalculationLabel,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 if ProfileError
    %                     Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
    %                 else
                        Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
    %                 end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf('Finished!\n')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    close(AZFig)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                %ALIGNED BinNorm Split Mod MatchX Centered
                if CenteredPlot
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    FigName1=[FigName,' ALIGNBinNormSplitModMatchXCentered',RemovalLabela];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf(['Making: ',FigName1,'...'])
                    AZFig=figure('name',FigName1);
                    if length(Groups)>3
                        set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                    elseif length(Groups)==1
                        MetricLabelFontSize=12;
                        MetricScaleFontSize=10;
                        set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                    else
                        set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                    end
                    set(gcf,'color','w')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    clear PlotPanels LabelPanels GroupLabels TempPos
                    NumPanels=(length(Groups)+1)*(NumMods);
                    PanelCount=1;
                    PlotPanels=[];
                    PlotPanelCount=1;
                    LabelPanels=[];
                    LabelPanelCount=1;
                    GlobalVertAdjust=0.15;
                    LineWidth=0.5;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                if ProfileError
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                    TempError(isinf(TempError))=NaN;
                                    TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                else
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempMax=max([TempMax,max(TempMean)]);
                                end
                            end
                            clear TempMean TempError
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        box off
                        axis off
                        TempPos=get(LabelPanels(LabelPanelCount),'position');
                        set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                        PanelCount=PanelCount+1;
                        LabelPanelCount=LabelPanelCount+1;
                        PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                        hold on
                        for q1=1:length(Groups)
                            q=Groups(q1);
                            if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
    %                             if ProfileError
    %                                 lineProps.col{1}=ModBins(Mod).Color;
    %                                 lineProps.style='-';
    %                                 lineProps.width=LineWidth;
    %                                 mseb(ModBins(Mod).Profile_XData,...
    %                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
    %                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
    %                                     lineProps,0);
    %                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Mean,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Error,...
    %                 %                     ['-',ModBins(Mod).Color]);
    %                             else
                                if isfield(ModBins,'Bin_Colors')
                                    TempColor=ModBins(Mod).Bin_Colors{q};
                                else
                                    TempColor=ModBins(Mod).Color;
                                end
                                    plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                        ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
                                        '-','color',TempColor,'linewidth',LineWidth);
    %                             end
                                if isfield(ModBins(Mod).Bins,'PlotMarkers')
                                    if isfield(ModBins,'Bin_Colors')
                                        TempColor=ModBins(Mod).Bin_Colors{q};
                                        TempColor1=ModBins(Mod).Bin_Colors{q};
                                    else
                                        TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
                                        TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
                                    end
                                    hold on
                                    for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
                                        if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
                                            plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
                                                [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                                'color',TempColor,...
                                                'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
                                        else
                                            plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
                                                [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
                                                'color',TempColor,...
                                                'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
                                                'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
                                        end
                                            if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
                                                text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
                                                    ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
                                                    ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
                                                    'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
                                                    'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
                                                    'color',TempColor1);
                                            end
                                    end
                                end
                            end
                            ylim([0 1.05])
                            if ~isempty(MatchProfileXLim)
                                xlim(MatchProfileXLim)
                            else
                                if any(~isnan(ModBins(Mod).Profile_XData))
                                    xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                                end
                            end
                            if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
                                %set(gca,'yticklabels',[])
                            else
                                if FlipHist
                                    ylabel(vertcat({'Normalized'}),...
                                        'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                        'horizontalalignment',YLabelHorzAlign,...
                                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                                else
                                    ylabel(vertcat(ModBins(Mod).Label,{'Normalized'}),...
                                        'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                                        'horizontalalignment',YLabelHorzAlign,...
                                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                                end
                            end
                            xticks(MatchProfileXTicks)
                            if (Mod~=NumMods&&~FlipHist)%||(q~=Groups(1)&&FlipHist)
                                set(gca,'xticklabels',[])
                            else
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                                tempxticklabels=[];
                                for i=1:length(MatchProfileXTicks)
                                    tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                                end
                                xticklabels(tempxticklabels)
                                xtickangle(XTickAngle)
                            end
                        end
                        if ~isempty(PlotMarkers)
                            hold on
                            for ii=1:length(PlotMarkers)
                                if isempty(PlotMarkers(ii).MarkerStyle)
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth,...
                                        'markersize',PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(PlotMarkers,'Text')
                                    text(PlotMarkers(ii).Text_X,...
                                        PlotMarkers(ii).Text_Y,...
                                        PlotMarkers(ii).Text,...
                                        'FontName',PlotMarkers(ii).FontName,...
                                        'FontSize',PlotMarkers(ii).FontSize,...
                                        'color',PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                        ylim([0 1.05])
                        FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                        if FlipHist
                            YScaleInfo=get(gca,'ylabel');
                            YScaleModifier=[];
                            if ischar(YScaleInfo.String)
                                YScaleModifier=YScaleInfo.String;
                            elseif iscell(YScaleInfo.String)
                                for s=1:length(YScaleInfo.String)
                                    if any(strfind(YScaleInfo.String{s},'\times'))
                                        YScaleModifier=YScaleInfo.String{s};
                                    end
                                end
                            end
                            if any(strfind(YScaleModifier,'\times'))
                                TextAddition=YScaleModifier;
                            else
                                TextAddition=[];
                            end
                            XLimits=xlim;YLimits=ylim;
                            text(XLimits(1)+(XLimits(2)-XLimits(1))*0.1,...
                                YLimits(1)+(YLimits(2)-YLimits(1))*0.1,...
                                [ModBins(Mod).Label,TextAddition],...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                        end
                        PanelCount=(Mod)*(length(Groups)+1)+1;
                        PlotPanelCount=PlotPanelCount+1;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    TempModCount=0;
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1)+TempPos(3)/2,TempPos(2)+TempPos(4)*0.5+(TempModCount*TempPos(4)*0.4),TempPos(3)/2,TempPos(4)*0.5])
                        set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                        TempModCount=TempModCount+1;
                    end
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
                    for LabelPanelCount1=1:length(LabelPanels)
                        TempPos=get(LabelPanels(LabelPanelCount1),'position');
                        set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
    %                 for q1=1:length(Groups)
    %                     q=Groups(q1);
    %                     TempPos=get(PlotPanels(q1),'position');
    %                     GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
    %                         'string',ModBins(1).Bins(q).Label,...
    %                         'verticalalignment','middle',...
    %                         'horizontalalignment','center',...
    %                         'color','k','fontname','arial','fontsize',MetricLabelFontSize);
    %                 end
                    q=1;
                    TempPos=get(PlotPanels(q),'position');
                    GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                        'string',CalculationLabel,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 if ProfileError
    %                     Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
    %                 else
                        Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
    %                 end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf('Finished!\n')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    close(AZFig)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                %ALIGNED BinNorm Mod Overlay MatchX Centered
                if NumMods>1&&CenteredPlot&&~DetailMarkersOn
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    FigName1=[FigName,' ALIGNBinNormModOverMatchXCentered',RemovalLabela];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf(['Making: ',FigName1,'...'])
                    AZFig=figure('name',FigName1);
                    if length(Groups)>3
                        set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                    elseif length(Groups)==1
                        MetricLabelFontSize=12;
                        MetricScaleFontSize=10;
                        set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                    else
                        set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                    end
                    set(gcf,'color','w')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    clear PlotPanels LabelPanels GroupLabels
                    NumPanels=(length(Groups)+1)*(NumMods);
                    PanelCount=1;
                    PlotPanels=[];
                    PlotPanelCount=1;
                    LabelPanels=[];
                    LabelPanelCount=1;
                    GlobalVertAdjust=0.15;
                    LineWidth=0.5;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                    box off
                    axis off
                    TempPos=get(LabelPanels(LabelPanelCount),'position');
                    set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                    PanelCount=PanelCount+1;
                    LabelPanelCount=LabelPanelCount+1;
                    PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                    for q1=1:length(Groups)
                        q=Groups(q1);
                        for Mod=1:NumMods
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            TempMax=0;
                            for Mod1=1:length(ModBins)
                                for q3=1:length(Groups)
                                    q2=Groups(q3);
                                    if any(~isnan(ModBins(Mod1).Bins(q2).Profile_Mean))&&length(ModBins(Mod1).Bins(q2).Profile_Mean)>=length(ModBins(Mod1).MatchProfileXIndices)
                                        if ProfileError
                                            TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                            TempMean(isinf(TempMean))=NaN;
                                            TempError=ModBins(Mod1).Bins(q2).Profile_Error(ModBins(Mod1).MatchProfileXIndices);
                                            TempError(isinf(TempError))=NaN;
                                            TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                        else
                                            TempMean=ModBins(Mod1).Bins(q2).Profile_Mean(ModBins(Mod1).MatchProfileXIndices);
                                            TempMean(isinf(TempMean))=NaN;
                                            TempMax=max([TempMax,max(TempMean)]);
                                        end
                                    end
                                    clear TempMean TempError
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            hold on
                            if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
    %                             if ProfileError
    %                                 lineProps.col{1}=ModBins(Mod).Color;
    %                                 lineProps.style='-';
    %                                 lineProps.width=LineWidth;
    %                                 mseb(ModBins(Mod).Profile_XData,...
    %                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
    %                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
    %                                     lineProps,0);
    %                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
    %                 %                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
    %                 %                     ['-',ModBins(Mod).Color]);
    %                             else
                                    plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                        ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
                                        '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
    %                             end
                                if isfield(ModBins(Mod).Bins,'PlotMarkers')
%                                     if isfield(ModBins,'Bin_Colors')
%                                         TempColor=ModBins(Mod).Bin_Colors{q};
%                                         TempColor1=ModBins(Mod).Bin_Colors{q};
%                                     else
%                                         TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
%                                         TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
%                                     end
%                                     hold on
%                                     for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
%                                         if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
%                                         else
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
%                                                 'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
%                                         end
%                                             if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
%                                                 text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
%                                                     'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
%                                                     'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
%                                                     'color',TempColor1);
%                                             end
%                                     end
                                end
                            end
                        end
                        if ~isempty(MatchProfileXLim)
                            xlim(MatchProfileXLim)
                        else
                            if any(~isnan(ModBins(Mod).Profile_XData))
                                xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                            end
                        end
                    end
                    if ~isempty(PlotMarkers)
                        hold on
                        for ii=1:length(PlotMarkers)
                            if isempty(PlotMarkers(ii).MarkerStyle)
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth);                    
                            else
                                plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                    [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                    'color',PlotMarkers(ii).Color,...
                                    'linewidth',PlotMarkers(ii).LineWidth,...
                                    'markersize',PlotMarkers(ii).MarkerSize);
                            end
                            if isfield(PlotMarkers,'Text')
                                text(PlotMarkers(ii).Text_X,...
                                    PlotMarkers(ii).Text_Y,...
                                    PlotMarkers(ii).Text,...
                                    'FontName',PlotMarkers(ii).FontName,...
                                    'FontSize',PlotMarkers(ii).FontSize,...
                                    'color',PlotMarkers(ii).FontColor);
                            end
                        end
                    end
                    ylim([0 1.05])
                     ylabel({'Globally';'Normalized'},...
                        'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                        'horizontalalignment',YLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    xticks(MatchProfileXTicks)
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    tempxticklabels=[];
                    for i=1:length(MatchProfileXTicks)
                        tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                    end
                    xticklabels(tempxticklabels)
                    xtickangle(XTickAngle)
                    FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                    PanelCount=PanelCount+1;
                    PlotPanelCount=PlotPanelCount+1;
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1)+TempPos(3)/2,TempPos(2)+TempPos(4)*0.5,TempPos(3)/2,TempPos(4)*0.5])
                        set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                    end
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
                    for LabelPanelCount1=1:length(LabelPanels)
                        TempPos=get(LabelPanels(LabelPanelCount1),'position');
                        set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
    %                 for q1=1:length(Groups)
    %                     q=Groups(q1);
    %                     TempPos=get(PlotPanels(q1),'position');
    %                     GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
    %                         'string',ModBins(1).Bins(q).Label,...
    %                         'verticalalignment','middle',...
    %                         'horizontalalignment','center',...
    %                         'color','k','fontname','arial','fontsize',MetricLabelFontSize);
    %                 end
                    q=1;
                    TempPos=get(PlotPanels(q),'position');
                    GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                        'string',CalculationLabel,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 if ProfileError
    %                     Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
    %                 else
                        Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
    %                 end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf('Finished!\n')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    close(AZFig)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                %ALIGNED GroupNorm Mod Overlay MatchX Centered
                if NumMods>1&&CenteredPlot&&~DetailMarkersOn
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    FigName1=[FigName,' ALIGNGroupNormModOverMatchXCentered',RemovalLabela];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf(['Making: ',FigName1,'...'])
                    AZFig=figure('name',FigName1);
                    if length(Groups)>3
                        set(gcf,'position',[50 0 (length(Groups))*300 NumModsSubPlot*300])
                    elseif length(Groups)==1
                        MetricLabelFontSize=12;
                        MetricScaleFontSize=10;
                        set(gcf,'position',[50 0 400 NumModsSubPlot*300-100])
                    else
                        set(gcf,'position',[50 0 (length(Groups))*300+100 NumModsSubPlot*300])
                    end
                    set(gcf,'color','w')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    clear PlotPanels LabelPanels GroupLabels
                    NumPanels=(length(Groups)+1)*(NumMods);
                    PanelCount=1;
                    PlotPanels=[];
                    PlotPanelCount=1;
                    LabelPanels=[];
                    LabelPanelCount=1;
                    GlobalVertAdjust=0.15;
                    LineWidth=0.5;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    LabelPanels(LabelPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                    box off
                    axis off
                    TempPos=get(LabelPanels(LabelPanelCount),'position');
                    set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                    PanelCount=PanelCount+1;
                    LabelPanelCount=LabelPanelCount+1;
                    PlotPanels(PlotPanelCount)=subtightplot(NumModsSubPlot,(length(Groups))+1,PanelCount);
                        if FlipHist
                            set(gca,'xdir','reverse')
                            view(90,90)
                        end
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempMax=0;
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            if any(~isnan(ModBins(Mod).Bins(q2).Profile_Mean))&&length(ModBins(Mod).Bins(q2).Profile_Mean)>=length(ModBins(Mod).MatchProfileXIndices)
                                if ProfileError
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempError=ModBins(Mod).Bins(q2).Profile_Error(ModBins(Mod).MatchProfileXIndices);
                                    TempError(isinf(TempError))=NaN;
                                    TempMax=max([TempMax,max(TempMean)+max(TempError)]);
                                else
                                    TempMean=ModBins(Mod).Bins(q2).Profile_Mean(ModBins(Mod).MatchProfileXIndices);
                                    TempMean(isinf(TempMean))=NaN;
                                    TempMax=max([TempMax,max(TempMean)]);
                                end
                            end
                            clear TempMean TempError
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        for q1=1:length(Groups)
                            q=Groups(q1);
                            hold on
                            if any(~isnan(ModBins(Mod).Bins(q).Profile_Mean))
    %                             if ProfileError
    %                                 lineProps.col{1}=ModBins(Mod).Color;
    %                                 lineProps.style='-';
    %                                 lineProps.width=LineWidth;
    %                                 mseb(ModBins(Mod).Profile_XData,...
    %                                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
    %                                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices)/max(ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)),...
    %                                     lineProps,0);
    %                 %                 shadedErrorBar(ModBins(Mod).Profile_XData,...
    %                 %                     ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices),...
    %                 %                     ModBins(Mod).Bins(q).Profile_Error(ModBins(Mod).MatchProfileXIndices),...
    %                 %                     ['-',ModBins(Mod).Color]);
    %                             else
                                    plot(ModBins(Mod).Profile_XData(ModBins(Mod).MatchProfileXIndices),...
                                        ModBins(Mod).Bins(q).Profile_Mean(ModBins(Mod).MatchProfileXIndices)/TempMax,...
                                        '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
    %                             end
                                if isfield(ModBins(Mod).Bins,'PlotMarkers')
%                                     if isfield(ModBins,'Bin_Colors')
%                                         TempColor=ModBins(Mod).Bin_Colors{q};
%                                         TempColor1=ModBins(Mod).Bin_Colors{q};
%                                     else
%                                         TempColor=ModBins(Mod).Bins(q).PlotMarkers(1).Color;
%                                         TempColor1=ModBins(Mod).Bins(q).PlotMarkers(1).FontColor;
%                                     end
%                                     hold on
%                                     for ii=1:length(ModBins(Mod).Bins(q).PlotMarkers)
%                                         if isempty(ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle)
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth);                    
%                                         else
%                                             plot(ModBins(Mod).Bins(q).PlotMarkers(ii).XData,ModBins(Mod).Bins(q).PlotMarkers(ii).YData,...
%                                                 [ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerStyle,ModBins(Mod).Bins(q).PlotMarkers(ii).LineStyle],...
%                                                 'color',TempColor,...
%                                                 'linewidth',ModBins(Mod).Bins(q).PlotMarkers(ii).LineWidth,...
%                                                 'markersize',ModBins(Mod).Bins(q).PlotMarkers(ii).MarkerSize);
%                                         end
%                                             if isfield(ModBins(Mod).Bins(q).PlotMarkers,'Text')
%                                                 text(ModBins(Mod).Bins(q).PlotMarkers(ii).Text_X,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text_Y,...
%                                                     ModBins(Mod).Bins(q).PlotMarkers(ii).Text,...
%                                                     'FontName',ModBins(Mod).Bins(q).PlotMarkers(ii).FontName,...
%                                                     'FontSize',ModBins(Mod).Bins(q).PlotMarkers(ii).FontSize,...
%                                                     'color',TempColor1);
%                                             end
%                                     end
                                end
                            end
                        end
                        if ~isempty(PlotMarkers)
                            hold on
                            for ii=1:length(PlotMarkers)
                                if isempty(PlotMarkers(ii).MarkerStyle)
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth);                    
                                else
                                    plot(PlotMarkers(ii).XData,PlotMarkers(ii).YData,...
                                        [PlotMarkers(ii).MarkerStyle,PlotMarkers(ii).LineStyle],...
                                        'color',PlotMarkers(ii).Color,...
                                        'linewidth',PlotMarkers(ii).LineWidth,...
                                        'markersize',PlotMarkers(ii).MarkerSize);
                                end
                                if isfield(PlotMarkers,'Text')
                                    text(PlotMarkers(ii).Text_X,...
                                        PlotMarkers(ii).Text_Y,...
                                        PlotMarkers(ii).Text,...
                                        'FontName',PlotMarkers(ii).FontName,...
                                        'FontSize',PlotMarkers(ii).FontSize,...
                                        'color',PlotMarkers(ii).FontColor);
                                end
                            end
                        end
                        ylim([0 1.05])
                        if ~isempty(MatchProfileXLim)
                            xlim(MatchProfileXLim)
                        else
                            if any(~isnan(ModBins(Mod).Profile_XData))
                                xlim([0,ModBins(Mod).Profile_XData(max(ModBins(Mod).MatchProfileXIndices))])
                            end
                        end
    %                     if (q~=Groups(1)&&~FlipHist)||(Mod~=NumMods&&FlipHist)
    %                         %set(gca,'yticklabels',[])
    %                     else
    %                     end

                    end
                    ylabel({'Group';'Normalized'},...
                        'rotation',YLabelRotation,'verticalalignment',YLabelVertAlign,...
                        'horizontalalignment',YLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    xticks(MatchProfileXTicks)
                    xlabel([ProfileXLabel],...
                        'rotation',XLabelRotation,'verticalalignment',XLabelVertAlign,...
                        'horizontalalignment',XLabelHorzAlign,...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    tempxticklabels=[];
                    for i=1:length(MatchProfileXTicks)
                        tempxticklabels{i}=num2str(MatchProfileXTicks(i));
                    end
                    xticklabels(tempxticklabels)
                    xtickangle(XTickAngle)
                    FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                    PanelCount=PanelCount+1;
                    PlotPanelCount=PlotPanelCount+1;
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempYTicks=get(PlotPanels(PlotPanelCount1),'ytick');
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1)+TempPos(3)/2,TempPos(2)+TempPos(4)*0.5,TempPos(3)/2,TempPos(4)*0.5])
                        set(PlotPanels(PlotPanelCount1),'ytick',TempYTicks);
                    end
                    for PlotPanelCount1=1:length(PlotPanels)
                        TempPos=get(PlotPanels(PlotPanelCount1),'position');
                        set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
                    for LabelPanelCount1=1:length(LabelPanels)
                        TempPos=get(LabelPanels(LabelPanelCount1),'position');
                        set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
                    end
    %                 for q1=1:length(Groups)
    %                     q=Groups(q1);
    %                     TempPos=get(PlotPanels(q1),'position');
    %                     GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
    %                         'string',ModBins(1).Bins(q).Label,...
    %                         'verticalalignment','middle',...
    %                         'horizontalalignment','center',...
    %                         'color','k','fontname','arial','fontsize',MetricLabelFontSize);
    %                 end
                    q=1;
                    TempPos=get(PlotPanels(q),'position');
                    GroupLabels(q+1)=annotation('textbox',CalculationLabelPos,...
                        'string',CalculationLabel,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 if ProfileError
    %                     Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),13)
    %                 else
                        Full_Export_Fig(gcf,[PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1,[],1),3)
    %                 end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf('Finished!\n')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    close(AZFig)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        
        warning on
        warning('NOTE ENOUGH DATA PROVIDED TO MAKE HISTOGRAM FIGURES!')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
