function [ANOVA_Results]=ANOVA_Post_Hoc(DataStructure,AnovaPostHoc_alpha,DisplayChoice,DisplayTables,ANOVA_Mode,ExportTables,TestName,SaveDir)

    if ~exist('ANOVA_Mode')
        ANOVA_Mode=[];
    end
    if isempty(ANOVA_Mode)
        error('Need to Define ANOVA MODE 1 = One-way 2 = Two-Way 3 = N-Way ANOVA')
    end
    %ANOVA Tests
    if length(DataStructure)>1
        %first find largest DataSet
        MaxNumEntries=0;
        for i=1:length(DataStructure) 
            if strcmp(DisplayTables,'on')
                disp(DataStructure(i).Label)
                disp(['n = ',num2str(DataStructure(i).Count)])
            end
            MaxNumEntries=max([MaxNumEntries,DataStructure(i).Count]);
        end
        EmptyArray=zeros(MaxNumEntries,length(DataStructure));
        EmptyArray(EmptyArray==0)=NaN;

        ANOVA_Results.ANOVA_Result=[];
        ANOVA_Results.ANOVA2_Result=[];
        ANOVA_Results.ANOVAn_Result=[];
        
        ForANOVA_Data=EmptyArray;
        ForANOVAn_Data=[];
        ForANOVAn_Labels=[];
        Count=0;
        %Compile data
        for i=1:length(DataStructure)
            if size(DataStructure(i).Data,1)==1
                ForANOVA_Data(1:DataStructure(i).Count,i)=DataStructure(i).Data';
                ForANOVAn_Data=vertcat(ForANOVAn_Data,DataStructure(i).Data');
            else
                ForANOVA_Data(1:DataStructure(i).Count,i)=DataStructure(i).Data;
                ForANOVAn_Data=vertcat(ForANOVAn_Data,DataStructure(i).Data);
            end
            ForANOVA_Labels{i}=DataStructure(i).Label;
            for j=1:DataStructure(i).Count
                Count=Count+1;
                ForANOVAn_Labels{Count,1}=DataStructure(i).Label;
            end
        end

        if any(ANOVA_Mode==1)
            disp('Running One-Way ANOVA...');
            try
                [   ANOVA_Result.ANOVA_p,...
                    ANOVA_Result.ANOVA_Table,...
                    ANOVA_Result.ANOVA_Stats]=...
                    anova1(...
                    ForANOVA_Data,ForANOVA_Labels,'off');

                if strcmp(DisplayChoice,'on'); figure;end


                [   ANOVA_Result.ANOVA_PostHoc_Bon_c,...
                    ANOVA_Result.ANOVA_PostHoc_Bon_m,...
                    h,...
                    ANOVA_Result.ANOVA_PostHoc_Bon_nms] = ...
                    multcompare_ZN(...
                    ANOVA_Result.ANOVA_Stats,...
                    'alpha',AnovaPostHoc_alpha,...
                    'ctype','bonferroni','display',DisplayChoice);
                if strcmp(DisplayChoice,'on'); set(h,'name','Bonferroni');end

                ANOVA_Result.ANOVA_PostHoc_Bon_p=...
                    PostHoc_P_Value_Table_Compiler(ANOVA_Result.ANOVA_PostHoc_Bon_c);
                if strcmp(DisplayTables,'on')
                    disp('One-way ANOVA with Bonferroni P-Values:')
                    disp([num2str(round(ANOVA_Result.ANOVA_PostHoc_Bon_p*10000)/10000)])
                end

                if strcmp(DisplayChoice,'on'); figure;end
                [   ANOVA_Result.ANOVA_PostHoc_Tuk_c,...
                    ANOVA_Result.ANOVA_PostHoc_Tuk_m,...
                    h, ANOVA_Result.ANOVA_PostHoc_Tuk_nms] = ...
                    multcompare_ZN(...
                    ANOVA_Result.ANOVA_Stats,...
                    'alpha',AnovaPostHoc_alpha,...
                    'ctype','tukey-kramer','display',DisplayChoice);
                if strcmp(DisplayChoice,'on'); set(h,'name','Tukey');end
                ANOVA_Result.ANOVA_PostHoc_Tuk_p=...
                    PostHoc_P_Value_Table_Compiler(ANOVA_Result.ANOVA_PostHoc_Tuk_c);

                if strcmp(DisplayTables,'on')
                    disp('One-way ANOVA with Tukeys P-Values:')
                    disp([num2str(round(ANOVA_Result.ANOVA_PostHoc_Tuk_p*10000)/10000)])
                end

                if ExportTables
                    if isfield(DataStructure,'BasicStats')
                        for i=1:length(DataStructure)
                            BasicStats{i}=DataStructure(i).BasicStats;
                        end
                        StatsTableExporterFull(BasicStats,ANOVA_Result.ANOVA_PostHoc_Tuk_p,ANOVA_Result.ANOVA_p,ForANOVA_Labels,[TestName,' ANOVA with Tukeys'],SaveDir)

                        StatsTableExporterFull(BasicStats,ANOVA_Result.ANOVA_PostHoc_Bon_p,ANOVA_Result.ANOVA_p,ForANOVA_Labels,[TestName,' ANOVA with Bonferroni'],SaveDir)

                    else

                        StatsTableExporter(ANOVA_Result.ANOVA_PostHoc_Tuk_p,ANOVA_Result.ANOVA_p,ForANOVA_Labels,[TestName,' ANOVA with Tukeys'],SaveDir)

                        StatsTableExporter(ANOVA_Result.ANOVA_PostHoc_Bon_p,ANOVA_Result.ANOVA_p,ForANOVA_Labels,[TestName,' ANOVA with Bonferroni'],SaveDir)

                    end
                end            

                ANOVA_Results.ANOVA_Result=ANOVA_Result;
            catch
                warning('One-Way ANOVA FAILED!');
            end
        end
        if any(ANOVA_Mode==2)
            disp('Running Two-Way ANOVA...');
            try
                [   ANOVA2_Result.ANOVA_p,...
                    ANOVA2_Result.ANOVA_Table,...
                    ANOVA2_Result.ANOVA_Stats]=...
                    anova2(...
                    ForANOVAn_Data,ForANOVA_Labels,'off');

                if strcmp(DisplayChoice,'on'); figure;end


                [   ANOVA2_Result.ANOVA_PostHoc_Bon_c,...
                    ANOVA2_Result.ANOVA_PostHoc_Bon_m,...
                    h,...
                    ANOVA2_Result.ANOVA_PostHoc_Bon_nms] = ...
                    multcompare_ZN(...
                    ANOVA2_Result.ANOVA_Stats,...
                    'alpha',AnovaPostHoc_alpha,...
                    'ctype','bonferroni','display',DisplayChoice);
                if strcmp(DisplayChoice,'on'); set(h,'name','Bonferroni');end

                ANOVA2_Result.ANOVA_PostHoc_Bon_p=...
                    PostHoc_P_Value_Table_Compiler(ANOVA2_Result.ANOVA_PostHoc_Bon_c);
                if strcmp(DisplayTables,'on')
                    disp('Two-Way ANOVA with Bonferroni P-Values:')
                    disp([num2str(round(ANOVA2_Result.ANOVA_PostHoc_Bon_p*10000)/10000)])
                end

                if strcmp(DisplayChoice,'on'); figure;end
                [   ANOVA2_Result.ANOVA_PostHoc_Tuk_c,...
                    ANOVA2_Result.ANOVA_PostHoc_Tuk_m,...
                    h, ANOVA2_Result.ANOVA_PostHoc_Tuk_nms] = ...
                    multcompare_ZN(...
                    ANOVA2_Result.ANOVA_Stats,...
                    'alpha',AnovaPostHoc_alpha,...
                    'ctype','tukey-kramer','display',DisplayChoice);
                if strcmp(DisplayChoice,'on'); set(h,'name','Tukey');end
                ANOVA2_Result.ANOVA_PostHoc_Tuk_p=...
                    PostHoc_P_Value_Table_Compiler(ANOVA2_Result.ANOVA_PostHoc_Tuk_c);

                if strcmp(DisplayTables,'on')
                    disp('Two-Way with Tukeys P-Values:')
                    disp([num2str(round(ANOVA2_Result.ANOVA_PostHoc_Tuk_p*10000)/10000)])
                end

                if ExportTables
                    if isfield(DataStructure,'BasicStats')
                        for i=1:length(DataStructure)
                            BasicStats{i}=DataStructure(i).BasicStats;
                        end
                        StatsTableExporterFull(BasicStats,ANOVA2_Result.ANOVA_PostHoc_Tuk_p,ANOVA2_Result.ANOVA_p,ForANOVA_Labels,[TestName,' Two-Way ANOVA with Tukeys'],SaveDir)

                        StatsTableExporterFull(BasicStats,ANOVA2_Result.ANOVA_PostHoc_Bon_p,ANOVA2_Result.ANOVA_p,ForANOVA_Labels,[TestName,' Two-Way ANOVA with Bonferroni'],SaveDir)

                    else

                        StatsTableExporter(ANOVA2_Result.ANOVA_PostHoc_Tuk_p,ANOVA2_Result.ANOVA_p,ForANOVA_Labels,[TestName,' Two-Way ANOVA with Tukeys'],SaveDir)

                        StatsTableExporter(ANOVA2_Result.ANOVA_PostHoc_Bon_p,ANOVA2_Result.ANOVA_p,ForANOVA_Labels,[TestName,' Two-Way ANOVA with Bonferroni'],SaveDir)

                    end
                end

                ANOVA_Results.ANOVA2_Result=ANOVA2_Result;
            catch
                warning('Two-Way ANOVA FAILED!');
            end
        end
        if any(ANOVA_Mode==3)
            disp('Running n-Way ANOVA...');
            try
                [   ANOVAn_Result.ANOVA_p,...
                    ANOVAn_Result.ANOVA_Table,...
                    ANOVAn_Result.ANOVA_Stats,~]=...
                    anovan(...
                    ForANOVAn_Data,ForANOVAn_Labels);
                if strcmp(DisplayChoice,'on'); figure;end


                [   ANOVAn_Result.ANOVA_PostHoc_Bon_c,...
                    ANOVAn_Result.ANOVA_PostHoc_Bon_m,...
                    h,...
                    ANOVAn_Result.ANOVA_PostHoc_Bon_nms] = ...
                    multcompare_ZN(...
                    ANOVAn_Result.ANOVA_Stats,...
                    'alpha',AnovaPostHoc_alpha,...
                    'ctype','bonferroni','display',DisplayChoice);
                if strcmp(DisplayChoice,'on'); set(h,'name','Bonferroni');end

                ANOVAn_Result.ANOVA_PostHoc_Bon_p=...
                    PostHoc_P_Value_Table_Compiler(ANOVAn_Result.ANOVA_PostHoc_Bon_c);
                if strcmp(DisplayTables,'on')
                    disp('n-Way ANOVA with Bonferroni P-Values:')
                    disp([num2str(round(ANOVAn_Result.ANOVA_PostHoc_Bon_p*10000)/10000)])
                end

                if strcmp(DisplayChoice,'on'); figure;end
                [   ANOVAn_Result.ANOVA_PostHoc_Tuk_c,...
                    ANOVAn_Result.ANOVA_PostHoc_Tuk_m,...
                    h, ANOVAn_Result.ANOVA_PostHoc_Tuk_nms] = ...
                    multcompare_ZN(...
                    ANOVAn_Result.ANOVA_Stats,...
                    'alpha',AnovaPostHoc_alpha,...
                    'ctype','tukey-kramer','display',DisplayChoice);
                if strcmp(DisplayChoice,'on'); set(h,'name','Tukey');end
                ANOVAn_Result.ANOVA_PostHoc_Tuk_p=...
                    PostHoc_P_Value_Table_Compiler(ANOVAn_Result.ANOVA_PostHoc_Tuk_c);

                if strcmp(DisplayTables,'on')
                    disp('n-Way with Tukeys P-Values:')
                    disp([num2str(round(ANOVAn_Result.ANOVA_PostHoc_Tuk_p*10000)/10000)])
                end

                if ExportTables
                    if isfield(DataStructure,'BasicStats')
                        for i=1:length(DataStructure)
                            BasicStats{i}=DataStructure(i).BasicStats;
                        end
                        StatsTableExporterFull(BasicStats,ANOVAn_Result.ANOVA_PostHoc_Tuk_p,ANOVAn_Result.ANOVA_p,ForANOVA_Labels,[TestName,' n-Way ANOVA with Tukeys'],SaveDir)

                        StatsTableExporterFull(BasicStats,ANOVAn_Result.ANOVA_PostHoc_Bon_p,ANOVAn_Result.ANOVA_p,ForANOVA_Labels,[TestName,' n-Way ANOVA with Bonferroni'],SaveDir)

                    else

                        StatsTableExporter(ANOVAn_Result.ANOVA_PostHoc_Tuk_p,ANOVAn_Result.ANOVA_p,ForANOVA_Labels,[TestName,' n-Way ANOVA with Tukeys'],SaveDir)

                        StatsTableExporter(ANOVAn_Result.ANOVA_PostHoc_Bon_p,ANOVAn_Result.ANOVA_p,ForANOVA_Labels,[TestName,' n-Way ANOVA with Bonferroni'],SaveDir)

                    end
                end            
                ANOVA_Results.ANOVAn_Result=ANOVAn_Result;
            catch
                warning('n-Way ANOVA FAILED!');
            end
        end


    else
       warning('Not enough data to complete ANOVA!') 
        
    end
end