function [KW_Result]=KW_Post_Hoc(DataStructure,KWPostHoc_alpha,DisplayChoice,DisplayTables,ExportTables,TestName,SaveDir)

    %Kruskal-Wallis Tests

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

        ForKW_Data=[];
        ForKW_Labels=[];
        ForKW_GroupLabels{i}=[];
        Count=0;
        %Compile data
        for i=1:length(DataStructure)
            if size(DataStructure(i).Data,1)==1
                ForKW_Data=vertcat(ForKW_Data,DataStructure(i).Data');
            else
                ForKW_Data=vertcat(ForKW_Data,DataStructure(i).Data);
            end
            ForKW_GroupLabels{i}=DataStructure(i).Label;
            for j=1:DataStructure(i).Count
                Count=Count+1;
                ForKW_Labels{Count,1}=DataStructure(i).Label;
            end
        end

        [   KW_Result.KW_p,...
            KW_Result.KW_Table,...
            KW_Result.KW_Stats]=...
            kruskalwallis(...
            ForKW_Data,ForKW_Labels,'off');


        if strcmp(DisplayChoice,'on'); figure;end
        [   KW_Result.KW_PostHoc_Bon_c,...
            KW_Result.KW_PostHoc_Bon_m,...
            h,...
            KW_Result.KW_PostHoc_Bon_nms] = ...
            multcompare_ZN(...
            KW_Result.KW_Stats,...
            'alpha',KWPostHoc_alpha,...
            'ctype','bonferroni','display',DisplayChoice);
        if strcmp(DisplayChoice,'on'); set(h,'name','Bonferroni');end

        KW_Result.KW_PostHoc_Bon_p=...
            PostHoc_P_Value_Table_Compiler(KW_Result.KW_PostHoc_Bon_c);
        if strcmp(DisplayTables,'on')
            disp('Kruskal-Wallis with Bonferroni P-Values:')
            disp([num2str(round(KW_Result.KW_PostHoc_Bon_p*10000)/10000)])
        end

        if strcmp(DisplayChoice,'on'); figure;end
        [   KW_Result.KW_PostHoc_Tuk_c,...
            KW_Result.KW_PostHoc_Tuk_m,...
            h, KW_Result.KW_PostHoc_Tuk_nms] = ...
            multcompare_ZN(...
            KW_Result.KW_Stats,...
            'alpha',KWPostHoc_alpha,...
            'ctype','tukey-kramer','display',DisplayChoice);
        if strcmp(DisplayChoice,'on'); set(h,'name','Tukey');end
        KW_Result.KW_PostHoc_Tuk_p=...
            PostHoc_P_Value_Table_Compiler(KW_Result.KW_PostHoc_Tuk_c);

        if strcmp(DisplayTables,'on')
            disp('Kruskal-Wallis with Tukeys P-Values:')
            disp([num2str(round(KW_Result.KW_PostHoc_Tuk_p*10000)/10000)])
        end
        if ExportTables
            if isfield(DataStructure,'BasicStats')
                for i=1:length(DataStructure)
                    BasicStats{i}=DataStructure(i).BasicStats;
                end
                StatsTableExporterFull(BasicStats,KW_Result.KW_PostHoc_Tuk_p,KW_Result.KW_p,ForKW_GroupLabels,[TestName,' Kruskal-Wallis with Tukeys'],SaveDir)

                StatsTableExporterFull(BasicStats,KW_Result.KW_PostHoc_Bon_p,KW_Result.KW_p,ForKW_GroupLabels,[TestName,' Kruskal-Wallis with Bonferroni'],SaveDir)
            
            else
            
                StatsTableExporter(KW_Result.KW_PostHoc_Tuk_p,KW_Result.KW_p,ForKW_GroupLabels,[TestName,' Kruskal-Wallis with Tukeys'],SaveDir)

                StatsTableExporter(KW_Result.KW_PostHoc_Bon_p,KW_Result.KW_p,ForKW_GroupLabels,[TestName,' Kruskal-Wallis with Bonferroni'],SaveDir)
            
            end
        end
    else
       warning('Not enough data to complete Kruskal-Wallis!') 
        
    end
end