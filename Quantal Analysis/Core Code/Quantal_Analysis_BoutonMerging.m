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
SaveDir1=[LoadDir,dc,ModalitySuffix,dc];
SaveDir2=[LoadDir,dc,'ModMerge'];
CurrentScratchDir1=[ScratchDir,StackSaveName,dc,ModalitySuffix,dc];
CurrentScratchDir2=[ScratchDir,StackSaveName,dc];
if ~exist(CurrentScratchDir1)
    mkdir(CurrentScratchDir1)
end
if ~exist(CurrentScratchDir2)
    mkdir(CurrentScratchDir2)
end
FigureSaveDir=[SaveDir1,'Figures',dc,AnalysisLabelShort];
if ~exist(FigureSaveDir)
    mkdir(FigureSaveDir)
end
FigureScratchDir=[CurrentScratchDir1,'Figures',dc,AnalysisLabelShort];
if ~exist(FigureScratchDir)
    mkdir(FigureScratchDir)
end
MoviesSaveDir=[SaveDir1,'Movies',dc,AnalysisLabelShort];
if ~exist(MoviesSaveDir)
    mkdir(MoviesSaveDir)
end
MoviesScratchDir=[CurrentScratchDir1,'Movies',dc,AnalysisLabelShort];
if ~exist(MoviesScratchDir)
    mkdir(MoviesScratchDir)
