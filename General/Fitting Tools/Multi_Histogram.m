function [Num_Bins,Bin_Edges,Bin_Labels,Bin_Centers,Histogram,Normalized_Histogram,...
    Cumulative_Histogram,Normalized_Cumulative_Histogram]=Multi_Histogram(Data,Bin_Range,Bin_Size)
    if any(Data==Inf)
        warning on
        warning('Removing Inf values!')
        Data(Data==Inf)=NaN;
    end
    if any(~isnan(Data))

        if isempty(Bin_Range)
            if min(Data(:))<0&&abs(max(Data(:))-min(Data(:)))>10
                MinBin=floor(min(Data(:)));
            elseif min(Data(:))<0
                MinBin=floor(min(Data(:))*100)/100;
            else
                MinBin=0;
            end
            if abs(max(Data(:))-min(Data(:)))>10
                MaxBin=ceil(max(Data(:)));
            else
                MaxBin=ceil(max(Data(:))*100)/100;
            end
            Bin_Range=[MinBin,MaxBin];
           
        end
        if isempty(Bin_Size)
            Bin_Size=abs(Bin_Range(2)-Bin_Range(1))/100;
        end
        if Bin_Size>max(abs(Bin_Range))
            error('Bins are larger than range!')
        end
        Bin_Edges=[Bin_Range(1):Bin_Size:Bin_Range(2)];
        Num_Bins=length(Bin_Edges)-1;
        for Bin=1:Num_Bins
            if Bin<Num_Bins
                Bin_Labels{Bin}=[num2str(Bin_Edges(Bin)),'<=x<',num2str(Bin_Edges(Bin+1))];
            else
                Bin_Labels{Bin}=[num2str(Bin_Edges(Bin)),'<=x<=',num2str(Bin_Edges(Bin+1))];
            end
            Bin_Centers(Bin)=(Bin_Edges(Bin+1)-Bin_Edges(Bin))/2+Bin_Edges(Bin);
        end
        if length(Bin_Edges)>1
            Histogram=histcounts(Data,Bin_Edges);
            Normalized_Histogram=Histogram/max(Histogram);
            Cumulative_Histogram=cumsum(Histogram);
            Normalized_Cumulative_Histogram=Cumulative_Histogram/max(Cumulative_Histogram);
        else
            Num_Bins=[];
            Bin_Edges=[];
            Bin_Labels=[];
            Bin_Centers=[];

            Histogram=[];
            Normalized_Histogram=[];
            Cumulative_Histogram=[];
            Normalized_Cumulative_Histogram=[];
        end
    else
        warning('No Non-NAN values present in data....')
        Num_Bins=[];
        Bin_Edges=[];
        Bin_Labels=[];
        Bin_Centers=[];
        
        Histogram=[];
        Normalized_Histogram=[];
        Cumulative_Histogram=[];
        Normalized_Cumulative_Histogram=[];
    end
end