function Multi_Histogram_Figures(AllHistogramData,TempSaveDir)
    OS=computer;
    if strcmp(OS,'MACI64')
        dc='/';
    else
        dc='\';
    end
    FigPosition=[50 50 800 800];
    FigAxesPosition=[0.2 0.2 0.6 0.6];
    FigFontSizes=[22 20];
    
    close all
    if ~isempty(AllHistogramData.Overall_Label)
        if ~exist([TempSaveDir,dc,AllHistogramData.Overall_Label])
            mkdir([TempSaveDir,dc,AllHistogramData.Overall_Label])
        end
        
        FigName=[AllHistogramData.Overall_Label,' Hist'];
        figure,
        set(gcf,'position',FigPosition)
        set(gcf, 'color', 'white');
        hold on
        clear TempLegend
        count=0;
        for row=1:size(AllHistogramData.Data,1)
            for col=1:size(AllHistogramData.Data,2)
                plot([0,AllHistogramData.Data{row,col}.Stats.Bin_Centers],...
                    [0,AllHistogramData.Data{row,col}.Stats.Histogram],...
                    '-','LineWidth',0.5,'color',AllHistogramData.All_Colors{row,col})
                count=count+1;
                TempLegend{count}=[AllHistogramData.All_Labels{row,col},...
                    ' n=',num2str(AllHistogramData.Data{row,col}.Stats.Num)];
            end
        end
        xlabel([AllHistogramData.Overall_Label,' ',AllHistogramData.Units])
        ylabel(['Frequency'])
        XLimits=xlim;
        xlim([0,XLimits(2)])
        YLimits=ylim;
        ylim([0,YLimits(2)*1.1]) 
        legend(TempLegend,'location','NE')
        box off;pbaspect([1,1,1]);
                set(gca,'position',FigAxesPosition)
                FigureStandardizer_FixTicks(gca,FigFontSizes);
        Full_Export_Fig(gcf,gca,[TempSaveDir,dc,AllHistogramData.Overall_Label,dc,FigName],1)

        FigName=[AllHistogramData.Overall_Label,' Norm Hist'];
        figure,
        set(gcf,'position',FigPosition)
        set(gcf, 'color', 'white');
        hold on
        clear TempLegend
        count=0;
        for row=1:size(AllHistogramData.Data,1)
            for col=1:size(AllHistogramData.Data,2)
                plot([0,AllHistogramData.Data{row,col}.Stats.Bin_Centers],...
                    [0,AllHistogramData.Data{row,col}.Stats.Normalized_Histogram],...
                    '-','LineWidth',0.5,'color',AllHistogramData.All_Colors{row,col})
                count=count+1;
                TempLegend{count}=[AllHistogramData.All_Labels{row,col},...
                    ' n=',num2str(AllHistogramData.Data{row,col}.Stats.Num)];
            end
        end
        xlabel([AllHistogramData.Overall_Label,' ',AllHistogramData.Units])
        ylabel(['Normalized Frequency'])
        XLimits=xlim;
        xlim([0,XLimits(2)])
        YLimits=ylim;
        ylim([0,YLimits(2)*1.1]) 
        legend(TempLegend,'location','NE')
        box off;pbaspect([1,1,1]);
                set(gca,'position',FigAxesPosition)
                FigureStandardizer_FixTicks(gca,FigFontSizes);
        Full_Export_Fig(gcf,gca,[TempSaveDir,dc,AllHistogramData.Overall_Label,dc,FigName],1)

        FigName=[AllHistogramData.Overall_Label,' Norm Cumulative Hist'];
        figure,
        set(gcf,'position',FigPosition)
        set(gcf, 'color', 'white');
        hold on
        clear TempLegend
        MaxBin=0;
        for row1=1:size(AllHistogramData.Data,1)
            for col1=1:size(AllHistogramData.Data,2)
                MaxBin=max([MaxBin,max(AllHistogramData.Data{row1,col1}.Stats.Bin_Centers)]);
            end
        end
        count=0;
        for row=1:size(AllHistogramData.Data,1)
            for col=1:size(AllHistogramData.Data,2)
                plot([0,AllHistogramData.Data{row,col}.Stats.Bin_Centers,MaxBin],...
                    [0,AllHistogramData.Data{row,col}.Stats.Normalized_Cumulative_Histogram,1],...
                    '-','LineWidth',0.5,'color',AllHistogramData.All_Colors{row,col})
                count=count+1;
                TempLegend{count}=[AllHistogramData.All_Labels{row,col},...
                    ' n=',num2str(AllHistogramData.Data{row,col}.Stats.Num)];
            end
        end
        xlabel([AllHistogramData.Overall_Label,' ',AllHistogramData.Units])
        ylabel(['Normalized Cumulative Frequency'])
        XLimits=xlim;
        xlim([0,XLimits(2)])
        YLimits=ylim;
        ylim([0,YLimits(2)*1.1])
        legend(TempLegend,'location','sE')
        box off;pbaspect([1,1,1]);
                set(gca,'position',FigAxesPosition)
                FigureStandardizer_FixTicks(gca,FigFontSizes);
        Full_Export_Fig(gcf,gca,[TempSaveDir,dc,AllHistogramData.Overall_Label,dc,FigName],1)  
    end
    close all
    if ~isempty(AllHistogramData.RowGroup_Labels)
        for col=1:size(AllHistogramData.Data,2)
            if ~exist([TempSaveDir,dc,AllHistogramData.RowGroup_Labels{1,col}])
                mkdir([TempSaveDir,dc,AllHistogramData.RowGroup_Labels{1,col}])
            end

            FigName=[AllHistogramData.RowGroup_Labels{1,col},' Hist'];
            figure,
            set(gcf,'position',FigPosition)
            set(gcf, 'color', 'white');
            hold on
            clear TempLegend
            for row=1:size(AllHistogramData.Data,1)
                plot([0,AllHistogramData.Data{row,col}.Stats.Bin_Centers],...
                    [0,AllHistogramData.Data{row,col}.Stats.Histogram],...
                    '-','LineWidth',0.5,'color',AllHistogramData.RowGroup_Colors{row,col})
                TempLegend{row}=[AllHistogramData.All_Labels{row,col},...
                    ' n=',num2str(AllHistogramData.Data{row,col}.Stats.Num)];
            end
            xlabel([AllHistogramData.RowGroup_Labels{1,col},' ',AllHistogramData.Units])
            ylabel(['Frequency'])
            XLimits=xlim;
            xlim([0,XLimits(2)])
            YLimits=ylim;
            ylim([0,YLimits(2)*1.1]) 
            legend(TempLegend,'location','NE')
            box off;pbaspect([1,1,1]);
                set(gca,'position',FigAxesPosition)
                FigureStandardizer_FixTicks(gca,FigFontSizes);
            Full_Export_Fig(gcf,gca,[TempSaveDir,dc,AllHistogramData.RowGroup_Labels{1,col},dc,FigName],1)

            FigName=[AllHistogramData.RowGroup_Labels{1,col},' Norm Hist'];
            figure,
            set(gcf,'position',FigPosition)
            set(gcf, 'color', 'white');
            hold on
            clear TempLegend
            for row=1:size(AllHistogramData.Data,1)
                plot([0,AllHistogramData.Data{row,col}.Stats.Bin_Centers],...
                    [0,AllHistogramData.Data{row,col}.Stats.Normalized_Histogram],...
                    '-','LineWidth',0.5,'color',AllHistogramData.RowGroup_Colors{row,col})
                TempLegend{row}=[AllHistogramData.All_Labels{row,col},...
                    ' n=',num2str(AllHistogramData.Data{row,col}.Stats.Num)];
            end
            xlabel([AllHistogramData.RowGroup_Labels{1,col},' ',AllHistogramData.Units])
            ylabel(['Normalized Frequency'])
            XLimits=xlim;
            xlim([0,XLimits(2)])
            YLimits=ylim;
            ylim([0,YLimits(2)*1.1]) 
            legend(TempLegend,'location','NE')
            box off;pbaspect([1,1,1]);
                set(gca,'position',FigAxesPosition)
                FigureStandardizer_FixTicks(gca,FigFontSizes);
            Full_Export_Fig(gcf,gca,[TempSaveDir,dc,AllHistogramData.RowGroup_Labels{1,col},dc,FigName],1)

            FigName=[AllHistogramData.RowGroup_Labels{1,col},' Norm Cumulative Hist'];
            figure,
            set(gcf,'position',FigPosition)
            set(gcf, 'color', 'white');
            hold on
            clear TempLegend
            MaxBin=0;
            for row1=1:size(AllHistogramData.Data,1)
                %for col1=1:size(AllHistogramData.Data,2)
                    MaxBin=max([MaxBin,max(AllHistogramData.Data{row1,col}.Stats.Bin_Centers)]);
                %end
            end
            for row=1:size(AllHistogramData.Data,1)
                plot([0,AllHistogramData.Data{row,col}.Stats.Bin_Centers,MaxBin],...
                    [0,AllHistogramData.Data{row,col}.Stats.Normalized_Cumulative_Histogram,1],...
                    '-','LineWidth',0.5,'color',AllHistogramData.RowGroup_Colors{row,col})
                TempLegend{row}=[AllHistogramData.All_Labels{row,col},...
                    ' n=',num2str(AllHistogramData.Data{row,col}.Stats.Num)];
            end
            xlabel([AllHistogramData.RowGroup_Labels{1,col},' ',AllHistogramData.Units])
            ylabel(['Normalized Cumulative Frequency'])
            XLimits=xlim;
            xlim([0,XLimits(2)])
            YLimits=ylim;
            ylim([0,YLimits(2)*1.1])
            legend(TempLegend,'location','sE')
            box off;pbaspect([1,1,1]);
                set(gca,'position',FigAxesPosition)
                FigureStandardizer_FixTicks(gca,FigFontSizes);
            Full_Export_Fig(gcf,gca,[TempSaveDir,dc,AllHistogramData.RowGroup_Labels{1,col},dc,FigName],1)  
            
            
            close all
        end
    end
    close all
    if ~isempty(AllHistogramData.ColGroup_Labels)
        for row=1:size(AllHistogramData.Data,1)
            if ~exist([TempSaveDir,dc,AllHistogramData.ColGroup_Labels{row,1}])
                mkdir([TempSaveDir,dc,AllHistogramData.ColGroup_Labels{row,1}])
            end

            FigName=[AllHistogramData.ColGroup_Labels{row,1},' Hist'];
            figure,
            set(gcf,'position',FigPosition)
            set(gcf, 'color', 'white');
            hold on
            clear TempLegend
            for col=1:size(AllHistogramData.Data,2)
                plot([0,AllHistogramData.Data{row,col}.Stats.Bin_Centers],...
                    [0,AllHistogramData.Data{row,col}.Stats.Histogram],...
                    '-','LineWidth',0.5,'color',AllHistogramData.ColGroup_Colors{row,col})
                TempLegend{col}=[AllHistogramData.All_Labels{row,col},...
                    ' n=',num2str(AllHistogramData.Data{row,col}.Stats.Num)];
            end
            xlabel([AllHistogramData.ColGroup_Labels{row,1},' ',AllHistogramData.Units])
            ylabel(['Frequency'])
            XLimits=xlim;
            xlim([0,XLimits(2)])
            YLimits=ylim;
            ylim([0,YLimits(2)*1.1]) 
            legend(TempLegend,'location','NE')
            box off;pbaspect([1,1,1]);
                set(gca,'position',FigAxesPosition)
                FigureStandardizer_FixTicks(gca,FigFontSizes);
            Full_Export_Fig(gcf,gca,[TempSaveDir,dc,AllHistogramData.ColGroup_Labels{row,1},dc,FigName],1)

            FigName=[AllHistogramData.ColGroup_Labels{row,1},' Norm Hist'];
            figure,
            set(gcf,'position',FigPosition)
            set(gcf, 'color', 'white');
            hold on
            clear TempLegend
            for col=1:size(AllHistogramData.Data,2)
                plot([0,AllHistogramData.Data{row,col}.Stats.Bin_Centers],...
                    [0,AllHistogramData.Data{row,col}.Stats.Normalized_Histogram],...
                    '-','LineWidth',0.5,'color',AllHistogramData.ColGroup_Colors{row,col})
                TempLegend{col}=[AllHistogramData.All_Labels{row,col},...
                    ' n=',num2str(AllHistogramData.Data{row,col}.Stats.Num)];
            end
            xlabel([AllHistogramData.ColGroup_Labels{row,1},' ',AllHistogramData.Units])
            ylabel(['Normalized Frequency'])
            XLimits=xlim;
            xlim([0,XLimits(2)])
            YLimits=ylim;
            ylim([0,YLimits(2)*1.1]) 
            legend(TempLegend,'location','NE')
            box off;pbaspect([1,1,1]);
                set(gca,'position',FigAxesPosition)
                FigureStandardizer_FixTicks(gca,FigFontSizes);
            Full_Export_Fig(gcf,gca,[TempSaveDir,dc,AllHistogramData.ColGroup_Labels{row,1},dc,FigName],1)

            FigName=[AllHistogramData.ColGroup_Labels{row,1},' Norm Cumulative Hist'];
            figure,
            set(gcf,'position',FigPosition)
            set(gcf, 'color', 'white');
            hold on
            clear TempLegend
            MaxBin=0;
            %for row1=1:size(AllHistogramData.Data,1)
                for col1=1:size(AllHistogramData.Data,2)
                    MaxBin=max([MaxBin,max(AllHistogramData.Data{row,col1}.Stats.Bin_Centers)]);
                end
            %end
            for col=1:size(AllHistogramData.Data,2)
                plot([0,AllHistogramData.Data{row,col}.Stats.Bin_Centers,MaxBin],...
                    [0,AllHistogramData.Data{row,col}.Stats.Normalized_Cumulative_Histogram,1],...
                    '-','LineWidth',0.5,'color',AllHistogramData.ColGroup_Colors{row,col})
                TempLegend{col}=[AllHistogramData.All_Labels{row,col},...
                    ' n=',num2str(AllHistogramData.Data{row,col}.Stats.Num)];
            end
            xlabel([AllHistogramData.ColGroup_Labels{row,1},' ',AllHistogramData.Units])
            ylabel(['Normalized Cumulative Frequency'])
            XLimits=xlim;
            xlim([0,XLimits(2)])
            YLimits=ylim;
            ylim([0,YLimits(2)*1.1])
            legend(TempLegend,'location','sE')
            box off;pbaspect([1,1,1]);
                set(gca,'position',FigAxesPosition)
                FigureStandardizer_FixTicks(gca,FigFontSizes);
            Full_Export_Fig(gcf,gca,[TempSaveDir,dc,AllHistogramData.ColGroup_Labels{row,1},dc,FigName],1)  
            
            close all
        end
    end
    close all
    if ~isempty(AllHistogramData.All_Labels)
        for row=1:size(AllHistogramData.Data,1)
            for col=1:size(AllHistogramData.Data,2)
                if ~exist([TempSaveDir,dc,AllHistogramData.All_Labels{row,col}])
                    mkdir([TempSaveDir,dc,AllHistogramData.All_Labels{row,col}])
                end

                FigName=[AllHistogramData.All_Labels{row,col},' Hist'];
                figure,
                set(gcf,'position',FigPosition)
                set(gcf, 'color', 'white');
                hold on
                plot([0,AllHistogramData.Data{row,col}.Stats.Bin_Centers],...
                    [0,AllHistogramData.Data{row,col}.Stats.Histogram],...
                    '-','LineWidth',0.5,'color',AllHistogramData.All_Colors{row,col})
                xlabel([AllHistogramData.All_Labels{row,col},' ',AllHistogramData.Units])
                ylabel(['Frequency'])
                XLimits=xlim;
                xlim([0,XLimits(2)])
                YLimits=ylim;
                ylim([0,YLimits(2)*1.1]) 
                text(0.05,YLimits(2),['n=',num2str(AllHistogramData.Data{row,col}.Stats.Num)],...
                    'fontsize',10,'fontname','arial','color',AllHistogramData.All_Colors{row,col})
                box off;pbaspect([1,1,1]);
                set(gca,'position',FigAxesPosition)
                FigureStandardizer_FixTicks(gca,FigFontSizes);
                Full_Export_Fig(gcf,gca,[TempSaveDir,dc,AllHistogramData.All_Labels{row,col},dc,FigName],1)

                FigName=[AllHistogramData.All_Labels{row,col},' Norm Hist'];
                figure,
                set(gcf,'position',FigPosition)
                set(gcf, 'color', 'white');
                hold on
                plot([0,AllHistogramData.Data{row,col}.Stats.Bin_Centers],...
                    [0,AllHistogramData.Data{row,col}.Stats.Normalized_Histogram],...
                    '-','LineWidth',0.5,'color',AllHistogramData.All_Colors{row,col})
                xlabel([AllHistogramData.All_Labels{row,col},' ',AllHistogramData.Units])
                ylabel(['Normalized Frequency'])
                XLimits=xlim;
                xlim([0,XLimits(2)])
                YLimits=ylim;
                ylim([0,YLimits(2)*1.1]) 
                text(0.05,YLimits(2),['n=',num2str(AllHistogramData.Data{row,col}.Stats.Num)],...
                    'fontsize',10,'fontname','arial','color',AllHistogramData.All_Colors{row,col})
                box off;pbaspect([1,1,1]);
                set(gca,'position',FigAxesPosition)
                FigureStandardizer_FixTicks(gca,FigFontSizes);
                Full_Export_Fig(gcf,gca,[TempSaveDir,dc,AllHistogramData.All_Labels{row,col},dc,FigName],1)

                FigName=[AllHistogramData.All_Labels{row,col},' Cumulative Hist'];
                figure,
                set(gcf,'position',FigPosition)
                set(gcf, 'color', 'white');
                hold on
                plot([0,AllHistogramData.Data{row,col}.Stats.Bin_Centers],...
                    [0,AllHistogramData.Data{row,col}.Stats.Cumulative_Histogram],...
                    '-','LineWidth',0.5,'color',AllHistogramData.All_Colors{row,col})
                xlabel([AllHistogramData.All_Labels{row,col},' ',AllHistogramData.Units])
                ylabel(['Cumulative Frequency'])
                XLimits=xlim;
                xlim([0,XLimits(2)])
                YLimits=ylim;
                ylim([0,YLimits(2)*1.1])
                text(0.05,YLimits(2),['n=',num2str(AllHistogramData.Data{row,col}.Stats.Num)],...
                    'fontsize',10,'fontname','arial','color',AllHistogramData.All_Colors{row,col})
                box off;pbaspect([1,1,1]);
                set(gca,'position',FigAxesPosition)
                FigureStandardizer_FixTicks(gca,FigFontSizes);
                Full_Export_Fig(gcf,gca,[TempSaveDir,dc,AllHistogramData.All_Labels{row,col},dc,FigName],1)

                FigName=[AllHistogramData.All_Labels{row,col},' Norm Cumulative Hist'];
                figure,
                set(gcf,'position',FigPosition)
                set(gcf, 'color', 'white');
                hold on
                plot([0,AllHistogramData.Data{row,col}.Stats.Bin_Centers],...
                    [0,AllHistogramData.Data{row,col}.Stats.Normalized_Cumulative_Histogram],...
                    '-','LineWidth',0.5,'color',AllHistogramData.All_Colors{row,col})
                xlabel([AllHistogramData.All_Labels{row,col},' ',AllHistogramData.Units])
                ylabel(['Normalized Cumulative Frequency'])
                XLimits=xlim;
                xlim([0,XLimits(2)])
                YLimits=ylim;
                ylim([0,YLimits(2)*1.1])
                text(0.05,YLimits(2),['n=',num2str(AllHistogramData.Data{row,col}.Stats.Num)],...
                    'fontsize',10,'fontname','arial','color',AllHistogramData.All_Colors{row,col})
                box off;pbaspect([1,1,1]);
                set(gca,'position',FigAxesPosition)
                FigureStandardizer_FixTicks(gca,FigFontSizes);
                Full_Export_Fig(gcf,gca,[TempSaveDir,dc,AllHistogramData.All_Labels{row,col},dc,FigName],1)
                
                
                close all
            end
        end
    end
    close all

    
end