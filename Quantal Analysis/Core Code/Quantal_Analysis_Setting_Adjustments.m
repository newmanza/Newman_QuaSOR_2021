        

RecordingNum=2
[OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(0);
        SaveName=Recording(RecordingNum).SaveName;
        StackSaveName=Recording(RecordingNum).StackSaveName;
        ImageSetSaveName=Recording(RecordingNum).ImageSetSaveName;
        ModalitySuffix=Recording(RecordingNum).ModalitySuffix;
        BoutonSuffix=Recording(RecordingNum).BoutonSuffix;
        LoadDir=Recording(RecordingNum).dir;
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

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        AdjustChoice = questdlg({['Adjust ',AnalysisLabel,' for'];['Recording #',num2str(RecordingNum)];[StackSaveName,'?']},['Adjust?'],'Adjust','Skip','Adjust');
        if strcmp(AdjustChoice,'Adjust')
            Adjusting=1;
        elseif strcmp(AdjustChoice,'Skip')
            Adjusting=0;
        end
        Adjusting=1;
        while Adjusting
            warning(['Adjusting ',AnalysisLabel,' for Recording #',num2str(RecordingNum),' ',StackSaveName])
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~exist('ImagingInfo')
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
                load([CurrentScratchDir,StackSaveName,FileSuffix],'ImagingInfo','BoutonSuffix','RegistrationSettings',...
                    'AllBoutonsRegion_Orig','Crop_Props','RegEnhancement','RefRegEnhancement','DemonReg');
                fprintf('Finished!\n')
                disp('============================================================')
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(AnalysisLabelShort,'Reg')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if ~exist('ImageArray')
                    disp('============================================================')
                    FileSuffix='_ImageData.mat';
                    if ~exist([SaveDir1,ImageSetSaveName,FileSuffix])
                        error([ImageSetSaveName,FileSuffix,' Missing!']);  
                    else
                        FileInfo = dir([SaveDir1,ImageSetSaveName,FileSuffix]);
                        TimeStamp = FileInfo.date;
                        CurrentDateNum=FileInfo.datenum;
                        disp([ImageSetSaveName,FileSuffix,' Last updated: ',TimeStamp]);  
                        if Safe2CopyDelete
                            fprintf(['Copying ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
                            [CopyStatus,CopyMessage]=copyfile([SaveDir1,ImageSetSaveName,FileSuffix],CurrentScratchDir1);
                            if CopyStatus
                                fprintf('Copy successful!\n')
                            else
                                error(CopyMessage)
                            end               
                        end
                    end
                    fprintf(['Loading ',ImageSetSaveName,FileSuffix,'...']);
                    load([CurrentScratchDir1,ImageSetSaveName,FileSuffix],'ImageArray');
                    fprintf('Finished!\n')
                    disp('============================================================')
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                TutorialNotes=0;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                run('Quantal_Analysis_Protocol_Input.m')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [RegEnhancement,RefRegEnhancement,DemonReg]=...
                    Enhanced_Muli_Modality_Registration_Setup([SaveName,ImagingInfo.ModalitySuffix,BoutonSuffix],...
                    RegistrationSettings,ImageArray,RegistrationSettings.OverallReferenceImage,...
                    AllBoutonsRegion_Orig,Crop_Props,...
                    RegEnhancement,RefRegEnhancement,DemonReg);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                
                error('Not ready yet!')
                
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            AdjustingChoice = questdlg({['Re-Adjust ',AnalysisLabel,' for'];['Recording #',num2str(RecordingNum)];[StackSaveName,'?']},['Re-Adjust?'],'Re-Adjust','Good','Good');
            if strcmp(AdjustingChoice,'Re-Adjust')
                Adjusting=1;
            elseif strcmp(AdjustingChoice,'Good')
                Adjusting=0;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SavingChoice = questdlg({['Save ',AnalysisLabel,' Parameters for'];['Recording #',num2str(RecordingNum)];[StackSaveName,'?']},['Save Params?'],'Save','Skip','Save');
        if strcmp(SavingChoice,'Save')
            Saving=1;
        elseif strcmp(SavingChoice,'Skip')
            Saving=0;
        end
        if Saving
            if strcmp(AnalysisLabelShort,'Reg')
                FileSuffix='_Analysis_Setup.mat';
                fprintf(['Saving Updated ',AnalysisLabel,' Parameters to: ',StackSaveName,FileSuffix,'...'])
                save([CurrentScratchDir,StackSaveName,FileSuffix],'RegistrationSettings','RegEnhancement','RefRegEnhancement','DemonReg','-append')
                fprintf('Finished!\n')
                if exist([CurrentScratchDir,StackSaveName,FileSuffix])&&Safe2CopyDelete
                    fprintf(['Copying: ',StackSaveName,FileSuffix,'...'])
                    [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
                    if CopyStatus
                        disp('Copy successful!')
%                         warning('Deleting CurrentScratchDir Version')
%                         delete([CurrentScratchDir,StackSaveName,FileSuffix]);
                    else
                        error(CopyMessage)
                    end
                end
            else
                error('Not ready yet!')
            end
        end
        clear ImageArray ImageArray_FirstImages BoutonSuffix RegistrationSettings AllBoutonsRegion_Orig Crop_Props RegEnhancement RefRegEnhancement DemonReg
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
