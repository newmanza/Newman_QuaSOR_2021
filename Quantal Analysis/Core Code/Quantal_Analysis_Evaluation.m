
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if ~exist('RecordingNum')
        RecNum=0;
        RecordingChoiceOptions=[];
        for RecNum=1:length(Recording)
            RecordingChoiceOptions{RecNum}=['Rec #',num2str(RecNum),': ',Recording(RecNum).StackSaveName];
        end
        [RecordingNum, ~] = listdlg('PromptString','Select RecordingNum?','SelectionMode','single','ListString',RecordingChoiceOptions,'ListSize', [500 600]);
    end
    if ~exist('AnalysisParts')
        [AnalysisPartsChoice, ~] = listdlg('PromptString','Select Analysis Parts?','SelectionMode','single','ListString',AnalysisPartsChoiceOptions,'ListSize', [400 600]);
        AnalysisParts=AnalysisPartOptions{AnalysisPartsChoice};
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
[OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Starting ',AnalysisLabel,' On ',RecordingChoiceOptions{RecordingNum}])
TimeStamp=datestr(now);
TrackerDir=[Recording(RecordingNum).dir,dc,'Trackers',dc];
save([TrackerDir,Recording(RecordingNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'],'TimeStamp','OS','compName','MatlabVersion','MatlabVersionYear')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Initial Settings from Recording
    [OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(1);
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
%Directories
    SaveDir=[Recording(RecordingNum).dir,dc,ModalitySuffix,BoutonSuffix,dc];
    SaveDir1=[Recording(RecordingNum).dir,dc,ModalitySuffix,dc];
    SaveDir2=[Recording(RecordingNum).dir,dc];
    CurrentScratchDir=[ScratchDir,StackSaveName,dc,ModalitySuffix,BoutonSuffix,dc];
    CurrentScratchDir1=[ScratchDir,StackSaveName,dc,ModalitySuffix,dc];
    CurrentScratchDir2=[ScratchDir,StackSaveName,dc];
    if ~exist(CurrentScratchDir)
        mkdir(CurrentScratchDir)
    end
    if ~exist(CurrentScratchDir1)
        mkdir(CurrentScratchDir1)
    end
    if ~exist(CurrentScratchDir2)
        mkdir(CurrentScratchDir2)
    end
    FigureSaveDir=[SaveDir,'Figures',dc,AnalysisLabelShort];
    if ~exist(FigureSaveDir)
        mkdir(FigureSaveDir)
    end
    FigureScratchDir=[CurrentScratchDir,'Figures',dc,AnalysisLabelShort];
    if ~exist(FigureScratchDir)
        mkdir(FigureScratchDir)
    end
    MoviesSaveDir=[SaveDir,'Movies',dc,AnalysisLabelShort];
    if ~exist(MoviesSaveDir)
        mkdir(MoviesSaveDir)
    end
    MoviesScratchDir=[CurrentScratchDir,'Movies',dc,AnalysisLabelShort];
    if ~exist(MoviesScratchDir)
        mkdir(MoviesScratchDir)
    end
    if any(strfind(BoutonSuffix,'Ib'))
        BoutonCount=1;
    elseif any(strfind(BoutonSuffix,'Is'))
        BoutonCount=2;
    else
        BoutonCount=0;
    end
    Safe2CopyDelete=1;
    if strcmp([SaveDir],[CurrentScratchDir])||...
            strcmp([SaveDir],[CurrentScratchDir])||...
            strcmp([SaveDir],[CurrentScratchDir,dc])
        Safe2CopyDelete=0;
        warning('CurrentScratchDir and SaveDir are the same')
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    RegComplete=0;
    FileSuffix='_DeltaFData.mat';
    if exist([SaveDir,StackSaveName,FileSuffix])
        RegComplete=1;
    end
    DetectComplete=0;
    FileSuffix='_EventDetectionData.mat';
    if exist([SaveDir,StackSaveName,FileSuffix])
        DetectComplete=1;
    end
    QuaSORComplete=0;
    FileSuffix='_QuaSOR_Evaluation.mat';
    if exist([SaveDir,StackSaveName,FileSuffix])
        QuaSORComplete=1;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%Load Data
    disp('============================================================')
    disp(['Prepping ',AnalysisLabel,' on File#',num2str(RecordingNum),' ',StackSaveName]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('============================================================')
    FileSuffix='_Analysis_Setup.mat';
    if ~exist([SaveDir,StackSaveName,FileSuffix])
        error([StackSaveName,FileSuffix,' Missing!']);
    else
        FileInfo = dir([SaveDir,StackSaveName,FileSuffix]);
        TimeStamp = FileInfo.date;
        CurrentDateNum=FileInfo.datenum;
        disp([StackSaveName,FileSuffix,' Last updated: ',TimeStamp]);
        if Safe2CopyDelete
            if ~exist([CurrentScratchDir,StackSaveName,FileSuffix])
                fprintf(['Copying ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
                [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
                if CopyStatus
                    fprintf('Copy successful!\n')
                else
                    error(CopyMessage)
                end    
            end
        end
    end
    fprintf(['Loading ',StackSaveName,FileSuffix,'...']);
    load([CurrentScratchDir,StackSaveName,FileSuffix]);
    fprintf('Finished!\n')
    disp('============================================================')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%Overall Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%Add Missing Variables
    AbortButton=1;
    if ~exist('AdjustONLY')
        AdjustONLY=0;
    end
    if ~exist('DebugMode')
        DebugMode=0;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Main Sector
fprintf(['==========================================================================================\n'])
fprintf(['==========================================================================================\n'])
fprintf(['==========================================================================================\n'])
fprintf(['==========================================================================================\n'])
fprintf(['==========================================================================================\n'])
fprintf(['==========================================================================================\n'])
OverallTimer=tic;
fprintf(['Starting ',AnalysisLabel,' File # ',num2str(RecordingNum),' ',StackSaveName,'\n']);
if DebugMode
    error('Stopping because in Debug Mode!')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Add Code Here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
KeepEvaluating=1;
while KeepEvaluating
    if RegComplete&&DetectComplete&&QuaSORComplete
        EvalChoice = questdlg({['Currently Evaluating: ',StackSaveName];'Which analysis sector do you want to evaluate?'},...
            'Evaluation Sector?','Registration','Event Detection','QuaSOR Fitting','QuaSOR Fitting');
    elseif RegComplete&&DetectComplete&&~QuaSORComplete
        EvalChoice = questdlg({['Currently Evaluating: ',StackSaveName];'Which analysis sector do you want to evaluate?'},...
            'Evaluation Sector?','Registration','Event Detection','Event Detection');
    elseif RegComplete&&~DetectComplete&&~QuaSORComplete
        EvalChoice = 'Registration';
    else
       error('Doesnt look like you have done any of the analysis sectors yet!') 
    end
    switch EvalChoice
        case 'Registration'
            run('Quantal_Analysis_Registration_Evaluation.m')
        case 'Event Detection'
            run('Quantal_Analysis_Event_Detection_Evaluation.m')
        case 'QuaSOR Fitting'
            run('Quantal_Analysis_QuaSOR_Evaluation.m')
    end
    KeepCheckingChoice = questdlg({['Currently Evaluating: ',StackSaveName];'Repeat or choose different section?'},...
        'Repeat Evaluation?','Repeat','Continue','Continue');
    switch KeepCheckingChoice
        case 'Repeat'
            KeepEvaluating=1;
        case 'Continue'
            KeepEvaluating=0;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Copy files from CurrentScratchDir and delete
if Safe2CopyDelete
    warning on
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Deleting some ScratchDir Files...')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_DeltaFData.mat';
    if exist([CurrentScratchDir,StackSaveName,FileSuffix])
        fprintf(['Deleting CurrentScratchDir: ',StackSaveName,FileSuffix,'...'])
        delete([CurrentScratchDir,StackSaveName,FileSuffix]);
        fprintf('Finished\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if SplitEpisodeFiles
        for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
            if exist([CurrentScratchDir,StackSaveName,FileSuffix])
                if Safe2CopyDelete
                    fprintf(['Deleting ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
                    delete([CurrentScratchDir,StackSaveName,FileSuffix])
                    fprintf('Finished!\n')
                else
                    fprintf('Finished!\n')
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_EventDetectionData.mat';
    if exist([CurrentScratchDir,StackSaveName,FileSuffix])
        fprintf(['Deleting CurrentScratchDir: ',StackSaveName,FileSuffix,'...'])
        delete([CurrentScratchDir,StackSaveName,FileSuffix]);
        fprintf('Finished\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if SplitEpisodeFiles
        for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            FileSuffix=['_EventDetectionData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
            if exist([CurrentScratchDir,StackSaveName,FileSuffix])
                if Safe2CopyDelete
                    fprintf(['Deleting ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
                    delete([CurrentScratchDir,StackSaveName,FileSuffix])
                    fprintf('Finished!\n')
                else
                    fprintf('Finished!\n')
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_QuaSOR_Evaluation.mat';
    if exist([CurrentScratchDir,StackSaveName,FileSuffix])
        fprintf(['Deleting CurrentScratchDir: ',StackSaveName,FileSuffix,'...'])
        delete([CurrentScratchDir,StackSaveName,FileSuffix]);
        fprintf('Finished\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if SplitEpisodeFiles
        for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            FileSuffix=['_QuaSOR_Evaluation_Ep_',num2str(EpisodeNumber_Load),'.mat'];
            if exist([CurrentScratchDir,StackSaveName,FileSuffix])
                if Safe2CopyDelete
                    fprintf(['Deleting ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
                    delete([CurrentScratchDir,StackSaveName,FileSuffix])
                    fprintf('Finished!\n')
                else
                    fprintf('Finished!\n')
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_Analysis_Setup.mat';
    if exist([CurrentScratchDir,StackSaveName,FileSuffix])
        fprintf(['Deleting CurrentScratchDir: ',StackSaveName,FileSuffix,'...'])
        delete([CurrentScratchDir,StackSaveName,FileSuffix]);
        fprintf('Finished\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_ImageData.mat';
    if exist([CurrentScratchDir,StackSaveName,FileSuffix])
        fprintf(['Deleting CurrentScratchDir: ',ImageSetSaveName,FileSuffix,'...'])
        delete([CurrentScratchDir,ImageSetSaveName,FileSuffix]);
        fprintf('Finished\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Copying Files to SaveDir...')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_QuaSOR_Data.mat';
    if exist([CurrentScratchDir,StackSaveName,FileSuffix])
        fprintf(['Deleting CurrentScratchDir: ',StackSaveName,FileSuffix,'...'])
        delete([CurrentScratchDir,StackSaveName,FileSuffix]);
        fprintf('Finished\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_QuaSOR_Maps.mat';
    if exist([CurrentScratchDir,StackSaveName,FileSuffix])
        fprintf(['Deleting CurrentScratchDir: ',StackSaveName,FileSuffix,'...'])
        delete([CurrentScratchDir,StackSaveName,FileSuffix]);
        fprintf('Finished\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_QuaSOR_AZs.mat';
    if exist([CurrentScratchDir,StackSaveName,FileSuffix])
        fprintf(['Deleting CurrentScratchDir: ',StackSaveName,FileSuffix,'...'])
        delete([CurrentScratchDir,StackSaveName,FileSuffix]);
        fprintf('Finished\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if exist([CurrentScratchDir,'Figures'])
%         fprintf(['Copying: Figures...'])
%         [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,'Figures'],[SaveDir,'Figures']);
%         if CopyStatus
%             disp('Copy successful!')
%             warning('Deleting CurrentScratchDir Version')
%             try
%                 rmdir([CurrentScratchDir,'Figures'],'s')
%             catch
%                 warning('Unable to remove Figure Directory!')
%             end
%         else
%             error(CopyMessage)
%         end       
%     end
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if exist([CurrentScratchDir,'Movies'])
%         fprintf(['Copying: Movies...'])
%         [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,'Movies'],[SaveDir,'Movies']);
%         if CopyStatus
%             disp('Copy successful!')
%             warning('Deleting CurrentScratchDir Version')
%             try
%                 rmdir([CurrentScratchDir,'Movies'],'s')
%             catch
%                 warning('Unable to remove Movies Directory!')
%             end
%         else
%             error(CopyMessage)
%         end         
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist([CurrentScratchDir])
        warning('Removing CurrentScratchDir')
        try
            rmdir([CurrentScratchDir],'s')
        catch
            warning('Unable to remove CurrentScratchDir!')
        end
    end
    if exist([CurrentScratchDir1])
        warning('Removing CurrentScratchDir1')
        try
            rmdir([CurrentScratchDir1],'s')
        catch
            warning('Unable to remove CurrentScratchDir1!')
        end
    end
    if exist([CurrentScratchDir2])
        warning('Removing CurrentScratchDir2')
        try
            rmdir([CurrentScratchDir2],'s')
        catch
            warning('Unable to remove CurrentScratchDir2!')
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    warning('SaveDir and CurrentScratchDir are the same so not copying or deleting!')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
OverallTime=toc(OverallTimer);
fprintf(['Finished ',AnalysisLabel,' File # ',num2str(RecordingNum),' ',StackSaveName,'\n']);
fprintf(['Analysis took ',num2str((round(OverallTime*10)/10)/60),' min\n']);
fprintf(['==========================================================================================\n'])
fprintf(['==========================================================================================\n'])
fprintf(['==========================================================================================\n'])
fprintf(['==========================================================================================\n'])
fprintf(['==========================================================================================\n'])
fprintf(['==========================================================================================\n'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
disp(['Finished ',AnalysisLabel,' On ',RecordingChoiceOptions{RecordingNum}])
TrackerDir=[Recording(RecordingNum).dir,dc,'Trackers',dc];
if exist([TrackerDir,Recording(RecordingNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
    fprintf('Deleting Currently Running Tracking File...')
    delete([TrackerDir,Recording(RecordingNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
    fprintf('Finished!\n')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(0);
SaveName=Recording(RecordingNum).SaveName;
StackSaveName=Recording(RecordingNum).StackSaveName;
ImageSetSaveName=Recording(RecordingNum).ImageSetSaveName;
ModalitySuffix=Recording(RecordingNum).ModalitySuffix;
BoutonSuffix=Recording(RecordingNum).BoutonSuffix;
LoadDir=Recording(RecordingNum).dir;
TrackerDir=[Recording(RecordingNum).dir,dc,'Trackers',dc];
if ~exist(TrackerDir)
    mkdir(TrackerDir)
end
fprintf(['Updating ',StackSaveName,File2Check,'...'])
Tracker=1;
CurrentComputer=compName;
CurrentOS=OS;
BatchChoice=[];
save([TrackerDir,dc,StackSaveName,File2Check],'Tracker','CurrentComputer','CurrentOS','BatchChoice'); 
FileInfo = dir([TrackerDir,StackSaveName,File2Check]);
TimeStamp = FileInfo.date;
fprintf('Finished!\n')
disp([StackSaveName,File2Check,' Last updated: ',TimeStamp,' [',CurrentComputer,' (',CurrentOS,')]']);  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist([ScratchDir,Recording(RecordingNum).StackSaveName,dc,'TempFiles',dc])
    warning('Deleting Temp File Directory...')
    rmdir([ScratchDir,Recording(RecordingNum).StackSaveName,dc,'TempFiles',dc],'s');
end
if exist([ScratchDir,Recording(RecordingNum).StackSaveName,dc])
    warning('Deleting StackSaveName-Specific ScrachDir Directory...')
    rmdir([ScratchDir,Recording(RecordingNum).StackSaveName,dc],'s');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except myPool dc OS compName ClentCompName MatlabVersion MatlabVersionYear ScreenSize CurrentScratchDir ScratchDir LabDefaults...
    CurrentParentDir ParentDir ParentDir1 ParentDir2 ParentDir3...
    Recording Client_Recording Server_Recording currentFolder File2Check AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions BatchMode AnalysisPartsChoiceOptions AnalysisPartOptions RecordingChoiceOptions Function RecordingNum RecordingNum1 RecordingNums LastRecording...
    LoopCount File2Check AnalysisLabel AnalysisLabelShort Function ErrorTolerant BrokeLoop AbortButton BufferSize Port PortChoice PortOptions PortOptionsText TimeOut NumLoops ServerIP BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
    RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode AdjustOnly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    








