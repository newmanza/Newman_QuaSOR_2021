%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
CheckingMode=1;
RecNum=0;
RecordingChoiceOptions=[];
for RecNum=1:length(Recording)
    RecordingChoiceOptions{RecNum}=['Rec #',num2str(RecNum),': ',Recording(RecNum).StackSaveName];
end
if exist('FlaggedRecordings')
    warning on
    warning(['FlaggedRecordings exists with ',num2str(FlaggedCount),' Flagged entries!'])
    for f=1:FlaggedCount
        warning(['Flag #',num2str(f),' ',RecordingChoiceOptions{FlaggedRecordings(f)}]);
    end
    
    ClearAllFlags = questdlg({['Currently ',num2str(FlaggedCount),'/',num2str(length(Recording)),' Flagged'];'Clear Flags?'},'Clear Flags?','Clear','Skip','Skip');
    if strcmp(ClearAllFlags,'Clear')
        FlaggedRecordings=[];
        FlaggedCount=0;
    end
else
    FlaggedRecordings=[];
    FlaggedCount=0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
CheckingModeChoice = questdlg(['How Would You Like To Check the ',num2str(length(Recording)),'Recordings?'],'Checking Mode?',...
    'Select Start','Custom','Single','Select Start');
if strcmp(CheckingModeChoice,'Select Start')
    [StartingRecordingNum, ~] = listdlg('PromptString','Where to start Checking?','SelectionMode','single','ListString',RecordingChoiceOptions,'ListSize', [500 600],'InitialValue',1);
    RecordingNums=[StartingRecordingNum:length(Recording)];
elseif strcmp(CheckingModeChoice,'Custom')
    [RecordingNums, ~] = listdlg('PromptString','Select Recordings to Check?','ListString',RecordingChoiceOptions,'ListSize', [500 600],'InitialValue',[1:length(Recording)]);
elseif strcmp(CheckingModeChoice,'Single')
    [StartingRecordingNum, ~] = listdlg('PromptString','Pick Recording To Check?','SelectionMode','single','ListString',RecordingChoiceOptions,'ListSize', [500 600]);
    RecordingNums=[StartingRecordingNum];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
