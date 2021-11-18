function [Summary]=SummaryStats(InputData,varargin)
    %Summary=SummaryStats(InputData,Dimension,Bin_Range,Bin_Size,SaveName,SaveDir)
    if ~isempty(InputData)
        nin = nargin;
        if nin == 2
            Dimension=varargin{1};
        elseif nin == 3
            Dimension=varargin{1};
            Bin_Range=varargin{2};
        elseif nin == 4
            Dimension=varargin{1};
            Bin_Range=varargin{2};
            Bin_Size=varargin{3};
        elseif nin == 5
            Dimension=varargin{1};
            Bin_Range=varargin{2};
            Bin_Size=varargin{3};
            SaveName=varargin{4};
        elseif nin == 6
            Dimension=varargin{1};
            Bin_Range=varargin{2};
            Bin_Size=varargin{3};
            SaveName=varargin{4};
            SaveDir=varargin{5};
        end
        if ~exist('Dimension')
            Dimension=[];
        end
        if ~exist('Bin_Range')
            Bin_Range=[];
        end
        if ~exist('Bin_Size')
            Bin_Size=[];
        end
        if ~exist('SaveName')
            SaveName=[];
        end
        if ~exist('SaveDir')&&~isempty(SaveName)
            SaveDir=cd;
        elseif ~exist('SaveDir')&&isempty(SaveName)
            SaveDir=[];
        end
        if ~strcmp(class(InputData),'double')
            InputData=double(InputData);
        end
        Summary.InputDataSize=size(InputData);
        if ~isempty(Dimension)
            Summary.Dimension=Dimension;
        else
            if isempty(Dimension)&&length(Summary.InputDataSize)==2&&any(Summary.InputDataSize==1)
                Summary.Dimension=find(Summary.InputDataSize~=1);
            else
                error('Must define Dimension for analysis...')
            end
        end
        Summary.Bin_Range=Bin_Range;
        Summary.Bin_Size=Bin_Size;

        if any(InputData==Inf)
            warning on
            warning('Removing Inf values!')
            InputData(InputData==Inf)=NaN;
        end

        if any(~isnan(InputData))
            if any(isnan(InputData(:)))
                Summary.Mean=nanmean(InputData,Summary.Dimension);
                Summary.STD=nanstd(InputData,0,Summary.Dimension);
                Summary.Num=sum(~isnan(InputData));
                Summary.SEM=Summary.STD/sqrt(Summary.Num);
                Summary.CV=Summary.STD/Summary.Mean;
                Summary.Max=max(InputData,[],Summary.Dimension);
                Summary.Min=min(InputData,[],Summary.Dimension);
                Summary.Median=nanmedian(InputData,Summary.Dimension);
                Summary.Sum=sum(InputData(:));
            else
                Summary.Mean=mean(InputData,Summary.Dimension);
                Summary.STD=std(InputData,0,Summary.Dimension);
                Summary.Num=size(InputData,Summary.Dimension);
                Summary.SEM=Summary.STD/sqrt(Summary.Num);
                Summary.CV=Summary.STD/Summary.Mean;
                Summary.Max=max(InputData,[],Summary.Dimension);
                Summary.Min=min(InputData,[],Summary.Dimension);
                Summary.Median=median(InputData,Summary.Dimension);
                Summary.Sum=sum(InputData(:));
            end

            if isempty(Summary.Bin_Range)

                Summary.RangeCoverage=abs(Summary.Max-Summary.Min);

                if Summary.Min<0&&Summary.RangeCoverage>10
                    Summary.MinBin=floor(Summary.Min);
                elseif Summary.Min<0
                    Summary.MinBin=floor(Summary.Min*100)/100;
                else
                    Summary.MinBin=0;
                end
                if Summary.RangeCoverage>10
                    Summary.MaxBin=ceil(Summary.Max);
                else
                    Summary.MaxBin=ceil(Summary.Max*100)/100;
                end
                Summary.Bin_Range=[Summary.MinBin,Summary.MaxBin];

            end
            if isempty(Summary.Bin_Size)
                Summary.Bin_Size=abs(Summary.Bin_Range(2)-Summary.Bin_Range(1))/100;
            end
            if Summary.Bin_Size>max(abs(Summary.Bin_Range))
                error('Bins are larger than range!')
            end
            Summary.Bin_Edges=[Summary.Bin_Range(1):Summary.Bin_Size:Summary.Bin_Range(2)];
            Summary.Num_Bins=length(Summary.Bin_Edges)-1;
            for Bin=1:Summary.Num_Bins
                if Bin<Summary.Num_Bins
                    Summary.Bin_Labels{Bin}=[num2str(Summary.Bin_Edges(Bin)),'<=x<',num2str(Summary.Bin_Edges(Bin+1))];
                else
                    Summary.Bin_Labels{Bin}=[num2str(Summary.Bin_Edges(Bin)),'<=x<=',num2str(Summary.Bin_Edges(Bin+1))];
                end
                Summary.Bin_Centers(Bin)=(Summary.Bin_Edges(Bin+1)-Summary.Bin_Edges(Bin))/2+Summary.Bin_Edges(Bin);
            end
            if length(Summary.Bin_Edges)>1
                if Summary.Dimension==2
                    HistData=InputData;
                else
                    HistData=InputData';
                end
                Summary.Histogram=histcounts(HistData,Summary.Bin_Edges);
                Summary.Normalized_Histogram=Summary.Histogram/max(Summary.Histogram);
                Summary.Cumulative_Histogram=cumsum(Summary.Histogram);
                Summary.Normalized_Cumulative_Histogram=Summary.Cumulative_Histogram/max(Summary.Cumulative_Histogram);
            else
                Summary.Num_Bins=[];
                Summary.Bin_Edges=[];
                Summary.Bin_Labels=[];
                Summary.Bin_Centers=[];

                Summary.Histogram=[];
                Summary.Normalized_Histogram=[];
                Summary.Cumulative_Histogram=[];
                Summary.Normalized_Cumulative_Histogram=[];
            end
        else
            warning on
            warning('No Non-NAN values present in data....')
            Summary.Mean=[NaN];
            Summary.STD=[NaN];
            Summary.Num=[NaN];
            Summary.SEM=[NaN];
            Summary.CV=[NaN];
            Summary.Max=[NaN];
            Summary.Min=[NaN];
            Summary.Median=[NaN];

            Summary.Num_Bins=[NaN];
            Summary.Bin_Edges=[NaN];
            Summary.Bin_Labels=[NaN];
            Summary.Bin_Centers=[NaN];

            Summary.Histogram=[NaN];
            Summary.Normalized_Histogram=[NaN];
            Summary.Cumulative_Histogram=[NaN];
            Summary.Normalized_Cumulative_Histogram=[NaN];
        end
        if ~isempty(SaveName)&&~isempty(SaveName)
            StatsTableExporterFull(Summary,[],[],{SaveName},SaveName,SaveDir)
        end
    else
       warning on
       warning('NO DATA PROVIDED!')
       Summary=[];
    end
end