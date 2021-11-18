%todo:
%import flagged episode list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edited and Maintained by Zachary Newman (newmanza@gmail.com)
% STAGE 1 Part 0: Data Intake and Preparation
% AnalysisPart 1: Set up and find files
% AnalysisPart 2: Episode Checking
% AnalysisPart 3: Define Modality Protocol
% AnalysisPart 4: Select Ib/Is Analysis Regions
% AnalysisPart 5: Registration Setup
% AnalysisPart 6: Add Treament Markers
% AnalysisPart 7: IbIs Merge Settings
% AnalysisPart 8: Export Formatted List files for Batch Processing
% AnalysisPart 9: Save and generate directories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StartChoice = questdlg('Start Quantal Analysis Preparation?','Start Preparation?','Clear','Redo','Cancel','Clear');
if strcmp(StartChoice,'Clear')
    clearvars -except myPool dc OS compName ClentCompName MatlabVersion MatlabVersionYear ScreenSize CurrentScratchDir ScratchDir LabDefaults...
        CurrentParentDir ParentDir ParentDir1 ParentDir2 ParentDir3...
        Recording Client_Recording Server_Recording currentFolder File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions BatchMode AnalysisPartsChoiceOptions AnalysisPartOptions RecordingChoiceOptions Function RecordingNum RecordingNum1 RecordingNums RecordingNum1 RecordingNums LastRecording...
        LoopCount File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort Function ErrorTolerant BrokeLoop AbortButton BufferSize Port PortChoice PortOptions PortOptionsText TimeOut NumLoops ServerIP BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
        RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode AdjustOnly
elseif strcmp(StartChoice,'Redo')
    warning('Not Clearing Workspace!')
else strcmp(StartChoice,'Cancel')
    error('Not Starting...');