KeepChecking=1;
RecordingNum1=1;
while KeepChecking&&RecordingNum1<=length(RecordingNums)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    RecordingNum=RecordingNums(RecordingNum1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
            clearvars -except myPool dc OS compName MatlabVersion MatlabVersionYear ScreenSize CurrentScratchDir ScratchDir LabDefaults...
                CurrentParentDir ParentDir ParentDir1 ParentDir2 ParentDir3 StackSaveName...
                Recording currentFolder File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions BatchMode AnalysisPartsChoiceOptions AnalysisPartOptions RecordingChoiceOptions Function RecordingNum RecordingNum1 RecordingNums LastRecording...
                LoopCount File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort Function ErrorTolerant BrokeLoop AbortButton BufferSize Port PortChoice PortOptions PortOptionsText TimeOut NumLoops ServerIP BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
                RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode BatchMode Users
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
    if any(FlaggedRecordings==RecordingNum)
        warning([RecordingChoiceOptions{RecordingNum},' Already Flagged!'])
        ClearAllFlags = questdlg({[RecordingChoiceOptions{RecordingNum},' Already Flagged!'];'Re-Check?'},'Re-Check?','Re-Check','Skip','Skip');
        if strcmp(ClearAllFlags,'Re-Check')
            CheckRecording=1; 
        else
            CheckRecording=0; 
        end
    else
       CheckRecording=1; 
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    if CheckRecording

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        %Initial Settings from Recording
        [OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(0);
        cd([Recording(RecordingNum).dir]);
        SaveName=Recording(RecordingNum).SaveName;
        StackSaveName=Recording(RecordingNum).StackSaveName;
        ImageSetSaveName=Recording(RecordingNum).ImageSetSaveName;
        ModalitySuffix=Recording(RecordingNum).ModalitySuffix;
        BoutonSuffix=Recording(RecordingNum).BoutonSuffix;
        LoadDir=Recording(RecordingNum).dir;
        fprintf('====================================================================================\n')
        fprintf('====================================================================================\n')
        fprintf('====================================================================================\n')
        fprintf('====================================================================================\n')
        disp(['Checking ',AnalysisLabel,' for File#',num2str(RecordingNum),' ',StackSaveName]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('============================================================')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        run('Quantal_Analysis_Watch_Movie_Records.m')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        warning on
        FlagChoice = questdlg({['Flag ',AnalysisLabel,' for'];['Recording #',num2str(RecordingNum)];[StackSaveName,'?']},'Flag?','Good','Flag','Good');
        if strcmp(FlagChoice,'Good')
            Flag=0;
        elseif strcmp(FlagChoice,'Flag')
            Flag=1;
        end
        if Flag
            warning(['Flagging Recording #',num2str(RecordingNum),' ',StackSaveName])
            if ~any(FlaggedRecordings==RecordingNum)
                FlaggedCount=FlaggedCount+1;
                FlaggedRecordings(FlaggedCount)=RecordingNum;
            else
                warning('Already in list!')
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            AdjustChoice = questdlg({['Flagged ',AnalysisLabel,' for'];['Recording #',num2str(RecordingNum),' ',StackSaveName];'Adjust Settings Now?'},...
                'Adjust Settings?','Adjust','Skip','Adjust');
            if strcmp(AdjustChoice,'Adjust')
                AdjustONLY=1;
                run(Function)
            elseif strcmp(AdjustChoice,'Skip')
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        [OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(0);
        cd([Recording(RecordingNum).dir]);
        SaveName=Recording(RecordingNum).SaveName;
        StackSaveName=Recording(RecordingNum).StackSaveName;
        ImageSetSaveName=Recording(RecordingNum).ImageSetSaveName;
        ModalitySuffix=Recording(RecordingNum).ModalitySuffix;
        BoutonSuffix=Recording(RecordingNum).BoutonSuffix;
        LoadDir=Recording(RecordingNum).dir;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        %Cleanup
        if exist([ScratchDir,StackSaveName,dc])
            warning('Deleting StackSaveName-Specific ScrachDir Directory...')
            try
                rmdir([ScratchDir,StackSaveName,dc],'s');
            catch
                warning('Problem Deleting StackSaveName-Specific ScrachDir Directory')
                warning('Trying to remove the Movie Directory Only...')
                try
                    rmdir(MoviesScratchDir,'s');
                catch
                    warning('Problem Deleting Movie ScrachDir Directory')
                end
            end
        end
        fprintf('====================================================================================\n')
        fprintf('====================================================================================\n')
        fprintf('====================================================================================\n')
        fprintf('====================================================================================\n')
        disp(['Finished Checking ',AnalysisLabel,' for File#',num2str(RecordingNum),' ',StackSaveName]);
        fprintf('====================================================================================\n')
        fprintf('====================================================================================\n')
        fprintf('====================================================================================\n')
        fprintf('====================================================================================\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
            clearvars -except myPool dc OS compName MatlabVersion MatlabVersionYear ScreenSize CurrentScratchDir ScratchDir LabDefaults...
                CurrentParentDir ParentDir ParentDir1 ParentDir2 ParentDir3 StackSaveName...
                Recording currentFolder File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions BatchMode AnalysisPartsChoiceOptions AnalysisPartOptions RecordingChoiceOptions Function RecordingNum RecordingNum1 RecordingNums LastRecording...
                LoopCount File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort Function ErrorTolerant BrokeLoop AbortButton BufferSize Port PortChoice PortOptions PortOptionsText TimeOut NumLoops ServerIP BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
                RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode BatchMode Users
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    if RecordingNum1<length(RecordingNums)
        ContinueChoice = questdlg({['Checked ',num2str(RecordingNum1),'/',num2str(length(RecordingNums)),' Flagged'];...
            ['Flagged ',num2str(FlaggedCount),'/',num2str(length(RecordingNums)),' Flagged'];'Keep Checking?'},...
            'Keep Checking?','Continue','Exit','Continue');
        if strcmp(ContinueChoice,'Continue')
            KeepChecking=1;
            RecordingNum1=RecordingNum1+1;
        else
            KeepChecking=0;
        end
    else
        KeepChecking=0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Export new list for fixing
if FlaggedCount>0
    warning on
    warning(['Flagged ',num2str(FlaggedCount),' Files!'])
    warning(['FlaggedRecordings = ',num2str(FlaggedRecordings)])
    FileRecord_Dir=[ScratchDir,'Fixing Lists'];
    if ~exist(FileRecord_Dir)
        mkdir(FileRecord_Dir)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    warning('I currently only have the default parent directories set up for a few folks, but you can add more options here when re-generating fixing lists')
    FoundCurrentParentDir=[];
    if strcmp(CurrentParentDir,'z:\Enterprise Image Analysis 4\')
        FoundCurrentParentDir='ParentDir';
    elseif strcmp(CurrentParentDir,'z:\Enterprise Image Analysis\')
        FoundCurrentParentDir='ParentDir1';
    elseif strcmp(CurrentParentDir,'z:\Enterprise Image Analysis 2\')
        FoundCurrentParentDir='ParentDir2';
    elseif strcmp(CurrentParentDir,'z:\Enterprise Image Analysis 3\')
        FoundCurrentParentDir='ParentDir3';
    elseif strcmp(CurrentParentDir,'U:\Enterprise Image Analysis\')
        FoundCurrentParentDir='DariyaParentDir';
    elseif strcmp(CurrentParentDir,'D:\Enterprise Image Analysis\')
        FoundCurrentParentDir='RyanParentDir';
    else
        warning('Unable to match tthe CurrentParentDir to default options...')
    end
    warning(['FoundCurrentParentDir = ',CurrentParentDir])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    CurrentDateTime=clock;
    Year=num2str(CurrentDateTime(1)-2000);Month=num2str(CurrentDateTime(2));Day=num2str(CurrentDateTime(3));Hour=num2str(CurrentDateTime(4));Minute=num2str(CurrentDateTime(5));Second=num2str(CurrentDateTime(6));
    if length(Month)<2;Month=['0',Month];end;if length(Day)<2;Day=['0',Day];end
    cd(FileRecord_Dir)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Export RecordingLists_Stage2.txt Ib/Is Merge
    disp('======================================================');
    disp('Generating new RecordingLists_Stage2.txt List...')
    clear InfoArray
    CurrentLine=0;
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}=['% NOTE: fix ',AnalysisLabel];
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
%     CurrentLine=CurrentLine+1;
%     InfoArray{CurrentLine,1}=['if ~exist(CurrentParentDir)'];
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}=['CurrentParentDir=','ParentDir',';'];
%     CurrentLine=CurrentLine+1;
%     InfoArray{CurrentLine,1}=['end'];
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}=['if isempty(CurrentParentDir);warning(''Please Select/Include CurrentParentDir to load files from'');CurrentParentDir=uigetdir(''Select a CurrentParentDir Directory'');end'];
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    for i=1:FlaggedCount
        disp(['Flagged: ',Recording(FlaggedRecordings(i)).ImageSetSaveName])
        [~, TempDir] = fileparts(Recording(FlaggedRecordings(i)).dir);
        InfoArray{CurrentLine+1,1}=['RecNum=RecNum+1;'];
        InfoArray{CurrentLine+2,1}=['Recording(RecNum).dir=               [CurrentParentDir,''',TempDir,'''];'];
        InfoArray{CurrentLine+3,1}=['Recording(RecNum).SaveName=          ''',Recording(FlaggedRecordings(i)).SaveName,'''',';'];
        InfoArray{CurrentLine+4,1}=['Recording(RecNum).ModalitySuffix=    ''',Recording(FlaggedRecordings(i)).ModalitySuffix,''';'];
        InfoArray{CurrentLine+5,1}=['Recording(RecNum).BoutonSuffix=      [];'];
        InfoArray{CurrentLine+6,1}=['Recording(RecNum).ImageSetSaveName=  ''',Recording(FlaggedRecordings(i)).ImageSetSaveName,''';'];
        InfoArray{CurrentLine+7,1}=['Recording(RecNum).StackSaveName=     ''',Recording(FlaggedRecordings(i)).ImageSetSaveName,''';'];
        CurrentLine=CurrentLine+8;
        InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
        disp(['Successfully added: ',Recording(FlaggedRecordings(i)).ImageSetSaveName])
    end
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dlmcell([FileRecord_Dir,dc,(Year),(Month),(Day),' To Be Fixed RecordingLists_Stage2.txt'], InfoArray);
    open([FileRecord_Dir,dc,(Year),(Month),(Day),' To Be Fixed RecordingLists_Stage2.txt']);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Export RecordingLists_Stage1.txt Separate Bouton
    disp('======================================================');
    disp('Generating new RecordingLists_Stage1.txt List...')
    clear InfoArray
    CurrentLine=0;
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}=['% NOTE: fix ',AnalysisLabel];
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
%     CurrentLine=CurrentLine+1;
%     InfoArray{CurrentLine,1}=['if ~exist(CurrentParentDir)'];
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}=['CurrentParentDir=','ParentDir',';'];
%     CurrentLine=CurrentLine+1;
%     InfoArray{CurrentLine,1}=['end'];
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}=['if isempty(CurrentParentDir);warning(''Please Select/Include CurrentParentDir to load files from'');CurrentParentDir=uigetdir(''Select a CurrentParentDir Directory'');end'];
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    for i=1:FlaggedCount
        disp(['Flagged: ',Recording(FlaggedRecordings(i)).ImageSetSaveName])
        [~, TempDir] = fileparts(Recording(FlaggedRecordings(i)).dir);
        InfoArray{CurrentLine+1,1}=['RecNum=RecNum+1;'];
        InfoArray{CurrentLine+2,1}=['Recording(RecNum).dir=               [CurrentParentDir,''',TempDir,'''];'];
        InfoArray{CurrentLine+3,1}=['Recording(RecNum).SaveName=          ''',Recording(FlaggedRecordings(i)).SaveName,'''',';'];
        InfoArray{CurrentLine+4,1}=['Recording(RecNum).ModalitySuffix=    ''',Recording(FlaggedRecordings(i)).ModalitySuffix,''';'];
        InfoArray{CurrentLine+5,1}=['Recording(RecNum).BoutonSuffix=      ''',Recording(FlaggedRecordings(i)).BoutonSuffix,''';'];
        InfoArray{CurrentLine+6,1}=['Recording(RecNum).ImageSetSaveName=  ''',Recording(FlaggedRecordings(i)).ImageSetSaveName,''';'];
        InfoArray{CurrentLine+7,1}=['Recording(RecNum).StackSaveName=     ''',Recording(FlaggedRecordings(i)).StackSaveName,''';'];
        CurrentLine=CurrentLine+8;
        InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
        disp(['Successfully added: ',Recording(FlaggedRecordings(i)).StackSaveName])
    end
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dlmcell([FileRecord_Dir,dc,(Year),(Month),(Day),' To Be Fixed RecordingLists_Stage1.txt'], InfoArray);
    open([FileRecord_Dir,dc,(Year),(Month),(Day),' To Be Fixed RecordingLists_Stage1.txt']);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('======================================================');
        
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Cleanup
for RecordingNum1=1:length(RecordingNums)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    RecordingNum=RecordingNums(RecordingNum1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %Initial Settings from Recording
    [OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(0);
    cd([Recording(RecordingNum).dir]);
    SaveName=Recording(RecordingNum).SaveName;
    StackSaveName=Recording(RecordingNum).StackSaveName;
    ImageSetSaveName=Recording(RecordingNum).ImageSetSaveName;
    ModalitySuffix=Recording(RecordingNum).ModalitySuffix;
    BoutonSuffix=Recording(RecordingNum).BoutonSuffix;
    LoadDir=Recording(RecordingNum).dir;
    fprintf('====================================================================================\n')
    disp(['Cleaning UP Checking ',AnalysisLabel,' for File#',num2str(RecordingNum),' ',StackSaveName]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('============================================================')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %Directories
    CurrentSaveDir=[Recording(RecordingNum).dir,dc,ModalitySuffix,BoutonSuffix,dc];
    CurrentSaveDir1=[Recording(RecordingNum).dir,dc,ModalitySuffix,dc];
    CurrentSaveDir2=[Recording(RecordingNum).dir,dc];
    CurrentScratchDir=[ScratchDir,StackSaveName,dc,ModalitySuffix,BoutonSuffix,dc];
    CurrentScratchDir1=[ScratchDir,StackSaveName,dc,ModalitySuffix,dc];
    CurrentScratchDir2=[ScratchDir,StackSaveName,dc];
    MoviesScratchDir=[CurrentScratchDir,'Movies',dc,AnalysisLabelShort];
    if exist([ScratchDir,Recording(RecordingNum).StackSaveName,dc])
        warning('Deleting StackSaveName-Specific ScrachDir Directory...')
        try
            rmdir([ScratchDir,Recording(RecordingNum).StackSaveName,dc],'s');
        catch
            warning('Problem Deleting StackSaveName-Specific ScrachDir Directory')
            warning('Trying to remove the Movie Directory Only...')
            try
                rmdir(MoviesScratchDir,'s');
            catch
                warning('Problem Deleting Movie ScrachDir Directory')
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
