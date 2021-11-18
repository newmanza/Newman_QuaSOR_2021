function [DuplicateCoords,DuplicateIndices,DuplicateCount]=DuplicateFinder(AllCoords)
    NumCoords=size(AllCoords,1);
    NumAxes=size(AllCoords,2);
    DuplicateCoords=[];
    DuplicateIndices=[];
    DuplicateCount=0;
    if NumAxes==1
        [unique1 InputIndex1 OutputIndex1] = unique(AllCoords,'first');
        Duplicate1Indices = find(not(ismember(1:numel(unique1),InputIndex1)));
        for dup=1:length(Duplicate1Indices)
            %try
                CurrentIndex=Duplicate1Indices(dup);
                for TextIndex=1:NumCoords
                    if TextIndex~=CurrentIndex
                        if AllCoords(CurrentIndex,1)==AllCoords(TextIndex,1)
                            DuplicateDuplicate=0;
                            for dup2=1:DuplicateCount
                               if DuplicateIndices(dup2,2)==CurrentIndex&&DuplicateIndices(dup2,1)==TextIndex
                                   DuplicateDuplicate=1;
                               end
                            end
                            if ~DuplicateDuplicate
                                DuplicateCount=DuplicateCount+1;
                                DuplicateIndices(DuplicateCount,:)=[CurrentIndex,TextIndex];
                                DuplicateCoords(DuplicateCount,:)=AllCoords(CurrentIndex);
                            end
                        end
                    end
                end
           % catch

            %end
        end
    elseif NumAxes==2
        %error('This format is not tested yet')
        [unique2 InputIndex2 OutputIndex2] = unique(AllCoords(:,1),'first');
        Duplicate2Indices = find(not(ismember(1:numel(unique2),InputIndex2)));
        for dup=1:length(Duplicate2Indices)
            %try
                CurrentIndex=Duplicate2Indices(dup);
                for TextIndex=1:NumCoords
                    if TextIndex~=CurrentIndex
                        if AllCoords(CurrentIndex,1)==AllCoords(TextIndex,1)&&...
                             AllCoords(CurrentIndex,2)==AllCoords(TextIndex,2)
                         DuplicateDuplicate=0;
                            for dup2=1:DuplicateCount
                               if DuplicateIndices(dup2,2)==CurrentIndex&&DuplicateIndices(dup2,1)==TextIndex
                                   DuplicateDuplicate=1;
                               end
                            end
                            if ~DuplicateDuplicate
                                DuplicateCount=DuplicateCount+1;
                                DuplicateIndices(DuplicateCount,:)=[CurrentIndex,TextIndex]
                                DuplicateCoords(DuplicateCount,:)=AllCoords(CurrentIndex,:);
                            end
                        end
                    end
                end
           % catch

            %end
        end
    elseif NumAxes==3
        [unique3 InputIndex3 OutputIndex3] = unique(AllCoords(:,1),'first');
        Duplicate3Indices = find(not(ismember(1:numel(unique3),InputIndex3)));
        for dup=1:length(Duplicate3Indices)
            %try
                CurrentIndex=Duplicate3Indices(dup);
                for TextIndex=1:NumCoords
                    if TextIndex~=CurrentIndex
                        %disp(['Current: ',num2str(AllCoords(CurrentIndex,:))])
                        %disp(['Test:    ',num2str(AllCoords(TextIndex,:))])
                         if AllCoords(CurrentIndex,1)==AllCoords(TextIndex,1)&&...
                             AllCoords(CurrentIndex,2)==AllCoords(TextIndex,2)&&...
                             AllCoords(CurrentIndex,3)==AllCoords(TextIndex,3)
                            DuplicateDuplicate=0;
                            for dup2=1:DuplicateCount
                               if DuplicateIndices(dup2,2)==CurrentIndex&&DuplicateIndices(dup2,1)==TextIndex
                                   DuplicateDuplicate=1;
                               end
                            end
                            if ~DuplicateDuplicate
                                DuplicateCount=DuplicateCount+1;
                                DuplicateIndices(DuplicateCount,:)=[CurrentIndex,TextIndex];
                                DuplicateCoords(DuplicateCount,:)=AllCoords(CurrentIndex,:);
                            end
                        end
                    end
                end
           % catch

            %end
        end
    end
end