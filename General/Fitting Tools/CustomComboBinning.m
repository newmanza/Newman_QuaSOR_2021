function [OutputBins UnSortedEntries,ComboMatchingInfo]=CustomComboBinning(InputVals,BinEdges)

    %Use Bin Edge of NaN to automatically include or Inf to include anyting
    %that is not 0
%     InputVals=Grouped_Measurements.Verified_Quantifications.BoutonSorted(BoutonCount).All_Binned_Data.All_STORM_Bins(STORM_Bin).STORM_Bins.SortVals
%     BinEdges=Grouped_Measurements.Verified_Quantifications.BoutonSorted(BoutonCount).All_Binned_Data.All_STORM_Bins(STORM_Bin).STORM_Bins.BinEdges
    
    NumEntries=size(InputVals,2);
    NumBins=size(BinEdges,2)-1;
    NumCats=size(BinEdges,1);
    NumMatchOptions=NumCats*NumBins;
    MatchOptions=[];
    MatchArray=zeros(NumCats,NumBins);
    MatchArray1=zeros(NumCats,NumBins);
    MatchVector=zeros(1,NumMatchOptions);
    MatchVector1=zeros(1,NumMatchOptions);
    Count=0;
    for Cat=1:NumCats
        for Bin=1:NumBins
            Count=Count+1;
            MatchArray(Cat,Bin)=Count;
            MatchVector(Count)=Count;
            MatchArray1(Cat,Bin)=Cat;
            MatchVector1(Count)=Cat;
        end
    end
    AllPermuations=perms([0:NumCats-1;0:NumBins-1]);
    %AllPermuations=flipud(AllPermuations);
    AllUniquePermuations=unique(AllPermuations,'rows');
    AllUniquePermuations=flipud(AllUniquePermuations);
    AllPossiblePerumatations=[];
    for i=1:size(AllUniquePermuations,1)
        TempRow=logical(AllUniquePermuations(i,:));
        TempCats=MatchVector1(TempRow);
        if length(unique(TempCats))==NumCats
            AllPossiblePerumatations=vertcat(AllPossiblePerumatations,TempRow);
        end
    end
    for i=1:size(AllPossiblePerumatations,1)
        TempRow=logical(AllPossiblePerumatations(i,:));
        MatchOptions(i).MatchArray=zeros(NumCats,NumBins);
        TempPos=MatchVector(TempRow);
        for j=1:length(TempPos)
            TempArray=MatchArray==TempPos(j);
            MatchOptions(i).MatchArray=MatchOptions(i).MatchArray+TempArray;
        end
    end
    ComboMatchingInfo.MatchArray=MatchArray;
    ComboMatchingInfo.MatchArray1=MatchArray1;
    ComboMatchingInfo.MatchVector=MatchVector;
    ComboMatchingInfo.MatchVector1=MatchVector1;
    ComboMatchingInfo.AllPossiblePerumatations=AllPossiblePerumatations;
    ComboMatchingInfo.MatchOptions=MatchOptions;
    
%     for i=1:size(AllPossiblePerumatations,1)
%         MatchOptions(i).MatchArray
%     end
    OutputBins=zeros(1,NumEntries);
    OutputBins(OutputBins==0)=NaN;
    UnSortedEntries=[];
    fprintf(['Binning ',num2str(NumEntries),' Entries into ',num2str(NumBins),' Bins According to ',num2str(NumCats),' Metrics...']);
    for i=1:NumEntries
        CurrentVals=InputVals(:,i);
        if any(~isnan(CurrentVals))
            GoodMatch=zeros(NumCats,NumBins);
            for Cat=1:NumCats
                for Bin=1:NumBins
                    if isinf(BinEdges(Cat,Bin))||isinf(BinEdges(Cat,Bin+1))
                        if CurrentVals(Cat,1)~=0
                            GoodMatch(Cat,Bin)=1;
                        end
                    elseif isnan(BinEdges(Cat,Bin))||isnan(BinEdges(Cat,Bin+1))
                        GoodMatch(Cat,1)=1;
                    else
                        if BinEdges(Cat,Bin)==BinEdges(Cat,Bin+1)
                            if CurrentVals(Cat,1)==BinEdges(Cat,Bin)
                                GoodMatch(Cat,Bin)=1;
                            end
                        else
                            if Bin<NumBins
                                if CurrentVals(Cat,1)>=BinEdges(Cat,Bin)&&...
                                        CurrentVals(Cat,1)<BinEdges(Cat,Bin+1)
                                    GoodMatch(Cat,Bin)=1;
                                end
                            else
                                if CurrentVals(Cat,1)>=BinEdges(Cat,Bin)&&...
                                        CurrentVals(Cat,1)<=BinEdges(Cat,Bin+1)
                                    GoodMatch(Cat,Bin)=1;
                                end
                            end
                        end
                    end
                end
                if ~any(~GoodMatch)
                    %CurrentBin=[CurrentBin,Bin];
                    %Matches=Matches+1;
                end
            end
        else
            CurrentBin=[NaN];
        end

        if sum(GoodMatch(:))~=NumCats
            UnSortedEntries=[UnSortedEntries,i];
        elseif sum(GoodMatch(:))==NumCats
            for j=1:size(AllPossiblePerumatations,1)
                if any(GoodMatch~=MatchOptions(j).MatchArray)
                else
                    OutputBins(i)=j;
                end
            end
        end
    end
    fprintf('Finished!\n');
    if ~isempty(UnSortedEntries)
        warning on
        warning([num2str(length(UnSortedEntries)),' Unsorted Entries!'])
    end
%     
%     for i=1:10
%         disp('========')
%         InputVals(:,i)
%         OutputBins(i)
%     end
%         BinEdges

    
end