function AZ_Image_Profile_Figure(FigName,FigSaveDir,dc,ModBins,ColorScalar,...
    ProfileError,Profile_XData,ProfileXTicks,ProfileXLabel,ProfileYLabel,ColorLabel,CalculationLabel,...
    NumMods,NumGroups,PixelSize_nm,AZScaleBarLength_nm,ImageSize,RemovalIndex,MatchedModMax,ImageMarkers,PlotMarkers)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    AutoCloseFig=1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    if NumMods~=length(ModBins)
        warning('Activating Overlay Settings!')
        ColorMerge=1;
    else
        ColorMerge=0;
    end
    ScreenSize=get(0,'ScreenSize');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MetricLabelFontSize=18;
    MetricScaleFontSize=14;
    YScalar=100;
    if ScreenSize(4)>1000
        if NumGroups>3
        elseif NumGroups==1
            MetricLabelFontSize=16;
            MetricScaleFontSize=12;
        else
        end
    else
        if NumGroups>3
        elseif NumGroups==1
            MetricLabelFontSize=16;
            MetricScaleFontSize=12;
        else
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NumIterations=0;
    if isempty(RemovalIndex)||any(RemovalIndex==0)
        NumIterations=0;
    else
        NumIterations=length(RemovalIndex);
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
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            FigName1=[FigName,RemovalLabel];
            FigName1a=[FigName,RemovalLabela];
            fprintf(['Making: ',FigName1,'...'])
            AZFig=figure('name',FigName1);
            
            if ScreenSize(4)>1000
                if length(Groups)>1
                    set(gcf,'position',[0 0 (length(Groups))*300 1000])
                else
                    set(gcf,'position',[0 0 500 1000])
                end
            else
                if length(Groups)>1
                    set(gcf,'position',[0 0 (length(Groups))*200 900])
                else
                    set(gcf,'position',[0 0 500 900])
                end
            end
            if ColorMerge
                if ScreenSize(4)>1000
                    if NumGroups>3
                        set(gcf,'position',[0 0 (length(Groups))*300 800])
                    elseif NumGroups==1
                        set(gcf,'position',[0 0 500 800])
                    else
                        set(gcf,'position',[0 0 (length(Groups))*300 800])
                    end
                else
                    if NumGroups>3
                        set(gcf,'position',[0 0 (length(Groups))*300 800])
                    elseif NumGroups==1
                        set(gcf,'position',[0 0 500 800])
                    else
                        set(gcf,'position',[0 0 (length(Groups))*300 800])
                    end
                end
            end               
            set(gcf,'color','w')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            clear ImagePanels PlotPanels LabelPanels GroupLabels
            if ColorMerge
                NumPanels=(length(Groups)+1)*(NumMods+1);
            else
                NumPanels=(length(Groups)+1)*(NumMods+2);
            end
            PanelCount=1;
            ImagePanels=[];
            ImagePanelCount=1;
            PlotPanels=[];
            PlotPanelCount=1;
            LabelPanels=[];
            LabelPanelCount=1;
            GlobalVertAdjust=0.15;
            AZScaleBarLength_px=AZScaleBarLength_nm/PixelSize_nm;
            LineWidth=0.5;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ColorMerge
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                LabelPanels(LabelPanelCount)=subtightplot(NumMods+2,length(Groups)+1,PanelCount);
                box off
                axis off
                ColorMapImageMerge=[];
                for Mod=1:length(ModBins)
                    if ischar(ModBins(Mod).ImageColor)
                        if length(ModBins(Mod).ImageColor)==1
                            Temp_cMap=makeColorMap([0 0 0],ColorDefinitions(ModBins(Mod).ImageColor),ColorScalar);
                        else
                            if any(contains(ModBins(Mod).ImageColor,'jet'))
                                Temp_cMap=jet(ColorScalar);
                            elseif any(contains(ModBins(Mod).ImageColor,'parula'))
                                Temp_cMap=parula(ColorScalar);
                            elseif any(contains(ModBins(Mod).ImageColor,'hot'))
                                Temp_cMap=hot(ColorScalar);
                            elseif any(contains(ModBins(Mod).ImageColor,'gray'))||any(contains(ModBins(Mod).ImageColor,'grays'))
                                Temp_cMap=gray(ColorScalar);
                            else
                                warning('Missing Color Code Needs to be [0,1,1], r or jet/parula/hot/gray')
                                error('Fix Color Code...')
                            end
                        end
                    elseif length(ModBins(Mod).ImageColor)==3
                        Temp_cMap=makeColorMap([0 0 0],ModBins(Mod).ImageColor,ColorScalar);
                    else
                        warning('Missing Color Code Needs to be [0,1,1], r or jet/parula/hot/gray')
                        error('Fix Color Code...')
                    end
                    ColorScarlarWidth=ColorScalar/5;
                    ColorMapImage=zeros(ColorScalar,ColorScarlarWidth,3);
                    for y=1:ColorScalar
                        ColorMapImage(y,1,:)=Temp_cMap(y,:);
                    end
                    for x=2:ColorScarlarWidth
                        ColorMapImage(:,x,:)=ColorMapImage(:,1,:);
                    end
                    ColorMapImage=flipud(ColorMapImage);
            %         imagesc(fliplr([0:0.01:1])')
            %         colormap(ModBins(Mod).ImageColor)
                    ColorMapImageMerge=cat(2,ColorMapImageMerge,cat(2,ones(ColorScalar,ColorScarlarWidth/2,3),ColorMapImage));
                end
                imshow(double(ColorMapImageMerge),...
                    'border','tight');
                set(gca,'xtick',[]),set(gca,'ytick',[])
                text(-0.5*ColorScarlarWidth, ColorScalar/2,ColorLabel,...
                    'verticalalignment','middle',...
                    'horizontalalignment','right',...
                    'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                for Mod=1:length(ModBins)
                    if MatchedModMax==1
                        TempImageMax=0;
                        for Mod1=1:length(ModBins)
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                TempImageMax=max([TempImageMax,max(ModBins(Mod1).Bins(q2).Image(:))]);
                            end
                        end
                    elseif MatchedModMax==2
                        TempImageMax=ModBins(Mod).Image_Max;
                    else    
                        TempImageMax=0;
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            TempImageMax=max([TempImageMax,max(ModBins(Mod).Bins(q2).Image(:))]);
                        end
                    end
                    text((Mod)*ColorScarlarWidth+(Mod-1)*0.5*ColorScarlarWidth, 0.5*ColorScalar, ModBins(Mod).Label,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'rotation',90,...
                        'color','w','fontname','arial','fontsize',MetricScaleFontSize)
                    text((Mod)*ColorScarlarWidth+(Mod-1)*0.5*ColorScarlarWidth, ColorScalar+0.075*ColorScalar, num2str(ModBins(Mod).Min),...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricScaleFontSize-2)
                    text((Mod)*ColorScarlarWidth+(Mod-1)*0.5*ColorScarlarWidth, -0.075*ColorScalar, num2str(round(TempImageMax*YScalar)/YScalar),...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricScaleFontSize-2)
                    clear ColorMapImage
                    freezeColors
                end
                TempPos=get(LabelPanels(LabelPanelCount),'position');
                set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.5,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.5,TempPos(4)-TempPos(4)*0.4]);
                LabelPanelCount=LabelPanelCount+1;
                PanelCount=PanelCount+1;
                for q1=1:length(Groups)
                    q=Groups(q1);
                    MergeImage=zeros(size(ModBins(Mod).Bins(q).Image,1),size(ModBins(Mod).Bins(q).Image,2),3);
                    for Mod=1:length(ModBins)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if MatchedModMax==1
                            TempImageMax=0;
                            for Mod1=1:length(ModBins)
                                for q3=1:length(Groups)
                                    q2=Groups(q3);
                                    TempImageMax=max([TempImageMax,max(ModBins(Mod1).Bins(q2).Image(:))]);
                                end
                            end
                        elseif MatchedModMax==2
                            TempImageMax=ModBins(Mod).Image_Max;
                        else    
                            TempImageMax=0;
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                TempImageMax=max([TempImageMax,max(ModBins(Mod).Bins(q2).Image(:))]);
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        [~,TempImage_Color,~]=...
                            Adjust_Contrast_and_Color(...
                            ModBins(Mod).Bins(q).Image,ModBins(Mod).Min,TempImageMax,...
                            ModBins(Mod).ImageColor,ColorScalar);
                        MergeImage=MergeImage+TempImage_Color;
                    end
                    ImagePanels(ImagePanelCount)=subtightplot(NumMods+2,length(Groups)+1,PanelCount);
                    imshow(double(MergeImage),...
                        'border','tight');
                    if ~isempty(ImageMarkers)
                        hold on
                        for ii=1:length(ImageMarkers)
                            if isempty(ImageMarkers(ii).MarkerStyle)
                                plot(ImageMarkers(ii).XData,ImageMarkers(ii).YData,...
                                    [ImageMarkers(ii).LineStyle],...
                                    'color',ImageMarkers(ii).Color,...
                                    'linewidth',ImageMarkers(ii).LineWidth);                    
                            else
                                plot(ImageMarkers(ii).XData,ImageMarkers(ii).YData,...
                                    [ImageMarkers(ii).MarkerStyle,ImageMarkers(ii).LineStyle],...
                                    'color',ImageMarkers(ii).Color,...
                                    'linewidth',ImageMarkers(ii).LineWidth,...
                                    'markersize',ImageMarkers(ii).MarkerSize);
                            end
                        end
                    end
                    hold on
                    plot([ImageSize(2)*0.05,ImageSize(2)*0.05+AZScaleBarLength_px],...
                        [ImageSize(1)*0.95,ImageSize(1)*0.95],'-','color','w','linewidth',1)
                    if ImagePanelCount==1
                        text(ImageSize(2)*0.05,ImageSize(1)*0.85,[num2str(AZScaleBarLength_nm),' nm'],...
                            'color','w','fontname','arial','fontsize',MetricLabelFontSize)
                    end
                    set(gca,'xtick',[])
                    set(gca,'ytick',[])
                    box off
                    PanelCount=PanelCount+1;
                    ImagePanelCount=ImagePanelCount+1;
                    clear TempImage_Cont TempImage_Color
                end
                for Mod=1:length(ModBins)
                    PanelCount=PanelCount+1;
                    for q1=1:length(Groups)
                        q=Groups(q1);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if MatchedModMax==1
                            TempProfileMax=0;
                            for Mod1=1:length(ModBins)
                                for q3=1:length(Groups)
                                    q2=Groups(q3);
                                    if ProfileError
                                        TempProfileMax=max([TempProfileMax,max(ModBins(Mod1).Bins(q2).Profile_Mean(:))+max(ModBins(Mod1).Bins(q2).Profile_Error(:))]);
                                    else
                                        TempProfileMax=max([TempProfileMax,max(ModBins(Mod1).Bins(q2).Profile_Mean(:))]);
                                    end
                                end
                            end
                        elseif MatchedModMax==2
                            TempProfileMax=ModBins(Mod).Profile_Max;
                        else    
                            TempProfileMax=0;
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                if ProfileError
                                    TempProfileMax=max([TempProfileMax,max(ModBins(Mod).Bins(q2).Profile_Mean(:))+max(ModBins(Mod).Bins(q2).Profile_Error(:))]);
                                else
                                    TempProfileMax=max([TempProfileMax,max(ModBins(Mod).Bins(q2).Profile_Mean(:))]);
                                end
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if MatchedModMax==1
                            TempImageMax=0;
                            for Mod1=1:length(ModBins)
                                for q3=1:length(Groups)
                                    q2=Groups(q3);
                                    TempImageMax=max([TempImageMax,max(ModBins(Mod1).Bins(q2).Image(:))]);
                                end
                            end
                        elseif MatchedModMax==2
                            TempImageMax=ModBins(Mod).Image_Max;
                        else    
                            TempImageMax=0;
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                TempImageMax=max([TempImageMax,max(ModBins(Mod).Bins(q2).Image(:))]);
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        PlotPanels(PlotPanelCount)=subtightplot(NumMods+2,length(Groups)+1,PanelCount);
                        hold on
                        if ProfileError
                            lineProps.col{1}=ModBins(Mod).Color;
                            lineProps.style='-';
                            lineProps.width=LineWidth;
                            mseb(Profile_XData,...
                                ModBins(Mod).Bins(q).Profile_Mean,...
                                ModBins(Mod).Bins(q).Profile_Error,...
                                lineProps,0);
            %                 shadedErrorBar(Profile_XData,...
            %                     ModBins(Mod).Bins(q).Profile_Mean,...
            %                     ModBins(Mod).Bins(q).Profile_Error,...
            %                     ['-',ModBins(Mod).Color]);
                        else
                            plot(Profile_XData,...
                                ModBins(Mod).Bins(q).Profile_Mean,...
                                '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
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
                        end
                        try
                            ylim([ModBins(Mod).Min,ceil(TempProfileMax*YScalar)/YScalar])
                            yticks([ModBins(Mod).Min,ceil(TempProfileMax*YScalar)/YScalar])
                            yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempProfileMax*YScalar)/YScalar)})
                        catch
                            warning('YLimit error!')
                        end
                        xlim([Profile_XData(1),Profile_XData(length(Profile_XData))])
                        if q~=Groups(1)
                            set(gca,'yticklabels',[])
                        else
                            ylabel(vertcat(ModBins(Mod).Label,ProfileYLabel),...
                                'rotation',0,'verticalalignment','middle',...
                                'horizontalalignment','right',...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                        end
                        xticks(ProfileXTicks)
                        if Mod~=length(ModBins)
                            set(gca,'xticklabels',[])
                        else
                            xlabel([ProfileXLabel])
                            tempxticklabels=[];
                            for i=1:length(ProfileXTicks)
                                tempxticklabels{i}=num2str(ProfileXTicks(i));
                            end
                            xticklabels(tempxticklabels)
                            xtickangle(30)
                        end
                        FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                        PanelCount=PanelCount+1;
                        PlotPanelCount=PlotPanelCount+1;
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for Mod=1:NumMods
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if MatchedModMax==1
                        TempImageMax=0;
                        for Mod1=1:length(ModBins)
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                TempImageMax=max([TempImageMax,max(ModBins(Mod1).Bins(q2).Image(:))]);
                            end
                        end
                    elseif MatchedModMax==2
                        TempImageMax=ModBins(Mod).Image_Max;
                    else    
                        TempImageMax=0;
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            TempImageMax=max([TempImageMax,max(ModBins(Mod).Bins(q2).Image(:))]);
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    LabelPanels(LabelPanelCount)=subtightplot(NumMods+2,length(Groups)+1,PanelCount);
                    box off
                    axis off
                    if ischar(ModBins(Mod).ImageColor)
                        if length(ModBins(Mod).ImageColor)==1
                            Temp_cMap=makeColorMap([0 0 0],ColorDefinitions(ModBins(Mod).ImageColor),ColorScalar);
                        else
                            if any(contains(ModBins(Mod).ImageColor,'jet'))
                                Temp_cMap=jet(ColorScalar);
                            elseif any(contains(ModBins(Mod).ImageColor,'parula'))
                                Temp_cMap=parula(ColorScalar);
                            elseif any(contains(ModBins(Mod).ImageColor,'hot'))
                                Temp_cMap=hot(ColorScalar);
                            elseif any(contains(ModBins(Mod).ImageColor,'gray'))||any(contains(ModBins(Mod).ImageColor,'grays'))
                                Temp_cMap=gray(ColorScalar);
                            else
                                warning('Missing Color Code Needs to be [0,1,1], r or jet/parula/hot/gray')
                                error('Fix Color Code...')
                            end
                        end
                    elseif length(ModBins(Mod).ImageColor)==3
                        Temp_cMap=makeColorMap([0 0 0],ModBins(Mod).ImageColor,ColorScalar);
                    else
                        warning('Missing Color Code Needs to be [0,1,1], r or jet/parula/hot/gray')
                        error('Fix Color Code...')
                    end
                    ColorScarlarWidth=ColorScalar/5;
                    ColorMapImage=zeros(ColorScalar,ColorScarlarWidth,3);
                    for y=1:ColorScalar
                        ColorMapImage(y,1,:)=Temp_cMap(y,:);
                    end
                    for x=2:ColorScarlarWidth
                        ColorMapImage(:,x,:)=ColorMapImage(:,1,:);
                    end
                    ColorMapImage=flipud(ColorMapImage);
            %         imagesc(fliplr([0:0.01:1])')
            %         colormap(ModBins(Mod).ImageColor)
                    imshow(double(ColorMapImage),...
                        'border','tight');
                    set(gca,'xtick',[]),set(gca,'ytick',[])
                    text(-1*ColorScarlarWidth, ColorScalar/2,vertcat(ModBins(Mod).Label,ColorLabel),...
                        'verticalalignment','middle',...
                        'horizontalalignment','right',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                    text(-0.1*ColorScarlarWidth, ColorScalar, num2str(ModBins(Mod).Min),...
                        'verticalalignment','middle',...
                        'horizontalalignment','right',...
                        'color','k','fontname','arial','fontsize',MetricScaleFontSize)
                    text(-0.1*ColorScarlarWidth, 0, num2str(round(TempImageMax*YScalar)/YScalar),...
                        'verticalalignment','middle',...
                        'horizontalalignment','right',...
                        'color','k','fontname','arial','fontsize',MetricScaleFontSize)
                    clear ColorMapImage
                    freezeColors
                    TempPos=get(LabelPanels(LabelPanelCount),'position');
                    set(LabelPanels(LabelPanelCount),'position',[TempPos(1)+TempPos(3)*0.8,TempPos(2)+TempPos(4)*0.2,TempPos(3)*0.2,TempPos(4)-TempPos(4)*0.4]);
                    PanelCount=PanelCount+1;
                    LabelPanelCount=LabelPanelCount+1;
                    for q1=1:length(Groups)
                        q=Groups(q1);
                        [~,TempImage_Color,~]=...
                            Adjust_Contrast_and_Color(...
                            ModBins(Mod).Bins(q).Image,ModBins(Mod).Min,TempImageMax,...
                            ModBins(Mod).ImageColor,ColorScalar);

                        ImagePanels(ImagePanelCount)=subtightplot(NumMods+2,length(Groups)+1,PanelCount);
                        imshow(double(TempImage_Color),...
                            'border','tight');
                        if ~isempty(ImageMarkers)
                            hold on
                            for ii=1:length(ImageMarkers)
                                if isempty(ImageMarkers(ii).MarkerStyle)
                                    plot(ImageMarkers(ii).XData,ImageMarkers(ii).YData,...
                                        [ImageMarkers(ii).LineStyle],...
                                        'color',ImageMarkers(ii).Color,...
                                        'linewidth',ImageMarkers(ii).LineWidth);                    
                                else
                                    plot(ImageMarkers(ii).XData,ImageMarkers(ii).YData,...
                                        [ImageMarkers(ii).MarkerStyle,ImageMarkers(ii).LineStyle],...
                                        'color',ImageMarkers(ii).Color,...
                                        'linewidth',ImageMarkers(ii).LineWidth,...
                                        'markersize',ImageMarkers(ii).MarkerSize);
                                end
                            end
                        end
                        hold on
                        plot([ImageSize(2)*0.05,ImageSize(2)*0.05+AZScaleBarLength_px],...
                            [ImageSize(1)*0.95,ImageSize(1)*0.95],'-','color','w','linewidth',1)
                        if ImagePanelCount==1
                            text(ImageSize(2)*0.05,ImageSize(1)*0.85,[num2str(AZScaleBarLength_nm),' nm'],...
                                'color','w','fontname','arial','fontsize',MetricLabelFontSize)
                        end
                        set(gca,'xtick',[])
                        set(gca,'ytick',[])
                        box off
                        PanelCount=PanelCount+1;
                        ImagePanelCount=ImagePanelCount+1;
                        clear TempImage_Cont TempImage_Color
                    end
                end
                for Mod=1:NumMods
                    PanelCount=PanelCount+1;
                    for q1=1:length(Groups)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if MatchedModMax==1
                            TempProfileMax=0;
                            for Mod1=1:length(ModBins)
                                for q3=1:length(Groups)
                                    q2=Groups(q3);
                                    if ProfileError
                                        TempProfileMax=max([TempProfileMax,max(ModBins(Mod1).Bins(q2).Profile_Mean(:))+max(ModBins(Mod1).Bins(q2).Profile_Error(:))]);
                                    else
                                        TempProfileMax=max([TempProfileMax,max(ModBins(Mod1).Bins(q2).Profile_Mean(:))]);
                                    end
                                end
                            end
                       elseif MatchedModMax==2
                            TempProfileMax=ModBins(Mod).Profile_Max;
                       else    
                            TempProfileMax=0;
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                if ProfileError
                                    TempProfileMax=max([TempProfileMax,max(ModBins(Mod).Bins(q2).Profile_Mean(:))+max(ModBins(Mod).Bins(q2).Profile_Error(:))]);
                                else
                                    TempProfileMax=max([TempProfileMax,max(ModBins(Mod).Bins(q2).Profile_Mean(:))]);
                                end
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        q=Groups(q1);
                        PlotPanels(PlotPanelCount)=subtightplot(NumMods+2,length(Groups)+1,PanelCount);
                        hold on
                        if ProfileError
                            lineProps.col{1}=ModBins(Mod).Color;
                            lineProps.style='-';
                            lineProps.width=LineWidth;
                            mseb(Profile_XData,...
                                ModBins(Mod).Bins(q).Profile_Mean,...
                                ModBins(Mod).Bins(q).Profile_Error,...
                                lineProps,0);
            %                 shadedErrorBar(Profile_XData,...
            %                     ModBins(Mod).Bins(q).Profile_Mean,...
            %                     ModBins(Mod).Bins(q).Profile_Error,...
            %                     ['-',ModBins(Mod).Color]);
                        else
                            plot(Profile_XData,...
                                ModBins(Mod).Bins(q).Profile_Mean,...
                                '-','color',ModBins(Mod).Color,'linewidth',LineWidth);
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
                        end
                        try
                            ylim([ModBins(Mod).Min,ceil(TempProfileMax*YScalar)/YScalar])
                            yticks([ModBins(Mod).Min,ceil(TempProfileMax*YScalar)/YScalar])
                            yticklabels({num2str(ModBins(Mod).Min),num2str(ceil(TempProfileMax*YScalar)/YScalar)})
                        catch
                            warning('YLimit error!')
                        end
                        xlim([Profile_XData(1),Profile_XData(length(Profile_XData))])
                        if q~=Groups(1)
                            set(gca,'yticklabels',[])
                        else
                            ylabel(vertcat(ModBins(Mod).Label,ProfileYLabel),...
                                'rotation',0,'verticalalignment','middle',...
                                'horizontalalignment','right',...
                                'color','k','fontname','arial','fontsize',MetricLabelFontSize)
                        end
                        xticks(ProfileXTicks)
                        if Mod~=NumMods
                            set(gca,'xticklabels',[])
                        else
                            xlabel([ProfileXLabel])
                            tempxticklabels=[];
                            for i=1:length(ProfileXTicks)
                                tempxticklabels{i}=num2str(ProfileXTicks(i));
                            end
                            xticklabels(tempxticklabels)
                            xtickangle(30)
                        end
                        FigureStandardizer_FixTicks(gca,[MetricLabelFontSize,MetricScaleFontSize])
                        PanelCount=PanelCount+1;
                        PlotPanelCount=PlotPanelCount+1;
                    end
                end
            end
            for PlotPanelCount1=1:length(PlotPanels)
                TempPos=get(PlotPanels(PlotPanelCount1),'position');
                if PlotPanelCount1<=length(Groups)
                    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)/2,TempPos(3),TempPos(4)/2])
                else
                    set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)+TempPos(4)*0.9,TempPos(3),TempPos(4)/2])
                end
            end
            for PlotPanelCount1=1:length(PlotPanels)
                TempPos=get(PlotPanels(PlotPanelCount1),'position');
                set(PlotPanels(PlotPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
            end
            for ImagePanelCount1=1:length(ImagePanels)
                TempPos=get(ImagePanels(ImagePanelCount1),'position');
                set(ImagePanels(ImagePanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
            end
            for LabelPanelCount1=1:length(LabelPanels)
                TempPos=get(LabelPanels(LabelPanelCount1),'position');
                set(LabelPanels(LabelPanelCount1),'position',[TempPos(1),TempPos(2)-GlobalVertAdjust,TempPos(3),TempPos(4)])
            end
            for q1=1:length(Groups)
                q=Groups(q1);
                TempPos=get(PlotPanels(q1),'position');
                if ColorMerge
                    GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.80,0,0],...
                        'string',ModBins(1).Bins(q).Label,...
                        'verticalalignment','bottom',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                else
                    GroupLabels(q)=annotation('textbox',[TempPos(1)+TempPos(3)/2,0.88,0,0],...
                        'string',ModBins(1).Bins(q).Label,...
                        'verticalalignment','middle',...
                        'horizontalalignment','center',...
                        'color','k','fontname','arial','fontsize',MetricLabelFontSize);
                end
            end
            q1=1;
            q=Groups(q1);
            TempPos=get(PlotPanels(q1),'position');
            GroupLabels(q+1)=annotation('textbox',[0.01,0.80,0.15,0.15],...
                'string',CalculationLabel,...
                'verticalalignment','middle',...
                'horizontalalignment','center',...
                'color','k','fontname','arial','fontsize',MetricLabelFontSize);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            try
                if ProfileError
                    Full_Export_Fig(gcf,[ImagePanels,PlotPanels,LabelPanels],[FigSaveDir,dc, FigName1],2)
                else
                    Full_Export_Fig(gcf,[ImagePanels,PlotPanels,LabelPanels],[FigSaveDir,dc, FigName1],1)
                end
            catch
                if ProfileError
                    Full_Export_Fig(gcf,[ImagePanels,PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1a,[],1),13)
                else
                    Full_Export_Fig(gcf,[ImagePanels,PlotPanels,LabelPanels],Check_Dir_and_File(FigSaveDir,FigName1a,[],1),3)
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('Finished!\n')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if AutoCloseFig
                close(AZFig)
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['Exporting All Tiffs...'])
    FigSaveDir_TIFs=[FigSaveDir,dc,'tiffs'];
    if ~exist(FigSaveDir_TIFs)
        mkdir(FigSaveDir_TIFs)
    end
    for Mod=1:NumMods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if MatchedModMax==1
            TempImageMax=0;
            for Mod1=1:length(ModBins)
                for q3=1:length(Groups)
                    q2=Groups(q3);
                    TempImageMax=max([TempImageMax,max(ModBins(Mod1).Bins(q2).Image(:))]);
                end
            end
        elseif MatchedModMax==2
            TempImageMax=ModBins(Mod).Image_Max;
        else    
            TempImageMax=0;
            for q3=1:length(Groups)
                q2=Groups(q3);
                TempImageMax=max([TempImageMax,max(ModBins(Mod).Bins(q2).Image(:))]);
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for q=1:NumGroups
            try
                [TempImage_Cont,TempImage_Color,~]=...
                    Adjust_Contrast_and_Color(...
                    ModBins(Mod).Bins(q).Image,ModBins(Mod).Min,TempImageMax,...
                    ModBins(Mod).ImageColor,ColorScalar);
                imwrite(TempImage_Color,[FigSaveDir_TIFs,dc,FigName,' M',num2str(Mod),'_Q',num2str(q),'.tif'])
            catch
               warning('Problem generating TIF') 
            end
        end
    end
    if ColorMerge
        for q=1:NumGroups
            TempMerge=zeros(size(ModBins(1).Bins(1).Image));
            for Mod=1:NumMods
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if MatchedModMax==1
                    TempImageMax=0;
                    for Mod1=1:length(ModBins)
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            TempImageMax=max([TempImageMax,max(ModBins(Mod1).Bins(q2).Image(:))]);
                        end
                    end
                elseif MatchedModMax==2
                    TempImageMax=ModBins(Mod).Image_Max;
                else    
                    TempImageMax=0;
                    for q3=1:length(Groups)
                        q2=Groups(q3);
                        TempImageMax=max([TempImageMax,max(ModBins(Mod).Bins(q2).Image(:))]);
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                try
                    [TempImage_Cont,TempImage_Color,~]=...
                        Adjust_Contrast_and_Color(...
                        ModBins(Mod).Bins(q).Image,ModBins(Mod).Min,TempImageMax,...
                        ModBins(Mod).ImageColor,ColorScalar);
                    TempMerge=TempMerge+TempImage_Color;
                catch
                   warning('Problem generating TIF') 
            end
            end
            imwrite(TempMerge,[FigSaveDir_TIFs,dc,FigName,' Q',num2str(q),' Merge.tif'])
        end
    else

    end
    fprintf('Finished!\n')
    if ~isempty(RemovalIndex)||any(RemovalIndex==0)
        for RemovalNum=1:NumIterations
            RemovalLabela=[' M_'];
            for r=1:length(RemovalIndex(1:RemovalNum))
                RemovalLabela=[RemovalLabela,num2str(RemovalIndex(r))];
                if length(RemovalIndex(1:RemovalNum))>1&&r<length(RemovalIndex(1:RemovalNum))
                    RemovalLabela=[RemovalLabela,'_'];
                end
            end
            fprintf(['Exporting ',RemovalLabela,' Tiffs...'])

            FigSaveDir_TIFs=[FigSaveDir,dc,'tiffs',dc,RemovalLabela];
            if ~exist(FigSaveDir_TIFs)
                mkdir(FigSaveDir_TIFs)
            end
            for Mod=1:NumMods
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if MatchedModMax==1
                    TempImageMax=0;
                    for Mod1=1:length(ModBins)
                        for q3=1:length(Groups)
                            q2=Groups(q3);
                            TempImageMax=max([TempImageMax,max(ModBins(Mod1).Bins(q2).Image(:))]);
                        end
                    end
                elseif MatchedModMax==2
                    TempImageMax=ModBins(Mod).Image_Max;
                else    
                    TempImageMax=0;
                    for q3=1:length(Groups)
                        q2=Groups(q3);
                        TempImageMax=max([TempImageMax,max(ModBins(Mod).Bins(q2).Image(:))]);
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for q=1:NumGroups
                    try
                        [TempImage_Cont,TempImage_Color,~]=...
                            Adjust_Contrast_and_Color(...
                            ModBins(Mod).Bins(q).Image,ModBins(Mod).Min,TempImageMax,...
                            ModBins(Mod).ImageColor,ColorScalar);
                        imwrite(TempImage_Color,[FigSaveDir_TIFs,dc,FigName,' M',num2str(Mod),'_Q',num2str(q),RemovalLabela,'.tif'])
                    catch
                       warning('Problem generating TIF') 
                    end
                end
            end
            if ColorMerge
                for q=1:NumGroups
                    TempMerge=zeros(size(ModBins(1).Bins(1).Image));
                    for Mod=1:NumMods
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if MatchedModMax==1
                            TempImageMax=0;
                            for Mod1=1:length(ModBins)
                                for q3=1:length(Groups)
                                    q2=Groups(q3);
                                    TempImageMax=max([TempImageMax,max(ModBins(Mod1).Bins(q2).Image(:))]);
                                end
                            end
                        elseif MatchedModMax==2
                            TempImageMax=ModBins(Mod).Image_Max;
                        else    
                            TempImageMax=0;
                            for q3=1:length(Groups)
                                q2=Groups(q3);
                                TempImageMax=max([TempImageMax,max(ModBins(Mod).Bins(q2).Image(:))]);
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        try
                            [TempImage_Cont,TempImage_Color,~]=...
                                Adjust_Contrast_and_Color(...
                                ModBins(Mod).Bins(q).Image,ModBins(Mod).Min,TempImageMax,...
                                ModBins(Mod).ImageColor,ColorScalar);
                            TempMerge=TempMerge+TempImage_Color;
                        catch
                           warning('Problem generating TIF') 
                        end
                    end
                    imwrite(TempMerge,[FigSaveDir_TIFs,dc,FigName,' Q',num2str(q),RemovalLabela,' Merge.tif'])
                end
            else

            end
            fprintf('Finished!\n')

        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
