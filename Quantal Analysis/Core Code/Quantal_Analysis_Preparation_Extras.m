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
%   %                            %   %
%       %                    %       %
%           %            %           %
%               STAGE 0              %
%               Part 0               %
%           %            %           %
%       %                    %       %
%   %                            %   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This will allow you to jump into the main Preparation script and adjust
%settings safely
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ReLoad Files to adjust settings somewhere above
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LabDefaults=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ReLoadPrep=questdlg('Are you sure you want CLEAR and reload a file preparation?','Reload Prep','Yes','No','Yes'); 
switch ReLoadPrep
    case 'Yes'
        clearvars -except myPool dc OS compName ClentCompName MatlabVersion MatlabVersionYear ScreenSize CurrentScratchDir ScratchDir LabDefaults
        [ScratchDir,dc]=ScratchDir_Lookup(LabDefaults);
        [OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(1);
        ModeChoice = questdlg('Quantal Pipeline Mode?','Quantal Pipeline Mode?','Beginner','Intermediate','Advanced','Advanced');
        if strcmp(ModeChoice,'Advanced')
            TutorialNotes=0;
            AdvancedMode=1;
        elseif strcmp(ModeChoice,'Intermediate')
            TutorialNotes=0;
            AdvancedMode=0;
        elseif strcmp(ModeChoice,'Beginner')
            TutorialNotes=1;
            AdvancedMode=0;
        end
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
            prompt = {['SaveName (Genotype_Protocol_Unique#): '];['Genotype: '];LabDefaults};
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
            InputImagingInfo=InputWithVerification('Enter <1> to RESET ImagingInfo.ModalitySuffix: ',{[],[1]},0);
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
        PlayBackAllFrames=InputWithVerification('Enter <1> to Play ALL FRAMES: ',{[],[1]},0);
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
