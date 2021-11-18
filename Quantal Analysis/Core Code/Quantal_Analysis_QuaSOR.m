%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
if ~exist('AnalysisParts')
    [AnalysisPartsChoice, ~] = listdlg('PromptString','Select Analysis Parts?','SelectionMode','single','ListString',AnalysisPartsChoiceOptions,'ListSize', [600 600]);
    AnalysisParts=AnalysisPartOptions{AnalysisPartsChoice};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(0);
if ~exist('Client_Recording')
    Client_Recording=[];
end
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
    elseif ~isempty(Client_Recording)
        RecordingNum=Client_Recording(RecordingNum).RecordingNum;
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
FileSuffix='_EventDetectionData.mat';
load([SaveDir,StackSaveName,FileSuffix],'SplitEpisodeFiles')
if any(AnalysisParts>0)
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
    load([CurrentScratchDir,StackSaveName,FileSuffix],'EventDetectionSettings','PixelMax_Struct','SplitEpisodeFiles');
    fprintf('Finished!\n')

else

end
disp('============================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('SplitEpisodeFiles')
    SplitEpisodeFiles=0;
end
if SplitEpisodeFiles&&any(AnalysisParts>0)
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
disp('============================================================')
FileSuffix='_QuaSOR_Data.mat';
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
    if any(AnalysisParts>0)
        fprintf(['Loading ',StackSaveName,FileSuffix,'...']);
        load([CurrentScratchDir,StackSaveName,FileSuffix]);
        fprintf('Finished!\n')
    else
        load([CurrentScratchDir,StackSaveName,FileSuffix],'QuaSOR_Parameters','QuaSOR_Event_Extraction_Settings','ScaleBar_Upscale');
    end
end
disp('============================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('SplitEpisodeFiles')
    SplitEpisodeFiles=0;
end
if SplitEpisodeFiles&&any(AnalysisParts>0)
    for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
        FileSuffix=['_QuaSOR_Data_Ep_',num2str(EpisodeNumber_Load),'.mat'];
        if Safe2CopyDelete
            fprintf(['Copying: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
            [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
            fprintf('Finished!\n')
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('============================================================')
FileSuffix='_QuaSOR_Maps.mat';
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
    if any(AnalysisParts>0)
        fprintf(['Loading ',StackSaveName,FileSuffix,'...']);
        load([CurrentScratchDir,StackSaveName,FileSuffix]);
        fprintf('Finished!\n')
    else
        load([CurrentScratchDir,StackSaveName,FileSuffix],'QuaSOR_Map_Settings','PixelMax_Map_Settings','QuaSOR_LowRes_Map_Settings');
    end
end
disp('============================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('============================================================')
FileSuffix='_QuaSOR_AZs.mat';
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
    if any(AnalysisParts>0)
        fprintf(['Loading ',StackSaveName,FileSuffix,'...']);
        load([CurrentScratchDir,StackSaveName,FileSuffix]);
        fprintf('Finished!\n')
    else
        load([CurrentScratchDir,StackSaveName,FileSuffix],'QuaSOR_Auto_AZ_Settings');
    end
end
disp('============================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('============================================================')
FileSuffix='_QuaSOR_Evaluation.mat';
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
    if any(AnalysisParts>0)
        fprintf(['Loading ',StackSaveName,FileSuffix,'...']);
        load([CurrentScratchDir,StackSaveName,FileSuffix]);
        fprintf('Finished!\n')
    end
end
disp('============================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('SplitEpisodeFiles')
    SplitEpisodeFiles=0;
end
if SplitEpisodeFiles&&any(AnalysisParts>0)
    for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
        FileSuffix=['_QuaSOR_Evaluation_Ep_',num2str(EpisodeNumber_Load),'.mat'];
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
    if ~exist('AdjustONLY')
        AdjustONLY=0;
    end
    if ~exist('DebugMode')
        DebugMode=0;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%Default Parameters Sets (we can add more defaults)
for zzzz=1:1%if ~exist('GlobalDefault_QuaSOR_Parameters')
    Mod=1;
    GlobalDefault_QuaSOR_Parameters.Modality(Mod).Label='Evoked';
    Mod=2;
    GlobalDefault_QuaSOR_Parameters.Modality(Mod).Label='Spontaneous';
    switch ImagingInfo.ModalityType
        case 1  
            %Save/Display Parameters
            GlobalDefault_QuaSOR_Parameters.QuaSOR_Mode=2;
            GlobalDefault_QuaSOR_Parameters.General.StoreAllFitTests=0;
            GlobalDefault_QuaSOR_Parameters.General.SaveStacks=0; %Very large
            GlobalDefault_QuaSOR_Parameters.General.Reconstruct_Upscale_Fit_Stack=0; %currently you must leave QuaSOR_Parameters.General.DisplayFinal on to make a movie
            GlobalDefault_QuaSOR_Parameters.General.DisplayOn=0;%lots of plots if you want 'em, useful for parameter testing
            GlobalDefault_QuaSOR_Parameters.General.DisplayFinal=0;%Realtime plotting
            GlobalDefault_QuaSOR_Parameters.General.DisplayRegionTracking=0;
            GlobalDefault_QuaSOR_Parameters.General.SaveIntermediates=0;
            GlobalDefault_QuaSOR_Parameters.General.MinimizeFigureWindow=0;
            GlobalDefault_QuaSOR_Parameters.General.MemorySaver=0;
            GlobalDefault_QuaSOR_Parameters.General.EventThreshold=200;
            GlobalDefault_QuaSOR_Parameters.General.GBThreshold=5e9;
            GlobalDefault_QuaSOR_Parameters.General.ScalePoint_Scalar=200;%Normalization value aka how many points for density representations
            GlobalDefault_QuaSOR_Parameters.General.BoxAdjustment=0;    

            %Upscaling settings
            GlobalDefault_QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust=-1.5;
            GlobalDefault_QuaSOR_Parameters.UpScaling.UpScale_CoordinateAdjust=0; %not used
            GlobalDefault_QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor=10;
            GlobalDefault_QuaSOR_Parameters.UpScaling.UpScaleMethod='nearest';
            GlobalDefault_QuaSOR_Parameters.UpScaling.XOffset=0; %for the upscale remapping, need to adjust?
            GlobalDefault_QuaSOR_Parameters.UpScaling.YOffset=0;
            %GlobalDefault_QuaSOR_Parameters.UpScaling.UpScale_Fix_Adjust=-1;

            %Display Settings
%             GlobalDefault_QuaSOR_Parameters.Display.PixelMax_Color='b';
%             GlobalDefault_QuaSOR_Parameters.Display.QuaSOR_Color='y';    
%             GlobalDefault_QuaSOR_Parameters.Display.UpScale_Map_FilterSize=11;
%             GlobalDefault_QuaSOR_Parameters.Display.UpScale_Map_FilterSigma=2;
%             GlobalDefault_QuaSOR_Parameters.Display.LowPercent=0;
%             GlobalDefault_QuaSOR_Parameters.Display.HighPercent=0.2;
%             GlobalDefault_QuaSOR_Parameters.Display.LowPercent1=0;
%             GlobalDefault_QuaSOR_Parameters.Display.HighPercent1=0;
%             GlobalDefault_QuaSOR_Parameters.Display.MarkerSize=10;   
            GlobalDefault_QuaSOR_Parameters.Display.DilateRegion=1;
            GlobalDefault_QuaSOR_Parameters.Display.BorderThickness=1;    
            GlobalDefault_QuaSOR_Parameters.Display.UseBorderLine=1;
            GlobalDefault_QuaSOR_Parameters.Display.BorderColor='w';
            GlobalDefault_QuaSOR_Parameters.Display.BorderLineAdjustment=0;%for fig export a 2 pixel shift needs to be applied to the border lines or they are off a little
            GlobalDefault_QuaSOR_Parameters.Display.MovieScaleFactor=2;
            GlobalDefault_QuaSOR_Parameters.Display.MovieFPS=10;
            GlobalDefault_QuaSOR_Parameters.Display.MovieQuality=90;

        case 2
            GlobalDefault_QuaSOR_Parameters.QuaSOR_Mode=2;
            %Save/Display Parameters
            GlobalDefault_QuaSOR_Parameters.General.StoreAllFitTests=0;
            GlobalDefault_QuaSOR_Parameters.General.SaveStacks=0; %Very large
            GlobalDefault_QuaSOR_Parameters.General.Reconstruct_Upscale_Fit_Stack=0; %currently you must leave QuaSOR_Parameters.General.DisplayFinal on to make a movie
            GlobalDefault_QuaSOR_Parameters.General.DisplayOn=0;%lots of plots if you want 'em, useful for parameter testing
            GlobalDefault_QuaSOR_Parameters.General.DisplayFinal=0;%Realtime plotting
            GlobalDefault_QuaSOR_Parameters.General.DisplayRegionTracking=0;
            GlobalDefault_QuaSOR_Parameters.General.SaveIntermediates=0;
            GlobalDefault_QuaSOR_Parameters.General.MinimizeFigureWindow=0;
            GlobalDefault_QuaSOR_Parameters.General.MemorySaver=0;
            GlobalDefault_QuaSOR_Parameters.General.EventThreshold=200;
            GlobalDefault_QuaSOR_Parameters.General.GBThreshold=5e9;
            GlobalDefault_QuaSOR_Parameters.General.ScalePoint_Scalar=200;%Normalization value aka how many points for density representations
            GlobalDefault_QuaSOR_Parameters.General.BoxAdjustment=0;    

            %Upscaling settings
            GlobalDefault_QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust=-1.5;
            GlobalDefault_QuaSOR_Parameters.UpScaling.UpScale_CoordinateAdjust=0; %not used
            GlobalDefault_QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor=10;
            GlobalDefault_QuaSOR_Parameters.UpScaling.UpScaleMethod='nearest';
            GlobalDefault_QuaSOR_Parameters.UpScaling.XOffset=0; %for the upscale remapping, need to adjust?
            GlobalDefault_QuaSOR_Parameters.UpScaling.YOffset=0;
            %GlobalDefault_QuaSOR_Parameters.UpScaling.UpScale_Fix_Adjust=-1;

            %Display Settings
%             GlobalDefault_QuaSOR_Parameters.Display.PixelMax_Color='b';
%             GlobalDefault_QuaSOR_Parameters.Display.QuaSOR_Color='y';    
%             GlobalDefault_QuaSOR_Parameters.Display.UpScale_Map_FilterSize=11;
%             GlobalDefault_QuaSOR_Parameters.Display.UpScale_Map_FilterSigma=2;
%             GlobalDefault_QuaSOR_Parameters.Display.LowPercent=0;
%             GlobalDefault_QuaSOR_Parameters.Display.HighPercent=0.2;
%             GlobalDefault_QuaSOR_Parameters.Display.LowPercent1=0;
%             GlobalDefault_QuaSOR_Parameters.Display.HighPercent1=0;
%             GlobalDefault_QuaSOR_Parameters.Display.MarkerSize=10;   
            GlobalDefault_QuaSOR_Parameters.Display.DilateRegion=1;
            GlobalDefault_QuaSOR_Parameters.Display.BorderThickness=1;    
            GlobalDefault_QuaSOR_Parameters.Display.UseBorderLine=1;
            GlobalDefault_QuaSOR_Parameters.Display.BorderColor='w';
            GlobalDefault_QuaSOR_Parameters.Display.BorderLineAdjustment=0;%for fig export a 2 pixel shift needs to be applied to the border lines or they are off a little
            GlobalDefault_QuaSOR_Parameters.Display.MovieScaleFactor=2;
            GlobalDefault_QuaSOR_Parameters.Display.MovieFPS=10;
            GlobalDefault_QuaSOR_Parameters.Display.MovieQuality=90;

        case 3
            GlobalDefault_QuaSOR_Parameters.QuaSOR_Mode=2;
            %Save/Display Parameters
            GlobalDefault_QuaSOR_Parameters.General.StoreAllFitTests=0;
            GlobalDefault_QuaSOR_Parameters.General.SaveStacks=0; %Very large
            GlobalDefault_QuaSOR_Parameters.General.Reconstruct_Upscale_Fit_Stack=0; %currently you must leave QuaSOR_Parameters.General.DisplayFinal on to make a movie
            GlobalDefault_QuaSOR_Parameters.General.DisplayOn=0;%lots of plots if you want 'em, useful for parameter testing
            GlobalDefault_QuaSOR_Parameters.General.DisplayFinal=0;%Realtime plotting
            GlobalDefault_QuaSOR_Parameters.General.DisplayRegionTracking=0;
            GlobalDefault_QuaSOR_Parameters.General.SaveIntermediates=0;
            GlobalDefault_QuaSOR_Parameters.General.MinimizeFigureWindow=0;
            GlobalDefault_QuaSOR_Parameters.General.MemorySaver=0;
            GlobalDefault_QuaSOR_Parameters.General.EventThreshold=200;
            GlobalDefault_QuaSOR_Parameters.General.GBThreshold=5e9;
            GlobalDefault_QuaSOR_Parameters.General.ScalePoint_Scalar=200;%Normalization value aka how many points for density representations
            GlobalDefault_QuaSOR_Parameters.General.BoxAdjustment=0;    

            %Upscaling settings
            GlobalDefault_QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust=-1.5;
            GlobalDefault_QuaSOR_Parameters.UpScaling.UpScale_CoordinateAdjust=0; %not used
            GlobalDefault_QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor=10;
            GlobalDefault_QuaSOR_Parameters.UpScaling.UpScaleMethod='nearest';
            GlobalDefault_QuaSOR_Parameters.UpScaling.XOffset=0; %for the upscale remapping, need to adjust?
            GlobalDefault_QuaSOR_Parameters.UpScaling.YOffset=0;
            %GlobalDefault_QuaSOR_Parameters.UpScaling.UpScale_Fix_Adjust=-1;

            %Display Settings
%             GlobalDefault_QuaSOR_Parameters.Display.PixelMax_Color='b';
%             GlobalDefault_QuaSOR_Parameters.Display.QuaSOR_Color='y';    
%             GlobalDefault_QuaSOR_Parameters.Display.UpScale_Map_FilterSize=11;
%             GlobalDefault_QuaSOR_Parameters.Display.UpScale_Map_FilterSigma=2;
%             GlobalDefault_QuaSOR_Parameters.Display.LowPercent=0;
%             GlobalDefault_QuaSOR_Parameters.Display.HighPercent=0.2;
%             GlobalDefault_QuaSOR_Parameters.Display.LowPercent1=0;
%             GlobalDefault_QuaSOR_Parameters.Display.HighPercent1=0;
%             GlobalDefault_QuaSOR_Parameters.Display.MarkerSize=10;   
            GlobalDefault_QuaSOR_Parameters.Display.DilateRegion=1;
            GlobalDefault_QuaSOR_Parameters.Display.BorderThickness=1;    
            GlobalDefault_QuaSOR_Parameters.Display.UseBorderLine=1;
            GlobalDefault_QuaSOR_Parameters.Display.BorderColor='w';
            GlobalDefault_QuaSOR_Parameters.Display.BorderLineAdjustment=0;%for fig export a 2 pixel shift needs to be applied to the border lines or they are off a little
            GlobalDefault_QuaSOR_Parameters.Display.MovieScaleFactor=2;
            GlobalDefault_QuaSOR_Parameters.Display.MovieFPS=10;
            GlobalDefault_QuaSOR_Parameters.Display.MovieQuality=90;

    end
end
for zzzz=1:1%if ~exist('Default_QuaSOR_Parameters')
    q=0;
    clear Default_QuaSOR_Parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Example Low Freq Evoked Fitting Parameters 
            q=q+1;Default_QuaSOR_Parameters(q).ParameterSet_Name='Example Low Freq Evoked Fitting Parameters';
            for b=1:1
                %Region settings
                Default_QuaSOR_Parameters(q).Region.FixedROISize=0;
                Default_QuaSOR_Parameters(q).Region.RegionSize_um2=0;
                Default_QuaSOR_Parameters(q).Region.RegionSplitting_Threshold=0.05; %Apply a stricter threshold to the initial region finding CorrAmp map to get more smaller regions, will need to adjust for different inputs/amplitudes
                Default_QuaSOR_Parameters(q).Region.RegionSplitting_Threshold_Increase=0.05;
                Default_QuaSOR_Parameters(q).Region.Max_Region_Area_um2=35; %will split by increasing the starting threshold value
                Default_QuaSOR_Parameters(q).Region.Min_Region_Area_um2=0.6;
                Default_QuaSOR_Parameters(q).Region.RegionEdge_Padding_um=0.4; %to increase the size of the
                Default_QuaSOR_Parameters(q).Region.SuppressBorder=1; %Can avoid any matches too close to the border, shouldnt be a problem anymore but probably safer
                Default_QuaSOR_Parameters(q).Region.SuppressBorderSize_um=0.4;
                Default_QuaSOR_Parameters(q).Region.SuppressBorderRatio=0.8;%how much to suppress edge pixel values

                %Replicate/components handling
                Default_QuaSOR_Parameters(q).Components.NumReplicates=20;%Initial number of complete runs through progressing numbers of components
                Default_QuaSOR_Parameters(q).Components.MaxNumGaussians=6;%Initial number of components to test per window can set differently for different inputs
                Default_QuaSOR_Parameters(q).Components.ReplicateIncrease=10; %The number of test fits will increase as the number of components increases
                Default_QuaSOR_Parameters(q).Components.MaxAllowed_NumReplicates=200;%To prevent too many tests
                Default_QuaSOR_Parameters(q).Components.MaxAllowed_NumGaussians=8;%to prevent too many fits.  with very large regions this would need to be increased
                Default_QuaSOR_Parameters(q).Components.MaxAllowed_NumResets=1;%if no good fits are found it will restart after adjusting parameters
                Default_QuaSOR_Parameters(q).Components.Repeat_Amp_Threshold=0.1;
                Default_QuaSOR_Parameters(q).Components.RunInParallelMode=2;%new method is very different, currently the non-parallel mode is not a default option

                %GMM Settings
                Default_QuaSOR_Parameters(q).GMM.Check_Prior_Frame_Fit=0;%This option will allow the script to check for conditions that would allow the frame prior to the peak frame to be used for fitting, probably most useful in Is where spots spread rapidly
                Default_QuaSOR_Parameters(q).GMM.Check_Prior_Frame_Limits=[0.3,0.8];%Will trigger an alternative image if the frame before the TemplatePeakPosition is within this range.
                Default_QuaSOR_Parameters(q).GMM.FitFiltered=0;%uses filtered data for the primary analysis, I would rather not have to use this but it seems to work better and less errors
                Default_QuaSOR_Parameters(q).GMM.TestFiltered=0;%use a filtered test image for the 2d correlation testing procedure to avoid noise triggering more fits
                Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSize_um=3;%Filter the TestImage, gaussian, might be bad prior to gaussian fitting, data was intially gaussian filtered once
                Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSigma_um=1;
                Default_QuaSOR_Parameters(q).GMM.MinDistance_um=0.8;%helps avoid double matches right on top of one another but might be good
                Default_QuaSOR_Parameters(q).GMM.PenalizeMoreComponents=1;%Will try to supress fits that have more components
                Default_QuaSOR_Parameters(q).GMM.NumCompPenalty=-0.15;%how much to scale the 
                Default_QuaSOR_Parameters(q).GMM.ProbabilityTolerance=1e-9;%not used right now
                Default_QuaSOR_Parameters(q).GMM.InternalReplicates=1;%how many replicates each fitgmdist call runs, it will pick the best fit from each run with the largest liklihood
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions=statset;
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions.Display='off';
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions.MaxIter=10;%To get different options keep this low
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions.TolFun=1e-6;%not sure but not used yet
                Default_QuaSOR_Parameters(q).GMM.StartCondition='randSample';%eventually I would like to guide fitting here
                Default_QuaSOR_Parameters(q).GMM.RegularizationValue=1e-6;%will keep the function converging and not going off to infinity
                Default_QuaSOR_Parameters(q).GMM.Minimum_Peak_Amplitude=0.05;
                Default_QuaSOR_Parameters(q).GMM.Minimum_Peak_Amplitude_EpisodeDelta=-0.0025;
                Default_QuaSOR_Parameters(q).GMM.Corr_Score_Scalar=3;

                %Mini-based Weighting Settings
                % SynapGCaMP6 Minis Ib Boutons
                % Amp Mean: 0.44989 STD: 0.37106
                % Variance Mean: 7.8505 STD: 3.5213
                % Variance Diff Mean: 2.3381 STD: 2.2767
                % Covariance Mean: -0.1273 STD: 1.7553
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Hist_XData = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3];
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Norm_Hist = [0.7185, 1, 0.92279, 0.87882, 0.71153, 0.55818, 0.42145, 0.31957, 0.24665, 0.18874, 0.14263, 0.10509, 0.078284, 0.057373, 0.046113, 0.034853, 0.026273, 0.021984, 0.017694, 0.012869, 0.010724, 0.0085791, 0.0053619, 0.0037534, 0.0037534, 0.002681, 0.0016086, 0.0010724, 0.0010724, 0, 0];
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Scalar=1;

                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Hist_XData_um = [0, 0.210, 0.420, 0.630, 0.840, 1.05, 1.26, 1.47, 1.68, 1.89, 2.10, 2.31, 2.52, 2.73, 2.94, 3.15, 3.36, 3.57, 3.78, 3.99, 4.20, 4.41, 4.62, 4.83, 5.04, 5.25, 5.46, 5.67, 5.88, 6.09, 6.30, 6.51, 6.72, 6.93, 7.14, 7.35, 7.56, 7.77, 7.98, 8.19, 8.40];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Norm_Hist = [0, 0.029842, 0.25878, 0.45304, 0.67365, 0.89054, 0.98885, 1, 0.91757, 0.78209, 0.62872, 0.47601, 0.35709, 0.26385, 0.20101, 0.13682, 0.1, 0.069595, 0.056081, 0.036149, 0.020608, 0.016216, 0.0125, 0.0084459, 0.0054054, 0.0043919, 0.0030405, 0.0016892, 0.0010135, 0.0016892, 0.0016892, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Scalar=2;

                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Hist_XData_um = [0, 0.210, 0.420, 0.630, 0.840, 1.05, 1.26, 1.47, 1.68, 1.89, 2.10, 2.31, 2.52, 2.73, 2.94, 3.15, 3.36, 3.57, 3.78, 3.99, 4.20];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Norm_Hist = [0.75183, 1, 0.80085, 0.69951, 0.46024, 0.29159, 0.17927, 0.10427, 0.058537, 0.038049, 0.023049, 0.016463, 0.012439, 0.01061, 0.0065854, 0.0047561, 0.0032927, 0.002561, 0.0014634, 0.0018293, 0.0018293];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Scalar=2;

                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Hist_XData_um = [0, 0.105, 0.21, 0.315, 0.42, 0.525, 0.63, 0.735, 0.84, 0.945, 1.05, 1.155, 1.26, 1.365, 1.47, 1.575, 1.68, 1.785, 1.89, 1.995, 2.1];
                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Norm_Hist = [1, 0.45299, 0.29255, 0.096947, 0.056777, 0.02906, 0.015873, 0.010745, 0.0070818, 0.004884, 0.003663, 0.0026862, 0.0020757, 0.0017094, 0.0017094, 0.0019536, 0.0015873, 0.0013431, 0.0014652, 0.001221, 0.002442];
                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Scalar=1;
            end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Example Spontaneous Fitting Parameters
            q=q+1;Default_QuaSOR_Parameters(q).ParameterSet_Name='Example Spontaneous Fitting Parameters';
            for b=1:1

                %Region settings
                Default_QuaSOR_Parameters(q).Region.FixedROISize=0;
                Default_QuaSOR_Parameters(q).Region.RegionSize_um2=3.5;
                Default_QuaSOR_Parameters(q).Region.RegionSplitting_Threshold=0.05; %Apply a stricter threshold to the initial region finding CorrAmp map to get more smaller regions, will need to adjust for different inputs/amplitudes
                Default_QuaSOR_Parameters(q).Region.RegionSplitting_Threshold_Increase=0.05;
                Default_QuaSOR_Parameters(q).Region.Max_Region_Area_um2=35; %will split by increasing the starting threshold value
                Default_QuaSOR_Parameters(q).Region.Min_Region_Area_um2=0.6;
                Default_QuaSOR_Parameters(q).Region.RegionEdge_Padding_um=0.4; %to increase the size of the
                Default_QuaSOR_Parameters(q).Region.SuppressBorder=1; %Can avoid any matches too close to the border, shouldnt be a problem anymore but probably safer
                Default_QuaSOR_Parameters(q).Region.SuppressBorderSize_um=0.4;
                Default_QuaSOR_Parameters(q).Region.SuppressBorderRatio=0.8;%how much to suppress edge pixel values

                %Replicate/components handling
                Default_QuaSOR_Parameters(q).Components.NumReplicates=20;%Initial number of complete runs through progressing numbers of components
                Default_QuaSOR_Parameters(q).Components.MaxNumGaussians=1;%Initial number of components to test per window can set differently for different inputs
                Default_QuaSOR_Parameters(q).Components.ReplicateIncrease=10; %The number of test fits will increase as the number of components increases
                Default_QuaSOR_Parameters(q).Components.MaxAllowed_NumReplicates=200;%To prevent too many tests
                Default_QuaSOR_Parameters(q).Components.MaxAllowed_NumGaussians=2;%to prevent too many fits.  with very large regions this would need to be increased
                Default_QuaSOR_Parameters(q).Components.MaxAllowed_NumResets=1;%if no good fits are found it will restart after adjusting parameters
                Default_QuaSOR_Parameters(q).Components.Repeat_Amp_Threshold=0.1;
                Default_QuaSOR_Parameters(q).Components.RunInParallelMode=2;%new method is very different, currently the non-parallel mode is not a default option

                %GMM Settings
                Default_QuaSOR_Parameters(q).GMM.Check_Prior_Frame_Fit=0;%This option will allow the script to check for conditions that would allow the frame prior to the peak frame to be used for fitting, probably most useful in Is where spots spread rapidly
                Default_QuaSOR_Parameters(q).GMM.Check_Prior_Frame_Limits=[0.3,0.8];%Will trigger an alternative image if the frame before the TemplatePeakPosition is within this range.
                Default_QuaSOR_Parameters(q).GMM.FitFiltered=0;%uses filtered data for the primary analysis, I would rather not have to use this but it seems to work better and less errors
                Default_QuaSOR_Parameters(q).GMM.TestFiltered=0;%use a filtered test image for the 2d correlation testing procedure to avoid noise triggering more fits
                Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSize_um=5;%Filter the TestImage, gaussian, might be bad prior to gaussian fitting, data was intially gaussian filtered once
                Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSigma_um=1;
                Default_QuaSOR_Parameters(q).GMM.MinDistance_um=2;%helps avoid double matches right on top of one another but might be good
                Default_QuaSOR_Parameters(q).GMM.PenalizeMoreComponents=1;%Will try to supress fits that have more components
                Default_QuaSOR_Parameters(q).GMM.NumCompPenalty=-0.3;%how much to scale the 
                Default_QuaSOR_Parameters(q).GMM.ProbabilityTolerance=1e-9;%not used right now
                Default_QuaSOR_Parameters(q).GMM.InternalReplicates=1;%how many replicates each fitgmdist call runs, it will pick the best fit from each run with the largest liklihood
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions=statset;
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions.Display='off';
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions.MaxIter=10;%To get different options keep this low
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions.TolFun=1e-6;%not sure but not used yet
                Default_QuaSOR_Parameters(q).GMM.StartCondition='randSample';%eventually I would like to guide fitting here
                Default_QuaSOR_Parameters(q).GMM.RegularizationValue=1e-6;%will keep the function converging and not going off to infinity
                Default_QuaSOR_Parameters(q).GMM.Minimum_Peak_Amplitude=0.04;
                Default_QuaSOR_Parameters(q).GMM.Minimum_Peak_Amplitude_EpisodeDelta=-0.0025;
                Default_QuaSOR_Parameters(q).GMM.Corr_Score_Scalar=3;

                %Mini-based Weighting Settings
                % SynapGCaMP6 Minis Ib Boutons
                % Amp Mean: 0.44989 STD: 0.37106
                % Variance Mean: 7.8505 STD: 3.5213
                % Variance Diff Mean: 2.3381 STD: 2.2767
                % Covariance Mean: -0.1273 STD: 1.7553
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Hist_XData = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3];
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Norm_Hist = [0.7185, 1, 0.92279, 0.87882, 0.71153, 0.55818, 0.42145, 0.31957, 0.24665, 0.18874, 0.14263, 0.10509, 0.078284, 0.057373, 0.046113, 0.034853, 0.026273, 0.021984, 0.017694, 0.012869, 0.010724, 0.0085791, 0.0053619, 0.0037534, 0.0037534, 0.002681, 0.0016086, 0.0010724, 0.0010724, 0, 0];
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Scalar=1;

                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Hist_XData_um = [0, 0.210, 0.420, 0.630, 0.840, 1.05, 1.26, 1.47, 1.68, 1.89, 2.10, 2.31, 2.52, 2.73, 2.94, 3.15, 3.36, 3.57, 3.78, 3.99, 4.20, 4.41, 4.62, 4.83, 5.04, 5.25, 5.46, 5.67, 5.88, 6.09, 6.30];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Norm_Hist = [0, 0.029842, 0.25878, 0.45304, 0.67365, 0.89054, 0.98885, 1, 0.91757, 0.78209, 0.62872, 0.47601, 0.35709, 0.26385, 0.20101, 0.13682, 0.1, 0.069595, 0.056081, 0.036149, 0.020608, 0.016216, 0.0125, 0.0084459, 0.0054054, 0.0043919, 0.0030405, 0.0016892, 0.0010135, 0.0016892, 0.0016892];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Scalar=1;

                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Hist_XData_um = [0, 0.210, 0.420, 0.630, 0.840, 1.05, 1.26, 1.47, 1.68, 1.89, 2.10, 2.31, 2.52, 2.73, 2.94, 3.15, 3.36, 3.57, 3.78, 3.99, 4.20];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Norm_Hist = [0.75183, 1, 0.80085, 0.69951, 0.46024, 0.29159, 0.17927, 0.10427, 0.058537, 0.038049, 0.023049, 0.016463, 0.012439, 0.01061, 0.0065854, 0.0047561, 0.0032927, 0.002561, 0.0014634, 0.0018293, 0.0018293];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Scalar=2;

                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Hist_XData_um = [0, 0.105, 0.21, 0.315, 0.42, 0.525, 0.63, 0.735, 0.84, 0.945, 1.05, 1.155, 1.26, 1.365, 1.47, 1.575, 1.68, 1.785, 1.89, 1.995, 2.1];
                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Norm_Hist = [1, 0.45299, 0.29255, 0.096947, 0.056777, 0.02906, 0.015873, 0.010745, 0.0070818, 0.004884, 0.003663, 0.0026862, 0.0020757, 0.0017094, 0.0017094, 0.0019536, 0.0015873, 0.0013431, 0.0014652, 0.001221, 0.002442];
                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Scalar=1.5;

            end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Example Spontaneous with Evoked Fitting Parameters
            q=q+1;Default_QuaSOR_Parameters(q).ParameterSet_Name='Example Spontaneous with Evoked Fitting Parameters';
            for b=1:1

                %Region settings
                Default_QuaSOR_Parameters(q).Region.FixedROISize=0;
                Default_QuaSOR_Parameters(q).Region.RegionSize_um2=0;
                Default_QuaSOR_Parameters(q).Region.RegionSplitting_Threshold=0.05; %Apply a stricter threshold to the initial region finding CorrAmp map to get more smaller regions, will need to adjust for different inputs/amplitudes
                Default_QuaSOR_Parameters(q).Region.RegionSplitting_Threshold_Increase=0.05;
                Default_QuaSOR_Parameters(q).Region.Max_Region_Area_um2=25; %will split by increasing the starting threshold value
                Default_QuaSOR_Parameters(q).Region.Min_Region_Area_um2=0.6;
                Default_QuaSOR_Parameters(q).Region.RegionEdge_Padding_um=0.4; %to increase the size of the
                Default_QuaSOR_Parameters(q).Region.SuppressBorder=1; %Can avoid any matches too close to the border, shouldnt be a problem anymore but probably safer
                Default_QuaSOR_Parameters(q).Region.SuppressBorderSize_um=0.4;
                Default_QuaSOR_Parameters(q).Region.SuppressBorderRatio=0.8;%how much to suppress edge pixel values

                %Replicate/components handling
                Default_QuaSOR_Parameters(q).Components.NumReplicates=20;%Initial number of complete runs through progressing numbers of components
                Default_QuaSOR_Parameters(q).Components.MaxNumGaussians=6;%Initial number of components to test per window can set differently for different inputs
                Default_QuaSOR_Parameters(q).Components.ReplicateIncrease=10; %The number of test fits will increase as the number of components increases
                Default_QuaSOR_Parameters(q).Components.MaxAllowed_NumReplicates=200;%To prevent too many tests
                Default_QuaSOR_Parameters(q).Components.MaxAllowed_NumGaussians=4;%to prevent too many fits.  with very large regions this would need to be increased
                Default_QuaSOR_Parameters(q).Components.MaxAllowed_NumResets=1;%if no good fits are found it will restart after adjusting parameters
                Default_QuaSOR_Parameters(q).Components.Repeat_Amp_Threshold=0.1;
                Default_QuaSOR_Parameters(q).Components.RunInParallelMode=2;%new method is very different, currently the non-parallel mode is not a default option

                %GMM Settings
                Default_QuaSOR_Parameters(q).GMM.Check_Prior_Frame_Fit=0;%This option will allow the script to check for conditions that would allow the frame prior to the peak frame to be used for fitting, probably most useful in Is where spots spread rapidly
                Default_QuaSOR_Parameters(q).GMM.Check_Prior_Frame_Limits=[0.3,0.8];%Will trigger an alternative image if the frame before the TemplatePeakPosition is within this range.
                Default_QuaSOR_Parameters(q).GMM.FitFiltered=0;%uses filtered data for the primary analysis, I would rather not have to use this but it seems to work better and less errors
                Default_QuaSOR_Parameters(q).GMM.TestFiltered=0;%use a filtered test image for the 2d correlation testing procedure to avoid noise triggering more fits
                Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSize_um=5;%Filter the TestImage, gaussian, might be bad prior to gaussian fitting, data was intially gaussian filtered once
                Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSigma_um=1;
                Default_QuaSOR_Parameters(q).GMM.MinDistance_um=1.4;%helps avoid double matches right on top of one another but might be good
                Default_QuaSOR_Parameters(q).GMM.PenalizeMoreComponents=1;%Will try to supress fits that have more components
                Default_QuaSOR_Parameters(q).GMM.NumCompPenalty=-0.3;%-0.15;%how much to scale the 
                Default_QuaSOR_Parameters(q).GMM.ProbabilityTolerance=1e-9;%not used right now
                Default_QuaSOR_Parameters(q).GMM.InternalReplicates=1;%how many replicates each fitgmdist call runs, it will pick the best fit from each run with the largest liklihood
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions=statset;
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions.Display='off';
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions.MaxIter=10;%To get different options keep this low
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions.TolFun=1e-6;%not sure but not used yet
                Default_QuaSOR_Parameters(q).GMM.StartCondition='randSample';%eventually I would like to guide fitting here
                Default_QuaSOR_Parameters(q).GMM.RegularizationValue=1e-6;%will keep the function converging and not going off to infinity
                Default_QuaSOR_Parameters(q).GMM.Minimum_Peak_Amplitude=0.15;%0.035;
                Default_QuaSOR_Parameters(q).GMM.Minimum_Peak_Amplitude_EpisodeDelta=-0.0025;
                Default_QuaSOR_Parameters(q).GMM.Corr_Score_Scalar=3;

                %Mini-based Weighting Settings
                % SynapGCaMP6 Minis Ib Boutons
                % Amp Mean: 0.44989 STD: 0.37106
                % Variance Mean: 7.8505 STD: 3.5213
                % Variance Diff Mean: 2.3381 STD: 2.2767
                % Covariance Mean: -0.1273 STD: 1.7553
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Hist_XData = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3];
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Norm_Hist = [0.7185, 1, 0.92279, 0.87882, 0.71153, 0.55818, 0.42145, 0.31957, 0.24665, 0.18874, 0.14263, 0.10509, 0.078284, 0.057373, 0.046113, 0.034853, 0.026273, 0.021984, 0.017694, 0.012869, 0.010724, 0.0085791, 0.0053619, 0.0037534, 0.0037534, 0.002681, 0.0016086, 0.0010724, 0.0010724, 0, 0];
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Scalar=0.5;%1;

                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Hist_XData_um = [0, 0.210, 0.420, 0.630, 0.840, 1.05, 1.26, 1.47, 1.68, 1.89, 2.10, 2.31, 2.52, 2.73, 2.94, 3.15, 3.36, 3.57, 3.78, 3.99, 4.20, 4.41, 4.62, 4.83, 5.04, 5.25, 5.46, 5.67, 5.88, 6.09, 6.30];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Norm_Hist = [0, 0.029842, 0.25878, 0.45304, 0.67365, 0.89054, 0.98885, 1, 0.91757, 0.78209, 0.62872, 0.47601, 0.35709, 0.26385, 0.20101, 0.13682, 0.1, 0.069595, 0.056081, 0.036149, 0.020608, 0.016216, 0.0125, 0.0084459, 0.0054054, 0.0043919, 0.0030405, 0.0016892, 0.0010135, 0.0016892, 0.0016892];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Scalar=2;%1;

                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Hist_XData_um = [0, 0.210, 0.420, 0.630, 0.840, 1.05, 1.26, 1.47, 1.68, 1.89, 2.10, 2.31, 2.52, 2.73, 2.94, 3.15, 3.36, 3.57, 3.78, 3.99, 4.20];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Norm_Hist = [0.75183, 1, 0.80085, 0.69951, 0.46024, 0.29159, 0.17927, 0.10427, 0.058537, 0.038049, 0.023049, 0.016463, 0.012439, 0.01061, 0.0065854, 0.0047561, 0.0032927, 0.002561, 0.0014634, 0.0018293, 0.0018293];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Scalar=2;

                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Hist_XData_um = [0, 0.105, 0.21, 0.315, 0.42, 0.525, 0.63, 0.735, 0.84, 0.945, 1.05, 1.155, 1.26, 1.365, 1.47, 1.575, 1.68, 1.785, 1.89, 1.995, 2.1];
                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Norm_Hist = [1, 0.45299, 0.29255, 0.096947, 0.056777, 0.02906, 0.015873, 0.010745, 0.0070818, 0.004884, 0.003663, 0.0026862, 0.0020757, 0.0017094, 0.0017094, 0.0019536, 0.0015873, 0.0013431, 0.0014652, 0.001221, 0.002442];
                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Scalar=1.5;

            end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %WT Ib 5Hz parameter set (NOTE this is from the Cpx spontaneous set)
            q=q+1;Default_QuaSOR_Parameters(q).ParameterSet_Name='Example 5Hz Fitting Parameters';
            for b=1:1
                %Region settings
                Default_QuaSOR_Parameters(q).Region.FixedROISize=0;
                Default_QuaSOR_Parameters(q).Region.RegionSize_um2=0;
                Default_QuaSOR_Parameters(q).Region.RegionSplitting_Threshold=0.05; %Apply a stricter threshold to the initial region finding CorrAmp map to get more smaller regions, will need to adjust for different inputs/amplitudes
                Default_QuaSOR_Parameters(q).Region.RegionSplitting_Threshold_Increase=0.05;
                Default_QuaSOR_Parameters(q).Region.Max_Region_Area_um2=35; %will split by increasing the starting threshold value
                Default_QuaSOR_Parameters(q).Region.Min_Region_Area_um2=0.6;
                Default_QuaSOR_Parameters(q).Region.RegionEdge_Padding_um=0.4; %to increase the size of the
                Default_QuaSOR_Parameters(q).Region.SuppressBorder=1; %Can avoid any matches too close to the border, shouldnt be a problem anymore but probably safer
                Default_QuaSOR_Parameters(q).Region.SuppressBorderSize_um=0.4;
                Default_QuaSOR_Parameters(q).Region.SuppressBorderRatio=0.8;%how much to suppress edge pixel values

                %Replicate/components handling
                Default_QuaSOR_Parameters(q).Components.NumReplicates=20;%Initial number of complete runs through progressing numbers of components
                Default_QuaSOR_Parameters(q).Components.MaxNumGaussians=6;%Initial number of components to test per window can set differently for different inputs
                Default_QuaSOR_Parameters(q).Components.ReplicateIncrease=10; %The number of test fits will increase as the number of components increases
                Default_QuaSOR_Parameters(q).Components.MaxAllowed_NumReplicates=200;%To prevent too many tests
                Default_QuaSOR_Parameters(q).Components.MaxAllowed_NumGaussians=4;%to prevent too many fits.  with very large regions this would need to be increased
                Default_QuaSOR_Parameters(q).Components.MaxAllowed_NumResets=1;%if no good fits are found it will restart after adjusting parameters
                Default_QuaSOR_Parameters(q).Components.Repeat_Amp_Threshold=0.1;
                Default_QuaSOR_Parameters(q).Components.RunInParallelMode=2;%new method is very different, currently the non-parallel mode is not a default option

                %GMM Settings
                Default_QuaSOR_Parameters(q).GMM.Check_Prior_Frame_Fit=0;%This option will allow the script to check for conditions that would allow the frame prior to the peak frame to be used for fitting, probably most useful in Is where spots spread rapidly
                Default_QuaSOR_Parameters(q).GMM.Check_Prior_Frame_Limits=[0.3,0.8];%Will trigger an alternative image if the frame before the TemplatePeakPosition is within this range.
                Default_QuaSOR_Parameters(q).GMM.FitFiltered=0;%uses filtered data for the primary analysis, I would rather not have to use this but it seems to work better and less errors
                Default_QuaSOR_Parameters(q).GMM.TestFiltered=0;%use a filtered test image for the 2d correlation testing procedure to avoid noise triggering more fits
                Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSize_um=5;%Filter the TestImage, gaussian, might be bad prior to gaussian fitting, data was intially gaussian filtered once
                Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSigma_um=1;
                Default_QuaSOR_Parameters(q).GMM.MinDistance_um=1;%helps avoid double matches right on top of one another but might be good
                Default_QuaSOR_Parameters(q).GMM.PenalizeMoreComponents=1;%Will try to supress fits that have more components
                Default_QuaSOR_Parameters(q).GMM.NumCompPenalty=-0.3;%how much to scale the 
                Default_QuaSOR_Parameters(q).GMM.ProbabilityTolerance=1e-9;%not used right now
                Default_QuaSOR_Parameters(q).GMM.InternalReplicates=1;%how many replicates each fitgmdist call runs, it will pick the best fit from each run with the largest liklihood
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions=statset;
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions.Display='off';
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions.MaxIter=10;%To get different options keep this low
                Default_QuaSOR_Parameters(q).GMM.GMDistFitOptions.TolFun=1e-6;%not sure but not used yet
                Default_QuaSOR_Parameters(q).GMM.StartCondition='randSample';%eventually I would like to guide fitting here
                Default_QuaSOR_Parameters(q).GMM.RegularizationValue=1e-6;%will keep the function converging and not going off to infinity
                Default_QuaSOR_Parameters(q).GMM.Minimum_Peak_Amplitude=0.1;
                Default_QuaSOR_Parameters(q).GMM.Minimum_Peak_Amplitude_EpisodeDelta=-0.0025;
                Default_QuaSOR_Parameters(q).GMM.Corr_Score_Scalar=3;

                %Mini-based Weighting Settings
                % SynapGCaMP6 Minis Ib Boutons
                % Amp Mean: 0.44989 STD: 0.37106
                % Variance Mean: 7.8505 STD: 3.5213
                % Variance Diff Mean: 2.3381 STD: 2.2767
                % Covariance Mean: -0.1273 STD: 1.7553
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Hist_XData = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3];
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Norm_Hist = [0.7185, 1, 0.92279, 0.87882, 0.71153, 0.55818, 0.42145, 0.31957, 0.24665, 0.18874, 0.14263, 0.10509, 0.078284, 0.057373, 0.046113, 0.034853, 0.026273, 0.021984, 0.017694, 0.012869, 0.010724, 0.0085791, 0.0053619, 0.0037534, 0.0037534, 0.002681, 0.0016086, 0.0010724, 0.0010724, 0, 0];
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Amp_Score.Scalar=1;

                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Hist_XData_um = [0, 0.210, 0.420, 0.630, 0.840, 1.05, 1.26, 1.47, 1.68, 1.89, 2.10, 2.31, 2.52, 2.73, 2.94, 3.15, 3.36, 3.57, 3.78, 3.99, 4.20, 4.41, 4.62, 4.83, 5.04, 5.25, 5.46, 5.67, 5.88, 6.09, 6.30];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Norm_Hist = [0, 0.029842, 0.25878, 0.45304, 0.67365, 0.89054, 0.98885, 1, 0.91757, 0.78209, 0.62872, 0.47601, 0.35709, 0.26385, 0.20101, 0.13682, 0.1, 0.069595, 0.056081, 0.036149, 0.020608, 0.016216, 0.0125, 0.0084459, 0.0054054, 0.0043919, 0.0030405, 0.0016892, 0.0010135, 0.0016892, 0.0016892];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Scalar=1;

                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Hist_XData_um = [0, 0.210, 0.420, 0.630, 0.840, 1.05, 1.26, 1.47, 1.68, 1.89, 2.10, 2.31, 2.52, 2.73, 2.94, 3.15, 3.36, 3.57, 3.78, 3.99, 4.20];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Norm_Hist = [0.75183, 1, 0.80085, 0.69951, 0.46024, 0.29159, 0.17927, 0.10427, 0.058537, 0.038049, 0.023049, 0.016463, 0.012439, 0.01061, 0.0065854, 0.0047561, 0.0032927, 0.002561, 0.0014634, 0.0018293, 0.0018293];
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Scalar=2;

                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Hist_XData_um = [0, 0.105, 0.21, 0.315, 0.42, 0.525, 0.63, 0.735, 0.84, 0.945, 1.05, 1.155, 1.26, 1.365, 1.47, 1.575, 1.68, 1.785, 1.89, 1.995, 2.1];
                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Norm_Hist = [1, 0.45299, 0.29255, 0.096947, 0.056777, 0.02906, 0.015873, 0.010745, 0.0070818, 0.004884, 0.003663, 0.0026862, 0.0020757, 0.0017094, 0.0017094, 0.0019536, 0.0015873, 0.0013431, 0.0014652, 0.001221, 0.002442];
                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Shift=0;
                Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Scalar=1.5;
            end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear Default_QuaSOR_Parameter_List
    for q=1:length(Default_QuaSOR_Parameters)
        Default_QuaSOR_Parameters(q).Region.RegionSize_px=...
            ceil(Default_QuaSOR_Parameters(q).Region.RegionSize_um2/...
            (ImagingInfo.PixelSize^2));
        Default_QuaSOR_Parameters(q).Region.RegionEdge_Padding=...
            ceil(Default_QuaSOR_Parameters(q).Region.RegionEdge_Padding_um/...
            ImagingInfo.PixelSize);
        Default_QuaSOR_Parameters(q).Region.SuppressBorderSize=...
            ceil(Default_QuaSOR_Parameters(q).Region.SuppressBorderSize_um/...
            ImagingInfo.PixelSize);
        Default_QuaSOR_Parameters(q).Region.Max_Region_Area_px2=...
            ceil(Default_QuaSOR_Parameters(q).Region.Max_Region_Area_um2/...
            (ImagingInfo.PixelSize^2));
        Default_QuaSOR_Parameters(q).Region.Min_Region_Area_px2=...
            ceil(Default_QuaSOR_Parameters(q).Region.Min_Region_Area_um2/...
            (ImagingInfo.PixelSize^2));
        Default_QuaSOR_Parameters(q).GMM.MinDistance=...
            ceil(Default_QuaSOR_Parameters(q).GMM.MinDistance_um/...
            ImagingInfo.PixelSize);
        Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSize_px=...
            ceil(Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSize_um/...
            ImagingInfo.PixelSize);
        if rem(Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSize_px,2)==0
            Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSize_px=Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSize_px+1;
        end
        Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSigma_px=...
            Default_QuaSOR_Parameters(q).GMM.PreFit_FilterSigma_um/...
            ImagingInfo.PixelSize;
        Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Hist_XData=...
            ceil(Default_QuaSOR_Parameters(q).Dist_Weights.Var_Score.Hist_XData_um/...
            ImagingInfo.PixelSize);
        Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Hist_XData=...
            ceil(Default_QuaSOR_Parameters(q).Dist_Weights.Var_Diff_Score.Hist_XData_um/...
            ImagingInfo.PixelSize);
        Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Hist_XData=...
            ceil(Default_QuaSOR_Parameters(q).Dist_Weights.Cov_Score.Hist_XData_um/...
            ImagingInfo.PixelSize);
        Default_QuaSOR_Parameter_List{q}=Default_QuaSOR_Parameters(q).ParameterSet_Name;
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
for zzzz=1:1%if ~exist('Default_QuaSOR_Map_Settings')
    Default_QuaSOR_Map_Settings.QuaSOR_UpScaleFactor=10;
    Default_QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas_um=[0.1 0.15];
    Default_QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_SizeBuffer_um=0.2;            %Only needed if autogenerating gaussian filter size
    Default_QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes=[];                %populate if you want to manually control filter size
    Default_QuaSOR_Map_Settings.ContrastEnhancements=[0.5];
    Default_QuaSOR_Map_Settings.QuaSOR_TemporalColorizations=[0 0];
    Default_QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex=1;
    Default_QuaSOR_Map_Settings.QuaSOR_Overlay_ContrastIndex=1;
    Default_QuaSOR_Map_Settings.QuaSOR_Overlay_Color='y';
    Default_QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_FilterIndex=1;
    Default_QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_ContrastIndices=[1,1];
    Default_QuaSOR_Map_Settings.Modality_Colors={'c','r'};
    Default_QuaSOR_Map_Settings.QuaSOR_BorderLine_Width=2;
    Default_QuaSOR_Map_Settings.QuaSOR_Color_Scalar=1000;
    Default_QuaSOR_Map_Settings.QuaSOR_PixelSizeScalar=1;
    Default_QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegionSize=15;
    Default_QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegionSize2=5;
    Default_QuaSOR_Map_Settings.QuaSOR_HighResBoutonErodeRegionSize=15;
    Default_QuaSOR_Map_Settings.SpotNormalization=true;
    Default_QuaSOR_Map_Settings.ExportColorMap='parula';
    Default_QuaSOR_Map_Settings.ExportBorderColor='w';
    Default_QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color=[0.3,0.3,0.3];
end
for zzzz=1:1%if ~exist('Default_PixelMax_Map_Settings')
    Default_PixelMax_Map_Settings.PixelMax_UpScaleFactor=1;
    Default_PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas_um=[0.2];
    Default_PixelMax_Map_Settings.PixelMax_Gaussian_Filter_SizeBuffer_um=0.6;            %Only needed if autogenerating gaussian filter size
    Default_PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes=[];                %populate if you want to manually control filter size
    Default_PixelMax_Map_Settings.ContrastEnhancements=[0.5];
    Default_PixelMax_Map_Settings.PixelMax_TemporalColorizations=[0];
    Default_PixelMax_Map_Settings.PixelMax_Overlay_FilterIndex=1;
    Default_PixelMax_Map_Settings.PixelMax_Overlay_ContrastIndex=1;
    Default_PixelMax_Map_Settings.PixelMax_Overlay_Color='b';
    Default_PixelMax_Map_Settings.PixelMax_BorderLine_Width=1;
    Default_PixelMax_Map_Settings.PixelMax_Color_Scalar=1000;
    Default_PixelMax_Map_Settings.PixelMax_PixelSizeScalar=2;
end
for zzzz=1:1%if ~exist('Default_QuaSOR_LowRes_Map_Settings')
    Default_QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_UpScaleFactor=1;
    Default_QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas_um=[0.2];
    Default_QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_SizeBuffer_um=0.6;            %Only needed if autogenerating gaussian filter size
    Default_QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes=[];                %populate if you want to manually control filter size
    Default_QuaSOR_LowRes_Map_Settings.ContrastEnhancements=[0.5];
    Default_QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_TemporalColorizations=[0];
    Default_QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Overlay_FilterIndex=1;
    Default_QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Overlay_ContrastIndex=1;
    Default_QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Overlay_Color='b';
    Default_QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_BorderLine_Width=1;
    Default_QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Color_Scalar=1000;
    Default_QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_PixelSizeScalar=2;
end
for zzzz=1:1%if ~exist('Default_QuaSOR_Auto_AZ_Settings')
    Default_QuaSOR_Auto_AZ_Settings.AutoMatch_AZ_Max_Dist_nm=800;
    Default_QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_um=0.300;
    Default_QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index=2;
    Default_QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_AZ_Distance_um=0.3;
    Default_QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_nm=350;
    Default_QuaSOR_Auto_AZ_Settings.AZ_Detect_Color='m';
    Default_QuaSOR_Auto_AZ_Settings.AZ_Map_Display_Contrast=0.2;
    Default_QuaSOR_Auto_AZ_Settings.Auto_Detect_Method=2;
    Default_QuaSOR_Auto_AZ_Settings.NumEventsRevertThresh=300;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Default_QuaSOR_Auto_AZ_Settings.Label='AllCoords';
    Default_QuaSOR_Auto_AZ_Settings.AZ_Detect_Adaptive_Threshold=1;
    Default_QuaSOR_Auto_AZ_Settings.AZ_Threshold=[];
    Default_QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_nm=Default_QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_nm;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Mod=1;
    Default_QuaSOR_Auto_AZ_Settings.Modality(Mod).Label=GlobalDefault_QuaSOR_Parameters.Modality(Mod).Label;
    Default_QuaSOR_Auto_AZ_Settings.Modality(Mod).AZ_Detect_Adaptive_Threshold=1;
    Default_QuaSOR_Auto_AZ_Settings.Modality(Mod).AZ_Threshold=[];
    Default_QuaSOR_Auto_AZ_Settings.Modality(Mod).Auto_AZ_Quant_ROI_Radius_nm=Default_QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_nm;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Mod=2;
    Default_QuaSOR_Auto_AZ_Settings.Modality(Mod).Label=GlobalDefault_QuaSOR_Parameters.Modality(Mod).Label;
    Default_QuaSOR_Auto_AZ_Settings.Modality(Mod).AZ_Detect_Adaptive_Threshold=0;
    Default_QuaSOR_Auto_AZ_Settings.Modality(Mod).AZ_Threshold=1;
    Default_QuaSOR_Auto_AZ_Settings.Modality(Mod).Auto_AZ_Quant_ROI_Radius_nm=Default_QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_nm;
end
for zzzz=1:1%if ~exist('Default_QuaSOR_Event_Extraction_Settings')
    if ImagingInfo.ImagingFrequency<=20
        Default_QuaSOR_Event_Extraction_Settings.PreTraceFrames=5;
        Default_QuaSOR_Event_Extraction_Settings.PostTraceFrames=10;
        Default_QuaSOR_Event_Extraction_Settings.PrePeakFrames=2;
        Default_QuaSOR_Event_Extraction_Settings.PostPeakFrames=3;
    else
        Default_QuaSOR_Event_Extraction_Settings.PreTraceFrames=10;
        Default_QuaSOR_Event_Extraction_Settings.PostTraceFrames=20;
        Default_QuaSOR_Event_Extraction_Settings.PrePeakFrames=4;
        Default_QuaSOR_Event_Extraction_Settings.PostPeakFrames=5;
    end
    Default_QuaSOR_Event_Extraction_Settings.RegionRadius_nm=350;
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
    %QuaSOR Setup
    if any(AnalysisParts==0)||AdjustONLY
        DefaultLoadLabel='QuaSOR Defaults';
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
        if ~exist('QuaSOR_Parameters')
            QuaSOR_Parameters=[];
        end
        if ~exist('QuaSOR_Map_Settings')
            QuaSOR_Map_Settings=[];
        end
        if ~exist('PixelMax_Map_Settings')
            PixelMax_Map_Settings=[];
        end
        if ~exist('QuaSOR_LowRes_Map_Settings')
            QuaSOR_LowRes_Map_Settings=[];
        end
        if ~exist('QuaSOR_Auto_AZ_Settings')
            QuaSOR_Auto_AZ_Settings=[];
        end
        if ~exist('QuaSOR_Event_Extraction_Settings')
            QuaSOR_Event_Extraction_Settings=[];
        end
        [   QuaSOR_Parameters,...
            QuaSOR_Map_Settings,....
            PixelMax_Map_Settings,...
            QuaSOR_LowRes_Map_Settings,...
            QuaSOR_Auto_AZ_Settings,...
            QuaSOR_Event_Extraction_Settings,...
            ScaleBar_Upscale]=...
            Multi_Modality_QuaSOR_Setup(myPool,OS,dc,SaveName,StackSaveName,...
            ScratchDir,CurrentScratchDir,ImagingInfo,ScaleBar,SplitEpisodeFiles,AllBoutonsRegion,...
            QuaSOR_Parameters,...
            QuaSOR_Map_Settings,...
            PixelMax_Map_Settings,...
            QuaSOR_LowRes_Map_Settings,...
            QuaSOR_Auto_AZ_Settings,...
            QuaSOR_Event_Extraction_Settings,...
            Default_QuaSOR_Parameter_List,...
            GlobalDefault_QuaSOR_Parameters,...
            Default_QuaSOR_Parameters,...
            Default_PixelMax_Map_Settings,...
            Default_QuaSOR_LowRes_Map_Settings,...
            Default_QuaSOR_Map_Settings,...
            Default_QuaSOR_Auto_AZ_Settings,...
            Default_QuaSOR_Event_Extraction_Settings);

    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix='_QuaSOR_Data.mat';
        fprintf(['Loading: ',FileSuffix,'...'])
        load([CurrentScratchDir,StackSaveName,FileSuffix],'QuaSOR_Parameters','QuaSOR_Event_Extraction_Settings','ScaleBar_Upscale')
        fprintf('Finished!\n')
        %%%%%%%
        FileSuffix='_QuaSOR_Maps.mat';
        fprintf(['Loading: ',FileSuffix,'...'])
        load([CurrentScratchDir,dc,StackSaveName,FileSuffix],'QuaSOR_Map_Settings','PixelMax_Map_Settings')
        fprintf('Finished!\n')
        %%%%%%%
        FileSuffix='_QuaSOR_AZs.mat';
        fprintf(['Loading: ',FileSuffix,'...'])
        load([CurrentScratchDir,dc,StackSaveName,FileSuffix],'QuaSOR_Auto_AZ_Settings')
        fprintf('Finished!\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 1
    %QuaSOR Fitting
    if any(AnalysisParts==1)&&~AdjustONLY
        TrackerDir=[LoadDir,dc,'Trackers',dc];
        close all
        [QuaSOR_Fitting_Struct,QuaSOR_Data,QuaSOR_Parameters,AllBoutonsRegion_Upscale,ScaleBar_Upscale,BorderLine_Upscale,AbortStatus]=...
            Multi_Modality_QuaSOR(myPool,OS,dc,SaveName,StackSaveName,SaveDir,...
            ScratchDir,CurrentScratchDir,ImagingInfo,QuaSOR_Parameters,QuaSOR_Event_Extraction_Settings,...
            SplitEpisodeFiles,AllBoutonsRegion,ScaleBar,ScaleBar_Upscale,MarkerSetInfo,Image_Width,Image_Height,AbortButton,TrackerDir,Safe2CopyDelete);

    elseif any(AnalysisParts>0)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix='_QuaSOR_Data.mat';
        fprintf(['Loading: ',FileSuffix,'...'])
        load([CurrentScratchDir,StackSaveName,FileSuffix])
        fprintf('Finished\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 2
    %QuaSOR Maps
    if any(AnalysisParts==2)&&~AdjustONLY
        GPU_Memory_Miniumum=5e9;
        GPU_Accelerate=0;
        RemoveDuplicates=0;
        DisplayIntermediates=0;
        ExportImages=1;
        CleanupMapRGB=1;
        IbIs_CoordinateAdjust=0;
        IbIs=0;
        if ~exist('BoutonMerge')
            BoutonMerge=[];
        end

        [QuaSOR_Maps,QuaSOR_Map_Settings,PixelMax_Maps,PixelMax_Map_Settings]=...
            Multi_Modality_QuaSOR_Maps(myPool,OS,dc,SaveName,StackSaveName,SaveDir,CurrentScratchDir,FigureScratchDir,...
            QuaSOR_Map_Settings,QuaSOR_Data,QuaSOR_Parameters,QuaSOR_Event_Extraction_Settings,QuaSOR_LowRes_Map_Settings,...
            PixelMax_Map_Settings,PixelMax_Struct,...
            Image_Height,Image_Width,AllBoutonsRegion,BoutonArray,BorderLine,...
            ScaleBar,ScaleBar_Upscale,MarkerSetInfo,...
            GPU_Memory_Miniumum,GPU_Accelerate,RemoveDuplicates,...
            DisplayIntermediates,ExportImages,CleanupMapRGB,...
            IbIs_CoordinateAdjust,IbIs,BoutonMerge)

    elseif any(AnalysisParts>0)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix='_QuaSOR_Maps.mat';
        fprintf(['Loading: ',FileSuffix,'...'])
        load([CurrentScratchDir,StackSaveName,FileSuffix])
        fprintf('Finished\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 3
    %Auto AZ Detection and Exports
    if any(AnalysisParts==3)&&~AdjustONLY


        [QuaSOR_Auto_AZ,QuaSOR_Auto_AZ_Settings]=...
            Multi_Modality_QuaSOR_Auto_AZ(myPool,OS,dc,SaveName,StackSaveName,SaveDir,CurrentScratchDir,FigureScratchDir,...
            ImagingInfo,QuaSOR_Auto_AZ_Settings,QuaSOR_Map_Settings,QuaSOR_Event_Extraction_Settings,QuaSOR_Maps,QuaSOR_Data,QuaSOR_Parameters,...
            ScaleBar,ScaleBar_Upscale,MarkerSetInfo,Image_Width,Image_Height,Safe2CopyDelete);


    elseif any(AnalysisParts>0)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix='_QuaSOR_AZs.mat';
        fprintf(['Loading: ',FileSuffix,'...'])
        load([CurrentScratchDir,StackSaveName,FileSuffix])
        fprintf('Finished\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    %AnalysisPart 4
    %QuaSOR Evaluation Prep
    if any(AnalysisParts==4)&&~AdjustONLY
        run('Multi_Modality_QuaSOR_Evaluation_Setup.m')
    else


    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 5
    %Movies
    if any(AnalysisParts==5)&&~AdjustONLY
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('============================================================')
        FileSuffix='_DeltaFData.mat';
        if ~exist([SaveDir,StackSaveName,FileSuffix])
            error([StackSaveName,FileSuffix,' Missing!']);
        else
            if ~exist([CurrentScratchDir,StackSaveName,FileSuffix])
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
        end
        disp('============================================================')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~exist('SplitEpisodeFiles')
            SplitEpisodeFiles=0;
        end
        if SplitEpisodeFiles&&any(AnalysisParts>0)
            for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
                FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
                if ~exist([CurrentScratchDir,StackSaveName,FileSuffix])
                    fprintf(['Copying: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
                    [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
                    fprintf('Finished!\n')
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('============================================================')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        run('Quantal_Analysis_QuaSOR_Movie_Records.m')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %AnalysisPart 6
    %Evaluate Results
    if any(AnalysisParts==6)&&~AdjustONLY
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
                    run('Quantal_Analysis_QuaSOR_Evaluation.m')
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
    %AnalysisPart 7
    %Custom Maps
    if any(AnalysisParts==7)&&~AdjustONLY

        error('Remind Zach to Finish')
    
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(BatchMode)
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
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Copying Files to SaveDir...')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_QuaSOR_Data.mat';
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_QuaSOR_Maps.mat';
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_QuaSOR_AZs.mat';
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            if ~isempty(BatchMode)
                warning('Deleting CurrentScratchDir Version')
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
        Recording Client_Recording Server_Recording currentFolder File2Check AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions BatchMode AnalysisPartsChoiceOptions AnalysisPartOptions RecordingChoiceOptions Function RecordingNum RecordingNum1 RecordingNums LastRecording...
        LoopCount File2Check AnalysisLabel AnalysisLabelShort Function ErrorTolerant BrokeLoop AbortButton AdjustOnly BufferSize Port PortChoice PortOptions PortOptionsText TimeOut NumLoops ServerIP BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
        RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode AdjustOnly
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
