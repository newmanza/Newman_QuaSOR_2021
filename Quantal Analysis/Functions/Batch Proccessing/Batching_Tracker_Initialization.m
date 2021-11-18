[OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for RecordingNum=1:size(Recording,2)
    SaveName=Recording(RecordingNum).SaveName;
    StackSaveName=Recording(RecordingNum).StackSaveName;
    ImageSetSaveName=Recording(RecordingNum).ImageSetSaveName;
    ModalitySuffix=Recording(RecordingNum).ModalitySuffix;
    BoutonSuffix=Recording(RecordingNum).BoutonSuffix;
    LoadDir=Recording(RecordingNum).dir;
    SaveDir=[Recording(RecordingNum).dir,dc,ModalitySuffix,BoutonSuffix,dc];
    SaveDir1=[Recording(RecordingNum).dir,dc,ModalitySuffix,dc];
    SaveDir2=[Recording(RecordingNum).dir,dc];
    TrackerDir=[Recording(RecordingNum).dir,dc,'Trackers',dc];
    if ~exist(TrackerDir)
        mkdir(TrackerDir)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('============================================================')
    disp(['Checking for Necessary Files to run: ',AnalysisLabel])
    disp(['Checking Rec#',num2str(RecordingNum),' ',StackSaveName]);
    switch AnalysisLabel
        case 'Registration'
            FileSuffix='_Analysis_Setup.mat';
            if ~exist([SaveDir,StackSaveName,FileSuffix])
                error([StackSaveName,FileSuffix,' Missing!']);
            else
                FileInfo = dir([SaveDir,StackSaveName,FileSuffix]);
                TimeStamp = FileInfo.date;
                disp([StackSaveName,FileSuffix,' Last updated: ',TimeStamp]);
            end
            FileSuffix='_ImageData.mat';
            if ~exist([SaveDir1,ImageSetSaveName,FileSuffix])
                error([ImageSetSaveName,FileSuffix,' Missing!']);  
            else
                FileInfo = dir([SaveDir1,ImageSetSaveName,FileSuffix]);
                TimeStamp = FileInfo.date;
                disp([ImageSetSaveName,FileSuffix,' Last updated: ',TimeStamp]);  
            end
        case 'EventDetection'
            FileSuffix='_Analysis_Setup.mat';
            if ~exist([SaveDir,StackSaveName,FileSuffix])
                error([StackSaveName,FileSuffix,' Missing!']);
            else
                FileInfo = dir([SaveDir,StackSaveName,FileSuffix]);
                TimeStamp = FileInfo.date;
                disp([StackSaveName,FileSuffix,' Last updated: ',TimeStamp]);
            end
            FileSuffix='_DeltaFData.mat';
            if ~exist([SaveDir,StackSaveName,FileSuffix])
                error([StackSaveName,FileSuffix,' Missing!']);
            else
                FileInfo = dir([SaveDir,StackSaveName,FileSuffix]);
                TimeStamp = FileInfo.date;
                disp([StackSaveName,FileSuffix,' Last updated: ',TimeStamp]);
            end
        case 'QuaSOR'
            FileSuffix='_Analysis_Setup.mat';
            if ~exist([SaveDir,StackSaveName,FileSuffix])
                error([StackSaveName,FileSuffix,' Missing!']);
            else
                FileInfo = dir([SaveDir,StackSaveName,FileSuffix]);
                TimeStamp = FileInfo.date;
                disp([StackSaveName,FileSuffix,' Last updated: ',TimeStamp]);
            end
            FileSuffix='_EventDetectionData.mat';
            if ~exist([SaveDir,StackSaveName,FileSuffix])
                error([StackSaveName,FileSuffix,' Missing!']);
            else
                FileInfo = dir([SaveDir,StackSaveName,FileSuffix]);
                TimeStamp = FileInfo.date;
                disp([StackSaveName,FileSuffix,' Last updated: ',TimeStamp]);
            end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~exist([TrackerDir,StackSaveName,File2Check])
        warning([StackSaveName,File2Check,' Does Not exist, generating for tracking...']);  
        Tracker=0;
        CurrentComputer=compName;
        CurrentOS=OS;
        save([TrackerDir,dc,StackSaveName,File2Check],'Tracker','CurrentComputer','CurrentOS','BatchChoice'); 
    else
        load([TrackerDir,dc,StackSaveName,File2Check],'Tracker','CurrentComputer','CurrentOS')
        FileInfo = dir([TrackerDir,StackSaveName,File2Check]);
        TimeStamp = FileInfo.date;
        if ~exist('CurrentComputer')
            CurrentComputer=[];
        end
        if ~exist('CurrentOS')
            CurrentOS=[];
        end
        if ~exist('BatchChoice')
            BatchChoice=[];
        end
        disp([StackSaveName,File2Check,' Last updated: ',TimeStamp,' on ',CurrentComputer,' (',CurrentOS,'}']);  
        Tracker=0;
        CurrentComputer=compName;
        CurrentOS=OS;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CHeck for lingering raw data in the scratchdir
    CurrentScratchDir=[ScratchDir,SaveName,dc];
    FileSuffix='_Analysis_Setup.mat';
    if exist([SaveDir1,ImageSetSaveName,FileSuffix])
        load([SaveDir1,ImageSetSaveName,FileSuffix],'LoadingInfo')
        try
            if exist([CurrentScratchDir,dc,LoadingInfo.FileNames{1}])
                DeleteOldScratchDirRawFiles=InputWithVerification(['Found ',ImageSetSaveName,' ScratchDir Raw Files from Preparation, <1> to delete: '],{[],[1]},0);
                if DeleteOldScratchDirRawFiles
                    for fileCount=1:LoadingInfo.NumFiles
                        if exist([CurrentScratchDir,dc,LoadingInfo.FileNames{fileCount}])
                            warning(['Deleting CurrentScratchDir Raw files...File # ',num2str(fileCount),'  FileName: ',LoadingInfo.FileNames{fileCount},'...']);
                            delete([CurrentScratchDir,dc,LoadingInfo.FileNames{fileCount}])
                            warning('Successful!')
                        end
                    end
                end
            end
            if exist(CurrentScratchDir)
                DeleteOldScratchDir=InputWithVerification(['Found ',ImageSetSaveName,' ScratchDir from Preparation, <1> to delete: '],{[],[1]},0);
                if DeleteOldScratchDir
                    warning('REMOVING CurrentScratchDir...')
                    [SUCCESS,MESSAGE,MESSAGEID]=rmdir(CurrentScratchDir,'s');
                    if SUCCESS
                        warning('Successful!')
                    else
                        warning(MESSAGE)
                        warning('There is a bug when loading meta data from files...')
                        warning('you may need to try to close matlab before deleting the raw data from the scratch drive')
                    end
                end
            end
        catch
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%.
    disp('============================================================')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clearvars -except myPool dc OS compName MatlabVersion MatlabVersionYear ScreenSize CurrentScratchDir ScratchDir LabDefaults...
        CurrentParentDir ParentDir ParentDir1 ParentDir2 ParentDir3...
        Recording Client_Recording Server_Recording currentFolder File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions BatchMode AnalysisPartsChoiceOptions AnalysisPartOptions RecordingChoiceOptions Function RecordingNum RecordingNum1 RecordingNums LastRecording...
        LoopCount File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort Function ErrorTolerant BrokeLoop AbortButton BufferSize Port PortChoice PortOptions PortOptionsText TimeOut NumLoops ServerIP BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
        RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
