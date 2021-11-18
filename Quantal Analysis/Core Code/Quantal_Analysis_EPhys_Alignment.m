cont=input('sure you wanna start over?');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except myPool dc OS compName MatlabVersion MatlabVersionYear ScreenSize CurrentScratchDir ScratchDir LabDefaults...
    CurrentParentDir ParentDir ParentDir1 ParentDir2 ParentDir3...
    Recording currentFolder File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions BatchMode AnalysisPartsChoiceOptions AnalysisPartOptions RecordingChoiceOptions Function RecordingNum RecordingNum1 RecordingNums LastRecording...
    LoopCount File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort Function ErrorTolerant BrokeLoop AbortButton BufferSize Port PortChoice PortOptions PortOptionsText TimeOut NumLoops ServerIP BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
    RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CurrentAnalysisLabel='QuaSOR EPhys Alignment';
CurrentAnalysisLabelShort='QuaSOR EPhys Align';
AnalysisLabel=CurrentAnalysisLabel;
AnalysisLabelShort=CurrentAnalysisLabelShort;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('myPool')
    myPool=[];
end
[myPool]=ParPoolManager(1,myPool);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RecNum=0;
RecordingChoiceOptions=[];
for RecNum=1:length(Recording)
    RecordingChoiceOptions{RecNum}=['Rec #',num2str(RecNum),': ',Recording(RecNum).StackSaveName];
