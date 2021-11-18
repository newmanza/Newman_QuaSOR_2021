%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%If you have data you want to match to a reference low frequuency
%dataset then you can use this script to set up the batch processing name
%reference
close all
jheapcl
clear
OS=computer;
if strcmp(OS,'MACI64')
    dc='/';
else
    dc='\';
end
CurrentDir=cd;
DirList=uipickfiles();
DirList_Rearranged = regexprep(DirList,'(.*) (\w*)$','$2 $1');
[DirList_Rearranged_Sorted, idx_sorted] = sort(DirList_Rearranged);
TotalNumTIFFs=0;
TotalNumTIFs=0;
for i=1:length(idx_sorted)
    DirList_Sorted{i}=DirList{idx_sorted(i)};
    TempString=strsplit(DirList_Sorted{i});
    StackSaveNameIDs{i}=TempString{length(TempString)};
    TiffFiles(i).FolderContents=dir([DirList_Sorted{i},'/*.tiff']);
    TifFiles(i).FolderContents=dir([DirList_Sorted{i},'/*.tif']);
    TotalNumTIFFs=TotalNumTIFFs+length(TiffFiles(i).FolderContents);
    TotalNumTIFs=TotalNumTIFs+length(TifFiles(i).FolderContents);
end
TotalNumTIFs
TotalNumTIFFs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check these settings
Ib_Reference_Suffix={'_Ib_01Hz','_Ib_02Hz'};
Is_Reference_Suffix={'_Is_01Hz','_Is_02Hz'};
ReferenceText={'0.1Hz','01Hz','0_1Hz','0.2Hz','02Hz','0_2Hz'};
StimConditions2Find=[]; %use Empty to look for any high freq
StimConditions2Find={'_C0','_C0'}; %use Empty to look for any high freq
ParentDirText='ParentDir3,';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BufferTextLength=22-length(ParentDirText);
% BufferText=[];
% for i=1:BufferTextLength
%     BufferText=[BufferText,' '];
% end
% clear PreInfoArray InfoArray
% CurrentEntry=1;
% for DirNum=1:length(DirList_Sorted)
%     if ~isempty(TiffFiles(DirNum).FolderContents)
%         for RecordingNum=1:length(TiffFiles(DirNum).FolderContents)
% 
%             TempName=TiffFiles(DirNum).FolderContents(RecordingNum);
%             % if      strfind(TempName.name,' 20Hz 10s_C488.tiff');
%             %         StimCondition='_20Hz10s';
%             StimCondition=[];
%             Repeat=0;
%             if strfind(TempName.name,' 5Hz20s.tiff')
%                     StimCondition='_5Hz20s';Repeat=1;
%             elseif strfind(TempName.name,' 5Hz 20s.tiff')
%                     StimCondition='_5Hz20s';Repeat=1;
%             elseif strfind(TempName.name,' 5Hz20s - 1.tiff')
%                     StimCondition='_5Hz20s_1';Repeat=2;
%             elseif strfind(TempName.name,' 5Hz 20s - 1.tiff')
%                     StimCondition='_5Hz20s_1';Repeat=2;
%             elseif strfind(TempName.name,' 5Hz20s - 2.tiff')
%                     StimCondition='_5Hz20s_2';Repeat=3;
%             elseif strfind(TempName.name,' 5Hz 20s - 2.tiff')
%                     StimCondition='_5Hz20s_2';Repeat=3;
%             elseif strfind(TempName.name,' 5Hz20s - 3.tiff')
%                     StimCondition='_5Hz20s_3';Repeat=4;
%             elseif strfind(TempName.name,' 5Hz 20s - 3.tiff')
%                     StimCondition='_5Hz20s_3';Repeat=4;
%             elseif strfind(TempName.name,' 5Hz20s - 4.tiff')
%                     StimCondition='_5Hz20s_4';Repeat=5;
%             elseif strfind(TempName.name,' 5Hz 20s - 4.tiff')
%                     StimCondition='_5Hz20s_4';Repeat=5;
%             elseif strfind(TempName.name,' 5Hz20s - 5.tiff')
%                     StimCondition='_5Hz20s_5';Repeat=6;
%             elseif strfind(TempName.name,' 5Hz 20s - 5.tiff')
%                     StimCondition='_5Hz20s_5';Repeat=6;
%             elseif strfind(TempName.name,' 5Hz40s.tiff')
%                     StimCondition='_5Hz40s';Repeat=1;
%             elseif strfind(TempName.name,' 5Hz 40s.tiff')
%                     StimCondition='_5Hz40s';Repeat=1;
%             elseif strfind(TempName.name,' 5Hz40s - 1.tiff')
%                     StimCondition='_5Hz40s_1';Repeat=2;
%             elseif strfind(TempName.name,' 5Hz 40s - 1.tiff')
%                     StimCondition='_5Hz40s_1';Repeat=2;
%             elseif strfind(TempName.name,' 5Hz40s - 2.tiff')
%                     StimCondition='_5Hz40s_2';Repeat=3;
%             elseif strfind(TempName.name,' 5Hz 40s - 2.tiff')
%                     StimCondition='_5Hz40s_2';Repeat=3;
%             elseif strfind(TempName.name,' 5Hz40s - 3.tiff')
%                     StimCondition='_5Hz40s_3';Repeat=4;
%             elseif strfind(TempName.name,' 5Hz 40s - 3.tiff')
%                     StimCondition='_5Hz40s_3';Repeat=4;
%             elseif strfind(TempName.name,' 5Hz40s - 4.tiff')
%                     StimCondition='_5Hz40s_4';Repeat=5;
%             elseif strfind(TempName.name,' 5Hz 40s - 4.tiff')
%                     StimCondition='_5Hz40s_4';Repeat=5;
%             elseif strfind(TempName.name,' 5Hz40s - 5.tiff')
%                     StimCondition='_5Hz40s_5';Repeat=6;
%             elseif strfind(TempName.name,' 5Hz 40s - 5.tiff')
%                     StimCondition='_5Hz40s_5';Repeat=6;
%             elseif  strfind(TempName.name,' 10Hz 20s_C488.tiff')
%                     StimCondition='_10Hz20s';Repeat=1;
%             elseif  strfind(TempName.name,' 5Hz 40s_C488.tiff')
%                     StimCondition='_5Hz40s';Repeat=1;
%             elseif  strfind(TempName.name,' 10Hz 10s.tiff')
%                     StimCondition='_10Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,'10Hz 10s - 1.tiff')
%                     StimCondition='_10Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 10Hz 10s - 2.tiff')
%                     StimCondition='_10Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 5Hz 10s.tiff')
%                     StimCondition='_5Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 5Hz 10s - 1.tiff')
%                     StimCondition='_5Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 5Hz 10s - 2.tiff')
%                     StimCondition='_5Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 2Hz 10s.tiff')
%                     StimCondition='_2Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 2Hz 10s - 1.tiff')
%                     StimCondition='_2Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 2Hz 10s - 2.tiff')
%                     StimCondition='_2Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 1Hz 10s.tiff')
%                     StimCondition='_1Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 1Hz 10s - 1.tiff')
%                     StimCondition='_1Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 1Hz 10s - 2.tiff')
%                     StimCondition='_1Hz10s_2';Repeat=3;        
%             elseif  strfind(TempName.name,' 15Hz 10s.tiff')
%                     StimCondition='_15Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 15Hz 10s - 1.tiff')
%                     StimCondition='_15Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 20Hz 10s.tiff')
%                     StimCondition='_20Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 20Hz 10s - 1.tiff')
%                     StimCondition='_20Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 20Hz 10s - 2.tiff')
%                     StimCondition='_20Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 40Hz 10s.tiff')
%                     StimCondition='_40Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 40Hz 10s - 1.tiff')
%                     StimCondition='_40Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 10Hz20s_C488.tiff')
%                     StimCondition='_10Hz20s';Repeat=1;
%             elseif  strfind(TempName.name,' 5Hz40s_C488.tiff')
%                     StimCondition='_5Hz40s';Repeat=1;
%             elseif  strfind(TempName.name,' 10Hz10s.tiff')
%                     StimCondition='_10Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,'10Hz10s - 1.tiff')
%                     StimCondition='_10Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 10Hz10s - 2.tiff')
%                     StimCondition='_10Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 5Hz10s.tiff')
%                     StimCondition='_5Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 5Hz10s - 1.tiff')
%                     StimCondition='_5Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 5Hz10s - 2.tiff')
%                     StimCondition='_5Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 2Hz10s.tiff')
%                     StimCondition='_2Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 2Hz10s - 1.tiff')
%                     StimCondition='_2Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 2Hz10s - 2.tiff')
%                     StimCondition='_2Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 1Hz10s.tiff')
%                     StimCondition='_1Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 1Hz10s - 1.tiff')
%                     StimCondition='_1Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 1Hz10s - 2.tiff')
%                     StimCondition='_1Hz10s_2';Repeat=3;        
%             elseif  strfind(TempName.name,' 15Hz10s.tiff')
%                     StimCondition='_15Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 15Hz10s - 1.tiff')
%                     StimCondition='_15Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 20Hz10s.tiff')
%                     StimCondition='_20Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 20Hz10s - 1.tiff')
%                     StimCondition='_20Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 20Hz10s - 2.tiff')
%                     StimCondition='_20Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 40Hz10s.tiff')
%                     StimCondition='_40Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 40Hz10s - 1.tiff')
%                     StimCondition='_40Hz10s_1';Repeat=2;
%             else
%                 StimCondition=[];
%             end
% 
%             DirParts = strsplit(DirList_Sorted{DirNum}, dc);
%             LastFolder=DirParts(length(DirParts));
% 
%             
%             ReferenceTIF=['.tif'];
%             for x=1:length(TifFiles(DirNum).FolderContents)
%                 for y=1:length(ReferenceText)
%                     if any(strfind(TifFiles(DirNum).FolderContents(x).name,ReferenceText{y}))
%                         ReferenceTIF=TifFiles(DirNum).FolderContents(x).name;
%                     end
%                 end
%             end
%             if ~isempty(StimCondition)
%                 cd(DirList_Sorted{DirNum})
%                 %Check for Ib Reference data
%                 for j=1:length(Ib_Reference_Suffix)
%                     if exist([StackSaveNameIDs{DirNum},Ib_Reference_Suffix{j},'_First.mat'])
%                         Located_Ib_Reference_Suffix=Ib_Reference_Suffix{j};
%                     end
%                 end
%                  for j=1:length(Is_Reference_Suffix)
%                     if exist([StackSaveNameIDs{DirNum},Is_Reference_Suffix{j},'_First.mat'])
%                         Located_Is_Reference_Suffix=Is_Reference_Suffix{j};
%                     end
%                  end
%                  if ~isempty(StimConditions2Find)
%                     FoundMatch=0;
%                     for x=1:length(StimConditions2Find)
%                         if any(strfind(StimCondition,StimConditions2Find{x}))
%                             FoundMatch=1;
%                         end
%                     end
%                  else
%                      FoundMatch=1;
%                  end
%                  if FoundMatch
%                     if exist([StackSaveNameIDs{DirNum},Located_Ib_Reference_Suffix,'_First.mat'])
%                         PreInfoArray(CurrentEntry).Date=LastFolder{1}(1:6);
%                         PreInfoArray(CurrentEntry).Prep=LastFolder{1}(8:9);
%                         PreInfoArray(CurrentEntry).Repeat=[StimCondition,num2str(Repeat)];
%                         PreInfoArray(CurrentEntry).dir=[ParentDirText,BufferText,'''',LastFolder{1}];
%                         PreInfoArray(CurrentEntry).StackSaveName=[StackSaveNameIDs{DirNum},'_Ib'];
%                         PreInfoArray(CurrentEntry).ReferenceStackSaveName=[StackSaveNameIDs{DirNum},Located_Ib_Reference_Suffix];
%                         PreInfoArray(CurrentEntry).StackSaveNameSuffix=StimCondition;
%                         PreInfoArray(CurrentEntry).StackFileName=TiffFiles(DirNum).FolderContents(RecordingNum).name;
%                         PreInfoArray(CurrentEntry).FirstImageFileName=ReferenceTIF(1:length(ReferenceTIF)-4);
% 
% %                         InfoArray{CurrentLine+1,1}=['Recording(',num2str(CurrentEntry),').dir=[',ParentDirText,BufferText,'''',LastFolder{1},'''];'];
% %                         InfoArray{CurrentLine+2,1}=['Recording(',num2str(CurrentEntry),').StackSaveName=             ''',StackSaveNameIDs{DirNum},'_Ib'';'];
% %                         InfoArray{CurrentLine+3,1}=['Recording(',num2str(CurrentEntry),').ReferenceStackSaveName=    ''',StackSaveNameIDs{DirNum},Located_Ib_Reference_Suffix,''';'];
% %                         InfoArray{CurrentLine+4,1}=['Recording(',num2str(CurrentEntry),').StackSaveNameSuffix=       ''',StimCondition,''';'];
% %                         InfoArray{CurrentLine+5,1}=['Recording(',num2str(CurrentEntry),').StackFileName=             ''',TiffFiles(DirNum).FolderContents(RecordingNum).name,''';'];
% %                         InfoArray{CurrentLine+6,1}=['Recording(',num2str(CurrentEntry),').FirstImageFileName=        ''',ReferenceTIF(1:length(ReferenceTIF)-4),''';'];
% %                         InfoArray{CurrentLine+7,1}=[];
% %                         CurrentLine=CurrentLine+7;
%                         
%                         disp(['Successfully added Entry # ',num2str(CurrentEntry),': ',TiffFiles(DirNum).FolderContents(RecordingNum).name,' ',...
%                             StackSaveNameIDs{DirNum},'_Ib',StimCondition])
%                         disp(['Reference TIF: ',ReferenceTIF,' ',StackSaveNameIDs{DirNum},Located_Ib_Reference_Suffix])
% 
%                         CurrentEntry=CurrentEntry+1;
%                         
%                     end
%                     if exist([StackSaveNameIDs{DirNum},Located_Is_Reference_Suffix,'_First.mat'])
%                         PreInfoArray(CurrentEntry).Date=LastFolder{1}(1:6);
%                         PreInfoArray(CurrentEntry).Prep=LastFolder{1}(8:9);
%                         PreInfoArray(CurrentEntry).Repeat=[StimCondition,num2str(Repeat)];
%                         PreInfoArray(CurrentEntry).dir=[ParentDirText,BufferText,'''',LastFolder{1}];
%                         PreInfoArray(CurrentEntry).StackSaveName=[StackSaveNameIDs{DirNum},'_Is'];
%                         PreInfoArray(CurrentEntry).ReferenceStackSaveName=[StackSaveNameIDs{DirNum},Located_Is_Reference_Suffix];
%                         PreInfoArray(CurrentEntry).StackSaveNameSuffix=StimCondition;
%                         PreInfoArray(CurrentEntry).StackFileName=TiffFiles(DirNum).FolderContents(RecordingNum).name;
%                         PreInfoArray(CurrentEntry).FirstImageFileName=ReferenceTIF(1:length(ReferenceTIF)-4);
% 
% %                         InfoArray{CurrentLine+1,1}=['Recording(',num2str(CurrentEntry),').dir=[',ParentDirText,BufferText,'''',LastFolder{1},'''];'];
% %                         InfoArray{CurrentLine+2,1}=['Recording(',num2str(CurrentEntry),').StackSaveName=             ''',StackSaveNameIDs{DirNum},'_Is'';'];
% %                         InfoArray{CurrentLine+3,1}=['Recording(',num2str(CurrentEntry),').ReferenceStackSaveName=    ''',StackSaveNameIDs{DirNum},Located_Is_Reference_Suffix,''';'];
% %                         InfoArray{CurrentLine+4,1}=['Recording(',num2str(CurrentEntry),').StackSaveNameSuffix=       ''',StimCondition,''';'];
% %                         InfoArray{CurrentLine+5,1}=['Recording(',num2str(CurrentEntry),').StackFileName=             ''',TiffFiles(DirNum).FolderContents(RecordingNum).name,''';'];
% %                         InfoArray{CurrentLine+6,1}=['Recording(',num2str(CurrentEntry),').FirstImageFileName=        ''',ReferenceTIF(1:length(ReferenceTIF)-4),''';'];
% %                         InfoArray{CurrentLine+7,1}=[];
% %                         CurrentLine=CurrentLine+7;
%                         
%                         disp(['Successfully added Entry # ',num2str(CurrentEntry),': ',TiffFiles(DirNum).FolderContents(RecordingNum).name,' ',...
%                             StackSaveNameIDs{DirNum},'_Is',StimCondition])
%                         disp(['Reference TIF: ',ReferenceTIF,' ',StackSaveNameIDs{DirNum},Located_Is_Reference_Suffix])
% 
%                         CurrentEntry=CurrentEntry+1;
%                     end
%                 
%                 end
%             else
%                 warning('Not able to match a preset stim tag!')
%             end
%         end
%         %InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
%         %CurrentLine=CurrentLine+1;
%     end
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if ~isempty(TifFiles(DirNum).FolderContents)
%         for RecordingNum=1:length(TifFiles(DirNum).FolderContents)
% 
%             TempName=TifFiles(DirNum).FolderContents(RecordingNum);
%             % if      strfind(TempName.name,' 20Hz 10s_C488.tiff');
%             %         StimCondition='_20Hz10s';
%             Repeat=0;
%             StimCondition=[];
%             if strfind(TempName.name,' 5Hz20s.tif')
%                     StimCondition='_5Hz20s';Repeat=1;
%             elseif strfind(TempName.name,' 5Hz 20s.tif')
%                     StimCondition='_5Hz20s';Repeat=1;
%             elseif strfind(TempName.name,' 5Hz20s - 1.tif')
%                     StimCondition='_5Hz20s_1';Repeat=2;
%             elseif strfind(TempName.name,' 5Hz 20s - 1.tif')
%                     StimCondition='_5Hz20s_1';Repeat=2; 
%             elseif strfind(TempName.name,' 5Hz20s - 2.tif')
%                     StimCondition='_5Hz20s_2';Repeat=3;
%             elseif strfind(TempName.name,' 5Hz 20s - 2.tif')
%                     StimCondition='_5Hz20s_2';Repeat=3;
%             elseif strfind(TempName.name,' 5Hz20s - 3.tif')
%                     StimCondition='_5Hz20s_3';Repeat=4;
%             elseif strfind(TempName.name,' 5Hz 20s - 3.tif')
%                     StimCondition='_5Hz20s_3';Repeat=4;
%             elseif strfind(TempName.name,' 5Hz20s - 4.tif')
%                     StimCondition='_5Hz20s_4';Repeat=5;
%             elseif strfind(TempName.name,' 5Hz 20s - 4.tif')
%                     StimCondition='_5Hz20s_4';Repeat=5;
%             elseif strfind(TempName.name,' 5Hz20s - 5.tif')
%                     StimCondition='_5Hz20s_5';Repeat=6;
%             elseif strfind(TempName.name,' 5Hz 20s - 5.tif')
%                     StimCondition='_5Hz20s_5';Repeat=6;
%             elseif strfind(TempName.name,' 5Hz40s.tif')
%                     StimCondition='_5Hz40s';Repeat=1;
%             elseif strfind(TempName.name,' 5Hz 40s.tif')
%                     StimCondition='_5Hz40s';Repeat=1;
%             elseif strfind(TempName.name,' 5Hz40s - 1.tif')
%                     StimCondition='_5Hz40s_1';Repeat=2;
%             elseif strfind(TempName.name,' 5Hz 40s - 1.tif')
%                     StimCondition='_5Hz40s_1';Repeat=2;
%             elseif strfind(TempName.name,' 5Hz40s - 2.tif')
%                     StimCondition='_5Hz40s_2';Repeat=3;
%             elseif strfind(TempName.name,' 5Hz 40s - 2.tif')
%                     StimCondition='_5Hz40s_2';Repeat=3;
%             elseif strfind(TempName.name,' 5Hz40s - 3.tif')
%                     StimCondition='_5Hz40s_3';Repeat=4;
%             elseif strfind(TempName.name,' 5Hz 40s - 3.tif')
%                     StimCondition='_5Hz40s_3';Repeat=4;
%             elseif strfind(TempName.name,' 5Hz40s - 4.tif')
%                     StimCondition='_5Hz40s_4';Repeat=5;
%             elseif strfind(TempName.name,' 5Hz 40s - 4.tif')
%                     StimCondition='_5Hz40s_4';Repeat=5;
%             elseif strfind(TempName.name,' 5Hz40s - 5.tif')
%                     StimCondition='_5Hz40s_5';Repeat=6;
%             elseif strfind(TempName.name,' 5Hz 40s - 5.tif')
%                     StimCondition='_5Hz40s_5';Repeat=6;
%             elseif  strfind(TempName.name,' 10Hz 20s_C488.tif')
%                     StimCondition='_10Hz20s';Repeat=1;
%             elseif  strfind(TempName.name,' 5Hz 40s_C488.tif')
%                     StimCondition='_5Hz40s';Repeat=1;
%             elseif  strfind(TempName.name,' 10Hz 10s.tif')
%                     StimCondition='_10Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,'10Hz 10s - 1.tif')
%                     StimCondition='_10Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 10Hz 10s - 2.tif')
%                     StimCondition='_10Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 5Hz 10s.tif')
%                     StimCondition='_5Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 5Hz 10s - 1.tif')
%                     StimCondition='_5Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 5Hz 10s - 2.tif')
%                     StimCondition='_5Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 2Hz 10s.tif')
%                     StimCondition='_2Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 2Hz 10s - 1.tif')
%                     StimCondition='_2Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 2Hz 10s - 2.tif')
%                     StimCondition='_2Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 1Hz 10s.tif')
%                     StimCondition='_1Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 1Hz 10s - 1.tif')
%                     StimCondition='_1Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 1Hz 10s - 2.tif')
%                     StimCondition='_1Hz10s_2';Repeat=3;        
%             elseif  strfind(TempName.name,' 15Hz 10s.tif')
%                     StimCondition='_15Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 15Hz 10s - 1.tif')
%                     StimCondition='_15Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 20Hz 10s.tif')
%                     StimCondition='_20Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 20Hz 10s - 1.tif')
%                     StimCondition='_20Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 20Hz 10s - 2.tif')
%                     StimCondition='_20Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 40Hz 10s.tif')
%                     StimCondition='_40Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 40Hz 10s - 1.tif')
%                     StimCondition='_40Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 10Hz20s_C488.tif')
%                     StimCondition='_10Hz20s';Repeat=1;
%             elseif  strfind(TempName.name,' 5Hz40s_C488.tif')
%                     StimCondition='_5Hz40s';Repeat=1;
%             elseif  strfind(TempName.name,' 10Hz10s.tif')
%                     StimCondition='_10Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,'10Hz10s - 1.tif')
%                     StimCondition='_10Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 10Hz10s - 2.tif')
%                     StimCondition='_10Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 5Hz10s.tif')
%                     StimCondition='_5Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 5Hz10s - 1.tif')
%                     StimCondition='_5Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 5Hz10s - 2.tif')
%                     StimCondition='_5Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 2Hz10s.tif')
%                     StimCondition='_2Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 2Hz10s - 1.tif')
%                     StimCondition='_2Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 2Hz10s - 2.tif')
%                     StimCondition='_2Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 1Hz10s.tif')
%                     StimCondition='_1Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 1Hz10s - 1.tif')
%                     StimCondition='_1Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 1Hz10s - 2.tif')
%                     StimCondition='_1Hz10s_2';Repeat=3;        
%             elseif  strfind(TempName.name,' 15Hz10s.tif')
%                     StimCondition='_15Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 15Hz10s - 1.tif')
%                     StimCondition='_15Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 20Hz10s.tif')
%                     StimCondition='_20Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 20Hz10s - 1.tif')
%                     StimCondition='_20Hz10s_1';Repeat=2;
%             elseif  strfind(TempName.name,' 20Hz10s - 2.tif')
%                     StimCondition='_20Hz10s_2';Repeat=3;
%             elseif  strfind(TempName.name,' 40Hz10s.tif')
%                     StimCondition='_40Hz10s';Repeat=1;
%             elseif  strfind(TempName.name,' 40Hz10s - 1.tif')
%                     StimCondition='_40Hz10s_1';Repeat=2;
%             else
%                     StimCondition=[];
%             end
% 
%             DirParts = strsplit(DirList_Sorted{DirNum}, dc);
%             LastFolder=DirParts(length(DirParts));
% 
%             
%             ReferenceTIF=['.tif'];
%             for x=1:length(TifFiles(DirNum).FolderContents)
%                 for y=1:length(ReferenceText)
%                     if any(strfind(TifFiles(DirNum).FolderContents(x).name,ReferenceText{y}))
%                         ReferenceTIF=TifFiles(DirNum).FolderContents(x).name;
%                     end
%                 end
%             end
%             if ~isempty(StimCondition)
%                 cd(DirList_Sorted{DirNum})
%                 %Check for Ib Reference data
%                 for j=1:length(Ib_Reference_Suffix)
%                     if exist([StackSaveNameIDs{DirNum},Ib_Reference_Suffix{j},'_First.mat'])
%                         Located_Ib_Reference_Suffix=Ib_Reference_Suffix{j};
%                     end
%                 end
%                  for j=1:length(Is_Reference_Suffix)
%                     if exist([StackSaveNameIDs{DirNum},Is_Reference_Suffix{j},'_First.mat'])
%                         Located_Is_Reference_Suffix=Is_Reference_Suffix{j};
%                     end
%                  end
%                  if ~isempty(StimConditions2Find)
%                     FoundMatch=0;
%                     for x=1:length(StimConditions2Find)
%                         if any(strfind(StimCondition,StimConditions2Find{x}))
%                             FoundMatch=1;
%                         end
%                     end
%                  else
%                      FoundMatch=1;
%                  end
%                  if FoundMatch
%                     if exist([StackSaveNameIDs{DirNum},Located_Ib_Reference_Suffix,'_First.mat'])
%                         PreInfoArray(CurrentEntry).Date=LastFolder{1}(1:6);
%                         PreInfoArray(CurrentEntry).Prep=LastFolder{1}(8:9);
%                         PreInfoArray(CurrentEntry).Repeat=[StimCondition,num2str(Repeat)];
%                         PreInfoArray(CurrentEntry).dir=[ParentDirText,BufferText,'''',LastFolder{1}];
%                         PreInfoArray(CurrentEntry).StackSaveName=[StackSaveNameIDs{DirNum},'_Ib'];
%                         PreInfoArray(CurrentEntry).ReferenceStackSaveName=[StackSaveNameIDs{DirNum},Located_Ib_Reference_Suffix];
%                         PreInfoArray(CurrentEntry).StackSaveNameSuffix=StimCondition;
%                         PreInfoArray(CurrentEntry).StackFileName=TifFiles(DirNum).FolderContents(RecordingNum).name;
%                         PreInfoArray(CurrentEntry).FirstImageFileName=ReferenceTIF(1:length(ReferenceTIF)-4);
%                         
% %                         InfoArray{CurrentLine+1,1}=['Recording(',num2str(CurrentEntry),').dir=[',ParentDirText,BufferText,'''',LastFolder{1},'''];'];
% %                         InfoArray{CurrentLine+2,1}=['Recording(',num2str(CurrentEntry),').StackSaveName=             ''',StackSaveNameIDs{DirNum},'_Ib'';'];
% %                         InfoArray{CurrentLine+3,1}=['Recording(',num2str(CurrentEntry),').ReferenceStackSaveName=    ''',StackSaveNameIDs{DirNum},Located_Ib_Reference_Suffix,''';'];
% %                         InfoArray{CurrentLine+4,1}=['Recording(',num2str(CurrentEntry),').StackSaveNameSuffix=       ''',StimCondition,''';'];
% %                         InfoArray{CurrentLine+5,1}=['Recording(',num2str(CurrentEntry),').StackFileName=             ''',TifFiles(DirNum).FolderContents(RecordingNum).name,''';'];
% %                         InfoArray{CurrentLine+6,1}=['Recording(',num2str(CurrentEntry),').FirstImageFileName=        ''',ReferenceTIF(1:length(ReferenceTIF)-4),''';'];
% %                         InfoArray{CurrentLine+7,1}=[];
% %                         CurrentLine=CurrentLine+7;
%                         
%                         disp(['Successfully added Entry # ',num2str(CurrentEntry),': ',TifFiles(DirNum).FolderContents(RecordingNum).name,' ',...
%                             StackSaveNameIDs{DirNum},'_Ib',StimCondition])
%                         disp(['Reference TIF: ',ReferenceTIF,' ',StackSaveNameIDs{DirNum},Located_Ib_Reference_Suffix])
% 
%                         CurrentEntry=CurrentEntry+1;
%                         
%                     end
%                     if exist([StackSaveNameIDs{DirNum},Located_Is_Reference_Suffix,'_First.mat'])
%                         PreInfoArray(CurrentEntry).Date=LastFolder{1}(1:6);
%                         PreInfoArray(CurrentEntry).Prep=LastFolder{1}(8:9);
%                         PreInfoArray(CurrentEntry).Repeat=[StimCondition,num2str(Repeat)];
%                         PreInfoArray(CurrentEntry).dir=[ParentDirText,BufferText,'''',LastFolder{1}];
%                         PreInfoArray(CurrentEntry).StackSaveName=[StackSaveNameIDs{DirNum},'_Is'];
%                         PreInfoArray(CurrentEntry).ReferenceStackSaveName=[StackSaveNameIDs{DirNum},Located_Is_Reference_Suffix];
%                         PreInfoArray(CurrentEntry).StackSaveNameSuffix=StimCondition;
%                         PreInfoArray(CurrentEntry).StackFileName=TifFiles(DirNum).FolderContents(RecordingNum).name;
%                         PreInfoArray(CurrentEntry).FirstImageFileName=ReferenceTIF(1:length(ReferenceTIF)-4);
%                         
% %                         InfoArray{CurrentLine+1,1}=['Recording(',num2str(CurrentEntry),').dir=[',ParentDirText,BufferText,'''',LastFolder{1},'''];'];
% %                         InfoArray{CurrentLine+2,1}=['Recording(',num2str(CurrentEntry),').StackSaveName=             ''',StackSaveNameIDs{DirNum},'_Is'';'];
% %                         InfoArray{CurrentLine+3,1}=['Recording(',num2str(CurrentEntry),').ReferenceStackSaveName=    ''',StackSaveNameIDs{DirNum},Located_Is_Reference_Suffix,''';'];
% %                         InfoArray{CurrentLine+4,1}=['Recording(',num2str(CurrentEntry),').StackSaveNameSuffix=       ''',StimCondition,''';'];
% %                         InfoArray{CurrentLine+5,1}=['Recording(',num2str(CurrentEntry),').StackFileName=             ''',TifFiles(DirNum).FolderContents(RecordingNum).name,''';'];
% %                         InfoArray{CurrentLine+6,1}=['Recording(',num2str(CurrentEntry),').FirstImageFileName=        ''',ReferenceTIF(1:length(ReferenceTIF)-4),''';'];
% %                         InfoArray{CurrentLine+7,1}=[];
% %                         CurrentLine=CurrentLine+7;
%                         
%                         disp(['Successfully added Entry # ',num2str(CurrentEntry),': ',TifFiles(DirNum).FolderContents(RecordingNum).name,' ',...
%                             StackSaveNameIDs{DirNum},'_Is',StimCondition])
%                         disp(['Reference TIF: ',ReferenceTIF,' ',StackSaveNameIDs{DirNum},Located_Is_Reference_Suffix])
% 
%                         CurrentEntry=CurrentEntry+1;
%                     end
%                 
%                 end
%             else
%                 warning('Not able to match a preset stim tag!')
%             end
%         end
%         %InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
%         %CurrentLine=CurrentLine+1;
%     end
% end
% SortChoice=input('<Enter> to group by Stim Condition and Bouton Type or <1> to sort by Stim Condition Only: ');
% if isempty(SortChoice)
%     PreInfoArray_Sorted=nestedSortStruct2(PreInfoArray, {'Date','Prep','StackSaveName','Repeat','StackFileName'});
% else
%     PreInfoArray_Sorted=nestedSortStruct2(PreInfoArray, {'Date','Prep','Repeat','StackFileName'});
% end
% CurrentLine=1;
% TempDir=PreInfoArray_Sorted(1).dir;
% InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
% CurrentLine=CurrentLine+1;
% InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
% CurrentLine=CurrentLine+1;
% for CurrentEntry=1:length(PreInfoArray_Sorted)
%     if ~strcmp(TempDir,PreInfoArray_Sorted(CurrentEntry).dir)
%         InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
%         CurrentLine=CurrentLine+1;
%     end
%     TempDir=PreInfoArray_Sorted(CurrentEntry).dir;
% 
%     InfoArray{CurrentLine+1,1}=['Recording(',num2str(CurrentEntry),').dir=[',PreInfoArray_Sorted(CurrentEntry).dir,'''];'];
%     InfoArray{CurrentLine+2,1}=['Recording(',num2str(CurrentEntry),').StackSaveName=             ''',PreInfoArray_Sorted(CurrentEntry).StackSaveName,''';'];
%     InfoArray{CurrentLine+3,1}=['Recording(',num2str(CurrentEntry),').ReferenceStackSaveName=    ''',PreInfoArray_Sorted(CurrentEntry).ReferenceStackSaveName,''';'];
%     InfoArray{CurrentLine+4,1}=['Recording(',num2str(CurrentEntry),').StackSaveNameSuffix=       ''',PreInfoArray_Sorted(CurrentEntry).StackSaveNameSuffix,''';'];
%     InfoArray{CurrentLine+5,1}=['Recording(',num2str(CurrentEntry),').StackFileName=             ''',PreInfoArray_Sorted(CurrentEntry).StackFileName,''';'];
%     InfoArray{CurrentLine+6,1}=['Recording(',num2str(CurrentEntry),').FirstImageFileName=        ''',PreInfoArray_Sorted(CurrentEntry).FirstImageFileName,''';'];
%     InfoArray{CurrentLine+7,1}=[];
%     CurrentLine=CurrentLine+7;    
%     
%                       
% end
% InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
% CurrentLine=CurrentLine+1;
% cd(CurrentDir)
% warning(['Exported ',num2str(length(PreInfoArray_Sorted)),' Files!'])
% warning(['Exported ',num2str(length(PreInfoArray_Sorted)),' Files!'])
% warning(['Exported ',num2str(length(PreInfoArray_Sorted)),' Files!'])
% warning(['Exported ',num2str(length(PreInfoArray_Sorted)),' Files!'])
% FileRecord_Dir=['ID Files'];
% mkdir(FileRecord_Dir)
% CurrentDateTime=clock;
% Year=num2str(CurrentDateTime(1)-2000);Month=num2str(CurrentDateTime(2));
% Day=num2str(CurrentDateTime(3));Hour=num2str(CurrentDateTime(4));
% Minute=num2str(CurrentDateTime(5));Second=num2str(CurrentDateTime(6));
% if length(Month)<2;Month=['0',Month];end;if length(Day)<2;Day=['0',Day];end
% dlmcell([FileRecord_Dir,dc,(Year),(Month),(Day),' Temp High Freq Name Prep.txt'], InfoArray);
% open([FileRecord_Dir,dc,(Year),(Month),(Day),' Temp High Freq Name Prep.txt']);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alignment analysis
for RecordingNum=1:length(Recording)
    StackSaveNameArray{RecordingNum,1} = [Recording(RecordingNum).StackSaveName,Recording(RecordingNum).StackSaveNameSuffix];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check setup
warning off
for RecordingNum=1:length(Recording)
    cd([Recording(RecordingNum).dir]);
    currentFolder = pwd;

    StackSaveName = Recording(RecordingNum).StackSaveName;
    StackSaveNameSuffix = Recording(RecordingNum).StackSaveNameSuffix;
                                TestPath=[Recording(RecordingNum).dir,dc,StackSaveName,StackSaveNameSuffix,' Summary Figures',dc,StackSaveName,StackSaveNameSuffix];
                                if length(TestPath)>200
                                    warning('Using Short Path')
                                    SaveDir=[StackSaveName(length(StackSaveName)-4:length(StackSaveName)),StackSaveNameSuffix,' Figs'];
                                    if ~exist(SaveDir)
                                        mkdir(SaveDir)
                                    end
                                else
                                    SaveDir=strcat(StackSaveName,StackSaveNameSuffix,' Summary Figures');
                                end
    StackFileName=Recording(RecordingNum).StackFileName;
    FirstImageFileName=Recording(RecordingNum).FirstImageFileName;
    ReferenceStackSaveName=Recording(RecordingNum).ReferenceStackSaveName;
disp('=====================================================================================')
    disp(['Dataset #',num2str(RecordingNum),' StackSaveName= ',StackSaveName,StackSaveNameSuffix]);

    if ~exist(StackFileName)
        warning(['Missing Image File: ',StackFileName])
    else
        disp(['Found Image File: ',StackFileName])
    end
    clear foundfile
    if ~exist([FirstImageFileName,'.tif'])
        warning(['Missing Reference Image File: ',FirstImageFileName])
    else
        disp(['Found Reference Image File: ',FirstImageFileName])
    end
    if ~exist([ReferenceStackSaveName '_First.mat'])
        warning(['Missing Reference Data: ',ReferenceStackSaveName])
    else
        disp(['Found Reference Data: ',ReferenceStackSaveName])
    end

    clearvars -except myPool  Recording ParentDir ParentDir1 ParentDir2 ParentDir3 RecordingNum dc currentFolder
    %cd(currentFolder)
end
warning on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set up alignment analysis
FastMode=1;
Load_Contrast_Parameters=1
Load_Contrast_Parameter_Suffix='_02Hz'
OverwriteDemonSettings=1
Default_AccumulatedFieldSmoothing=4
Default_SmoothDemon=2
Default_DemonSmoothSize=[15,11]
warning off
for RecordingNum=1:length(Recording)
    clearvars -except myPool OverwriteDemonSettings Default_AccumulatedFieldSmoothing Default_SmoothDemon Default_DemonSmoothSize Recording ParentDir ParentDir1 ParentDir2 ParentDir3 RecordingNum dc currentFolder FastMode Load_Contrast_Parameters Load_Contrast_Parameter_Suffix
    %jheapcl
    cd([Recording(RecordingNum).dir]);
    currentFolder = pwd;

    StackSaveName = Recording(RecordingNum).StackSaveName;
    StackSaveNameSuffix = Recording(RecordingNum).StackSaveNameSuffix;
    TestPath=[Recording(RecordingNum).dir,dc,StackSaveName,StackSaveNameSuffix,' Summary Figures',dc,StackSaveName,StackSaveNameSuffix];
    if length(TestPath)>200
        warning('Using Short Path')
        SaveDir=[StackSaveName(length(StackSaveName)-4:length(StackSaveName)),StackSaveNameSuffix,' Figs'];
        if ~exist(SaveDir)
            mkdir(SaveDir)
        end
    else
        SaveDir=strcat(StackSaveName,StackSaveNameSuffix,' Summary Figures');
    end
    if ~exist(SaveDir)
        mkdir(SaveDir)
    end
    
    StackFileName=Recording(RecordingNum).StackFileName;
    FirstImageFileName=Recording(RecordingNum).FirstImageFileName;
    ReferenceStackSaveName=Recording(RecordingNum).ReferenceStackSaveName;

    disp(['Dataset #',num2str(RecordingNum),' StackSaveName= ',StackSaveName,StackSaveNameSuffix]);


    ImagingFrequency=20; %in Hz
    MaxShift = 25; % max allowed pixel shift
    Jitters = [1 2 1];
    MinCorrValue = 0; %not used in function
    warning('Fix Filter size in future!')
    warning('Fix Filter size in future!')
    warning('Fix Filter size in future!')
    warning('Fix Filter size in future!')
    warning('Fix Filter size in future!')
    warning('Fix Filter size in future!')
    FilterSize=7
    FilterSigma=1


    [FileMetaData]=imreadBFmeta([currentFolder,dc,StackFileName]);
    disp(['Total Number of frames: ',num2str(FileMetaData.nframes)]);

    ImageHeight=FileMetaData.height;
    ImageWidth=FileMetaData.width;

    TotalFrames=FileMetaData.nframes;
    %TotalFrames=FileMetaData.zsize;

    GoodImages=1:TotalFrames;

    load([ReferenceStackSaveName '_First'],'AllBoutonsRegion', 'FilterSize', 'FilterSigma', 'AlignRegion', 'MaxShiftX', 'MaxShiftY', 'BoutonArray', 'MaxShift', 'MinCorrValue', 'Jitters', 'Crop_Props','ImageArrayReg_FirstImages');
    %load([ReferenceStackSaveName '_First'],'AllBoutonsRegion_orig');
    load([ReferenceStackSaveName '_BoutonArray'],'AllBoutonsRegion','BoutonArray');
    if exist([ReferenceStackSaveName,'_GFPs_1'])
        load([ReferenceStackSaveName,'_GFPs_1'],'Crop_Props','BoutonArray');
    end
    TempFirstImage=ImageArrayReg_FirstImages(:,:,1);
    
    TempFirstImage_Crop=imcrop(TempFirstImage, Crop_Props.BoundingBox);
    if strcmp(class(TempFirstImage_Crop),'uint16')
        TempFirstImage_Crop=TempFirstImage_Crop.*uint16(imcrop(AllBoutonsRegion, Crop_Props.BoundingBox));
    else
        TempFirstImage_Crop=TempFirstImage_Crop.*double(imcrop(AllBoutonsRegion, Crop_Props.BoundingBox));
    end
    clear ImageArrayReg_FirstImages
    
    
    if Load_Contrast_Parameters
        if exist([StackSaveName,Load_Contrast_Parameter_Suffix,'_EnhancementSettings.mat'])||exist([StackSaveName,Load_Contrast_Parameter_Suffix,'_ReferenceEnhancementSettings.mat'])
            disp(['Loading Reference Contrast Enhancement Parameters from: ',StackSaveName,Load_Contrast_Parameter_Suffix,'_ReferenceEnhancementSettings.mat'])
            if exist([StackSaveName,Load_Contrast_Parameter_Suffix,'_ReferenceEnhancementSettings.mat'])
                load([StackSaveName,Load_Contrast_Parameter_Suffix,'_ReferenceEnhancementSettings.mat'])
            end

            if ~exist('DemonMask','var')
                DemonMask=[];
            else
                disp('NOTE Loading Demon Mask...')
            end
            
            save([StackSaveName,StackSaveNameSuffix '_ReferenceEnhancementSettings'],'PadValue_Method','Padding','MaskSplitPercentage','StretchLimParams','MaskSplitDilate','BorderAdjustSize', ...
                'Bias_Region','BiasRatios','BiasRatioDiv','BiasProportion',...
                'weinerParams','openParams','Filter_Enhanced','EnhanceFilterSize','EnhanceFilterSigma','DemonMask')    
            disp(['Loading Contrast Enhancement Parameters from: ',StackSaveName,Load_Contrast_Parameter_Suffix,'_EnhancementSettings.mat'])
            if exist([StackSaveName,Load_Contrast_Parameter_Suffix,'_EnhancementSettings.mat'])
                load([StackSaveName,Load_Contrast_Parameter_Suffix,'_EnhancementSettings.mat'])
            end
            save([StackSaveName,StackSaveNameSuffix '_EnhancementSettings'],'PadValue_Method','Padding','MaskSplitPercentage','StretchLimParams','MaskSplitDilate','BorderAdjustSize', ...
                'Bias_Region','BiasRatios','BiasRatioDiv','BiasProportion',...
                'weinerParams','openParams','Filter_Enhanced','EnhanceFilterSize','EnhanceFilterSigma')    
            disp(['Loading Demon Parameters from: ',StackSaveName,Load_Contrast_Parameter_Suffix,'_DemonSettings.mat'])
            load([StackSaveName,Load_Contrast_Parameter_Suffix '_DemonSettings'],'PyramidLevels','Iterations','AccumulatedFieldSmoothing','SmoothDemon','DemonSmoothSize',...
                'IntermediateCropPadding','BorderBufferPixelSize','BoutonRefinement','DynamicSmoothing','DynamicSmoothingDerivThreshold')
            if OverwriteDemonSettings
                warning('Updating Demon Settings According to defaults...')
                AccumulatedFieldSmoothing=Default_AccumulatedFieldSmoothing
                SmoothDemon=Default_SmoothDemon
                DemonSmoothSize=Default_DemonSmoothSize
            end
            save([StackSaveName,StackSaveNameSuffix '_DemonSettings'],'PyramidLevels','Iterations','AccumulatedFieldSmoothing','SmoothDemon','DemonSmoothSize',...
                'IntermediateCropPadding','BorderBufferPixelSize','BoutonRefinement','DynamicSmoothing','DynamicSmoothingDerivThreshold')
        end
    end
    
    save([StackSaveName,StackSaveNameSuffix '_HighFreqContinuousImagingAnalysis'],'-regexp','^(?!(Recording|ParentDir|ParentDir1|ParentDir2|ParentDir3|RecordingNum|StackSaveName|currentFolder|Load_Contrast_Parameters)$).'); 
    Choice=[];
    if ~FastMode
        Choice=input('Enter 1 to preview stack: ');
    end
    if Choice==1

        FlipLeftRight=1;
        %check for movement
        TempImageArray = zeros(ImageHeight,ImageWidth,TotalFrames);
        Temp_AllBoutonsRegionPerim_Thick = bwperim(AllBoutonsRegion,8);
        Temp_AllBoutonsRegionPerim_Thick=imdilate(Temp_AllBoutonsRegionPerim_Thick,[1,1;1,1;1,1]);
        progressbar('Image Number');
        for i=1:TotalFrames
            progressbar(i/TotalFrames);
            TempImage=imread(StackFileName,'tif',i);
            if FlipLeftRight
                TempImage=fliplr(TempImage);
            end
            TempImage = imfilter(TempImage, fspecial('gaussian', FilterSize, FilterSigma));
            TempImage = single(TempImage);
            TempImage(Temp_AllBoutonsRegionPerim_Thick==1) = 0;
            TempImageArray(:,:,i) = TempImage;
            clear TempImage
        end
        AutoPlayback(TempImageArray,0.001,[0 MaxStack(TempImageArray(:,:,1))-MaxStack(TempImageArray(:,:,1))*0.3]);
        clear TempImageArray
        jheapcl

    end

    %to load alternative bouton parameters
    % load([StackSaveName,'_10Hz40s', '_HighFreqContinuousImagingAnalysis'],'AllBoutonsRegion','BoutonArray');%AllBoutonsRegion=AllBoutonsRegion_orig;


    AllBoutonsRegionPerim = bwperim(AllBoutonsRegion);
    DisplayImage = imoverlay(mat2gray(TempFirstImage), AllBoutonsRegionPerim, [1 1 0]); % [0 1 1] = color

    iptsetpref('ImshowBorder','tight');
    figure, imshow(DisplayImage,[], 'InitialMagnification', 200);
    hold on;
    LastBoutonNumber = size(BoutonArray,2);
    for BoutonNumber=1:LastBoutonNumber
        BoutonPerim = bwperim(BoutonArray(BoutonNumber).ImageArea);
        [BorderY BorderX] = find(BoutonPerim);
        plot(BorderX, BorderY, 'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 5);
        BoutonLabel=num2str(BoutonNumber);
        text(mean(BorderX),mean(BorderY),BoutonLabel,'fontsize',30, 'color', 'r');
    end
    title(strcat(StackSaveName, ' Alignment Bouton Borders'),'Interpreter','none','fontsize',24);
    set(gcf, 'color', 'white');
    [CropHeight CropWidth,CropDepth]=size(DisplayImage);
    set(gcf, 'Position', [100,500,CropWidth*3,CropHeight*3+20]);
    set(gcf,'units','centimeters');
    set(gcf,'papersize',[CropWidth/12,CropHeight/10]);
    set(gcf,'paperposition',[0,0,CropWidth/12,CropHeight/10]);
    hold off
    iptsetpref('ImshowBorder','loose');
    if ~FastMode
        Choice=input('Enter 1 to redefine bouton borders: ');
    end
    while Choice==1
    %to load previous high freq parameters here
    %load([StackSaveName,'_10Hz20s_HighFreqContinuousImagingAnalysis'],'BoutonArray','BoutonBorders');

        %Select new bouton borders for alignment
    %                     TempFirstImage = ArrayCrop(TempFirstImage, Crop_Props.BoundingBox);
    %                     TempAllBoutonsRegion=ArrayCrop(AllBoutonsRegion, Crop_Props.BoundingBox);
    %                     TempAllBoutonsRegionPerim = bwperim(TempAllBoutonsRegion);
        %TempAllBoutonsRegionPerim = ArrayCrop(TempAllBoutonsRegionPerim, Crop_Props.BoundingBox);
        clear BoutonArray
        AllBoutonsRegionPerim = bwperim(AllBoutonsRegion);
        DisplayImage = imoverlay(mat2gray(TempFirstImage(:,:,1)), AllBoutonsRegionPerim, [1 1 0]); % [0 1 1] = color
        figure, imshow(DisplayImage,[], 'InitialMagnification', 200);
        hold on;BoutonBorders = zeros(size(TempFirstImage(:,:,1)));
        Label = 1;cont = 1;     
        while cont
            BoutonRegion = roipoly;
            cont = any(BoutonRegion(:));
            BoutonRegion = BoutonRegion & AllBoutonsRegion; % BoutonRegion will be the selected region x AllBoutonsRegion 
            BoutonPerim = bwperim(BoutonRegion);
            BoutonBorders(BoutonPerim) = 1;   
            [BorderY BorderX] = find(BoutonPerim);
            plot(BorderX, BorderY,'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 1);
            TmpImage = zeros(size(TempFirstImage(:,:,1)));
            TmpImage(BoutonRegion) = 1;
            if cont
                 BoutonArray(Label).ImageArea = TmpImage;
            end
            Label = Label + 1;
        end
        clear cont TmpImage;hold off;

        figure, imshow(BoutonBorders,[]);AllBoutonsImage=zeros(size(BoutonArray(1).ImageArea,1),size(BoutonArray(1).ImageArea,2));
        for i=1:size(BoutonArray,2)
            AllBoutonsImage=AllBoutonsImage+BoutonArray(i).ImageArea;
        end
        figure, imshow(AllBoutonsImage,[]);
        AllBoutonsImage(AllBoutonsImage>0)=1;figure, imshow(AllBoutonsImage,[]);
        tilefigs
        Choice=input('Enter 1 to reselect: ');
    end

    AllVars=who;
    count=1;
    for i=1:length(AllVars)
        if ~strcmp(AllVars{i},'Recording')&&~strcmp(AllVars{i},'ParentDir')&&~strcmp(AllVars{i},'RecordingNum')&&~strcmp(AllVars{i},'currentFolder')&&~strcmp(AllVars{i},'FastMode')
            AllVarsEdit{count}=AllVars{i};count=count+1;
        end
    end
    
    %clear AllBoutonsRegion_orig
    save([StackSaveName,StackSaveNameSuffix '_HighFreqContinuousImagingAnalysis'],AllVarsEdit{:});
    jheapcl    
    close all
    disp(['Finished Prepping Recording #',num2str(RecordingNum),': ',StackSaveName,StackSaveNameSuffix])
    clearvars -except myPool OverwriteDemonSettings Default_AccumulatedFieldSmoothing Default_SmoothDemon Default_DemonSmoothSize Recording ParentDir ParentDir1 ParentDir2 ParentDir3 RecordingNum dc currentFolder FastMode Load_Contrast_Parameters Load_Contrast_Parameter_Suffix
    cd(currentFolder)
end
warning on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Verify files
% for RecordingNum=1:length(Recording)
%     cd([Recording(RecordingNum).dir]);
%     StackSaveName = Recording(RecordingNum).StackSaveName;
%     StackSaveNameSuffix = Recording(RecordingNum).StackSaveNameSuffix;
%                                 TestPath=[Recording(RecordingNum).dir,dc,StackSaveName,StackSaveNameSuffix,' Summary Figures',dc,StackSaveName,StackSaveNameSuffix];
%                                 if length(TestPath)>200
%                                     warning('Using Short Path')
%                                     SaveDir=[StackSaveName(length(StackSaveName)-4:length(StackSaveName)),StackSaveNameSuffix,' Figs'];
%                                     if ~exist(SaveDir)
%                                         mkdir(SaveDir)
%                                     end
%                                 else
%                                     SaveDir=strcat(StackSaveName,StackSaveNameSuffix,' Summary Figures');
%                                 end
%     disp('=====================================================================================')
%     disp(['Dataset #',num2str(RecordingNum),' StackSaveName= ',StackSaveName,StackSaveNameSuffix]);
%     if exist([StackSaveName,StackSaveNameSuffix '_HighFreqContinuousImagingAnalysis.mat'])
%         disp(['Verified: ',num2str(RecordingNum),' ',StackSaveName,StackSaveNameSuffix]);
%     else
%         warning(['Missing: ',num2str(RecordingNum),' ',StackSaveName,StackSaveNameSuffix]);
%     end
%     clearvars -except myPool  Recording ParentDir ParentDir1 ParentDir2 ParentDir3 RecordingNum dc currentFolder
%     cd(currentFolder)
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%