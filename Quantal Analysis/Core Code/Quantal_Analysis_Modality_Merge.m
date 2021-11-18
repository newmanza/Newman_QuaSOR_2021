%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
if ~isfield(Recording,'ModalitySuffixes')||~isfield(Recording,'IncludeSpont')||~isfield(Recording,'SplitHighFreqMod')
    warning('Recording structure now requires three new fields: ModalitySuffixes, IncludeSpont, SplitHighFreqMod')
    warning('ex: ModalitySuffixes={''_0.2Hz''}; for each Protocol to merge')
    warning('ex: IncludeSpont=[0]; (1/0) one value for each ModalitySuffix entry above')
    warning('USE if you want to include spont from evoked protocol')
    warning('ex: SplitHighFreqMod=1; (1/0) to activate defaults for multiple high freq protocols')
end
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
    ModalitySuffixes=Recording(RecordingNum).ModalitySuffixes;
else
    RecordingNum=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Directories
SaveDir2=[LoadDir,dc,AnalysisLabelShort,dc];
CurrentScratchDir2=[ScratchDir,StackSaveName,dc,AnalysisLabelShort,dc];
if ~exist(CurrentScratchDir2)
    mkdir(CurrentScratchDir2)
end
FigureSaveDir=[SaveDir2,'Figures',dc];
if ~exist(FigureSaveDir)
    mkdir(FigureSaveDir)
end
FigureScratchDir=[CurrentScratchDir2,'Figures',dc];
if ~exist(FigureScratchDir)
    mkdir(FigureScratchDir)
end
MoviesSaveDir=[SaveDir2,'Movies',dc];
if ~exist(MoviesSaveDir)
    mkdir(MoviesSaveDir)
end
MoviesScratchDir=[CurrentScratchDir2,'Movies',dc];
if ~exist(MoviesScratchDir)
    mkdir(MoviesScratchDir)
end

Safe2CopyDelete=1;
if strcmp([SaveDir2],[CurrentScratchDir2])||...
        strcmp([SaveDir2],[CurrentScratchDir2])||...
        strcmp([SaveDir2],[CurrentScratchDir2,dc])
    Safe2CopyDelete=0;
    warning('CurrentScratchDir and SaveDir are the same')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Load Data