end
Safe2CopyDelete=1;
if strcmp([SaveDir1],[CurrentScratchDir1])||...
        strcmp([SaveDir1],[CurrentScratchDir1])||...
        strcmp([SaveDir1],[CurrentScratchDir1,dc])
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
FileSuffix='_ImageSet_Analysis_Setup.mat';
fprintf(['Loading ',StackSaveName,FileSuffix,'...']);
load([SaveDir1,StackSaveName,FileSuffix]);
fprintf('Finished!\n')
disp('============================================================')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%Overall Parameters
        RemapAdjustment=1;

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
    %Bouton Merging
    if any(AnalysisParts==1)&&~AdjustONLY
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        PrimaryBouton=1;
        BoutonCount=PrimaryBouton;
        SaveDir=[LoadDir,dc,ModalitySuffix,BoutonArray(BoutonCount).BoutonSuffix,dc];
        FileSuffix=[BoutonArray(BoutonCount).BoutonSuffix,'_QuaSOR_Data.mat'];
        load([SaveDir,StackSaveName,FileSuffix],'QuaSOR_Parameters');
        BoutonMerge.Modality=QuaSOR_Parameters.Modality;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for BoutonCount=1:length(BoutonArray)
            if any(BoutonArray(BoutonCount).AllBoutonsRegion_Orig(:)~=0)
                disp(['============================================================================================================']);
                disp(['============================================================================================================']);
                disp(['============================================================================================================']);
                disp(['Adding ',BoutonArray(BoutonCount).Label,' Data...']);
                SaveDir=[LoadDir,dc,ModalitySuffix,BoutonArray(BoutonCount).BoutonSuffix,dc];
                CurrentScratchDir=[ScratchDir,StackSaveName,dc,ModalitySuffix,BoutonArray(BoutonCount).BoutonSuffix,dc];
                if ~exist(CurrentScratchDir)
                    mkdir(CurrentScratchDir)
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FileSuffix=[BoutonArray(BoutonCount).BoutonSuffix,'_EventDetectionData.mat'];
                fprintf(['Loading: ',FileSuffix,'...'])
                load([SaveDir,StackSaveName,FileSuffix],'PixelMax_Struct','SplitEpisodeFiles')
                fprintf('Finished!\n')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FileSuffix=[BoutonArray(BoutonCount).BoutonSuffix,'_QuaSOR_Data.mat'];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ~exist([SaveDir,StackSaveName,FileSuffix])
                    error([StackSaveName,FileSuffix,' Missing!']);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FileSuffix=[BoutonArray(BoutonCount).BoutonSuffix,'_QuaSOR_Data.mat'];
                fprintf(['Loading: ',FileSuffix,'...'])
                load([SaveDir,StackSaveName,FileSuffix],'QuaSOR_Data','QuaSOR_Parameters','QuaSOR_Event_Extraction_Settings','AllBoutonsRegion_Upscale','ScaleBar_Upscale','BorderLine_Upscale')
                fprintf('Finished!\n')
                %%%%%%%
                FileSuffix=[BoutonArray(BoutonCount).BoutonSuffix,'_QuaSOR_Maps.mat'];
                fprintf(['Loading: ',FileSuffix,'...'])
                load([SaveDir,dc,StackSaveName,FileSuffix],'QuaSOR_Map_Settings','QuaSOR_LowRes_Map_Settings','PixelMax_Map_Settings')
                fprintf('Finished!\n')
                %%%%%%%
                FileSuffix=[BoutonArray(BoutonCount).BoutonSuffix,'_QuaSOR_AZs.mat'];
                fprintf(['Loading: ',FileSuffix,'...'])
                load([SaveDir,dc,StackSaveName,FileSuffix],'QuaSOR_Auto_AZ','QuaSOR_Auto_AZ_Settings')
                fprintf('Finished!\n')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonArray(BoutonCount).PixelMax_Struct=PixelMax_Struct;
                BoutonArray(BoutonCount).QuaSOR_Data=QuaSOR_Data;
                BoutonArray(BoutonCount).QuaSOR_Parameters=QuaSOR_Parameters;
                BoutonArray(BoutonCount).QuaSOR_Event_Extraction_Settings=QuaSOR_Event_Extraction_Settings;
                if exist('QuaSOR_Map_Settings')
                    BoutonArray(BoutonCount).QuaSOR_Map_Settings=QuaSOR_Map_Settings;
                else
                    BoutonArray(BoutonCount).QuaSOR_Map_Settings=[];
                end
                if exist('QuaSOR_LowRes_Map_Settings')
                    BoutonArray(BoutonCount).QuaSOR_LowRes_Map_Settings=QuaSOR_LowRes_Map_Settings;
                else
                    BoutonArray(BoutonCount).QuaSOR_Map_Settings=[];
                end
                if exist('PixelMax_Map_Settings')
                    BoutonArray(BoutonCount).PixelMax_Map_Settings=PixelMax_Map_Settings;
                else
                    BoutonArray(BoutonCount).PixelMax_Map_Settings=[];
                end
                if exist('QuaSOR_Auto_AZ_Settings')
                    BoutonArray(BoutonCount).QuaSOR_Auto_AZ_Settings=QuaSOR_Auto_AZ_Settings;
                else
                    BoutonArray(BoutonCount).QuaSOR_Auto_AZ_Settings=[];
                end
                if exist('QuaSOR_Auto_AZ')
                    BoutonArray(BoutonCount).QuaSOR_Auto_AZ=QuaSOR_Auto_AZ;
                else
                    BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct=[];
                end
                BoutonArray(BoutonCount).RemapAdjustment=RemapAdjustment;
                BoutonArray(BoutonCount).AllBoutonsRegion_Upscale=AllBoutonsRegion_Upscale;
                BoutonArray(BoutonCount).BorderLine_Upscale=BorderLine_Upscale;
                BoutonArray(BoutonCount).ScaleBar_Upscale=ScaleBar_Upscale;
                clear QuaSOR_Data QuaSOR_Auto_AZ PixelMax_Struct
                clear AllBoutonsRegion_Upscale BorderLine_Upscale ScaleBar_Upscale QuaSOR_Parameters
                clear QuaSOR_Event_Extraction_Settings QuaSOR_Event_Extraction_Settings QuaSOR_Map_Settings QuaSOR_LowRes_Map_Settings PixelMax_Map_Settings QuaSOR_Auto_AZ_Settings
                if BoutonCount==PrimaryBouton
                    BoutonMerge.QuaSOR_Parameters=BoutonArray(BoutonCount).QuaSOR_Parameters;
                    BoutonMerge.QuaSOR_Event_Extraction_Settings=BoutonArray(BoutonCount).QuaSOR_Event_Extraction_Settings;
                    BoutonMerge.QuaSOR_Map_Settings=BoutonArray(BoutonCount).QuaSOR_Map_Settings;
                    BoutonMerge.QuaSOR_LowRes_Map_Settings=BoutonArray(BoutonCount).QuaSOR_LowRes_Map_Settings;
                    BoutonMerge.PixelMax_Map_Settings=BoutonArray(BoutonCount).PixelMax_Map_Settings;
                    BoutonMerge.QuaSOR_Auto_AZ_Settings=BoutonArray(BoutonCount).QuaSOR_Auto_AZ_Settings;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data=BoutonArray(BoutonCount).QuaSOR_Data;
                BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ=BoutonArray(BoutonCount).QuaSOR_Auto_AZ;
                BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct=BoutonArray(BoutonCount).PixelMax_Struct;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf('Re-mapping QuaSOR Coordinates...');
                BoutonMerge.ScaleBar_Upscale=BoutonMerge.ScaleBar;
                BoutonMerge.ScaleBar_Upscale.ScaleBarBurnDisplayImage=[];
                BoutonMerge.ScaleBar_Upscale.ScaleFactor=BoutonMerge.ScaleBar_Upscale.ScaleFactor/BoutonMerge.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor;
                BoutonMerge.ScaleBar_Upscale.PixelLength=BoutonMerge.ScaleBar_Upscale.PixelLength*BoutonMerge.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor;
                BoutonMerge.ScaleBar_Upscale.XCoordinate=BoutonMerge.ScaleBar_Upscale.XCoordinate*BoutonMerge.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor;
                BoutonMerge.ScaleBar_Upscale.YCoordinate=BoutonMerge.ScaleBar_Upscale.YCoordinate*BoutonMerge.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor;
                BoutonMerge.ScaleBar_Upscale.YData=[BoutonMerge.ScaleBar_Upscale.YCoordinate,BoutonMerge.ScaleBar_Upscale.YCoordinate];
                if strcmp(BoutonMerge.ScaleBar_Upscale.PointerSide,'R')
                    BoutonMerge.ScaleBar_Upscale.XData=[BoutonMerge.ScaleBar_Upscale.XCoordinate,BoutonMerge.ScaleBar_Upscale.XCoordinate-BoutonMerge.ScaleBar_Upscale.PixelLength];
                elseif strcmp(BoutonMerge.ScaleBar_Upscale.PointerSide,'L')
                    BoutonMerge.ScaleBar_Upscale.XData=[BoutonMerge.ScaleBar_Upscale.XCoordinate,BoutonMerge.ScaleBar_Upscale.XCoordinate+BoutonMerge.ScaleBar_Upscale.PixelLength];
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping=...
                    round(BoutonArray(BoutonCount).Crop_Props.BoundingBox(1))-round(BoutonMerge.Crop_Props.BoundingBox(1))+BoutonArray(BoutonCount).RemapAdjustment;
                BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping=...
                    round(BoutonArray(BoutonCount).Crop_Props.BoundingBox(2))-round(BoutonMerge.Crop_Props.BoundingBox(2))+BoutonArray(BoutonCount).RemapAdjustment;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ~isempty(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords(:,1)=...
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords(:,1)+...
                    BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords(:,2)=...
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords(:,2)+...
                    BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum(:,1)=...
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum(:,1)+...
                    BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum(:,2)=...
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum(:,2)+...
                    BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame(:,1)=...
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame(:,1)+...
                    BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame(:,2)=...
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame(:,2)+...
                    BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame(:,1)=...
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame(:,1)+...
                    BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame(:,2)=...
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame(:,2)+...
                    BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim(:,1)=...
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim(:,1)+...
                    BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim(:,2)=...
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim(:,2)+...
                    BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                for Mod=1:length(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality)
                    if ~isempty(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeFrame(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeFrame(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeFrame(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeFrame(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    else
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeFrame=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    end
                end
                for Ep=1:length(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode)
                    if ~isempty(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byFrame(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byFrame(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byFrame(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byFrame(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeNum(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeNum(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeNum(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeNum(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeFrame(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeFrame(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeFrame(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeFrame(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeStim(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeStim(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeStim(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeStim(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallFrame(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallFrame(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallFrame(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallFrame(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallStim(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallStim(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallStim(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallStim(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    else
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byFrame=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeNum=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeFrame=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeStim=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallFrame=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallStim=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    end
                end   
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ~isempty(BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum(:,1)=...
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum(:,1)+...
                    BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum(:,2)=...
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum(:,2)+...
                    BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame(:,1)=...
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame(:,1)+...
                    BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame(:,2)=...
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame(:,2)+...
                    BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim(:,1)=...
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim(:,1)+...
                    BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim(:,2)=...
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim(:,2)+...
                    BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                for Mod=1:length(BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality)
                    if ~isempty(BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byEpisodeNum(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byEpisodeNum(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byEpisodeNum(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byEpisodeNum(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallStim(:,1)=...
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallStim(:,1)+...
                        BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping;
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallStim(:,2)=...
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallStim(:,2)+...
                        BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    else
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byEpisodeNum=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallStim=[];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ~isempty(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ)
                    for AZ=1:length(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct)
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord(:,2)=...
                            BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord(:,2)+...
                            BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping*BoutonArray(BoutonCount).QuaSOR_Map_Settings.QuaSOR_UpScaleFactor;
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord(:,1)=...
                            BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord(:,1)+...
                            BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping*BoutonArray(BoutonCount).QuaSOR_Map_Settings.QuaSOR_UpScaleFactor;

                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord_Round=...
                            round(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord);
                        BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord_Orig=...
                            BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord/...
                            BoutonArray(BoutonCount).QuaSOR_Map_Settings.QuaSOR_UpScaleFactor;
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf('Finished\n')
            else
                
                warning(['Missing ',BoutonArray(BoutonCount).Label,' Data!']);
                warning(['Missing ',BoutonArray(BoutonCount).Label,' Data!']);
                warning(['Missing ',BoutonArray(BoutonCount).Label,' Data!']);
                warning(['Missing ',BoutonArray(BoutonCount).Label,' Data!']);
                warning(['Missing ',BoutonArray(BoutonCount).Label,' Data!']);
                warning(['Missing ',BoutonArray(BoutonCount).Label,' Data!']);
                BoutonArray(BoutonCount).QuaSOR_Map_Settings=[];
                BoutonArray(BoutonCount).QuaSOR_Map_Settings=[];
                BoutonArray(BoutonCount).PixelMax_Map_Settings=[];
                BoutonArray(BoutonCount).QuaSOR_Auto_AZ_Settings=[];
                BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct=[];
                BoutonArray(BoutonCount).RemapAdjustment=RemapAdjustment;
                BoutonArray(BoutonCount).AllBoutonsRegion_Upscale=zeros(size(BoutonArray(PrimaryBouton).AllBoutonsRegion_Upscale));
                BoutonArray(BoutonCount).BorderLine_Upscale=[];
                BoutonArray(BoutonCount).ScaleBar_Upscale=[];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.BoutonArray(BoutonCount).AllBoutonsRegion=zeros(size(BoutonArray(PrimaryBouton).AllBoutonsRegion));
                BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data=BoutonArray(BoutonCount).QuaSOR_Data;
                BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ=BoutonArray(BoutonCount).QuaSOR_Auto_AZ;
                BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct=BoutonArray(BoutonCount).PixelMax_Struct;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.BoutonArray(BoutonCount).XCoordinate_ReMapping=0;
                BoutonMerge.BoutonArray(BoutonCount).YCoordinate_ReMapping=0;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords=[];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum=[];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame=[];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame=[];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim=[];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Max_DeltaFF0=[];
                
                for Mod=1:length(BoutonMerge.BoutonArray(PrimaryBouton).QuaSOR_Data.Modality)

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeFrame=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Max_DeltaFF0=[];
                end
                for Ep=1:length(BoutonMerge.BoutonArray(PrimaryBouton).QuaSOR_Data.Episode)

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byFrame=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeNum=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeFrame=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeStim=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallFrame=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallStim=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Max_DeltaFF0=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).Max_DeltaFF0=[];
                end   

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum=[];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame=[];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim=[];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for Mod=1:length(BoutonMerge.BoutonArray(PrimaryBouton).PixelMax_Struct.Modality)

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byEpisodeNum=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallStim=[];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp(['============================================================================================================']);
        disp(['============================================================================================================']);
        disp(['============================================================================================================']);
        fprintf('Merging Bouton Coordinates...')
        BoutonMerge.QuaSOR_Data.BoutonType=[];
        BoutonMerge.QuaSOR_Data.All_Location_Coords=[];
        BoutonMerge.QuaSOR_Data.All_Location_Coords_byEpisodeNum=[];
        BoutonMerge.QuaSOR_Data.All_Location_Coords_byEpisodeFrame=[];
        BoutonMerge.QuaSOR_Data.All_Location_Coords_byOverallFrame=[];
        BoutonMerge.QuaSOR_Data.All_Location_Coords_byOverallStim=[];
        BoutonMerge.QuaSOR_Data.All_Max_DeltaFF0=[];
        for Mod=1:length(BoutonMerge.Modality)
            BoutonMerge.QuaSOR_Data.Modality(Mod).Label=BoutonMerge.BoutonArray(PrimaryBouton).QuaSOR_Data.Modality(Mod).Label;
            BoutonMerge.QuaSOR_Data.Modality(Mod).BoutonType=[];
            BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords=[];
            BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum=[];
            BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeFrame=[];
            BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame=[];
            BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim=[];
            BoutonMerge.QuaSOR_Data.Modality(Mod).All_Max_DeltaFF0=[];
        end
        for Ep=1:ImagingInfo.NumEpisodes
            BoutonMerge.QuaSOR_Data.Episode(Ep).BoutonType=[];
            BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords=[];
            BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byFrame=[];
            BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeNum=[];
            BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeFrame=[];
            BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeStim=[];
            BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallFrame=[];
            BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallStim=[];
            BoutonMerge.QuaSOR_Data.Episode(Ep).All_Max_DeltaFF0=[];
        end   
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for BoutonCount=1:length(BoutonArray)
            if ~isempty(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords)
                BoutonTypes=ones(size(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords,1),1)*BoutonCount;
            else
                BoutonTypes=[];
            end
            BoutonMerge.QuaSOR_Data.BoutonType=vertcat(BoutonMerge.QuaSOR_Data.BoutonType,BoutonTypes);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            BoutonMerge.QuaSOR_Data.All_Location_Coords=vertcat(BoutonMerge.QuaSOR_Data.All_Location_Coords,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            BoutonMerge.QuaSOR_Data.All_Location_Coords_byEpisodeNum=vertcat(BoutonMerge.QuaSOR_Data.All_Location_Coords_byEpisodeNum,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeNum);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            BoutonMerge.QuaSOR_Data.All_Location_Coords_byEpisodeFrame=vertcat(BoutonMerge.QuaSOR_Data.All_Location_Coords_byEpisodeFrame,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byEpisodeFrame);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            BoutonMerge.QuaSOR_Data.All_Location_Coords_byOverallFrame=vertcat(BoutonMerge.QuaSOR_Data.All_Location_Coords_byOverallFrame,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallFrame);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            BoutonMerge.QuaSOR_Data.All_Location_Coords_byOverallStim=vertcat(BoutonMerge.QuaSOR_Data.All_Location_Coords_byOverallStim,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Location_Coords_byOverallStim);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            BoutonMerge.QuaSOR_Data.All_Max_DeltaFF0=horzcat(BoutonMerge.QuaSOR_Data.All_Max_DeltaFF0,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.All_Max_DeltaFF0);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for Mod=1:length(BoutonMerge.Modality)
                if ~isempty(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords)
                    BoutonTypes=ones(size(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords,1),1)*BoutonCount;
                else
                    BoutonTypes=[];
                end
                BoutonMerge.QuaSOR_Data.Modality(Mod).BoutonType=vertcat(BoutonMerge.QuaSOR_Data.Modality(Mod).BoutonType,BoutonTypes);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords=vertcat(BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum=vertcat(BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeFrame=vertcat(BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeFrame,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeFrame);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame=vertcat(BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim=vertcat(BoutonMerge.QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Modality(Mod).All_Max_DeltaFF0=horzcat(BoutonMerge.QuaSOR_Data.Modality(Mod).All_Max_DeltaFF0,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Modality(Mod).All_Max_DeltaFF0);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            for Ep=1:ImagingInfo.NumEpisodes
                if ~isempty(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords)
                    BoutonTypes=ones(size(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords,1),1)*BoutonCount;
                else
                    BoutonTypes=[];
                end
                BoutonMerge.QuaSOR_Data.Episode(Ep).BoutonType=vertcat(BoutonMerge.QuaSOR_Data.Episode(Ep).BoutonType,BoutonTypes);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords=vertcat(BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byFrame=vertcat(BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byFrame,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byFrame);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeNum=vertcat(BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeNum,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeNum);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeFrame=vertcat(BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeFrame,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeFrame);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeStim=vertcat(BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeStim,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byEpisodeStim);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallFrame=vertcat(BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallFrame,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallFrame);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallStim=vertcat(BoutonMerge.QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallStim,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).All_Location_Coords_byOverallStim);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.QuaSOR_Data.Episode(Ep).All_Max_DeltaFF0=horzcat(BoutonMerge.QuaSOR_Data.Episode(Ep).All_Max_DeltaFF0,BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Data.Episode(Ep).Max_DeltaFF0);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end   
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        BoutonMerge.PixelMax_Struct.BoutonType=[];
        BoutonMerge.PixelMax_Struct.All_Location_Coords_byEpisodeNum=[];
        BoutonMerge.PixelMax_Struct.All_Location_Coords_byOverallFrame=[];
        BoutonMerge.PixelMax_Struct.All_Location_Coords_byOverallStim=[];
        for Mod=1:length(BoutonMerge.Modality)
            BoutonMerge.PixelMax_Struct.Modality(Mod).BoutonType=[];
            BoutonMerge.PixelMax_Struct.Modality(Mod).All_Location_Coords_byEpisodeNum=[];
            BoutonMerge.PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame=[];
            BoutonMerge.PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallStim=[];
        end
        for BoutonCount=1:length(BoutonArray)
            if ~isempty(BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame)
                BoutonTypes=ones(size(BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame,1),1)*BoutonCount;
            else
                BoutonTypes=[];
            end
            BoutonMerge.PixelMax_Struct.BoutonType=vertcat(BoutonMerge.PixelMax_Struct.BoutonType,BoutonTypes);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            BoutonMerge.PixelMax_Struct.All_Location_Coords_byEpisodeNum=vertcat(BoutonMerge.PixelMax_Struct.All_Location_Coords_byEpisodeNum,BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byEpisodeNum);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            BoutonMerge.PixelMax_Struct.All_Location_Coords_byOverallFrame=vertcat(BoutonMerge.PixelMax_Struct.All_Location_Coords_byOverallFrame,BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallFrame);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            BoutonMerge.PixelMax_Struct.All_Location_Coords_byOverallStim=vertcat(BoutonMerge.PixelMax_Struct.All_Location_Coords_byOverallStim,BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.All_Location_Coords_byOverallStim);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for Mod=1:length(BoutonMerge.Modality)
                if ~isempty(BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame)
                    BoutonTypes=ones(size(BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame,1),1)*BoutonCount;
                else
                    BoutonTypes=[];
                end
                BoutonMerge.PixelMax_Struct.Modality(Mod).BoutonType=vertcat(BoutonMerge.PixelMax_Struct.Modality(Mod).BoutonType,BoutonTypes);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.PixelMax_Struct.Modality(Mod).All_Location_Coords_byEpisodeNum=vertcat(BoutonMerge.PixelMax_Struct.Modality(Mod).All_Location_Coords_byEpisodeNum,BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byEpisodeNum);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame=vertcat(BoutonMerge.PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame,BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonMerge.PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallStim=vertcat(BoutonMerge.PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallStim,BoutonMerge.BoutonArray(BoutonCount).PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallStim);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
        fprintf('Finished!\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        close all
        figure
        imshow(BoutonMerge.ReferenceImage,[]);
        hold on
        for i=1:size(BoutonMerge.QuaSOR_Data.All_Location_Coords)
            plot(BoutonMerge.QuaSOR_Data.All_Location_Coords(i,2),...
                BoutonMerge.QuaSOR_Data.All_Location_Coords(i,1),'.','color','m','markersize',4);
        end
        pause(0.1)
        figure
        imshow(BoutonMerge.ReferenceImage,[]);
        hold on
        for BoutonCount=1:length(BoutonArray)
            for AZ=1:length(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct)
                plot(BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord_Orig(1),...
                    BoutonMerge.BoutonArray(BoutonCount).QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord_Orig(2),...
                    '.','color','m','markersize',4);
            end
        end
        pause(0.1)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix='_QuaSOR_Data.mat';
        fprintf(['Saving: ',FileSuffix,'...'])
        save([CurrentScratchDir1,StackSaveName,FileSuffix],'BoutonMerge','BoutonArray')
        fprintf('Finished\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp(['============================================================================================================']);
        disp(['============================================================================================================']);
        disp(['============================================================================================================']);
    elseif any(AnalysisParts>0)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix='_QuaSOR_Data.mat';
        fprintf(['Loading: ',FileSuffix,'...'])
        load([CurrentScratchDir1,StackSaveName,FileSuffix])
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
        IbIs=1;
        BorderLine=[];
        if ~exist('BoutonMerge')
            BoutonMerge=[];
        end

%             QuaSOR_Map_Settings=BoutonMerge.QuaSOR_Map_Settings;
%             QuaSOR_Data=BoutonMerge.QuaSOR_Data;
%             QuaSOR_Parameters=BoutonMerge.QuaSOR_Parameters;
%             QuaSOR_Event_Extraction_Settings=BoutonMerge.QuaSOR_Event_Extraction_Settings;
%             QuaSOR_LowRes_Map_Settings=BoutonMerge.QuaSOR_LowRes_Map_Settings;
%             PixelMax_Map_Settings=BoutonMerge.PixelMax_Map_Settings;
%             PixelMax_Struct=BoutonMerge.PixelMax_Struct;
%             Image_Height=BoutonMerge.Image_Height;
%             Image_Width=BoutonMerge.Image_Width;
%             AllBoutonsRegion=BoutonMerge.AllBoutonsRegion;
%             ScaleBar=BoutonMerge.ScaleBar;
%             ScaleBar_Upscale=BoutonMerge.ScaleBar_Upscale;

        [QuaSOR_Maps,...
            BoutonMerge.QuaSOR_Map_Settings,...
            BoutonMerge.PixelMax_Maps,...
            BoutonMerge.PixelMax_Map_Settings]=...
            Multi_Modality_QuaSOR_Maps(myPool,OS,dc,SaveName,StackSaveName,SaveDir1,CurrentScratchDir1,FigureScratchDir,...
            BoutonMerge.QuaSOR_Map_Settings,...
            BoutonMerge.QuaSOR_Data,...
            BoutonMerge.QuaSOR_Parameters,...
            BoutonMerge.QuaSOR_Event_Extraction_Settings,...
            BoutonMerge.QuaSOR_LowRes_Map_Settings,...
            BoutonMerge.PixelMax_Map_Settings,...
            BoutonMerge.PixelMax_Struct,...
            BoutonMerge.Image_Height,BoutonMerge.Image_Width,BoutonMerge.AllBoutonsRegion,BoutonArray,BorderLine,...
            BoutonMerge.ScaleBar,BoutonMerge.ScaleBar_Upscale,MarkerSetInfo,...
            GPU_Memory_Miniumum,GPU_Accelerate,RemoveDuplicates,...
            DisplayIntermediates,ExportImages,CleanupMapRGB,...
            IbIs_CoordinateAdjust,IbIs,BoutonMerge);
    elseif any(AnalysisParts>0)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix='_QuaSOR_Maps.mat';
        fprintf(['Loading: ',FileSuffix,'...'])
        load([CurrentScratchDir1,StackSaveName,FileSuffix])
        fprintf('Finished\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    
    
    
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
    for BoutonCount=1:length(BoutonArray)
                SaveDir=[LoadDir,dc,ModalitySuffix,BoutonArray(BoutonCount).BoutonSuffix,dc];
                CurrentScratchDir=[ScratchDir,StackSaveName,dc,ModalitySuffix,BoutonArray(BoutonCount).BoutonSuffix,dc];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Deleting some ScratchDir Files...')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix=[BoutonArray(BoutonCount).BoutonSuffix,'_DeltaFData.mat'];
        if exist([CurrentScratchDir,StackSaveName,FileSuffix])
            fprintf(['Deleting CurrentScratchDir: ',StackSaveName,FileSuffix,'...'])
            delete([CurrentScratchDir,StackSaveName,FileSuffix]);
            fprintf('Finished\n')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if SplitEpisodeFiles
            for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FileSuffix=[BoutonArray(BoutonCount).BoutonSuffix,'_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
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
        FileSuffix=[BoutonArray(BoutonCount).BoutonSuffix,'_EventDetectionData.mat'];
        if exist([CurrentScratchDir,StackSaveName,FileSuffix])
            fprintf(['Deleting CurrentScratchDir: ',StackSaveName,FileSuffix,'...'])
            delete([CurrentScratchDir,StackSaveName,FileSuffix]);
            fprintf('Finished\n')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if SplitEpisodeFiles
            for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FileSuffix=[BoutonArray(BoutonCount).BoutonSuffix,'_EventDetectionData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
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
        FileSuffix=[BoutonArray(BoutonCount).BoutonSuffix,'_QuaSOR_Evaluation.mat'];
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
        FileSuffix=[BoutonArray(BoutonCount).BoutonSuffix,'_Analysis_Setup.mat'];
        if exist([CurrentScratchDir,StackSaveName,FileSuffix])
            fprintf(['Deleting CurrentScratchDir: ',StackSaveName,FileSuffix,'...'])
            delete([CurrentScratchDir,StackSaveName,FileSuffix]);
            fprintf('Finished\n')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix=[BoutonArray(BoutonCount).BoutonSuffix,'_ImageData.mat'];
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
    if exist([CurrentScratchDir1,StackSaveName,FileSuffix])
        fprintf(['Copying: ',StackSaveName,FileSuffix,'...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir1,StackSaveName,FileSuffix],SaveDir1);
        if CopyStatus
            disp('Copy successful!')
            if ~isempty(BatchMode)
            warning('Deleting CurrentScratchDir Version')
            delete([CurrentScratchDir1,StackSaveName,FileSuffix]);
            end
        else
            error(CopyMessage)
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_QuaSOR_Maps.mat';
    if exist([CurrentScratchDir1,StackSaveName,FileSuffix])
        fprintf(['Copying: ',StackSaveName,FileSuffix,'...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir1,StackSaveName,FileSuffix],SaveDir1);
        if CopyStatus
            disp('Copy successful!')
            if ~isempty(BatchMode)
            warning('Deleting CurrentScratchDir Version')
            delete([CurrentScratchDir1,StackSaveName,FileSuffix]);
            end
        else
            error(CopyMessage)
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_QuaSOR_AZs.mat';
    if exist([CurrentScratchDir1,StackSaveName,FileSuffix])
        fprintf(['Copying: ',StackSaveName,FileSuffix,'...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir1,StackSaveName,FileSuffix],SaveDir1);
        if CopyStatus
            disp('Copy successful!')
            if ~isempty(BatchMode)
                warning('Deleting CurrentScratchDir Version')
                delete([CurrentScratchDir1,StackSaveName,FileSuffix]);
            end
        else
            error(CopyMessage)
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist([CurrentScratchDir1,'Figures'])
        fprintf(['Copying: Figures...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir1,'Figures'],[SaveDir1,'Figures']);
        if CopyStatus
            disp('Copy successful!')
            if ~isempty(BatchMode)
                warning('Deleting CurrentScratchDir Version')
                try
                    rmdir([CurrentScratchDir1,'Figures'],'s')
                catch
                    warning('Unable to remove Figure Directory!')
                end
            end
        else
            error(CopyMessage)
        end       
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist([CurrentScratchDir1,'Movies'])
        fprintf(['Copying: Movies...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir1,'Movies'],[SaveDir1,'Movies']);
        if CopyStatus
            disp('Copy successful!')
            if ~isempty(BatchMode)
                warning('Deleting CurrentScratchDir Version')
                try
                    rmdir([CurrentScratchDir1,'Movies'],'s')
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