end
[RecordingNum, ~] = listdlg('PromptString','Select RecordingNum?','SelectionMode','single','ListString',RecordingChoiceOptions,'ListSize', [500 600]);
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
[EphysFile,EphysDir] = uigetfile(SaveDir,['Select Ephys for: ',SaveDir]);
load([EphysDir,EphysFile])
cd(EphysDir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Load Data
warning on
disp('============================================================')
disp(['Loading Data for ',AnalysisLabel,' on File#',num2str(RecordingNum),' ',StackSaveName]);
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
FileSuffix='_DeltaFData.mat';
if exist([SaveDir,StackSaveName,FileSuffix])
    load([SaveDir,StackSaveName,FileSuffix],'SplitEpisodeFiles');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('SplitEpisodeFiles')
    SplitEpisodeFiles=0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('============================================================')
FileSuffix='_DeltaFData.mat';
load([SaveDir,StackSaveName,FileSuffix],'SplitEpisodeFiles')
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
fprintf(['Loading: ',StackSaveName,FileSuffix,'...'])
load([CurrentScratchDir,StackSaveName,FileSuffix])
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
            if ~exist([CurrentScratchDir,StackSaveName,FileSuffix])
                fprintf(['Copying: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
                [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
                fprintf('Finished!\n')
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
if ~isfield(ImagingInfo,'InterFrameTime')
    ImagingInfo.InterFrameTime=1/ImagingInfo.ImagingFrequency
end
FrameAdjust=-0.5;
Evaluation_Episodes=[1:ImagingInfo.NumEpisodes];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EPhys_Align_ImageArray=[];
InputAnalysis=[];
ImageCount=0;
EvaluationEpisodeList=[];
for e=1:ImagingInfo.NumEpisodes
    EvaluationEpisodeList{e}=['Episode ',num2str(e),' ',num2str(ImagingInfo.FramesPerEpisode),' Frames'];
end
[Evaluation_Episodes, ~] = listdlg('PromptString','Select Evaluation Episodes(s)?',...
    'ListString',EvaluationEpisodeList,'ListSize', [800 600],'InitialValue',Evaluation_Episodes);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EpMarker=1;
InputAnalysis.FrameMarkers(EpMarker).MarkerOn=1;
InputAnalysis.FrameMarkers(EpMarker).MarkerTextOn=1;
InputAnalysis.FrameMarkers(EpMarker).Frames=[];
InputAnalysis.FrameMarkers(EpMarker).FrameAdjust=FrameAdjust;
InputAnalysis.FrameMarkers(EpMarker).Label='Episodes';
InputAnalysis.FrameMarkers(EpMarker).Labels=[];
InputAnalysis.FrameMarkers(EpMarker).LabelPersistence.PreFrames=0;
InputAnalysis.FrameMarkers(EpMarker).LabelPersistence.PostFrames=ImagingInfo.FramesPerEpisode-1;
InputAnalysis.FrameMarkers(EpMarker).Color=[0.5,0.5,0.5];
InputAnalysis.FrameMarkers(EpMarker).Style=1;%1 vert 2 horz top 3 horz bottom
InputAnalysis.FrameMarkers(EpMarker).FontSize=10;
InputAnalysis.FrameMarkers(EpMarker).TextXOffset=0;
InputAnalysis.FrameMarkers(EpMarker).TextYOffset=0;
InputAnalysis.FrameMarkers(EpMarker).HorizontalAlignment='left';
InputAnalysis.FrameMarkers(EpMarker).VerticalAlignment='top';
InputAnalysis.FrameMarkers(EpMarker).LineMarkerStyle=':';
InputAnalysis.FrameMarkers(EpMarker).LineWidth=0.5;
InputAnalysis.FrameMarkers(EpMarker).MarkerSize=6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(MarkerSetInfo)
    m=length(InputAnalysis.FrameMarkers);
    for MarkerCount=1:length(MarkerSetInfo.Markers)
        if any(Evaluation_Episodes==MarkerSetInfo.Markers(MarkerCount).MarkerStart)||...
             any(Evaluation_Episodes==MarkerSetInfo.Markers(MarkerCount).MarkerEnd)   
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if MarkerSetInfo.Markers(MarkerCount).MarkerStyles==1
                m=m+1;
                TempFrames=[];
                for E=1:length(Evaluation_Episodes)
                    EpisodeNumber_Load=Evaluation_Episodes(E);
                    if any(EpisodeNumber_Load>=MarkerSetInfo.Markers(MarkerCount).MarkerStart)&&...
                            any(EpisodeNumber_Load<=MarkerSetInfo.Markers(MarkerCount).MarkerEnd)
                        TempFrames=[TempFrames,[(E-1)*ImagingInfo.FramesPerEpisode+1:...
                            (E)*ImagingInfo.FramesPerEpisode]];
                    end
                end
                InputAnalysis.FrameMarkers(m).MarkerOn=1;
                InputAnalysis.FrameMarkers(m).MarkerTextOn=1;
                InputAnalysis.FrameMarkers(m).Frames{1}=TempFrames;
                InputAnalysis.FrameMarkers(m).FrameAdjust=FrameAdjust;
                InputAnalysis.FrameMarkers(m).Label=MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel;
                InputAnalysis.FrameMarkers(m).Labels{1}=MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel;
                InputAnalysis.FrameMarkers(m).LabelPersistence.PreFrames=0;
                InputAnalysis.FrameMarkers(m).LabelPersistence.PostFrames=ImagingInfo.FramesPerEpisode*length(Evaluation_Episodes);
                InputAnalysis.FrameMarkers(m).Color=MarkerSetInfo.Markers(MarkerCount).MarkerColor;
                InputAnalysis.FrameMarkers(m).Style=2;%1 vert 2 horz top 3 horz bottom
                InputAnalysis.FrameMarkers(m).FontSize=10;
                InputAnalysis.FrameMarkers(m).TextXOffset=0;
                InputAnalysis.FrameMarkers(m).TextYOffset=0;
                InputAnalysis.FrameMarkers(m).HorizontalAlignment='left';
                InputAnalysis.FrameMarkers(m).VerticalAlignment='top';
                InputAnalysis.FrameMarkers(m).LineMarkerStyle=MarkerSetInfo.Markers(MarkerCount).MarkerLineStyle;
                InputAnalysis.FrameMarkers(m).LineWidth=0.5;
                InputAnalysis.FrameMarkers(m).MarkerSize=6;
            elseif MarkerSetInfo.Markers(MarkerCount).MarkerStyles==2
                m=m+1;
                InputAnalysis.FrameMarkers(m).MarkerOn=1;
                InputAnalysis.FrameMarkers(m).MarkerTextOn=1;
                InputAnalysis.FrameMarkers(m).Frames(1)=[(MarkerSetInfo.Markers(MarkerCount).MarkerStart-1)*ImagingInfo.FramesPerEpisode+1];
                InputAnalysis.FrameMarkers(m).FrameAdjust=-1*FrameAdjust;
                InputAnalysis.FrameMarkers(m).Label=MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel;
                InputAnalysis.FrameMarkers(m).Labels{1}=MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel;
                InputAnalysis.FrameMarkers(m).LabelPersistence.PreFrames=0;
                InputAnalysis.FrameMarkers(m).LabelPersistence.PostFrames=0;
                InputAnalysis.FrameMarkers(m).Color=MarkerSetInfo.Markers(MarkerCount).MarkerColor;
                InputAnalysis.FrameMarkers(m).Style=1;%1 vert 2 horz top 3 horz bottom
                InputAnalysis.FrameMarkers(m).FontSize=10;
                InputAnalysis.FrameMarkers(m).TextXOffset=0;
                InputAnalysis.FrameMarkers(m).TextYOffset=0;
                InputAnalysis.FrameMarkers(m).HorizontalAlignment='left';
                InputAnalysis.FrameMarkers(m).VerticalAlignment='top';
                InputAnalysis.FrameMarkers(m).LineMarkerStyle=MarkerSetInfo.Markers(MarkerCount).MarkerLineStyle;
                InputAnalysis.FrameMarkers(m).LineWidth=0.5;
                InputAnalysis.FrameMarkers(m).MarkerSize=6;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StimMarker=length(InputAnalysis.FrameMarkers)+1;
InputAnalysis.FrameMarkers(StimMarker).MarkerOn=1;
InputAnalysis.FrameMarkers(StimMarker).MarkerTextOn=0;
InputAnalysis.FrameMarkers(StimMarker).Frames=[];
InputAnalysis.FrameMarkers(StimMarker).FrameAdjust=FrameAdjust;
InputAnalysis.FrameMarkers(StimMarker).Label='Stimuli';
InputAnalysis.FrameMarkers(StimMarker).Labels=[];
InputAnalysis.FrameMarkers(StimMarker).LabelPersistence.PreFrames=0;
InputAnalysis.FrameMarkers(StimMarker).LabelPersistence.PostFrames=0;
InputAnalysis.FrameMarkers(StimMarker).Color=[1,0,0];
InputAnalysis.FrameMarkers(StimMarker).Style=3;%1 vert 2 horz top 3 horz bottom
InputAnalysis.FrameMarkers(StimMarker).FontSize=10;
InputAnalysis.FrameMarkers(StimMarker).TextXOffset=0;
InputAnalysis.FrameMarkers(StimMarker).TextYOffset=0;
InputAnalysis.FrameMarkers(StimMarker).HorizontalAlignment='left';
InputAnalysis.FrameMarkers(StimMarker).VerticalAlignment='bottom';
InputAnalysis.FrameMarkers(StimMarker).LineMarkerStyle='*';
InputAnalysis.FrameMarkers(StimMarker).LineWidth=0.5;
InputAnalysis.FrameMarkers(StimMarker).MarkerSize=6;
progressbar('Collecting Episodes...')
clear EPhys_Align_ImageTrace
for E=1:length(Evaluation_Episodes)
    EpisodeNumber_Load=Evaluation_Episodes(E);
    InputAnalysis.FrameMarkers(EpMarker).Frames=...
        [InputAnalysis.FrameMarkers(EpMarker).Frames,(E-1)*ImagingInfo.FramesPerEpisode+1+FrameAdjust];
    if length(Evaluation_Episodes)>50
        InputAnalysis.FrameMarkers(EpMarker).Labels{length(InputAnalysis.FrameMarkers(EpMarker).Frames)}=...
            [];
    else
        InputAnalysis.FrameMarkers(EpMarker).Labels{length(InputAnalysis.FrameMarkers(EpMarker).Frames)}=...
            ['Ep',num2str(EpisodeNumber_Load)];
    end
    if ~isnan(ImagingInfo.StimuliPerEpisode)
        s1=length(InputAnalysis.FrameMarkers(StimMarker).Frames)+1;
        for s=1:ImagingInfo.StimuliPerEpisode
            InputAnalysis.FrameMarkers(StimMarker).Frames{s}=...
                [(E-1)*ImagingInfo.FramesPerEpisode+ImagingInfo.IntraEpisode_StimuliFrames(s)+FrameAdjust];
            if ImagingInfo.StimuliPerEpisode==1
                InputAnalysis.FrameMarkers(StimMarker).Labels{s1}=...
                    [];
            elseif ImagingInfo.StimuliPerEpisode>1
                InputAnalysis.FrameMarkers(StimMarker).Labels{s1}=...
                    [num2str(s)];
            end
        end
    end
    if SplitEpisodeFiles
        EpisodeNumber=1;
        FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
        fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
        load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
        fprintf('Finished!\n')
    else
        EpisodeNumber=EpisodeNumber_Load;
    end
    EPhys_Align_ImageArray_DeltaF=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaF;
    EPhys_Align_ImageArray_DeltaFF0=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaFF0;
    for ImageNumber=1:ImagingInfo.FramesPerEpisode
        ImageCount=ImageCount+1;
        EPhys_Align_ImageArray(:,:,1,ImageCount)=EPhys_Align_ImageArray_DeltaF(:,:,ImageNumber);
        EPhys_Align_ImageArray(:,:,2,ImageCount)=EPhys_Align_ImageArray_DeltaFF0(:,:,ImageNumber);
        TempImage=EPhys_Align_ImageArray_DeltaF(:,:,ImageNumber);
        EPhys_Align_ImageTrace(1,ImageCount)=mean(TempImage(AllBoutonsRegion));
        TempImage=EPhys_Align_ImageArray_DeltaFF0(:,:,ImageNumber);
        EPhys_Align_ImageTrace(2,ImageCount)=mean(TempImage(AllBoutonsRegion));
    end
    clear EPhys_Align_ImageArray_DeltaF EPhys_Align_ImageArray_DeltaFF0
    progressbar(E/length(Evaluation_Episodes))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EpisodeLabel=[];
if length(Evaluation_Episodes)==1
    EpisodeLabel=['E',num2str(Evaluation_Episodes)];
else
    EpisodeLabel=['E',num2str(Evaluation_Episodes(1)),'-E',num2str(Evaluation_Episodes(length(Evaluation_Episodes)))];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StackOrder='YXCT';
Channel_Labels={'DeltaF','DeltaF/F'};
Channel_Colors={'jet','jet'};
ImagingInfo.PixelSize=ScaleBar.ScaleFactor;
ImagingInfo.PixelUnit='um';
ImagingInfo.VoxelDepth=NaN;
ImagingInfo.VoxelUnit='um';
ImagingInfo.InterFrameTime=1/ImagingInfo.ImagingFrequency;
ImagingInfo.FrameUnit='s';
Channel_Info=[];
EditRecord=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
ReleaseFig=0;
close all
ViewData=1;
while ViewData
    [ViewerFig,Channel_Info,ImagingInfo,OutputAnalysis,Temp_EPhys_Align_ImageArray]=Stack_Viewer(EPhys_Align_ImageArray,...
        AllBoutonsRegion,StackOrder,Channel_Labels,Channel_Colors,Channel_Info,ImagingInfo,...
        [StackSaveName,' ',EpisodeLabel,' ',CurrentAnalysisLabelShort],InputAnalysis,ReleaseFig);
    if ~isempty(Temp_EPhys_Align_ImageArray)
        EPhys_Align_ImageArray=Temp_EPhys_Align_ImageArray;
    end
    ViewDataChoice = questdlg({'Re-View Data?'},'Re-View Data?','Re-View','Continue','Continue');
    switch ViewDataChoice
        case 'Re-View'
            ViewData=1;
        case 'Continue'
            ViewData=0;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%Template Generator or Simple Detection Mode settings
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.DataType=1;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.Amp_Thresh=2000;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.Amp_Peak_Thresh=2500;
% EventDetectionSettings.Simple_Auto_Event_Finder_Settings.DataType=2;
% EventDetectionSettings.Simple_Auto_Event_Finder_Settings.Amp_Thresh=0.3;
% EventDetectionSettings.Simple_Auto_Event_Finder_Settings.Amp_Peak_Thresh=0.35;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSigma_um=0.35;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSize_um=2.5;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinArea_um2=0.8;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings_VolumeFrameScalar=2.5;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinVolume_um2=...
    EventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinArea_um2*...
    EventDetectionSettings.Simple_Auto_Event_Finder_Settings_VolumeFrameScalar;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinFramePersistence=3;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.EventMaxDistThresh_um=0.8;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.EventMaxFrameTimeDistance=3;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.Roundness_Test=1;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.Roundness_Test_Threshold=0.5;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.Active_Frames=[];
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.ExclusionFrames=[1 2 1499 1500];
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.EventPerFrameCutoff=40;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.Trace_Mask_Radius_um=0.5;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSigma_px=...
    EventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSigma_um/ImagingInfo.PixelSize;
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSize_px=...
    ceil(EventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSize_um/ImagingInfo.PixelSize);
if rem(EventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSize_px,2)==0
    EventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSize_px=EventDetectionSettings.Simple_Auto_Event_Finder_Settings.FilterSize_px+1;
end
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinArea=...
    ceil(EventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinArea_um2/...
    ImagingInfo.PixelSize^2);
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinVolume=...
    ceil(EventDetectionSettings.Simple_Auto_Event_Finder_Settings.MinVolume_um2/...
    ImagingInfo.PixelSize^2);
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.EventMaxDistThresh_px=...
    ceil(EventDetectionSettings.Simple_Auto_Event_Finder_Settings.EventMaxDistThresh_um/ImagingInfo.PixelSize);
EventDetectionSettings.Simple_Auto_Event_Finder_Settings.Trace_Mask_Radius_px=...
    ceil(EventDetectionSettings.Simple_Auto_Event_Finder_Settings.Trace_Mask_Radius_um/ImagingInfo.PixelSize);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
[myPool]=ParPoolManager(1,myPool);
[EPhys_Align_ImageArray_Masked,...
    EPhys_Align_ImageArray_Event_Mask,...
    EPhys_Align_ImageArray_Event_Locations,...
    EventStruct,EventStruct_ByImage,...
    EventDetectionSettings]=...
    Simple_Auto_Event_Finder([StackSaveName,' ',EpisodeLabel,' ',CurrentAnalysisLabelShort],...
    squeeze(EPhys_Align_ImageArray(:,:,EventDetectionSettings.Simple_Auto_Event_Finder_Settings.DataType,:)),EventDetectionSettings);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
ZerosImage=logical(zeros(size(EPhys_Align_ImageArray,1),size(EPhys_Align_ImageArray,2)));
TraceROI=strel('disk',EventDetectionSettings.Simple_Auto_Event_Finder_Settings.Trace_Mask_Radius_px);
progressbar('Collecing More Trace Data...')
for Event=1:length(EventStruct)
    EventStruct(Event).DeltaF_Trace=[];
    TempMask=ZerosImage;
    TempMask(EventStruct(Event).MaxCoord(1),EventStruct(Event).MaxCoord(2))=1;
    TempMask=imdilate(TempMask,TraceROI);
    for ImageNumber=1:size(EPhys_Align_ImageArray,4)
        TempImage=EPhys_Align_ImageArray(:,:,1,ImageNumber);
        EventStruct(Event).DeltaF_Trace(ImageNumber)=mean(TempImage(TempMask));
    end

    EventStruct(Event).DeltaFF0_Trace=[];
    TempMask=ZerosImage;
    TempMask(EventStruct(Event).MaxCoord(1),EventStruct(Event).MaxCoord(2))=1;
    TempMask=imdilate(TempMask,TraceROI);
    for ImageNumber=1:size(EPhys_Align_ImageArray,4)
        TempImage=EPhys_Align_ImageArray(:,:,2,ImageNumber);
        EventStruct(Event).DeltaFF0_Trace(ImageNumber)=mean(TempImage(TempMask));
    end
progressbar(Event/length(EventStruct))
end
clear EPhys_Align_ThreshImageTrace
ImageCount=0;
for E=1:length(Evaluation_Episodes)
    EpisodeNumber_Load=Evaluation_Episodes(E);
    if SplitEpisodeFiles
        EpisodeNumber=1;
        FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
        fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
        load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
        fprintf('Finished!\n')
    else
        EpisodeNumber=EpisodeNumber_Load;
    end
    
    switch EventDetectionSettings.Simple_Auto_Event_Finder_Settings.DataType
        case 1
            TempImageArray=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaF;
            for ImageNumber=1:ImagingInfo.FramesPerEpisode
                ImageCount=ImageCount+1;
                TempImage=TempImageArray(:,:,ImageNumber);
                TempImage(TempImage<EventDetectionSettings.Simple_Auto_Event_Finder_Settings.Amp_Thresh)=NaN;
                EPhys_Align_ThreshImageTrace(ImageCount)=nanmean(TempImage(AllBoutonsRegion));
            end
            
        case 2
            TempImageArray=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaFF0;
            for ImageNumber=1:ImagingInfo.FramesPerEpisode
                ImageCount=ImageCount+1;
                TempImage=TempImageArray(:,:,ImageNumber);
                TempImage(TempImage<EventDetectionSettings.Simple_Auto_Event_Finder_Settings.Amp_Thresh)=NaN;
                EPhys_Align_ThreshImageTrace(ImageCount)=nanmean(TempImage(AllBoutonsRegion));
            end
            
    end
    clear TempImage TempImageArray
            
    progressbar(E/length(Evaluation_Episodes))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
PreFrames=20;
PostFrames=30;
TracerPreFrames=10;
TracerPostFrames=10;
TileOffset=-0.05;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
figure('name',StackSaveName)
subtightplot(1,1,1,[0.05,0.05])
hold on
for e=1:length(EventStruct)
    if EventStruct(e).MaxCoord(3)-PreFrames<1
        TempX=[1:EventStruct(e).MaxCoord(3)+PostFrames];
    elseif EventStruct(e).MaxCoord(3)+PostFrames>length(EventStruct(e).DeltaFF0_Trace)
        TempX=[EventStruct(e).MaxCoord(3)-PreFrames:length(EventStruct(e).DeltaFF0_Trace)];
    else
        TempX=[EventStruct(e).MaxCoord(3)-PreFrames:EventStruct(e).MaxCoord(3)+PostFrames];
    end
    TempY=EventStruct(e).DeltaFF0_Trace(TempX);
    TempX=TempX*ImagingInfo.InterFrameTime;
    
    plot(TempX,TempY+TileOffset*(e-1),'-','linewidth',0.5);
end
xlim([0,30])
set(gcf,'units','normalized','position',[0,0,1,0.4]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
                %Rec1
                EphysYLim=[-70,-30]
                MatchX=[0,30]
                Exp=2
                Filt=0;
                TraceRange=[1:3]
                TileOffset=-0.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                %Rec3
                EphysYLim=[-50,0]
                MatchX=[0,30]
                Exp=3
                Filt=3;
                TraceRange=[1:3]
                TileOffset=-0.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                %Rec9
                EphysYLim=[-70,-30]
                MatchX=[0,30]
                Exp=2
                Filt=0;
                TraceRange=[1:3]
                TileOffset=-0.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                %Rec15
                EphysYLim=[-70,-30]
                MatchX=[0,30]
                Exp=2
                Filt=0;
                TraceRange=[1:3]
                TileOffset=-0.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                %Rec19
                EphysYLim=[-70,-30]
                MatchX=[0,30]
                Exp=2
                Filt=0;
                TraceRange=[1:3]
                TileOffset=-0.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                %Rec20
                EphysYLim=[-50,0]
                MatchX=[0,30]
                Exp=3
                Filt=3;
                TraceRange=[1:3]
                TileOffset=-0.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
LagOffset=0.05

ConcatenatedTrace=[];
for i1=1:length(TraceRange)
    i=TraceRange(i1);
    if Filt==0
        ConcatenatedTrace=[ConcatenatedTrace,Experiment(Exp).PrimaryData.GoodTraceData(:,i)'];
    else
        ConcatenatedTrace=[ConcatenatedTrace,Experiment(Exp).PrimaryData_Filtered(Filt).GoodTraceData_Filtered(:,i)'];
    end
end
MaxY=max(ConcatenatedTrace);
MinY=min(ConcatenatedTrace);

XData_Ephys=[1:length(ConcatenatedTrace)]*Experiment(Exp).DeltaT;
XData_Imaging=[1:size(EPhys_Align_ThreshImageTrace,2)]*ImagingInfo.InterFrameTime;

close all

figure,
subtightplot(2,1,1,[0.05,0.05])
hold on
plot(ConcatenatedTrace,'-','linewidth',0.5,'color','k')
ylim([MinY,MaxY])
subtightplot(2,1,2,[0.05,0.05])
plot(EPhys_Align_ThreshImageTrace,'-','linewidth',0.5,'color','k')
set(gcf,'units','normalized','position',[0,0.05,1,0.8]);

figure,
subtightplot(2,1,1,[0.05,0.05])
hold on
plot(XData_Ephys,ConcatenatedTrace,'-','linewidth',0.5,'color','k')
xlim(MatchX)
ylim([MinY,MaxY])
subtightplot(2,1,2,[0.05,0.05])
plot(XData_Imaging,EPhys_Align_ThreshImageTrace,'-','linewidth',0.5,'color','k')
xlim(MatchX)
set(gcf,'units','normalized','position',[0,0.05,1,0.8]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%EphysXMatch=[5801 55799 105800]*Experiment(Exp).DeltaT
EphysXMatch=[5604 55604 105604]*Experiment(Exp).DeltaT
ImagingXMatch=[47 527 1010]*ImagingInfo.InterFrameTime
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
EphysXMatch_Deltas=[];
for s=2:length(EphysXMatch)
    EphysXMatch_Deltas(s)=(EphysXMatch(s)-EphysXMatch(s-1));
end
EphysXMatch_Deltas

ImagingXMatch_Deltas=[];
for s=2:length(ImagingXMatch)
    ImagingXMatch_Deltas(s)=(ImagingXMatch(s)-ImagingXMatch(s-1));
end
ImagingXMatch_Deltas

Imaging2Ephys_FrameAdjust=nanmean(EphysXMatch(1)-ImagingXMatch(1))
Imaging2Ephys_FrameAdjustScalar=nanmean(ImagingXMatch_Deltas./EphysXMatch_Deltas)

XData_Imaging_Adjusted=(XData_Imaging+Imaging2Ephys_FrameAdjust)/Imaging2Ephys_FrameAdjustScalar;
RealImagingFrameTimes=[];
for i=2:length(XData_Imaging_Adjusted)
    RealImagingFrameTimes(i-1)=(XData_Imaging_Adjusted(i)-XData_Imaging_Adjusted(i-1));
end
RealImagingFrameTimeMean=mean(RealImagingFrameTimes)

close all

figure,
subtightplot(2,1,1,[0.05,0.05])
hold on
plot(XData_Ephys,ConcatenatedTrace,'-','linewidth',0.5,'color','k')
xlim(MatchX)
subtightplot(2,1,2,[0.05,0.05])
plot(XData_Imaging_Adjusted,EPhys_Align_ThreshImageTrace,'-','linewidth',0.5,'color','k')
xlim(MatchX)
set(gcf,'units','normalized','position',[0,0.05,1,0.85]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

close all
figure,
s1=subtightplot(2,1,1,[0,0],[0,0],[0,0]);
hold on
plot(XData_Ephys,ConcatenatedTrace,'-','linewidth',0.5,'color','k')
xlim(MatchX)
YLimits=ylim;
for i=1:length(XData_Imaging_Adjusted)
    hold on
    plot(LagOffset+[1,1]*XData_Imaging_Adjusted(i),[YLimits(1),YLimits(2)],'-','color',[0.5,0.5,0.5],'linewidth',0.5)
    %text(LagOffset+XData_Imaging_Adjusted(i)-RealImagingFrameTimeMean/2,YLimits(2),num2str(i),'fontsize',8,'horizontalalignment','center','verticalalignment','bottom')
end
box off
axis off
s2=subtightplot(2,1,2,[0,0],[0,0],[0,0]);
hold on
for e=1:length(EventStruct)
    if EventStruct(e).MaxCoord(3)-PreFrames<1
        TempX=[1:EventStruct(e).MaxCoord(3)+PostFrames];
    elseif EventStruct(e).MaxCoord(3)+PostFrames>length(EventStruct(e).DeltaFF0_Trace)
        TempX=[EventStruct(e).MaxCoord(3)-PreFrames:length(EventStruct(e).DeltaFF0_Trace)];
    else
        TempX=[EventStruct(e).MaxCoord(3)-PreFrames:EventStruct(e).MaxCoord(3)+PostFrames];
    end
    TempY=EventStruct(e).DeltaFF0_Trace(TempX);
    TempX=XData_Imaging_Adjusted(TempX);
    
    plot(TempX,TempY+TileOffset*(e-1),'-','linewidth',0.5);
end
xlim(MatchX)
YLimits=ylim;
for i=1:length(XData_Imaging_Adjusted)
    hold on
    plot(LagOffset+[1,1]*XData_Imaging_Adjusted(i),[YLimits(1),YLimits(2)],'-','color',[0.5,0.5,0.5],'linewidth',0.5)
    text(LagOffset+XData_Imaging_Adjusted(i)-RealImagingFrameTimeMean/2,YLimits(2),num2str(i),'fontsize',8,'horizontalalignment','center','verticalalignment','bottom')
end
box off
axis off
set(gcf,'units','normalized','position',[0,0.05,1,0.85]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
ImageTraceSmooth=5;
for e=1:length(EventStruct)
    EventStruct(e).DeltaF_Trace_Smoothed=smooth(EventStruct(e).DeltaF_Trace,ImageTraceSmooth);
    EventStruct(e).DeltaFF0_Trace_Smoothed=smooth(EventStruct(e).DeltaFF0_Trace,ImageTraceSmooth);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
                    %Rec1
                    EphysHighlightYLim=[-62 -57]
                    HighlightXLim=[5 8]
                    HighlightHorzScale=0.5;
                    HighlightTimeScale='s';
                    EphysHighlightScale=1;
                    EphysUnit='mV';
                    ImagingHighlightScale=1;
                    ImagingHighlightUnit='DF/F';
%                     ImagingHighightYRange=[-5 0]
%                     TileOffset=-0.1;
                    ImagingHighightYRange=[0 3]
                    UseSmoothedTraces=0;
                    IncludeImages=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                    %Rec3
                    EphysHighlightYLim=[-8 -4]
                    HighlightXLim=[7 10]
                    HighlightHorzScale=0.5;
                    HighlightTimeScale='s';
                    EphysHighlightScale=1;
                    EphysUnit='nA';
                    ImagingHighlightScale=1;
                    ImagingHighlightUnit='DF/F';
%                     ImagingHighightYRange=[-3 0]
%                     TileOffset=-0.1;
                    ImagingHighightYRange=[0 3]
                    UseSmoothedTraces=0;
                    IncludeImages=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                    %Rec9
                    EphysHighlightYLim=[-64 -58]
                    HighlightXLim=[3 6]
                    HighlightHorzScale=0.5;
                    HighlightTimeScale='s';
                    EphysHighlightScale=1;
                    EphysUnit='mV';
                    ImagingHighlightScale=1;
                    ImagingHighlightUnit='DF/F';
%                     ImagingHighightYRange=[-3 0]
%                     TileOffset=-0.1;
                    ImagingHighightYRange=[0 3]
                    UseSmoothedTraces=0;
                    IncludeImages=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                    %Rec15
                    EphysHighlightYLim=[-64 -58]
                    HighlightXLim=[3 6]
                    HighlightHorzScale=0.5;
                    HighlightTimeScale='s';
                    EphysHighlightScale=1;
                    EphysUnit='mV';
                    ImagingHighlightScale=1;
                    ImagingHighlightUnit='DF/F';
%                     ImagingHighightYRange=[-3 0]
%                     TileOffset=-0.1;
                    ImagingHighightYRange=[0 3]
                    UseSmoothedTraces=0;
                    IncludeImages=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                    %Rec15
                    EphysHighlightYLim=[-64 -58]
                    HighlightXLim=[3 6]
                    HighlightHorzScale=0.5;
                    HighlightTimeScale='s';
                    EphysHighlightScale=1;
                    EphysUnit='mV';
                    ImagingHighlightScale=1;
                    ImagingHighlightUnit='DF/F';
%                     ImagingHighightYRange=[-3 0]
%                     TileOffset=-0.1;
                    ImagingHighightYRange=[0 3]
                    UseSmoothedTraces=0;
                    IncludeImages=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                    %Rec19
                    EphysHighlightYLim=[-61 -57]
                    HighlightXLim=[5 7]
                    HighlightHorzScale=0.5;
                    HighlightTimeScale='s';
                    EphysHighlightScale=1;
                    EphysUnit='mV';
                    ImagingHighlightScale=0.5;
                    ImagingHighlightUnit='DF/F';
%                     ImagingHighightYRange=[-5 0]
%                     TileOffset=-0.1;
                    ImagingHighightYRange=[0 3]
                    UseSmoothedTraces=0;
                    IncludeImages=0;

                    %Rec19
                    EphysHighlightYLim=[-61 -57]
                    HighlightXLim=[4 6]
                    HighlightHorzScale=0.5;
                    HighlightTimeScale='s';
                    EphysHighlightScale=1;
                    EphysUnit='mV';
                    ImagingHighlightScale=0.5;
                    ImagingHighlightUnit='DF/F';
                    ImagingHighightYRange=[-3 0]
                    TileOffset=-0.5;
                    TileGroups=10;
                    UseSmoothedTraces=0;
                    IncludeImages=0;

                    %Rec19
                    EphysHighlightYLim=[-61 -57]
                    HighlightXLim=[4 6]
                    HighlightHorzScale=0.5;
                    HighlightTimeScale='s';
                    EphysHighlightScale=1;
                    EphysUnit='mV';
                    ImagingHighlightScale=0.5;
                    ImagingHighlightUnit='DF/F';
                    ImagingHighightYRange=[-12 0]
                    TileOffset=-2;
                    TileGroups=10;
                    UseSmoothedTraces=0;
                    IncludeImages=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                    %Rec20
                    EphysHighlightYLim=[-7 -3]
                    HighlightXLim=[5 8]
                    HighlightHorzScale=0.5;
                    HighlightTimeScale='s';
                    EphysHighlightScale=1;
                    EphysUnit='nA';
                    ImagingHighlightScale=0.5;
                    ImagingHighlightUnit='DF/F';
                    TileOffset=0;
                    TileGroups=[];
                    ImagingHighightYRange=[0 3]
                    UseSmoothedTraces=0;
                    IncludeImages=0;
                    
                    %Rec20
                    EphysHighlightYLim=[-7 -3]
                    HighlightXLim=[18 20]
                    HighlightHorzScale=0.5;
                    HighlightTimeScale='s';
                    EphysHighlightScale=1;
                    EphysUnit='nA';
                    ImagingHighlightScale=0.5;
                    ImagingHighlightUnit='DF/F';
                    ImagingHighightYRange=[-3 0]
                    TileOffset=-0.5;
                    TileGroups=10;
                    UseSmoothedTraces=0;
                    IncludeImages=0;
                    
                    %Rec20
                    EphysHighlightYLim=[-7 -3]
                    HighlightXLim=[18 20]
                    HighlightHorzScale=0.5;
                    HighlightTimeScale='s';
                    EphysHighlightScale=1;
                    EphysUnit='nA';
                    ImagingHighlightScale=0.5;
                    ImagingHighlightUnit='DF/F';
                    ImagingHighightYRange=[-8 0]
                    TileOffset=-2;
                    TileGroups=10;
                    UseSmoothedTraces=0;
                    IncludeImages=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
close all
run('Quantal_Analysis_EPhys_Alignment_Export.m')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Full_Export_Fig(AlignFig,[s1,s2],[FigureSaveDir,dc,FigName],0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cont=input('Enter to proceed to export and movies...');
pause(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Export Everything
close all
TileOffset=0;
TileGroups=10;
IncludeImages=0;
TimeSpan=2;
TimeSpanCenter=round(TimeSpan/2);
for t=MatchX(1)+TimeSpanCenter:MatchX(2)-TimeSpanCenter
    ImagingHighightYRange=[0 3];
    HighlightXLim=t+[-TimeSpanCenter,TimeSpanCenter];
    UseSmoothedTraces=0;
    run('Quantal_Analysis_EPhys_Alignment_Export.m')
    Full_Export_Fig(AlignFig,[s1,s2],[FigureSaveDir,dc,FigName],0)
    ImagingHighightYRange=[0 3];
    UseSmoothedTraces=1;
    run('Quantal_Analysis_EPhys_Alignment_Export.m')
    Full_Export_Fig(AlignFig,[s1,s2],[FigureSaveDir,dc,FigName],0)
    ImagingHighightYRange=[-3 0];
    HighlightXLim=t+[-TimeSpanCenter,TimeSpanCenter];
    UseSmoothedTraces=0;
    run('Quantal_Analysis_EPhys_Alignment_Export.m')
    Full_Export_Fig(AlignFig,[s1,s2],[FigureSaveDir,dc,FigName],0)
    ImagingHighightYRange=[-3 0];
    UseSmoothedTraces=1;
    run('Quantal_Analysis_EPhys_Alignment_Export.m')
    Full_Export_Fig(AlignFig,[s1,s2],[FigureSaveDir,dc,FigName],0)
    close all
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
close all
HighlightXLim=MatchX;
ImagingHighlightUnit='\DeltaF/F';
MovieInterval=0.01;
TimeSpan=2;
TimeSpanCenter=round(TimeSpan/2);
ImagingHighightYRange=[0 3];
UseSmoothedTraces=0;
run('Quantal_Analysis_EPhys_Alignment_Export.m')
mov = VideoWriter([MoviesScratchDir,dc,FigName,'.avi'],'Motion JPEG AVI');
mov.FrameRate = 10;  % Default 30
mov.Quality = 95;    % Default 75
open(mov);
for t=MatchX(1)+TimeSpanCenter:MovieInterval:MatchX(2)-TimeSpanCenter
    axes(s1)
    delete(p1a);delete(t1a);delete(p1b);delete(t1b);
    xlim(t+[-TimeSpanCenter,TimeSpanCenter])
    YLimits=ylim;
    XLimits=xlim;
    hold on
    p1a=plot([XLimits(1)+0.1,XLimits(1)+0.1+HighlightHorzScale],[YLimits(2),YLimits(2)]-(YLimits(2)-YLimits(1))*0.05,...
        '-','color','k','linewidth',3);
    t1a=text(mean([XLimits(1)+0.1,XLimits(1)+0.1+HighlightHorzScale]),[YLimits(2)]-(YLimits(2)-YLimits(1))*0.05,...
        [num2str(HighlightHorzScale),' ',HighlightTimeScale],'color','k','fontsize',14,'horizontalalignment','center','verticalalignment','top');
    p1b=plot([XLimits(1),XLimits(1)]+(XLimits(2)-XLimits(1))*0.01,[YLimits(2),YLimits(2)-EphysHighlightScale]-(YLimits(2)-YLimits(1))*0.05,...
        '-','color','k','linewidth',3);
    t1b=text(XLimits(1)+(XLimits(2)-XLimits(1))*0.01,mean([YLimits(2),YLimits(2)-EphysHighlightScale]-(YLimits(2)-YLimits(1))*0.05),...
        [' ',num2str(EphysHighlightScale),' ',EphysUnit],'color','k','fontsize',14,'horizontalalignment','left','verticalalignment','middle'); 
    axes(s2)
    delete(p2a);delete(t2a);
    xlim(t+[-TimeSpanCenter,TimeSpanCenter])
    hold on
    YLimits=ylim;
    XLimits=xlim;
    if any(ImagingHighightYRange<0)
        p2a=plot([XLimits(1),XLimits(1)]+(XLimits(2)-XLimits(1))*0.015,...
            -1*[(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale],...
            '-','color','k','linewidth',3);
        t2a=text(XLimits(1)+(XLimits(2)-XLimits(1))*0.015,...
            -1*mean([(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale]),...
            [' ',num2str(ImagingHighlightScale),' ',ImagingHighlightUnit],...
            'color','k','fontsize',14,'horizontalalignment','left','verticalalignment','middle');
    else
        p2a=plot([XLimits(1),XLimits(1)]+(XLimits(2)-XLimits(1))*0.015,...
            [(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale],...
            '-','color','k','linewidth',3);
        t2a=text(XLimits(1)+(XLimits(2)-XLimits(1))*0.015,...
            mean([(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale]),...
            [' ',num2str(ImagingHighlightScale),' ',ImagingHighlightUnit],...
            'color','k','fontsize',14,'horizontalalignment','left','verticalalignment','middle');
    end
    OneFrame = getframe(AlignFig);
    writeVideo(mov,OneFrame);
    pause(0.1);
end
close(mov);
close(AlignFig)
copyfile([MoviesScratchDir,dc,FigName,'.avi'],MoviesSaveDir)
delete([MoviesScratchDir,dc,FigName,'.avi'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
close all
HighlightXLim=MatchX;
ImagingHighlightUnit='\DeltaF/F';
MovieInterval=0.01;
TimeSpan=2;
TimeSpanCenter=round(TimeSpan/2);
UseSmoothedTraces=0;
IncludeImages=1;
%MovieContrast=[0,max(max(max(EPhys_Align_ImageArray(:,:,EventDetectionSettings.Simple_Auto_Event_Finder_Settings.DataType,:))))*0.5];
%MovieContrast=[0,10000];
ColorScalar=100;
OverlayColor=[0.3,0.3,0.3];
ImagingHighlightScale=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Tiled Version
switch RecordingNum
    case 1
    	MovieContrast=[0,10000]
        ImagingHighightYRange=[-10 0]
        TileGroups=5
    case 3
    	MovieContrast=[0,10000]
        ImagingHighightYRange=[-10 0]
        TileGroups=5
    case 19
    	MovieContrast=[0,5000]
        ImagingHighightYRange=[-10 0]
        TileGroups=5
    case 20
        MovieContrast=[0,5000]
        ImagingHighightYRange=[-10 0]
        TileGroups=5
end
run('Quantal_Analysis_EPhys_Alignment_Export.m')
mov = VideoWriter([MoviesScratchDir,dc,FigName,'.avi'],'Motion JPEG AVI');
mov.FrameRate = 20;  % Default 30
mov.Quality = 95;    % Default 75
open(mov);
p0=[];
for t=MatchX(1):MovieInterval:MatchX(2)
    CurrentFrame=0;
    for tt=1:length(XData_Imaging_Adjusted)
        if any(round(t*(1/ImagingInfo.InterFrameTime))/(1/ImagingInfo.InterFrameTime)==round(XData_Imaging_Adjusted(tt)*(1/ImagingInfo.InterFrameTime))/(1/ImagingInfo.InterFrameTime))
            CurrentFrame=tt;
        end
    end
    
    figure(AlignFig)
    axes(s1)
    delete(p1a);delete(t1a);delete(p1b);delete(t1b);
    if ~isempty(p0)
        delete(p0)
    end
    xlim(t+[-TimeSpanCenter,TimeSpanCenter])
    YLimits=ylim;
    XLimits=xlim;
    hold on
    p1a=plot([XLimits(1)+0.1,XLimits(1)+0.1+HighlightHorzScale],[YLimits(2),YLimits(2)]-(YLimits(2)-YLimits(1))*0.05,...
        '-','color','k','linewidth',3);
    t1a=text(mean([XLimits(1)+0.1,XLimits(1)+0.1+HighlightHorzScale]),[YLimits(2)]-(YLimits(2)-YLimits(1))*0.05,...
        [num2str(HighlightHorzScale),' ',HighlightTimeScale],'color','k','fontsize',14,'horizontalalignment','center','verticalalignment','top');
    p1b=plot([XLimits(1),XLimits(1)]+(XLimits(2)-XLimits(1))*0.01,[YLimits(2),YLimits(2)-EphysHighlightScale]-(YLimits(2)-YLimits(1))*0.05,...
        '-','color','k','linewidth',3);
    t1b=text(XLimits(1)+(XLimits(2)-XLimits(1))*0.01,mean([YLimits(2),YLimits(2)-EphysHighlightScale]-(YLimits(2)-YLimits(1))*0.05),...
        [' ',num2str(EphysHighlightScale),' ',EphysUnit],'color','k','fontsize',14,'horizontalalignment','left','verticalalignment','middle'); 
    axes(s2)
    delete(p2a);delete(t2a);
    xlim(t+[-TimeSpanCenter,TimeSpanCenter])
    hold on
    YLimits=ylim;
    XLimits=xlim;
    if any(ImagingHighightYRange<0)
        p2a=plot([XLimits(1),XLimits(1)]+(XLimits(2)-XLimits(1))*0.015,...
            -1*[(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale],...
            '-','color','k','linewidth',3);
        t2a=text(XLimits(1)+(XLimits(2)-XLimits(1))*0.015,...
            -1*mean([(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale]),...
            [' ',num2str(ImagingHighlightScale),' ',ImagingHighlightUnit],...
            'color','k','fontsize',14,'horizontalalignment','left','verticalalignment','middle');
    else
        p2a=plot([XLimits(1),XLimits(1)]+(XLimits(2)-XLimits(1))*0.015,...
            [(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale],...
            '-','color','k','linewidth',3);
        t2a=text(XLimits(1)+(XLimits(2)-XLimits(1))*0.015,...
            mean([(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale]),...
            [' ',num2str(ImagingHighlightScale),' ',ImagingHighlightUnit],...
            'color','k','fontsize',14,'horizontalalignment','left','verticalalignment','middle');
    end
    p0=plot([t,t],YLimits,'--','color',[0.3,0.3,0.3],'linewidth',2);
    chH = get(s2,'Children');
    set(s2,'Children',flipud(chH));
    
    CurrentFrame=0;
    for tt=1:length(XData_Imaging_Adjusted)
        if any(round(t*(1/ImagingInfo.InterFrameTime))/(1/ImagingInfo.InterFrameTime)==round(XData_Imaging_Adjusted(tt)*(1/ImagingInfo.InterFrameTime))/(1/ImagingInfo.InterFrameTime))
            CurrentFrame=tt;
        end
    end
    if CurrentFrame>0
        axes(s0)
        cla
        [~,TempContrastedImageColor,~]=...
            Adjust_Contrast_and_Color(EPhys_Align_ImageArray(:,:,EventDetectionSettings.Simple_Auto_Event_Finder_Settings.DataType,CurrentFrame),...
            MovieContrast(1),MovieContrast(2),'jet',ColorScalar);
        TempContrastedImageColor=ColorMasking(TempContrastedImageColor,~AllBoutonsRegion,OverlayColor);
        s0=subtightplot(2,2,3,[0,0],[0,0],[0,0]);
        imshow(TempContrastedImageColor,'border','tight');
        TempPos=get(s0,'position');
        TempPos(4)=1;
        set(s0,'position',TempPos);
    end
    
    OneFrame = getframe(AlignFig);
    writeVideo(mov,OneFrame);
    pause(0.1);
end
close(mov);
close(AlignFig)
copyfile([MoviesScratchDir,dc,FigName,'.avi'],MoviesSaveDir)
delete([MoviesScratchDir,dc,FigName,'.avi'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Overlayed Version
switch RecordingNum
    case 1
    	MovieContrast=[0,10000]
        ImagingHighightYRange=[0 3]
        TileGroups=1
    case 3
    	MovieContrast=[0,10000]
        ImagingHighightYRange=[0 3]
        TileGroups=1
    case 19
    	MovieContrast=[0,5000]
        ImagingHighightYRange=[0 3]
        TileGroups=1
    case 20
        MovieContrast=[0,5000]
        ImagingHighightYRange=[0 3]
        TileGroups=1
end
run('Quantal_Analysis_EPhys_Alignment_Export.m')
mov = VideoWriter([MoviesScratchDir,dc,FigName,'.avi'],'Motion JPEG AVI');
mov.FrameRate = 20;  % Default 30
mov.Quality = 95;    % Default 75
open(mov);
p0=[];
for t=MatchX(1):MovieInterval:MatchX(2)
    CurrentFrame=0;
    for tt=1:length(XData_Imaging_Adjusted)
        if any(round(t*(1/ImagingInfo.InterFrameTime))/(1/ImagingInfo.InterFrameTime)==round(XData_Imaging_Adjusted(tt)*(1/ImagingInfo.InterFrameTime))/(1/ImagingInfo.InterFrameTime))
            CurrentFrame=tt;
        end
    end
    
    figure(AlignFig)
    axes(s1)
    delete(p1a);delete(t1a);delete(p1b);delete(t1b);
    if ~isempty(p0)
        delete(p0)
    end
    xlim(t+[-TimeSpanCenter,TimeSpanCenter])
    YLimits=ylim;
    XLimits=xlim;
    hold on
    p1a=plot([XLimits(1)+0.1,XLimits(1)+0.1+HighlightHorzScale],[YLimits(2),YLimits(2)]-(YLimits(2)-YLimits(1))*0.05,...
        '-','color','k','linewidth',3);
    t1a=text(mean([XLimits(1)+0.1,XLimits(1)+0.1+HighlightHorzScale]),[YLimits(2)]-(YLimits(2)-YLimits(1))*0.05,...
        [num2str(HighlightHorzScale),' ',HighlightTimeScale],'color','k','fontsize',14,'horizontalalignment','center','verticalalignment','top');
    p1b=plot([XLimits(1),XLimits(1)]+(XLimits(2)-XLimits(1))*0.01,[YLimits(2),YLimits(2)-EphysHighlightScale]-(YLimits(2)-YLimits(1))*0.05,...
        '-','color','k','linewidth',3);
    t1b=text(XLimits(1)+(XLimits(2)-XLimits(1))*0.01,mean([YLimits(2),YLimits(2)-EphysHighlightScale]-(YLimits(2)-YLimits(1))*0.05),...
        [' ',num2str(EphysHighlightScale),' ',EphysUnit],'color','k','fontsize',14,'horizontalalignment','left','verticalalignment','middle'); 
    axes(s2)
    delete(p2a);delete(t2a);
    xlim(t+[-TimeSpanCenter,TimeSpanCenter])
    hold on
    YLimits=ylim;
    XLimits=xlim;
    if any(ImagingHighightYRange<0)
        p2a=plot([XLimits(1),XLimits(1)]+(XLimits(2)-XLimits(1))*0.015,...
            -1*[(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale],...
            '-','color','k','linewidth',3);
        t2a=text(XLimits(1)+(XLimits(2)-XLimits(1))*0.015,...
            -1*mean([(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale]),...
            [' ',num2str(ImagingHighlightScale),' ',ImagingHighlightUnit],...
            'color','k','fontsize',14,'horizontalalignment','left','verticalalignment','middle');
    else
        p2a=plot([XLimits(1),XLimits(1)]+(XLimits(2)-XLimits(1))*0.015,...
            [(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale],...
            '-','color','k','linewidth',3);
        t2a=text(XLimits(1)+(XLimits(2)-XLimits(1))*0.015,...
            mean([(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale]),...
            [' ',num2str(ImagingHighlightScale),' ',ImagingHighlightUnit],...
            'color','k','fontsize',14,'horizontalalignment','left','verticalalignment','middle');
    end
    p0=plot([t,t],YLimits,'--','color',[0.3,0.3,0.3],'linewidth',2);
    chH = get(s2,'Children');
    set(s2,'Children',flipud(chH));
    
    CurrentFrame=0;
    for tt=1:length(XData_Imaging_Adjusted)
        if any(round(t*(1/ImagingInfo.InterFrameTime))/(1/ImagingInfo.InterFrameTime)==round(XData_Imaging_Adjusted(tt)*(1/ImagingInfo.InterFrameTime))/(1/ImagingInfo.InterFrameTime))
            CurrentFrame=tt;
        end
    end
    if CurrentFrame>0
        axes(s0)
        cla
        [~,TempContrastedImageColor,~]=...
            Adjust_Contrast_and_Color(EPhys_Align_ImageArray(:,:,EventDetectionSettings.Simple_Auto_Event_Finder_Settings.DataType,CurrentFrame),...
            MovieContrast(1),MovieContrast(2),'jet',ColorScalar);
        TempContrastedImageColor=ColorMasking(TempContrastedImageColor,~AllBoutonsRegion,OverlayColor);
        s0=subtightplot(2,2,3,[0,0],[0,0],[0,0]);
        imshow(TempContrastedImageColor,'border','tight');
        TempPos=get(s0,'position');
        TempPos(4)=1;
        set(s0,'position',TempPos);
    end
    
    OneFrame = getframe(AlignFig);
    writeVideo(mov,OneFrame);
    pause(0.1);
end
close(mov);
close(AlignFig)
copyfile([MoviesScratchDir,dc,FigName,'.avi'],MoviesSaveDir)
delete([MoviesScratchDir,dc,FigName,'.avi'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
fprintf('Saving Data...')
save([SaveDir,SaveName,'_EPhys_Alignment.mat'])
fprintf('Finished!\n');





