function [Stats]=VectorStats(Data,Mode,Bin_Range,Bin_Size)
%Mode 1 All calcs including histograms
%Mode 2 just Mean STD SEM CV

    if ~isempty(Data)
        if iscell(Data)
            Data1=[];
            for i=1:length(Data)
                Data1(i)=Data{i};
            end
            Data=Data1;
            clear Data1
        end        
        if any(~isnan(Data))
            [Stats.Mean, Stats.STD, Stats.SEM, Stats.CV, Stats.Num]=Mean_STD_SEM_CV(Data);
            [Stats.Max, Stats.Min, Stats.Median]=Max_Min_Median(Data);
            if Mode>1
                Stats.Bin_Range=Bin_Range;
                Stats.Bin_Size=Bin_Size;
                [Stats.Num_Bins,Stats.Bin_Edges,Stats.Bin_Labels,Stats.Bin_Centers,Stats.Histogram,Stats.Normalized_Histogram,...
                    Stats.Cumulative_Histogram,Stats.Normalized_Cumulative_Histogram]=Multi_Histogram(Data,Bin_Range,Bin_Size);
            end
        else
            warning on
            warning('No non-NaN Data!')
            Stats.Mean=NaN;
            Stats.STD=NaN;
            Stats.SEM=NaN;
            Stats.Num=NaN;
            Stats.Max=NaN;
            Stats.Min=NaN;
            Stats.Median=NaN;
            if Mode>1
                Stats.Bin_Range=NaN;
                Stats.Bin_Size=NaN;
                Stats.Num_Bins=NaN;
                Stats.Bin_Edges=NaN;
                Stats.Bin_Labels=NaN;
                Stats.Bin_Centers=NaN;
                Stats.Histogram=NaN;
                Stats.Normalized_Histogram=NaN;
                Stats.Cumulative_Histogram=NaN;
                Stats.Normalized_Cumulative_Histogram=NaN;
            end
        end
    else
        warning on
        warning('No Data!')
        Stats.Mean=NaN;
        Stats.STD=NaN;
        Stats.SEM=NaN;
        Stats.Num=NaN;
        Stats.Max=NaN;
        Stats.Min=NaN;
        Stats.Median=NaN;
        if Mode>1
            Stats.Bin_Range=NaN;
            Stats.Bin_Size=NaN;
            Stats.Num_Bins=NaN;
            Stats.Bin_Edges=NaN;
            Stats.Bin_Labels=NaN;
            Stats.Bin_Centers=NaN;
            Stats.Histogram=NaN;
            Stats.Normalized_Histogram=NaN;
            Stats.Cumulative_Histogram=NaN;
            Stats.Normalized_Cumulative_Histogram=NaN;
        end
    end
end