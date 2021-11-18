function StatsTableExporter(PvaluesTable,OverallPValue,GroupNames,TestName,SaveDir)

    FullLabelTableDisplay=0;

    for i=1:length(GroupNames)
        GroupNamesNumberedList{i}=[num2str(i),': ',GroupNames{i}];
        GroupNamesNumbers{i}=[num2str(i)];
    end

    if FullLabelTableDisplay
        MaxLength=14;
        for i=1:length(GroupNames)
            if length(GroupNames{i})>MaxLength
                MaxLength=length(GroupNames{i});
            end
        end
        GroupNames2=GroupNames;
        for i=1:length(GroupNames)
            if length(GroupNames{i})<MaxLength
                for j=1:MaxLength-length(GroupNames{i})
                    GroupNames2{i}=horzcat(' ',GroupNames2{i});
                end
            end
        end
        GroupNames3=GroupNames;
        for i=1:length(GroupNames)
            if length(GroupNames{i})<MaxLength
                for j=length(GroupNames{i})+1:MaxLength
                    GroupNames3{i}=horzcat(GroupNames3{i},' ');
                end
            end
        end
    else
        MaxLength=10;
%         for i=1:length(GroupNames)
%             if length(GroupNames{i})>MaxLength
%                 MaxLength=length(GroupNames{i});
%             end
%         end
        GroupNames2=GroupNamesNumbers;
        for i=1:length(GroupNames2)
            if length(GroupNames2{i})<MaxLength
                for j=1:MaxLength-length(GroupNames2{i})
                    GroupNames2{i}=horzcat(' ',GroupNames2{i});
                end
            end
        end
        GroupNames3=GroupNamesNumbers;
        for i=1:length(GroupNames3)
            if length(GroupNames3{i})<MaxLength
                for j=length(GroupNames3{i})+1:MaxLength
                    GroupNames3{i}=horzcat(GroupNames3{i},' ');
                end
            end
        end
    end
    
    for i=1:size(PvaluesTable,1)
        for j=1:size(PvaluesTable,2)
            PvaluesTable_Clean{i,j}=num2str(PvaluesTable(i,j),5);
        end
    end
    for i=1:size(PvaluesTable,1)
        for j=1:size(PvaluesTable,2)
            if length(PvaluesTable_Clean{i,j})<MaxLength
                for k=length(PvaluesTable_Clean{i,j})+1:MaxLength
                    PvaluesTable_Clean{i,j}=horzcat(PvaluesTable_Clean{i,j},' ');
                end
            elseif length(PvaluesTable_Clean{i,j})>MaxLength
                TempText=PvaluesTable_Clean{i,j};
                PvaluesTable_Clean{i,j}=TempText(1:MaxLength);
                clear TempText
            end
        end
    end
    EmptyCell=[];
    for i=1:MaxLength
        EmptyCell=horzcat(EmptyCell,' ');
    end
    for i=1:size(PvaluesTable,1)+1
        for j=1:size(PvaluesTable,2)+1
            if i==1&&j==1
                PvaluesTable_Formatted{i,j}=EmptyCell;
            elseif i==j
                PvaluesTable_Formatted{i,j}=EmptyCell;
            elseif i==1
                PvaluesTable_Formatted{i,j}=GroupNames3{j-1};
            elseif j==1
                PvaluesTable_Formatted{i,j}=GroupNames2{i-1};
            else
                PvaluesTable_Formatted{i,j}=PvaluesTable_Clean(i-1,j-1);
            end
        end
    end
    for i=1:size(PvaluesTable,1)+1
        for j=1:size(PvaluesTable,2)+1
            if i==1&&j==1
                PvaluesTable_Formatted_Labels{i,j}=EmptyCell;
            elseif i==j
                PvaluesTable_Formatted_Labels{i,j}=EmptyCell;
            elseif i==1
                PvaluesTable_Formatted_Labels{i,j}=GroupNames3{j-1};
            elseif j==1
                PvaluesTable_Formatted_Labels{i,j}=GroupNames2{i-1};
            else
                if PvaluesTable(i-1,j-1)>0.05
                    PvaluesTable_Formatted_Labels{i,j}='ND';
                    for k=length(PvaluesTable_Formatted_Labels{i,j})+1:MaxLength
                        PvaluesTable_Formatted_Labels{i,j}=horzcat(PvaluesTable_Formatted_Labels{i,j},' ');
                    end
                elseif PvaluesTable(i-1,j-1)<=0.05&&PvaluesTable(i-1,j-1)>0.01
                    PvaluesTable_Formatted_Labels{i,j}='*';
                    for k=length(PvaluesTable_Formatted_Labels{i,j})+1:MaxLength
                        PvaluesTable_Formatted_Labels{i,j}=horzcat(PvaluesTable_Formatted_Labels{i,j},' ');
                    end
                elseif PvaluesTable(i-1,j-1)<=0.01&&PvaluesTable(i-1,j-1)>0.001
                    PvaluesTable_Formatted_Labels{i,j}='**';
                    for k=length(PvaluesTable_Formatted_Labels{i,j})+1:MaxLength
                        PvaluesTable_Formatted_Labels{i,j}=horzcat(PvaluesTable_Formatted_Labels{i,j},' ');
                    end
                elseif PvaluesTable(i-1,j-1)<=0.001&&PvaluesTable(i-1,j-1)>0.0001
                    PvaluesTable_Formatted_Labels{i,j}='***';
                    for k=length(PvaluesTable_Formatted_Labels{i,j})+1:MaxLength
                        PvaluesTable_Formatted_Labels{i,j}=horzcat(PvaluesTable_Formatted_Labels{i,j},' ');
                    end
                elseif PvaluesTable(i-1,j-1)<=0.0001
                    PvaluesTable_Formatted_Labels{i,j}='****';
                    for k=length(PvaluesTable_Formatted_Labels{i,j})+1:MaxLength
                        PvaluesTable_Formatted_Labels{i,j}=horzcat(PvaluesTable_Formatted_Labels{i,j},' ');
                    end
                end
            end
        end
    end
    
    OverallPValueLabel=[];
    if ~isempty(OverallPValue)
        OverallPValueLabel{1,1}=['Overall P-value: ',num2str(OverallPValue)];
    end
    if ~isempty(PvaluesTable)
        PvaluesTable_Formatted_Labels{size(PvaluesTable_Formatted_Labels,1)+2,1}='* P<0.05; ** P<0.01; *** P<0.001; **** P<0.0001';
        %PvaluesTable_Formatted_Labels{size(PvaluesTable_Formatted_Labels,1)+2,1}=['Overall P-value: ',num2str(OverallPValue)];
    else
        PvaluesTable_Formatted=[];
        PvaluesTable_Formatted_Labels=[];
