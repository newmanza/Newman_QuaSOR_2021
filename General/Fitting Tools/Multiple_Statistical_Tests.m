function [AllStatTests]=Multiple_Statistical_Tests(DataStructure,Statistical_Comparison_Label,DisplayResults,ExportAllResults,StatisticsSaveDir)
    AnovaPostHoc_alpha=0.05;
    DisplayChoice='off';
    if DisplayResults
        DisplayTables='on';
    else
        DisplayTables='off';
    end
    ANOVA_Mode=[1];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(DataStructure)
        if iscell(DataStructure(1).Data)
            for i=1:length(DataStructure)
                TempData=DataStructure(i).Data;
                TempData1=[];
                for j=1:length(TempData)
                    TempData1(j)=TempData{j};
                end
                DataStructure(i).Data=TempData1;
                clear TempData TempData1
            end        
        end
        Count=0;
        clear DataStructure1
        for i=1:length(DataStructure)
            if ~isempty(DataStructure(i).Data)
                Count=Count+1;
                DataStructure1(Count).Data=DataStructure(i).Data;
                DataStructure1(Count).Label=DataStructure(i).Label;
            else
                warning(['NO DATA in Category ',num2str(i)])
            end
        end
        DataStructure=DataStructure1;
        clear DataStructure1
        if ~isfield(DataStructure,'Count')
            for i=1:length(DataStructure)
                if size(DataStructure(i).Data,1)>size(DataStructure(i).Data,2)
                    DataStructure(i).Count=size(DataStructure(i).Data,1);
                    %DataStructure(i).Data=DataStructure(i).Data';
                else
                    DataStructure(i).Count=size(DataStructure(i).Data,2);
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        GoodData=1;
        for i=1:length(DataStructure)
            if DataStructure(i).Count<2
                warning(['Data Category #',num2str(i),' does not have enough datapoints for statistical tests...'])
                GoodData=0;
            end
        end
        if GoodData
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            AllStatTests.Statistical_Comparison_Label=Statistical_Comparison_Label;
            for i=1:length(DataStructure)
                AllStatTests.GroupNames{i}=DataStructure(i).Label;
                [AllStatTests.BasicStats{i}]=VectorStats(DataStructure(i).Data,2,[],[]);
                DataStructure(i).BasicStats=AllStatTests.BasicStats{i};
            end
            if ~exist(StatisticsSaveDir)
                mkdir(StatisticsSaveDir)
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ContainsData=0;
            for i=1:length(DataStructure)
                if any(~isnan(DataStructure(i).Data))
                    ContainsData=1;
                end
            end
            if ContainsData
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if length(DataStructure)>2
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %ANOVA Test with Post Hoc
                    AllStatTests.ANOVA.Label=[Statistical_Comparison_Label,' ANOVA'];
                    disp(AllStatTests.ANOVA.Label)
                    [AllStatTests.ANOVA]=...
                        ANOVA_Post_Hoc(DataStructure,AnovaPostHoc_alpha,DisplayChoice,DisplayTables,ANOVA_Mode,ExportAllResults,...
                        Statistical_Comparison_Label,StatisticsSaveDir);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Kruskal-Wallis Test with Post Hoc
                    AllStatTests.KW.Label=[Statistical_Comparison_Label,' Kruskal-Wallis'];
                    disp(AllStatTests.KW.Label)
                    [AllStatTests.KW]=...
                        KW_Post_Hoc(DataStructure,AnovaPostHoc_alpha,DisplayChoice,DisplayTables,ExportAllResults,...
                        Statistical_Comparison_Label,StatisticsSaveDir);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                elseif length(DataStructure)==2
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %ANOVA Tests with Post Hoc
                    AllStatTests.ANOVA.Label=[Statistical_Comparison_Label,' ANOVA'];
                    disp(AllStatTests.ANOVA.Label)
                    [   AllStatTests.ANOVA]=...
                        ANOVA_Post_Hoc(DataStructure,AnovaPostHoc_alpha,DisplayChoice,DisplayTables,ANOVA_Mode,ExportAllResults,...
                        Statistical_Comparison_Label,StatisticsSaveDir);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Kruskal-Wallis Test with Post Hoc
                    AllStatTests.KW.Label=[Statistical_Comparison_Label,' KW'];
                    disp(AllStatTests.KW.Label)
                    [AllStatTests.KW]=...
                        KW_Post_Hoc(DataStructure,AnovaPostHoc_alpha,DisplayChoice,DisplayTables,ExportAllResults,...
                        Statistical_Comparison_Label,StatisticsSaveDir);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if DataStructure(1).Count==DataStructure(2).Count
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %TTest Paired
                        AllStatTests.pTT.Label=[Statistical_Comparison_Label,' Paired Students T-Test'];
                        [   AllStatTests.pTT.h,...
                            AllStatTests.pTT.p,...
                            AllStatTests.pTT.ci,...
                            AllStatTests.pTT.stats] = ...
                            ttest( DataStructure(1).Data,...
                                    DataStructure(2).Data);
                            AllStatTests.pTT.Result_Text=[AllStatTests.pTT.Label,' p = ',num2str(AllStatTests.pTT.p)];
                            if DisplayResults
                                disp(AllStatTests.pTT.Result_Text);
                            end
                            if ExportAllResults
                                StatsTableExporterFull(AllStatTests.BasicStats,[],AllStatTests.pTT.p,AllStatTests.GroupNames,AllStatTests.pTT.Label,StatisticsSaveDir)
                            end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %Wilcoxon signed rank test
                            AllStatTests.WSR.Label=[Statistical_Comparison_Label,' Wilcoxon Signed Rank Test'];
                        [   AllStatTests.WSR.p,...
                            AllStatTests.WSR.h,...
                            AllStatTests.WSR.stats] = ...
                            signrank(DataStructure(1).Data,...
                                    DataStructure(2).Data);
                            AllStatTests.WSR.Result_Text=[AllStatTests.WSR.Label,' p = ',num2str(AllStatTests.WSR.p)];
                            if DisplayResults
                                disp(AllStatTests.WSR.Result_Text);
                            end
                            if ExportAllResults
                                StatsTableExporterFull(AllStatTests.BasicStats,[],AllStatTests.WSR.p,AllStatTests.GroupNames,AllStatTests.WSR.Label,StatisticsSaveDir)
                            end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %TTest Unpaired
                        AllStatTests.upTT.Label=[Statistical_Comparison_Label,' Unpaired Students T-Test'];
                    [   AllStatTests.upTT.h,...
                        AllStatTests.upTT.p,...
                        AllStatTests.upTT.ci,...
                        AllStatTests.upTT.stats] = ...
                        ttest2( DataStructure(1).Data,...
                                DataStructure(2).Data);
                        AllStatTests.upTT.Result_Text=[AllStatTests.upTT.Label,' p = ',num2str(AllStatTests.upTT.p)];
                        if DisplayResults
                            disp(AllStatTests.upTT.Result_Text);
                        end
                        if ExportAllResults
                            StatsTableExporterFull(AllStatTests.BasicStats,[],AllStatTests.upTT.p,AllStatTests.GroupNames,AllStatTests.upTT.Label,StatisticsSaveDir)
                        end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Kolmogorov–Smirnov Test
                        AllStatTests.KS2.Label=[Statistical_Comparison_Label,' Two-Sample Kolmogorov–Smirnov Test'];
                    [   AllStatTests.KS2.h,...
                        AllStatTests.KS2.p,...
                        AllStatTests.KS2.ks2stat] = ...
                        kstest2(DataStructure(1).Data,...
                                DataStructure(2).Data);
                        AllStatTests.KS2.Result_Text=[AllStatTests.KS2.Label,' p = ',num2str(AllStatTests.KS2.p)];
                        if DisplayResults
                            disp(AllStatTests.KS2.Result_Text);
                        end
                        if ExportAllResults
                            StatsTableExporterFull(AllStatTests.BasicStats,[],AllStatTests.KS2.p,AllStatTests.GroupNames,AllStatTests.KS2.Label,StatisticsSaveDir)
                        end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Cramer von Mises Test
                        AllStatTests.CvM.Label=[Statistical_Comparison_Label,' Two-Sample Cramer von Mises Test'];
                    [   AllStatTests.CvM.h,...
                        AllStatTests.CvM.p,...
                        AllStatTests.CvM.cmstat] = ...
                        cmtest2(DataStructure(1).Data,...
                                DataStructure(2).Data);
                        AllStatTests.CvM.Result_Text=[AllStatTests.CvM.Label,' p = ',num2str(AllStatTests.CvM.p)];
                        if DisplayResults
                            disp(AllStatTests.CvM.Result_Text);
                        end
                        if ExportAllResults
                            StatsTableExporterFull(AllStatTests.BasicStats,[],AllStatTests.CvM.p,AllStatTests.GroupNames,AllStatTests.CvM.Label,StatisticsSaveDir)
                        end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Mann-Whitney U Test or Wilcoxon Rank Sum
                        AllStatTests.MWU.Label=[Statistical_Comparison_Label,' Two-Sample Mann-Whitney U Test'];
                    [   AllStatTests.MWU.p,...
                        AllStatTests.MWU.h,...
                        AllStatTests.MWU.stats] = ...
                        ranksum(DataStructure(1).Data,...
                                DataStructure(2).Data);
                        AllStatTests.MWU.Result_Text=[AllStatTests.MWU.Label,' p = ',num2str(AllStatTests.MWU.p)];
                        if DisplayResults
                            disp(AllStatTests.MWU.Result_Text);
                        end
                        if ExportAllResults
                            StatsTableExporterFull(AllStatTests.BasicStats,[],AllStatTests.MWU.p,AllStatTests.GroupNames,AllStatTests.MWU.Label,StatisticsSaveDir)
                        end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                else
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for i=1:length(DataStructure)
                    %Kolmogorov–Smirnov Test
                        AllStatTests.KS(i).Label=[DataStructure(i).Label,' Kolmogorov–Smirnov Test'];
                    [   AllStatTests.KS(i).h,...
                        AllStatTests.KS(i).p,...
                        AllStatTests.KS(i).ksstat,...
                        AllStatTests.KS(i).cv] = ...
                        kstest(DataStructure(i).Data);
                        AllStatTests.KS(i).Result_Text=[AllStatTests.KS(i).Label,' p = ',num2str(AllStatTests.KS(i).p)];
                        if DisplayResults
                            disp(AllStatTests.KS(i).Result_Text);
                        end
                        if ExportAllResults
                            StatsTableExporterFull(AllStatTests.BasicStats{i},[],AllStatTests.KS(i).p,{AllStatTests.GroupNames{i}},AllStatTests.KS(i).Label,StatisticsSaveDir)
                        end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                warning on
                warning('NO DATA FOUND IN STRUCTURE!')
                warning('NO DATA FOUND IN STRUCTURE!')
                warning('NO DATA FOUND IN STRUCTURE!')
                warning('NO DATA FOUND IN STRUCTURE!')
                AllStatTests=[];
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        else
            AllStatTests=[];
        end
    else
       warning('Please Provide Data into DataStructure') 
       AllStatTests=[];
    end
end