end
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LabDefaults=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ScratchDir,dc]=ScratchDir_Lookup(LabDefaults);
[OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(1);
StartingDir=cd;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('AnalysisPartsChoiceOptions')
    [AnalysisPartsChoice, ~] = listdlg('PromptString','Select Analysis Parts?','SelectionMode','single','ListString',AnalysisPartsChoiceOptions,'ListSize', [600 600]);
    AnalysisParts=AnalysisPartOptions{AnalysisPartsChoice};
else
    AnalysisParts=[1:9];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
ModeChoice = questdlg('Quantal Intake Preparation?','Quantal Intake Preparation?','Hints ON','Hints OFF','Hints OFF');
if strcmp(ModeChoice,'Hints OFF')
    TutorialNotes=0;
elseif strcmp(ModeChoice,'Hints ON')
    TutorialNotes=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%               STAGE 0              %
%           AnalysisPart 1           %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if any(AnalysisParts==1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ReLoadPrep=questdlg('Reload a file preparation or start fresh?','Reload Prep','Reload','Start','Start'); 
    switch ReLoadPrep
        case 'Reload'
            %ReLoad Files to adjust settings somewhere above
            %This will allow you to jump into the main Preparation script and adjust
            %settings safely
            [OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(1);
            warning('Make sure to select the ImageSet Versions not the Specific Bouton Version here!')
            CurrentSaveDir=uigetdir('','Select the Primary DIRECTORY for the files');
            [CurrentParentDir, SaveDir] = fileparts(CurrentSaveDir);
            cd(CurrentSaveDir)
            [File1, FileDir1, ~] = uigetfile( ...
            {   '*_ImageData.mat','_ImageData.mat';...
               }, ...
               'Pick _ImageData.mat File for ImageSet NOT Bouton Set');
            cd(FileDir1);
            [File2, FileDir2, ~] = uigetfile( ...
            {   '*_ImageSet_Analysis_Setup.mat','_ImageSet_Analysis_Setup.mat';...
               }, ...
               'Pick _ImageSet_Analysis_Setup.mat File for ImageSet NOT Bouton Set');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            InputSaveName=1;
            while InputSaveName
                load([FileDir2,File2],'SaveName','Genotype')
                if ~exist('SaveName')
                    SaveName=File1(1:length(File1)-length('_ImageData.mat'));
                end
                if ~exist('Genotype')
                    Genotype='GC6';
                end
                warning('Remember SaveName doesnt have to have a protocol/modality tag')
                prompt = {['SaveName (Genotype_Protocol_Unique#): '];['Genotype: '];'LabDefault File'};
                dlg_title = 'Some important info:';
                num_lines = 1;
                defaultans = {SaveName;Genotype;LabDefaults};
                answer = inputdlgcolZN(prompt,dlg_title,num_lines,defaultans,'on',1);
                SaveName=answer{1};
                Genotype=answer{2};
                LabDefaults=answer{3};
                clear answer
                clear answer
                disp(['SaveName = ',SaveName])
                InputSaveNameChoice=questdlg('RESET SaveName?','RESET SaveName','Skip','Reset','Skip'); 
                switch InputSaveNameChoice
                    case 'Skip'
                        InputSaveName=0;
                    case 'Reset'
                        InputSaveName=1;
                end
            end
            InputImagingInfo=1;
            while InputImagingInfo
                load([FileDir2,File2],'ImagingInfo')
                if ~exist('SaveName')
                    ImagingInfo.ModalitySuffix=File2(1:length(File2)-length('_ImageSet_Analysis_Setup.mat'));
                end
                if ~isfield(ImagingInfo,'ModalitySuffix')
                    ImagingInfo.ModalitySuffix=File2(1:length(File2)-length('_ImageSet_Analysis_Setup.mat'));
                end
                warning('Remember ImagingInfo.ModalitySuffix JUST BE a protocol/modality tag')
                prompt = {['ImagingInfo.ModalitySuffix: ']};
                dlg_title = 'ImagingInfo.ModalitySuffix';
                num_lines = 1;
                defaultans = {ImagingInfo.ModalitySuffix};
                answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                ImagingInfo.ModalitySuffix=answer{1};
                clear answer
                disp(['ImagingInfo.ModalitySuffix = ',ImagingInfo.ModalitySuffix])
                ResetChoice = questdlg('Do you want to RESET ImagingInfo.ModalitySuffix?','Reset?','Reset','Continue','Continue');
                switch ResetChoice
                    case 'Reset'
                        InputImagingInfo=1;
                    case 'Continue'
                        InputImagingInfo=0;
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            CurrentScratchDir=[ScratchDir,SaveName,dc];
            if ~exist(CurrentScratchDir)
                mkdir(CurrentScratchDir)
            end
            Safe2CopyDelete=1;
            if strcmp([CurrentSaveDir],[CurrentScratchDir])||...
                    strcmp([CurrentSaveDir,dc],[CurrentScratchDir])||...
                    strcmp([CurrentSaveDir],[CurrentScratchDir,dc])
                Safe2CopyDelete=0;
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TempDir=[CurrentScratchDir,ImagingInfo.ModalitySuffix,dc];
            if ~exist(TempDir)
                mkdir(TempDir)
            end
            disp('============================================================')
            if Safe2CopyDelete
                fprintf(['Copying ',File1,' to CurrentScratchDir...'])
                [CopyStatus,CopyMessage]=copyfile([FileDir1,File1],TempDir);
                if CopyStatus
                    fprintf('Copy successful!\n')
                else
                    error(CopyMessage)
                end               
            end
            fprintf(['Loading ',File1,'...']);
            load([TempDir,File1]);
            fprintf('Finished!\n')
            disp('============================================================')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            disp('============================================================')
            if Safe2CopyDelete
                fprintf(['Copying ',File2,' to CurrentScratchDir...'])
                [CopyStatus,CopyMessage]=copyfile([FileDir1,File2],TempDir);
                if CopyStatus
                    fprintf('Copy successful!\n')
                else
                    error(CopyMessage)
                end               
            end
            fprintf(['Loading ',File2,'...']);
            load([TempDir,File2]);
            fprintf('Finished!\n')
            disp('============================================================')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if length(ImagingInfo.GoodEpisodeNumbers)>200
                ImagingInfo.AutoPlayBackInterval=0.001;
            elseif length(ImagingInfo.GoodEpisodeNumbers)>50
                ImagingInfo.AutoPlayBackInterval=0.01;
            else
                ImagingInfo.AutoPlayBackInterval=0.1;
            end
            ImageArray=zeros(ImagingInfo.Image_Height,ImagingInfo.Image_Width,length(ImagingInfo.AllGoodFrames),ImagingInfo.DataType);
            progressbar('ImageNumber')
            for ImageNumber=1:length(ImagingInfo.AllGoodFrames)
                progressbar(ImageNumber/length(ImagingInfo.AllGoodFrames))
                TempImage = ImageArray_All_Raw(:,:,ImagingInfo.AllGoodFrames(ImageNumber));
                ImageArray(:,:, ImageNumber) = TempImage;
                clear TempImage
            end
            %PlayBackAllFrames=InputWithVerification('Enter <1> to Play ALL FRAMES: ',{[],[1]},0);
            PlayBackChoice = questdlg('Do you want to Play ALL FRAMES?','Playback?','Play','Skip','Skip');
            switch PlayBackChoice
                case 'Play'
                    PlayBackAllFrames=1;
                case 'Skip'
                    PlayBackAllFrames=0;
            end

            if PlayBackAllFrames
                AutoPlaybackNew(ImageArray,1,AutoPlaybackInterval,[0 max(ImageArray(:))-0.3*max(ImageArray(:))],'jet');
            end
            if ~isfield(ImagingInfo,'TestDeltaFVectors')
                SelectingTestROI=1;
                while SelectingTestROI
                    close all
                    Test_FilterSize_px=11;
                    Test_FilterSigma_px=1;
                    TempVector=[];
                    if length(ImagingInfo.GoodEpisodeNumbers)>4
                        ImagingInfo.TestEpisodes=5;
                    elseif length(ImagingInfo.GoodEpisodeNumbers)>3
                        ImagingInfo.TestEpisodes=4;
                    elseif length(ImagingInfo.GoodEpisodeNumbers)>2
                        ImagingInfo.TestEpisodes=3;
                    elseif length(ImagingInfo.GoodEpisodeNumbers)>1
                        ImagingInfo.TestEpisodes=2;
                    else
                        ImagingInfo.TestEpisodes=1;
                    end
                    figure,
                    imshow(ImageArray_All_Raw(:,:,1),[],'border','tight')
                    hold on
                    text(10,10,'Select a test ROI to find overall DeltaF pattern','color','y','fontsize',14);
                    TestROI=roipoly;
                    close all
                    EpisodeCount=1;
                    FrameCount=1;
                    ImagingInfo.TestDeltaFVectors=[];
                    for ImageNumber=1:ImagingInfo.FramesPerEpisode*ImagingInfo.TestEpisodes
                        if rem(ImageNumber,ImagingInfo.FramesPerEpisode)==1
                            ImagingInfo.TestDeltaFVectors(EpisodeCount,FrameCount)=NaN;
                        else
                            TempImage = (double(ImageArray_All_Raw(:,:,ImageNumber))-double(ImageArray_All_Raw(:,:,1)))./double(ImageArray_All_Raw(:,:,1));
                            ImagingInfo.TestDeltaFVectors(EpisodeCount,FrameCount) = mean(TempImage(TestROI));
                            clear TempImage
                        end
                        if FrameCount<ImagingInfo.FramesPerEpisode
                            FrameCount=FrameCount+1;
                        else
                            FrameCount=1;
                            EpisodeCount=EpisodeCount+1;
                        end
                    end
                    figure
                    hold on
                    for i=1:size(ImagingInfo.TestDeltaFVectors,1)
                        plot([1:ImagingInfo.FramesPerEpisode],ImagingInfo.TestDeltaFVectors(i,:),'*-')
                    end
                    xlabel('Episode frame #')
                    ylabel('Test \DeltaF/F')
                    SelectingChoice=questdlg('Move ROI?','Move ROI?','Move','Good','Good');
                    switch SelectingChoice
                        case 'Move'
                            SelectingTestROI=1;
                        case 'Good'
                            SelectingTestROI=0;
                    end

                end
            end
        case 'Start'
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if TutorialNotes
                questdlg({'Some Definitions:';...
                    'Modality refers to the specific combination of imaging';...
                    'and stimulation conditions with multiple Modalities possible for each NMJ';...
                    'For Imaging we usually use Episodic or short bursts of imaging around';...
                    'one or two stimuli without any imaging in between episodes.';...
                    'Alternatively streaming is usually used for Spontaneous/minis, ';...
                    'Mini+evoked, or short bursts of high frequency stimulation';...
                    'Though sometimes we combine multiple streaming imaging bouts';...
                    'into a single dataset and in this case we will refer to each';...
                    'streaming aquisition session as an episode.'},...
                    'Zach''s Hints!','Continue','Continue');
                Instructions={'I would recommend using an unique <SaveName>';...
                    'for each NMJs experiment set. We will attach File/Modality and ';...
                    'Bouton-type suffixes to the SaveName to specific the protocol and Ib/Is';...
                    'if more than one protocol was performed on the NMJ.';...
                    'I recommend to use format w/o spaces: Genotype_Protocol_Unique#';...
                    '<ImageSetSaveName> will refer to the specific protocol and';...
                    '<StackSaveName> will refer to the Bouton-specific files'};
                TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
                if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
                    TutorialNotes=0;
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %SaveName ID will track throughout the rest of the code.
                SaveName = 'Genotype_Experiment_Replicate';
                Genotype = 'GC6';
                AnalysisLabel='Preparation';
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ModeChoice = questdlg('Load Previous SaveName/Genotype?','StackSaveName?','Load','Define','Define');
            if strcmp(ModeChoice,'Load')
                [TemFile, TempPath, ~] = uigetfile(...
                {'*_ImageSet_Analysis_Setup.mat','_ImageSet_Analysis_Setup.mat'},'Pick _ImageSet_Analysis_Setup.mat containing SaveName/Genotype');
                    load([TempPath,TemFile],'SaveName','Genotype')
            end
            prompt = {['SaveName (Genotype_Protocol_Unique#): '];['Genotype: '];LabDefaults};
            dlg_title = 'Some important info:';
            num_lines = 1;
            defaultans = {SaveName;Genotype;LabDefaults};
            answer = inputdlgcolZN(prompt,dlg_title,num_lines,defaultans,'on',1);
            SaveName=answer{1};
            Genotype=answer{2};
            LabDefaults=answer{3};
            clear answer
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Select Raw Data Files
            [RawDataFileNames, RawDataPath, ~] = uigetfile(...
            {'*.tif','.tif';'*.tiff','.tiff'},'Pick a RAW DATA file(s)','MultiSelect', 'on');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Select Directories
            if TutorialNotes
                Instructions={'I would recommend making a folder for each <SaveName>';...
                    'NMJ experiment set. The pipeline will be able to sort all of the';...
                    'Different Modalit8ies and Boutons out witin the main directory';...
                    'I also find it useful to include in the folcer name:';...
                    'Date Prep# NMJ ID Genotype SaveName';...
                    'ex: 180517 P2RA5M4 WT GC6f 0_2Hz Minis WT_GC6f_02Hz_Mini_11';...
                    'Though Shorter is Better...'};
                
                TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
                if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
                    TutorialNotes=0;
                end
            end
            DirChoice = questdlg('Save Directory?','Quantal Pipeline Mode?','Pick Dir','Make Dir','Pick Dir');
            if strcmp(DirChoice,'Pick Dir')
                CurrentSaveDir=uigetdir('','Select the FINAL DIRECTORY where you want to save all files');
                [CurrentParentDir, SaveDir] = fileparts(CurrentSaveDir);
            else
                Instructions={'NOTE: First you will pick the parent directory';...
                    'Then you will provide the folder name for the SaveDir...'};
                TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
                if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
                    TutorialNotes=0;
                end
                CurrentParentDir=uigetdir('','Select the PARENT DIRECTORY');
                cd(CurrentParentDir)

                prompt = {['Enter Folder for SaveDir (I rec. including Date PrepID Geno SaveName): ']};
                dlg_title = 'SaveDir';
                num_lines = 1;
                defaultans = {SaveName};
                answer = inputdlgcolZN(prompt,dlg_title,num_lines,defaultans,'on',1);
                SaveDir=answer{1};
                clear answer
                CurrentSaveDir=[CurrentParentDir,dc,SaveDir];
                if ~exist(CurrentSaveDir)
                    mkdir(CurrentSaveDir)
                end
            end
            if any(strfind(SaveDir,'Raw'))
                warning('Currently in a Raw file directory, adjusting to next directory up...')
                CurrentSaveDir=CurrentParentDir;
                [CurrentParentDir, SaveDir] = fileparts(CurrentSaveDir);
            end
            cd(CurrentSaveDir)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Copy Raw Data if Needed
            clear LoadingInfo TempNames
            LoadingInfo.NumFiles=length(RawDataFileNames);
            if iscell(RawDataFileNames)
            elseif ischar(RawDataFileNames)
                LoadingInfo.NumFiles=1;
                TempFileName=RawDataFileNames;
                clear RawDataFileNames
                RawDataFileNames{1}=TempFileName;
            end
            if ~any(strfind(RawDataPath,'Raw'))
                warning('It does not look like we are loading files from a Raw data directory in our eventual SaveDir')
                warning('I can move those files to make sure they are included in this analysis directory')
                TempChoice = questdlg('Copy files to analysis directory?','Copy files to analysis directory?','Copy','Skip','Copy');
                if strcmp(TempChoice,'Copy')
                    CopyRaw=1;
                else
                    CopyRaw=0;
                end
                if CopyRaw
                    RawDataDir=[CurrentSaveDir,dc,'Raw',dc];
                    if ~exist(RawDataDir)
                        mkdir(RawDataDir)
                    end
                    for fileCount=1:LoadingInfo.NumFiles
                        fprintf(['Copying To RawDataDir...File # ',num2str(fileCount),'  FileName: ',RawDataFileNames{fileCount},'...']);
                        [CopyStatus,CopyMessage]=copyfile([RawDataPath,RawDataFileNames{fileCount}],[RawDataDir]);
                        if CopyStatus
                            disp('Copy successful!')
                        else
                            error(CopyMessage)
                            error('Problem Moving Files...')
                        end   
                    end
                else
                    CopyRaw=0;
                    RawDataDir=RawDataPath;
                end
            else
                CopyRaw=0;
                RawDataDir=RawDataPath;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Organize File Names
            for fileCount=1:LoadingInfo.NumFiles
                TempName=RawDataFileNames{fileCount};
                [pathstr,name,ext] = fileparts(RawDataFileNames{fileCount});
                LoadingInfo.RawDataDir=RawDataDir;
                LoadingInfo.FileExtension=ext;
                LoadingInfo.FileNames{fileCount}=TempName;
                LoadingInfo.FileIDs{fileCount}=TempName(1:length(TempName)-length(ext));
                LoadingInfo.FileIDs_Struct(fileCount).Name=LoadingInfo.FileIDs{fileCount};
                LoadingInfo.FileIDs_Struct(fileCount).Length=length(LoadingInfo.FileIDs{fileCount});
                LoadingInfo.FileIDs_Struct(fileCount).Ext=ext;
                LoadingInfo.FileIDs_Struct(fileCount).RawDataDir=RawDataDir;
            end
            if LoadingInfo.NumFiles>1
            
               SortSelection = questdlg(['Do you want to skip file sorting?'],'Skip Sorting?','Skip','Sort','Sort');
                switch SortSelection
                    case 'Skip'
                        Skip_Sort=1;
                    case 'Sort'
                        Skip_Sort=0;
                end
                if ~Skip_Sort
                    LoadingInfo.FileIDs_Struct_Sorted=nestedSortStruct(LoadingInfo.FileIDs_Struct, {'Length', 'Name'});
                    LoadingInfo.FileNames=[];
                    LoadingInfo.FileIDs=[];
                    for fileCount=1:LoadingInfo.NumFiles
                        LoadingInfo.FileNames{fileCount}=[LoadingInfo.FileIDs_Struct_Sorted(fileCount).Name,LoadingInfo.FileIDs_Struct_Sorted(fileCount).Ext];
                        LoadingInfo.FileIDs{fileCount}=LoadingInfo.FileIDs_Struct_Sorted(fileCount).Name;
                        LoadingInfo.FileIDs_Struct(fileCount).Name=LoadingInfo.FileIDs_Struct_Sorted(fileCount).Name;
                        LoadingInfo.FileIDs_Struct(fileCount).Length=LoadingInfo.FileIDs_Struct_Sorted(fileCount).Length;
                        LoadingInfo.FileIDs_Struct(fileCount).Ext=LoadingInfo.FileIDs_Struct_Sorted(fileCount).Ext;
                        LoadingInfo.FileIDs_Struct(fileCount).RawDataDir=LoadingInfo.FileIDs_Struct_Sorted(fileCount).RawDataDir;
                    end   
                    LoadingInfo=rmfield(LoadingInfo,'FileIDs_Struct_Sorted');
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Copy Raw Data To ScratchDir
            if TutorialNotes
                Instructions={'I have programmed most of the quantal analysis pipeline to utilize';...
                    'a NAS as a common data repository with all analysis being run on';...
                    'workstations that utilize faster local drives as <CurrentScratchDir> for';...
                    'reading/writing of all .mat files as well as figures and movies as I have';...
                    'found that this greatly improves data safety and analysis speed.';...
                    'This also allows efficient batch processing for the longer steps.';...
                    'I do test to make sure though that what I see as the <CurrentScratchDir>';...
                    'is not the final <CurrentSaveDir>. If this is the case I try not to';...
                    'run any copy/delete commands as that would be bad!'};
                TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
                if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
                    TutorialNotes=0;
                end
            end
            CurrentScratchDir=[ScratchDir,SaveName,dc];
            if ~exist(CurrentScratchDir)
                mkdir(CurrentScratchDir)
            end
            Safe2CopyDelete=1;
            if strcmp([CurrentSaveDir],[CurrentScratchDir])||...
                    strcmp([CurrentSaveDir,dc],[CurrentScratchDir])||...
                    strcmp([CurrentSaveDir],[CurrentScratchDir,dc])
                Safe2CopyDelete=0;
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
                warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
            end
            if Safe2CopyDelete
                for fileCount=1:LoadingInfo.NumFiles
                    fprintf(['Copying To CurrentScratchDir...File # ',num2str(fileCount),'  FileName: ',LoadingInfo.FileNames{fileCount},'...']);
                    LoadNames{fileCount}=[RawDataDir,dc,LoadingInfo.FileNames{fileCount}];
                    TempLoadNames{fileCount}=[CurrentScratchDir,dc,LoadingInfo.FileNames{fileCount}];
                    [CopyStatus,CopyMessage]=copyfile([LoadNames{fileCount}],CurrentScratchDir);
                    if CopyStatus
                        disp('Copy successful!')
                    else
                        error(CopyMessage)
                        error('Problem Moving Files to CurrentScratchDir...')
                    end               
                end
            else
                TempLoadNames=LoadNames;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Load Metadata
            if LoadingInfo.NumFiles>4
                ParallelMetaDataLoading=1;
            else
                ParallelMetaDataLoading=0;
            end
            warning off
            disp('===================================================================')
            disp('===================================================================')
            disp('===================================================================')
            disp('===================================================================')
            disp('Loading Meta Data...')
            clear AllFileMetaData
            if LoadingInfo.NumFiles>4&&ParallelMetaDataLoading
                delete(gcp('nocreate'))
                myPool=parpool;
                try
                    addAttachedFiles(myPool,{'loci_tools.jar','bioformats_package.jar','imreadBFmeta.m','imreadBFmeta_NEW.m'})
                    parfor fileCount=1:LoadingInfo.NumFiles
                        disp(['Loading Metadata...File # ',num2str(fileCount),'  FileName: ',LoadingInfo.FileNames{fileCount}]);
                        [AllFileMetaData(fileCount).FileMetaData]=imreadBFmeta_NEW([LoadingInfo.RawDataDir,LoadingInfo.FileNames{fileCount}]);
                    end
                catch
                    warning('Unable to run metadata collection in parallel...')
                    for fileCount=1:LoadingInfo.NumFiles
                        disp(['Loading Metadata...File # ',num2str(fileCount),'  FileName: ',LoadingInfo.FileNames{fileCount}]);
                        [AllFileMetaData(fileCount).FileMetaData]=imreadBFmeta_NEW([LoadingInfo.RawDataDir,LoadingInfo.FileNames{fileCount}]);
                    end
                end        
                delete(gcp('nocreate'))
            elseif LoadingInfo.NumFiles>1&&~ParallelMetaDataLoading
                warning('Multiple files and ParallelMataDataLoading is inactive, this may take a while...')
                for fileCount=1:LoadingInfo.NumFiles
                    disp(['Loading Metadata...File # ',num2str(fileCount),'  FileName: ',LoadingInfo.FileNames{fileCount}]);
                    [AllFileMetaData(fileCount).FileMetaData]=imreadBFmeta_NEW([LoadingInfo.RawDataDir,LoadingInfo.FileNames{fileCount}]);
                end
            else
                fileCount=1;
                disp(['Loading Metadata...  LoadingInfo.FileNames ',LoadingInfo.FileIDs{fileCount},LoadingInfo.FileExtension]);
                [AllFileMetaData(fileCount).FileMetaData]=imreadBFmeta_NEW([LoadingInfo.RawDataDir,LoadingInfo.FileNames{fileCount}]);
            end
            for fileCount=1:LoadingInfo.NumFiles
                LoadNames{fileCount}=[RawDataDir,dc,LoadingInfo.FileNames{fileCount}];
                TempLoadNames{fileCount}=[CurrentScratchDir,dc,LoadingInfo.FileNames{fileCount}];
            end
            LoadingInfo.LoadNames=LoadNames;
            LoadingInfo.TempLoadNames=TempLoadNames;
            warning on
            for fileCount=1:length(AllFileMetaData)
                disp('===================================================================')
                disp(['File # ',num2str(fileCount),'  FileNames: ',LoadingInfo.FileNames{fileCount}]);
                disp(['width: ',num2str(AllFileMetaData(fileCount).FileMetaData.width)]);
                disp(['height: ',num2str(AllFileMetaData(fileCount).FileMetaData.height)]);
                disp(['zsize: ',num2str(AllFileMetaData(fileCount).FileMetaData.zsize)]);
                disp(['nframes: ',num2str(AllFileMetaData(fileCount).FileMetaData.nframes)]);
                disp(['channels: ',num2str(AllFileMetaData(fileCount).FileMetaData.channels)]);
            end
            disp('===================================================================')
            disp('===================================================================')
            disp('===================================================================')
            disp('===================================================================')        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%               STAGE 0              %
%           AnalysisPart 2           %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Loading Data, Episode management
if any(AnalysisParts==2)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Sort Out Episodes
    clear ImagingInfo
    warning on
    if TutorialNotes
        Instructions={'At higher frame rates we found that the Enterprise camera had a bad first frame';...
            'Remove here by lowering FramesPerEpisode by one and adding FirstFramesToIgnore'};
        TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
        if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
            TutorialNotes=0;
        end
    end
    ImagingInfo.FramesPerEpisode=AllFileMetaData(fileCount).FileMetaData.nframes;
    ImagingInfo.FirstFramesToIgnore=0;
    ImagingInfo.LastFramesToIgnore=0;
    prompt = {['DESIRED Frames Per Episode: ']};
    dlg_title = 'Episode Info';
    num_lines = 1;
    defaultans = {num2str(ImagingInfo.FramesPerEpisode)};
    answer = inputdlgcolZN(prompt,dlg_title,num_lines,defaultans,'on',1);
    ImagingInfo.FramesPerEpisode=str2double(answer{1});
    disp(['Frames Per Episode: ',num2str(ImagingInfo.FramesPerEpisode)])
    if rem(AllFileMetaData(1).FileMetaData.nframes,ImagingInfo.FramesPerEpisode)~=0
        warning(['WAIT! Too many aquisition file frames: ' num2str(AllFileMetaData(1).FileMetaData.nframes),' for FramesPerEpisode of: ',num2str(ImagingInfo.FramesPerEpisode)]);
        warning(['(NOTE: some software will often add extra frame(s) at the beginning and end of aquisition)'])
    %     FixFramesToIgnore=InputWithVerification('<1> to fix or <ENTER to skip: ',{[],[1]},0);
    %     if FixFramesToIgnore
            goodInput=0;
            while goodInput==0
                %ImagingInfo.FirstFramesToIgnore=InputWithVerification('How many initial aquisition frames to ignore?: ',{[0:1:100000]},0);
                %ImagingInfo.LastFramesToIgnore=InputWithVerification('How many final aquisition frames to ignore?: ',{[0:1:100000]},0);
                prompt = {['Initial Aquisition Frames to Remove: '],['Final Aquisition Frames to Remove: ']};
                dlg_title = 'Fixing Frame Loading';
                num_lines = 1;
                defaultans = {num2str(ImagingInfo.FirstFramesToIgnore),num2str(ImagingInfo.LastFramesToIgnore)};
                answer = inputdlgcolZN(prompt,dlg_title,num_lines,defaultans,'on',1);
                ImagingInfo.FirstFramesToIgnore=str2double(answer{1});
                ImagingInfo.LastFramesToIgnore=str2double(answer{2});
                if rem(AllFileMetaData(1).FileMetaData.nframes,ImagingInfo.FramesPerEpisode)==ImagingInfo.FirstFramesToIgnore+ImagingInfo.LastFramesToIgnore
                    goodInput=1;
                else
                    disp('That doesnt work please try again!')
                end
            end
    %     else
    %         ImagingInfo.FirstFramesToIgnore=0;
    %         ImagingInfo.LastFramesToIgnore=0;
    %     end
    else
        ImagingInfo.FirstFramesToIgnore=0;
        ImagingInfo.LastFramesToIgnore=0;
    end
    disp(['AQUISITION FirstFramesToIgnore: ',num2str(ImagingInfo.FirstFramesToIgnore)])
    disp(['AQUISITION LastFramesToIgnore: ',num2str(ImagingInfo.LastFramesToIgnore)])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Load Raw Data
    %%%%%
    ImagingInfo.Image_Width=AllFileMetaData(1).FileMetaData.width;
    ImagingInfo.Image_Height=AllFileMetaData(1).FileMetaData.height;
    %%%%%
    ImagingInfo.TotalNumInputFrames=0;
    for fileCount=1:LoadingInfo.NumFiles
        MetaDataRecord(fileCount).AquisitionFrames2Load=[(1+ImagingInfo.FirstFramesToIgnore):(AllFileMetaData(fileCount).FileMetaData.nframes-ImagingInfo.LastFramesToIgnore)];
        MetaDataRecord(fileCount).TotalNumInputFrames=length(MetaDataRecord(fileCount).AquisitionFrames2Load);
        MetaDataRecord(fileCount).FramesPerEpisode=ImagingInfo.FramesPerEpisode;
        MetaDataRecord(fileCount).TotalNumEpisodes=MetaDataRecord(fileCount).TotalNumInputFrames/ImagingInfo.FramesPerEpisode;
        ImagingInfo.TotalNumInputFrames=ImagingInfo.TotalNumInputFrames+MetaDataRecord(fileCount).TotalNumInputFrames;
    end
    disp(['Loading: ',num2str(ImagingInfo.TotalNumInputFrames),' Frames sorted into ',num2str(MetaDataRecord(fileCount).TotalNumEpisodes),' Episodes'])
    BytesPerPixel=2; %for 16bit
    EstimatedFileSize_Byte=ImagingInfo.TotalNumInputFrames*ImagingInfo.Image_Width*ImagingInfo.Image_Height*BytesPerPixel;
    EstimatedFileSize_GB=EstimatedFileSize_Byte/1e9;
    disp(['Estimated File Size: ',num2str(EstimatedFileSize_GB),' GB'])
    try
        ImagingInfo.FileType='tif';
        TestData=tiffread(LoadingInfo.TempLoadNames{1},[1]);
        ImagingInfo.DataType=class(TestData.data);
        ImagingInfo.BitDepth=TestData.bits;
        TestImage=TestData.data;
    catch
        ImagingInfo.FileType='OMEtif';
        tif_Data = bfopen(LoadingInfo.TempLoadNames{1});
        clear OME_MetaData BasicFileData
        if iscell(tif_Data)
            TestImage=tif_Data{1}{1};
        else
            TestImage=tif_Data;
        end
        ImagingInfo.DataType=class(TestData);
        warning('REMIND ZACH to get metadata from OME')
        ImagingInfo.BitDepth=16;
        clear tif_Data
    end
    %%%%%
    TestImage=double(TestImage);
    figure, imshow(TestImage,[],'border','tight')
    disp(['BitDepth: ',num2str(ImagingInfo.BitDepth)])
    fprintf(['Reading Data into ImageArray_All_Raw...\n']);
    ImageArray_All_Raw=zeros(ImagingInfo.Image_Height,ImagingInfo.Image_Width,ImagingInfo.TotalNumInputFrames,ImagingInfo.DataType);
    FrameCount=0;
    progressbar('File #','Image #');
    for fileCount=1:LoadingInfo.NumFiles
        fprintf(['Loading data...File # ',num2str(fileCount),'...']);
        switch ImagingInfo.FileType
            case 'tif'
                %load file with tiffread
                if exist(LoadingInfo.TempLoadNames{fileCount})
                    [TempFileData]=tiffread(LoadingInfo.TempLoadNames{fileCount},MetaDataRecord(fileCount).AquisitionFrames2Load);
                else
                    warning('Loading from final locaiton')
                    [TempFileData]=tiffread(LoadingInfo.LoadNames{fileCount},MetaDataRecord(fileCount).AquisitionFrames2Load);
                end
                fprintf('Writing Data to ImageArray_All_Raw...')
                for i=1:length(TempFileData)
                    progressbar((fileCount-1)/(LoadingInfo.NumFiles),i/length(TempFileData))
                    FrameCount=FrameCount+1;
                    ImageArray_All_Raw(:,:,FrameCount)=TempFileData(i).data;
                end
                progressbar((fileCount)/(LoadingInfo.NumFiles),1)
                %Save some meta data
                MetaDataRecord(fileCount).FileNumber=fileCount;
                MetaDataRecord(fileCount).FileNames=LoadingInfo.LoadNames{fileCount};
                MetaDataRecord(fileCount).FullFileNames=TempFileData(1).filename;
                MetaDataRecord(fileCount).width=TempFileData(1).width;
                MetaDataRecord(fileCount).height=TempFileData(1).height;
                MetaDataRecord(fileCount).bits=TempFileData(1).bits;
                MetaDataRecord(fileCount).info=TempFileData(1).info;
                MetaDataRecord(fileCount).x_resolution=TempFileData(1).x_resolution;
                MetaDataRecord(fileCount).y_resolution=TempFileData(1).y_resolution;
                MetaDataRecord(fileCount).resolution_unit=TempFileData(1).resolution_unit;
                MetaDataRecord(fileCount).software=TempFileData(1).software;
                MetaDataRecord(fileCount).datetime=TempFileData(1).datetime;
                MetaDataRecord(fileCount).PixelResolution=MetaDataRecord(fileCount).x_resolution(1)*1e-7/TempFileData(1).width; %should be in um/px
                fprintf('Finished!\n')
            case 'OMEtif'
                if exist(LoadingInfo.TempLoadNames{fileCount})
                    TempFileData=imreadBF(LoadingInfo.TempLoadNames{fileCount},1,MetaDataRecord(fileCount).AquisitionFrames2Load,1);
                else
                    warning('Loading from final locaiton')
                    TempFileData=imreadBF(LoadingInfo.LoadNames{fileCount},1,MetaDataRecord(fileCount).AquisitionFrames2Load,1);
                end
                fprintf('Writing Data to ImageArray_All_Raw...')
                for i=1:size(TempFileData,3)
                    progressbar((fileCount-1)/(LoadingInfo.NumFiles),i/size(TempFileData,3))
                    FrameCount=FrameCount+1;
                    ImageArray_All_Raw(:,:,FrameCount)=TempFileData(:,:,i);
                end
                progressbar((fileCount)/(LoadingInfo.NumFiles),1)
                %Save some meta data
                MetaDataRecord(fileCount).FileNumber=fileCount;
                MetaDataRecord(fileCount).FileNames=LoadingInfo.LoadNames{fileCount};
                MetaDataRecord(fileCount).FullFileNames=LoadingInfo.LoadNames{fileCount};
                MetaDataRecord(fileCount).width=size(TempFileData,2);
                MetaDataRecord(fileCount).height=size(TempFileData,1);
                MetaDataRecord(fileCount).bits=0;
                MetaDataRecord(fileCount).info=0;
                MetaDataRecord(fileCount).x_resolution=0;
                MetaDataRecord(fileCount).y_resolution=0;
                MetaDataRecord(fileCount).resolution_unit=0;
                MetaDataRecord(fileCount).software=0;
                MetaDataRecord(fileCount).datetime=0;
                MetaDataRecord(fileCount).PixelResolution=MetaDataRecord(fileCount).x_resolution(1)*1e-7/MetaDataRecord(fileCount).width; %should be in um/px
                fprintf('Finished!\n')
        end
    end
    progressbar(1,1)
    clear TestData TempFileData
    disp('===================================================================')
    disp('===================================================================')
    disp('===================================================================')
    disp('===================================================================')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Fix Pixel Size
    DefaultPixelSize_umpx=0.1;
    DefaultFlagPixelSize_umpx=0;
    DefaultLoadLabel='Microscope';
    LabDefaults=[];
    if exist(LabDefaults)
        LoadLabDefaultsChoice = questdlg([LabDefaults,' Exist...Load: ',DefaultLoadLabel,'?'],'Load Lab Defaults?','Load','Skip','Load');
        switch LoadLabDefaultsChoice
            case 'Load'
                run(LabDefaults)
        end
    end
    if ~exist('ImagingInfo')||~isfield(ImagingInfo,'PixelSize')
        disp('=======================================================')
        disp('=======================================================')
        disp('=======================================================')
        if round(MetaDataRecord(1).PixelResolution*10000)/10000==DefaultFlagPixelSize_umpx
            for s=1:length(ScopeNotes)
                warning(ScopeNotes{s})
            end
            ImagingInfo.PixelSize=DefaultPixelSize_umpx; %um per pixel   
        else
            ImagingInfo.PixelSize=MetaDataRecord(1).PixelResolution;
        end
        warning(['Current Pixel Size = ',num2str(ImagingInfo.PixelSize),'um/px'])
    end
    prompt = {'PixelSize (um/px)'};
    def = {num2str(ImagingInfo.PixelSize)};
    answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',2);
    ImagingInfo.PixelSize=str2num(answer{1});
    clear answer
    warning(['Pixel Size = ',num2str(ImagingInfo.PixelSize),'um/px'])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Fix Display size
    ImagingInfo.DisplaySize(1)=ImagingInfo.Image_Width*2;
    ImagingInfo.DisplaySize(2)=ImagingInfo.Image_Height*2;
    if ImagingInfo.DisplaySize(2)>ScreenSize(4)-150
        ExportScalarModifier=(ScreenSize(4)-150)/ImagingInfo.DisplaySize(2);
        warning(['Adjusting Vertical ExportSize by ',num2str(ExportScalarModifier),' to fit Monitor!'])
        ImagingInfo.DisplaySize=round(ImagingInfo.DisplaySize*ExportScalarModifier);
    end
    if ImagingInfo.DisplaySize(1)>ScreenSize(3)
        ExportScalarModifier=ScreenSize(3)/ImagingInfo.DisplaySize(1);
        warning(['Adjusting Horizontal ExportSize by ',num2str(ExportScalarModifier),' to fit Monitor!'])
        ImagingInfo.DisplaySize=round(ImagingInfo.DisplaySize*ExportScalarModifier);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Remove Frames in bulk
    if TutorialNotes
        Instructions={'You can start and crop the final frames here if you know you want to exclude several episodes';...
            'Just make sure that you subtract by whole Episodes'};
        TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
        if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
            TutorialNotes=0;
        end
    end
    Answer=inputdlgcolZN('TotalNumInputFrames: ','Define TotalNumInputFrames',1,{num2str(ImagingInfo.TotalNumInputFrames)},'on',1);
    ImagingInfo.TotalNumInputFrames=str2num(Answer{1});
    disp(['TotalNumInputFrames: ',num2str(ImagingInfo.TotalNumInputFrames),' Frames'])
    while rem(ImagingInfo.TotalNumInputFrames,ImagingInfo.FramesPerEpisode)~=0
        warning('Frame Mismatch!!!')
        Answer=inputdlgcolZN('TotalNumInputFrames: ','Define TotalNumInputFrames',1,{num2str(ImagingInfo.TotalNumInputFrames)},'on',1);
        ImagingInfo.TotalNumInputFrames=str2num(Answer{1});
        disp(['TotalNumInputFrames: ',num2str(ImagingInfo.TotalNumInputFrames),' Frames'])
    end
    ImagingInfo.AllGoodFrames = [1:ImagingInfo.TotalNumInputFrames];
    ImagingInfo.NumOrigEpisodes=ImagingInfo.TotalNumInputFrames/ImagingInfo.FramesPerEpisode;
    ImagingInfo.OrigEpisodeNumbers=[1:ImagingInfo.NumOrigEpisodes];
    ImagingInfo.GoodEpisodeNumbers=[1:ImagingInfo.NumOrigEpisodes];
    if length(ImagingInfo.GoodEpisodeNumbers)>200
        ImagingInfo.AutoPlayBackInterval=0.001;
    elseif length(ImagingInfo.GoodEpisodeNumbers)>50
        ImagingInfo.AutoPlayBackInterval=0.01;
    else
        ImagingInfo.AutoPlayBackInterval=0.1;
    end
    disp('===================================================================')
    disp('===================================================================')
    disp('===================================================================')
    disp('===================================================================')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Find Peak Frame
    Test_FilterSigma_um=0.200;
    Test_FilterSize_um=2.3;
    if TutorialNotes
        Instructions={'Try out a few regions to get a nice clean DeltaF/F';...
            'That we can use to define some of the stimulus timings if needed'};
        TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
        if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
            TutorialNotes=0;
        end
    end
    SelectingTestROI=1;
    while SelectingTestROI
        close all
        Test_FilterSigma_px=Test_FilterSigma_um/ImagingInfo.PixelSize;
        Test_FilterSize_px=round(Test_FilterSize_um/ImagingInfo.PixelSize);
        if rem(Test_FilterSize_px,2)==0
            Test_FilterSize_px=Test_FilterSize_px+1;
        end
        %Test_FilterSigma_px=1;
        %Test_FilterSize_px=11;
        TempVector=[];
        if length(ImagingInfo.OrigEpisodeNumbers)>4
            ImagingInfo.TestEpisodes=5;
        elseif length(ImagingInfo.OrigEpisodeNumbers)>3
            ImagingInfo.TestEpisodes=4;
        elseif length(ImagingInfo.OrigEpisodeNumbers)>2
            ImagingInfo.TestEpisodes=3;
        elseif length(ImagingInfo.OrigEpisodeNumbers)>1
            ImagingInfo.TestEpisodes=2;
        else
            ImagingInfo.TestEpisodes=1;
        end
        figure,
        imshow(ImageArray_All_Raw(:,:,1),[],'border','tight')
        hold on
        text(10,10,'Select a test ROI to find overall DeltaF pattern','color','y','fontsize',14);
        TestROI=roipoly;
        close all
        EpisodeCount=1;
        FrameCount=1;
        ImagingInfo.TestDeltaFVectors=[];
        progressbar('ImageNumber')
        for ImageNumber=1:ImagingInfo.FramesPerEpisode*ImagingInfo.TestEpisodes
            if rem(ImageNumber,ImagingInfo.FramesPerEpisode)==1
                ImagingInfo.TestDeltaFVectors(EpisodeCount,FrameCount)=NaN;
            else
                TempImage = (double(ImageArray_All_Raw(:,:,ImageNumber))-double(ImageArray_All_Raw(:,:,1)))./double(ImageArray_All_Raw(:,:,1));
                ImagingInfo.TestDeltaFVectors(EpisodeCount,FrameCount) = mean(TempImage(TestROI));
                clear TempImage
            end
            if FrameCount<ImagingInfo.FramesPerEpisode
                FrameCount=FrameCount+1;
            else
                FrameCount=1;
                EpisodeCount=EpisodeCount+1;
            end
            progressbar(ImageNumber/(ImagingInfo.FramesPerEpisode*ImagingInfo.TestEpisodes))
        end
        figure
        hold on
        for i=1:size(ImagingInfo.TestDeltaFVectors,1)
            plot([1:ImagingInfo.FramesPerEpisode],ImagingInfo.TestDeltaFVectors(i,:),'*-')
        end
        xlabel('Episode frame #')
        ylabel('Test \DeltaF/F')
        SelectingChoice=questdlg('Move ROI?','Move ROI?','Move','Good','Good');
        switch SelectingChoice
            case 'Move'
                SelectingTestROI=1;
            case 'Good'
                SelectingTestROI=0;
        end

    end
    Answer=inputdlgcolZN('PeakFrame: ','Define PeakFrame',1,{num2str(round((ImagingInfo.FramesPerEpisode/2)))},'on',1);
    ImagingInfo.PeakFrame=str2num(Answer{1});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Episode Checking 
    warning on
    if TutorialNotes
        Instructions={'Carefully check each episode here:';...
            'You want to remove out of focus episodes';...
            'failed stimuli or moving episodes';...
            'take the time to do this carefully'};
        TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
        if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
            TutorialNotes=0;
        end
    end
    if ~isfield(ImagingInfo,'EpisodeNumbersToDelete')
        ImagingInfo.EpisodeNumbersToDelete=[];
    else
        warning(['ImagingInfo.EpisodeNumbersToDelete = ',num2str(ImagingInfo.EpisodeNumbersToDelete)])
    end
    if length(ImagingInfo.OrigEpisodeNumbers)>1
        %IMPORTANT: NEW TEST FOR BAD IMAGE SEQUENCES RIGHT AWAY perform a rough deltaF calculation and then look for obvious Episodes that have shifted during the 1s interval and use this to correct ImagingInfo.OrigEpisodeNumbers above
        warning('Checking data to remove moving or out of focus episodes...')
        %load entire dataset first for checking
        ImagingInfo.AllGoodFrames=[];
        TempNumOfEpisodes = length(ImagingInfo.OrigEpisodeNumbers); % here ImagingInfo.AllGoodFirstFrames contain the Episodes for first images in sequence
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        CountEpisode = 1;
        for EpisodeNumber=1:TempNumOfEpisodes
            ImagingInfo.AllGoodFrames(CountEpisode :(CountEpisode + ImagingInfo.FramesPerEpisode - 1)) = (((ImagingInfo.OrigEpisodeNumbers(EpisodeNumber) * ImagingInfo.FramesPerEpisode) - ImagingInfo.FramesPerEpisode + 1): (ImagingInfo.OrigEpisodeNumbers(EpisodeNumber) * ImagingInfo.FramesPerEpisode ));
            CountEpisode = CountEpisode + ImagingInfo.FramesPerEpisode;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Collect first image data
        Temp_ImagingInfo.AllGoodFirstFrames = ImagingInfo.AllGoodFrames([1:ImagingInfo.FramesPerEpisode:length(ImagingInfo.AllGoodFrames)]);
        clear Temp_ImageArray_FirstImages
        for ImageNumber=1:length(Temp_ImagingInfo.AllGoodFirstFrames)
            TempImage = ImageArray_All_Raw(:,:,Temp_ImagingInfo.AllGoodFirstFrames(ImageNumber));
            TempImage = imfilter(TempImage, fspecial('gaussian', Test_FilterSize_px, Test_FilterSigma_px));
            TempImage(find(TempImage==0)) = NaN;
            TempVector = nanmean(TempImage(:,:),1);
            TempVector = nanmean(TempVector,2);
            MeanStartingFluorescenceVector(ImageNumber)=TempVector;
            Temp_ImageArray_FirstImages(:,:, ImageNumber) = TempImage;
            clear TempImage TempVector
        end
        figure();
        hold on
        subtightplot(1,1,1), imshow(Temp_ImageArray_FirstImages(:,:,1),[],'InitialMagnification', 300);title([SaveName,' Frame 1'],'interpreter','none');
        clear TempImage;
        progressbar('Episode Number')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Peak Image
        Image1=1;
        Image2=ImagingInfo.PeakFrame;
        Temp_ImageArray_Peak_DeltaF=zeros(size(Temp_ImageArray_FirstImages));
        progressbar('Peak \DeltaF Calculation...Episode #')
        for EpisodeNumber=1:TempNumOfEpisodes
            TempImage1 = ImageArray_All_Raw(:,:,((ImagingInfo.OrigEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image1));
            TempImage2 = ImageArray_All_Raw(:,:,((ImagingInfo.OrigEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image2));
            TempImage1 = imfilter(TempImage1, fspecial('gaussian', Test_FilterSize_px, Test_FilterSigma_px));
            TempImage2 = imfilter(TempImage2, fspecial('gaussian', Test_FilterSize_px, Test_FilterSigma_px));
            Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber)=TempImage2-TempImage1;
            clear TempImage1;clear TempImage2;
            progressbar(EpisodeNumber/TempNumOfEpisodes);
        end
        for EpisodeNumber=1:TempNumOfEpisodes
            Temp_ImageArray_Peak_DeltaFMeanVector(EpisodeNumber)=mean(mean(Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber)));
            Temp_ImageArray_Peak_DeltaFMaxVector(EpisodeNumber)=max(max(Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber)));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Last Image
        Image1=1;
        Image2=ImagingInfo.FramesPerEpisode;
        Temp_ImageArray_End_DeltaF=zeros(size(Temp_ImageArray_FirstImages));
        progressbar('End \DeltaF Calculation...Episode #')
        for EpisodeNumber=1:TempNumOfEpisodes
            TempImage1 = ImageArray_All_Raw(:,:,((ImagingInfo.OrigEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image1));
            TempImage2 = ImageArray_All_Raw(:,:,((ImagingInfo.OrigEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image2));
            TempImage1 = imfilter(TempImage1, fspecial('gaussian', Test_FilterSize_px, Test_FilterSigma_px));
            TempImage2 = imfilter(TempImage2, fspecial('gaussian', Test_FilterSize_px, Test_FilterSigma_px));
            Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber)=TempImage2-TempImage1;
            clear TempImage1;clear TempImage2;
            progressbar(EpisodeNumber/TempNumOfEpisodes);
        end
        for EpisodeNumber=1:TempNumOfEpisodes
            Temp_ImageArray_End_DeltaFMeanVector(EpisodeNumber)=mean(mean(Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber)));
            Temp_ImageArray_End_DeltaFMaxVector(EpisodeNumber)=max(max(Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber)));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        warning on
        SelectingEpisodeNumbersToDelete=1;
        while SelectingEpisodeNumbersToDelete
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~isempty(ImagingInfo.EpisodeNumbersToDelete)
                warning(['ImagingInfo.EpisodeNumbersToDelete = ',num2str(ImagingInfo.EpisodeNumbersToDelete)])
                %ClearDeleteEpisodes=InputWithVerification('Enter <1> to RESET EpisodeNumbersToDelete List: ',{[],[1]},0);
                ResetChoice = questdlg('Do you want to RESET EpisodeNumbersToDelete List?','Reset?','Reset','Continue','Continue');
                switch ResetChoice
                    case 'Reset'
                        ClearDeleteEpisodes=1;
                    case 'Continue'
                        ClearDeleteEpisodes=0;
                end

                if ClearDeleteEpisodes
                    ImagingInfo.EpisodeNumbersToDelete=[];
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Check Results
            if TempNumOfEpisodes>10 
                DefaultChoice='Check';
            else
                DefaultChoice='Skip';
            end
            CheckEpisodes = questdlg('Do you want to Check episodes with a quick playback?','Check Episodes?','Check','Skip',DefaultChoice);
            if strcmp(CheckEpisodes,'Check')
                Image1=1;
                Image2=ImagingInfo.PeakFrame;
                Image3=ImagingInfo.FramesPerEpisode;
                Test_ImageArray_FirstImages=[];
                Test_ImageArray_Peak_DeltaF=[];
                Test_ImageArray_End_DeltaF=[];
                progressbar('Checking Episode #')
                count=0;
                for EpisodeNumber=1:TempNumOfEpisodes
                    if any(ImagingInfo.EpisodeNumbersToDelete==EpisodeNumber)
                    else
                        count=count+1;
                        TempImage1 = ImageArray_All_Raw(:,:,((ImagingInfo.OrigEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image1));
                        TempImage2 = ImageArray_All_Raw(:,:,((ImagingInfo.OrigEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image2));
                        TempImage3 = ImageArray_All_Raw(:,:,((ImagingInfo.OrigEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image3));
                        TempImage1 = imfilter(TempImage1, fspecial('gaussian', Test_FilterSize_px, Test_FilterSigma_px));
                        TempImage2 = imfilter(TempImage2, fspecial('gaussian', Test_FilterSize_px, Test_FilterSigma_px));
                        TempImage3 = imfilter(TempImage3, fspecial('gaussian', Test_FilterSize_px, Test_FilterSigma_px));
                        Test_ImageArray_FirstImages(:,:,count)=TempImage1;
                        Test_ImageArray_Peak_DeltaF(:,:,count)=TempImage2-TempImage1;
                        Test_ImageArray_End_DeltaF(:,:,count)=TempImage3-TempImage1;
                        clear TempImage1;clear TempImage2;clear TempImage3;
                    end
                    progressbar(EpisodeNumber/TempNumOfEpisodes);
                end
                RepeatPlayback=1;
                while RepeatPlayback
                    close all
                    AutoPlaybackNew(Test_ImageArray_FirstImages,1,ImagingInfo.AutoPlayBackInterval,[0 max(Test_ImageArray_FirstImages(:))-0.3*max(Test_ImageArray_FirstImages(:))],'jet');
                    AutoPlaybackNew(Test_ImageArray_Peak_DeltaF,1,ImagingInfo.AutoPlayBackInterval,[0 max(Test_ImageArray_Peak_DeltaF(:))-0.8*max(Test_ImageArray_Peak_DeltaF(:))],'jet');
                    AutoPlaybackNew(Test_ImageArray_End_DeltaF,1,ImagingInfo.AutoPlayBackInterval,[-0.05*max(abs(Test_ImageArray_End_DeltaF(:))) 0.05*max(abs(Test_ImageArray_End_DeltaF(:)))],'jet');
                    %RepeatPlayback=InputWithVerification('Enter <1> to Repeat Movies: ',{[],[1]},0);
                    
                    RepeatSelection = questdlg('Do you want to Repeat Playback?','Repeat?','Repeat','Continue','Continue');
                    switch RepeatSelection
                        case 'Repeat'
                            RepeatPlayback=1;
                        case 'Continue'
                            RepeatPlayback=0;
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Reset Flagging of Episodes
            clearvars -global FLAGGEDEPISODENUMBERS
            global FLAGGEDEPISODENUMBERS
            FLAGGEDEPISODENUMBERS=ImagingInfo.EpisodeNumbersToDelete;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Run Episode checker
            close all
            StatusFig=figure;
            set(gcf,'units','normalized','position',[-1 -1 0.5 0.5])
            EpisodicImageChecker1(StatusFig,FLAGGEDEPISODENUMBERS,TempNumOfEpisodes,Temp_ImageArray_FirstImages,Temp_ImageArray_Peak_DeltaF,Temp_ImageArray_End_DeltaF,MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector);
            uiwait(StatusFig);
            % Pull from EpisodicImageChecker
            ImagingInfo.EpisodeNumbersToDelete=FLAGGEDEPISODENUMBERS;
            warning(['EpisodeNumbersToDelete = ',num2str(FLAGGEDEPISODENUMBERS)])
            warning(['Total # Episodes: ',num2str(TempNumOfEpisodes),' Total # Flagged Episodes to Delete: ',num2str(length(ImagingInfo.EpisodeNumbersToDelete))])
            %DeleteFlaggedEpisodes=InputWithVerification('Enter <1> to RESET Flagged Episodes: ',{[],[1]},0);
            ResetChoice = questdlg('Do you want to RESET Flagged Episodes?','Reset?','Reset','Continue','Continue');
            switch ResetChoice
                case 'Reset'
                    DeleteFlaggedEpisodes=0;
                case 'Continue'
                    DeleteFlaggedEpisodes=1;
            end
            %%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%
            if DeleteFlaggedEpisodes
                clearvars -global FLAGGEDEPISODENUMBERS
                count=0;
                while TempNumOfEpisodes-length(ImagingInfo.EpisodeNumbersToDelete)>TempNumOfEpisodes
                    ImagingInfo.EpisodeNumbersToDelete=[ImagingInfo.EpisodeNumbersToDelete,TempNumOfEpisodes-count];
                    ImagingInfo.EpisodeNumbersToDelete=sort(unique(ImagingInfo.EpisodeNumbersToDelete));
                    count=count+1;
                end
            else
                clearvars -global FLAGGEDEPISODENUMBERS
                ImagingInfo.EpisodeNumbersToDelete=[];
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Check Results
            if TempNumOfEpisodes>10 
                DefaultChoice='Check';
            else
                DefaultChoice='Skip';
            end
            CheckEpisodes = questdlg('Do you want to Check episodes with a quick playback?','Check Episodes?','Check','Skip',DefaultChoice);
            if strcmp(CheckEpisodes,'Check')
                Image1=1;
                Image2=ImagingInfo.PeakFrame;
                Image3=ImagingInfo.FramesPerEpisode;
                Test_ImageArray_FirstImages=[];
                Test_ImageArray_Peak_DeltaF=[];
                Test_ImageArray_End_DeltaF=[];
                progressbar('Checking Episode #')
                count=0;
                for EpisodeNumber=1:TempNumOfEpisodes
                    if any(ImagingInfo.EpisodeNumbersToDelete==EpisodeNumber)
                    else
                        count=count+1;
                        TempImage1 = ImageArray_All_Raw(:,:,((ImagingInfo.OrigEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image1));
                        TempImage2 = ImageArray_All_Raw(:,:,((ImagingInfo.OrigEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image2));
                        TempImage3 = ImageArray_All_Raw(:,:,((ImagingInfo.OrigEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image3));
                        TempImage1 = imfilter(TempImage1, fspecial('gaussian', Test_FilterSize_px, Test_FilterSigma_px));
                        TempImage2 = imfilter(TempImage2, fspecial('gaussian', Test_FilterSize_px, Test_FilterSigma_px));
                        TempImage3 = imfilter(TempImage3, fspecial('gaussian', Test_FilterSize_px, Test_FilterSigma_px));
                        Test_ImageArray_FirstImages(:,:,count)=TempImage1;
                        Test_ImageArray_Peak_DeltaF(:,:,count)=TempImage2-TempImage1;
                        Test_ImageArray_End_DeltaF(:,:,count)=TempImage3-TempImage1;
                        clear TempImage1;clear TempImage2;clear TempImage3;
                    end
                    progressbar(EpisodeNumber/TempNumOfEpisodes);
                end
                RepeatPlayback=1;
                while RepeatPlayback
                    close all
                    AutoPlaybackNew(Test_ImageArray_FirstImages,1,ImagingInfo.AutoPlayBackInterval,[0 max(Test_ImageArray_FirstImages(:))-0.3*max(Test_ImageArray_FirstImages(:))],'jet');
                    AutoPlaybackNew(Test_ImageArray_Peak_DeltaF,1,ImagingInfo.AutoPlayBackInterval,[0 max(Test_ImageArray_Peak_DeltaF(:))-0.8*max(Test_ImageArray_Peak_DeltaF(:))],'jet');
                    AutoPlaybackNew(Test_ImageArray_End_DeltaF,1,ImagingInfo.AutoPlayBackInterval,[-0.05*max(abs(Test_ImageArray_End_DeltaF(:))) 0.05*max(abs(Test_ImageArray_End_DeltaF(:)))],'jet');
                    %RepeatPlayback=InputWithVerification('Enter <1> to Repeat Movies: ',{[],[1]},0);
                    
                    RepeatSelection = questdlg('Do you want to Repeat Playback?','Repeat?','Repeat','Continue','Continue');
                    switch RepeatSelection
                        case 'Repeat'
                            RepeatPlayback=1;
                        case 'Continue'
                            RepeatPlayback=0;
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %SelectingEpisodeNumbersToDelete=InputWithVerification('Enter <1> to Repeat Flagging: ',{[],[1]},0);
            RepeatSelection = questdlg('Do you want to Repeat Episode Flagging?','Repeat?','Repeat','Continue','Continue');
            switch RepeatSelection
                case 'Repeat'
                    SelectingEpisodeNumbersToDelete=1;
                case 'Continue'
                    SelectingEpisodeNumbersToDelete=0;
            end
            
            clear Test_ImageArray_FirstImages Test_ImageArray_Peak_DeltaF Test_ImageArray_End_DeltaF
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        clear Temp_ImageArray_FirstImages Temp_ImageArray_Peak_DeltaF Temp_ImageArray_End_DeltaF Temp_ImageArray_Peak_DeltaFMaxVector Temp_ImageArray_End_DeltaFMaxVector Temp_ImageArray_End_DeltaFMeanVector Temp_ImageArray_Peak_DeltaFMeanVector MeanStartingFluorescenceVector
    else
        warning('Skipping Episode Checking Because Only One Episode')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Remove any bad Episode numbers here
    ImagingInfo.OrigEpisodeNumbers = [1:ImagingInfo.TotalNumInputFrames/ImagingInfo.FramesPerEpisode];
    warning(['Deleting ',num2str(length(ImagingInfo.EpisodeNumbersToDelete)),' Episodes']);
    [NewImagingInfo.GoodEpisodeNumbers]=BadIndexFinder(ImagingInfo.EpisodeNumbersToDelete,ImagingInfo.GoodEpisodeNumbers);
    ImagingInfo.GoodEpisodeNumbers=NewImagingInfo.GoodEpisodeNumbers;
    ImagingInfo.NumEpisodes = length(ImagingInfo.GoodEpisodeNumbers);
    warning(['GoodEpisodeNumbers = ',num2str(ImagingInfo.GoodEpisodeNumbers)]);
    ImagingInfo.AllGoodFrames=[];
    CountEpisode = 1;
    for EpisodeNumber=1:length(ImagingInfo.GoodEpisodeNumbers)
        ImagingInfo.AllGoodFrames(CountEpisode :(CountEpisode + ImagingInfo.FramesPerEpisode - 1)) = (((ImagingInfo.GoodEpisodeNumbers(EpisodeNumber) * ImagingInfo.FramesPerEpisode) - ImagingInfo.FramesPerEpisode + 1): (ImagingInfo.GoodEpisodeNumbers(EpisodeNumber) * ImagingInfo.FramesPerEpisode ));
        CountEpisode = CountEpisode + ImagingInfo.FramesPerEpisode;
    end
    % Choosing to read only first image of each sequence
    ImagingInfo.AllGoodFirstFrames = ImagingInfo.AllGoodFrames([1:ImagingInfo.FramesPerEpisode:length(ImagingInfo.AllGoodFrames)]);
    ImagingInfo.TotalNumFrames=length(ImagingInfo.AllGoodFrames);
    ImagingInfo.NumEpisodes=length(ImagingInfo.GoodEpisodeNumbers);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
if ImagingInfo.NumEpisodes*ImagingInfo.FramesPerEpisode~=ImagingInfo.TotalNumFrames
    error('Frame and episode number mismatch please fix!')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%               STAGE 0              %
%           AnalysisPart 3           %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Protocol Setup
if any(AnalysisParts==3)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Some Basic Defaults for below
    for zzzzzzz=1:1

    ImagingInfo.ModalitySuffix=['_Mini'];
    ImagingInfo.ImagingFrequency=0; %in FPS
    ImagingInfo.ImagingExposureTime=0; %in ms
    ImagingInfo.InterEpisodeFrequency=NaN; %in Hz
    ImagingInfo.StimuliPerEpisode=NaN;
    ImagingInfo.FramesPerStimulus=NaN;
    ImagingInfo.IntraEpisode_StimulusFrequency=NaN; %in Hz
    ImagingInfo.IntraEpisode_StimuliFrames=[];
    ImagingInfo.IntraEpisode_Evoked_ActiveFrames=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RegistrationSettings.FlipLR=0;
    RegistrationSettings.FlipUD=0;
    RegistrationSettings.RotateAngle=0;
    RegistrationSettings.RotateMethod='bilinear';
    RegistrationSettings.FilterSigma_um=0.180;
    RegistrationSettings.FilterSize_um=2;
    RegistrationSettings.FilterSigma_px=RegistrationSettings.FilterSigma_um/ImagingInfo.PixelSize;
    RegistrationSettings.FilterSize_px=ceil(RegistrationSettings.FilterSize_um/ImagingInfo.PixelSize);
    if rem(RegistrationSettings.FilterSize_px,2)==0
        RegistrationSettings.FilterSize_px=RegistrationSettings.FilterSize_px+1;
    end

    %RegistrationSettings.FilterSigma_px=0.8;
    %RegistrationSettings.FilterSize_px=9;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RegistrationSettings.RegisterToReference=0;
    RegistrationSettings.Reference.FileName=[];
    RegistrationSettings.Reference.Dir=[];
    RegistrationSettings.Reference.SaveName=[];
    RegistrationSettings.Reference.ImageSetSaveName=[];
    RegistrationSettings.Reference.RegistrationSettings=[];
    RegistrationSettings.Reference.ImagingInfo=[];
    RegistrationSettings.ReferenceImageMethod=1;
    RegistrationSettings.ReferenceImageNumbers=[1];
    RegistrationSettings.RegistrationClass=2;
    RegistrationSettings.RegistrationMethod=3;
    RegistrationSettings.CoarseReg_MinCorrValue = 0.5; %will discard an image that has low correlation to next image in stack. Not using for now...
    RegistrationSettings.CoarseReg_MaxShiftX_um = 10; % max allowed  shift
    RegistrationSettings.CoarseReg_MaxShiftY_um = 10;
    RegistrationSettings.CoarseReg_MaxShiftX=ceil(RegistrationSettings.CoarseReg_MaxShiftX_um/ImagingInfo.PixelSize);
    RegistrationSettings.CoarseReg_MaxShiftY=ceil(RegistrationSettings.CoarseReg_MaxShiftY_um/ImagingInfo.PixelSize);
    %RegistrationSettings.CoarseReg_MaxShiftX = 50; % max allowed pixel shift
    %RegistrationSettings.CoarseReg_MaxShiftY = 50;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RegistrationSettings.BaselineOption=1;
    RegistrationSettings.BaselineNumFrames=1;
    RegistrationSettings.BaselineFrames=[1];
    RegistrationSettings.BaselineNumBlocks=1;
    RegistrationSettings.BleachCorr_Option=3;
    RegistrationSettings.BleachCorr_Outliers=[];

    %MODALITY CHOICE Defaults
    clear ModalityChoices
    m=0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    m=m+1;
    ModalityChoices(m).Type=NaN;
    ModalityChoices(m).Option='Import from file';
    ModalityChoices(m).ImagingInfo=[];
    ModalityChoices(m).RegistrationSettings=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    m=m+1;
    ModalityChoices(m).Type=NaN;
    ModalityChoices(m).Option='Define Parameters';
    ModalityChoices(m).ImagingInfo.ModalitySuffix=ImagingInfo.ModalitySuffix;
    ModalityChoices(m).ImagingInfo.ImagingFrequency=ImagingInfo.ImagingFrequency; %in Hz
    ModalityChoices(m).ImagingInfo.ImagingExposureTime=ImagingInfo.ImagingExposureTime; %in ms
    ModalityChoices(m).ImagingInfo.InterEpisodeFrequency=ImagingInfo.InterEpisodeFrequency;
    ModalityChoices(m).ImagingInfo.StimuliPerEpisode=ImagingInfo.StimuliPerEpisode;
    ModalityChoices(m).ImagingInfo.FramesPerStimulus=ImagingInfo.FramesPerStimulus;
    ModalityChoices(m).ImagingInfo.IntraEpisode_StimulusFrequency=ImagingInfo.IntraEpisode_StimulusFrequency; %in Hz
    ModalityChoices(m).ImagingInfo.IntraEpisode_StimuliFrames=ImagingInfo.IntraEpisode_StimuliFrames;
    ModalityChoices(m).ImagingInfo.IntraEpisode_Evoked_ActiveFrames=ImagingInfo.IntraEpisode_Evoked_ActiveFrames;
    ModalityChoices(m).RegistrationSettings.ReferenceImageMethod=RegistrationSettings.ReferenceImageMethod;
    ModalityChoices(m).RegistrationSettings.ReferenceImageNumbers=RegistrationSettings.ReferenceImageNumbers;
    ModalityChoices(m).RegistrationSettings.RegistrationClass=RegistrationSettings.RegistrationClass;
    ModalityChoices(m).RegistrationSettings.RegistrationMethod=RegistrationSettings.RegistrationMethod;
    ModalityChoices(m).RegistrationSettings.BaselineOption=RegistrationSettings.BaselineOption;
    ModalityChoices(m).RegistrationSettings.BaselineNumFrames=RegistrationSettings.BaselineNumFrames;
    ModalityChoices(m).RegistrationSettings.BaselineFrames=RegistrationSettings.BaselineFrames;
    ModalityChoices(m).RegistrationSettings.BaselineNumBlocks=RegistrationSettings.BaselineNumBlocks;
    ModalityChoices(m).RegistrationSettings.BleachCorr_Option=RegistrationSettings.BleachCorr_Option;
    ModalityChoices(m).RegistrationSettings.BleachCorr_Outliers=RegistrationSettings.BleachCorr_Outliers;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %A bunch of input needed here to set up analysis properly
    GatheringUserInput=1;
    while GatheringUserInput
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist('ImageArray')
    else
        ImageArray=zeros(ImagingInfo.Image_Height,ImagingInfo.Image_Width,length(ImagingInfo.AllGoodFrames),ImagingInfo.DataType);
        progressbar('ImageNumber')
        for ImageNumber=1:length(ImagingInfo.AllGoodFrames)
            progressbar(ImageNumber/length(ImagingInfo.AllGoodFrames))
            TempImage = ImageArray_All_Raw(:,:,ImagingInfo.AllGoodFrames(ImageNumber));
            ImageArray(:,:, ImageNumber) = TempImage;
            clear TempImage
        end
        %PlayBackAllFrames=InputWithVerification('Enter <1> to Play ALL FRAMES: ',{[],[1]},0);
        PlayBackChoice = questdlg('Do you want to Play ALL FRAMES?','Playback?','Play','Skip','Skip');
        switch PlayBackChoice
            case 'Play'
                PlayBackAllFrames=1;
            case 'Skip'
                PlayBackAllFrames=0;
        end
        if PlayBackAllFrames
            AutoPlaybackNew(ImageArray,1,ImagingInfo.AutoPlayBackInterval,[0 max(ImageArray(:))-0.3*max(ImageArray(:))],'jet');
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    run('Quantal_Analysis_Protocol_Input.m')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Collect ImageArray_FirstImages
    ImageArray_FirstImages=[];
    for ImageNumber=1:length(ImagingInfo.AllGoodFirstFrames)
        TempImage = ImageArray_All_Raw(:,:,ImagingInfo.AllGoodFirstFrames(ImageNumber));
        TempImage=imfilter(TempImage, fspecial('gaussian', RegistrationSettings.FilterSize_px, RegistrationSettings.FilterSigma_px));
        if RegistrationSettings.FlipLR
            TempImage=fliplr(TempImage);
        end
        if RegistrationSettings.FlipUD
            TempImage=flipud(TempImage);
        end
        if RegistrationSettings.RotateAngle~=0
            TempImage=imrotate(TempImage,RegistrationSettings.RotateAngle,RegistrationSettings.RotateMethod);
        end
        ImageArray_FirstImages(:,:, ImageNumber) = TempImage;
        clear TempImage
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Check Data
        Image1=1;
        Image2=ImagingInfo.FramesPerEpisode;
        ImageArray_End_DeltaF=zeros(size(ImageArray_FirstImages));
        progressbar('End \DeltaF Calculation...Episode #')
        for EpisodeNumber=1:length(ImagingInfo.GoodEpisodeNumbers)
            TempImage1 = ImageArray_All_Raw(:,:,((ImagingInfo.GoodEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image1));
            TempImage2 = ImageArray_All_Raw(:,:,((ImagingInfo.GoodEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image2));
            TempImage1 = double(imfilter(TempImage1, fspecial('gaussian', RegistrationSettings.FilterSize_px, RegistrationSettings.FilterSigma_px)));
            TempImage2 = double(imfilter(TempImage2, fspecial('gaussian', RegistrationSettings.FilterSize_px, RegistrationSettings.FilterSigma_px)));

            if RegistrationSettings.FlipLR
                TempImage1=fliplr(TempImage1);
            end
            if RegistrationSettings.FlipUD
                TempImage1=flipud(TempImage1);
            end
            if RegistrationSettings.RotateAngle~=0
                TempImage1=imrotate(TempImage1,RegistrationSettings.RotateAngle,RegistrationSettings.RotateMethod);
            end
            if RegistrationSettings.FlipLR
                TempImage2=fliplr(TempImage2);
            end
            if RegistrationSettings.FlipUD
                TempImage2=flipud(TempImage2);
            end
            if RegistrationSettings.RotateAngle~=0
                TempImage2=imrotate(TempImage2,RegistrationSettings.RotateAngle,RegistrationSettings.RotateMethod);
            end
            TempImage=TempImage2-TempImage1;
            ImageArray_End_DeltaF(:,:,EpisodeNumber)=TempImage;
            clear TempImage1 TempImage2 TempImage
            progressbar(EpisodeNumber/length(ImagingInfo.GoodEpisodeNumbers));
        end
        %Peak Image
        Image1=1;
        Image2=ImagingInfo.PeakFrame;
        ImageArray_Peak_DeltaF=zeros(size(ImageArray_FirstImages));
        progressbar('Peak \DeltaF Calculation...Episode #')
        for EpisodeNumber=1:length(ImagingInfo.GoodEpisodeNumbers)
            TempImage1 = ImageArray_All_Raw(:,:,((ImagingInfo.GoodEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image1));
            TempImage2 = ImageArray_All_Raw(:,:,((ImagingInfo.GoodEpisodeNumbers(EpisodeNumber)-1)*ImagingInfo.FramesPerEpisode+Image2));
            TempImage1 = double(imfilter(TempImage1, fspecial('gaussian', RegistrationSettings.FilterSize_px, RegistrationSettings.FilterSigma_px)));
            TempImage2 = double(imfilter(TempImage2, fspecial('gaussian', RegistrationSettings.FilterSize_px, RegistrationSettings.FilterSigma_px)));
            if RegistrationSettings.FlipLR
                TempImage1=fliplr(TempImage1);
            end
            if RegistrationSettings.FlipUD
                TempImage1=flipud(TempImage1);
            end
            if RegistrationSettings.RotateAngle~=0
                TempImage1=imrotate(TempImage1,RegistrationSettings.RotateAngle,RegistrationSettings.RotateMethod);
            end
            if RegistrationSettings.FlipLR
                TempImage2=fliplr(TempImage2);
            end
            if RegistrationSettings.FlipUD
                TempImage2=flipud(TempImage2);
            end
            if RegistrationSettings.RotateAngle~=0
                TempImage2=imrotate(TempImage2,RegistrationSettings.RotateAngle,RegistrationSettings.RotateMethod);
            end

            TempImage=TempImage2-TempImage1;
            ImageArray_Peak_DeltaF(:,:,EpisodeNumber)=TempImage;
            clear TempImage1 TempImage2 TempImage
            progressbar(EpisodeNumber/length(ImagingInfo.GoodEpisodeNumbers));
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Check and rough align ImageArray_FirstImages
    if length(ImagingInfo.GoodEpisodeNumbers)>1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if length(ImagingInfo.GoodEpisodeNumbers)>10 
            DefaultChoice='Check';
        else
            DefaultChoice='Skip';
        end
        CheckEpisodes = questdlg('Do you want to Check episodes with a quick playback?','Check Episodes?','Check','Skip',DefaultChoice);
        if strcmp(CheckEpisodes,'Check')
            RepeatPlayback=1;
            while RepeatPlayback
                close all
                AutoPlaybackNew(ImageArray_FirstImages,1,ImagingInfo.AutoPlayBackInterval,[0 MaxStack(ImageArray_FirstImages)-0.3*MaxStack(ImageArray_FirstImages)],'jet');
                AutoPlaybackNew(ImageArray_Peak_DeltaF,1,ImagingInfo.AutoPlayBackInterval,[0 MaxStack(ImageArray_Peak_DeltaF)-0.8*MaxStack(ImageArray_Peak_DeltaF)],'jet');
                AutoPlaybackNew(ImageArray_End_DeltaF,1,ImagingInfo.AutoPlayBackInterval,[MaxStack(ImageArray_End_DeltaF)*-0.1 MaxStack(ImageArray_End_DeltaF)*0.2],'jet');
                %RepeatPlayback=InputWithVerification('Enter <1> to Repeat Movies: ',{[],[1]},0);
                RepeatSelection = questdlg('Do you want to Repeat Playback?','Repeat?','Repeat','Continue','Continue');
                switch RepeatSelection
                    case 'Repeat'
                        RepeatPlayback=1;
                    case 'Continue'
                        RepeatPlayback=0;
                end

            end
        end    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % choose a region for alignment
        if RegistrationSettings.RegisterToReference
            CheckAlignChoice = questdlg('Reset Align Region for Coarse Reg?','Reset Align Region?','Reset','Skip','Reset');
            if strcmp(CheckAlignChoice,'Reset')
                CheckAlignRegion=1;
            else
                CheckAlignRegion=0;
            end
        else
            CheckAlignRegion=1;
        end
        if CheckAlignRegion==1
            disp('Just choose a rough selection around the NMJ...')
            figure, imshow(ImageArray_FirstImages(:,:,1),[], 'InitialMagnification', 300);
            hold on; text(10, 10, 'Select Alignment Region','color','y','FontSize',12'); hold off;
            RegistrationSettings.AlignRegion = roipoly;
            close; pause(0.01);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Align all images one to the other
        fprintf('Temporary Coarse Aligning...');
        [ImageArrayReg_FirstImages, RegistrationSettings.DeltaX_Coarse, RegistrationSettings.DeltaY_Coarse, RegistrationSettings.MaxValue_First] = ...
            LapseReg_XY(ImageArray_FirstImages, RegistrationSettings.AlignRegion,...
            RegistrationSettings.CoarseReg_MaxShiftX, RegistrationSettings.CoarseReg_MaxShiftY, RegistrationSettings.CoarseReg_MinCorrValue); % not using RegistrationSettings.CoarseReg_MinCorrValue for now
        disp('Finished!');
        clear ImageArray_Temp Temp_FirstEpisode tempFig 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % checking
        Perim1 = bwperim(RegistrationSettings.AlignRegion);
        TempOverallMax=max(ImageArrayReg_FirstImages(:));
        ImageArray_Temp=ImageArrayReg_FirstImages;
        for ImageNumber = 1:size(ImageArrayReg_FirstImages, 3)
            TempImage = ImageArrayReg_FirstImages(:,:,ImageNumber);
            TempImage(Perim1==1) = TempOverallMax;
            ImageArray_Temp(:,:,ImageNumber) = TempImage;
        end
        ImageArray_Temp(isnan(ImageArray_Temp))=0;
        %autoplayback
        AutoPlaybackNew(ImageArray_Temp,1,ImagingInfo.AutoPlayBackInterval,[0 max(ImageArray_Temp(:))-0.2*max(ImageArray_Temp(:))],'jet');
        clear ImageArray_Temp 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        ImageArrayReg_FirstImages=ImageArray_FirstImages;
        RegistrationSettings.DeltaX_Coarse=0;
        RegistrationSettings.DeltaY_Coarse=0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %When Satisfied with Setup Collect All Data Into ImageArray
    clear ImageArray
    ImageArray=zeros(ImagingInfo.Image_Height,ImagingInfo.Image_Width,length(ImagingInfo.AllGoodFrames),ImagingInfo.DataType);
    progressbar('Collecting and Adjusting All data into ImageArray || ImageNumber')
    for ImageNumber=1:length(ImagingInfo.AllGoodFrames)
        progressbar(ImageNumber/length(ImagingInfo.AllGoodFrames))
        TempImage = ImageArray_All_Raw(:,:,ImagingInfo.AllGoodFrames(ImageNumber));
        TempImage=imfilter(TempImage, fspecial('gaussian', RegistrationSettings.FilterSize_px, RegistrationSettings.FilterSigma_px));
        if RegistrationSettings.FlipLR
            TempImage=fliplr(TempImage);
        end
        if RegistrationSettings.FlipUD
            TempImage=flipud(TempImage);
        end
        if RegistrationSettings.RotateAngle~=0
            TempImage=imrotate(TempImage,RegistrationSettings.RotateAngle,RegistrationSettings.RotateMethod);
        end
        ImageArray(:,:, ImageNumber) = TempImage;
        clear TempImage
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %GatheringUserInput=InputWithVerification(['<1> to Repeat Setting Input: '],{[],[1]},0);
    
    RepeatSelection = questdlg('Do you want to Repeat Setting up Protocol specific parameters?','Repeat?','Repeat','Continue','Continue');
    switch RepeatSelection
        case 'Repeat'
            GatheringUserInput=1;
        case 'Continue'
            GatheringUserInput=0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%               STAGE 0              %
%           AnalysisPart 4           %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Select Bouton Regions
if any(AnalysisParts==4)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Select Bouton Regions Crop and Scalebars
    BorderColor_Ib=[0,0.648, 0.746];
    BorderColor_Is=[1,0.5,0];
    PlotColor_Ib=BorderColor_Ib;
    PlotColor_Is=BorderColor_Is;
    BorderThickness=0.5;    
    UseBorderLine=1;
    dilateSize = 3.5; %Used for auto selection can be adjusted in UI
    min_pixels = 20; %Used for auto selection can be adjusted in UI
    fudgeFactor = 0.95; %Used for auto selection can be adjusted in UI
    DilateRegionSize=1;  %Used for Borderline generation
    if DilateRegionSize>0
        DilateRegion=ones(DilateRegionSize);
    else
        DilateRegion=[];
    end
    AutoCropBuffer=2;
    DefaultScalebarLength_um=10;
    DefaultScaleBarLineWidth=2;
    DefaultScaleBarPixelWidth=5;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~RegistrationSettings.RegisterToReference
        if ~exist('BoutonArray')
            BoutonCount=1;
            BoutonArray(BoutonCount).Label='Ib';
            BoutonArray(BoutonCount).BoutonSuffix='_Ib';
            BoutonArray(BoutonCount).Color=BorderColor_Ib;
            BoutonArray(BoutonCount).AllBoutonsRegion_Orig=zeros(ImagingInfo.Image_Height,ImagingInfo.Image_Width,'logical');
            BoutonArray(BoutonCount).AllBoutonsRegionPerim_Orig=zeros(ImagingInfo.Image_Height,ImagingInfo.Image_Width,'logical');
            BoutonArray(BoutonCount).BorderLine_Orig=[];
            BoutonArray(BoutonCount).BorderLine=[];
            BoutonArray(BoutonCount).Crop_Region=[];
            BoutonArray(BoutonCount).Crop_Props=[];
            BoutonArray(BoutonCount).Crop_XCoords=[];
            BoutonArray(BoutonCount).Crop_YCoords=[];
            BoutonArray(BoutonCount).ReferenceImage=[];
            BoutonArray(BoutonCount).AllBoutonsRegion=[];
            BoutonArray(BoutonCount).AllBoutonsRegionPerim=[];
            BoutonArray(BoutonCount).BorderLine=[];
            BoutonArray(BoutonCount).ScaleBar=[];
            BoutonCount=2;
            BoutonArray(BoutonCount).Label='Is';
            BoutonArray(BoutonCount).BoutonSuffix='_Is';
            BoutonArray(BoutonCount).Color=BorderColor_Is;
            BoutonArray(BoutonCount).AllBoutonsRegion_Orig=zeros(ImagingInfo.Image_Height,ImagingInfo.Image_Width,'logical');
            BoutonArray(BoutonCount).AllBoutonsRegionPerim_Orig=zeros(ImagingInfo.Image_Height,ImagingInfo.Image_Width,'logical');
            BoutonArray(BoutonCount).BorderLine_Orig=[];
            BoutonArray(BoutonCount).BorderLine=[];
            BoutonArray(BoutonCount).Crop_Region=[];
            BoutonArray(BoutonCount).Crop_Props=[];
            BoutonArray(BoutonCount).Crop_XCoords=[];
            BoutonArray(BoutonCount).Crop_YCoords=[];
            BoutonArray(BoutonCount).ReferenceImage=[];
            BoutonArray(BoutonCount).AllBoutonsRegion=[];
            BoutonArray(BoutonCount).AllBoutonsRegionPerim=[];
            BoutonArray(BoutonCount).BorderLine=[];
            BoutonArray(BoutonCount).ScaleBar=[];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for BoutonCount=1:length(BoutonArray)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            close all
            figure
            imshow(RegistrationSettings.OverallReferenceImage,[],'Border','tight')
            hold on
            for Bouton=1:length(BoutonArray)
                for j=1:length(BoutonArray(Bouton).BorderLine_Orig)
                    if Bouton==BoutonCount
                        plot(BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,2),...
                            BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,1),...
                            '-','color',BoutonArray(Bouton).Color,'linewidth',2)
                    else
                        plot(BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,2),...
                            BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,1),...
                            '-','color',BoutonArray(Bouton).Color,'linewidth',0.5)
                    end
                end
            end
            set(gcf,'position',[0 50 ImagingInfo.DisplaySize])
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            MaskBoutonType = questdlg({'Perform or REPerform Area Masking for:';BoutonArray(BoutonCount).Label},['Area Masking for ',BoutonArray(BoutonCount).Label],'Mask','Skip','Mask');
            switch MaskBoutonType
                case 'Mask'
                    SkipMasking=0;
                case 'Skip'
                    SkipMasking=1;
            end
            if ~SkipMasking
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                ROISelecting=1;
                while ROISelecting
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %AllBoutonsRegion Selection
                    clearvars -global ALLBOUTONSREGION1
                    global ALLBOUTONSREGION1
                    close all
                    ALLBOUTONSREGION1=logical(zeros(size(RegistrationSettings.OverallReferenceImage)));
                    StatusFig=figure;
                    set(gcf,'units','normalized','position',[-100 -100 0.5 0.5])
                    NMJ_Region_Selector(StatusFig,SaveName,RegistrationSettings.OverallReferenceImage,...
                        dilateSize, min_pixels, fudgeFactor,ImageArray_Peak_DeltaF, ImagingInfo.FramesPerEpisode,...
                        ImagingInfo.PeakFrame, RegistrationSettings.DeltaX_Coarse, RegistrationSettings.DeltaY_Coarse, BoutonArray(BoutonCount).AllBoutonsRegion_Orig)
                    cont=input(['Perform Area Masking for ',BoutonArray(BoutonCount).Label,'in GUI, exit and press <ENTER> when finished: ']);
                    %When Satisfied with Region
                    if exist('StatusFig')
                        close(StatusFig)
                        uiresume
                    end
                    BoutonArray(BoutonCount).AllBoutonsRegion_Orig=ALLBOUTONSREGION1;
                    Contrast=[min(min(RegistrationSettings.OverallReferenceImage)) max(max(RegistrationSettings.OverallReferenceImage))*0.75];
                    BoutonArray(BoutonCount).AllBoutonsRegionPerim_Orig = bwperim(BoutonArray(BoutonCount).AllBoutonsRegion_Orig);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %When Satisfied with Region
                    [TempBorderLine]=FindROIBorders(ALLBOUTONSREGION1,DilateRegion);

                    figure
                    imshow(RegistrationSettings.OverallReferenceImage,[],'Border','tight')
                    hold on
                    for Bouton=1:length(BoutonArray)
                        for j=1:length(BoutonArray(Bouton).BorderLine_Orig)
                            if Bouton==BoutonCount
                                plot(BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,2),...
                                    BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,1),...
                                    '-','color',BoutonArray(Bouton).Color,'linewidth',2)
                            else
                                plot(BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,2),...
                                    BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,1),...
                                    '-','color',BoutonArray(Bouton).Color,'linewidth',0.5)
                            end
                        end
                    end
                    for j=1:length(TempBorderLine)
                        plot(TempBorderLine{j}.BorderLine(:,2),...
                            TempBorderLine{j}.BorderLine(:,1),...
                            '-','color','r','linewidth',2)
                    end
                    set(gcf,'position',[0 50 ImagingInfo.DisplaySize])
                    %ROISelecting=InputWithVerification(['Enter <1> to Repeat ',BoutonArray(BoutonCount).Label,' masking: '],{1,[]},0);
                    
                    RepeatSelection = questdlg(['Do you want to Repeat ',BoutonArray(BoutonCount).Label,' masking?'],'Repeat?','Repeat','Continue','Continue');
                    switch RepeatSelection
                        case 'Repeat'
                            ROISelecting=1;
                        case 'Continue'
                            ROISelecting=0;
                    end
                    

                    if ROISelecting
                        BoutonArray(BoutonCount).AllBoutonsRegion_Orig=zeros(ImagingInfo.Image_Height,ImagingInfo.Image_Width,'logical');
                        BoutonArray(BoutonCount).AllBoutonsRegionPerim_Orig=zeros(ImagingInfo.Image_Height,ImagingInfo.Image_Width,'logical');
                        BoutonArray(BoutonCount).BorderLine_Orig=[];
                    else
                        BoutonArray(BoutonCount).BorderLine_Orig=TempBorderLine;
                    end
                    clear TempBorderLine
                    close all
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                BoutonArray(BoutonCount).SubBoutonArray=[];
                %SubBoutonSelecting=InputWithVerification(['Enter <1> to select Registration Sub Bouton Regions ',BoutonArray(BoutonCount).Label,': '],{1,[]},0);
                AnalysisSelection = questdlg(['Do you want to select Registration Sub Bouton Regions ',BoutonArray(BoutonCount).Label,' NOT CURRENTLY NEEDED'],'Sub Bouton Regions?','Select','Skip','Skip');
                switch AnalysisSelection
                    case 'Select'
                        SubBoutonSelecting=1;
                    case 'Skip'
                        SubBoutonSelecting=0;
                end
                while SubBoutonSelecting
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    error('Fix here!')




                    RepeatSelection = questdlg(['Do you want to Repeat ',BoutonArray(BoutonCount).Label,' Sub Region Selection?'],'Repeat?','Repeat','Continue','Continue');
                    switch RepeatSelection
                        case 'Repeat'
                            SubBoutonSelecting=1;
                        case 'Continue'
                            SubBoutonSelecting=0;
                    end

                    if SubBoutonSelecting
                        BoutonArray(BoutonCount).SubBoutonArray=[];
                    else
                        BoutonArray(BoutonCount).SubBoutonArray=SubBoutonArray;
                    end
                    clear TempBorderLine
                    close all
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Define Crop Region
                CropSelecting=1;
                while CropSelecting
                    BoutonArray(BoutonCount).AllBoutonsRegion_Orig=logical(BoutonArray(BoutonCount).AllBoutonsRegion_Orig);
                    figure
                    imshow(RegistrationSettings.OverallReferenceImage,[],'Border','tight')
                    hold on
                    for Bouton=1:length(BoutonArray)
                        for j=1:length(BoutonArray(Bouton).BorderLine_Orig)
                            if Bouton==BoutonCount
                                plot(BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,2),...
                                    BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,1),...
                                    '-','color',BoutonArray(Bouton).Color,'linewidth',2)
                            else
                                plot(BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,2),...
                                    BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,1),...
                                    '-','color',BoutonArray(Bouton).Color,'linewidth',0.5)
                            end
                        end
                    end
                    set(gcf,'position',[0 50 ImagingInfo.DisplaySize])
                    hold on
                    text(10, 10, ['Auto Crop Box ',BoutonArray(BoutonCount).Label,' Region, Enter 1 to Manual Select'],'color','y','FontSize',12');
                    BoutonArray(BoutonCount).Crop_Props = regionprops(double(BoutonArray(BoutonCount).AllBoutonsRegion_Orig), 'BoundingBox');
                    BoutonArray(BoutonCount).Crop_Props.BoundingBox(1)=round(BoutonArray(BoutonCount).Crop_Props.BoundingBox(1))-AutoCropBuffer;
                    BoutonArray(BoutonCount).Crop_Props.BoundingBox(2)=round(BoutonArray(BoutonCount).Crop_Props.BoundingBox(2))-AutoCropBuffer;
                    BoutonArray(BoutonCount).Crop_Props.BoundingBox(3)=round(BoutonArray(BoutonCount).Crop_Props.BoundingBox(3))+AutoCropBuffer*2;
                    BoutonArray(BoutonCount).Crop_Props.BoundingBox(4)=round(BoutonArray(BoutonCount).Crop_Props.BoundingBox(4))+AutoCropBuffer*2;
                    BoutonArray(BoutonCount).Crop_Region=zeros(size(BoutonArray(BoutonCount).AllBoutonsRegion_Orig));
                    BoutonArray(BoutonCount).Crop_Region(floor(BoutonArray(BoutonCount).Crop_Props.BoundingBox(2)):1:floor(BoutonArray(BoutonCount).Crop_Props.BoundingBox(2))+floor(BoutonArray(BoutonCount).Crop_Props.BoundingBox(4)),floor(BoutonArray(BoutonCount).Crop_Props.BoundingBox(1)):1:floor(BoutonArray(BoutonCount).Crop_Props.BoundingBox(1))+floor(BoutonArray(BoutonCount).Crop_Props.BoundingBox(3)))=1;
                    hold on
                    plot([BoutonArray(BoutonCount).Crop_Props.BoundingBox(1),BoutonArray(BoutonCount).Crop_Props.BoundingBox(1)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(3)],[BoutonArray(BoutonCount).Crop_Props.BoundingBox(2),BoutonArray(BoutonCount).Crop_Props.BoundingBox(2)],'-','color','y','LineWidth',3);plot([BoutonArray(BoutonCount).Crop_Props.BoundingBox(1),BoutonArray(BoutonCount).Crop_Props.BoundingBox(1)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(3)],[BoutonArray(BoutonCount).Crop_Props.BoundingBox(2)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(4),BoutonArray(BoutonCount).Crop_Props.BoundingBox(2)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3);
                    plot([BoutonArray(BoutonCount).Crop_Props.BoundingBox(1),BoutonArray(BoutonCount).Crop_Props.BoundingBox(1)],[BoutonArray(BoutonCount).Crop_Props.BoundingBox(2),BoutonArray(BoutonCount).Crop_Props.BoundingBox(2)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3);plot([BoutonArray(BoutonCount).Crop_Props.BoundingBox(1)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(3),BoutonArray(BoutonCount).Crop_Props.BoundingBox(1)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(3)],[BoutonArray(BoutonCount).Crop_Props.BoundingBox(2),BoutonArray(BoutonCount).Crop_Props.BoundingBox(2)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3); 
                    %ReDo=input(['Enter 1 to Manual Select Crop Box ',BoutonArray(BoutonCount).Label,' Region']);
                    
                    RepeatSelection = questdlg(['Do you want to repeat/adjust ',BoutonArray(BoutonCount).Label,' Cropping?'],'Repeat?','Repeat','Continue','Continue');
                    switch RepeatSelection
                        case 'Repeat'
                            ReDo=1;
                        case 'Continue'
                            ReDo=0;
                    end

                    while ReDo
                        figure
                        imshow(RegistrationSettings.OverallReferenceImage,[],'Border','tight')
                        hold on
                        for Bouton=1:length(BoutonArray)
                            for j=1:length(BoutonArray(Bouton).BorderLine_Orig)
                                if Bouton==BoutonCount
                                    plot(BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,2),...
                                        BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,1),...
                                        '-','color',BoutonArray(Bouton).Color,'linewidth',2)
                                else
                                    plot(BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,2),...
                                        BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,1),...
                                        '-','color',BoutonArray(Bouton).Color,'linewidth',0.5)
                                end
                            end
                        end
                        set(gcf,'position',[0 50 ImagingInfo.DisplaySize])
                        hold on
                        text(10, 10, 'Select Crop Box Region','color','y','FontSize',12');
                        BoutonArray(BoutonCount).Crop_Region = roipoly;
                        BoutonArray(BoutonCount).Crop_Props = regionprops(double(BoutonArray(BoutonCount).Crop_Region), 'BoundingBox');
                        plot([BoutonArray(BoutonCount).Crop_Props.BoundingBox(1),BoutonArray(BoutonCount).Crop_Props.BoundingBox(1)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(3)],[BoutonArray(BoutonCount).Crop_Props.BoundingBox(2),BoutonArray(BoutonCount).Crop_Props.BoundingBox(2)],'-','color','y','LineWidth',3);plot([BoutonArray(BoutonCount).Crop_Props.BoundingBox(1),BoutonArray(BoutonCount).Crop_Props.BoundingBox(1)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(3)],[BoutonArray(BoutonCount).Crop_Props.BoundingBox(2)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(4),BoutonArray(BoutonCount).Crop_Props.BoundingBox(2)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3);
                        plot([BoutonArray(BoutonCount).Crop_Props.BoundingBox(1),BoutonArray(BoutonCount).Crop_Props.BoundingBox(1)],[BoutonArray(BoutonCount).Crop_Props.BoundingBox(2),BoutonArray(BoutonCount).Crop_Props.BoundingBox(2)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3);plot([BoutonArray(BoutonCount).Crop_Props.BoundingBox(1)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(3),BoutonArray(BoutonCount).Crop_Props.BoundingBox(1)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(3)],[BoutonArray(BoutonCount).Crop_Props.BoundingBox(2),BoutonArray(BoutonCount).Crop_Props.BoundingBox(2)+BoutonArray(BoutonCount).Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3); 
                        hold off
                        %ReDo=input(['Enter 1 to Manual Select Crop Box ',BoutonArray(BoutonCount).Label,' Region']);
                        
                        RepeatSelection = questdlg(['Do you want to repeat/adjust ',BoutonArray(BoutonCount).Label,' Cropping?'],'Repeat?','Repeat','Continue','Continue');
                        switch RepeatSelection
                            case 'Repeat'
                                ReDo=1;
                            case 'Continue'
                                ReDo=0;
                        end

                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BoutonArray(BoutonCount).Crop_XCoords=[round(BoutonArray(BoutonCount).Crop_Props.BoundingBox(1)):...
                                                           round(BoutonArray(BoutonCount).Crop_Props.BoundingBox(1))+...
                                                           round(BoutonArray(BoutonCount).Crop_Props.BoundingBox(3))];
                    BoutonArray(BoutonCount).Crop_YCoords=[round(BoutonArray(BoutonCount).Crop_Props.BoundingBox(2)):...
                                                           round(BoutonArray(BoutonCount).Crop_Props.BoundingBox(2))+...
                                                           round(BoutonArray(BoutonCount).Crop_Props.BoundingBox(4))];
                    BoutonArray(BoutonCount).ReferenceImage=imcrop(RegistrationSettings.OverallReferenceImage,BoutonArray(BoutonCount).Crop_Props.BoundingBox);
                    BoutonArray(BoutonCount).AllBoutonsRegion=imcrop(BoutonArray(BoutonCount).AllBoutonsRegion_Orig,BoutonArray(BoutonCount).Crop_Props.BoundingBox);
                    BoutonArray(BoutonCount).AllBoutonsRegionPerim=imcrop(BoutonArray(BoutonCount).AllBoutonsRegionPerim_Orig,BoutonArray(BoutonCount).Crop_Props.BoundingBox);
                    BoutonArray(BoutonCount).Image_Height=size(BoutonArray(BoutonCount).AllBoutonsRegion,1);
                    BoutonArray(BoutonCount).Image_Width=size(BoutonArray(BoutonCount).AllBoutonsRegion,2);
                    [TempBorderLine]=FindROIBorders(BoutonArray(BoutonCount).AllBoutonsRegion,DilateRegion);
                    BoutonArray(BoutonCount).BorderLine=TempBorderLine;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    figure
                    subtightplot(1,2,1,[0 0],[0 0],[0,0])
                    imshow(BoutonArray(BoutonCount).AllBoutonsRegion,[],'Border','tight')
                    hold on
                    for j=1:length(BoutonArray(BoutonCount).BorderLine)
                        plot(BoutonArray(BoutonCount).BorderLine{j}.BorderLine(:,2),...
                            BoutonArray(BoutonCount).BorderLine{j}.BorderLine(:,1),...
                            '-','color',BoutonArray(BoutonCount).Color,'linewidth',1)
                    end
                    subtightplot(1,2,2,[0 0],[0 0],[0,0])
                    imshow(BoutonArray(BoutonCount).ReferenceImage,[],'Border','tight')
                    hold on
                    for j=1:length(BoutonArray(BoutonCount).BorderLine)
                        plot(BoutonArray(BoutonCount).BorderLine{j}.BorderLine(:,2),...
                            BoutonArray(BoutonCount).BorderLine{j}.BorderLine(:,1),...
                            '-','color',BoutonArray(BoutonCount).Color,'linewidth',1)
                    end
                    set(gcf,'position',[0 50 BoutonArray(BoutonCount).Image_Width*2 BoutonArray(BoutonCount).Image_Height])

                    %CropSelecting=InputWithVerification(['Enter <1> to Repeat ',BoutonArray(BoutonCount).Label,' Cropping: '],{1,[]},0);
                    
                    RepeatSelection = questdlg(['Do you want to Repeat ',BoutonArray(BoutonCount).Label,' Cropping?'],'Repeat?','Repeat','Continue','Continue');
                    switch RepeatSelection
                        case 'Repeat'
                            CropSelecting=1;
                        case 'Continue'
                            CropSelecting=0;
                    end

                    if CropSelecting
                        BoutonArray(BoutonCount).AllBoutonsRegion=[];
                        BoutonArray(BoutonCount).AllBoutonsRegionPerim=[];
                        BoutonArray(BoutonCount).BorderLine=[];
                    end
                    clear TempBorderLine
                    close all
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                ScaleBarSelecting=1;
                while ScaleBarSelecting==1
                    try
                        BoutonArray(BoutonCount).ScaleBar.ScaleFactor=ImagingInfo.PixelSize; %um per pixel 
                        NewScaleBar=1;
                        if NewScaleBar==1
                            close all
                            figure
                            imshow(BoutonArray(BoutonCount).ReferenceImage,[],'Border','tight')
                            hold on
                            for j=1:length(BoutonArray(BoutonCount).BorderLine)
                                plot(BoutonArray(BoutonCount).BorderLine{j}.BorderLine(:,2),...
                                    BoutonArray(BoutonCount).BorderLine{j}.BorderLine(:,1),...
                                    '-','color',BoutonArray(BoutonCount).Color,'linewidth',1)
                            end
                            set(gcf,'position',[0 50 BoutonArray(BoutonCount).Image_Width*2 BoutonArray(BoutonCount).Image_Height*2])
                            RepeatPrompt=1;
                            while RepeatPrompt==1
                                prompt = {'Scale Bar Length (um)','Scale Bar Width','Scale Bar Pixel Width','Scale Bar Color','Define Left or Right Edge (L/R)'};
                                dlg_title = 'Confirm Scale Bar Properties';
                                num_lines = 1;
                                def = {num2str(DefaultScalebarLength_um),num2str(DefaultScaleBarLineWidth),num2str(DefaultScaleBarPixelWidth),'w','L'};
                                answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',1);
                                BoutonArray(BoutonCount).ScaleBar.Length=str2num(answer{1});
                                BoutonArray(BoutonCount).ScaleBar.Width=str2num(answer{2});
                                BoutonArray(BoutonCount).ScaleBar.PixelWidth=str2num(answer{3});
                                BoutonArray(BoutonCount).ScaleBar.Color=answer{4};
                                BoutonArray(BoutonCount).ScaleBar.PointerSide=answer{5};
                                clear answer;
                                if strcmp(BoutonArray(BoutonCount).ScaleBar.PointerSide,'L')||strcmp(BoutonArray(BoutonCount).ScaleBar.PointerSide,'R')
                                    RepeatPrompt=0;
                                else
                                    disp('Error with inputs try again')
                                    RepeatPrompt=1;
                                end
                            end
                            GoodScaleBar=0;
                            while GoodScaleBar==0
                                if strcmp(BoutonArray(BoutonCount).ScaleBar.PointerSide,'L')
                                    hold on
                                    text(10, 20, 'Place left corner of scale bar (enter when complete)','color','y','FontSize',12');
                                    plot([10 10+BoutonArray(BoutonCount).ScaleBar.Length/BoutonArray(BoutonCount).ScaleBar.ScaleFactor],[10 10],'-','color','y','LineWidth',BoutonArray(BoutonCount).ScaleBar.Width); hold off;
                                    [BoutonArray(BoutonCount).ScaleBar.XCoordinate BoutonArray(BoutonCount).ScaleBar.YCoordinate]=ginput_w(1); %mark left corner of BoutonArray(BoutonCount).ScaleBar location
                                    if BoutonArray(BoutonCount).ScaleBar.XCoordinate+BoutonArray(BoutonCount).ScaleBar.Length/BoutonArray(BoutonCount).ScaleBar.ScaleFactor>=size(BoutonArray(BoutonCount).ReferenceImage,2);
                                        disp('Scale Bar will not fit in window!, Please retry')
                                    else
                                        GoodScaleBar=1;
                                    end
                                elseif strcmp(BoutonArray(BoutonCount).ScaleBar.PointerSide,'R')
                                    hold on
                                    text(10, 20, 'Place right corner of scale bar (enter when complete)','color','y','FontSize',12');
                                    plot([10 10+BoutonArray(BoutonCount).ScaleBar.Length/BoutonArray(BoutonCount).ScaleBar.ScaleFactor],[10 10],'-','color','y','LineWidth',BoutonArray(BoutonCount).ScaleBar.Width); hold off;
                                    [BoutonArray(BoutonCount).ScaleBar.XCoordinate BoutonArray(BoutonCount).ScaleBar.YCoordinate]=ginput_w(1); %mark right corner of scalebar location
                                    if BoutonArray(BoutonCount).ScaleBar.XCoordinate-BoutonArray(BoutonCount).ScaleBar.Length/BoutonArray(BoutonCount).ScaleBar.ScaleFactor<=0;
                                        disp('Scale Bar will not fit in window!, Please retry')
                                    else
                                        GoodScaleBar=1;
                                    end
                                end

                            end
                        end
                        BoutonArray(BoutonCount).ScaleBar.ColorCode=ColorDefinitions(BoutonArray(BoutonCount).ScaleBar.Color);
                        if strcmp(BoutonArray(BoutonCount).ScaleBar.PointerSide,'L')
                            BoutonArray(BoutonCount).ScaleBar.XData=[BoutonArray(BoutonCount).ScaleBar.XCoordinate BoutonArray(BoutonCount).ScaleBar.XCoordinate+BoutonArray(BoutonCount).ScaleBar.Length/BoutonArray(BoutonCount).ScaleBar.ScaleFactor];
                        elseif strcmp(BoutonArray(BoutonCount).ScaleBar.PointerSide,'R')
                            BoutonArray(BoutonCount).ScaleBar.XData=[BoutonArray(BoutonCount).ScaleBar.XCoordinate-BoutonArray(BoutonCount).ScaleBar.Length/BoutonArray(BoutonCount).ScaleBar.ScaleFactor BoutonArray(BoutonCount).ScaleBar.XCoordinate];
                        end
                        BoutonArray(BoutonCount).ScaleBar.YData=[BoutonArray(BoutonCount).ScaleBar.YCoordinate BoutonArray(BoutonCount).ScaleBar.YCoordinate];
                        BoutonArray(BoutonCount).ScaleBar.PixelLength=round(BoutonArray(BoutonCount).ScaleBar.Length/BoutonArray(BoutonCount).ScaleBar.ScaleFactor);
                        BoutonArray(BoutonCount).ScaleBar.BoutonArray(BoutonCount).ScaleBarMask=zeros(size(BoutonArray(BoutonCount).ReferenceImage));
                        if strcmp(BoutonArray(BoutonCount).ScaleBar.PointerSide,'L')
                            BoutonArray(BoutonCount).ScaleBar.BoutonArray(BoutonCount).ScaleBarMask(round(BoutonArray(BoutonCount).ScaleBar.YCoordinate):round(BoutonArray(BoutonCount).ScaleBar.YCoordinate)+BoutonArray(BoutonCount).ScaleBar.PixelWidth-1,round(BoutonArray(BoutonCount).ScaleBar.XCoordinate):round(BoutonArray(BoutonCount).ScaleBar.XCoordinate)+BoutonArray(BoutonCount).ScaleBar.PixelLength)=1;
                        elseif strcmp(BoutonArray(BoutonCount).ScaleBar.PointerSide,'R')
                            BoutonArray(BoutonCount).ScaleBar.BoutonArray(BoutonCount).ScaleBarMask(round(BoutonArray(BoutonCount).ScaleBar.YCoordinate):round(BoutonArray(BoutonCount).ScaleBar.YCoordinate)+BoutonArray(BoutonCount).ScaleBar.PixelWidth-1,round(BoutonArray(BoutonCount).ScaleBar.XCoordinate)-BoutonArray(BoutonCount).ScaleBar.PixelLength:round(BoutonArray(BoutonCount).ScaleBar.XCoordinate))=1;
                        end
                        BoutonArray(BoutonCount).ScaleBar.BoutonArray(BoutonCount).ScaleBarMask=logical(BoutonArray(BoutonCount).ScaleBar.BoutonArray(BoutonCount).ScaleBarMask);
                        TempImage=BoutonArray(BoutonCount).ReferenceImage;
                        BoutonArray(BoutonCount).ScaleBar.ScaleBarBurnDisplayImage = imoverlay(mat2gray(TempImage), BoutonArray(BoutonCount).ScaleBar.BoutonArray(BoutonCount).ScaleBarMask, BoutonArray(BoutonCount).ScaleBar.ColorCode);
                        figure
                        imshow(BoutonArray(BoutonCount).ReferenceImage,[],'Border','tight')
                        hold on
                        for j=1:length(BoutonArray(BoutonCount).BorderLine)
                            plot(BoutonArray(BoutonCount).BorderLine{j}.BorderLine(:,2),...
                                BoutonArray(BoutonCount).BorderLine{j}.BorderLine(:,1),...
                                '-','color',BoutonArray(BoutonCount).Color,'linewidth',1)
                        end
                        hold on
                        plot(BoutonArray(BoutonCount).ScaleBar.XData,BoutonArray(BoutonCount).ScaleBar.YData,...
                            '-','color',BoutonArray(BoutonCount).ScaleBar.Color,'linewidth',BoutonArray(BoutonCount).ScaleBar.Width);
                        set(gcf,'position',[100 200 BoutonArray(BoutonCount).Image_Width*2 BoutonArray(BoutonCount).Image_Height*2])

                        %ScaleBarSelecting=InputWithVerification('Enter 1 to repeat the scale bar placement: ',{1,[]},0);BringAllToFront;

                        RepeatSelection = questdlg(['Do you want to Repeat ',BoutonArray(BoutonCount).Label,' scale bar placement?'],'Repeat?','Repeat','Continue','Continue');
                        switch RepeatSelection
                            case 'Repeat'
                                ScaleBarSelecting=1;
                            case 'Continue'
                                ScaleBarSelecting=0;
                        end

                        if ScaleBarSelecting==1
                            GoodScaleBar=0;NewScaleBar=1;
                        end
                    catch
                       warning('Problem with scalebar!') 
                    end
                end
                close all;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            close all
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ImagingInfo.ActiveBoutons=[];
    for BoutonCount=1:length(BoutonArray)
        if any(BoutonArray(BoutonCount).AllBoutonsRegion_Orig(:)~=0)
            ImagingInfo.ActiveBoutons=[ImagingInfo.ActiveBoutons,BoutonCount];
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%               STAGE 0              %
%           AnalysisPart 5           %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Registration Setup
if any(AnalysisParts==5)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ImagingInfo.MicroscopeClass = questdlg({'What type of microscope did you use?';...
        'Confocal and epifluorescence scopes have very different contrast requirements'},...
        'Microscope type?','Confocal','Epifluorescence','Confocal');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %DemonReg Settings By Bouton
    OverwriteDemonReg=1;
    if RegistrationSettings.RegisterToReference&&isfield(BoutonArray,'DemonReg')
        DemonChoice = questdlg({'You are either registering to a reference file';...
            'or DemonReg settinge exist. If the Reference';...
            'is a different modality you may want to force overwrite';...
            'the demon registraiton settings'},...
            'DemonReg Overwrite?','Skip','Overwrite','Overwrite');
        if strcmp(DemonChoice,'Overwrite')
            OverwriteDemonReg=1;
        else
            OverwriteDemonReg=0;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    OverwriteRegEnhance=1;
    if RegistrationSettings.RegisterToReference&&isfield(BoutonArray,'RegEnhancement')
        RegOverChoice = questdlg({'You are either registering to a reference file';...
            'or RegEnhancement settinge exist. You may want to force overwrite';...
            'the registraiton enhancement settings but less criticial than demon settings'},...
            'RegEnhancement Overwrite?','Skip','Overwrite','Skip');
        if strcmp(RegOverChoice,'Overwrite')
            OverwriteRegEnhance=1;
        else
            OverwriteRegEnhance=0;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for BoutonCount=1:length(BoutonArray)  
        if any(ImagingInfo.ActiveBoutons==BoutonCount)
            BoutonArray(BoutonCount).RegistrationSettings=RegistrationSettings;

            %Demon Algorithm Settings
            switch ImagingInfo.ModalityType
                case 1
                    if OverwriteDemonReg
                        BoutonArray(BoutonCount).DemonReg.OverwriteDemonSettings=0;
                        BoutonArray(BoutonCount).DemonReg.PadValue_Method=1;
                        BoutonArray(BoutonCount).DemonReg.Padding=100;%150
                        BoutonArray(BoutonCount).DemonReg.DFT_Pad_Enhance=1;
                        BoutonArray(BoutonCount).DemonReg.RegisterToReference=RegistrationSettings.RegisterToReference;

                        BoutonArray(BoutonCount).DemonReg.PyramidLevels=6;%4
                        BoutonArray(BoutonCount).DemonReg.Iterations=[4000 2000 1000 500 250 100];
                        BoutonArray(BoutonCount).DemonReg.AccumulatedFieldSmoothing=4;%5 %Higher corrects worse but less artifacts
                        BoutonArray(BoutonCount).DemonReg.SmoothDemon=2;%1 %to get rid of temporal jitters will also set the number of smooth repeats
                        BoutonArray(BoutonCount).DemonReg.DemonSmoothSize=[15 11];%11 %Keep Odd but be careful not to make too big b/c will have problems at beginning and end
                        %Refinement Settings
                        BoutonArray(BoutonCount).DemonReg.IntermediateCropPadding=4;%
                        BoutonArray(BoutonCount).DemonReg.BoutonRefinement=0;%
                        BoutonArray(BoutonCount).DemonReg.BorderBufferPixelSize=4;%

                        %Advancned Settings
                        BoutonArray(BoutonCount).DemonReg.DynamicSmoothing=0; %will reduce Accumulated Field Smoothing and Temporal Smoothing when it flaggs frames with large DFT DeltaX or DeltaY Derivatives. This is to provide greater flexibility when things are moving rapidly between frames
                        BoutonArray(BoutonCount).DemonReg.DynamicSmoothingDerivThreshold=2;%For the derivative of +x -x frames 
                        BoutonArray(BoutonCount).DemonReg.CarryOver_DemonField_Smoothing=0; %Useful for long imaging sessions with short gaps between images
                        BoutonArray(BoutonCount).DemonReg.CarryOverFrames=15; %More weill encroach more into the previoius file
                        BoutonArray(BoutonCount).DemonReg.CircularFilter=0;
                        BoutonArray(BoutonCount).DemonReg.CircularFilterFrames=[];
                        BoutonArray(BoutonCount).DemonReg.CoarseTranslation=1;
                        BoutonArray(BoutonCount).DemonReg.CoarseTranslationMode=1;
                        BoutonArray(BoutonCount).DemonReg.FastSmoothing=1;
                        BoutonArray(BoutonCount).DemonReg.PixelBlockSize=10;
                        
                        BoutonArray(BoutonCount).DemonReg.DemonMask=[];
                    end
                case 2
                    if OverwriteDemonReg

                        BoutonArray(BoutonCount).DemonReg.OverwriteDemonSettings=0;
                        BoutonArray(BoutonCount).DemonReg.PadValue_Method=1;
                        BoutonArray(BoutonCount).DemonReg.Padding=100;%150
                        BoutonArray(BoutonCount).DemonReg.DFT_Pad_Enhance=1;
                        BoutonArray(BoutonCount).DemonReg.RegisterToReference=RegistrationSettings.RegisterToReference;

                        BoutonArray(BoutonCount).DemonReg.PyramidLevels=6;%4
                        BoutonArray(BoutonCount).DemonReg.Iterations=[2000 1000 500 250 100 50];
                        BoutonArray(BoutonCount).DemonReg.AccumulatedFieldSmoothing=5;%5 %Higher corrects worse but less artifacts
                        BoutonArray(BoutonCount).DemonReg.SmoothDemon=2;%1 %to get rid of temporal jitters will also set the number of smooth repeats
                        BoutonArray(BoutonCount).DemonReg.DemonSmoothSize=[31 21];%11 %Keep Odd but be careful not to make too big b/c will have problems at beginning and end
                        %Refinement Settings
                        BoutonArray(BoutonCount).DemonReg.IntermediateCropPadding=4;%
                        BoutonArray(BoutonCount).DemonReg.BoutonRefinement=0;%
                        BoutonArray(BoutonCount).DemonReg.BorderBufferPixelSize=4;%

                        %Advancned Settings
                        BoutonArray(BoutonCount).DemonReg.DynamicSmoothing=1; %will reduce Accumulated Field Smoothing and Temporal Smoothing when it flaggs frames with large DFT DeltaX or DeltaY Derivatives. This is to provide greater flexibility when things are moving rapidly between frames
                        BoutonArray(BoutonCount).DemonReg.DynamicSmoothingDerivThreshold=2;%0.5 For the derivative of +x -x frames 
                        BoutonArray(BoutonCount).DemonReg.CarryOver_DemonField_Smoothing=1; %Useful for long imaging sessions with short gaps between images
                        BoutonArray(BoutonCount).DemonReg.CarryOverFrames=15; %More weill encroach more into the previoius file
                        BoutonArray(BoutonCount).DemonReg.CircularFilter=0;
                        BoutonArray(BoutonCount).DemonReg.CircularFilterFrames=[];
                        BoutonArray(BoutonCount).DemonReg.CoarseTranslation=0;
                        BoutonArray(BoutonCount).DemonReg.CoarseTranslationMode=1;
                        BoutonArray(BoutonCount).DemonReg.FastSmoothing=1;
                        BoutonArray(BoutonCount).DemonReg.PixelBlockSize=10;

                        BoutonArray(BoutonCount).DemonReg.DemonMask=[];
                    end
                case 3
                    if OverwriteDemonReg
                        BoutonArray(BoutonCount).DemonReg.OverwriteDemonSettings=0;
                        BoutonArray(BoutonCount).DemonReg.PadValue_Method=1;
                        BoutonArray(BoutonCount).DemonReg.Padding=100;%150
                        BoutonArray(BoutonCount).DemonReg.DFT_Pad_Enhance=1;
                        BoutonArray(BoutonCount).DemonReg.RegisterToReference=RegistrationSettings.RegisterToReference;

                        BoutonArray(BoutonCount).DemonReg.PyramidLevels=6;%4
                        BoutonArray(BoutonCount).DemonReg.Iterations=[2000 1000 500 250 100 50];
                        BoutonArray(BoutonCount).DemonReg.AccumulatedFieldSmoothing=5;%5 %Higher corrects worse but less artifacts
                        BoutonArray(BoutonCount).DemonReg.SmoothDemon=2;%1 %to get rid of temporal jitters will also set the number of smooth repeats
                        BoutonArray(BoutonCount).DemonReg.DemonSmoothSize=[31 21];%11 %Keep Odd but be careful not to make too big b/c will have problems at beginning and end
                        %Refinement Settings
                        BoutonArray(BoutonCount).DemonReg.IntermediateCropPadding=4;%
                        BoutonArray(BoutonCount).DemonReg.BoutonRefinement=0;%
                        BoutonArray(BoutonCount).DemonReg.BorderBufferPixelSize=4;%

                        %Advancned Settings
                        BoutonArray(BoutonCount).DemonReg.DynamicSmoothing=1; %will reduce Accumulated Field Smoothing and Temporal Smoothing when it flaggs frames with large DFT DeltaX or DeltaY Derivatives. This is to provide greater flexibility when things are moving rapidly between frames
                        BoutonArray(BoutonCount).DemonReg.DynamicSmoothingDerivThreshold=2;%0.5 For the derivative of +x -x frames 
                        BoutonArray(BoutonCount).DemonReg.CarryOver_DemonField_Smoothing=0; %Useful for long imaging sessions with short gaps between images
                        BoutonArray(BoutonCount).DemonReg.CarryOverFrames=15; %More weill encroach more into the previoius file
                        BoutonArray(BoutonCount).DemonReg.CircularFilter=0;
                        BoutonArray(BoutonCount).DemonReg.CircularFilterFrames=[];
                        BoutonArray(BoutonCount).DemonReg.CoarseTranslation=0;
                        BoutonArray(BoutonCount).DemonReg.CoarseTranslationMode=1;
                        BoutonArray(BoutonCount).DemonReg.FastSmoothing=1;
                        BoutonArray(BoutonCount).DemonReg.PixelBlockSize=10;
                        
                        BoutonArray(BoutonCount).DemonReg.DemonMask=[];
                    end
            end
            %Enhancement settings
            switch ImagingInfo.MicroscopeClass
                case 'Confocal'
                    if OverwriteRegEnhance
                        BoutonArray(BoutonCount).RegEnhancement.MicroscopeClass=ImagingInfo.MicroscopeClass;
                        
                        %lower StretchLimParam(2) to get higher contrast, sometimes good sometimes bad
                        BoutonArray(BoutonCount).RegEnhancement.MaskSplitPercentage=0.01;%0.1
                        BoutonArray(BoutonCount).RegEnhancement.StretchLimParams=[0.8,0.99];%[0.01,0.99] if padding size increases this may need to be decreased because its a % of total pixels
                        %BoutonArray(BoutonCount).RegEnhancement.StretchLimParams=[0.01 1]
                        BoutonArray(BoutonCount).RegEnhancement.MaskSplitDilate=30;%30
                        BoutonArray(BoutonCount).RegEnhancement.BorderAdjustSize=10;%10
                        BoutonArray(BoutonCount).RegEnhancement.Bias_Region=1;%1
                        BoutonArray(BoutonCount).RegEnhancement.BiasRatios=5;%5
                        BoutonArray(BoutonCount).RegEnhancement.BiasRatioDiv=10;%10
                        BoutonArray(BoutonCount).RegEnhancement.BiasProportion=0.9;%0.9

                        BoutonArray(BoutonCount).RegEnhancement.weinerParams=[15,15];%15
                        BoutonArray(BoutonCount).RegEnhancement.openParams=20;%20 %Lower is stronger
                        BoutonArray(BoutonCount).RegEnhancement.Filter_Enhanced=1;%1
                        BoutonArray(BoutonCount).RegEnhancement.EnhanceFilterSize_um=2;%9
                        BoutonArray(BoutonCount).RegEnhancement.EnhanceFilterSigma_um=0.2;%1
                    end
                case 'Epifluorescence'
                        %lower StretchLimParam(2) to get higher contrast, sometimes good sometimes bad
                        BoutonArray(BoutonCount).RegEnhancement.MaskSplitPercentage=0.05;%0.1
                        BoutonArray(BoutonCount).RegEnhancement.StretchLimParams=[0.7,0.975];%[0.01,0.99] if padding size increases this may need to be decreased because its a % of total pixels
                        %BoutonArray(BoutonCount).RegEnhancement.StretchLimParams=[0.01 1]
                        BoutonArray(BoutonCount).RegEnhancement.MaskSplitDilate=40;%30
                        BoutonArray(BoutonCount).RegEnhancement.BorderAdjustSize=10;%10
                        BoutonArray(BoutonCount).RegEnhancement.Bias_Region=1;%1
                        BoutonArray(BoutonCount).RegEnhancement.BiasRatios=10;%5
                        BoutonArray(BoutonCount).RegEnhancement.BiasRatioDiv=20;%10
                        BoutonArray(BoutonCount).RegEnhancement.BiasProportion=0.1;%0.9

                        BoutonArray(BoutonCount).RegEnhancement.weinerParams=[10,10];%15
                        BoutonArray(BoutonCount).RegEnhancement.openParams=80;%20 %Lower is stronger
                        BoutonArray(BoutonCount).RegEnhancement.Filter_Enhanced=1;%1
                        BoutonArray(BoutonCount).RegEnhancement.EnhanceFilterSize_um=1;%9
                        BoutonArray(BoutonCount).RegEnhancement.EnhanceFilterSigma_um=3;%1
                    
                    
            end
            BoutonArray(BoutonCount).RegEnhancement.EnhanceFilterSigma_px=...
                BoutonArray(BoutonCount).RegEnhancement.EnhanceFilterSigma_um/ImagingInfo.PixelSize;
            BoutonArray(BoutonCount).RegEnhancement.EnhanceFilterSize_px=...
                ceil(BoutonArray(BoutonCount).RegEnhancement.EnhanceFilterSize_um/ImagingInfo.PixelSize);
            if rem(BoutonArray(BoutonCount).RegEnhancement.EnhanceFilterSize_px,2)==0
                BoutonArray(BoutonCount).RegEnhancement.EnhanceFilterSize_px=BoutonArray(BoutonCount).RegEnhancement.EnhanceFilterSize_px+1;
            end
            if ~isfield(BoutonArray(BoutonCount).RegEnhancement,'DemonMask')
                BoutonArray(BoutonCount).DemonReg.DemonMask=[];
            end
            if RegistrationSettings.RegisterToReference
            else
                BoutonArray(BoutonCount).RefRegEnhancement=BoutonArray(BoutonCount).RegEnhancement;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for BoutonCount=1:length(BoutonArray)
        if any(ImagingInfo.ActiveBoutons==BoutonCount)
            [BoutonArray(BoutonCount).RegistrationSettings,BoutonArray(BoutonCount).RegEnhancement,BoutonArray(BoutonCount).RefRegEnhancement,BoutonArray(BoutonCount).DemonReg]=...
                Enhanced_Multi_Modality_Registration_Setup([SaveName,ImagingInfo.ModalitySuffix,BoutonArray(BoutonCount).BoutonSuffix],...
                ImageArray,RegistrationSettings.OverallReferenceImage,...
                BoutonArray(BoutonCount).AllBoutonsRegion_Orig,BoutonArray(BoutonCount).Crop_Props,...
                ImagingInfo,BoutonArray(BoutonCount).RegistrationSettings,BoutonArray(BoutonCount).RegEnhancement,BoutonArray(BoutonCount).RefRegEnhancement,BoutonArray(BoutonCount).DemonReg);

        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%               STAGE 0              %
%           AnalysisPart 6           %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Episode Markers
if any(AnalysisParts==6)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Create a Marker for pharmacology, plasticity, or photoactivation experiments
    if length(ImagingInfo.GoodEpisodeNumbers)~=max(ImagingInfo.GoodEpisodeNumbers)
        close all
        IntakeEpisodeNumberRecord=[];
        count=1;
        for fileCount=1:LoadingInfo.NumFiles
            IntakeEpisodeNumberRecord(1:10,count:count+MetaDataRecord(fileCount).TotalNumEpisodes-1)=fileCount;
            count=count+MetaDataRecord(fileCount).TotalNumEpisodes;
        end
        AllEpisodeNumbers=1:ImagingInfo.TotalNumInputFrames/ImagingInfo.FramesPerEpisode;
        EpisodeNumberRecord=zeros(10,length(AllEpisodeNumbers));
        for i=1:length(AllEpisodeNumbers)
            if any(AllEpisodeNumbers(i)==ImagingInfo.GoodEpisodeNumbers)
                EpisodeNumberRecord(1:10,i)=1;
            end
        end
        for i=1:length(ImagingInfo.GoodEpisodeNumbers)
            GoodEpisodeNumberRecord(1:10,i)=1;
        end
        EpisodeNumberRecordOverlay=EpisodeNumberRecord+IntakeEpisodeNumberRecord;

        for i=1:length(ImagingInfo.GoodEpisodeNumbers)
            disp(['Ep ',num2str(i),' OrigEp ',num2str(ImagingInfo.GoodEpisodeNumbers(i))])
        end
        count=1;
        for fileCount=1:LoadingInfo.NumFiles
            disp(['File ',num2str(fileCount),' Intake Episodes: ',num2str(count),'-',num2str(count+MetaDataRecord(fileCount).TotalNumEpisodes-1)]);
            count=count+MetaDataRecord(fileCount).TotalNumEpisodes;
        end

        figure;
        subplot(3,1,1);
        imagesc(IntakeEpisodeNumberRecord, [0 LoadingInfo.NumFiles]),
        axis equal tight; hold on;title(['AllEpisodeNumbers Total=',num2str(length(AllEpisodeNumbers))]);
        ylim([0 10]);
        hold off
        subplot(3,1,2);
        imagesc(EpisodeNumberRecord, [0 1]),
        axis equal tight;hold on;title(['ImagingInfo.GoodEpisodeNumbers Total=',num2str(length(ImagingInfo.GoodEpisodeNumbers))]);
        ylim([0 10]);
        hold off; 
        subplot(3,1,3);
        imagesc(EpisodeNumberRecordOverlay, [0 max(EpisodeNumberRecordOverlay(:))]),
        axis equal tight;hold on;title(['ImagingInfo.GoodEpisodeNumbers Total=',num2str(length(ImagingInfo.GoodEpisodeNumbers))]);
        ylim([0 10]);
        hold off; 
        set(gcf,'units','normalized','position',[0.2    0.3    0.6    0.4])

        if TutorialNotes
            Instructions={'Because you have removed some episodes the original treatment';...
                'timing relative to the raw data may not line up with the new clean';...
                'episode numbers so look at how the new #s compare to the original intake ';...
                'episode numbers where the treamtant may have occured and record';...
                'before proceeding!'};
            TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
            if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
                TutorialNotes=0;
            end
        
        end
        cont=input('Press any key to continue: ');

    end
    AddMarker = questdlg('Add Marker(s)?','Add Marker?','Add','Skip','Skip');
    if strcmp(AddMarker,'Add')  
        prompt = {['How Many Treamtment Episode Markers to add? ']};
        dlg_title = 'Add Treatment Markers';
        num_lines = 1;
        defaultans = {num2str(0)};
        answer = inputdlgcolZN(prompt,dlg_title,num_lines,defaultans,'on',1);
        MarkerSetInfo.NumMarkers=str2num(answer{1});
        for MarkerCount=1:MarkerSetInfo.NumMarkers
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            MarkerChoice = questdlg({['Marker # ',num2str(MarkerCount),' Type'];'Across Episodes (1) = Treatment Present over Multiple Episodes';...
                                     'Between Episodes (2) = Brief treatment that turned off when imaging starts again'},...
                                    ['Marker # ',num2str(MarkerCount),' Type'],'Across Episodes','Between Episodes','Across Episodes');
            if strcmp(MarkerChoice,'Across Episodes')
                MarkerSetInfo.Markers(MarkerCount).MarkerStyles=1;
            elseif strcmp(MarkerChoice,'Between Episodes')
                MarkerSetInfo.Markers(MarkerCount).MarkerStyles=2;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            prompt = {'Treatment Full Label','Treatment Short Label','Treatment Color (single letter)','Treatment MarkerLine Style'};
            dlg_title = ['Marker # ',num2str(MarkerCount),' Details ',MarkerChoice];
            num_lines = 1;
            def = {'10uM LY341495','LY','r','-',num2str(1),num2str(ImagingInfo.NumEpisodes)};
            answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',1);
            MarkerSetInfo.Markers(MarkerCount).MarkerLabel=answer{1};
            MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel=answer{2};
            MarkerSetInfo.Markers(MarkerCount).MarkerColor=answer{3};
            MarkerSetInfo.Markers(MarkerCount).MarkerLineStyle=answer{4};
            clear answer
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if MarkerSetInfo.Markers(MarkerCount).MarkerStyles==1
                prompt = {'Treatment Episode Start','Treatment Episode End'};
                dlg_title = ['Marker # ',num2str(MarkerCount),' Details ',MarkerChoice];
                num_lines = 1;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                def = {num2str(1),num2str(ImagingInfo.NumEpisodes)};
                answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',1);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                MarkerSetInfo.Markers(MarkerCount).MarkerStart=str2num(answer{1});
                MarkerSetInfo.Markers(MarkerCount).MarkerEnd=str2num(answer{2});
                clear answer
                MarkerSetInfo.Markers(MarkerCount).MarkerXData=...
                    [MarkerSetInfo.Markers(MarkerCount).MarkerStart,...
                    MarkerSetInfo.Markers(MarkerCount).MarkerEnd];
                MarkerSetInfo.Markers(MarkerCount).MarkerYData=...
                    [1,...
                    1];
            elseif MarkerSetInfo.Markers(MarkerCount).MarkerStyles==2
                prompt = {'Treatment Episode Pre','Treatment Episode Post'};
                dlg_title = ['Marker # ',num2str(MarkerCount),' Details ',MarkerChoice];
                num_lines = 1;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                def = {num2str(ceil(ImagingInfo.NumEpisodes/2)),num2str(ceil(ImagingInfo.NumEpisodes/2)+1)};
                answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',1);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                MarkerSetInfo.Markers(MarkerCount).MarkerStart=str2num(answer{1});
                MarkerSetInfo.Markers(MarkerCount).MarkerEnd=str2num(answer{2});
                clear answer
                MarkerSetInfo.Markers(MarkerCount).MarkerXData=...
                    [1,1]*(MarkerSetInfo.Markers(MarkerCount).MarkerStart+(MarkerSetInfo.Markers(MarkerCount).MarkerEnd-MarkerSetInfo.Markers(MarkerCount).MarkerStart)/2);
                MarkerSetInfo.Markers(MarkerCount).MarkerYData=...
                    [0,...
                    1];
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            AddROIChoice = questdlg({['Marker # ',num2str(MarkerCount),' ROIs?'];'Add any ROIs to the NMJ'},...
                                    ['Marker # ',num2str(MarkerCount),' ROIs?'],'Skip','Add ROI','Skip');
            if strcmp(AddROIChoice,'Skip')
                MarkerSetInfo.Markers(MarkerCount).NumROIs=0;
                MarkerSetInfo.Markers(MarkerCount).ROIs=[];
            elseif strcmp(AddROIChoice,'Add ROI')
                prompt = {['How Many ROIs to add? ']};
                dlg_title = ['Marker # ',num2str(MarkerCount),' ROIs'];
                num_lines = 1;
                defaultans = {num2str(1)};
                answer = inputdlgcolZN(prompt,dlg_title,num_lines,defaultans,'on',1);
                MarkerSetInfo.Markers(MarkerCount).NumROIs=str2num(answer{1});
                MarkerSetInfo.Markers(MarkerCount).ROIs=[];
                for MarkerROI=1:MarkerSetInfo.Markers(MarkerCount).NumROIs
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    prompt = {'ROI Full Label','ROI Short Label','ROI Color (single letter)','ROI MarkerLine Style','ROI Bouton (Ib/Is)'};
                    dlg_title = ['Marker # ',num2str(MarkerCount),' ROI # ',num2str(MarkerROI),'  ',MarkerChoice,' Details'];
                    num_lines = 1;
                    def = {MarkerSetInfo.Markers(MarkerCount).MarkerLabel,MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel,...
                        MarkerSetInfo.Markers(MarkerCount).MarkerColor,MarkerSetInfo.Markers(MarkerCount).MarkerLineStyle,'Ib'};
                    answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',1);
                    MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILabel=answer{1};
                    MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIShortLabel=answer{2};
                    MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIColor=answer{3};
                    MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILineStyle=answer{4};
                    MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBouton=answer{5};
                    if strcmp(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBouton,'Ib')
                        MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBoutonCount=1;
                    elseif strcmp(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBouton,'Is')
                        MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBoutonCount=2;
                    else
                        error('Unknow Bouton Type!');
                    end
                    clear answer
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if ~exist('DilateRegionSize')
                        DilateRegionSize=1;
                        if DilateRegionSize>0
                            DilateRegion=ones(DilateRegionSize);
                        else
                            DilateRegion=[];
                        end
                    end
                    SelectROI=1;
                    while SelectROI
                        MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIMask_Orig=[];
                        MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBorderLine_Orig=[];
                        MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIMask_Crop=[];
                        MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBorderLine_Crop=[];
                        close all
                        figure
                        imshow(RegistrationSettings.OverallReferenceImage,[],'Border','tight')
                        hold on
                        for Bouton=1:length(BoutonArray)
                            for j=1:length(BoutonArray(Bouton).BorderLine_Orig)
                                plot(BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,2),...
                                    BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,1),...
                                    '-','color',BoutonArray(Bouton).Color,'linewidth',1)
                            end
                        end
                        hold on
                        for MarkerCount1=1:length(MarkerSetInfo.Markers)
                            if isfield(MarkerSetInfo.Markers,'ROI')
                                for MarkerROI1=1:length(MarkerSetInfo.Markers(MarkerCount1).ROI)
                                    for j=1:length(MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine_Orig)
                                        plot(MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine_Orig{j}.BorderLine(:,2),...
                                            MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine_Orig{j}.BorderLine(:,1),...
                                            MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILineStyle,'color',MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIColor,'linewidth',2)
                                    end
                                end
                            end
                        end
                        hold on
                        text(15, 15,['Draw ROI for Marker # ',num2str(MarkerCount),' ROI # ',num2str(MarkerROI)],'color','y')
                        set(gcf,'position',[0 50 ImagingInfo.Image_Width*1.5 ImagingInfo.Image_Height*1.5])
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIMask_Orig = roipoly; % draw a region on the current figure
                        [MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBorderLine_Orig]=...
                            FindROIBorders(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIMask_Orig,DilateRegion);
                        hold on
                        for j=1:length(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBorderLine_Orig)
                            plot(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBorderLine_Orig{j}.BorderLine(:,2),...
                                MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBorderLine_Orig{j}.BorderLine(:,1),...
                                MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILineStyle,'color',MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIColor,'linewidth',2)
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIMask_Crop=...
                            imcrop(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIMask_Orig,...
                            BoutonArray(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBoutonCount).Crop_Props.BoundingBox);
                        [MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBorderLine_Crop]=...
                            FindROIBorders(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIMask_Crop,DilateRegion);
                        figure
                        imshow(BoutonArray(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBoutonCount).ReferenceImage,[],'Border','tight')
                        hold on
                        for j=1:length(BoutonArray(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBoutonCount).BorderLine)
                            plot(BoutonArray(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBoutonCount).BorderLine{j}.BorderLine(:,2),...
                                BoutonArray(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBoutonCount).BorderLine{j}.BorderLine(:,1),...
                                '-','color',BoutonArray(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBoutonCount).Color,'linewidth',1)
                        end
                        hold on
                        for j=1:length(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBorderLine_Crop)
                            plot(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBorderLine_Crop{j}.BorderLine(:,2),...
                                MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBorderLine_Crop{j}.BorderLine(:,1),...
                                MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILineStyle,'color',MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIColor,'linewidth',2)
                        end
                        hold on
                        for MarkerCount1=1:length(MarkerSetInfo.Markers)
                            if isfield(MarkerSetInfo.Markers,'ROI')
                                for MarkerROI1=1:length(MarkerSetInfo.Markers(MarkerCount1).ROI)
                                    if MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBoutonCount==MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBoutonCount
                                        for j=1:length(MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine_Crop)
                                            plot(MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine_Crop{j}.BorderLine(:,2),...
                                                MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine_Crop{j}.BorderLine(:,1),...
                                                MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILineStyle,'color',MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIColor,'linewidth',2)
                                        end
                                    end
                                end
                            end
                        end
                        hold on
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %SelectROI=InputWithVerification('<1> To repeate placement: ',{[],1},0);
                        
                        RepeatSelection = questdlg('Do you want to Repeat ROI placement?','Repeat?','Repeat','Continue','Continue');
                        switch RepeatSelection
                            case 'Repeat'
                                SelectROI=1;
                            case 'Continue'
                                SelectROI=0;
                        end
                    
                        
                        
                        close all
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    else
        MarkerSetInfo.Markers=[];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%               STAGE 0              %
%           AnalysisPart 7           %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Bouton Merging
if any(AnalysisParts==7)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    AutoCropBuffer=2;
    DefaultScalebarLength_um=10;
    DefaultScaleBarLineWidth=2;
    DefaultScaleBarPixelWidth=5;
    DilateRegionSize=1;  %Used for Borderline generation
    if DilateRegionSize>0
        DilateRegion=ones(DilateRegionSize);
    else
        DilateRegion=[];
    end
    if ~RegistrationSettings.RegisterToReference
        BoutonMerging=1;
        while BoutonMerging
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ReDo=0;
            close all
            BoutonMerge.AllBoutonsRegion_Orig=zeros(size(RegistrationSettings.OverallReferenceImage));
            for Bouton=1:length(BoutonArray)
                if any(BoutonArray(Bouton).AllBoutonsRegion_Orig(:)~=0)
                    BoutonMerge.AllBoutonsRegion_Orig=...
                        logical(BoutonMerge.AllBoutonsRegion_Orig+BoutonArray(Bouton).AllBoutonsRegion_Orig);
                end
            end
            if length(ImagingInfo.ActiveBoutons)==1
                BoutonMerge.Crop_Props=BoutonArray(ImagingInfo.ActiveBoutons).Crop_Props;
                BoutonMerge.Crop_Region=BoutonArray(ImagingInfo.ActiveBoutons).Crop_Region;
            else
                BoutonMerge.Crop_Props = regionprops(double(BoutonMerge.AllBoutonsRegion_Orig), 'BoundingBox');
                BoutonMerge.Crop_Props.BoundingBox(1)=BoutonMerge.Crop_Props.BoundingBox(1)-AutoCropBuffer;
                BoutonMerge.Crop_Props.BoundingBox(2)=BoutonMerge.Crop_Props.BoundingBox(2)-AutoCropBuffer;
                BoutonMerge.Crop_Props.BoundingBox(3)=BoutonMerge.Crop_Props.BoundingBox(3)+AutoCropBuffer*2;
                BoutonMerge.Crop_Props.BoundingBox(4)=BoutonMerge.Crop_Props.BoundingBox(4)+AutoCropBuffer*2;
                if BoutonMerge.Crop_Props.BoundingBox(1)<1
                    BoutonMerge.Crop_Props.BoundingBox(1)=1;
                end
                if BoutonMerge.Crop_Props.BoundingBox(2)<1
                    BoutonMerge.Crop_Props.BoundingBox(2)=1;
                end
                if BoutonMerge.Crop_Props.BoundingBox(3)>size(RegistrationSettings.OverallReferenceImage,2)
                    BoutonMerge.Crop_Props.BoundingBox(3)=size(RegistrationSettings.OverallReferenceImage,2);
                end
                if BoutonMerge.Crop_Props.BoundingBox(4)>size(RegistrationSettings.OverallReferenceImage,1)
                    BoutonMerge.Crop_Props.BoundingBox(4)=size(RegistrationSettings.OverallReferenceImage,1);
                end             
                BoutonMerge.Crop_Region=zeros(size(BoutonMerge.AllBoutonsRegion_Orig));
                BoutonMerge.Crop_Region(floor(BoutonMerge.Crop_Props.BoundingBox(2)):1:floor(BoutonMerge.Crop_Props.BoundingBox(2))+floor(BoutonMerge.Crop_Props.BoundingBox(4)),floor(BoutonMerge.Crop_Props.BoundingBox(1)):1:floor(BoutonMerge.Crop_Props.BoundingBox(1))+floor(BoutonMerge.Crop_Props.BoundingBox(3)))=1;
            end
            figure
            imshow(BoutonMerge.AllBoutonsRegion_Orig);
            figure
            imshow(RegistrationSettings.OverallReferenceImage,[],'Border','tight')
            hold on
            for Bouton=1:length(BoutonArray)
                if any(BoutonArray(Bouton).AllBoutonsRegion_Orig(:)~=0)
                    for j=1:length(BoutonArray(Bouton).BorderLine_Orig)
                        plot(BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,2),...
                            BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,1),...
                            '-','color',BoutonArray(Bouton).Color,'linewidth',1)
                    end
                    plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1),BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2),BoutonArray(Bouton).Crop_Props.BoundingBox(2)],'-','color',BoutonArray(Bouton).Color,'LineWidth',1);
                    plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1),BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4),BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4)],'-','color',BoutonArray(Bouton).Color,'LineWidth',1);
                    plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1),BoutonArray(Bouton).Crop_Props.BoundingBox(1)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2),BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4)],'-','color',BoutonArray(Bouton).Color,'LineWidth',1);
                    plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3),BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2),BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4)],'-','color',BoutonArray(Bouton).Color,'LineWidth',1); 
                end
            end
            hold on
            for MarkerCount1=1:length(MarkerSetInfo.Markers)
                if isfield(MarkerSetInfo.Markers,'ROI')
                    for MarkerROI1=1:length(MarkerSetInfo.Markers(MarkerCount1).ROI)
                        for j=1:length(MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine_Orig)
                            plot(MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine_Orig{j}.BorderLine(:,2),...
                                MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine_Orig{j}.BorderLine(:,1),...
                                MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILineStyle,...
                                'color',MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIColor,'linewidth',2)
                        end
                    end
                end
            end
            hold on
            text(10, 10, 'Auto Crop Box Region, Enter 1 to Manual Select','color','y','FontSize',12');
            plot([BoutonMerge.Crop_Props.BoundingBox(1),BoutonMerge.Crop_Props.BoundingBox(1)+BoutonMerge.Crop_Props.BoundingBox(3)],[BoutonMerge.Crop_Props.BoundingBox(2),BoutonMerge.Crop_Props.BoundingBox(2)],'-','color','y','LineWidth',3);plot([BoutonMerge.Crop_Props.BoundingBox(1),BoutonMerge.Crop_Props.BoundingBox(1)+BoutonMerge.Crop_Props.BoundingBox(3)],[BoutonMerge.Crop_Props.BoundingBox(2)+BoutonMerge.Crop_Props.BoundingBox(4),BoutonMerge.Crop_Props.BoundingBox(2)+BoutonMerge.Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3);
            plot([BoutonMerge.Crop_Props.BoundingBox(1),BoutonMerge.Crop_Props.BoundingBox(1)],[BoutonMerge.Crop_Props.BoundingBox(2),BoutonMerge.Crop_Props.BoundingBox(2)+BoutonMerge.Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3);plot([BoutonMerge.Crop_Props.BoundingBox(1)+BoutonMerge.Crop_Props.BoundingBox(3),BoutonMerge.Crop_Props.BoundingBox(1)+BoutonMerge.Crop_Props.BoundingBox(3)],[BoutonMerge.Crop_Props.BoundingBox(2),BoutonMerge.Crop_Props.BoundingBox(2)+BoutonMerge.Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3); 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            BringAllToFront;
            %ReDo=input('Enter 1 to Manual Select Crop Box: ');
            RepeatSelection = questdlg(['Do you want to repeat/adjust Bouton Merge Cropping?'],'Repeat?','Repeat','Continue','Continue');
            switch RepeatSelection
                case 'Repeat'
                    ReDo=1;
                case 'Continue'
                    ReDo=0;
            end

            while ReDo
                figure
                imshow(RegistrationSettings.OverallReferenceImage,[],'Border','tight')
                hold on
                BoutonMerge.AllBoutonsRegion_Orig=zeros(size(RegistrationSettings.OverallReferenceImage));
                for Bouton=1:length(BoutonArray)
                    if any(BoutonArray(Bouton).AllBoutonsRegion_Orig(:)~=0)
                        for j=1:length(BoutonArray(Bouton).BorderLine_Orig)
                            plot(BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,2),...
                                BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,1),...
                                '-','color',BoutonArray(Bouton).Color,'linewidth',1)
                        end
                        plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1),BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2),BoutonArray(Bouton).Crop_Props.BoundingBox(2)],'-','color',BoutonArray(Bouton).Color,'LineWidth',1);
                        plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1),BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4),BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4)],'-','color',BoutonArray(Bouton).Color,'LineWidth',1);
                        plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1),BoutonArray(Bouton).Crop_Props.BoundingBox(1)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2),BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4)],'-','color',BoutonArray(Bouton).Color,'LineWidth',1);
                        plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3),BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2),BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4)],'-','color',BoutonArray(Bouton).Color,'LineWidth',1); 
                    end
                end
                hold on
                for MarkerCount1=1:length(MarkerSetInfo.Markers)
                    if isfield(MarkerSetInfo.Markers,'ROI')
                        for MarkerROI1=1:length(MarkerSetInfo.Markers(MarkerCount1).ROI)
                            for j=1:length(MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine_Orig)
                                plot(MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine_Orig{j}.BorderLine(:,2),...
                                    MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine_Orig{j}.BorderLine(:,1),...
                                    MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILineStyle,'color',MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIColor,'linewidth',2)
                            end
                        end
                    end
                end
                hold on
                plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1),BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2),BoutonArray(Bouton).Crop_Props.BoundingBox(2)],'-','color',BorderColor_Ib,'LineWidth',1);plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1),BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4),BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4)],'-','color',BorderColor_Ib,'LineWidth',1);
                plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1),BoutonArray(Bouton).Crop_Props.BoundingBox(1)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2),BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4)],'-','color',BorderColor_Ib,'LineWidth',1);plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3),BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2),BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4)],'-','color',BorderColor_Ib,'LineWidth',1); 
                BoutonMerge.Crop_Region = roipoly;
                BoutonMerge.Crop_Props = regionprops(double(BoutonMerge.Crop_Region), 'BoundingBox');
                plot([BoutonMerge.Crop_Props.BoundingBox(1),BoutonMerge.Crop_Props.BoundingBox(1)+BoutonMerge.Crop_Props.BoundingBox(3)],[BoutonMerge.Crop_Props.BoundingBox(2),BoutonMerge.Crop_Props.BoundingBox(2)],'-','color','y','LineWidth',3);plot([BoutonMerge.Crop_Props.BoundingBox(1),BoutonMerge.Crop_Props.BoundingBox(1)+BoutonMerge.Crop_Props.BoundingBox(3)],[BoutonMerge.Crop_Props.BoundingBox(2)+BoutonMerge.Crop_Props.BoundingBox(4),BoutonMerge.Crop_Props.BoundingBox(2)+BoutonMerge.Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3);
                plot([BoutonMerge.Crop_Props.BoundingBox(1),BoutonMerge.Crop_Props.BoundingBox(1)],[BoutonMerge.Crop_Props.BoundingBox(2),BoutonMerge.Crop_Props.BoundingBox(2)+BoutonMerge.Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3);plot([BoutonMerge.Crop_Props.BoundingBox(1)+BoutonMerge.Crop_Props.BoundingBox(3),BoutonMerge.Crop_Props.BoundingBox(1)+BoutonMerge.Crop_Props.BoundingBox(3)],[BoutonMerge.Crop_Props.BoundingBox(2),BoutonMerge.Crop_Props.BoundingBox(2)+BoutonMerge.Crop_Props.BoundingBox(4)],'-','color','y','LineWidth',3); 
                hold off
                RepeatSelection = questdlg(['Do you want to repeat/adjust Bouton Merge Cropping?'],'Repeat?','Repeat','Continue','Continue');
                switch RepeatSelection
                    case 'Repeat'
                        ReDo=1;
                    case 'Continue'
                        ReDo=0;
                end
            end
            BoutonMerge.ReferenceImage=imcrop(RegistrationSettings.OverallReferenceImage,BoutonMerge.Crop_Props.BoundingBox);
            BoutonMerge.AllBoutonsRegion=imcrop(BoutonMerge.AllBoutonsRegion_Orig,BoutonMerge.Crop_Props.BoundingBox);
            BoutonMerge.Image_Height=size(BoutonMerge.AllBoutonsRegion,1);
            BoutonMerge.Image_Width=size(BoutonMerge.AllBoutonsRegion,2);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for Bouton=1:length(BoutonArray)
                if any(BoutonArray(Bouton).AllBoutonsRegion_Orig(:)~=0)
                     BoutonMerge.BoutonArray(Bouton).Label=BoutonArray(Bouton).Label;
                     BoutonMerge.BoutonArray(Bouton).BoutonSuffix=BoutonArray(Bouton).BoutonSuffix;

                    BoutonMerge.BoutonArray(Bouton).Color=BoutonArray(Bouton).Color;
                    BoutonMerge.BoutonArray(Bouton).AllBoutonsRegion=ArrayCrop(BoutonArray(Bouton).AllBoutonsRegion_Orig,BoutonMerge.Crop_Props.BoundingBox);
                    BoutonMerge.BoutonArray(Bouton).AllBoutonsRegionPerim=bwperim(BoutonMerge.BoutonArray(Bouton).AllBoutonsRegion);
                    if ~isempty(DilateRegion)
                        [B,L] = bwboundaries(imdilate(BoutonMerge.BoutonArray(Bouton).AllBoutonsRegion,DilateRegion),'noholes');
                    else
                        [B,L] = bwboundaries(BoutonMerge.BoutonArray(Bouton).AllBoutonsRegion,'noholes');
                    end
                    for j=1:length(B)
                        for k = 1:length(B{j})
                            BoutonMerge.BoutonArray(Bouton).BorderLine{j}.BorderLine(k,:) = B{j}(k,:);
                        end
                    end
                end   
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isempty(MarkerSetInfo.Markers)
                BoutonMerge.MarkerSetInfo.Markers=[];
            else
                BoutonMerge.MarkerSetInfo.Markers=MarkerSetInfo.Markers;
                for MarkerCount=1:length(MarkerSetInfo.Markers)
                    if isfield(MarkerSetInfo.Markers,'ROI')
                        for MarkerROI=1:length(MarkerSetInfo.Markers(MarkerCount).ROI)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILabel=...
                            MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILabel;
                        BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIShortLabel=...
                            MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIShortLabel;
                        BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIColor=...
                            MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIColor;
                        BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILineStyle=...
                            MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILineStyle;
                        BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBouton=...
                            MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBouton;
                        BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBoutonCount=...
                            MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBoutonCount;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIMask=...
                            imcrop(MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIMask_Orig,BoutonMerge.Crop_Props.BoundingBox);
                        [BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBorderLine]=...
                            FindROIBorders(BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIMask,DilateRegion);
                        BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIMask_Crop=...
                            imcrop(BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIMask,...
                            BoutonArray(BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBoutonCount).Crop_Props.BoundingBox);
                        [BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIBorderLine_Crop]=...
                            FindROIBorders(BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROIMask_Crop,DilateRegion);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    end
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if length(ImagingInfo.ActiveBoutons)==1
                BoutonMerge.ScaleBar=BoutonArray(ImagingInfo.ActiveBoutons).ScaleBar;
                figure
                imshow(BoutonMerge.ReferenceImage,[],'Border','tight')
                hold on
                for Bouton=1:length(BoutonMerge.BoutonArray)
                    for j=1:length(BoutonMerge.BoutonArray(Bouton).BorderLine)
                        plot(BoutonMerge.BoutonArray(Bouton).BorderLine{j}.BorderLine(:,2),...
                            BoutonMerge.BoutonArray(Bouton).BorderLine{j}.BorderLine(:,1),...
                            '-','color',BoutonMerge.BoutonArray(Bouton).Color,'linewidth',1)
                    end
                end
                hold on
                for MarkerCount1=1:length(BoutonMerge.MarkerSetInfo.Markers)
                    if isfield(BoutonMerge.MarkerSetInfo.Markers,'ROI')
                        for MarkerROI1=1:length(BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI)
                            for j=1:length(BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine)
                                plot(BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine{j}.BorderLine(:,2),...
                                    BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine{j}.BorderLine(:,1),...
                                    BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILineStyle,'color',BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIColor,'linewidth',2)
                            end
                        end
                    end
                end
                plot(BoutonMerge.ScaleBar.XData,BoutonMerge.ScaleBar.YData,...
                    '-','color',BoutonMerge.ScaleBar.Color,'linewidth',BoutonMerge.ScaleBar.Width);
                %ScaleBarSelecting=input('Enter 1 to Move Scalebar: ');
                RepeatSelection = questdlg(['Do you want to move BoutonMerge Scale Bar?'],'Repeat?','Move','Continue','Continue');
                switch RepeatSelection
                    case 'Move'
                        ScaleBarSelecting=1;
                    case 'Continue'
                        ScaleBarSelecting=0;
                end
                
            else
                ScaleBarSelecting=1;
            end
            while ScaleBarSelecting==1
                BoutonMerge.ScaleBar.ScaleFactor=ImagingInfo.PixelSize; %um per pixel 
                NewScaleBar=1;
                if NewScaleBar==1
                    close all
                    figure
                    imshow(BoutonMerge.ReferenceImage,[],'Border','tight')
                    hold on
                    for BoutonCount=1:length(BoutonMerge.BoutonArray)
                        for j=1:length(BoutonMerge.BoutonArray(BoutonCount).BorderLine)
                            plot(BoutonMerge.BoutonArray(BoutonCount).BorderLine{j}.BorderLine(:,2),...
                                BoutonMerge.BoutonArray(BoutonCount).BorderLine{j}.BorderLine(:,1),...
                                '-','color',BoutonMerge.BoutonArray(BoutonCount).Color,'linewidth',1)
                        end
                    end
                    set(gcf,'position',[0 50 BoutonMerge.Image_Width*2 BoutonMerge.Image_Height*2])
                    RepeatPrompt=1;
                    while RepeatPrompt==1
                        prompt = {'Scale Bar Length (um)','Scale Bar Width','Scale Bar Pixel Width','Scale Bar Color','Define Left or Right Edge (L/R)'};
                        dlg_title = 'Confirm Scale Bar Properties';
                        num_lines = 1;
                        def = {num2str(DefaultScalebarLength_um),num2str(DefaultScaleBarLineWidth),num2str(DefaultScaleBarPixelWidth),'w','L'};
                        answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',1);
                        BoutonMerge.ScaleBar.Length=str2num(answer{1});
                        BoutonMerge.ScaleBar.Width=str2num(answer{2});
                        BoutonMerge.ScaleBar.PixelWidth=str2num(answer{3});
                        BoutonMerge.ScaleBar.Color=answer{4};
                        BoutonMerge.ScaleBar.PointerSide=answer{5};
                        clear answer;
                        if strcmp(BoutonMerge.ScaleBar.PointerSide,'L')||strcmp(BoutonMerge.ScaleBar.PointerSide,'R')
                            RepeatPrompt=0;
                        else
                            disp('Error with inputs try again')
                            RepeatPrompt=1;
                        end
                    end
                    GoodScaleBar=0;
                    while GoodScaleBar==0
                        if strcmp(BoutonMerge.ScaleBar.PointerSide,'L')
                            hold on
                            text(10, 20, 'Place left corner of scale bar (enter when complete)','color','y','FontSize',12');
                            plot([10 10+BoutonMerge.ScaleBar.Length/BoutonMerge.ScaleBar.ScaleFactor],[10 10],'-','color','y','LineWidth',BoutonMerge.ScaleBar.Width); hold off;
                            [BoutonMerge.ScaleBar.XCoordinate BoutonMerge.ScaleBar.YCoordinate]=ginput_w(1); %mark left corner of BoutonMerge.ScaleBar location
                            if BoutonMerge.ScaleBar.XCoordinate+BoutonMerge.ScaleBar.Length/BoutonMerge.ScaleBar.ScaleFactor>=size(BoutonArray(BoutonCount).ReferenceImage,2);
                                disp('Scale Bar will not fit in window!, Please retry')
                            else
                                GoodScaleBar=1;
                            end
                        elseif strcmp(BoutonMerge.ScaleBar.PointerSide,'R')
                            hold on
                            text(10, 20, 'Place right corner of scale bar (enter when complete)','color','y','FontSize',12');
                            plot([10 10+BoutonMerge.ScaleBar.Length/BoutonMerge.ScaleBar.ScaleFactor],[10 10],'-','color','y','LineWidth',BoutonMerge.ScaleBar.Width); hold off;
                            [BoutonMerge.ScaleBar.XCoordinate BoutonMerge.ScaleBar.YCoordinate]=ginput_w(1); %mark right corner of scalebar location
                            if BoutonMerge.ScaleBar.XCoordinate-BoutonMerge.ScaleBar.Length/BoutonMerge.ScaleBar.ScaleFactor<=0;
                                disp('Scale Bar will not fit in window!, Please retry')
                            else
                                GoodScaleBar=1;
                            end
                        end

                    end
                end
                BoutonMerge.ScaleBar.ColorCode=ColorDefinitions(BoutonMerge.ScaleBar.Color);
                if strcmp(BoutonMerge.ScaleBar.PointerSide,'L')
                    BoutonMerge.ScaleBar.XData=[BoutonMerge.ScaleBar.XCoordinate BoutonMerge.ScaleBar.XCoordinate+BoutonMerge.ScaleBar.Length/BoutonMerge.ScaleBar.ScaleFactor];
                elseif strcmp(BoutonMerge.ScaleBar.PointerSide,'R')
                    BoutonMerge.ScaleBar.XData=[BoutonMerge.ScaleBar.XCoordinate-BoutonMerge.ScaleBar.Length/BoutonMerge.ScaleBar.ScaleFactor BoutonMerge.ScaleBar.XCoordinate];
                end
                BoutonMerge.ScaleBar.YData=[BoutonMerge.ScaleBar.YCoordinate BoutonMerge.ScaleBar.YCoordinate];
                BoutonMerge.ScaleBar.PixelLength=round(BoutonMerge.ScaleBar.Length/BoutonMerge.ScaleBar.ScaleFactor);
                BoutonMerge.ScaleBar.BoutonMerge.ScaleBarMask=zeros(size(BoutonArray(BoutonCount).ReferenceImage));
                if strcmp(BoutonMerge.ScaleBar.PointerSide,'L')
                    BoutonMerge.ScaleBar.BoutonMerge.ScaleBarMask(round(BoutonMerge.ScaleBar.YCoordinate):round(BoutonMerge.ScaleBar.YCoordinate)+BoutonMerge.ScaleBar.PixelWidth-1,round(BoutonMerge.ScaleBar.XCoordinate):round(BoutonMerge.ScaleBar.XCoordinate)+BoutonMerge.ScaleBar.PixelLength)=1;
                elseif strcmp(BoutonMerge.ScaleBar.PointerSide,'R')
                    BoutonMerge.ScaleBar.BoutonMerge.ScaleBarMask(round(BoutonMerge.ScaleBar.YCoordinate):round(BoutonMerge.ScaleBar.YCoordinate)+BoutonMerge.ScaleBar.PixelWidth-1,round(BoutonMerge.ScaleBar.XCoordinate)-BoutonMerge.ScaleBar.PixelLength:round(BoutonMerge.ScaleBar.XCoordinate))=1;
                end
                BoutonMerge.ScaleBar.BoutonMerge.ScaleBarMask=logical(BoutonMerge.ScaleBar.BoutonMerge.ScaleBarMask);
                TempImage=BoutonMerge.ReferenceImage;
                BoutonMerge.ScaleBar.ScaleBarBurnDisplayImage = imoverlay(mat2gray(TempImage), BoutonMerge.ScaleBar.BoutonMerge.ScaleBarMask, BoutonMerge.ScaleBar.ColorCode);
                figure
                imshow(BoutonMerge.ReferenceImage,[],'Border','tight')
                hold on
                for BoutonCount=1:length(BoutonMerge.BoutonArray)
                    for j=1:length(BoutonMerge.BoutonArray(BoutonCount).BorderLine)
                        plot(BoutonMerge.BoutonArray(BoutonCount).BorderLine{j}.BorderLine(:,2),...
                            BoutonMerge.BoutonArray(BoutonCount).BorderLine{j}.BorderLine(:,1),...
                            '-','color',BoutonMerge.BoutonArray(BoutonCount).Color,'linewidth',1)
                    end
                end
                hold on
                plot(BoutonMerge.ScaleBar.XData,BoutonMerge.ScaleBar.YData,...
                    '-','color',BoutonMerge.ScaleBar.Color,'linewidth',BoutonMerge.ScaleBar.Width);
                set(gcf,'position',[100 200 BoutonMerge.Image_Width*2 BoutonMerge.Image_Height*2])

                RepeatSelection = questdlg('Do you want to Repeat Bouton Merge scale bar placement?','Repeat?','Repeat','Continue','Continue');
                switch RepeatSelection
                    case 'Repeat'
                        ScaleBarSelecting=1;
                    case 'Continue'
                        ScaleBarSelecting=0;
                end
                if ScaleBarSelecting==1
                    GoodScaleBar=0;NewScaleBar=1;
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            close all
            figure
            imshow(BoutonMerge.ReferenceImage,[],'Border','tight')
            hold on
            for Bouton=1:length(BoutonMerge.BoutonArray)
                for j=1:length(BoutonMerge.BoutonArray(Bouton).BorderLine)
                    plot(BoutonMerge.BoutonArray(Bouton).BorderLine{j}.BorderLine(:,2),...
                        BoutonMerge.BoutonArray(Bouton).BorderLine{j}.BorderLine(:,1),...
                        '-','color',BoutonMerge.BoutonArray(Bouton).Color,'linewidth',1)
                end
            end
            hold on
            for MarkerCount1=1:length(BoutonMerge.MarkerSetInfo.Markers)
                if isfield(BoutonMerge.MarkerSetInfo.Markers,'ROI')
                    for MarkerROI1=1:length(BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI)
                        for j=1:length(BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine)
                            plot(BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine{j}.BorderLine(:,2),...
                                BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine{j}.BorderLine(:,1),...
                                BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILineStyle,'color',BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIColor,'linewidth',2)
                        end
                    end
                end
            end
            plot(BoutonMerge.ScaleBar.XData,BoutonMerge.ScaleBar.YData,...
                '-','color',BoutonMerge.ScaleBar.Color,'linewidth',BoutonMerge.ScaleBar.Width);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %BoutonMerging=InputWithVerification('Enter <1> to repeate Bouton merging: ',{[],[1]},0); 
            RepeatSelection = questdlg('Do you want to Repeat Bouton Mergeing?','Repeat?','Repeat','Continue','Continue');
            switch RepeatSelection
                case 'Repeat'
                    BoutonMerging=1;
                case 'Continue'
                    BoutonMerging=0;
            end
        end
    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        close all
        figure
        imshow(BoutonMerge.ReferenceImage,[],'Border','tight')
        hold on
        for Bouton=1:length(BoutonMerge.BoutonArray)
            for j=1:length(BoutonMerge.BoutonArray(Bouton).BorderLine)
                plot(BoutonMerge.BoutonArray(Bouton).BorderLine{j}.BorderLine(:,2),...
                    BoutonMerge.BoutonArray(Bouton).BorderLine{j}.BorderLine(:,1),...
                    '-','color',BoutonMerge.BoutonArray(Bouton).Color,'linewidth',1)
            end
        end
        hold on
        for MarkerCount1=1:length(BoutonMerge.MarkerSetInfo.Markers)
            for MarkerROI1=1:length(BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI)
                for j=1:length(BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine)
                    plot(BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine{j}.BorderLine(:,2),...
                        BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIBorderLine{j}.BorderLine(:,1),...
                        BoutonMerge.MarkerSetInfo.Markers(MarkerCount).ROI(MarkerROI).ROILineStyle,'color',BoutonMerge.MarkerSetInfo.Markers(MarkerCount1).ROI(MarkerROI1).ROIColor,'linewidth',2)
                end
            end
        end
        plot(BoutonMerge.ScaleBar.XData,BoutonMerge.ScaleBar.YData,...
            '-','color',BoutonMerge.ScaleBar.Color,'linewidth',BoutonMerge.ScaleBar.Width);
        pause(0.1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%               STAGE 0              %
%       AnalysisPart 8               %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if any(AnalysisParts==8)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Export RecordingLists_Stage2.txt Ib/Is Merge
    if ~exist([CurrentSaveDir,dc,'Lists'])
        mkdir([CurrentSaveDir,dc,'Lists'])
    end
    clear InfoArray
    CurrentLine=0;
    for zzzzzz=1:1
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='CurrentParentDir=[]';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    ImageSetSaveName=[SaveName,ImagingInfo.ModalitySuffix];
    InfoArray{CurrentLine+1,1}=['RecNum=RecNum+1;'];
    InfoArray{CurrentLine+2,1}=['Recording(RecNum).dir=               [CurrentParentDir,''',SaveDir,'''];'];
    InfoArray{CurrentLine+3,1}=['Recording(RecNum).SaveName=          ''',SaveName,'''',';'];
    InfoArray{CurrentLine+4,1}=['Recording(RecNum).ModalitySuffix=    ''',ImagingInfo.ModalitySuffix,''';'];
    InfoArray{CurrentLine+5,1}=['Recording(RecNum).BoutonSuffix=      [];'];
    InfoArray{CurrentLine+6,1}=['Recording(RecNum).ImageSetSaveName=  ''',ImageSetSaveName,''';'];
    InfoArray{CurrentLine+7,1}=['Recording(RecNum).StackSaveName=     ''',ImageSetSaveName,''';'];
    CurrentLine=CurrentLine+8;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    disp(['Successfully added: ',ImageSetSaveName])
    dlmcell([CurrentSaveDir,dc,'Lists',dc,SaveName,ImagingInfo.ModalitySuffix,' RecordingLists_Stage2.txt'], InfoArray);
    open([CurrentSaveDir,dc,'Lists',dc,SaveName,ImagingInfo.ModalitySuffix,' RecordingLists_Stage2.txt']);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Export RecordingLists_Stage1.txt Separate Bouton
    clear InfoArray
    CurrentLine=0;
    for zzzzzz=1:1
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
    InfoArray{CurrentLine,1}='CurrentParentDir=[]';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    for BoutonCount=1:length(BoutonArray)
        if any(ImagingInfo.ActiveBoutons==BoutonCount)
            ImageSetSaveName=[SaveName,ImagingInfo.ModalitySuffix];
            StackSaveName=[SaveName,ImagingInfo.ModalitySuffix,BoutonArray(BoutonCount).BoutonSuffix];
            InfoArray{CurrentLine+1,1}=['RecNum=RecNum+1;'];
            InfoArray{CurrentLine+2,1}=['Recording(RecNum).dir=               [CurrentParentDir,''',SaveDir,'''];'];
            InfoArray{CurrentLine+3,1}=['Recording(RecNum).SaveName=          ''',SaveName,'''',';'];
            InfoArray{CurrentLine+4,1}=['Recording(RecNum).ModalitySuffix=    ''',ImagingInfo.ModalitySuffix,''';'];
            InfoArray{CurrentLine+5,1}=['Recording(RecNum).BoutonSuffix=      ''',BoutonArray(BoutonCount).BoutonSuffix,''';'];
            InfoArray{CurrentLine+6,1}=['Recording(RecNum).ImageSetSaveName=  ''',ImageSetSaveName,''';'];
            InfoArray{CurrentLine+7,1}=['Recording(RecNum).StackSaveName=     ''',StackSaveName,''';'];
            CurrentLine=CurrentLine+8;
            InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
            disp(['Successfully added: ',StackSaveName])
            %CurrentLine=CurrentLine+1;
        end
    end
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    CurrentLine=CurrentLine+1;
    InfoArray{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
    dlmcell([CurrentSaveDir,dc,'Lists',dc,SaveName,ImagingInfo.ModalitySuffix,' RecordingLists_Stage1.txt'], InfoArray);
    open([CurrentSaveDir,dc,'Lists',dc,SaveName,ImagingInfo.ModalitySuffix,' RecordingLists_Stage1.txt']);

    end
    pause(0.1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if TutorialNotes
        Instructions={'Dont forget to copy the recording lists to a master list';...
            'of your recording lists for future use with the batch processing';...
            'Though I save a copy of the formatted lists for each recording';...
            'In the respective directory'};
        TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
        if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
            TutorialNotes=0;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%               STAGE 0              %
%       AnalysisPart 9               %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if any(AnalysisParts==9)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Saving Data...')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TempDir=[CurrentScratchDir,ImagingInfo.ModalitySuffix,dc];
if ~exist(TempDir)
    mkdir(TempDir)
end
FileSuffix='_ImageData.mat';
fprintf(['Saving: ',SaveName,ImagingInfo.ModalitySuffix,FileSuffix,'...'])
save([TempDir,SaveName,ImagingInfo.ModalitySuffix,FileSuffix],...
    'ImageArray','ImageArray_All_Raw','ImageArray_FirstImages','SaveName')
fprintf('Finished!\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ImageSetSaveName=[SaveName,ImagingInfo.ModalitySuffix];
TempDir=[CurrentScratchDir,ImagingInfo.ModalitySuffix,dc];
if ~exist(TempDir)
    mkdir(TempDir)
end
FileSuffix='_ImageSet_Analysis_Setup.mat';
fprintf(['Saving: ',SaveName,ImagingInfo.ModalitySuffix,FileSuffix,'...'])
save([TempDir,SaveName,ImagingInfo.ModalitySuffix,FileSuffix],...
    'LoadingInfo',...
    'MetaDataRecord',...
    'ImagingInfo',...
    'RegistrationSettings',...
    'BoutonArray',...
    'MarkerSetInfo',...
    'SaveName',...
    'ImageSetSaveName',...
    'Genotype',...
    'BoutonMerge')
fprintf('Finished!\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for BoutonCount=1:length(BoutonArray)
    if any(ImagingInfo.ActiveBoutons==BoutonCount)
        TempDir=[CurrentScratchDir,ImagingInfo.ModalitySuffix,BoutonArray(BoutonCount).BoutonSuffix,dc];
        if ~exist(TempDir)
            mkdir(TempDir)
        end
        FileSuffix='_Analysis_Setup.mat';
        ImageSetSaveName=[SaveName,ImagingInfo.ModalitySuffix];
        StackSaveName=[SaveName,ImagingInfo.ModalitySuffix,BoutonArray(BoutonCount).BoutonSuffix];
        fprintf(['Saving: ',StackSaveName,FileSuffix,'...'])
        Label=BoutonArray(BoutonCount).Label;
        Suffix=BoutonArray(BoutonCount).BoutonSuffix;
        Color=BoutonArray(BoutonCount).Color;
        AllBoutonsRegion_Orig=BoutonArray(BoutonCount).AllBoutonsRegion_Orig;
        AllBoutonsRegionPerim_Orig=BoutonArray(BoutonCount).AllBoutonsRegionPerim_Orig;
        BorderLine_Orig=BoutonArray(BoutonCount).BorderLine_Orig;
        BorderLine=BoutonArray(BoutonCount).BorderLine;
        Crop_Region=BoutonArray(BoutonCount).Crop_Region;
        Crop_Props=BoutonArray(BoutonCount).Crop_Props;
        Crop_XCoords=BoutonArray(BoutonCount).Crop_XCoords;
        Crop_YCoords=BoutonArray(BoutonCount).Crop_YCoords;
        ReferenceImage=BoutonArray(BoutonCount).ReferenceImage;
        AllBoutonsRegion=BoutonArray(BoutonCount).AllBoutonsRegion;
        AllBoutonsRegionPerim=BoutonArray(BoutonCount).AllBoutonsRegionPerim;
        ScaleBar=BoutonArray(BoutonCount).ScaleBar;
        Image_Height=BoutonArray(BoutonCount).Image_Height;
        Image_Width=BoutonArray(BoutonCount).Image_Width;
        DemonReg=BoutonArray(BoutonCount).DemonReg;
        RegEnhancement=BoutonArray(BoutonCount).RegEnhancement;
        RefRegEnhancement=BoutonArray(BoutonCount).RefRegEnhancement;
        SubBoutonArray=BoutonArray(BoutonCount).SubBoutonArray;
        save([TempDir,StackSaveName,FileSuffix],...
            'SaveName','StackSaveName',...
            'LoadingInfo',...
            'MetaDataRecord',...
            'ImagingInfo',...
            'RegistrationSettings',...
            'BoutonArray',...
            'MarkerSetInfo',...
            'Label',...
            'Suffix',...
            'Color',...
            'AllBoutonsRegion_Orig',...
            'AllBoutonsRegionPerim_Orig',...
            'BorderLine_Orig',...
            'BorderLine',...
            'Crop_Region',...
            'Crop_Props',...
            'Crop_XCoords',...
            'Crop_YCoords',...
            'ReferenceImage',...
            'AllBoutonsRegion',...
            'AllBoutonsRegionPerim',...
            'ScaleBar',...
            'Image_Height',...
            'Image_Width',...
            'DemonReg',...
            'RegEnhancement',...
            'RefRegEnhancement',...
            'SubBoutonArray',...
            'SaveName',...
            'ImageSetSaveName',...
            'Genotype')
        fprintf('Finished!\n')
        clear StackSaveName Label
        clear Suffix Color AllBoutonsRegion_Orig AllBoutonsRegionPerim_Orig
        clear BorderLine_Orig BorderLine Crop_Region Crop_Props Crop_XCoords Crop_YCoords
        clear ReferenceImage AllBoutonsRegion AllBoutonsRegionPerim
        clear ScaleBar Image_Height Image_Width
        clear DemonReg RegEnhancement RefRegEnhancement
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Safe2CopyDelete
    CopyDelete = questdlg('Do you want to COPY all files to FINAL dir and delete CurrentScratchDir versions?','Copy and Delete Files?','Copy and Delete','Skip','Copy and Delete');
else
    CopyDelete=[];
end
SaveDir=CurrentSaveDir;
BadCopy=[];
if Safe2CopyDelete&&strcmp(CopyDelete,'Copy and Delete')
    disp('Copying Files to SaveDir...')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TempDir=[CurrentScratchDir,ImagingInfo.ModalitySuffix,dc];
    TempDir1=[SaveDir,dc,ImagingInfo.ModalitySuffix,dc];
    if ~exist(TempDir1)
        mkdir(TempDir1)
    end
    FileSuffix='_ImageData.mat';
    fprintf(['Copying: ',SaveName,ImagingInfo.ModalitySuffix,FileSuffix,'...'])
    [CopyStatus,CopyMessage]=copyfile([TempDir,SaveName,ImagingInfo.ModalitySuffix,FileSuffix],TempDir1);
    if CopyStatus
        disp('Copy successful!')
        warning('Deleting TempDir Version')
        delete([TempDir,SaveName,ImagingInfo.ModalitySuffix,FileSuffix]);
    else
        error(CopyMessage)
        BadCopy=[BadCopy,1];
    end               
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TempDir=[CurrentScratchDir,ImagingInfo.ModalitySuffix,dc];
    TempDir1=[SaveDir,dc,ImagingInfo.ModalitySuffix,dc];
    if ~exist(TempDir1)
        mkdir(TempDir1)
    end
    FileSuffix='_ImageSet_Analysis_Setup.mat';
    fprintf(['Copying: ',SaveName,ImagingInfo.ModalitySuffix,FileSuffix,'...'])
    [CopyStatus,CopyMessage]=copyfile([TempDir,SaveName,ImagingInfo.ModalitySuffix,FileSuffix],TempDir1);
    if CopyStatus
        disp('Copy successful!')
        warning('Deleting TempDir Version')
        delete([TempDir,SaveName,ImagingInfo.ModalitySuffix,FileSuffix]);
    else
        error(CopyMessage)
        BadCopy=[BadCopy,1];
    end               
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for BoutonCount=1:length(BoutonArray)
        if any(ImagingInfo.ActiveBoutons==BoutonCount)
            TempDir=[CurrentScratchDir,ImagingInfo.ModalitySuffix,BoutonArray(BoutonCount).BoutonSuffix,dc];
            TempDir1=[SaveDir,dc,ImagingInfo.ModalitySuffix,BoutonArray(BoutonCount).BoutonSuffix,dc];
            if ~exist(TempDir1)
                mkdir(TempDir1)
            end
            StackSaveName=[SaveName,ImagingInfo.ModalitySuffix,BoutonArray(BoutonCount).BoutonSuffix];
            FileSuffix='_Analysis_Setup.mat';
            fprintf(['Copying: ',StackSaveName,FileSuffix,'...'])
            [CopyStatus,CopyMessage]=copyfile([TempDir,StackSaveName,FileSuffix],TempDir1);
            if CopyStatus
                disp('Copy successful!')
                warning('Deleting TempDir Version')
                delete([TempDir,StackSaveName,FileSuffix]);
            else
                error(CopyMessage)
                BadCopy=[BadCopy,1];
            end               
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    warning('Deleting Raw Data ON ScratchDir...')
    for fileCount=1:LoadingInfo.NumFiles
        fprintf(['Deleting CurrentScratchDir...File # ',num2str(fileCount),'  FileName: ',LoadingInfo.FileNames{fileCount},'...']);
        LoadingInfo.TempLoadNames{fileCount}=[CurrentScratchDir,dc,LoadingInfo.FileNames{fileCount}];
        delete(LoadingInfo.TempLoadNames{fileCount})
        fprintf('Finished~\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if any(BadCopy)
        warning('NOT REMOVING CurrentScratchDir,ImagingInfo.ModalitySuffix...')
    else
        warning('REMOVING CurrentScratchDir,ImagingInfo.ModalitySuffix...')
        [SUCCESS,MESSAGE,MESSAGEID]=rmdir([CurrentScratchDir,ImagingInfo.ModalitySuffix,dc],'s');
        if SUCCESS
            warning('Successful!')
        else
            warning(MESSAGE)
        end
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    warning('CurrentSaveDir and CurrentScratchDir are the same so not copying or deleting!')
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('StartingDir')
    cd(StartingDir)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Premake all trackers
TrackerDir=[CurrentSaveDir,dc,'Trackers',dc];
if ~exist(TrackerDir)
    mkdir(TrackerDir)
end
AnalysisLabels{1}={'Registration'};
AnalysisLabels{2}={'EventDetection'};
AnalysisLabels{3}={'QuaSOR'};
AnalysisLabels{4}={'Quantal Analysis Evaluation'};
Files2Check{1}='_RegistrationTracker.mat';
Files2Check{2}='_EventDetectionTracker.mat';
Files2Check{3}='_QuaSOR_Tracker.mat';
Files2Check{4}='_Quantal_Evaluation_Tracker.mat';
for BoutonCount=1:length(BoutonArray)
    if any(BoutonArray(BoutonCount).AllBoutonsRegion_Orig(:)~=0)
        StackSaveName=[SaveName,ImagingInfo.ModalitySuffix,BoutonArray(BoutonCount).BoutonSuffix];
        for f=1:length(Files2Check)
            warning(['Generating: ',StackSaveName,Files2Check{f},' for tracking...']);  
            Tracker=0;
            CurrentComputer=compName;
            CurrentOS=OS;
            save([TrackerDir,dc,StackSaveName,Files2Check{f}],'Tracker','CurrentComputer','CurrentOS'); 
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if TutorialNotes
    Instructions={'When Loading Meta data from the files Matlab';...
        'currently has trouble releasing the files back to be';...
        'Deleted. The solution is to restart matlab and run a cleanup loop';...
        'in the next phase'};
    TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
    if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
        TutorialNotes=0;
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%                STOP                %
%                HERE                %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