disp('============================================================')
disp(['Prepping ',AnalysisLabel,' on File#',num2str(RecordingNum),' ',StackSaveName]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%Overall Parameters    
    ReferenceModality=1;
    PriorityCheckSigmaIndex=5;
    PriorityCheckContrast=0.2;
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
%Default Parameters Sets
clear Default_Modality
DefMod=0;
for zzzzz=1:1
    DefMod=DefMod+1;
    Default_Modality(DefMod).ModalityTypeLabel='Low Frequency AP Evoked';
    Default_Modality(DefMod).ID_Suffix={'_01Hz','_02Hz','_05Hz','_1Hz'};
    Default_Modality(DefMod).Labels={'0.1Hz Evoked','0.2Hz Evoked','0.5Hz Evoked','1Hz Evoked'};
    Default_Modality(DefMod).ShortLabel='LF Evoked';
    Default_Modality(DefMod).ModalityType=1;
    Default_Modality(DefMod).Color='c';
    Default_Modality(DefMod).GoodMatch=0;

    DefMod=DefMod+1;
    Default_Modality(DefMod).ModalityTypeLabel='Spontaneous';
    Default_Modality(DefMod).ShortLabel='Spont.';
    Default_Modality(DefMod).ID_Suffix={'_Mini'};
    Default_Modality(DefMod).Labels={'Spont'};
    Default_Modality(DefMod).ModalityType=2;
    Default_Modality(DefMod).GoodMatch=0;
    Default_Modality(DefMod).Color='r';
    
    if ~Recording(RecordingNum).SplitHighFreqMod

        DefMod=DefMod+1;
        Default_Modality(DefMod).ModalityTypeLabel='High Frequency AP Evoked';
        Default_Modality(DefMod).ID_Suffix={'_2Hz10s','_5Hz10s','_10Hz10s','_15Hz10s','_20Hz10s','_30Hz10s','_40Hz10s',...
                                            '_2Hz20s','_5Hz20s','_10Hz20s','_15Hz20s','_20Hz20s','_30Hz20s','_40Hz20s'};
        Default_Modality(DefMod).Labels={'2Hz 10s Evoked','5Hz 10s Evoked','10Hz 10s Evoked','15Hz 10s Evoked','20Hz 10s Evoked','30Hz 10s Evoked','40Hz 10s Evoked',...
                                         '2Hz 20s Evoked','5Hz 20s Evoked','10Hz 20s Evoked','15Hz 20s Evoked','20Hz 20s Evoked','30Hz 20s Evoked','40Hz 20s Evoked'};
        Default_Modality(DefMod).ShortLabel='HF Evoked';
        Default_Modality(DefMod).ModalityType=3;
        Default_Modality(DefMod).GoodMatch=0;
        Default_Modality(DefMod).Color='y';
    
    else
        error('You need to define the Default_Modality sets you want here')
    end

end
% DefaultLoadLabel='Modality Merge Defaults';
% if exist('LabDefaults')
%     if exist(LabDefaults)
%         run(LabDefaults)
%     end
% else
%     warning('<LabDefaults> Variable Doesnt Exist...')
% end
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
    %AnalysisPart 1
    %Modality Merging
    if any(AnalysisParts==1)&&~AdjustONLY
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        clear Modality_Merge Modality
        Modality_Merge=[];
        Modality=[];
        for EntryNum=1:length(ModalitySuffixes)
            disp(['============================================================================================================']);
            CurrentModalitySuffix=ModalitySuffixes{EntryNum};
            disp(['Importing: ',StackSaveName,CurrentModalitySuffix,' Bouton Merge Data...'])
            disp('============================================================')
            SaveDir1=[LoadDir,dc,CurrentModalitySuffix,dc];
            CurrentScratchDir1=[ScratchDir,StackSaveName,dc,CurrentModalitySuffix,dc];
            if ~exist(CurrentScratchDir1)
                mkdir(CurrentScratchDir1)
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            FileSuffix=[CurrentModalitySuffix,'_ImageSet_Analysis_Setup.mat'];
            fprintf(['Loading ',StackSaveName,FileSuffix,'...']);
            load([SaveDir1,StackSaveName,FileSuffix],...
                'LoadingInfo',...
                'MetaDataRecord',...
                'ImagingInfo',...
                'MarkerSetInfo')
            fprintf('Finished!\n')
            disp('============================================================')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            FileSuffix=[CurrentModalitySuffix,'_QuaSOR_Data.mat'];
            if ~exist([SaveDir1,StackSaveName,FileSuffix])
                error([StackSaveName,FileSuffix,' Missing!']);
            else
                if ~exist([CurrentScratchDir1,StackSaveName,FileSuffix])
                    FileInfo = dir([SaveDir1,StackSaveName,FileSuffix]);
                    TimeStamp = FileInfo.date;
                    CurrentDateNum=FileInfo.datenum;
                    disp([StackSaveName,FileSuffix,' Last updated: ',TimeStamp]);
                    if Safe2CopyDelete
                        fprintf(['Copying ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
                        [CopyStatus,CopyMessage]=copyfile([SaveDir1,StackSaveName,FileSuffix],CurrentScratchDir1);
                        if CopyStatus
                            fprintf('Copy successful!\n')
                        else
                            error(CopyMessage)
                        end               
                    end
                end
            end
            fprintf(['Loading ',StackSaveName,FileSuffix,'...']);
            load([CurrentScratchDir1,StackSaveName,FileSuffix],...
                'BoutonArray',...
                'BoutonMerge')
            fprintf('Finished!\n')
            disp('============================================================')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            Modality_Merge(EntryNum).LoadingInfo=LoadingInfo;
            clear LoadingInfo
            Modality_Merge(EntryNum).MetaDataRecord=MetaDataRecord;
            clear MetaDataRecord
            Modality_Merge(EntryNum).ImagingInfo=ImagingInfo;
            clear ImagingInfo
            Modality_Merge(EntryNum).MarkerSetInfo=MarkerSetInfo;
            clear MarkerSetInfo
            Modality_Merge(EntryNum).BoutonMerge=BoutonMerge;
            clear BoutonMerge
            Modality_Merge(EntryNum).BoutonArray=BoutonArray;
            clear BoutonArray
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('Matching with Default Modality...');
            Mod=[];
            IDCheck=[];
            for DefMod=1:length(Default_Modality)
                for ID=1:length(Default_Modality(DefMod).ID_Suffix)
                    if any(strcmp(Default_Modality(DefMod).ID_Suffix{ID},CurrentModalitySuffix))
                        fprintf(['Adding to Modality# ',num2str(DefMod),' ',Default_Modality(DefMod).ModalityTypeLabel,' type\n'])
                        Mod=[Mod,DefMod];
                        IDCheck=[IDCheck,ID];
                    end
                end
            end
            if length(Mod)>1
                warning('Multiple MODALITY matches using the first one for now...')
                Mod=Mod(1);
            end
            if length(IDCheck)>1
                warning('Multiple ID matches using the first one for now...')
                IDCheck=IDCheck(1);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('Adding Data into Modality...');
            if Mod~=0
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Check if new mod
                NewMod=1;
                if ~isempty(Modality)
                    if length(Modality)>=Mod
                        if ~isempty(Modality(Mod).GoodMatch)
                            NewMod=0;
                        end
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Assign Mod values if new entry
                if NewMod
                    Modality(Mod).Label=Default_Modality(Mod).Labels{IDCheck};
                    Modality(Mod).ID_Suffix=Default_Modality(Mod).ID_Suffix{IDCheck};
                    Modality(Mod).ShortLabel=Default_Modality(Mod).ShortLabel;
                    Modality(Mod).ModalityType=Default_Modality(Mod).ModalityType;
                    Modality(Mod).ModalityTypeLabel=Default_Modality(Mod).ModalityTypeLabel;
                    Modality(Mod).Color=Default_Modality(Mod).Color;
                    Modality(Mod).GoodMatch=1;
                    Modality(Mod).NumEvokedStimuli=0;
                    Modality(Mod).TotalSpontImagingTime=0;
                    Modality(Mod).Labels=Default_Modality(Mod).Labels;
                    Modality(Mod).Group_ID=StackSaveName;
                else
                    Modality(Mod).GoodMatch=Modality(Mod).GoodMatch+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Add Modality ID Info
                Modality(Mod).Recording(Modality(Mod).GoodMatch).Label=Default_Modality(Mod).Labels{IDCheck};
                Modality(Mod).Recording(Modality(Mod).GoodMatch).ID_Suffix=Default_Modality(Mod).ID_Suffix{IDCheck};
                Modality(Mod).Recording(Modality(Mod).GoodMatch).Group_ID=[Recording(RecordingNum).StackSaveName,Recording(RecordingNum).ModalitySuffixes{EntryNum}];
                Modality(Mod).Recording(Modality(Mod).GoodMatch).Group_ID_Suffix=Default_Modality(Mod).ID_Suffix{IDCheck};
                Modality(Mod).Recording(Modality(Mod).GoodMatch).StackSaveName_Ib=[Recording(RecordingNum).StackSaveName,...
                    Recording(RecordingNum).ModalitySuffixes{EntryNum},'_Ib'];
                Modality(Mod).Recording(Modality(Mod).GoodMatch).StackSaveName_Is=[Recording(RecordingNum).StackSaveName,...
                    Recording(RecordingNum).ModalitySuffixes{EntryNum},'_Is'];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Generate pooling vectors for coordinates
                if NewMod
                    Modality(Mod).NumEvokedStimuli=0;
                    Modality(Mod).TotalSpontImagingTime=0;
                    %%%%%%%%%
                    for BoutonCount=1:length(Modality_Merge(EntryNum).BoutonArray)
                        Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.EntryNum=[];
                        Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords=[];
                        Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum=[];
                        Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=[];
                        Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame=[];
                        Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim=[];
                        Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Max_DeltaFF0=[];
                    end
                    Modality(Mod).QuaSOR_Data.BoutonType=[];
                    Modality(Mod).QuaSOR_Data.EntryNum=[];
                    Modality(Mod).QuaSOR_Data.All_Location_Coords=[];
                    Modality(Mod).QuaSOR_Data.All_Location_Coords_byEpisodeNum=[];
                    Modality(Mod).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=[];
                    Modality(Mod).QuaSOR_Data.All_Location_Coords_byOverallFrame=[];
                    Modality(Mod).QuaSOR_Data.All_Location_Coords_byOverallStim=[];
                    Modality(Mod).QuaSOR_Data.All_Max_DeltaFF0=[];
                    %%%%%%%%%
                    for BoutonCount=1:length(Modality_Merge(EntryNum).BoutonArray)
                        Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.EntryNum=[];
                        Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum=[];
                        Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame=[];
                        Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim=[];
                    end
                    Modality(Mod).PixelMax_Struct.BoutonType=[];
                    Modality(Mod).PixelMax_Struct.EntryNum=[];
                    Modality(Mod).PixelMax_Struct.All_Location_Coords_byEpisodeNum=[];
                    Modality(Mod).PixelMax_Struct.All_Location_Coords_byOverallFrame=[];
                    Modality(Mod).PixelMax_Struct.All_Location_Coords_byOverallStim=[];
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Check for spont data in evoked datasets
                PrimarySubMod=0;
                AltMod=0;
                AltSubMod=0;
                NewAltMod=0;
                if Recording(RecordingNum).IncludeSpont(EntryNum)&&(Modality(Mod).ModalityType==1||Modality(Mod).ModalityType==3)
                    PrimarySubMod=1;
                    AltMod=2;
                    AltSubMod=2;
                    if length(Modality)>=AltMod
                        if isempty(Modality(AltMod).GoodMatch)
                            NewAltMod=1;
                        end
                    else
                        NewAltMod=1;
                    end
                elseif Modality(Mod).ModalityType==2
                    PrimarySubMod=2;
                    AltMod=0;
                    AltSubMod=0;
                elseif (Modality(Mod).ModalityType==1||Modality(Mod).ModalityType==3)
                    PrimarySubMod=1;
                    AltMod=0;
                    AltSubMod=0;
                else
                    error('Problem here')
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Assign AltMod values if new entry
                if NewAltMod&&AltMod
                    Modality(AltMod).Label='Spont';
                    Modality(Mod).ID_Suffix=Default_Modality(Mod).ID_Suffix{IDCheck};
                    Modality(AltMod).ShortLabel=Default_Modality(AltMod).ShortLabel;
                    Modality(AltMod).ModalityType=Default_Modality(AltMod).ModalityType;
                    Modality(AltMod).ModalityTypeLabel=Default_Modality(AltMod).ModalityTypeLabel;
                    Modality(AltMod).Color=Default_Modality(AltMod).Color;
                    Modality(AltMod).GoodMatch=1;
                    Modality(AltMod).NumEvokedStimuli=0;
                    Modality(AltMod).TotalSpontImagingTime=0;
                    Modality(AltMod).Labels=Default_Modality(AltMod).Labels;
                    Modality(AltMod).Group_ID=StackSaveName;
                elseif AltMod
                    Modality(AltMod).GoodMatch=Modality(AltMod).GoodMatch+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Add AltMod ID Info
                if AltMod
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).Label=[Default_Modality(Mod).Labels{IDCheck},' ',Modality(AltMod).ShortLabel,' DATA'];
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).ID_Suffix=[Default_Modality(Mod).ID_Suffix{IDCheck}];
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).Group_ID=[Recording(RecordingNum).StackSaveName,Recording(RecordingNum).ModalitySuffixes{EntryNum}];
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).Group_ID_Suffix=Modality(AltMod).Recording(Modality(AltMod).GoodMatch).ID_Suffix;
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).StackSaveName_Ib=[Recording(RecordingNum).StackSaveName,...
                        Recording(RecordingNum).ModalitySuffixes{EntryNum},'_Ib'];
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).StackSaveName_Ib=[Recording(RecordingNum).StackSaveName,...
                        Recording(RecordingNum).ModalitySuffixes{EntryNum},'_Is'];
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %If evoked add to spont also if possible
                if NewAltMod&&AltMod
                    Modality(AltMod).NumEvokedStimuli=0;
                    Modality(AltMod).TotalSpontImagingTime=0;
                    %%%%%%%%%
                    for BoutonCount=1:length(Modality_Merge(EntryNum).BoutonArray)
                        Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.EntryNum=[];
                        Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords=[];
                        Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum=[];
                        Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=[];
                        Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame=[];
                        Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim=[];
                        Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Max_DeltaFF0=[];
                    end
                    Modality(AltMod).QuaSOR_Data.BoutonType=[];
                    Modality(AltMod).QuaSOR_Data.EntryNum=[];
                    Modality(AltMod).QuaSOR_Data.All_Location_Coords=[];
                    Modality(AltMod).QuaSOR_Data.All_Location_Coords_byEpisodeNum=[];
                    Modality(AltMod).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=[];
                    Modality(AltMod).QuaSOR_Data.All_Location_Coords_byOverallFrame=[];
                    Modality(AltMod).QuaSOR_Data.All_Location_Coords_byOverallStim=[];
                    Modality(AltMod).QuaSOR_Data.All_Max_DeltaFF0=[];
                    %%%%%%%%%
                    for BoutonCount=1:length(Modality_Merge(EntryNum).BoutonArray)
                        Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.EntryNum=[];
                        Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum=[];
                        Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame=[];
                        Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim=[];
                    end
                    Modality(AltMod).PixelMax_Struct.BoutonType=[];
                    Modality(AltMod).PixelMax_Struct.EntryNum=[];
                    Modality(AltMod).PixelMax_Struct.All_Location_Coords_byEpisodeNum=[];
                    Modality(AltMod).PixelMax_Struct.All_Location_Coords_byOverallFrame=[];
                    Modality(AltMod).PixelMax_Struct.All_Location_Coords_byOverallStim=[];
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Calculate Recordinga and total Imaging Time and Num Stimuli
                if Modality(Mod).ModalityType==1||Modality(Mod).ModalityType==3
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).NumEvokedStimuli=...
                        Modality_Merge(EntryNum).ImagingInfo.NumEpisodes*Modality_Merge(EntryNum).ImagingInfo.StimuliPerEpisode;
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).TotalSpontImagingTime=0;
                    if AltMod
                        Modality(AltMod).Recording(Modality(AltMod).GoodMatch).NumEvokedStimuli=0;
                        Modality(AltMod).Recording(Modality(AltMod).GoodMatch).TotalSpontImagingTime=...
                            ((Modality_Merge(EntryNum).ImagingInfo.NumEpisodes*...
                            (Modality_Merge(EntryNum).ImagingInfo.FramesPerEpisode-...
                            Modality_Merge(EntryNum).ImagingInfo.FramesPerStimulus*...
                            Modality_Merge(EntryNum).ImagingInfo.StimuliPerEpisode)))*...
                            (1/Modality_Merge(EntryNum).ImagingInfo.ImagingFrequency);
                    end
                elseif Modality(Mod).ModalityType==2
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).NumEvokedStimuli=0;
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).TotalSpontImagingTime=...
                        Modality_Merge(EntryNum).ImagingInfo.NumEpisodes*...
                        Modality_Merge(EntryNum).ImagingInfo.FramesPerEpisode*...
                        (1/Modality_Merge(EntryNum).ImagingInfo.ImagingFrequency);
                end
                Modality(Mod).NumEvokedStimuli=Modality(Mod).NumEvokedStimuli+Modality(Mod).Recording(Modality(Mod).GoodMatch).NumEvokedStimuli;
                Modality(Mod).TotalSpontImagingTime=Modality(Mod).TotalSpontImagingTime+Modality(Mod).Recording(Modality(Mod).GoodMatch).TotalSpontImagingTime;
                if AltMod
                    Modality(AltMod).NumEvokedStimuli=Modality(AltMod).NumEvokedStimuli+Modality(AltMod).Recording(Modality(AltMod).GoodMatch).NumEvokedStimuli;
                    Modality(AltMod).TotalSpontImagingTime=Modality(AltMod).TotalSpontImagingTime+Modality(AltMod).Recording(Modality(AltMod).GoodMatch).TotalSpontImagingTime;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Pull recording specific QuaSOR Coords from PrimaryMod
                for zzz=1:1
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.BoutonType=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(PrimarySubMod).BoutonType;
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Location_Coords=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(PrimarySubMod).All_Location_Coords;
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Location_Coords_byEpisodeNum=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(PrimarySubMod).All_Location_Coords_byEpisodeNum;
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(PrimarySubMod).All_Location_Coords_byEpisodeFrame;
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Location_Coords_byOverallFrame=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(PrimarySubMod).All_Location_Coords_byOverallFrame;
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Location_Coords_byOverallStim=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(PrimarySubMod).All_Location_Coords_byOverallStim;
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Max_DeltaFF0=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(PrimarySubMod).All_Max_DeltaFF0;
                    for BoutonCount=1:length(Modality_Merge(EntryNum).BoutonArray)
                        Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords=...
                            Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(PrimarySubMod).All_Location_Coords;
                        Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum=...
                            Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(PrimarySubMod).All_Location_Coords_byEpisodeNum;
                        Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=...
                            Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(PrimarySubMod).All_Location_Coords_byEpisodeFrame;
                        Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame=...
                            Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(PrimarySubMod).All_Location_Coords_byOverallFrame;
                        Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim=...
                            Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(PrimarySubMod).All_Location_Coords_byOverallStim;
                        Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Max_DeltaFF0=...
                            Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(PrimarySubMod).All_Max_DeltaFF0;
                    end
                    %%%%%%%%%
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).PixelMax_Struct.BoutonType=...
                        Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(PrimarySubMod).BoutonType;
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).PixelMax_Struct.All_Location_Coords_byEpisodeNum=...
                        Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(PrimarySubMod).All_Location_Coords_byEpisodeNum;
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallFrame=...
                        Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(PrimarySubMod).All_Location_Coords_byOverallFrame;
                    Modality(Mod).Recording(Modality(Mod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallStim=...
                        Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(PrimarySubMod).All_Location_Coords_byOverallStim;
                    for BoutonCount=1:length(Modality_Merge(EntryNum).BoutonArray)
                        Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum=...
                            Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(PrimarySubMod).All_Location_Coords_byEpisodeNum;
                        Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame=...
                            Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(PrimarySubMod).All_Location_Coords_byOverallFrame;
                        Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim=...
                            Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(PrimarySubMod).All_Location_Coords_byOverallStim;
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Pull recording specific Spont QuaSOR Coords from Evoked
                %Protocols
                if AltMod
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.BoutonType=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(AltSubMod).BoutonType;
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Location_Coords=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(AltSubMod).All_Location_Coords;
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Location_Coords_byEpisodeNum=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(AltSubMod).All_Location_Coords_byEpisodeNum;
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(AltSubMod).All_Location_Coords_byEpisodeFrame;
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Location_Coords_byOverallFrame=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(AltSubMod).All_Location_Coords_byOverallFrame;
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Location_Coords_byOverallStim=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(AltSubMod).All_Location_Coords_byOverallStim;
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Max_DeltaFF0=...
                        Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(AltSubMod).All_Max_DeltaFF0;
                    for BoutonCount=1:length(Modality_Merge(EntryNum).BoutonArray)
                        Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords=...
                            Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(AltSubMod).All_Location_Coords;
                        Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum=...
                            Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(AltSubMod).All_Location_Coords_byEpisodeNum;
                        Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=...
                            Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(AltSubMod).All_Location_Coords_byEpisodeFrame;
                        Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame=...
                            Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(AltSubMod).All_Location_Coords_byOverallFrame;
                        Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim=...
                            Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(AltSubMod).All_Location_Coords_byOverallStim;
                        Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Max_DeltaFF0=...
                            Modality_Merge(EntryNum).BoutonMerge.QuaSOR_Data.Modality(AltSubMod).All_Max_DeltaFF0;
                    end
                    %%%%%%%%%
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).PixelMax_Struct.BoutonType=...
                        Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(AltSubMod).BoutonType;
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).PixelMax_Struct.All_Location_Coords_byEpisodeNum=...
                        Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(AltSubMod).All_Location_Coords_byEpisodeNum;
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallFrame=...
                        Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(AltSubMod).All_Location_Coords_byOverallFrame;
                    Modality(AltMod).Recording(Modality(AltMod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallStim=...
                        Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(AltSubMod).All_Location_Coords_byOverallStim;
                    for BoutonCount=1:length(Modality_Merge(EntryNum).BoutonArray)
                        Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum=...
                            Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(AltSubMod).All_Location_Coords_byEpisodeNum;
                        Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame=...
                            Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(AltSubMod).All_Location_Coords_byOverallFrame;
                        Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim=...
                            Modality_Merge(EntryNum).BoutonMerge.PixelMax_Struct.Modality(AltSubMod).All_Location_Coords_byOverallStim;
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Concatenate data for PrimarySubMod
                for zzz=1:1
                    if ~isempty(Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Location_Coords)
                        %BoutonTypes=ones(size(Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Location_Coords,1),1)*BoutonCount;
                        EntryNums=ones(size(Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Location_Coords,1),1)*EntryNum;
                    else
                        %BoutonTypes=[];
                        EntryNums=[];
                    end
                    %Modality(Mod).QuaSOR_Data.BoutonType=vertcat(Modality(Mod).QuaSOR_Data.BoutonType,BoutonTypes);
                    Modality(Mod).QuaSOR_Data.EntryNum=vertcat(Modality(Mod).QuaSOR_Data.EntryNum,EntryNums);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).QuaSOR_Data.BoutonType=vertcat(Modality(Mod).QuaSOR_Data.BoutonType,Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.BoutonType);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).QuaSOR_Data.All_Location_Coords=vertcat(Modality(Mod).QuaSOR_Data.All_Location_Coords,Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Location_Coords);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).QuaSOR_Data.All_Location_Coords_byEpisodeNum=vertcat(Modality(Mod).QuaSOR_Data.All_Location_Coords_byEpisodeNum,Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Location_Coords_byEpisodeNum);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=vertcat(Modality(Mod).QuaSOR_Data.All_Location_Coords_byEpisodeFrame,Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Location_Coords_byEpisodeFrame);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).QuaSOR_Data.All_Location_Coords_byOverallFrame=vertcat(Modality(Mod).QuaSOR_Data.All_Location_Coords_byOverallFrame,Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Location_Coords_byOverallFrame);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).QuaSOR_Data.All_Location_Coords_byOverallStim=vertcat(Modality(Mod).QuaSOR_Data.All_Location_Coords_byOverallStim,Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Location_Coords_byOverallStim);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).QuaSOR_Data.All_Max_DeltaFF0=horzcat(Modality(Mod).QuaSOR_Data.All_Max_DeltaFF0,Modality(Mod).Recording(Modality(Mod).GoodMatch).QuaSOR_Data.All_Max_DeltaFF0);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if ~isempty(Modality(Mod).Recording(Modality(Mod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallFrame)
                        %BoutonTypes=ones(size(Modality(Mod).Recording(Modality(Mod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallFrame,1),1)*BoutonCount;
                        EntryNums=ones(size(Modality(Mod).Recording(Modality(Mod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallFrame,1),1)*EntryNum;
                    else
                        %BoutonTypes=[];
                        EntryNums=[];
                    end
                    %Modality(Mod).PixelMax_Struct.BoutonType=vertcat(Modality(Mod).PixelMax_Struct.BoutonType,BoutonTypes);
                    Modality(Mod).PixelMax_Struct.EntryNum=vertcat(Modality(Mod).PixelMax_Struct.EntryNum,EntryNums);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).PixelMax_Struct.BoutonType=vertcat(Modality(Mod).PixelMax_Struct.BoutonType,Modality(Mod).Recording(Modality(Mod).GoodMatch).PixelMax_Struct.BoutonType);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).PixelMax_Struct.All_Location_Coords_byEpisodeNum=vertcat(Modality(Mod).PixelMax_Struct.All_Location_Coords_byEpisodeNum,Modality(Mod).Recording(Modality(Mod).GoodMatch).PixelMax_Struct.All_Location_Coords_byEpisodeNum);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).PixelMax_Struct.All_Location_Coords_byOverallFrame=vertcat(Modality(Mod).PixelMax_Struct.All_Location_Coords_byOverallFrame,Modality(Mod).Recording(Modality(Mod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallFrame);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).PixelMax_Struct.All_Location_Coords_byOverallStim=vertcat(Modality(Mod).PixelMax_Struct.All_Location_Coords_byOverallStim,Modality(Mod).Recording(Modality(Mod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallStim);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                for BoutonCount=1:length(Modality(Mod).BoutonArray)
                    if ~isempty(Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords)
                        %BoutonTypes=ones(size(Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords,1),1)*BoutonCount;
                        EntryNums=ones(size(Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords,1),1)*EntryNum;
                    else
                        %BoutonTypes=[];
                        EntryNums=[];
                    end
                    %Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.BoutonType=vertcat(Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.BoutonType,BoutonTypes);
                    Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.EntryNum=vertcat(Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.EntryNum,EntryNums);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords=vertcat(Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords,Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum=vertcat(Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum,Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=vertcat(Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame,Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame=vertcat(Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame,Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim=vertcat(Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim,Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Max_DeltaFF0=horzcat(Modality(Mod).BoutonArray(BoutonCount).QuaSOR_Data.All_Max_DeltaFF0,Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Max_DeltaFF0);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if ~isempty(Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame)
                        %BoutonTypes=ones(size(Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame,1),1)*BoutonCount;
                        EntryNums=ones(size(Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame,1),1)*EntryNum;
                    else
                        %BoutonTypes=[];
                        EntryNums=[];
                    end
                    %Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.BoutonType=vertcat(Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.BoutonType,BoutonTypes);
                    Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.EntryNum=vertcat(Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.EntryNum,EntryNums);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum=vertcat(Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum,Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame=vertcat(Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame,Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim=vertcat(Modality(Mod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim,Modality(Mod).Recording(Modality(Mod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Concatenate data for AltMod
                if AltMod
                for zzz=1:1
                    if ~isempty(Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Location_Coords)
                        %BoutonTypes=ones(size(Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Location_Coords,1),1)*BoutonCount;
                        EntryNums=ones(size(Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Location_Coords,1),1)*EntryNum;
                    else
                        %BoutonTypes=[];
                        EntryNums=[];
                    end
                    %Modality(AltMod).QuaSOR_Data.BoutonType=vertcat(Modality(AltMod).QuaSOR_Data.BoutonType,BoutonTypes);
                    Modality(AltMod).QuaSOR_Data.EntryNum=vertcat(Modality(AltMod).QuaSOR_Data.EntryNum,EntryNums);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).QuaSOR_Data.All_Location_Coords=vertcat(Modality(AltMod).QuaSOR_Data.All_Location_Coords,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Location_Coords);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).QuaSOR_Data.BoutonType=vertcat(Modality(AltMod).QuaSOR_Data.BoutonType,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.BoutonType);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).QuaSOR_Data.All_Location_Coords_byEpisodeNum=vertcat(Modality(AltMod).QuaSOR_Data.All_Location_Coords_byEpisodeNum,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Location_Coords_byEpisodeNum);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=vertcat(Modality(AltMod).QuaSOR_Data.All_Location_Coords_byEpisodeFrame,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Location_Coords_byEpisodeFrame);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).QuaSOR_Data.All_Location_Coords_byOverallFrame=vertcat(Modality(AltMod).QuaSOR_Data.All_Location_Coords_byOverallFrame,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Location_Coords_byOverallFrame);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).QuaSOR_Data.All_Location_Coords_byOverallStim=vertcat(Modality(AltMod).QuaSOR_Data.All_Location_Coords_byOverallStim,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Location_Coords_byOverallStim);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).QuaSOR_Data.All_Max_DeltaFF0=horzcat(Modality(AltMod).QuaSOR_Data.All_Max_DeltaFF0,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).QuaSOR_Data.All_Max_DeltaFF0);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if ~isempty(Modality(AltMod).Recording(Modality(AltMod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallFrame)
                        %BoutonTypes=ones(size(Modality(AltMod).Recording(Modality(AltMod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallFrame,1),1)*BoutonCount;
                        EntryNums=ones(size(Modality(AltMod).Recording(Modality(AltMod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallFrame,1),1)*EntryNum;
                    else
                        %BoutonTypes=[];
                        EntryNums=[];
                    end
                    %Modality(AltMod).PixelMax_Struct.BoutonType=vertcat(Modality(AltMod).PixelMax_Struct.BoutonType,BoutonTypes);
                    Modality(AltMod).PixelMax_Struct.EntryNum=vertcat(Modality(AltMod).PixelMax_Struct.EntryNum,EntryNums);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).PixelMax_Struct.BoutonType=vertcat(Modality(AltMod).PixelMax_Struct.BoutonType,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).PixelMax_Struct.BoutonType);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).PixelMax_Struct.All_Location_Coords_byEpisodeNum=vertcat(Modality(AltMod).PixelMax_Struct.All_Location_Coords_byEpisodeNum,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).PixelMax_Struct.All_Location_Coords_byEpisodeNum);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).PixelMax_Struct.All_Location_Coords_byOverallFrame=vertcat(Modality(AltMod).PixelMax_Struct.All_Location_Coords_byOverallFrame,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallFrame);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).PixelMax_Struct.All_Location_Coords_byOverallStim=vertcat(Modality(AltMod).PixelMax_Struct.All_Location_Coords_byOverallStim,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).PixelMax_Struct.All_Location_Coords_byOverallStim);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                for BoutonCount=1:length(Modality(AltMod).BoutonArray)
                    if ~isempty(Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords)
                        %BoutonTypes=ones(size(Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords,1),1)*BoutonCount;
                        EntryNums=ones(size(Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords,1),1)*EntryNum;
                    else
                        %BoutonTypes=[];
                        EntryNums=[];
                    end
                    %Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.BoutonType=vertcat(Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.BoutonType,BoutonTypes);
                    Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.EntryNum=vertcat(Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.EntryNum,EntryNums);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords=vertcat(Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum=vertcat(Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=vertcat(Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame=vertcat(Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim=vertcat(Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Max_DeltaFF0=horzcat(Modality(AltMod).BoutonArray(BoutonCount).QuaSOR_Data.All_Max_DeltaFF0,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).QuaSOR_Data.All_Max_DeltaFF0);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if ~isempty(Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame)
                        %BoutonTypes=ones(size(Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame,1),1)*BoutonCount;
                        EntryNums=ones(size(Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame,1),1)*EntryNum;
                    else
                        %BoutonTypes=[];
                        EntryNums=[];
                    end
                    %Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.BoutonType=vertcat(Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.BoutonType,BoutonTypes);
                    Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.EntryNum=vertcat(Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.EntryNum,EntryNums);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum=vertcat(Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame=vertcat(Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim=vertcat(Modality(AltMod).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim,Modality(AltMod).Recording(Modality(AltMod).GoodMatch).BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                error('Data was not matched properly!')
            end
            fprintf('Finished!\n');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            disp(['============================================================================================================']);
        end
        for Mod=1:length(Modality)
            if ~isempty(Modality(Mod).QuaSOR_Data)
                Modality(Mod).QuaSOR_All_Location_Coords=Modality(Mod).QuaSOR_Data.All_Location_Coords_byOverallFrame;
                Modality(Mod).QuaSOR_All_Location_Coords_Ib=Modality(Mod).BoutonArray(1).QuaSOR_Data.All_Location_Coords_byOverallFrame;
                Modality(Mod).QuaSOR_All_Location_Coords_Is=Modality(Mod).BoutonArray(2).QuaSOR_Data.All_Location_Coords_byOverallFrame;
                Modality(Mod).QuaSOR_NumFrames=[];
                Modality(Mod).NumStimuli=Modality(Mod).NumEvokedStimuli;
                Modality(Mod).StimStarts=[];
                Modality(Mod).TotalImagingTime=Modality(Mod).TotalSpontImagingTime;
                for EntryNum=1:length(Modality(Mod).Recording)
                    Modality(Mod).Recording(EntryNum).Group_Name=StackSaveName;
                    Modality(Mod).Recording(EntryNum).IDNum=IDCheck;
                    Modality(Mod).Recording(EntryNum).QuaSOR_All_Location_Coords=Modality(Mod).Recording(EntryNum).QuaSOR_Data.All_Location_Coords_byOverallFrame;
                    Modality(Mod).Recording(EntryNum).QuaSOR_All_Location_Coords_Ib=Modality(Mod).Recording(EntryNum).BoutonArray(1).QuaSOR_Data.All_Location_Coords_byOverallFrame;
                    Modality(Mod).Recording(EntryNum).QuaSOR_All_Location_Coords_Is=Modality(Mod).Recording(EntryNum).BoutonArray(2).QuaSOR_Data.All_Location_Coords_byOverallFrame;
                    Modality(Mod).Recording(EntryNum).QuaSOR_NumFrames=[];
                    Modality(Mod).Recording(EntryNum).NumStimuli=Modality(Mod).Recording(EntryNum).NumEvokedStimuli;
                    Modality(Mod).Recording(EntryNum).StimStarts=[];
                    Modality(Mod).Recording(EntryNum).TotalImagingTime=Modality(Mod).Recording(EntryNum).TotalSpontImagingTime;
                end
            else
                Modality(Mod).QuaSOR_Data.BoutonType=[];
                Modality(Mod).QuaSOR_Data.EntryNum=[];
                Modality(Mod).QuaSOR_Data.All_Location_Coords=[];
                Modality(Mod).QuaSOR_Data.All_Location_Coords_byEpisodeNum=[];
                Modality(Mod).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=[];
                Modality(Mod).QuaSOR_Data.All_Location_Coords_byOverallFrame=[];
                Modality(Mod).QuaSOR_Data.All_Location_Coords_byOverallStim=[];
                Modality(Mod).QuaSOR_Data.All_Max_DeltaFF0=[];
                
                Modality(Mod).QuaSOR_All_Location_Coords=[];
                Modality(Mod).QuaSOR_All_Location_Coords_Ib=[];
                Modality(Mod).QuaSOR_All_Location_Coords_Is=[];
                Modality(Mod).QuaSOR_NumFrames=[];
                Modality(Mod).NumStimuli=[];
                Modality(Mod).StimStarts=[];
                Modality(Mod).TotalImagingTime=[];
                Modality(Mod).Recording=[];
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        close all
        figure
        imshow(Modality_Merge(1).BoutonMerge.ReferenceImage,[]);
        hold on
        for Mod=1:length(Modality)
            if Modality(Mod).GoodMatch
                for i=1:size(Modality(Mod).QuaSOR_Data.All_Location_Coords)
                    plot(Modality(Mod).QuaSOR_Data.All_Location_Coords(i,2),...
                        Modality(Mod).QuaSOR_Data.All_Location_Coords(i,1),'.','color',Modality(Mod).Color,'markersize',4);
                end
            end
        end
        pause(0.1)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        QuaSOR_UpScaleFactor=Modality_Merge(ReferenceModality).BoutonMerge.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor;
        for Mod=1:length(Modality_Merge)
            Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask=imresize(Modality_Merge(Mod).BoutonMerge.AllBoutonsRegion,...
                Modality_Merge(Mod).BoutonMerge.QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,Modality_Merge(Mod).BoutonMerge.QuaSOR_Parameters.UpScaling.UpScaleMethod);
            Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask(Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask<0)=0;
            Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask(Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask>0)=1;
            Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask=logical(Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask);
            Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask=imdilate(Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask,Modality_Merge(Mod).BoutonMerge.QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion);
            Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask=imdilate(Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask,Modality_Merge(Mod).BoutonMerge.QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion2);
            Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask=imerode(Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask,Modality_Merge(Mod).BoutonMerge.QuaSOR_Map_Settings.QuaSOR_HighResBoutonErodeRegion);
            Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine=[];
            [B,L] = bwboundaries(Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask,'noholes');
            count=0;
            LineCount=1;
            for j=1:length(B)
                for k = 1:length(B{j})
                    if B{j}(k,1)~=1&&B{j}(k,2)~=1&&B{j}(k,1)~=size(Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask,1)&&B{j}(k,2)~=size(Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask,2)
                        count=count+1;
                        Modality_Merge(Mod).BoutonMerge.QuaSOR_Bouton_Mask_BorderLine{LineCount}.BorderLine(count,:) = B{j}(k,:);
                    else
                        if count==0
                        else
                            LineCount=LineCount+1;
                            count=0;
                        end
                    end
                end
                if count==0
                else
                    LineCount=LineCount+1;
                    count=0;
                end
            end
            for BoutonCount=1:length(Modality_Merge(ReferenceModality).BoutonMerge.BoutonArray)
                Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask=imresize(Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).AllBoutonsRegion,...
                    Modality_Merge(Mod).BoutonMerge.QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,Modality_Merge(Mod).BoutonMerge.QuaSOR_Parameters.UpScaling.UpScaleMethod);
                Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask(Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask<0)=0;
                Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask(Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask>0)=1;
                Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask=logical(Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask);
                Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask=imdilate(Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask,Modality_Merge(Mod).BoutonMerge.QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion);
                Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask=imdilate(Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask,Modality_Merge(Mod).BoutonMerge.QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion2);
                Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask=imerode(Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask,Modality_Merge(Mod).BoutonMerge.QuaSOR_Map_Settings.QuaSOR_HighResBoutonErodeRegion);
                Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine=[];
                [B,L] = bwboundaries(Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask,'noholes');
                count=0;
                LineCount=1;
                for j=1:length(B)
                    for k = 1:length(B{j})
                        if B{j}(k,1)~=1&&B{j}(k,2)~=1&&B{j}(k,1)~=size(Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask,1)&&B{j}(k,2)~=size(Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask,2)
                            count=count+1;
                            Modality_Merge(Mod).BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{LineCount}.BorderLine(count,:) = B{j}(k,:);
                        else
                            if count==0
                            else
                                LineCount=LineCount+1;
                                count=0;
                            end
                        end
                    end
                    if count==0
                    else
                        LineCount=LineCount+1;
                        count=0;
                    end
                end
            end        
        end
        ReferenceImage_Crop=Modality_Merge(ReferenceModality).BoutonMerge.ReferenceImage;
        QuaSOR_Ib_Bouton_Mask=Modality_Merge(ReferenceModality).BoutonMerge.BoutonArray(1).QuaSOR_Bouton_Mask;
        QuaSOR_Is_Bouton_Mask=Modality_Merge(ReferenceModality).BoutonMerge.BoutonArray(2).QuaSOR_Bouton_Mask;
        QuaSOR_Ib_Bouton_Mask_BorderLine=Modality_Merge(ReferenceModality).BoutonMerge.BoutonArray(1).QuaSOR_Bouton_Mask_BorderLine;
        QuaSOR_Is_Bouton_Mask_BorderLine=Modality_Merge(ReferenceModality).BoutonMerge.BoutonArray(2).QuaSOR_Bouton_Mask_BorderLine;
        BorderColor_Ib=Modality_Merge(ReferenceModality).BoutonMerge.BoutonArray(1).Color;
        BorderColor_Is=Modality_Merge(ReferenceModality).BoutonMerge.BoutonArray(2).Color;
        IbIs=1;
        ScaleBar=Modality_Merge(ReferenceModality).BoutonMerge.ScaleBar;
        ScaleBar_Upscale=Modality_Merge(ReferenceModality).BoutonMerge.ScaleBar_Upscale;
        QuaSOR_BorderLine_Width=Modality_Merge(ReferenceModality).BoutonMerge.QuaSOR_Map_Settings.QuaSOR_BorderLine_Width;
        QuaSOR_ImageHeight=size(Modality_Merge(ReferenceModality).BoutonMerge.QuaSOR_Bouton_Mask,1);
        QuaSOR_ImageWidth=size(Modality_Merge(ReferenceModality).BoutonMerge.QuaSOR_Bouton_Mask,2);
        QuaSOR_Color_Scalar=Modality_Merge(ReferenceModality).BoutonMerge.QuaSOR_Map_Settings.QuaSOR_Color_Scalar;
        QuaSOR_Bouton_Mask=Modality_Merge(ReferenceModality).BoutonMerge.QuaSOR_Bouton_Mask;
        Bouton_Region_Mask_Background_Color=Modality_Merge(ReferenceModality).BoutonMerge.QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color;
        Modality_Labels=[];
        Active_Mods=[];
        Active_Mod_Indices=[];
        TotalModalityMergeCount=0;
        for Mod=1:length(Modality)
            if Modality(Mod).GoodMatch
                TotalModalityMergeCount=TotalModalityMergeCount+Modality(Mod).GoodMatch;
                Active_Mods=[Active_Mods,Mod];
                Modality_Labels{TotalModalityMergeCount}=Modality(Mod).Label;
                Active_Mod_Indices=[Active_Mod_Indices,TotalModalityMergeCount];
            end
        end
        ContrastEnhancements=Modality_Merge(ReferenceModality).BoutonMerge.QuaSOR_Map_Settings.ContrastEnhancements;
        QuaSOR_Filter_Sigma_px_Options=Modality_Merge(ReferenceModality).BoutonMerge.QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas;
        QuaSOR_Filter_Size_px_Options=Modality_Merge(ReferenceModality).BoutonMerge.QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes;
        QuaSOR_Filter_Sigma_nm_Options=Modality_Merge(ReferenceModality).BoutonMerge.QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas_nm;
        GPU_Accelerate=0;
        QuaSOR_Colormap=Modality_Merge(ReferenceModality).BoutonMerge.QuaSOR_Map_Settings.ExportColorMap;
        SpotNormalization=Modality_Merge(ReferenceModality).BoutonMerge.QuaSOR_Map_Settings.SpotNormalization;
        QuaSOR_TemporalColorizations=zeros(size(QuaSOR_Filter_Sigma_px_Options));
        QuaSOR_Temporal_Colormap=[];
        QuaSOR_ZerosImage=zeros(QuaSOR_ImageHeight,QuaSOR_ImageWidth);
        QuaSOR_ZerosImage_Color=zeros(QuaSOR_ImageHeight,QuaSOR_ImageWidth,3);
        disp('======================================')
        disp('======================================')
        disp('======================================')
        disp('======================================')
        disp('======================================')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('Making QuaSOR Maps...\n')
        for Mod=1:length(Modality)
            disp('============================================================================')
            disp('============================================================================')
            disp('============================================================================')
            fprintf(['Making Mod ',num2str(Mod),' QuaSOR Maps...\n'])
            if ~isempty(Modality(Mod).QuaSOR_Data)
            if size(Modality(Mod).QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1
                for z=1:length(QuaSOR_Filter_Sigma_px_Options)
                    disp('======================================')
                    disp(['Making QuaSOR Map #',num2str(z),' for Gaussian Filter SIZE = ',num2str(QuaSOR_Filter_Size_px_Options(z)),...
                        ' SIGMA = ',num2str(QuaSOR_Filter_Sigma_px_Options(z))])

                    [Modality(Mod).QuaSOR_HighRes_Maps(z).QuaSOR_Image,~,myPool]=...
                        QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_UpScaleFactor,QuaSOR_ImageHeight,QuaSOR_ImageWidth,...
                        Modality(Mod).QuaSOR_Data.All_Location_Coords_byOverallFrame,...
                        QuaSOR_Filter_Size_px_Options(z),QuaSOR_Filter_Sigma_px_Options(z),...
                        SpotNormalization,QuaSOR_TemporalColorizations(z),QuaSOR_Colormap,0);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for x=1:length(ContrastEnhancements)
                        Modality(Mod).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                            max(Modality(Mod).QuaSOR_HighRes_Maps(z).QuaSOR_Image(:));
                        Modality(Mod).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                            Modality(Mod).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*ContrastEnhancements(x);
                    end
                end
            else
                warning on
                warning('No events to render!')
                warning('No events to render!')
                warning('No events to render!')
                warning('No events to render!')
                warning('No events to render!')
                for z=1:length(QuaSOR_Filter_Sigma_px_Options)
                    Modality(Mod).QuaSOR_HighRes_Maps(z).QuaSOR_Image=QuaSOR_ZerosImage;
                    Modality(Mod).QuaSOR_HighRes_Maps(z).QuaSOR_Image_TemporalColors=[];
                end
                for x=1:length(ContrastEnhancements)
                    Modality(Mod).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                        max(Modality(Mod).QuaSOR_HighRes_Maps(z).QuaSOR_Image(:));
                    Modality(Mod).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                        Modality(Mod).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*ContrastEnhancements(x);
                end
            end
            end
            disp('============================================================================')
            disp('============================================================================')
            disp('============================================================================')
            for EntryNum=1:Modality(Mod).GoodMatch
                disp('============================================================================')
                disp('============================================================================')
                disp('============================================================================')
                fprintf(['Making Mod ',num2str(Mod),' Entry ',num2str(EntryNum),' QuaSOR Maps...\n'])
                if size(Modality(Mod).Recording(EntryNum).QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1
                    for z=1:length(QuaSOR_Filter_Sigma_px_Options)
                        disp('======================================')
                        disp(['Making QuaSOR Map #',num2str(z),' for Gaussian Filter SIZE = ',num2str(QuaSOR_Filter_Size_px_Options(z)),...
                            ' SIGMA = ',num2str(QuaSOR_Filter_Sigma_px_Options(z))])

                        [Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).QuaSOR_Image,~,myPool]=...
                            QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_UpScaleFactor,QuaSOR_ImageHeight,QuaSOR_ImageWidth,...
                            Modality(Mod).Recording(EntryNum).QuaSOR_Data.All_Location_Coords_byOverallFrame,...
                            QuaSOR_Filter_Size_px_Options(z),QuaSOR_Filter_Sigma_px_Options(z),...
                            SpotNormalization,QuaSOR_TemporalColorizations(z),QuaSOR_Colormap,0);

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        for x=1:length(ContrastEnhancements)
                            Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                                max(Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).QuaSOR_Image(:));
                            Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                                Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*ContrastEnhancements(x);
                        end
                    end
                else
                    warning on
                    warning('No events to render!')
                    warning('No events to render!')
                    warning('No events to render!')
                    warning('No events to render!')
                    warning('No events to render!')
                    for z=1:length(QuaSOR_Filter_Sigma_px_Options)
                        Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).QuaSOR_Image=QuaSOR_ZerosImage;
                        Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).QuaSOR_Image_TemporalColors=[];
                    end
                    for x=1:length(ContrastEnhancements)
                        Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                            max(Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).QuaSOR_Image(:));
                        Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                            Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*ContrastEnhancements(x);
                    end

                end
            end
            disp('============================================================================')
            disp('============================================================================')
            disp('============================================================================')
        end
        disp('======================================')
        disp('======================================')
        disp('======================================')
        disp('======================================')
        disp('======================================')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('Pick Primary Entries if multiple files per modality...\n')
        %Pick Primary_Entry
        for Mod=1:length(Modality)
            if Modality(Mod).GoodMatch>0
                disp(['Checking Mod #',num2str(Mod),': ',Modality(Mod).Label])
                if Modality(Mod).GoodMatch>1

                    close all
                    warning(['Found ',num2str(Modality(Mod).GoodMatch),' Entries Please Pick Priority!'])
                    if isfield(Modality,'Primary_Entry')
                        if ~isempty(Modality(Mod).Primary_Entry)
                            warning(['Current Primary Entry: ',num2str(Modality(Mod).Primary_Entry)])
                            PickPrimary=InputWithVerification('Enter 1 to Re-enter Primary entry or <0> to skip: ',{[0,1]},0);
                        else
                            PickPrimary=1;
                        end
                    else
                        PickPrimary=1;
                    end

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if PickPrimary

                        TestImage=Modality(ReferenceModality).Recording(1).QuaSOR_HighRes_Maps(PriorityCheckSigmaIndex).QuaSOR_Image;
                        [~,ReferenceTestImage_Color,~]=...
                            Adjust_Contrast_and_Color(TestImage,...
                            0,max(TestImage(:))*PriorityCheckContrast,Modality(ReferenceModality).Color,...
                            QuaSOR_Color_Scalar);
                        ReferenceTestImage_Color=...
                            ColorMasking(ReferenceTestImage_Color,...
                            ~QuaSOR_Bouton_Mask,Bouton_Region_Mask_Background_Color);
                        ReferenceTestImage_Color=...
                            single(ReferenceTestImage_Color);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
                        for z=1:Modality(Mod).GoodMatch
                            TestImage=Modality(Mod).Recording(z).QuaSOR_HighRes_Maps(PriorityCheckSigmaIndex).QuaSOR_Image;
                            [~,TestImage_Color,~]=...
                                Adjust_Contrast_and_Color(TestImage,...
                                0,max(TestImage(:))*PriorityCheckContrast,Modality(Mod).Color,...
                                QuaSOR_Color_Scalar);
                            TestImage_Color=...
                                ColorMasking(TestImage_Color,...
                                ~QuaSOR_Bouton_Mask,Bouton_Region_Mask_Background_Color);
                            TestImage_Color=...
                                single(TestImage_Color);
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            figure('name',['Mod ',num2str(Mod),' Recording # ',num2str(z)])
                            subtightplot(1,2,1,[0,0],[0,0],[0,0])
                            imshow(TestImage_Color,'border','tight')
                            set(gca,'XTick', []); set(gca,'YTick', []);
                            hold on
                            for j=1:length(QuaSOR_Ib_Bouton_Mask_BorderLine)
                                plot(QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                                    QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                                    '-','color',BorderColor_Ib,'linewidth',1)
                            end
                            for j=1:length(QuaSOR_Is_Bouton_Mask_BorderLine)
                                plot(QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                                    QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                                    '-','color',BorderColor_Is,'linewidth',1)
                            end
                            text(100,100,['Mod ',num2str(Mod),' Recording # ',num2str(z)],'color','w','fontsize',18)
                            subtightplot(1,2,2,[0,0],[0,0],[0,0])
                            imshow(ReferenceTestImage_Color,'border','tight')
                            set(gca,'XTick', []); set(gca,'YTick', []);
                            hold on
                            for j=1:length(QuaSOR_Ib_Bouton_Mask_BorderLine)
                                plot(QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                                    QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                                    '-','color',BorderColor_Ib,'linewidth',1)
                            end
                            for j=1:length(QuaSOR_Is_Bouton_Mask_BorderLine)
                                plot(QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                                    QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                                    '-','color',BorderColor_Is,'linewidth',1)
                            end
                            text(100,100,['REFERENCE Mod ',num2str(ReferenceModality),' Recording # ',num2str(1)],'color','w','fontsize',18)
                            set(gcf,'units','normalized','position',[z*0.05,0.05,0.85,0.85])

                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempPick=InputWithVerification('Primary Entry (Mark <0> if want to ignore MODALITY COMPLETELY): ',{[0:1:Modality(Mod).GoodMatch]},0);
                        if TempPick==0
                            warning('Setting to ignore this condition...')
                            Modality(Mod).Primary_Entry=TempPick;
                            Modality(Mod).GoodMatch=0;
                            Modality(Mod).Flagged=1;
                        else
                            Modality(Mod).Primary_Entry=TempPick;
                            Modality(Mod).Flagged=InputWithVerification('Flag as Bad (0/1): ',{[0,1]},0);
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                else
                    Modality(Mod).Primary_Entry=1;
                    Modality(Mod).Flagged=0;
                end
            end
        end
        disp('======================================')
        disp('======================================')
        disp('======================================')
        disp('======================================')
        disp('======================================')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Set up alignment image for Structure align
        Summary_QuaSOR_Modality_Merge_AZ_Select_Image_Color_Exclusions=[];
        Summary_QuaSOR_Modality_Merge_Image_Color_Exclusions=[];
        SettingUpAlignmentImage=1;
        QuaSOR_Overlay_Mod_Indices=Active_Mod_Indices;
        QuaSOR_Overlay_FilterIndex=length(QuaSOR_Filter_Sigma_nm_Options);
        for i=1:length(QuaSOR_Filter_Sigma_nm_Options)
            QuaSOR_Filter_Sigma_nm_Options_Text{i}=['Sig = ',num2str(QuaSOR_Filter_Sigma_nm_Options(i)),' nm'];
        end
        QuaSOR_Overlay_ContrastIndex=length(ContrastEnhancements);
        while SettingUpAlignmentImage
            for i=1:length(ContrastEnhancements)
                ContrastEnhancements_Text{i}=['Contrast % = ',num2str(ContrastEnhancements(i))];
            end
            ContrastEnhancements_Text{i+1}='NEW';
            [QuaSOR_Overlay_Mod_Indices, ~] = listdlg('PromptString','Select Modalities to Merge for INITIAL Structure Alignment?',...
                'ListString',Modality_Labels,'SelectionMode','multiple','InitialValue',QuaSOR_Overlay_Mod_Indices,'ListSize', [400 200]);

            [QuaSOR_Overlay_FilterIndex, ~] = listdlg('PromptString','Select Filter Sigma to Merge for INITIAL Structure Alignment? (nm)',...
                'ListString',QuaSOR_Filter_Sigma_nm_Options_Text,'SelectionMode','multiple','InitialValue',QuaSOR_Overlay_FilterIndex,'ListSize', [400 200]);

            [QuaSOR_Overlay_ContrastIndex, ~] = listdlg('PromptString','Channel Contrast % for INITIAL Structure Alignment',...
                'ListString',ContrastEnhancements_Text,'SelectionMode','multiple','InitialValue',QuaSOR_Overlay_ContrastIndex,'ListSize', [400 200]);

            QuaSOR_Overlay_Mods=[];
            for j=1:length(QuaSOR_Overlay_Mod_Indices)
                QuaSOR_Overlay_Mods=[QuaSOR_Overlay_Mods,Active_Mods(QuaSOR_Overlay_Mod_Indices(j))];
            end
            
            
            if QuaSOR_Overlay_ContrastIndex>length(ContrastEnhancements)

                NewContrast=input('Enter contrast ratio (ex. 0.5 1 1.5): ');
                NewContrastIndex=length(ContrastEnhancements)+1;
                ContrastEnhancements(NewContrastIndex)=NewContrast;
                for Mod=1:length(Modality)
                    if size(Modality(Mod).QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1
                        for z=1:length(QuaSOR_Filter_Sigma_px_Options)
                            for x=1:length(ContrastEnhancements)
                                Modality(Mod).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                                    max(Modality(Mod).QuaSOR_HighRes_Maps(z).QuaSOR_Image(:));
                                Modality(Mod).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                                    Modality(Mod).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*ContrastEnhancements(x);
                            end
                        end
                    else
                        for z=1:length(QuaSOR_Filter_Sigma_px_Options)
                            for x=1:length(ContrastEnhancements)
                                Modality(Mod).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                                    max(Modality(Mod).QuaSOR_HighRes_Maps(z).QuaSOR_Image(:));
                                Modality(Mod).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                                    Modality(Mod).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*ContrastEnhancements(x);
                            end
                        end
                    end
                    for EntryNum=1:Modality(Mod).GoodMatch
                        if size(Modality(Mod).Recording(EntryNum).QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1
                            for z=1:length(QuaSOR_Filter_Sigma_px_Options)
                                for x=1:length(ContrastEnhancements)
                                    Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                                        max(Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).QuaSOR_Image(:));
                                    Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                                        Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*ContrastEnhancements(x);
                                end
                            end
                        else
                            for z=1:length(QuaSOR_Filter_Sigma_px_Options)
                                for x=1:length(ContrastEnhancements)
                                    Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                                        max(Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).QuaSOR_Image(:));
                                    Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                                        Modality(Mod).Recording(EntryNum).QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*ContrastEnhancements(x);
                                end
                            end
                        end
                    end
                end
            end        
            %%%%%%%%%%%
            %%%%%%%%%%%
            %%%%%%%%%%%
            %%%%%%%%%%%
            AZ_Detect_Gaussian_Index=QuaSOR_Overlay_FilterIndex;
            AZ_Select_Overlay_ContrastIndex=QuaSOR_Overlay_ContrastIndex;
            %%%%%%%%%%%
            %%%%%%%%%%%
            %%%%%%%%%%%
            %%%%%%%%%%%
            Summary_QuaSOR_Modality_Merge_Image_Color=QuaSOR_ZerosImage_Color;
            Summary_QuaSOR_Modality_Merge_AZ_Select_Image_Color=QuaSOR_ZerosImage_Color;
            for Mod=1:length(Modality)
                if Modality(Mod).GoodMatch>0
                    [~,Temp_QuaSOR_Image_Color,~]=...
                        Adjust_Contrast_and_Color(Modality(Mod).Recording(Modality(Mod).Primary_Entry).QuaSOR_HighRes_Maps(QuaSOR_Overlay_FilterIndex).QuaSOR_Image,...
                        0,Modality(Mod).Recording(Modality(Mod).Primary_Entry).QuaSOR_HighRes_Maps(QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Overlay_ContrastIndex).MaxValue_Cont,...
                        Modality(Mod).Color,...
                        QuaSOR_Color_Scalar);
                    Summary_QuaSOR_Modality_Merge_Image_Color=Summary_QuaSOR_Modality_Merge_Image_Color+Temp_QuaSOR_Image_Color;
                    if any(Mod==QuaSOR_Overlay_Mods)
                        Summary_QuaSOR_Modality_Merge_AZ_Select_Image_Color=Summary_QuaSOR_Modality_Merge_AZ_Select_Image_Color+Temp_QuaSOR_Image_Color;
                    end
                end     
            end

            Summary_QuaSOR_Modality_Merge_Image_Color=...
                single(ColorMasking(Summary_QuaSOR_Modality_Merge_Image_Color,...
                ~QuaSOR_Bouton_Mask,Bouton_Region_Mask_Background_Color));
            Summary_QuaSOR_Modality_Merge_AZ_Select_Image_Color=...
                single(ColorMasking(Summary_QuaSOR_Modality_Merge_AZ_Select_Image_Color,...
                ~QuaSOR_Bouton_Mask,Bouton_Region_Mask_Background_Color));

            Summary_QuaSOR_Modality_Merge_Image_Color=single(Summary_QuaSOR_Modality_Merge_Image_Color);
            Summary_QuaSOR_Modality_Merge_AZ_Select_Image_Color=single(Summary_QuaSOR_Modality_Merge_AZ_Select_Image_Color);
            figure
            imshow(Summary_QuaSOR_Modality_Merge_Image_Color,'border','tight')
            set(gca,'XTick', []); set(gca,'YTick', []);
            hold on
            for j=1:length(QuaSOR_Ib_Bouton_Mask_BorderLine)
                plot(QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                    '-','color',BorderColor_Ib,'linewidth',1)
            end
            for j=1:length(QuaSOR_Is_Bouton_Mask_BorderLine)
                plot(QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                    '-','color',BorderColor_Is,'linewidth',1)
            end
            text(100,100,['All Modalities'],'color','w','fontsize',18)
            figure
            imshow(Summary_QuaSOR_Modality_Merge_AZ_Select_Image_Color,'border','tight')
            set(gca,'XTick', []); set(gca,'YTick', []);
            hold on
            for j=1:length(QuaSOR_Ib_Bouton_Mask_BorderLine)
                plot(QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                    '-','color',BorderColor_Ib,'linewidth',1)
            end
            for j=1:length(QuaSOR_Is_Bouton_Mask_BorderLine)
                plot(QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                    '-','color',BorderColor_Is,'linewidth',1)
            end
            text(100,100,['Alignment Selection Modalities ONLY'],'color','w','fontsize',18)
            fprintf('FINISHED!\n')

            SettingUpAlignmentImage=input('Enter <1> to adjust overlay settings for alignment: ');

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix=' Modality Merge.mat';
        fprintf(['Saving: ',StackSaveName,FileSuffix,'...'])
        save([CurrentScratchDir2,StackSaveName,FileSuffix],'Modality','Modality_Merge',...
                'Summary_QuaSOR_Modality_Merge_Image_Color',...
                'Summary_QuaSOR_Modality_Merge_AZ_Select_Image_Color',...
                'Summary_QuaSOR_Modality_Merge_AZ_Select_Image_Color_Exclusions',...
                'Summary_QuaSOR_Modality_Merge_Image_Color_Exclusions',...
                'ReferenceImage_Crop','QuaSOR_Overlay_Mods',...
                'QuaSOR_Ib_Bouton_Mask','QuaSOR_Is_Bouton_Mask',...
                'QuaSOR_Ib_Bouton_Mask_BorderLine','QuaSOR_Is_Bouton_Mask_BorderLine',...
                'BorderColor_Ib','BorderColor_Is','QuaSOR_UpScaleFactor','IbIs',...
                'QuaSOR_BorderLine_Width','ScaleBar','ScaleBar_Upscale',...
                'QuaSOR_ImageHeight','QuaSOR_ImageWidth','ContrastEnhancements','QuaSOR_Color_Scalar',...
                'QuaSOR_Bouton_Mask','Bouton_Region_Mask_Background_Color','TotalModalityMergeCount',...
                'QuaSOR_Overlay_FilterIndex','QuaSOR_Overlay_ContrastIndex',...
                'AZ_Detect_Gaussian_Index','AZ_Select_Overlay_ContrastIndex',...
                'QuaSOR_Filter_Sigma_px_Options','QuaSOR_Filter_Size_px_Options','QuaSOR_Filter_Sigma_nm_Options',...
                'QuaSOR_ZerosImage',...
                'Modality_Labels','Active_Mods','Active_Mod_Indices','TotalModalityMergeCount','QuaSOR_Filter_Sigma_px_Options','QuaSOR_Filter_Size_px_Options','QuaSOR_Filter_Sigma_nm_Options','GPU_Accelerate','QuaSOR_Colormap','SpotNormalization','QuaSOR_TemporalColorizations','QuaSOR_Temporal_Colormap');
        fprintf('Finished\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp(['============================================================================================================']);
        disp(['============================================================================================================']);
        disp(['============================================================================================================']);
    elseif any(AnalysisParts>0)
        FileSuffix=' Modality Merge.mat';
        if ~exist([CurrentScratchDir2,StackSaveName,FileSuffix])
            if Safe2CopyDelete
                fprintf(['Copying ',StackSaveName,FileSuffix,' to CurrentScratchDir2...'])
                [CopyStatus,CopyMessage]=copyfile([SaveDir2,StackSaveName,FileSuffix],CurrentScratchDir2);
                if CopyStatus
                    fprintf('Copy successful!\n')
                else
                    error(CopyMessage)
                end               
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['Loading: ',FileSuffix,'...'])
        load([CurrentScratchDir2,StackSaveName,FileSuffix])
        fprintf('Finished\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    for EntryNum=1:length(ModalitySuffixes)
        CurrentModalitySuffix=ModalitySuffixes{EntryNum};
        SaveDir1=[LoadDir,dc,CurrentModalitySuffix,dc];
        CurrentScratchDir1=[ScratchDir,StackSaveName,dc,CurrentModalitySuffix,dc];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix=[CurrentModalitySuffix,'_QuaSOR_Data.mat'];
        if exist([CurrentScratchDir1,StackSaveName,FileSuffix])
            fprintf(['Deleting CurrentScratchDir: ',StackSaveName,FileSuffix,'...'])
            delete([CurrentScratchDir1,StackSaveName,FileSuffix]);
            fprintf('Finished\n')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if exist([CurrentScratchDir1])
            warning('Removing CurrentScratchDir1')
            try
                rmdir([CurrentScratchDir1],'s')
            catch
                warning('Unable to remove CurrentScratchDir1!')
            end
        end
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Copying Files to SaveDir...')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix=' Modality Merge.mat';
    if exist([CurrentScratchDir2,StackSaveName,FileSuffix])
        fprintf(['Copying: ',StackSaveName,FileSuffix,'...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir2,StackSaveName,FileSuffix],SaveDir2);
        if CopyStatus
            disp('Copy successful!')
            if ~isempty(BatchMode)
                warning('Deleting CurrentScratchDir Version')
                delete([CurrentScratchDir2,dc,StackSaveName,FileSuffix]);
            end
        else
            error(CopyMessage)
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix=' Modality Merge Maps.mat';
    if exist([CurrentScratchDir2,StackSaveName,FileSuffix])
        fprintf(['Copying: ',StackSaveName,FileSuffix,'...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir2,StackSaveName,FileSuffix],SaveDir2);
        if CopyStatus
            disp('Copy successful!')
            if ~isempty(BatchMode)
            warning('Deleting CurrentScratchDir Version')
            delete([CurrentScratchDir2,StackSaveName,FileSuffix]);
            end
        else
            error(CopyMessage)
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix=' Modality Merge AZs.mat';
    if exist([CurrentScratchDir2,StackSaveName,FileSuffix])
        fprintf(['Copying: ',StackSaveName,FileSuffix,'...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir2,StackSaveName,FileSuffix],SaveDir2);
        if CopyStatus
            disp('Copy successful!')
            if ~isempty(BatchMode)
                warning('Deleting CurrentScratchDir Version')
                delete([CurrentScratchDir2,StackSaveName,FileSuffix]);
            end
        else
            error(CopyMessage)
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist([CurrentScratchDir2,'Figures'])
        fprintf(['Copying: Figures...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir2,'Figures'],[SaveDir2,'Figures']);
        if CopyStatus
            disp('Copy successful!')
            if ~isempty(BatchMode)
                warning('Deleting CurrentScratchDir Version')
                try
                    rmdir([CurrentScratchDir2,'Figures'],'s')
                catch
                    warning('Unable to remove Figure Directory!')
                end
            end
        else
            error(CopyMessage)
        end       
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist([CurrentScratchDir2,'Movies'])
        fprintf(['Copying: Movies...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir2,'Movies'],[SaveDir2,'Movies']);
        if CopyStatus
            disp('Copy successful!')
            if ~isempty(BatchMode)
                warning('Deleting CurrentScratchDir Version')
                try
                    rmdir([CurrentScratchDir2,'Movies'],'s')
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
%         if exist([CurrentScratchDir])
%             warning('Removing CurrentScratchDir')
%             try
%                 rmdir([CurrentScratchDir],'s')
%             catch
%                 warning('Unable to remove CurrentScratchDir!')
%             end
%         end
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