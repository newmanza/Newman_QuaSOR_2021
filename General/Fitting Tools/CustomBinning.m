function [OutputBins UnSortedEntries]=CustomBinning(InputVals,BinEdges)

    %Use Bin Edge of NaN to automatically include or Inf to include anyting that is not 0

    if ~iscell(BinEdges)
        NumEntries=size(InputVals,2);
        NumBins=size(BinEdges,2)-1;
        NumCats=size(BinEdges,1);
        OutputBins=zeros(1,NumEntries);
        OutputBins(OutputBins==0)=NaN;
        UnSortedEntries=[];
        if NumEntries>1
        fprintf(['Binning ',num2str(NumEntries),' Entries into ',num2str(NumBins),' Bins According to ',num2str(NumCats),' Metrics...']);
        end
        for i=1:NumEntries
            CurrentVals=InputVals(:,i);
            CurrentBin=[];
            Matches=0;
            if any(~isnan(CurrentVals))
                for Bin=1:NumBins
                    GoodMatch=zeros(size(InputVals,1),1);
                    for Cat=1:NumCats
                        if isinf(BinEdges(Cat,Bin))||isinf(BinEdges(Cat,Bin+1))
                            if CurrentVals(Cat,1)~=0
                                GoodMatch(Cat,1)=1;
                            end
                        elseif isnan(BinEdges(Cat,Bin))||isnan(BinEdges(Cat,Bin+1))
                            GoodMatch(Cat,1)=1;
                        else
                            if BinEdges(Cat,Bin)==BinEdges(Cat,Bin+1)
                                if CurrentVals(Cat,1)==BinEdges(Cat,Bin)
                                    GoodMatch(Cat,1)=1;
                                end
                            else
                                if Bin<NumBins
                                    if CurrentVals(Cat,1)>=BinEdges(Cat,Bin)&&...
                                            CurrentVals(Cat,1)<BinEdges(Cat,Bin+1)
                                        GoodMatch(Cat,1)=1;
                                    end
                                else
                                    if CurrentVals(Cat,1)>=BinEdges(Cat,Bin)&&...
                                            CurrentVals(Cat,1)<=BinEdges(Cat,Bin+1)
                                        GoodMatch(Cat,1)=1;
                                    end
                                end
                            end
                        end
                    end
                    if ~any(~GoodMatch)
                        CurrentBin=[CurrentBin,Bin];
                        Matches=Matches+1;
                    end
                end
            else
                CurrentBin=[NaN];
            end
            if (isempty(CurrentBin)&&Matches~=1)||(isnan(CurrentBin)&&Matches~=1)
                UnSortedEntries=[UnSortedEntries,i];
            elseif ~isnan(CurrentBin)&&Matches~=1
                OutputBins(i)=CurrentBin(1);
            else
                OutputBins(i)=CurrentBin(1);
            end
        end
        if NumEntries>1
            fprintf('Finished!\n');
        end
        if ~isempty(UnSortedEntries)
            warning on
            warning([num2str(length(UnSortedEntries)),' Unsorted Entries!'])
        end
    else
        NumEntries=size(InputVals,2);
        NumBins=size(BinEdges,2);
        NumCats=size(BinEdges{1},1);
        OutputBins=zeros(1,NumEntries);
        OutputBins(OutputBins==0)=NaN;
        UnSortedEntries=[];
        if NumEntries>1
        warning('Using Mixed Bins...')
        fprintf(['Binning ',num2str(NumEntries),' Entries into ',num2str(NumBins),' Bins According to ',num2str(NumCats),' Metrics...']);
        end
        for i=1:NumEntries
            CurrentVals=InputVals(:,i);
            CurrentBin=[];
            Matches=0;
            if any(~isnan(CurrentVals))
                for Bin=1:NumBins
                    TempBinEdges=BinEdges{Bin};
                    GoodMatch=zeros(size(InputVals,1),1);
                    for Cat=1:NumCats
                        if isinf(TempBinEdges(Cat,1))||isinf(TempBinEdges(Cat,2))
                            if CurrentVals(Cat,1)~=0
                                GoodMatch(Cat,1)=1;
                            end
                        elseif isnan(TempBinEdges(Cat,1))||isnan(TempBinEdges(Cat,2))
                            GoodMatch(Cat,1)=1;
                        else
                            if TempBinEdges(Cat,1)==TempBinEdges(Cat,2)
                                if CurrentVals(Cat,1)==TempBinEdges(Cat,1)
                                    GoodMatch(Cat,1)=1;
                                end
                            else
                                if Bin<NumBins
                                    if CurrentVals(Cat,1)>=TempBinEdges(Cat,1)&&...
                                            CurrentVals(Cat,1)<TempBinEdges(Cat,2)
                                        GoodMatch(Cat,1)=1;
                                    end
                                else
                                    if CurrentVals(Cat,1)>=TempBinEdges(Cat,1)&&...
                                            CurrentVals(Cat,1)<=TempBinEdges(Cat,2)
                                        GoodMatch(Cat,1)=1;
                                    end
                                end
                            end
                        end
                    end
                    if ~any(~GoodMatch)
                        CurrentBin=[CurrentBin,Bin];
                        Matches=Matches+1;
                    end
                end
            else
                CurrentBin=[NaN];
            end
            if isnan(CurrentBin)&&Matches~=1
                UnSortedEntries=[UnSortedEntries,i];
            elseif ~isnan(CurrentBin)&&Matches~=1
                OutputBins(i)=CurrentBin(1);
            else
                OutputBins(i)=CurrentBin(1);
            end
        end
        if NumEntries>1
        fprintf('Finished!\n');
        end
        if ~isempty(UnSortedEntries)
            warning on
            warning([num2str(length(UnSortedEntries)),' Unsorted Entries!'])
        end
    end
    
end