%         for i=1:length(GroupNames)
%             PvaluesTable_Formatted{i,1}=GroupNames{i};
%         end
    end
    
    
    Spacer=cell(1,size(PvaluesTable,1)+1);
    Spacer{1,1}=['================================================================'];
    FinalTable=cell(length(GroupNamesNumberedList)+4,size(PvaluesTable,1)+1);
    FinalTable{1,1}=TestName;
    FinalTable{2,1}=['================================================================'];
    for i=1:length(GroupNamesNumberedList)
        FinalTable{2+i,1}=GroupNamesNumberedList{i};
    end
    FinalTable{length(GroupNamesNumberedList)+3,1}=['================================================================'];
    FinalTable{length(GroupNamesNumberedList)+4,1}=OverallPValueLabel;
    FinalTable=vertcat(FinalTable,Spacer);
    if ~isempty(PvaluesTable_Formatted)
        FinalTable=vertcat(FinalTable,PvaluesTable_Formatted);
        FinalTable=vertcat(FinalTable,Spacer);
    end
    if ~isempty(PvaluesTable_Formatted_Labels)
        FinalTable=vertcat(FinalTable,PvaluesTable_Formatted_Labels);
        FinalTable=vertcat(FinalTable,Spacer);
    end
    dlmcell([SaveDir, '/',TestName , ' Statistics Summary' , '.txt'], FinalTable,'delimiter','\t');











end