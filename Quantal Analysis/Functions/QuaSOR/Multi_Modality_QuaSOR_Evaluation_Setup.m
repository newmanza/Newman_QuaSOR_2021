%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('myPool')
    if ~isempty(myPool)&&myPool.Connected~=0
        disp('Parpool active...')
    else
        delete(gcp('nocreate'))
        myPool=parpool;%
    end
else
    delete(gcp('nocreate'))
    myPool=parpool;%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if QuaSOR_Parameters.QuaSOR_Mode==2
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
    FileSuffix=['_DeltaFData.mat'];
    fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
    load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
    fprintf('Finished!\n')
    FileSuffix=['_EventDetectionData.mat'];
    fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
    load([CurrentScratchDir,StackSaveName,FileSuffix],'EventDetectionStruct')
    fprintf('Finished!\n')
    FileSuffix=['_QuaSOR_Data.mat'];
    fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
    load([CurrentScratchDir,StackSaveName,FileSuffix],'QuaSOR_Fitting_Struct')
    fprintf('Finished!\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ImageWidth=size(AllBoutonsRegion,2);
    ImageHeight=size(AllBoutonsRegion,1);
    ZerosImage=zeros(ImageHeight,ImageWidth);
    ZerosImage_UpScale=zeros(ImageHeight*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,ImageWidth*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor);
    ZerosImage_UpScale_Single=zeros(ImageHeight*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,ImageWidth*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,'single');
    ZerosImage_UpScale_Color=zeros(ImageHeight*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,ImageWidth*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,3);
    x2 = (1/QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor):(1/QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor):size(AllBoutonsRegion,2);
    y2 = (1/QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor):(1/QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor):size(AllBoutonsRegion,1);
    [X2,Y2] = meshgrid(x2,y2);
    StimCount=0;
    StimCount1=0;
    TimerCount=0;
    MovieTimes=[];
    OverallFrameCount=0;
    for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
        if SplitEpisodeFiles
            EpisodeNumber=1;
            FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
            fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
            load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
            fprintf('Finished!\n')
            FileSuffix=['_EventDetectionData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
            fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
            load([CurrentScratchDir,StackSaveName,FileSuffix],'EventDetectionStruct')
            fprintf('Finished!\n')
            FileSuffix=['_QuaSOR_Data_Ep_',num2str(EpisodeNumber_Load),'.mat'];
            fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
            load([CurrentScratchDir,StackSaveName,FileSuffix],'QuaSOR_Fitting_Struct')
            fprintf('Finished!\n')
        else
            EpisodeNumber=EpisodeNumber_Load;
        end
        fprintf(['Finding All Events In Episode ',num2str(EpisodeNumber),'...'])
        Episode_Eval=[];
        ImageArray_Input=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaFF0;
        ImageArray_CorrAmp_Events_Thresh_Clean=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean_Norm;
        ImageArray_Input(isnan(ImageArray_Input))=0;
        ImageArray_CorrAmp_Events_Thresh_Clean(isnan(ImageArray_CorrAmp_Events_Thresh_Clean))=0;
        QuaSOR_Fits=QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits;
        %ImageArray_Max=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_Max;
        if ImagingInfo.ModalityType==1
            CorrAmp_Alt=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.Image_CorrAmp_Events_Thresh_Clean;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            QuaSOR_Eval_FitRegions=[];
            Count=0;
            for i=1:size(QuaSOR_Fits,2)
                if any(QuaSOR_Fits(i).EpisodeNumber==EpisodeNumber)
                    Count=Count+1;
                    Mod=0;
                    if any(QuaSOR_Fits(i).ImageNumber==ImagingInfo.IntraEpisode_Evoked_ActiveFrames)
                        Mod=1;
                    elseif any(QuaSOR_Fits(i).ImageNumber==ImagingInfo.IntraEpisode_Spont_ActiveFrames)
                        Mod=2;
                    end
                    QuaSOR_Eval_FitRegions(Count).Mod=Mod;
                    QuaSOR_Eval_FitRegions(Count).EpisodeNumber=QuaSOR_Fits(i).EpisodeNumber;
                    QuaSOR_Eval_FitRegions(Count).ImageNumber=QuaSOR_Fits(i).ImageNumber;
                    QuaSOR_Eval_FitRegions(Count).XCoord=QuaSOR_Fits(i).XCoord;
                    QuaSOR_Eval_FitRegions(Count).YCoord=QuaSOR_Fits(i).YCoord;
                    QuaSOR_Eval_FitRegions(Count).YCoords=QuaSOR_Fits(i).YCoords;
                    QuaSOR_Eval_FitRegions(Count).XCoords=QuaSOR_Fits(i).XCoords;
                    QuaSOR_Eval_FitRegions(Count).RegionProps=QuaSOR_Fits(i).RegionProps;
%                     QuaSOR_Eval_FitRegions(Count).TestImage=QuaSOR_Fits(i).TestImage;
%                     QuaSOR_Eval_FitRegions(Count).TestImage_Z_Scaled=QuaSOR_Fits(i).TestImage_Z_Scaled;
%                     QuaSOR_Eval_FitRegions(Count).TestImage_Filt=QuaSOR_Fits(i).TestImage_Filt;
%                     QuaSOR_Eval_FitRegions(Count).TestImage_Filt_Z_Scaled=QuaSOR_Fits(i).TestImage_Filt_Z_Scaled;
%                     QuaSOR_Eval_FitRegions(Count).ScalePoints=QuaSOR_Fits(i).ScalePoints;
%                     QuaSOR_Eval_FitRegions(Count).ScalePoints_Filt=QuaSOR_Fits(i).ScalePoints_Filt;
%                     QuaSOR_Eval_FitRegions(Count).AllFitTests=QuaSOR_Fits(i).AllFitTests;
%                     QuaSOR_Eval_FitRegions(Count).NumResets=QuaSOR_Fits(i).NumResets;
%                     QuaSOR_Eval_FitRegions(Count).NumReplicates=QuaSOR_Fits(i).NumReplicates;
%                     QuaSOR_Eval_FitRegions(Count).MaxNumGaussians=QuaSOR_Fits(i).MaxNumGaussians;
%                     QuaSOR_Eval_FitRegions(Count).InternalReplicates=QuaSOR_Fits(i).InternalReplicates;
%                     QuaSOR_Eval_FitRegions(Count).MaxVar=QuaSOR_Fits(i).MaxVar;
%                     QuaSOR_Eval_FitRegions(Count).MaxCov=QuaSOR_Fits(i).MaxCov;
%                     QuaSOR_Eval_FitRegions(Count).MaxVarDiff=QuaSOR_Fits(i).MaxVarDiff;
%                     QuaSOR_Eval_FitRegions(Count).PooledScoreTotals=QuaSOR_Fits(i).PooledScoreTotals;
                    QuaSOR_Eval_FitRegions(Count).Successful_Fit=QuaSOR_Fits(i).Successful_Fit;
%                     QuaSOR_Eval_FitRegions(Count).Best_NumGaussian=QuaSOR_Fits(i).Best_NumGaussian;
%                     QuaSOR_Eval_FitRegions(Count).Best_Replicate=QuaSOR_Fits(i).Best_Replicate;
%                     QuaSOR_Eval_FitRegions(Count).Best_GaussianFitModel=QuaSOR_Fits(i).Best_GaussianFitModel;
%                     QuaSOR_Eval_FitRegions(Count).Best_GaussianFitTest=QuaSOR_Fits(i).Best_GaussianFitTest;
%                     QuaSOR_Eval_FitRegions(Count).Best_GaussianFitImage=QuaSOR_Fits(i).Best_GaussianFitImage;
                    QuaSOR_Eval_FitRegions(Count).BestGaussianFitModel_Clean=QuaSOR_Fits(i).BestGaussianFitModel_Clean;

                end
            end
            for Mod2=1:length(QuaSOR_Parameters.Modality)
                QuaSOR_Eval_Modality(Mod2).TempCoords=[];
            end
            if ~isempty(QuaSOR_Eval_FitRegions)
                for i=1:size(QuaSOR_Eval_FitRegions,2)
                    if any(QuaSOR_Eval_FitRegions(i).EpisodeNumber==EpisodeNumber)
                        Mod=0;
                        if any(ImagingInfo.PeakFrame==ImagingInfo.IntraEpisode_Evoked_ActiveFrames)
                            Mod=1;
                        elseif any(ImagingInfo.PeakFrame==ImagingInfo.IntraEpisode_Spont_ActiveFrames)
                            Mod=2;
                        end
                        if Mod~=0
                            for k=1:QuaSOR_Eval_FitRegions(i).BestGaussianFitModel_Clean.NumComponents
                                TempCoord=QuaSOR_Eval_FitRegions(i).BestGaussianFitModel_Clean.mu(k,1:2);
                                XFix=QuaSOR_Eval_FitRegions(i).RegionProps.BoundingBox(1)+QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust;
                                YFix=QuaSOR_Eval_FitRegions(i).RegionProps.BoundingBox(2)+QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust;
                                TempCoordFix=[TempCoord(1)+YFix,TempCoord(2)+XFix];
                                QuaSOR_Eval_Modality(Mod).TempCoords=vertcat(QuaSOR_Eval_Modality(Mod).TempCoords,[TempCoordFix,ImagingInfo.PeakFrame]);
                            end
                        end
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        else
            CorrAmp_Alt_Color=[];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ActiveImageCount=0;
        for ImageNumber=1:ImagingInfo.FramesPerEpisode
            OverallFrameCount=OverallFrameCount+1;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            IsStimFrame=0;
            if any(ImageNumber==ImagingInfo.IntraEpisode_StimuliFrames)
                IsStimFrame=1;
                StimCount=StimCount+1;
                StimCount1=StimCount1+1;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if rem((OverallFrameCount*1/ImagingInfo.ImagingFrequency),1)==0
                TimePoint=[num2str((OverallFrameCount)*(1/ImagingInfo.ImagingFrequency)),'.00s'];
            elseif rem((OverallFrameCount*10/ImagingInfo.ImagingFrequency),1)==0
                TimePoint=[num2str((OverallFrameCount)*(1/ImagingInfo.ImagingFrequency)),'0s'];
            else
                TimePoint=[num2str((OverallFrameCount)*(1/ImagingInfo.ImagingFrequency)),'s'];
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            EventPersistenceFrames=[ImageNumber];
            GoodEventPersistenceFrames=[];
            for i=1:length(EventPersistenceFrames)
                if EventPersistenceFrames(i)>0&&EventPersistenceFrames(i)<=ImagingInfo.FramesPerEpisode
                    GoodEventPersistenceFrames=[GoodEventPersistenceFrames,EventPersistenceFrames(i)];
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            QuaSOR_Eval_FitRegions=[];
            Count=0;
            for i=1:size(QuaSOR_Fits,2)
                if any(QuaSOR_Fits(i).ImageNumber==ImageNumber)
                    Count=Count+1;
                    Mod=0;
                    if any(QuaSOR_Fits(i).ImageNumber==ImagingInfo.IntraEpisode_Evoked_ActiveFrames)
                        Mod=1;
                    elseif any(QuaSOR_Fits(i).ImageNumber==ImagingInfo.IntraEpisode_Spont_ActiveFrames)
                        Mod=2;
                    end
                    QuaSOR_Eval_FitRegions(Count).Mod=Mod;
                    QuaSOR_Eval_FitRegions(Count).EpisodeNumber=QuaSOR_Fits(i).EpisodeNumber;
                    QuaSOR_Eval_FitRegions(Count).ImageNumber=QuaSOR_Fits(i).ImageNumber;
                    QuaSOR_Eval_FitRegions(Count).XCoord=QuaSOR_Fits(i).XCoord;
                    QuaSOR_Eval_FitRegions(Count).YCoord=QuaSOR_Fits(i).YCoord;
                    QuaSOR_Eval_FitRegions(Count).YCoords=QuaSOR_Fits(i).YCoords;
                    QuaSOR_Eval_FitRegions(Count).XCoords=QuaSOR_Fits(i).XCoords;
                    QuaSOR_Eval_FitRegions(Count).RegionProps=QuaSOR_Fits(i).RegionProps;
%                     QuaSOR_Eval_FitRegions(Count).TestImage=QuaSOR_Fits(i).TestImage;
%                     QuaSOR_Eval_FitRegions(Count).TestImage_Z_Scaled=QuaSOR_Fits(i).TestImage_Z_Scaled;
%                     QuaSOR_Eval_FitRegions(Count).TestImage_Filt=QuaSOR_Fits(i).TestImage_Filt;
%                     QuaSOR_Eval_FitRegions(Count).TestImage_Filt_Z_Scaled=QuaSOR_Fits(i).TestImage_Filt_Z_Scaled;
%                     QuaSOR_Eval_FitRegions(Count).ScalePoints=QuaSOR_Fits(i).ScalePoints;
%                     QuaSOR_Eval_FitRegions(Count).ScalePoints_Filt=QuaSOR_Fits(i).ScalePoints_Filt;
%                     QuaSOR_Eval_FitRegions(Count).AllFitTests=QuaSOR_Fits(i).AllFitTests;
%                     QuaSOR_Eval_FitRegions(Count).NumResets=QuaSOR_Fits(i).NumResets;
%                     QuaSOR_Eval_FitRegions(Count).NumReplicates=QuaSOR_Fits(i).NumReplicates;
%                     QuaSOR_Eval_FitRegions(Count).MaxNumGaussians=QuaSOR_Fits(i).MaxNumGaussians;
%                     QuaSOR_Eval_FitRegions(Count).InternalReplicates=QuaSOR_Fits(i).InternalReplicates;
%                     QuaSOR_Eval_FitRegions(Count).MaxVar=QuaSOR_Fits(i).MaxVar;
%                     QuaSOR_Eval_FitRegions(Count).MaxCov=QuaSOR_Fits(i).MaxCov;
%                     QuaSOR_Eval_FitRegions(Count).MaxVarDiff=QuaSOR_Fits(i).MaxVarDiff;
%                     QuaSOR_Eval_FitRegions(Count).PooledScoreTotals=QuaSOR_Fits(i).PooledScoreTotals;
                    QuaSOR_Eval_FitRegions(Count).Successful_Fit=QuaSOR_Fits(i).Successful_Fit;
%                     QuaSOR_Eval_FitRegions(Count).Best_NumGaussian=QuaSOR_Fits(i).Best_NumGaussian;
%                     QuaSOR_Eval_FitRegions(Count).Best_Replicate=QuaSOR_Fits(i).Best_Replicate;
%                     QuaSOR_Eval_FitRegions(Count).Best_GaussianFitModel=QuaSOR_Fits(i).Best_GaussianFitModel;
%                     QuaSOR_Eval_FitRegions(Count).Best_GaussianFitTest=QuaSOR_Fits(i).Best_GaussianFitTest;
%                     QuaSOR_Eval_FitRegions(Count).Best_GaussianFitImage=QuaSOR_Fits(i).Best_GaussianFitImage;
                    QuaSOR_Eval_FitRegions(Count).BestGaussianFitModel_Clean=QuaSOR_Fits(i).BestGaussianFitModel_Clean;

                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for Mod2=1:length(QuaSOR_Parameters.Modality)
                QuaSOR_Eval_Modality(Mod2).TempCoords=[];
            end
            if ~isempty(QuaSOR_Eval_FitRegions)
                for i=1:size(QuaSOR_Eval_FitRegions,2)
                    if any(QuaSOR_Eval_FitRegions(i).ImageNumber==ImageNumber)
                        Mod=0;
                        if any(ImageNumber==ImagingInfo.IntraEpisode_Evoked_ActiveFrames)
                            Mod=1;
                        elseif any(ImageNumber==ImagingInfo.IntraEpisode_Spont_ActiveFrames)
                            Mod=2;
                        end
                        if Mod~=0
                            for k=1:QuaSOR_Eval_FitRegions(i).BestGaussianFitModel_Clean.NumComponents
                                TempCoord=QuaSOR_Eval_FitRegions(i).BestGaussianFitModel_Clean.mu(k,1:2);
                                XFix=QuaSOR_Eval_FitRegions(i).RegionProps.BoundingBox(1)+QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust;
                                YFix=QuaSOR_Eval_FitRegions(i).RegionProps.BoundingBox(2)+QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust;
                                TempCoordFix=[TempCoord(1)+YFix,TempCoord(2)+XFix];
                                QuaSOR_Eval_Modality(Mod).TempCoords=vertcat(QuaSOR_Eval_Modality(Mod).TempCoords,[TempCoordFix,ImageNumber]);
                            end
                        end
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~isempty(QuaSOR_Eval_FitRegions)
                ActiveImageCount=ActiveImageCount+1;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                InputImage=single(ImageArray_Input(:,:,ImageNumber));
                if ImagingInfo.ModalityType~=1
                    CorrAmp=single(max(ImageArray_CorrAmp_Events_Thresh_Clean(:,:,GoodEventPersistenceFrames),[],3));
                else
                    CorrAmp=single(CorrAmp_Alt);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Episode_Eval(ActiveImageCount).EpisodeNumber=EpisodeNumber;
                Episode_Eval(ActiveImageCount).ImageNumber=ImageNumber;
                Episode_Eval(ActiveImageCount).OverallFrameCount=OverallFrameCount;
                Episode_Eval(ActiveImageCount).TimePoint=TimePoint;
                Episode_Eval(ActiveImageCount).IsStimFrame=IsStimFrame;
                Episode_Eval(ActiveImageCount).IsStimFrame=IsStimFrame;
                Episode_Eval(ActiveImageCount).StimCount=StimCount;
                Episode_Eval(ActiveImageCount).StimCount1=StimCount1;
                Episode_Eval(ActiveImageCount).InputImage=single(InputImage); clear InputImage
                Episode_Eval(ActiveImageCount).CorrAmp=single(CorrAmp); clear CorrAmp
                Episode_Eval(ActiveImageCount).CorrAmp_UpScale=ZerosImage_UpScale_Single; clear CorrAmp
                Episode_Eval(ActiveImageCount).QuaSOR_Eval_FitRegions=QuaSOR_Eval_FitRegions; clear QuaSOR_Eval_FitRegions
                Episode_Eval(ActiveImageCount).QuaSOR_Eval_Modality=QuaSOR_Eval_Modality;clear QuaSOR_Eval_Modality
                Episode_Eval(ActiveImageCount).QuaSOR_FitImage=ZerosImage_UpScale_Single;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
        fprintf('Finished!\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['Rendering ',num2str(length(Episode_Eval)),' QuaSOR Fit Frames for All Events In Episode ',num2str(EpisodeNumber),'...'])
        parfor ActiveImageCount=1:length(Episode_Eval)
            Episode_Eval(ActiveImageCount).CorrAmp_UpScale=...
                imresize(Episode_Eval(ActiveImageCount).CorrAmp,...
                QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,...
                QuaSOR_Parameters.UpScaling.UpScaleMethod);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for i=1:size(Episode_Eval(ActiveImageCount).QuaSOR_Eval_FitRegions,2)
                for k=1:Episode_Eval(ActiveImageCount).QuaSOR_Eval_FitRegions(i).BestGaussianFitModel_Clean.NumComponents
                    %Upscale Reconstruction
                    TestSigma=Episode_Eval(ActiveImageCount).QuaSOR_Eval_FitRegions(i).BestGaussianFitModel_Clean.Sigma(:,:,k);
                    TempCoord=Episode_Eval(ActiveImageCount).QuaSOR_Eval_FitRegions(i).BestGaussianFitModel_Clean.mu(k,1:2);
                    XFix=Episode_Eval(ActiveImageCount).QuaSOR_Eval_FitRegions(i).RegionProps.BoundingBox(1)+QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust;
                    YFix=Episode_Eval(ActiveImageCount).QuaSOR_Eval_FitRegions(i).RegionProps.BoundingBox(2)+QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust;
                    TempCoordFix=[TempCoord(1)+YFix,TempCoord(2)+XFix];
                    temp1=TestSigma(1,1);
                    temp2=TestSigma(2,2);
                    TestSigma(1,1)=temp2;TestSigma(2,2)=temp1;
                    %clear temp1 temp2
                    F2 = mvnpdf([X2(:) Y2(:)],fliplr(TempCoordFix),TestSigma);
                    F2 = reshape(F2,length(y2),length(x2));
                    F2=F2/max(F2(:))*Episode_Eval(ActiveImageCount).QuaSOR_Eval_FitRegions(i).BestGaussianFitModel_Clean.Amp(k);
                    Episode_Eval(ActiveImageCount).QuaSOR_FitImage=Episode_Eval(ActiveImageCount).QuaSOR_FitImage+single(F2);
                    %clear F2
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isfield(Episode_Eval(ActiveImageCount).QuaSOR_Eval_FitRegions,'FitImage')
                Episode_Eval(ActiveImageCount).QuaSOR_Eval_FitRegions=rmfield(Episode_Eval(ActiveImageCount).QuaSOR_Eval_FitRegions,'FitImage');
            end
        end
        fprintf('Finished!\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if SplitEpisodeFiles
            QuaSOR_Eval_Struct(1).Episode_Eval=Episode_Eval;
            FileSuffix=['_QuaSOR_Evaluation_Ep_',num2str(EpisodeNumber_Load),'.mat'];
            fprintf(['Saving: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
            save([CurrentScratchDir,StackSaveName,FileSuffix],'QuaSOR_Eval_Struct')
            fprintf('Finished!\n')
            fprintf(['Copying: ',StackSaveName,FileSuffix,' to SaveDir...'])
            [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
            fprintf('Finished!\n')
            if ~CopyStatus
                error('Problem Copying Split Episode Data!')
            else
            end
            QuaSOR_Eval_Struct=[];
        else
            QuaSOR_Eval_Struct(EpisodeNumber).Episode_Eval=Episode_Eval;
        end
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileSuffix=['_QuaSOR_Evaluation.mat'];
    fprintf(['Saving: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
    save([CurrentScratchDir,StackSaveName,FileSuffix],'QuaSOR_Eval_Struct')
    fprintf('Finished!\n')
    fprintf(['Copying: ',StackSaveName,FileSuffix,' to SaveDir...'])
    [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
    fprintf('Finished!\n')
    if ~CopyStatus
        error('Problem Copying Data!')
    else
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    
    error('Not ready yet!')


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
