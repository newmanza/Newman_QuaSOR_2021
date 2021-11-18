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
if ~exist('ImageSetSaveName')
    warning('Missing ImageSetSaveName fixing in the _Analysis_Setup.mat file') 
    ImageSetSaveName=[SaveName,ImagingInfo.ModalitySuffix];
    save([SaveDir,StackSaveName,'_Analysis_Setup.mat'],'ImageSetSaveName','-append')
end
if isempty(ImageSetSaveName)
    warning('Missing ImageSetSaveName fixing in the _Analysis_Setup.mat file') 
    ImageSetSaveName=[SaveName,ImagingInfo.ModalitySuffix];
    save([SaveDir,StackSaveName,'_Analysis_Setup.mat'],'ImageSetSaveName','-append')
end
disp('============================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FileSuffix='_ImageData.mat';
if ~exist([SaveDir1,ImageSetSaveName,FileSuffix])
    error([ImageSetSaveName,FileSuffix,' Missing!']);  
else
    FileInfo = dir([SaveDir1,ImageSetSaveName,FileSuffix]);
    TimeStamp = FileInfo.date;
    CurrentDateNum=FileInfo.datenum;
    disp([ImageSetSaveName,FileSuffix,' Last updated: ',TimeStamp]);  
    if Safe2CopyDelete
        if ~exist([CurrentScratchDir1,ImageSetSaveName,FileSuffix])
            fprintf(['Copying ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
            [CopyStatus,CopyMessage]=copyfile([SaveDir1,ImageSetSaveName,FileSuffix],CurrentScratchDir1);
            if CopyStatus
                fprintf('Copy successful!\n')
            else
                error(CopyMessage)
            end    
        else
            warning([ImageSetSaveName,FileSuffix,' Already exists on CurrentScratchDir']);
        end
    end
end
fprintf(['Loading ',ImageSetSaveName,FileSuffix,'...']);
load([CurrentScratchDir1,ImageSetSaveName,FileSuffix],'ImageArray','ImageArray_FirstImages');
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%Overall Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%Add Missing Variables
    AbortButton=1;
    if ~exist('SubBoutonArray')
        SubBoutonArray=[];

    end
    if ~exist('SplitEpisodeFile')
        SplitEpisodeFile=0;
    end
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
RunningAnalysis=1;
while RunningAnalysis
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 0
    %Adjust Registration Settings
    if any(AnalysisParts==0)||AdjustONLY
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if size(ImageArray,1)~=size(RegistrationSettings.OverallReferenceImage,1)||...
               size(ImageArray,2)~=size(RegistrationSettings.OverallReferenceImage,2)||...
               size(ImageArray,3)~=ImagingInfo.TotalNumFrames
            warning('Reloading ImageArray...')
            FileSuffix='_ImageData.mat';
            fprintf(['Loading ',ImageSetSaveName,FileSuffix,'...']);
            load([CurrentScratchDir1,ImageSetSaveName,FileSuffix],'ImageArray','ImageArray_FirstImages');
            fprintf('Finished!\n')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [RegistrationSettings,RegEnhancement,RefRegEnhancement,DemonReg]=...
            Enhanced_Multi_Modality_Registration_Setup([SaveName,ImagingInfo.ModalitySuffix,BoutonSuffix],...
            ImageArray,RegistrationSettings.OverallReferenceImage,...
            AllBoutonsRegion_Orig,Crop_Props,...
            ImagingInfo,RegistrationSettings,RegEnhancement,RefRegEnhancement,DemonReg);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix='_Analysis_Setup.mat';
        fprintf(['Saving: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
        save([CurrentScratchDir,StackSaveName,FileSuffix],...
            'RegistrationSettings',...
            'DemonReg',...
            'RegEnhancement',...
            'RefRegEnhancement',...
            '-append')
        fprintf('Finished!\n')  
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('Copying to SaveDir...')
        if exist([CurrentScratchDir,StackSaveName,FileSuffix])
            fprintf(['Copying: ',StackSaveName,FileSuffix,'...'])
            [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
            if CopyStatus
                disp('Copy successful!')
            else
                error(CopyMessage)
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 1
    %Primary Registration
    if any(AnalysisParts==1)&&~AdjustONLY
        if exist('myPool')
            try
                if isempty(myPool.IdleTimeout)
                    disp('Parpool timed out! Restarting now...')
                    delete(gcp('nocreate'))
                    myPool=parpool;%
                else
                    disp('Parpool active...')
                end
            catch
                delete(gcp('nocreate'))
                myPool=parpool;
            end
        else
            delete(gcp('nocreate'))
            myPool=parpool;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if size(ImageArray,1)~=size(RegistrationSettings.OverallReferenceImage,1)||...
               size(ImageArray,2)~=size(RegistrationSettings.OverallReferenceImage,2)||...
               size(ImageArray,3)~=ImagingInfo.TotalNumFrames
            warning('Reloading ImageArray...')
            FileSuffix='_ImageData.mat';
            fprintf(['Loading ',ImageSetSaveName,FileSuffix,'...']);
            load([CurrentScratchDir1,ImageSetSaveName,FileSuffix],'ImageArray','ImageArray_FirstImages');
            fprintf('Finished!\n')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [ImageArrayReg_AllImages,ImageArrayReg_FirstImages]=...
            Enhanced_Multi_Modality_Registration(myPool,dc,SaveName,StackSaveName,ScratchDir,CurrentScratchDir,FigureSaveDir,...
            ImageArray,ImageArray_FirstImages,...
            ReferenceImage,AllBoutonsRegion,AllBoutonsRegion_Orig,BorderLine_Orig,Crop_Props,SubBoutonArray,...
            ImagingInfo,RegistrationSettings,RegEnhancement,RefRegEnhancement,DemonReg);
        fprintf(['Copying: ',StackSaveName,FileSuffix,'...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
        fprintf('Finished!\n')
    elseif ~AdjustONLY
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix='_RegistrationData.mat';
        fprintf(['Copying: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
        [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
        fprintf(['Loading: ImageArrayReg_AllImages...'])
        load([CurrentScratchDir,StackSaveName,FileSuffix],...
            'ImageArrayReg_AllImages',...
            'ImageArrayReg_FirstImages',...
            'AllBoutonsRegion_Orig_Mask',...
            'AllBoutonsRegion_Orig_Padded',...
            'AllBoutonsRegion_Orig_Mask_Padded',...
            'ReferenceImage_Padded','ReferenceImage_Padded_Masked_Filtered_Enhanced',...
            'DemonReg',...
            'DeltaX_DFTReg_Intermediate_Crop','DeltaY_DFTReg_Intermediate_Crop',...
            'DeltaX_Coarse','DeltaY_Coarse',...
            'DeltaX_DFTReg_Whole','DeltaY_DFTReg_Whole',...
            'Diffphase_DFTReg_Whole','Error_DFTReg_Whole',...
            'DeltaX_All_Translations','DeltaY_All_Translations',...
            'DeltaX_DFTReg_Intermediate_Crop','DeltaY_DFTReg_Intermediate_Crop',...
            'DeltaX_All_Translations_Derivative','DeltaY_All_Translations_Derivative','IsDFTMoving');
        fprintf('Finished!\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 2
    %Separate Episodes Bleach Correction and DeltaF Calculations
    if any(AnalysisParts==2)&&~AdjustONLY
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        run('Multi_Modality_Bleach_Correction.m')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    elseif ~AdjustONLY
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix='_DeltaFData.mat';
        if Safe2CopyDelete
            fprintf(['Copying: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
            [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
        end
        fprintf(['Loading: EpisodeStruct...'])
        load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct','EpisodeStructCurves','SplitEpisodeFiles')
        fprintf('Finished!\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %AnalysisPart 3
    %Figures
    if any(AnalysisParts==3)&&~AdjustONLY
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
        FileSuffix='_RegistrationData.mat';
        load([CurrentScratchDir,StackSaveName,FileSuffix],...
            'AllBoutonsRegion_Orig_Mask',...
            'AllBoutonsRegion_Orig_Padded',...
            'AllBoutonsRegion_Orig_Mask_Padded',...
            'ReferenceImage_Padded','ReferenceImage_Padded_Masked_Filtered_Enhanced',...
            'DemonReg',...
            'DeltaX_DFTReg_Intermediate_Crop','DeltaY_DFTReg_Intermediate_Crop',...
            'DeltaX_Coarse','DeltaY_Coarse',...
            'DeltaX_DFTReg_Whole','DeltaY_DFTReg_Whole',...
            'Diffphase_DFTReg_Whole','Error_DFTReg_Whole',...
            'DeltaX_All_Translations','DeltaY_All_Translations',...
            'DeltaX_DFTReg_Intermediate_Crop','DeltaY_DFTReg_Intermediate_Crop',...
            'DeltaX_All_Translations_Derivative','DeltaY_All_Translations_Derivative','IsDFTMoving');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [ReferenceImage_Padded,ReferenceImage_Padded_Masked_Filtered_Enhanced]=...
            RegistrationImageEnhancement(RegistrationSettings.OverallReferenceImage,AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,BorderLine_Orig,Crop_Props,DemonReg,RefRegEnhancement,[StackSaveName,' ReferenceImage'],FigureSaveDir,1,1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FigName=[StackSaveName , ' DFT Refinement Shifts'];
        ColorSet = varycolor(size(DeltaY_DFTReg_Whole,2));
        figure('name',FigName);
        title(['DFT Refinement Shifts for Whole Image']);
        hold on
        if max(abs(DeltaY_DFTReg_Whole))>0
            ylim([-1.2*max(abs(DeltaY_DFTReg_Whole)),1.2*max(abs(DeltaY_DFTReg_Whole))]);
        end
        if max(abs(DeltaX_DFTReg_Whole))>0
            xlim([-1.2*max(abs(DeltaX_DFTReg_Whole)),1.2*max(abs(DeltaX_DFTReg_Whole))]);
        end
        ylabel('\DeltaY (px)');xlabel('\DeltaX (px)');
        for ImageNumber=1:size(DeltaY_DFTReg_Whole,2) 
            plot(DeltaX_DFTReg_Whole(ImageNumber),DeltaY_DFTReg_Whole(ImageNumber),'.','color',ColorSet(ImageNumber,:),'MarkerSize',10);
        end
        set(gcf, 'color', 'white');
        box off
        hold off
        fprintf(['Saving: ',FigName,'...'])
        saveas(gcf, [FigureSaveDir,dc,FigName, '.fig']);
        Full_Export_Fig(gcf,gca,Check_Dir_and_File(FigureSaveDir,FigName,[],1),1)
        fprintf('Finished!\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(DeltaY_DFTReg_Intermediate_Crop)
            FigName=[StackSaveName , ' Intermediate Crop Region DFT Refinement Shifts'];
            ColorSet = varycolor(size(DeltaY_DFTReg_Intermediate_Crop,2));
            figure('name',FigName);
            title(['Shifts for Intermediate Crop Region']);
            hold on
            ylim([-1.2*max(abs(DeltaY_DFTReg_Intermediate_Crop)),1.2*max(abs(DeltaY_DFTReg_Intermediate_Crop))]); xlim([-1.2*max(abs(DeltaX_DFTReg_Intermediate_Crop)),1.2*max(abs(DeltaX_DFTReg_Intermediate_Crop))]);
            ylabel('\DeltaY (px)');xlabel('\DeltaX (px)');
            for ImageNumber=1:size(DeltaY_DFTReg_Intermediate_Crop,2) 
                plot(DeltaX_DFTReg_Intermediate_Crop(ImageNumber),DeltaY_DFTReg_Intermediate_Crop(ImageNumber),'.','color',ColorSet(ImageNumber,:),'MarkerSize',10);
            end
            set(gcf, 'color', 'white');
            box off
            hold off
            fprintf(['Saving: ',FigName,'...'])
            saveas(gcf, [FigureSaveDir,dc,FigName, '.fig']);
            Full_Export_Fig(gcf,gca,Check_Dir_and_File(FigureSaveDir,FigName,[],1),1)
            fprintf('Finished!\n')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if DemonReg.BoutonRefinement&&exist('SubBoutonArray')
            if isempty(SubBoutonArray)
            else
                %Figure
                FigName=[StackSaveName , ' DFT Refinement Shifts'];
                ColorSet = varycolor(LastBoutonNumber);
                figure('name',['Shfits for Bouton Refinement']);
                title(['Shfits for Bouton Refinement']);
                hold on
                for BoutonNumber=1:LastBoutonNumber
                    for ImageNumber=1:size(ImageArray,3) 
                        plot(DeltaX_DFTReg_Bouton_Intermediate_Crop(BoutonNumber,ImageNumber),DeltaY_DFTReg_Bouton_Intermediate_Crop(BoutonNumber,ImageNumber),'.','color',ColorSet(BoutonNumber,:),'MarkerSize',10);
                    end
                end        
                %ylim([-1*max(abs(DeltaY_DFTReg_Bouton(BoutonNumber,:))),max(abs(DeltaY_DFTReg_Bouton(BoutonNumber,:)))]); xlim([-1*max(abs(DeltaX_DFTReg_Bouton(BoutonNumber,:))),max(abs(DeltaX_DFTReg_Bouton(BoutonNumber,:)))]);
                ylabel('\DeltaY (px)');xlabel('\DeltaX (px)');
                set(gcf, 'color', 'white');
                box off
                hold off    
                fprintf(['Saving: ',FigName,'...'])
                saveas(gcf, [FigureSaveDir,dc,FigName, '.fig']);
                Full_Export_Fig(gcf,gca,Check_Dir_and_File(FigureSaveDir,FigName,[],1),1)
                fprintf('Finished!\n')
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FigName=[StackSaveName , ' DFT Shifts and Derivatives'];
        ColorSet = varycolor(size(DeltaX_DFTReg_Whole,2));
        figure('name',FigName);
        title(['DFT Refinement Shifts for Whole Image']);
        ax(1)=subtightplot(2,2,1,[0.1,0.1]);
        hold on
        if max(abs(DeltaX_DFTReg_Whole))>0
            ylim([-1.2*max(abs(DeltaX_DFTReg_Whole)),1.2*max(abs(DeltaX_DFTReg_Whole))]);
        end
        ylabel('\DeltaX (px)');xlabel('Episode/Image #');
        for EpisodeNumber=1:size(DeltaX_DFTReg_Whole,2) 
            plot(EpisodeNumber,DeltaX_DFTReg_Whole(EpisodeNumber),'.','color',ColorSet(EpisodeNumber,:),'MarkerSize',20);
        end
        set(gcf, 'color', 'white');
        box off
        hold off
        ax(2)=subtightplot(2,2,2,[0.1,0.1]);
        hold on
        if max(abs(DeltaY_DFTReg_Whole))>0
            ylim([-1.2*max(abs(DeltaY_DFTReg_Whole)),1.2*max(abs(DeltaY_DFTReg_Whole))]);
        end
        ylabel('\DeltaY (px)');xlabel('Episode/Image #');
        for EpisodeNumber=1:size(DeltaY_DFTReg_Whole,2) 
            plot(EpisodeNumber,DeltaY_DFTReg_Whole(EpisodeNumber),'.','color',ColorSet(EpisodeNumber,:),'MarkerSize',20);
        end
        set(gcf, 'color', 'white');
        box off
        hold off    
        ax(3)=subtightplot(2,2,3,[0.1,0.1]);
        hold on
        plot(IsDFTMoving*DemonReg.DynamicSmoothingDerivThreshold,'-','color','k')
        plot(IsDFTMoving*DemonReg.DynamicSmoothingDerivThreshold*-1,'-','color','k')
        if max(abs(DeltaX_All_Translations_Derivative))>0
            ylim([-1.2*max(abs(DeltaX_All_Translations_Derivative)),1.2*max(abs(DeltaX_All_Translations_Derivative))]);
        end
        ylabel('\delta\DeltaX (px)');xlabel('Episode/Image #');
        for EpisodeNumber=1:length(DeltaX_All_Translations_Derivative) 
            plot(EpisodeNumber+0.5,DeltaX_All_Translations_Derivative(EpisodeNumber),'.','color',ColorSet(EpisodeNumber,:),'MarkerSize',20);
        end
        set(gcf, 'color', 'white');
        box off
        hold off
        ax(4)=subtightplot(2,2,4,[0.1,0.1]);
        hold on
        plot(IsDFTMoving*DemonReg.DynamicSmoothingDerivThreshold,'-','color','k')
        plot(IsDFTMoving*DemonReg.DynamicSmoothingDerivThreshold*-1,'-','color','k')
        if max(abs(DeltaY_All_Translations_Derivative))>0
            ylim([-1.2*max(abs(DeltaY_All_Translations_Derivative)),1.2*max(abs(DeltaY_All_Translations_Derivative))]);
        end
        ylabel('\delta\DeltaY (px)');xlabel('Episode/Image #');
        for EpisodeNumber=1:length(DeltaY_All_Translations_Derivative)
            plot(EpisodeNumber+0.5,DeltaY_All_Translations_Derivative(EpisodeNumber),'.','color',ColorSet(EpisodeNumber,:),'MarkerSize',20);
        end
        set(gcf, 'color', 'white');
        box off
        hold off  
        set(gcf','units','normalized','position',[0.1,0.1,0.8,0.8]);
        fprintf(['Saving: ',FigName,'...'])
        saveas(gcf, [FigureSaveDir,dc,FigName, '.fig']);
        Full_Export_Fig(gcf,ax,Check_Dir_and_File(FigureSaveDir,FigName,[],1),1)
        fprintf('Finished!\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if DemonReg.CoarseTranslation

            FigName=[StackSaveName , ' All Coarse Translation Shifts'];
            ColorSet = varycolor(size(DeltaX_Coarse,2));
            figure('name',StackSaveName);
            title(['All Translation Shifts for Whole Image']);
            hold on
            if max(abs(DeltaY_Coarse))>0
                ylim([-1.2*max(abs(DeltaY_Coarse)),1.2*max(abs(DeltaY_Coarse))]);
            end
            if max(abs(DeltaX_Coarse))>0
                xlim([-1.2*max(abs(DeltaX_Coarse)),1.2*max(abs(DeltaX_Coarse))]);
            end
            ylabel('\DeltaY (px)');xlabel('\DeltaX (px)');
            for EpisodeNumber=1:size(DeltaX_Coarse,2) 
                plot(DeltaX_Coarse(EpisodeNumber),DeltaY_Coarse(EpisodeNumber),'.','color',ColorSet(EpisodeNumber,:),'MarkerSize',10);
            end
            set(gcf, 'color', 'white');
            box off
            hold off
            fprintf(['Saving: ',FigName,'...'])
            saveas(gcf, [FigureSaveDir,dc,FigName, '.fig']);
            Full_Export_Fig(gcf,gca,Check_Dir_and_File(FigureSaveDir,FigName,[],1),1)
            fprintf('Finished!\n')

            FigName=[StackSaveName , ' All Translation Shifts'];
            ColorSet = varycolor(size(DeltaY_All_Translations,2));
            figure('name',StackSaveName);
            title(['All Translation Shifts for Whole Image']);
            hold on
            if max(abs(DeltaY_All_Translations))>0
                ylim([-1.2*max(abs(DeltaY_All_Translations)),1.2*max(abs(DeltaY_All_Translations))]);
            end
            if max(abs(DeltaX_All_Translations))>0
                xlim([-1.2*max(abs(DeltaX_All_Translations)),1.2*max(abs(DeltaX_All_Translations))]);
            end
            ylabel('\DeltaY (px)');xlabel('\DeltaX (px)');
            for EpisodeNumber=1:size(DeltaY_All_Translations,2) 
                plot(DeltaX_All_Translations(EpisodeNumber),DeltaY_All_Translations(EpisodeNumber),'.','color',ColorSet(EpisodeNumber,:),'MarkerSize',10);
            end
            set(gcf, 'color', 'white');
            box off
            hold off
            fprintf(['Saving: ',FigName,'...'])
            saveas(gcf, [FigureSaveDir,dc,FigName, '.fig']);
            Full_Export_Fig(gcf,gca,Check_Dir_and_File(FigureSaveDir,FigName,[],1),1)
            fprintf('Finished!\n')
        end    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        close all
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
        FileSuffix='_RegistrationData.mat';
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
        load([CurrentScratchDir,StackSaveName,FileSuffix],...
            'AllBoutonsRegion_Orig_Mask',...
            'AllBoutonsRegion_Orig_Padded',...
            'AllBoutonsRegion_Orig_Mask_Padded',...
            'ReferenceImage_Padded','ReferenceImage_Padded_Masked_Filtered_Enhanced',...
            'DemonReg',...
            'DeltaX_DFTReg_Intermediate_Crop','DeltaY_DFTReg_Intermediate_Crop',...
            'DeltaX_Coarse','DeltaY_Coarse',...
            'DeltaX_DFTReg_Whole','DeltaY_DFTReg_Whole',...
            'Diffphase_DFTReg_Whole','Error_DFTReg_Whole',...
            'DeltaX_All_Translations','DeltaY_All_Translations',...
            'DeltaX_DFTReg_Intermediate_Crop','DeltaY_DFTReg_Intermediate_Crop',...
            'DeltaX_All_Translations_Derivative','DeltaY_All_Translations_Derivative','IsDFTMoving');
        if ~exist('ImageArrayReg_AllImages')
            load([CurrentScratchDir,StackSaveName,FileSuffix],...
                'ImageArrayReg_AllImages')
        end

        if ~exist('SplitEpisodeFiles')
            SplitEpisodeFiles=0;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
        run('Quantal_Analysis_Registration_Movie_Records.m')
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
                    run('Quantal_Analysis_Registration_Evaluation.m')
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
    if ~isempty(BatchMode)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Deleting some ScratchDir Files...')
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
    FileSuffix='_DeltaFData.mat';
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
    for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
        if SplitEpisodeFiles
            warning on
            FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
            if Safe2CopyDelete
                if ~isempty(BatchMode)
                    fprintf(['Deleting: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
                    delete([CurrentScratchDir,StackSaveName,FileSuffix])
                    fprintf('Finished!\n')
                end
            else
                fprintf('Finished!\n')
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix='_RegistrationData.mat';
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
    FileSuffix='_DemonRegDispFields.mat';
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
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
        Recording Client_Recording Server_Recording currentFolder File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions BatchMode AnalysisPartsChoiceOptions AnalysisPartOptions RecordingChoiceOptions Function RecordingNum RecordingNum1 RecordingNums RecordingNum1 RecordingNums LastRecording...
        LoopCount File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort Function ErrorTolerant BrokeLoop AbortButton BufferSize Port PortChoice PortOptions PortOptionsText TimeOut NumLoops ServerIP BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
        RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode AdjustOnly
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

