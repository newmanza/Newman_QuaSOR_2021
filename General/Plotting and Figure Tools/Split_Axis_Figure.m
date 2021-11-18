function Split_Axis_Figure(FigName,FigDir,FigPosition,XVals_Mean,YVals_Mean,XVals_Error,YVals_Error
        

        XMax=0;
        XMin=100000;

        YMax=0;
        YMin=100000;
        for BoutonCount=1:length(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray)
            for q=1:length(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).All_Binned_Data.Evoked_Sil_Quart_Pr_Bin_wFullSilent.Counts)
                Labels{BoutonCount,q}=[num2str(round(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).All_Binned_Data.Evoked_Sil_Quart_Pr_Bin_wFullSilent.Percents(q)*1000)/10),'%'];
                MarkerColor{BoutonCount,q}=ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Color;
                if q>=3    
                    AxisLocations(BoutonCount,q)=2;
                    MarkerStyles{BoutonCount,q}='.';
                    MarkerSizes{BoutonCount,q}=16;
                    LineStyles{BoutonCount,q}='-';
                    LineWidths{BoutonCount,q}=0.5;
                else
                    AxisLocations(BoutonCount,q)=1;
                    if q==1
                        MarkerStyles{BoutonCount,q}='s';
                        MarkerSizes{BoutonCount,q}=12;
                        LineStyles{BoutonCount,q}='-';
                        LineWidths{BoutonCount,q}=0.5;
                    else
                        MarkerStyles{BoutonCount,q}='o';
                        MarkerSizes{BoutonCount,q}=6;
                        LineStyles{BoutonCount,q}='-';
                        LineWidths{BoutonCount,q}=0.5;
                    end
                end
                XVals_Mean(BoutonCount,q)=ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).All_Binned_Data.Evoked_Sil_Quart_Pr_Bin_wFullSilent.Binned_AZs(q).QuaSOR_AZ_Data(LowFreq_Mods).AZ_QuaSOR_HighRes_Maps(gauss).RotationAuto_Profiles.Auto_AZ_QuaSOR_Image_Sum_AZNorm.AllAuto_Profiles_Mean_Int;
                XVals_Error(BoutonCount,q)=NaN;
                YVals_Mean(BoutonCount,q)=ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).All_Binned_Data.Evoked_Sil_Quart_Pr_Bin_wFullSilent.Binned_AZs(q).QuaSOR_AZ_Data(Spont_Mods).AZ_QuaSOR_HighRes_Maps(gauss).RotationAuto_Profiles.Auto_AZ_QuaSOR_Image_Sum_AZNorm.AllAuto_Profiles_Mean_Int;
                YVals_Error(BoutonCount,q)=NaN;
                if any(~isnan(YVals_Error(BoutonCount,q)))
                    YMax=max([YMax,max(YVals_Mean(BoutonCount,q))+...
                        max(YVals_Error(BoutonCount,q))]);
                    YMin=min([YMin,min(YVals_Mean(BoutonCount,q))-...
                        max(YVals_Error(BoutonCount,q))]);
                else
                    YMax=max([YMax,max(YVals_Mean(BoutonCount,q))]);
                    YMin=min([YMin,min(YVals_Mean(BoutonCount,q))]);
                end
                if any(~isnan(XVals_Error(BoutonCount,q)))
                    XMax=max([XMax,max(YVals_Mean(BoutonCount,q))+...
                        max(XVals_Error(BoutonCount,q))]);
                    XMin=min([XMin,min(XVals_Mean(BoutonCount,q))-...
                        max(XVals_Error(BoutonCount,q))]);
                else
                    XMax=max([XMax,max(XVals_Mean(BoutonCount,q))]);
                    XMin=min([XMin,min(XVals_Mean(BoutonCount,q))]);
                end
            end
        end


        FigName=[ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).Label,' IbIs Binned Mean E_M Int wSilent Split'];
        disp(['Making Figure: ',FigName])
        figure('name',FigName)
        set(gcf,'position',[50,50,800,800])
        set(gcf, 'color', 'white');
        %%%%%%%%%%%%%%
        Ax2=subtightplot(1,2,2);
        hold on
        for r=1:size(XVals_Mean,1)
            for q=1:size(XVals_Mean,2)
                if AxisLocations(r,q)==2
                    if ~isempty(XVals_Mean)
                        if any(~isnan(YVals_Error(q)))
                            errorbar(   XVals_Mean(q),...
                                        YVals_Mean(q),...
                                        YVals_Error(q),...
                                        YVals_Error(q),...
                                        XVals_Error(q),...
                                        XVals_Error(q),...
                                        '.-','MarkerSize',16,'LineWidth',0.5,'color',ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Color)    
                            YMax=max([YMax,max(YVals_Mean(q))+...
                                max(YVals_Error(q))]);
                            YMin=min([YMin,min(YVals_Mean(q))-...
                                max(YVals_Error(q))]);
                        else
                            plot(   XVals_Mean(q),...
                                    YVals_Mean(q),...
                                    '.','MarkerSize',16,'LineWidth',0.5,'color',ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Color)    
                            YMax=max([YMax,max(YVals_Mean(q))]);
                            YMin=min([YMin,min(YVals_Mean(q))]);
                        end
                        if TextOn&&any(~isnan(YVals_Error(q)))
                            text(XVals_Mean(q),...
                                YVals_Mean(q)*1.05+YVals_Error(q),...
                                [num2str(round(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).All_Binned_Data.Evoked_Sil_Quart_Pr_Bin_wFullSilent.Percents(q)*1000)/10),'%'],...
                                'color',ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Color,'fontname','arial','fontsize',10,'horizontalalignment','center')
                        else
                            text(XVals_Mean(q),...
                                YVals_Mean(q)*1.05,...
                                [num2str(round(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).All_Binned_Data.Evoked_Sil_Quart_Pr_Bin_wFullSilent.Percents(q)*1000)/10),'%'],...
                                'color',ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Color,'fontname','arial','fontsize',10,'horizontalalignment','center')
                        end
                    end
                end
            end
            if ~isempty(XVals_Mean)
                plot(   XVals_Mean(3:size(XVals_Mean,2)),...
                        YVals_Mean(3:length(YVals_Mean)),...
                        '-','LineWidth',0.5,'color',ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Color)
            end
        end
        set(gca,'yticklabels',[])
        if LogX
            set(gca,'xscale','log')
            XLimits=xlim;
            xlim([XLimits(1)-XLimits(1)*0.1,XLimits(2)*1.1])
        else
            XLimits=xlim;
            xlim([0,XLimits(2)*1.1])
        end
        if ~isempty(MatchX)
            xlim([MatchX(1),MatchX(2)])
        end
        if ~isempty(MatchY)
            ylim([MatchY(1),MatchY(2)])
        end
        xlabel(XLabel)
        %FigureStandardizer_FixTicks(gca,[22 20]);
        %%%%%%%%%%
        Ax1=subtightplot(1,2,1);
        hold on
        for BoutonCount1=1:length(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray)
            hold on
            BoutonCount=length(BoutonArray)-(BoutonCount1-1);
            for q=1:length(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).All_Binned_Data.Evoked_Sil_Quart_Pr_Bin_wFullSilent.Counts)
                XVals_Mean(q)=ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).All_Binned_Data.Evoked_Sil_Quart_Pr_Bin_wFullSilent.Binned_AZs(q).QuaSOR_AZ_Data(LowFreq_Mods).AZ_QuaSOR_HighRes_Maps(gauss).RotationAuto_Profiles.Auto_AZ_QuaSOR_Image_Sum_AZNorm.AllAuto_Profiles_Mean_Int;
                XVals_Error(q)=NaN;
                YVals_Mean(q)=ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).All_Binned_Data.Evoked_Sil_Quart_Pr_Bin_wFullSilent.Binned_AZs(q).QuaSOR_AZ_Data(Spont_Mods).AZ_QuaSOR_HighRes_Maps(gauss).RotationAuto_Profiles.Auto_AZ_QuaSOR_Image_Sum_AZNorm.AllAuto_Profiles_Mean_Int;
                YVals_Error(q)=NaN;
            end
            for q=1:2
                if ~isempty(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).All_Binned_Data.Evoked_Sil_Quart_Pr_Bin_wFullSilent.Binned_AZs(q).QuaSOR_AZ_Data(LowFreq_Mods).AZ_QuaSOR_HighRes_Maps(gauss).RotationAuto_Profiles.Auto_AZ_QuaSOR_Image_Sum_AZNorm.AllAuto_Profiles_Mean_Int)
                    if any(~isnan(YVals_Error(q)))
                        if q==1
                            errorbar(   1,...
                                        YVals_Mean(q),...
                                        YVals_Error(q),...
                                        YVals_Error(q),...
                                        0,...
                                        0,...
                                        's-','MarkerSize',12,'LineWidth',0.5,'color',ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Color)
                        else
                            errorbar(   1,...
                                        YVals_Mean(q),...
                                        YVals_Error(q),...
                                        YVals_Error(q),...
                                        0,...
                                        0,...
                                        'o-','MarkerSize',6,'LineWidth',0.5,'color',ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Color)
                        end
                        YMax=max([YMax,max(YVals_Mean(q))+...
                            max(YVals_Error(q))]);
                        YMin=min([YMin,min(YVals_Mean(q))-...
                            max(YVals_Error(q))]);                    
                    else
                        if q==1
                            plot(   1,...
                                    YVals_Mean(q),...
                                    's','MarkerSize',12,'LineWidth',0.5,'color',ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Color)
                        else
                            plot(   1,...
                                    YVals_Mean(q),...
                                    'o','MarkerSize',6,'LineWidth',0.5,'color',ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Color)
                        end
                        YMax=max([YMax,max(YVals_Mean(q))]);
                        YMin=min([YMin,min(YVals_Mean(q))]);
                    end
                    hold on
                    if TextOn&&any(~isnan(YVals_Error(q)))
                        text(XVals_Mean(q),...
                            YVals_Mean(q)*1.05+YVals_Error(q),...
                            [num2str(round(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).All_Binned_Data.Evoked_Sil_Quart_Pr_Bin_wFullSilent.Percents(q)*1000)/10),'%'],...
                            'color',ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Color,'fontname','arial','fontsize',10,'horizontalalignment','center')
                    else
                        text(XVals_Mean(q),...
                            YVals_Mean(q)*1.05,...
                            [num2str(round(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).All_Binned_Data.Evoked_Sil_Quart_Pr_Bin_wFullSilent.Percents(q)*1000)/10),'%'],...
                            'color',ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Color,'fontname','arial','fontsize',10,'horizontalalignment','center')
                    end
                end
            end
        end
        xticks([1])
        xticklabels({'Silent'})
        xtickangle(30)
        xlim([0.9,1.1])
        if LogY
            set(gca,'yscale','log')
            YLimits=ylim;
            ylim([YMin-0.1*YMin,YMax*1.1])
        else
            YLimits=ylim;
            ylim([0,YMax*1.1])
        end
        if ~isempty(MatchY)
            ylim([MatchY(1),MatchY(2)])
        end
        ylabel([YLabel])
        %FigureStandardizer_FixTicks(gca,[22 20]);
        axes(Ax2)
        if LogY
            set(gca,'yscale','log')
            YLimits=ylim;
            ylim([YMin-0.1*YMin,YMax*1.1])
        else
            YLimits=ylim;
            ylim([0,YMax*1.1])
        end
        if ~isempty(MatchX)
            xlim([MatchX(1),MatchX(2)])
        end
        if ~isempty(MatchY)
            ylim([MatchY(1),MatchY(2)])
        end
        XLimits=xlim;
        YLimits=ylim;
        for BoutonCount1=1:length(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray)
            hold on
            BoutonCount=length(BoutonArray)-(BoutonCount1-1);
            YAdjust=(YLimits(2)-YLimits(1))*0.05;
            text(XLimits(1)+XLimits(2)*0.02,YLimits(2)-YAdjust*BoutonCount,...
                [ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Label,' ',...
                num2str(sum(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).All_Binned_Data.Evoked_Sil_Quart_Pr_Bin_wFullSilent.Counts))],...
                'fontsize',10,'color',ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(Experiment).BoutonArray(BoutonCount).Color)
        end
        axes(Ax1)
        set(Ax1,'units','normalized','position',[0.17,0.16,0.1,0.75])
        set(Ax2,'units','normalized','position',[0.30,0.16,0.65,0.75])
        if LogX
            FigName=[FigName,' LogX'];
        end
        if LogY
            FigName=[FigName,'LogY'];
        end
        if ~isempty(MatchX)||~isempty(MatchY)
            FigName=[FigName,' Match'];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        axes(Ax1);FigureStandardizer_FixTicks(gca,[22 20]);
        axes(Ax2);FigureStandardizer_FixTicks(gca,[22 20]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Full_Export_Fig(gcf,[Ax1;Ax2],[BinnedSaveDir,dc, FigName],1)