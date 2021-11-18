%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
if ~exist('AnalysisParts')
    [AnalysisPartsChoice, ~] = listdlg('PromptString','Select Analysis Parts?','SelectionMode','single','ListString',AnalysisPartsChoiceOptions,'ListSize', [600 600]);
    AnalysisParts=AnalysisPartOptions{AnalysisPartsChoice};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(BatchMode)
    if ~exist('RecordingNum')
        RecNum=0;
        RecordingChoiceOptions=[];
        for RecNum=1:length(Recording)
            RecordingChoiceOptions{RecNum}=['Rec #',num2str(RecNum),': ',Recording(RecNum).StackSaveName];
        end
        [RecordingNum, ~] = listdlg('PromptString','Select RecordingNum?','SelectionMode','single','ListString',RecordingChoiceOptions,'ListSize', [500 600]);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
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
else
    RecordingNum=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Directories
SaveDir=[LoadDir,dc,ModalitySuffix,BoutonSuffix,dc];
SaveDir1=[LoadDir,dc,ModalitySuffix,dc];
SaveDir2=[LoadDir,dc];
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
        fprintf(['Copying ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
        [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
        if CopyStatus
            fprintf('Copy successful!\n')
        else
            error(CopyMessage)
        end               
    end
end
fprintf(['Loading ',StackSaveName,FileSuffix,'...']);
load([CurrentScratchDir,StackSaveName,FileSuffix]);
fprintf('Finished!\n')
disp('============================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('============================================================')
FileSuffix='_DeltaFData.mat';
if ~exist([SaveDir,StackSaveName,FileSuffix])
    error([StackSaveName,FileSuffix,' Missing!']);
else
    FileInfo = dir([SaveDir,StackSaveName,FileSuffix]);
    TimeStamp = FileInfo.date;
    CurrentDateNum=FileInfo.datenum;
    disp([StackSaveName,FileSuffix,' Last updated: ',TimeStamp]);
    if Safe2CopyDelete
        fprintf(['Copying ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
        [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
        if CopyStatus
            fprintf('Copy successful!\n')
        else
            error(CopyMessage)
        end               
    end
end
fprintf(['Loading ',StackSaveName,FileSuffix,'...']);
load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct','EpisodeStructCurves','SplitEpisodeFiles');
fprintf('Finished!\n')
disp('============================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('SplitEpisodeFiles')
    SplitEpisodeFiles=0;
end
if SplitEpisodeFiles
    for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
        FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
        if Safe2CopyDelete
            fprintf(['Copying: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
            [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
            fprintf('Finished!\n')
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('============================================================')
FileSuffix='_EventDetectionData.mat';
if ~exist([SaveDir,StackSaveName,FileSuffix])
    warning([StackSaveName,FileSuffix,' Missing!']);
else
    FileInfo = dir([SaveDir,StackSaveName,FileSuffix]);
    TimeStamp = FileInfo.date;
    CurrentDateNum=FileInfo.datenum;
    disp([StackSaveName,FileSuffix,' Last updated: ',TimeStamp]);
    if Safe2CopyDelete
        fprintf(['Copying ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
        [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
        if CopyStatus
            fprintf('Copy successful!\n')
        else
            error(CopyMessage)
        end               
    end
    fprintf(['Loading ',StackSaveName,FileSuffix,'...']);
    load([CurrentScratchDir,StackSaveName,FileSuffix],'EventDetectionStruct','PixelMax_Struct',...
        'EpisodeArray_CorrAmp_Events_Thresh_Clean','EpisodeArray_CorrAmp_Events_Thresh_Clean_Norm','EpisodeArray_Max_Sharp',...
        'EventDetectionSettings','EventDetectionSettings','SplitEpisodeFiles','FullCorrAmpSave');
    fprintf('Finished!\n')
end
disp('============================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if SplitEpisodeFiles
    for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
        FileSuffix=['_EventDetectionData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
        if Safe2CopyDelete
            fprintf(['Copying: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
            [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
            fprintf('Finished!\n')
        end
    end
end
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
    FullCorrAmpSave=1;
    FigPosition=[0,10,1000,800];
    SelectionFigPosition=[0,50,1100, 700];
    if ~exist('AdjustONLY')
        AdjustONLY=0;
    end
    if ~exist('DebugMode')
        DebugMode=0;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%Basic Default Parameters Sets
clear DefaultEventDetectionSettings DefaultTemplateOptions
for zzzzz=1:1
    %Template Generator or Simple Detection Mode settings
    
    DefaultEventDetectionSettings.AutoTemplateGlobalPercentThresh=0.03;
    DefaultEventDetectionSettings.AutoTemplateEventPercentThresh=0.03;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.DataType=2;
    %DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSigma_px=1.2;
    %DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSize_px=9;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSigma_um=0.280;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSize_um=2.5;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.Amp_Thresh=0.1;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.Amp_Peak_Thresh=0.2;
    %DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinArea=30;
    %DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinVolume=50;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinArea_um2=1.2;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings_VolumeFrameScalar=2.5;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinVolume_um2=...
        DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinArea_um2*...
        DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings_VolumeFrameScalar;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinFramePersistence=2;
    %DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.EventMaxDistThresh_px=4;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.EventMaxDistThresh_um=0.8;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.EventMaxFrameTimeDistance=3;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.Roundness_Test=0;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.Roundness_Test_Threshold=0.5;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.Active_Frames=[];
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.ExclusionFrames=[];
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.EventPerFrameCutoff=20;
    %DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.Trace_Mask_Radius_px=5;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.Trace_Mask_Radius_um=0.1;
    
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSigma_px=...
        DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSigma_um/ImagingInfo.PixelSize;
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSize_px=...
        ceil(DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSize_um/ImagingInfo.PixelSize);
    if rem(DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSize_px,2)==0
        DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSize_px=DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSize_px+1;
    end
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinArea=...
        ceil(DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinArea_um2/...
        ImagingInfo.PixelSize^2);
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinVolume=...
        ceil(DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinVolume_um2/...
        ImagingInfo.PixelSize^2);
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.EventMaxDistThresh_px=...
        ceil(DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.EventMaxDistThresh_um/ImagingInfo.PixelSize);
    DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.Trace_Mask_Radius_px=...
        ceil(DefaultEventDetectionSettings.Simple_Auto_Event_Finder_Settings.Trace_Mask_Radius_um/ImagingInfo.PixelSize);
    
    
    if ImagingInfo.ModalityType==1
         if ImagingInfo.NumEpisodes<5
            DefaultEventDetectionSettings.SimpleEventTestEpisodes=[1];
        else
            DefaultEventDetectionSettings.SimpleEventTestEpisodes=[1:5];
         end
       if ImagingInfo.ImagingFrequency<=20
            DefaultEventDetectionSettings.SimpleEventTestFrameWindow=[];
        else
            DefaultEventDetectionSettings.SimpleEventTestFrameWindow=[];
        end
    elseif ImagingInfo.ModalityType==2
            DefaultEventDetectionSettings.SimpleEventTestEpisodes=[1];
        if ImagingInfo.ImagingFrequency<=20
            DefaultEventDetectionSettings.SimpleEventTestFrameWindow=[4 8];
        else
            DefaultEventDetectionSettings.SimpleEventTestFrameWindow=[5 10];
        end
    elseif ImagingInfo.ModalityType==3
            DefaultEventDetectionSettings.SimpleEventTestEpisodes=[1];
        if ImagingInfo.ImagingFrequency<=20
            DefaultEventDetectionSettings.SimpleEventTestFrameWindow=[4 8];
        else
            DefaultEventDetectionSettings.SimpleEventTestFrameWindow=[5 10];
        end
    else
        DefaultEventDetectionSettings.SimpleEventTestEpisodes=[1];
        if ImagingInfo.ImagingFrequency<=20
            DefaultEventDetectionSettings.SimpleEventTestFrameWindow=[];
        else
            DefaultEventDetectionSettings.SimpleEventTestFrameWindow=[];
        end
    end
    %TestEpisodes
    if ImagingInfo.NumEpisodes<5
        DefaultEventDetectionSettings.SimpleEventTestEpisodes=[1];
    else
        DefaultEventDetectionSettings.SimpleEventTestEpisodes=[1:5];
    end
    %Main Default CorrAmp Settings
    if any(ImagingInfo.ModalityType==1)
    %Episodic DeltaFF0
        DefaultEventDetectionSettings.DataType=2;
        DefaultEventDetectionSettings.Corr_Thresh=0.1;
        DefaultEventDetectionSettings.StdFactor=1.5;
        DefaultEventDetectionSettings.MinGap=2;
        DefaultEventDetectionSettings.ReZeroDeltaF=0;
        DefaultEventDetectionSettings.TrueBaselinePercent=0;
        %%%%%%%%%%%
        DefaultEventDetectionSettings.Active_Frames=[ImagingInfo.PeakFrame-1:ImagingInfo.PeakFrame+2];
        DefaultEventDetectionSettings.ExclusionFrames=[];
        %%%%%%%%%%%
        DefaultEventDetectionSettings.AdvancedFittingFixing=0; %0 uses max of peak frames from template 1 is old FixSPlitting and 2 is advanced fix splitting, useful for cpx
        DefaultEventDetectionSettings.PersistenceChecker=0;
        DefaultEventDetectionSettings.PersistenceOption=2; %1 is sum 2 is max
        DefaultEventDetectionSettings.MaxPersistence=0;
        DefaultEventDetectionSettings.TrackingMaskMethod=0;
        DefaultEventDetectionSettings.MinAreaTrackingMask_um2=0;
        DefaultEventDetectionSettings.FrameFix=1; %when using any of the event split fixing there is often a frame or two shifting, you can manually correct that here
        %%%%%%%%%%%
        DefaultEventDetectionSettings.Event_Min_Area_um2=0.9;
        DefaultEventDetectionSettings.Event_SizeAmp_Threshold_1=[]; 
        DefaultEventDetectionSettings.Event_SizeAmp_Min_Area_um2_1=[];
        DefaultEventDetectionSettings.Event_SizeAmp_Threshold_2=[];
        DefaultEventDetectionSettings.Event_SizeAmp_Min_Area_um2_2=[];
        DefaultEventDetectionSettings.Event_Size_AlertThresh_um2=[];
        %%%%%%%%%%%
        DefaultEventDetectionSettings.Roundness_Test=0;
        DefaultEventDetectionSettings.Roundness_Test_Threshold=[];
        DefaultEventDetectionSettings.Roundness_Test_Min_Area_um2=[];
        DefaultEventDetectionSettings.Roundness_Test_Exclusion_Frames=[];%Stim Frames for mini evoked?
        %%%%%%%%%%%
        DefaultEventDetectionSettings.StarterCleanupSettings.Corr_Thresh_Adjust=DefaultEventDetectionSettings.Corr_Thresh*0.125;
        DefaultEventDetectionSettings.AutoEventCleanup=0;
        DefaultEventDetectionSettings.DynamicAdjustments=1;
        DefaultEventDetectionSettings.StarterCleanupSettings.Corr_Thresh=                    DefaultEventDetectionSettings.Corr_Thresh+DefaultEventDetectionSettings.StarterCleanupSettings.Corr_Thresh_Adjust;
        DefaultEventDetectionSettings.StarterCleanupSettings.Corr_Thresh_Delta=              0;
        DefaultEventDetectionSettings.StarterCleanupSettings.MinSize_Adjust_um2=             0.2;
        DefaultEventDetectionSettings.StarterCleanupSettings.MinSize_um2=                    DefaultEventDetectionSettings.Event_Min_Area_um2+DefaultEventDetectionSettings.StarterCleanupSettings.MinSize_Adjust_um2;
        DefaultEventDetectionSettings.StarterCleanupSettings.STD_Factor=                     1.5;
        DefaultEventDetectionSettings.StarterCleanupSettings.STD_Factor_Delta=               -0.02;
        DefaultEventDetectionSettings.StarterCleanupSettings.Mean_CorrAmpThresh=             [DefaultEventDetectionSettings.Corr_Thresh*0.75,DefaultEventDetectionSettings.Corr_Thresh*0.75,DefaultEventDetectionSettings.Corr_Thresh*1.8,      DefaultEventDetectionSettings.Corr_Thresh*2,        DefaultEventDetectionSettings.Corr_Thresh*2.5,      DefaultEventDetectionSettings.Corr_Thresh*2.125]; %less than or equal
        DefaultEventDetectionSettings.StarterCleanupSettings.Mean_CorrAmpThresh_Delta=       [0,                                             0,                                             DefaultEventDetectionSettings.Corr_Thresh*-0.005,   DefaultEventDetectionSettings.Corr_Thresh*-0.005,   DefaultEventDetectionSettings.Corr_Thresh*-0.005,   DefaultEventDetectionSettings.Corr_Thresh*-0.005];
        DefaultEventDetectionSettings.StarterCleanupSettings.SizeThresh_um2=                 [18,   4.5,    1.5,     1.8,     2.6,     3]; %less than or equal
        DefaultEventDetectionSettings.StarterCleanupSettings.SizeThresh_um2_Delta=           [0,    0,     -0.05,   -0.05,   -0.05    -0.05];
        DefaultEventDetectionSettings.StarterCleanupSettings.EccentricityThresh=             [0,     0.95,   0,      0,      0.85,   0.8]; %less than or equal
        DefaultEventDetectionSettings.StarterCleanupSettings.EccentricityThresh_Delta=       [0,     0,      0,      0,      0.005,  0.005]; 
    elseif any(ImagingInfo.ModalityType==2)||any(ImagingInfo.ModalityType==3)
    %Streaming DeltaF
        DefaultEventDetectionSettings.DataType=1;
        DefaultEventDetectionSettings.Corr_Thresh = 1600;
        DefaultEventDetectionSettings.StdFactor = 2;
        DefaultEventDetectionSettings.MinGap = 2;
        DefaultEventDetectionSettings.ReZeroDeltaF=1;
        DefaultEventDetectionSettings.TrueBaselinePercent=10;
        %%%%%%%%%%%
        DefaultEventDetectionSettings.Active_Frames=[];
        DefaultEventDetectionSettings.ExclusionFrames=[1:2,ImagingInfo.FramesPerEpisode-2:ImagingInfo.FramesPerEpisode];
        %%%%%%%%%%%
        DefaultEventDetectionSettings.AdvancedFittingFixing=2; %0/1/2
        DefaultEventDetectionSettings.PersistenceChecker=1;
        DefaultEventDetectionSettings.PersistenceOption=2; %1 is sum 2 is max
        DefaultEventDetectionSettings.MaxPersistence=3;%only 3 works right now?
        DefaultEventDetectionSettings.TrackingMaskMethod=2;
        DefaultEventDetectionSettings.MinAreaTrackingMask_um2=0.14;
        DefaultEventDetectionSettings.FrameFix=1; %when using any of the event split fixing there is often a frame or two shifting, you can manually correct that here
        %%%%%%%%%%%
        DefaultEventDetectionSettings.Event_Min_Area_um2=0.9;
        DefaultEventDetectionSettings.Event_SizeAmp_Threshold_1=DefaultEventDetectionSettings.Corr_Thresh+DefaultEventDetectionSettings.Corr_Thresh*0.25; 
        DefaultEventDetectionSettings.Event_SizeAmp_Min_Area_um2_1=1.1;
        DefaultEventDetectionSettings.Event_SizeAmp_Threshold_2=DefaultEventDetectionSettings.Corr_Thresh+DefaultEventDetectionSettings.Corr_Thresh*0.125;
        DefaultEventDetectionSettings.Event_SizeAmp_Min_Area_um2_2=1.3;
        DefaultEventDetectionSettings.Event_Size_AlertThresh_um2=40;
        %%%%%%%%%%%
        DefaultEventDetectionSettings.Roundness_Test=0;
        DefaultEventDetectionSettings.Roundness_Test_Threshold=0.5;
        DefaultEventDetectionSettings.Roundness_Test_Min_Area_um2=4.5;
        DefaultEventDetectionSettings.Roundness_Test_Exclusion_Frames=[];%Stim Frames for mini evoked?
        %%%%%%%%%%%
        DefaultEventDetectionSettings.StarterCleanupSettings.Corr_Thresh_Adjust=DefaultEventDetectionSettings.Corr_Thresh*0.125;
        DefaultEventDetectionSettings.AutoEventCleanup=0;
        DefaultEventDetectionSettings.DynamicAdjustments=1;
        DefaultEventDetectionSettings.StarterCleanupSettings.Corr_Thresh=                    DefaultEventDetectionSettings.Corr_Thresh+DefaultEventDetectionSettings.StarterCleanupSettings.Corr_Thresh_Adjust;
        DefaultEventDetectionSettings.StarterCleanupSettings.Corr_Thresh_Delta=              0;
        DefaultEventDetectionSettings.StarterCleanupSettings.MinSize_Adjust_um2=             0.2;
        DefaultEventDetectionSettings.StarterCleanupSettings.MinSize_um2=                    DefaultEventDetectionSettings.Event_Min_Area_um2+DefaultEventDetectionSettings.StarterCleanupSettings.MinSize_Adjust_um2;
        DefaultEventDetectionSettings.StarterCleanupSettings.STD_Factor=                     1.5;
        DefaultEventDetectionSettings.StarterCleanupSettings.STD_Factor_Delta=               -0.02;
        DefaultEventDetectionSettings.StarterCleanupSettings.Mean_CorrAmpThresh=             [DefaultEventDetectionSettings.Corr_Thresh*0.75,DefaultEventDetectionSettings.Corr_Thresh*0.75,DefaultEventDetectionSettings.Corr_Thresh*1.8,      DefaultEventDetectionSettings.Corr_Thresh*2,        DefaultEventDetectionSettings.Corr_Thresh*2.5,      DefaultEventDetectionSettings.Corr_Thresh*2.125]; %less than or equal
        DefaultEventDetectionSettings.StarterCleanupSettings.Mean_CorrAmpThresh_Delta=       [0,                                             0,                                             DefaultEventDetectionSettings.Corr_Thresh*-0.005,   DefaultEventDetectionSettings.Corr_Thresh*-0.005,   DefaultEventDetectionSettings.Corr_Thresh*-0.005,   DefaultEventDetectionSettings.Corr_Thresh*-0.005];
        DefaultEventDetectionSettings.StarterCleanupSettings.SizeThresh_um2=                 [18,   4.5,    1.5,     1.8,     2.6,     3]; %less than or equal
        DefaultEventDetectionSettings.StarterCleanupSettings.SizeThresh_um2_Delta=           [0,    0,     -0.05,   -0.05,   -0.05    -0.05];
        DefaultEventDetectionSettings.StarterCleanupSettings.EccentricityThresh=             [0,     0.95,   0,      0,      0.85,   0.8]; %less than or equal
        DefaultEventDetectionSettings.StarterCleanupSettings.EccentricityThresh_Delta=       [0,     0,      0,      0,      0.005,  0.005]; 
    end
        DefaultEventDetectionSettings.StarterCleanupSettings.MinSize_px2=...
            ceil(DefaultEventDetectionSettings.StarterCleanupSettings.MinSize_um2/...
            ImagingInfo.PixelSize^2);
        DefaultEventDetectionSettings.StarterCleanupSettings.SizeThresh_px2=...
            ceil(DefaultEventDetectionSettings.StarterCleanupSettings.SizeThresh_um2/...
            ImagingInfo.PixelSize^2);
        DefaultEventDetectionSettings.StarterCleanupSettings.SizeThresh_px2_Delta=...
            ceil(DefaultEventDetectionSettings.StarterCleanupSettings.SizeThresh_um2_Delta/...
            ImagingInfo.PixelSize^2);

        DefaultEventDetectionSettings.MinAreaTrackingMask_px2=...
            ceil(DefaultEventDetectionSettings.MinAreaTrackingMask_um2/...
            ImagingInfo.PixelSize^2);

        DefaultEventDetectionSettings.Event_Min_Area_px2=...
            ceil(DefaultEventDetectionSettings.Event_Min_Area_um2/...
            ImagingInfo.PixelSize^2);
        DefaultEventDetectionSettings.Event_SizeAmp_Min_Area_px2_1=...
            ceil(DefaultEventDetectionSettings.Event_SizeAmp_Min_Area_um2_1/...
            ImagingInfo.PixelSize^2);
        DefaultEventDetectionSettings.Event_SizeAmp_Min_Area_px2_2=...
            ceil(DefaultEventDetectionSettings.Event_SizeAmp_Min_Area_um2_2/...
            ImagingInfo.PixelSize^2);
        DefaultEventDetectionSettings.Event_Size_AlertThresh_px2=...
            ceil(DefaultEventDetectionSettings.Event_Size_AlertThresh_um2/...
            ImagingInfo.PixelSize^2);
    
        DefaultEventDetectionSettings.Roundness_Test_Min_Area_px2=...
            ceil(DefaultEventDetectionSettings.Roundness_Test_Min_Area_um2/...
            ImagingInfo.PixelSize^2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %DefaultEventDetectionSettings.Max_Pixel_FilterSigma_px=1;
    %DefaultEventDetectionSettings.Max_Pixel_FilterSize_px=9;
    DefaultEventDetectionSettings.Max_Pixel_FilterSigma_um=0.2;
    DefaultEventDetectionSettings.Max_Pixel_FilterSize_um=2;
    DefaultEventDetectionSettings.Max_Pixel_CorrAmp_Amp_Threshold=0.1;
    DefaultEventDetectionSettings.Max_Pixel_CorrAmp_Size_Threshold=0.03;
    %DefaultEventDetectionSettings.Max_Pixel_EdgeSize=2;
    DefaultEventDetectionSettings.Max_Pixel_EdgeSize_um=0.04;

    DefaultEventDetectionSettings.Max_Pixel_FilterSigma_px=...
        DefaultEventDetectionSettings.Max_Pixel_FilterSigma_um/...
        ImagingInfo.PixelSize;
    DefaultEventDetectionSettings.Max_Pixel_FilterSize_px=...
        ceil(DefaultEventDetectionSettings.Max_Pixel_FilterSize_um/...
        ImagingInfo.PixelSize);
    if rem(DefaultEventDetectionSettings.Max_Pixel_FilterSize_px,2)==0
        DefaultEventDetectionSettings.Max_Pixel_FilterSize_px=DefaultEventDetectionSettings.Max_Pixel_FilterSize_px+1;
    end
    DefaultEventDetectionSettings.Max_Pixel_EdgeSize=...
        ceil(DefaultEventDetectionSettings.Max_Pixel_EdgeSize_um/...
        ImagingInfo.PixelSize);
    
    
    %Some Default Template options
    if ImagingInfo.ModalityType==1
        for zzzzzz=1:1
            t=0;
            %%%%%%%%%%%%%%%%%%%%
            t=t+1;
            DefaultTemplateOptions(t).TemplateLabel={['Episodic 10x50ms'];['1 Stim ~0.3s Delay']};
            DefaultTemplateOptions(t).AvgSeq=[0,-0.00653432616851009,-0.0149366890916656,0.374542336307107,0.972381659520659,0.624599316630531,0.352787786016572,0.179382367047456,0.0767966507037672,0.0306238040358268];
            DefaultTemplateOptions(t).TemplateResponse=[0,0,0,0.385180379164844,1,0.642339672406440,0.362807939210290,0.184477324609232,0.0789778889305918,0.0314936051456616];
            DefaultTemplateOptions(t).corrTemplate=[0,0,0,0.380318440309065,0.987377501246765,0.634231740692336,0.358228396449944,0.182148759809351,0.0779809906260322,0.0310960771539756];
            DefaultTemplateOptions(t).FirstIndex_Correlation=6;
            DefaultTemplateOptions(t).SecondIndex_Correlation=8;
            DefaultTemplateOptions(t).TemplatePeakPosition=5;
            DefaultTemplateOptions(t).MaxLags=5;
            DefaultTemplateOptions(t).PeakFrames=[4 5 6];
            DefaultTemplateOptions(t).MultiTemplateFitting=0;
            %%%%%%%%%%%%%%%%%%%%
        end
    elseif ImagingInfo.ModalityType==2||ImagingInfo.ModalityType==3
        for zzzzzz=1:1
            t=0;
            %%%%%%%%%%%%%%%%%%%%
            t=t+1;
            DefaultTemplateOptions(t).TemplateLabel={['Streaming 20fps'];['Standard']};
            DefaultTemplateOptions(t).AvgSeq=[];
            DefaultTemplateOptions(t).TemplateResponse=[0,0,0,0,0,0.492939368909639,1,0.785666313252651,0.578124258912378,0.406174673107676,0.285367483772510,0.200491577112848,0.140860030588634,0.0989644976769420,0.0695298145224152,0.0488497918041556,0.0343205598303451,0.0241127092576083,0.0169409459116070,0.0119022564123290,0.00836220766207433];
            DefaultTemplateOptions(t).corrTemplate=DefaultTemplateOptions(t).TemplateResponse;
            DefaultTemplateOptions(t).FirstIndex_Correlation=ImagingInfo.FramesPerEpisode-4;
            DefaultTemplateOptions(t).SecondIndex_Correlation=ImagingInfo.FramesPerEpisode*2-4;
            DefaultTemplateOptions(t).TemplatePeakPosition=7;
            DefaultTemplateOptions(t).MaxLags=ImagingInfo.FramesPerEpisode;
            DefaultTemplateOptions(t).PeakFrames=[];
            DefaultTemplateOptions(t).MultiTemplateFitting=0;
            %%%%%%%%%%%%%%%%%%%%
            t=t+1;
            DefaultTemplateOptions(t).TemplateLabel={['Streaming 20fps'];['MULTITEMPLATE']};
            DefaultTemplateOptions(t).AvgSeq=[];
            DefaultTemplateOptions(t).TemplateResponse=[0,0,0,0,0,0.492939368909639,1,0.785666313252651,0.578124258912378,0.406174673107676,0.285367483772510,0.200491577112848,0.140860030588634,0.0989644976769420,0.0695298145224152,0.0488497918041556,0.0343205598303451,0.0241127092576083,0.0169409459116070,0.0119022564123290,0.00836220766207433];
            DefaultTemplateOptions(t).corrTemplate=DefaultTemplateOptions(t).TemplateResponse;
            DefaultTemplateOptions(t).FirstIndex_Correlation=ImagingInfo.FramesPerEpisode-4;
            DefaultTemplateOptions(t).SecondIndex_Correlation=ImagingInfo.FramesPerEpisode*2-4;
            DefaultTemplateOptions(t).TemplatePeakPosition=7;
            DefaultTemplateOptions(t).MaxLags=ImagingInfo.FramesPerEpisode;
            DefaultTemplateOptions(t).PeakFrames=[];
            DefaultTemplateOptions(t).MultiTemplateFitting=1;
            for zzzz=1:1
                DefaultTemplateOptions(t).TemplateStruct(1).corrTemplate=[0,0,0,0,0.49,1,0.78,0.58,0.40,0.28,0.20];
                DefaultTemplateOptions(t).TemplateStruct(1).corrTemplate_PeakPosition=6;
                DefaultTemplateOptions(t).TemplateStruct(2).corrTemplate=[0,0,0,0,0.49,1,0.78,0.58,0.40];
                DefaultTemplateOptions(t).TemplateStruct(2).corrTemplate_PeakPosition=6;
                DefaultTemplateOptions(t).TemplateStruct(3).corrTemplate=[0,0,0,0,0.49,1,0.78];
                DefaultTemplateOptions(t).TemplateStruct(3).corrTemplate_PeakPosition=6;
                DefaultTemplateOptions(t).TemplateStruct(4).corrTemplate=[0,0,0,0.5,1,0.78,0.58,0.40];
                DefaultTemplateOptions(t).TemplateStruct(4).corrTemplate_PeakPosition=5;
                DefaultTemplateOptions(t).TemplateStruct(5).corrTemplate=[0,0,0,0.5,1,0.78,0.58];
                DefaultTemplateOptions(t).TemplateStruct(5).corrTemplate_PeakPosition=5;
                DefaultTemplateOptions(t).TemplateStruct(6).corrTemplate=[0,0,0.5,1,0.78,0.58,0.40];
                DefaultTemplateOptions(t).TemplateStruct(6).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(7).corrTemplate=[0.4,0,0.5,1,0.78,0.58,0.40,0.28];
                DefaultTemplateOptions(t).TemplateStruct(7).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(8).corrTemplate=[0.8,0,0.5,1,0.78,0.58,0.40,0.28];
                DefaultTemplateOptions(t).TemplateStruct(8).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(9).corrTemplate=[0.4,0,0.5,1,0.78,0.58,0.40];
                DefaultTemplateOptions(t).TemplateStruct(9).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(10).corrTemplate=[0.8,0,0.5,1,0.78,0.58,0.40];
                DefaultTemplateOptions(t).TemplateStruct(10).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(11).corrTemplate=[0.8,0,0.5,1,0.7,0.3];
                DefaultTemplateOptions(t).TemplateStruct(11).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(12).corrTemplate=[0.8,0,0.5,1,0.75,0.5];
                DefaultTemplateOptions(t).TemplateStruct(12).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(13).corrTemplate=[0,0,0,0,0.8,1,0.7,0.40,0.2];
                DefaultTemplateOptions(t).TemplateStruct(13).corrTemplate_PeakPosition=6;
                DefaultTemplateOptions(t).TemplateStruct(14).corrTemplate=[0,0,0,0.8,1,0.8,0.6];
                DefaultTemplateOptions(t).TemplateStruct(14).corrTemplate_PeakPosition=5;
                DefaultTemplateOptions(t).TemplateStruct(15).corrTemplate=[0,0,0.8,1,0.8,0.6];
                DefaultTemplateOptions(t).TemplateStruct(15).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(16).corrTemplate=[0,0,0.8,1,0.8];
                DefaultTemplateOptions(t).TemplateStruct(16).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(17).corrTemplate=[0.8,0,0.8,1,0.8,0.5];
                DefaultTemplateOptions(t).TemplateStruct(17).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(18).corrTemplate=[0.8,0,0.8,1,0.8];
                DefaultTemplateOptions(t).TemplateStruct(18).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(19).corrTemplate=[0,0,0,1,0.78,0.58,0.40,0.28,0.20];
                DefaultTemplateOptions(t).TemplateStruct(19).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(20).corrTemplate=[0,0,0,1,0.7,0.4,0.2];
                DefaultTemplateOptions(t).TemplateStruct(20).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(21).corrTemplate=[0,0,0,1,0.7,0.4];
                DefaultTemplateOptions(t).TemplateStruct(21).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(22).corrTemplate=[0,0,0,1,0.8,0.3];
                DefaultTemplateOptions(t).TemplateStruct(22).corrTemplate_PeakPosition=4;     
                DefaultTemplateOptions(t).TemplateStruct(23).corrTemplate=[0,0,0,1,0.8,0.1];
                DefaultTemplateOptions(t).TemplateStruct(23).corrTemplate_PeakPosition=4;          
                DefaultTemplateOptions(t).TemplateStruct(24).corrTemplate=[0,0,1,0.8,0.3];
                DefaultTemplateOptions(t).TemplateStruct(24).corrTemplate_PeakPosition=3;     
                DefaultTemplateOptions(t).TemplateStruct(25).corrTemplate=[0,0,1,0.8,0.1];
                DefaultTemplateOptions(t).TemplateStruct(25).corrTemplate_PeakPosition=3;          
                DefaultTemplateOptions(t).TemplateStruct(26).corrTemplate=[0,0,0,0.3,1,0.6,0.3];
                DefaultTemplateOptions(t).TemplateStruct(26).corrTemplate_PeakPosition=5;        
                DefaultTemplateOptions(t).TemplateStruct(27).corrTemplate=[0.3,0,0.3,1,0.6,0.3];
                DefaultTemplateOptions(t).TemplateStruct(27).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(28).corrTemplate=[0,0,0.3,1,0.6,0.3];
                DefaultTemplateOptions(t).TemplateStruct(28).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(29).corrTemplate=[0.3,0,0.3,1,0.6];
                DefaultTemplateOptions(t).TemplateStruct(29).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(30).corrTemplate=[0,0,0.3,1,0.6];
                DefaultTemplateOptions(t).TemplateStruct(30).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(31).corrTemplate=[0,0.15,0.2,1,0.4,0.3];
                DefaultTemplateOptions(t).TemplateStruct(31).corrTemplate_PeakPosition=4;
                DefaultTemplateOptions(t).TemplateStruct(32).corrTemplate=[0,0.15,0.2,1,0.4];
                DefaultTemplateOptions(t).TemplateStruct(32).corrTemplate_PeakPosition=4;        
                DefaultTemplateOptions(t).TemplateStruct(33).corrTemplate=[0.4,0,1,0.7,0.4,0.2];
                DefaultTemplateOptions(t).TemplateStruct(33).corrTemplate_PeakPosition=3;
                DefaultTemplateOptions(t).TemplateStruct(34).corrTemplate=[0.8,0,1,0.7,0.4];
                DefaultTemplateOptions(t).TemplateStruct(34).corrTemplate_PeakPosition=3;        
                DefaultTemplateOptions(t).TemplateStruct(35).corrTemplate=[0.4,0,1,0.7,0.4];
                DefaultTemplateOptions(t).TemplateStruct(35).corrTemplate_PeakPosition=3;
            end
            %%%%%%%%%%%%%%%%%%%%
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
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
RunningAnalysis=1;
while RunningAnalysis
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 0
    %Analysis Setup Define Defaults and Templates
    if any(AnalysisParts==0)||AdjustONLY
        DefaultLoadLabel='Event Detection Defaults';
        if exist('LabDefaults')
            if exist(LabDefaults)
                LoadLabDefaultsChoice = questdlg([LabDefaults,' Exist...Load: ',DefaultLoadLabel,'?'],'Load Lab Defaults?','Load','Skip','Load');
                switch LoadLabDefaultsChoice
                    case 'Load'
                        run(LabDefaults)
                end
            end
        else
            warning('<LabDefaults> Variable Doesnt Exist...')
        end
        if ~exist('EventDetectionSettings')
            EventDetectionSettings=[];
        end
        FileSuffix='_EventDetectionData.mat';
        if exist([SaveDir,dc,StackSaveName,FileSuffix])
            warning off
            load([CurrentScratchDir,dc,StackSaveName,FileSuffix],'PixelMax_Struct')
            warning on
            if exist('PixelMax_Struct')
                warning('I found previous Event Detection Data Would you like to view?')
                    ViewDataChoice=questdlg({[StackSaveName];['View Event Detection Data?']},'View Data','View','Skip','Skip');
                if strcmp(ViewDataChoice,'View')
                    ViewData=1;
                else
                    ViewData=0;
                end
                while ViewData
                    TestingMode=0;
                    BasicStackOnly=0;
                    EpisodeChoice=[];
                    run('Muli_Modality_Event_Detection_DataViewer.m')
                    ReViewDataChoice=questdlg({[StackSaveName];['Repeat Viewing?']},'View Data?','Repeat','Continue','Continue');
                    if strcmp(ReViewDataChoice,'Repeat')
                        ViewData=1;
                    else
                        ViewData=0;
                    end
                end
                clear TempData            
            end
        end

        [EventDetectionSettings]=Multi_Modality_Event_Detection_Setup(myPool,OS,dc,SaveName,StackSaveName,...
            ScratchDir,CurrentScratchDir,FigureSaveDir,ImagingInfo,RegistrationSettings,...
            EpisodeStruct,SplitEpisodeFiles,AllBoutonsRegion,EventDetectionSettings,...
            DefaultEventDetectionSettings,DefaultTemplateOptions,FigPosition,SelectionFigPosition); 
        close all
    else


    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 1
    %Run Detection and Pixel Max Mapping
    if any(AnalysisParts==1)&&~AdjustONLY
        SkipCorrAmp=0;
        [EventDetectionStruct,PixelMax_Struct,EventDetectionSettings,...
            EpisodeArray_CorrAmp_Events_Thresh_Clean,...
            EpisodeArray_CorrAmp_Events_Thresh_Clean_Norm,...
            EpisodeArray_Max_Sharp]=...
            Multi_Modality_Event_Detection(myPool,OS,dc,SaveName,StackSaveName,SaveDir,...
            ScratchDir,CurrentScratchDir,FigureSaveDir,ImagingInfo,EventDetectionSettings,...
            MarkerSetInfo,EpisodeStruct,SplitEpisodeFiles,AllBoutonsRegion,FullCorrAmpSave,SkipCorrAmp,FigPosition,SelectionFigPosition);  
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix='_EventDetectionData.mat';
        if exist([CurrentScratchDir,StackSaveName,FileSuffix])
            fprintf(['Copying: ',StackSaveName,FileSuffix,'...'])
            [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
            if CopyStatus
                disp('Copy successful!')
            else
                error('Unable to copy...')
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 2
    %Manual Checking and Cleaning
    if any(AnalysisParts==2)&&~AdjustONLY
        EditMode=1;
        EvaluatingResults=1;
        DefaultChoice='Data Viewer';
        while EvaluatingResults
            EvaluationMode = questdlg({['Evaluating ',AnalysisLabel];'I can open up the automatic Movie records or';'The Data Viewer to give you a more detailed view of the data'},...
                'Evaluation Mode?','Movies','Data Viewer','Finished',DefaultChoice);
            switch EvaluationMode
                case 'Movies'
                    CheckingMode=1;
                    run('Quantal_Analysis_Watch_Movie_Records.m')
                    DefaultChoice='Finished';
                case 'Data Viewer'
                    run('Quantal_Analysis_Event_Detection_Evaluation.m')
                    DefaultChoice='Finished';
                case 'Finished'
                    EvaluatingResults=0;
            end
        end
        close all
        
        error('add save updates here!')

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 3
    %Pixel Max Mapping ONLY
    if any(AnalysisParts==3)&&~AdjustONLY
        SkipCorrAmp=1;
        [EventDetectionStruct,PixelMax_Struct,EventDetectionSettings,...
            EpisodeArray_CorrAmp_Events_Thresh_Clean,...
            EpisodeArray_CorrAmp_Events_Thresh_Clean_Norm,...
            EpisodeArray_Max_Sharp]=...
            Multi_Modality_Event_Detection(myPool,OS,dc,SaveName,StackSaveName,SaveDir,...
            ScratchDir,CurrentScratchDir,FigureSaveDir,ImagingInfo,EventDetectionSettings,...
            MarkerSetInfo,EpisodeStruct,SplitEpisodeFiles,AllBoutonsRegion,FullCorrAmpSave,SkipCorrAmp,FigPosition,SelectionFigPosition);  
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 4
    %Movies
    if any(AnalysisParts==4)&&~AdjustONLY
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
        run('Quantal_Analysis_Event_Detection_Movie_Records.m')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
        fprintf(['Copying: Movies...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,'Movies'],[SaveDir,'Movies']);
        if CopyStatus
            disp('Copy successful!')
        else
            error(CopyMessage)
        end       
        close all
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 5
    %Evaluate Results
    if any(AnalysisParts==5)&&~AdjustONLY
        EditMode=0;
        EvaluatingResults=1;
        DefaultChoice='Movies';
        while EvaluatingResults
            EvaluationMode = questdlg({['Evaluating ',AnalysisLabel];'I can open up the automatic Movie records or';'The Data Viewer to give you a more detailed view of the data'},...
                'Evaluation Mode?','Movies','Data Viewer','Finished',DefaultChoice);
            switch EvaluationMode
                case 'Movies'
                    CheckingMode=1;
                    run('Quantal_Analysis_Watch_Movie_Records.m')
                    DefaultChoice='Finished';
                case 'Data Viewer'
                    run('Quantal_Analysis_Event_Detection_Evaluation.m')
                    DefaultChoice='Finished';
                case 'Finished'
                    EvaluatingResults=0;
            end
        end
        close all
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if ~isempty(BatchMode)
        RunningAnalysis=0;
    else
        CheckingResults = questdlg({['Repeat ',AnalysisLabel,'for :'];StackSaveName},...
            ['Repeat ',AnalysisLabelShort],'Good','Repeat','Good');
        switch CheckingResults
            case 'Repeat'
                RunningAnalysis=1;
            case 'Good'
                RunningAnalysis=0;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Copy files from CurrentScratchDir and delete
if Safe2CopyDelete
    warning on
    if ~isempty(BatchMode)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Deleting some ScratchDir Files...')
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
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Copying Files to SaveDir...')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_EventDetectionData.mat';
    if exist([CurrentScratchDir,StackSaveName,FileSuffix])
        fprintf(['Copying: ',StackSaveName,FileSuffix,'...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
        if CopyStatus
            disp('Copy successful!')
            if ~isempty(BatchMode)
                warning('Deleting CurrentScratchDir Version')
                delete([CurrentScratchDir,StackSaveName,FileSuffix]);
            end
        else
            error(CopyMessage)
        end
    end
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FileSuffix='_RegistrationData.mat';
%     if exist([CurrentScratchDir,StackSaveName,FileSuffix])
%         fprintf(['Copying: ',StackSaveName,FileSuffix,'...'])
%         [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
%         if CopyStatus
%             disp('Copy successful!')
%             if ~isempty(BatchMode)
%                 warning('Deleting CurrentScratchDir Version')
%                 delete([CurrentScratchDir,StackSaveName,FileSuffix]);
%             end
%         else
%             error(CopyMessage)
%         end
%     end
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist([CurrentScratchDir,'Figures'])
        fprintf(['Copying: Figures...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,'Figures'],[SaveDir,'Figures']);
        if CopyStatus
            disp('Copy successful!')
            if ~isempty(BatchMode)
                warning('Deleting CurrentScratchDir Version')
                try
                    rmdir([CurrentScratchDir,'Figures'],'s')
                catch
                    warning('Unable to remove Figure Directory!')
                end
            end
        else
            error(CopyMessage)
        end       
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist([CurrentScratchDir,'Movies'])
        fprintf(['Copying: Movies...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,'Movies'],[SaveDir,'Movies']);
        if CopyStatus
            disp('Copy successful!')
            warning('Deleting CurrentScratchDir Version')
            if ~isempty(BatchMode)
                try
                    rmdir([CurrentScratchDir,'Movies'],'s')
                catch
                    warning('Unable to remove Movies Directory!')
                end
            end
        else
            error(CopyMessage)
        end         
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Removing All ScratchDirs
    if ~isempty(BatchMode)
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
if ~isempty(BatchMode)
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
        try
            rmdir([ScratchDir,Recording(RecordingNum).StackSaveName,dc,'TempFiles',dc],'s');
        catch
            warning('Unable to Delete Temp File Directory...')
            warning('Unable to Delete Temp File Directory...')
            warning('Unable to Delete Temp File Directory...')
            warning('Unable to Delete Temp File Directory...')
        end
    end
    if exist([ScratchDir,Recording(RecordingNum).StackSaveName,dc])
        warning('Deleting StackSaveName-Specific ScrachDir Directory...')
        try
            rmdir([ScratchDir,Recording(RecordingNum).StackSaveName,dc],'s');
        catch
            warning('Unable to Delete StackSaveName-Specific ScrachDir Directory...')
            warning('Unable to Delete StackSaveName-Specific ScrachDir Directory...')
            warning('Unable to Delete StackSaveName-Specific ScrachDir Directory...')
            warning('Unable to Delete StackSaveName-Specific ScrachDir Directory...')
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clearvars -except myPool dc OS compName ClentCompName MatlabVersion MatlabVersionYear ScreenSize CurrentScratchDir ScratchDir LabDefaults...
        CurrentParentDir ParentDir ParentDir1 ParentDir2 ParentDir3...
        Recording Client_Recording Server_Recording currentFolder File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions BatchMode AnalysisPartsChoiceOptions AnalysisPartOptions RecordingChoiceOptions Function RecordingNum RecordingNum1 RecordingNums LastRecording...
        LoopCount File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort Function ErrorTolerant BrokeLoop AbortButton BufferSize Port PortChoice PortOptions PortOptionsText TimeOut NumLoops ServerIP BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
        RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode AdjustOnly
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
