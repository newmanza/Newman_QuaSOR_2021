function [ImageArrayReg_AllImages,ImageArrayReg_FirstImages]=Enhanced_Multi_Modality_Registration(myPool,dc,SaveName,StackSaveName,...
    ScratchDir,CurrentScratchDir,FigureSaveDir,ImageArray,ImageArray_FirstImages,...
            ReferenceImage,AllBoutonsRegion,AllBoutonsRegion_Orig,BorderLine_Orig,Crop_Props,SubBoutonArray,...
            ImagingInfo,RegistrationSettings,RegEnhancement,RefRegEnhancement,DemonReg)
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
    fprintf(['==========================================================================================\n'])
    fprintf(['==========================================================================================\n'])
    fprintf(['==========================================================================================\n'])
    fprintf(['Starting Enhanced_Muli_Modality_Registration on ',StackSaveName,'\n']);
    [OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(1);
    Temp_MatlabVersionYear=MatlabVersion(1:4);
    warning on all
    warning off verbose
    warning off backtrace
    if ~isempty(myPool)
        RunParallel=1;
    else
        RunParallel=0;
    end
    if RunParallel
        try
            if isempty(myPool.IdleTimeout)
                disp('Parpool timed out! Restarting now...')
                delete(gcp('nocreate'))
                myPool=parpool;%
            else
                disp('Parpool active...')
            end
        catch
            disp('Parpool timed out! Restarting now...')
            delete(gcp('nocreate'))
            myPool=parpool;%
        end
    end
    OverallTimer=tic;
    TimeHandle=tic;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if DemonReg.CircularFilter
        warning('Circular Demon Filter Engaged!')
    end
    DemonReg.FastSmoothing=1;
    if DemonReg.FastSmoothing
        DemonReg.PixelBlockSize=10;
        warning on
        warning('Fast Demon field smoothing active!')
    end
    if DemonReg.CarryOver_DemonField_Smoothing
        warning('DemonReg.CarryOver_DemonField_Smoothing is engaged!')
    end
    if ~exist(ScratchDir)||isempty(ScratchDir)
       [~,~,~,~,~,~,~,ScratchDir]=BatchStartup;
    end
    TempScratchSaveDir=[ScratchDir,StackSaveName,dc,'TempFiles',dc];
    if ~exist(TempScratchSaveDir)
        mkdir(TempScratchSaveDir);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Parameters
    SaveDemonField=0;
    SaveIndividualDemonField=0;
    DFT_UpScaleFactor=100;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    disp('Preparing to Register All Data...')
    warning(['Analyzing: ',num2str(ImagingInfo.NumEpisodes), ' Episodes...'])
    warning(['Analyzing: ',num2str(ImagingInfo.NumEpisodes), ' Episodes...'])
    warning(['Analyzing: ',num2str(ImagingInfo.NumEpisodes), ' Episodes...'])
    %TotalNumFrames=size(ImageArray,3);
    warning(['Analyzing: ',num2str(ImagingInfo.TotalNumFrames), ' Frames...'])
    warning(['Analyzing: ',num2str(ImagingInfo.TotalNumFrames), ' Frames...'])
    warning(['Analyzing: ',num2str(ImagingInfo.TotalNumFrames), ' Frames...'])
    if RegistrationSettings.RegistrationClass==1
        if ~isfield(DemonReg,'CoarseTranslationMode')
            DemonReg.CoarseTranslationMode=1;
        end
        if DemonReg.CoarseTranslationMode==0
            warning('CoarseTranslationMode=0 is not currently set up for RegistrationSettings.RegistrationClass=1')
            warning('This is a very unlikely combination so I am setting CoarseTranslationMode=1')
            DemonReg.CoarseTranslationMode=1;
        end
        DeltaX_Coarse=zeros(1, ImagingInfo.NumEpisodes); 
        DeltaY_Coarse=zeros(1, ImagingInfo.NumEpisodes);
        DeltaX_DFTReg_Whole=zeros(1, ImagingInfo.NumEpisodes); 
        DeltaY_DFTReg_Whole=zeros(1, ImagingInfo.NumEpisodes); 
        Error_DFTReg_Whole=zeros(1, ImagingInfo.NumEpisodes); 
        Diffphase_DFTReg_Whole=zeros(1, ImagingInfo.NumEpisodes); 
    else
        if ~isfield(DemonReg,'CoarseTranslationMode')
            DemonReg.CoarseTranslationMode=0;
        end
        if DemonReg.CoarseTranslationMode==0
            DeltaX_Coarse=zeros(1, ImagingInfo.TotalNumFrames); 
            DeltaY_Coarse=zeros(1, ImagingInfo.TotalNumFrames);
        elseif DemonReg.CoarseTranslationMode==1
            DeltaX_Coarse=zeros(1, ImagingInfo.NumEpisodes); 
            DeltaY_Coarse=zeros(1, ImagingInfo.NumEpisodes);
        end
        DeltaX_DFTReg_Whole=zeros(1, ImagingInfo.TotalNumFrames); 
        DeltaY_DFTReg_Whole=zeros(1, ImagingInfo.TotalNumFrames); 
        Error_DFTReg_Whole=zeros(1, ImagingInfo.TotalNumFrames); 
        Diffphase_DFTReg_Whole=zeros(1, ImagingInfo.TotalNumFrames); 
    end
    DeltaX_All_Translations=[];
    DeltaY_All_Translations=[];
    DeltaX_All_Translations_Derivative=[];
    DeltaY_All_Translations_Derivative=[];
    IsDFTMoving=[];
    DeltaX_DFTReg_Intermediate_Crop=[];
    DeltaY_DFTReg_Intermediate_Crop=[];
    demonDispFields=[];
    FirstImage_demonDispFields=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Pad Bouton Region Mask
    AllBoutonsRegion_Orig_Mask=ones(size(AllBoutonsRegion_Orig));
    AllBoutonsRegion_Orig_Padded = padarray(AllBoutonsRegion_Orig,[DemonReg.Padding DemonReg.Padding],0);
    AllBoutonsRegion_Orig_Mask_Padded = padarray(AllBoutonsRegion_Orig_Mask,[DemonReg.Padding DemonReg.Padding],1);
    for j=1:RegEnhancement.BiasRatios
        Temp=imdilate(AllBoutonsRegion_Orig,ones(j*RegEnhancement.BiasRatioDiv));
        AllBoutonsRegion_Orig_Mask=AllBoutonsRegion_Orig_Mask+Temp;
        Temp=imdilate(AllBoutonsRegion_Orig_Padded,ones(j*RegEnhancement.BiasRatioDiv));
        AllBoutonsRegion_Orig_Mask_Padded=AllBoutonsRegion_Orig_Mask_Padded+Temp;
    end
    AllBoutonsRegion_Orig_Mask=AllBoutonsRegion_Orig_Mask/max(AllBoutonsRegion_Orig_Mask(:));
    AllBoutonsRegion_Orig_Mask=AllBoutonsRegion_Orig_Mask*RegEnhancement.BiasProportion+(1-RegEnhancement.BiasProportion);
    AllBoutonsRegion_Orig_Mask_Padded=AllBoutonsRegion_Orig_Mask_Padded/max(AllBoutonsRegion_Orig_Mask_Padded(:));
    AllBoutonsRegion_Orig_Mask_Padded=AllBoutonsRegion_Orig_Mask_Padded*RegEnhancement.BiasProportion+(1-RegEnhancement.BiasProportion);
    AllBoutonsRegion_Orig_Mask_Crop=imcrop(AllBoutonsRegion_Orig_Mask,Crop_Props.BoundingBox);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ReferenceImage_FFT = fft2(RegistrationSettings.OverallReferenceImage);
    %Set up DemonReg.Padding and Masking regions
    [ReferenceImage_Padded,ReferenceImage_Padded_Masked_Filtered_Enhanced]=...
        RegistrationImageEnhancement(RegistrationSettings.OverallReferenceImage,...
        AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,BorderLine_Orig,...
        Crop_Props,DemonReg,RefRegEnhancement,[StackSaveName,' ReferenceImage'],FigureSaveDir,0,0);
    ReferenceImage_Padded_Masked_Filtered_Enhanced_FFT=fft2(ReferenceImage_Padded_Masked_Filtered_Enhanced);
    %Add adjustments for edges of image
    DemonReg.Intermediate_Crop_Props=Crop_Props;
    DemonReg.Intermediate_Crop_Props.BoundingBox(1)=round(DemonReg.Intermediate_Crop_Props.BoundingBox(1))+1-DemonReg.IntermediateCropPadding;
    DemonReg.Intermediate_Crop_Props.BoundingBox(2)=round(DemonReg.Intermediate_Crop_Props.BoundingBox(2))+1-DemonReg.IntermediateCropPadding;
    DemonReg.Intermediate_Crop_Props.BoundingBox(3)=DemonReg.Intermediate_Crop_Props.BoundingBox(3)+2*DemonReg.IntermediateCropPadding;
    DemonReg.Intermediate_Crop_Props.BoundingBox(4)=DemonReg.Intermediate_Crop_Props.BoundingBox(4)+2*DemonReg.IntermediateCropPadding;
    DemonReg.Final_Crop_Props=Crop_Props;
    DemonReg.Final_Crop_Props.BoundingBox(1)=DemonReg.IntermediateCropPadding;
    DemonReg.Final_Crop_Props.BoundingBox(2)=DemonReg.IntermediateCropPadding;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ZerosImage=zeros(size(RegistrationSettings.OverallReferenceImage));
    ZerosImage_Crop=imcrop(ZerosImage,[Crop_Props.BoundingBox]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isfield(DemonReg,'CircularFilterFrames')
        warning('Missing CircularFilterFrames!')
        DemonReg.CircularFilterFrames=round(max(DemonReg.DemonSmoothSize)/2);
        warning(['DemonReg.CircularFilterFrames = ',num2str(DemonReg.CircularFilterFrames)])
    end
    if isempty(DemonReg.CircularFilterFrames)
        warning('Missing CircularFilterFrames!')
        DemonReg.CircularFilterFrames=round(max(DemonReg.DemonSmoothSize)/2);
        warning(['DemonReg.CircularFilterFrames = ',num2str(DemonReg.CircularFilterFrames)])
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('====================================================================================\n')
    if DemonReg.DynamicSmoothing
        warning('NOTE: Dynamic Smoothing Engaged!')
        warning('Make sure to check the flagged episodes!')
    end
    disp('Key Settings:')
    disp(['DemonReg.Padding = ',num2str(DemonReg.Padding)])
    disp(['DemonReg.PyramidLevels = ',num2str(DemonReg.PyramidLevels)])
    fprintf('DemonReg.Iterations = [')
    for i=1:length(DemonReg.Iterations)
        fprintf([num2str(DemonReg.Iterations(i)),' '])
    end
    fprintf('\b]\n')
    disp(['DemonReg.AccumulatedFieldSmoothing = ',num2str(DemonReg.AccumulatedFieldSmoothing)])
    disp(['DemonReg.SmoothDemon = ',num2str(DemonReg.SmoothDemon)])
    if DemonReg.SmoothDemon
        fprintf('DemonReg.DemonSmoothSize = [')
        for i=1:length(DemonReg.DemonSmoothSize)
            fprintf([num2str(DemonReg.DemonSmoothSize(i)),' '])
        end
        fprintf('\b]\n')
        if DemonReg.CarryOver_DemonField_Smoothing
            warning('DemonReg.CarryOver_DemonField_Smoothing is engaged!')
            disp(['DemonReg.CarryOverFrames = ',num2str(DemonReg.CarryOverFrames)])
        end
    end
    disp(['RegEnhancement.MaskSplitPercentage = ',num2str(RegEnhancement.MaskSplitPercentage)])
    disp(['RegEnhancement.StretchLimParams = [',num2str(RegEnhancement.StretchLimParams(1)),' ',num2str(RegEnhancement.StretchLimParams(2)),']'])
    disp(['DemonReg.DynamicSmoothing = ',num2str(DemonReg.DynamicSmoothing)])
    disp(['DemonReg.DynamicSmoothingDerivThreshold = ',num2str(DemonReg.DynamicSmoothingDerivThreshold)])
    fprintf('====================================================================================\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if RegistrationSettings.RegistrationClass==1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if RegistrationSettings.RegistrationMethod==1
            error('Not up to date currently ...')
        elseif RegistrationSettings.RegistrationMethod==2
            error('Not up to date currently ...')
        elseif RegistrationSettings.RegistrationMethod==3
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if DemonReg.CoarseTranslation
                if DemonReg.CoarseTranslationMode==1
                    fprintf(['====================================================\n'])
                    fprintf('Calculating Coarse Translation...')
                    TimeHandle=tic;
                    [ImageArrayCoarseReg_FirstImages DeltaX_Coarse DeltaY_Coarse MaxValue_First] =...
                        Coarse_Reg(cat(3,RegistrationSettings.OverallReferenceImage,ImageArray_FirstImages),...
                        RegistrationSettings.AlignRegion, RegistrationSettings.CoarseReg_MaxShiftX, RegistrationSettings.CoarseReg_MaxShiftY,...
                        RegistrationSettings.CoarseReg_MinCorrValue); % not using MinCorrValue for now
                    ImageArrayCoarseReg_FirstImages=ImageArrayCoarseReg_FirstImages(:,:,2:ImagingInfo.NumEpisodes+1);
                    DeltaX_Coarse=DeltaX_Coarse(:,2:ImagingInfo.NumEpisodes+1);
                    DeltaY_Coarse=DeltaY_Coarse(:,2:ImagingInfo.NumEpisodes+1);
                    clear TempArray
                    fprintf('Finished!\n')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
                    fprintf('Cleaning Coarse Registered Array...')        
                    %clean up motion correction edges
                    progressbar('Episode')
                    for EpisodeNumber=1:ImagingInfo.NumEpisodes 
                        progressbar(EpisodeNumber/ImagingInfo.NumEpisodes)
                        TempImage1 = ImageArrayCoarseReg_FirstImages(:,:,EpisodeNumber);
                        EdgeMask=zeros(size(TempImage1));
                        XShift=ceil(DeltaX_Coarse(EpisodeNumber));
                        YShift=ceil(DeltaY_Coarse(EpisodeNumber));
                        if XShift<0
                            XShift=XShift-1;
                            EdgeMask(:,size(EdgeMask,2)+XShift:size(EdgeMask,2))=1;
                        elseif XShift>0
                            XShift=XShift+1;
                            EdgeMask(:,1:XShift)=1;
                        end
                        if YShift<0
                            YShift=YShift-1;
                            EdgeMask(size(EdgeMask,1)+YShift:size(EdgeMask,1),:)=1;
                        elseif YShift>0
                            YShift=YShift+1;
                            EdgeMask(1:YShift,:)=1;
                        end
                        if DemonReg.PadValue_Method==1
                            DFT_Fix_Value=median(TempImage1(:));
                        elseif PadValueMethod==2
                            DFT_Fix_Value=mean(TempImage1(:));
                        elseif PadValueMethod==3
                            DFT_Fix_Value=min(TempImage1(:));
                        else
                            DFT_Fix_Value=0;
                        end
                        TempImage1(logical(EdgeMask))=DFT_Fix_Value;
                        ImageArrayCoarseReg_FirstImages(:,:,EpisodeNumber)=uint16(TempImage1);
                     end
                    fprintf('Finished!\n')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
                    TimeInterval=toc(TimeHandle);
                    fprintf(['Whole Image DFT Registration took: ',num2str(round(TimeInterval*10)/10),' s\n']);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
                elseif DemonReg.CoarseTranslationMode==0
                    error('It is not likely that you will need to run coarse reg in this imaging mode!')
                    
                end
            else
                warning('Skipping Coarse Translation')
                ImageArrayCoarseReg_FirstImages=ImageArray_FirstImages;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %NEW Subpixel registration by crosscorrelation using DFTRegistration on whole image
            [ImageArrayDFTReg_FirstImages,DeltaX_DFTReg_Whole,DeltaY_DFTReg_Whole]=Episodic_DFT_Reg(RunParallel,myPool,StackSaveName,...
                    ImageArray_FirstImages,ImageArrayCoarseReg_FirstImages,...
                    ReferenceImage_FFT,ReferenceImage_Padded_Masked_Filtered_Enhanced_FFT,...
                    AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,BorderLine_Orig,Crop_Props,...
                    ImagingInfo,RegEnhancement,DemonReg,DFT_UpScaleFactor);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
            %Calculate Derivatives and exclusion regions if using adaptive
            %smoothing
            fprintf('Calculating Translation Derivatives...')
            if DemonReg.CoarseTranslation
                if DemonReg.CoarseTranslationMode==0
                    error('Not set up currently')
                elseif DemonReg.CoarseTranslationMode==1
                    for EpisodeNumber=1:ImagingInfo.NumEpisodes 
                        DeltaX_All_Translations(EpisodeNumber)=DeltaX_Coarse(EpisodeNumber)+DeltaX_DFTReg_Whole(EpisodeNumber);        
                        DeltaY_All_Translations(EpisodeNumber)=DeltaY_Coarse(EpisodeNumber)+DeltaY_DFTReg_Whole(EpisodeNumber);
                    end
                    DeltaX_All_Translations_Derivative=diff(DeltaX_DFTReg_Whole+DeltaX_Coarse);
                    DeltaY_All_Translations_Derivative=diff(DeltaY_DFTReg_Whole+DeltaY_Coarse);
                    IsDFTMoving=zeros(size(DeltaY_DFTReg_Whole));
                    for EpisodeNumber=1+1:ImagingInfo.NumEpisodes-1
                        if abs(DeltaX_All_Translations_Derivative(EpisodeNumber))>DemonReg.DynamicSmoothingDerivThreshold||...
                                abs(DeltaY_All_Translations_Derivative(EpisodeNumber))>DemonReg.DynamicSmoothingDerivThreshold     
                            IsDFTMoving(EpisodeNumber)=1;
                        end
                    end
                end
            else
                for EpisodeNumber=1:ImagingInfo.NumEpisodes 
                    DeltaX_All_Translations(EpisodeNumber)=DeltaX_DFTReg_Whole(EpisodeNumber);        
                    DeltaY_All_Translations(EpisodeNumber)=DeltaY_DFTReg_Whole(EpisodeNumber);
                end
                DeltaX_All_Translations_Derivative=diff(DeltaX_DFTReg_Whole+DeltaX_Coarse);
                DeltaY_All_Translations_Derivative=diff(DeltaY_DFTReg_Whole+DeltaY_Coarse);
                IsDFTMoving=zeros(size(DeltaY_DFTReg_Whole));
                for EpisodeNumber=1+1:ImagingInfo.NumEpisodes-1
                    if abs(DeltaX_All_Translations_Derivative(EpisodeNumber))>DemonReg.DynamicSmoothingDerivThreshold||...
                            abs(DeltaY_All_Translations_Derivative(EpisodeNumber))>DemonReg.DynamicSmoothingDerivThreshold     
                        IsDFTMoving(EpisodeNumber)=1;
                    end
                end
            end
            fprintf('Finished!\n')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
            %Demon registration
            [ImageArrayDemonReg_FirstImages,FirstImage_demonDispFields]=Episodic_Demon_Reg(RunParallel,myPool,StackSaveName,ImageArrayDFTReg_FirstImages,...
                    ReferenceImage_Padded_Masked_Filtered_Enhanced,...
                    AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,BorderLine_Orig,Crop_Props,...
                    ImagingInfo,RegistrationSettings,RegEnhancement,DemonReg,IsDFTMoving);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            clear ImageArrayReg ImageArray_Whole ImageArrayReg_Whole
            clear ImageArrayDFTReg_FirstImages ImageArrayCoarseReg_FirstImages
            fprintf('Applying FirstImage Translations to AllImages...')
            progressbar('Correcting AllImages')
            ImageArrayDemonReg_AllImages=zeros(size(ImageArray));
            ImageCount=0;
            for EpisodeNumber=1:ImagingInfo.NumEpisodes
            
                TempEpisodeImages = [(EpisodeNumber-1)*ImagingInfo.FramesPerEpisode+1:...
                    EpisodeNumber*ImagingInfo.FramesPerEpisode];
                
                TempImage_Pad_Value=0;
                [nr,nc]=size(fft2(ImageArray(:,:,1)));
                Nr = ifftshift([-fix(nr/2):ceil(nr/2)-1]);
                Nc = ifftshift([-fix(nc/2):ceil(nc/2)-1]);
                [Nc,Nr] = meshgrid(Nc,Nr);
                for EpisodeImageNumber=1:ImagingInfo.FramesPerEpisode 
                    ImageCount=ImageCount+1;
                    progressbar(ImageCount/ImagingInfo.TotalNumFrames)
                    %Apply coarse Translation
                    TempImage1=ImageArray(:,:,TempEpisodeImages(EpisodeImageNumber));
                    if DemonReg.CoarseTranslation
                        if DemonReg.CoarseTranslationMode==0
                            %TempImage=TranslateArraySimple(TempImage1, DeltaX_Coarse(EpisodeNumber),DeltaY_Coarse(EpisodeNumber));
                            se = translate(strel(1), [DeltaY_Coarse(ImageCount) DeltaX_Coarse(ImageCount)]);
                            TempImage1 = imdilate(TempImage1, se);
                        else
                            %TempImage=TranslateArraySimple(TempImage1, DeltaX_Coarse(EpisodeNumber),DeltaY_Coarse(EpisodeNumber));
                            se = translate(strel(1), [DeltaY_Coarse(EpisodeNumber) DeltaX_Coarse(EpisodeNumber)]);
                            TempImage1 = imdilate(TempImage1, se);
                        end
                    end
                    %Apply DFT Shifts
                    XShift=DeltaX_DFTReg_Whole(EpisodeNumber);
                    YShift=DeltaY_DFTReg_Whole(EpisodeNumber);
                    CorrectionField=exp(1i*2*pi*(-YShift*Nr/nr-XShift*Nc/nc));
                    TempFFTOutput = fft2(TempImage1).*CorrectionField;
                    TempFFTOutput = TempFFTOutput*exp(1i*Diffphase_DFTReg_Whole(EpisodeNumber));
                    TempDFTCorrectedImage=uint16(real(ifft2(TempFFTOutput)));

                    %Pad Border and then warp the image according to the demon field
                    CorrectedImage=imwarp(double(padarray(TempDFTCorrectedImage,[DemonReg.Padding DemonReg.Padding],TempImage_Pad_Value)),FirstImage_demonDispFields{EpisodeNumber}.dField);
                    FinalizedImage=CorrectedImage(DemonReg.Padding+1:size(TempDFTCorrectedImage,1)+DemonReg.Padding,DemonReg.Padding+1:size(TempDFTCorrectedImage,2)+DemonReg.Padding);
                    ImageArrayDemonReg_AllImages(:,:,ImageCount) = uint16(FinalizedImage).*uint16(AllBoutonsRegion_Orig);
                 end
                 %dField(:,:,1)=FirstImage_demonDispFields{EpisodeNumber}.dField(DemonReg.Padding+1:size(TempDFTCorrectedImage,1)+DemonReg.Padding,DemonReg.Padding+1:size(TempDFTCorrectedImage,2)+DemonReg.Padding,1);
                 %dField(:,:,2)=FirstImage_demonDispFields{EpisodeNumber}.dField(DemonReg.Padding+1:size(TempDFTCorrectedImage,1)+DemonReg.Padding,DemonReg.Padding+1:size(TempDFTCorrectedImage,2)+DemonReg.Padding,2);
            end
            fprintf('Finished!\n')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Final Crop and mask
            fprintf('Final Cropping ImageArrayReg_FirstImages...')
            ImageArrayReg_FirstImages=[];
            for EpisodeNumber=1:ImagingInfo.NumEpisodes 
                ImageArrayReg_FirstImages(:,:,EpisodeNumber)=uint16(ZerosImage_Crop);
            end
            for EpisodeNumber=1:ImagingInfo.NumEpisodes 
                ImageArrayReg_FirstImages(:,:,EpisodeNumber)=uint16(imcrop(ImageArrayDemonReg_FirstImages(:,:,EpisodeNumber),[Crop_Props.BoundingBox]));
            end
            fprintf('Masking FirstImages...')
            for EpisodeNumber=1:ImagingInfo.NumEpisodes 
                ImageArrayReg_FirstImages(:,:,EpisodeNumber)=...
                    uint16(double(ImageArrayReg_FirstImages(:,:,EpisodeNumber)).*double(imcrop(AllBoutonsRegion_Orig,[Crop_Props.BoundingBox])));
            end    
            fprintf('Finished!\n')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('Final Cropping ImageArrayReg_AllImages...')
            ImageArrayReg_AllImages=[];
            for ImageNumber=1:ImagingInfo.TotalNumFrames 
                ImageArrayReg_AllImages(:,:,ImageNumber)=uint16(ZerosImage_Crop);
            end
            progressbar('ImageNumber')
            for ImageNumber=1:ImagingInfo.TotalNumFrames
                progressbar(ImageNumber/ImagingInfo.TotalNumFrames)
                ImageArrayReg_AllImages(:,:,ImageNumber)=uint16(imcrop(ImageArrayDemonReg_AllImages(:,:,ImageNumber),[Crop_Props.BoundingBox]));
            end
            fprintf('Masking ImageArrayReg_AllImages...')
            progressbar('ImageNumber')
            for ImageNumber=1:ImagingInfo.TotalNumFrames
                progressbar(ImageNumber/ImagingInfo.TotalNumFrames)
                ImageArrayReg_AllImages(:,:,ImageNumber)=uint16(double(ImageArrayReg_AllImages(:,:,ImageNumber)).*double(imcrop(AllBoutonsRegion_Orig,[Crop_Props.BoundingBox])));
            end
            fprintf('Finished!\n')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 AutoPlaybackNew(ImageArrayReg_FirstImages,1,0.0001,[0 max(ImageArrayReg_FirstImages(:))*0.8],'jet');
%                 AutoPlaybackNew(ImageArrayReg_AllImages,1,0.0001,[0 max(ImageArrayReg_AllImages(:))*0.8],'jet');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('Finished Alignment!\n');
            fprintf(['====================================================\n'])
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif RegistrationSettings.RegistrationClass==2||RegistrationSettings.RegistrationClass==3
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if RegistrationSettings.RegistrationMethod==1
            error('Not up to date currently ...')
            %This one function will do all of the filtering, aligning and cropping
            %required if the NMJ did not move much
            %[ImageArrayReg_AllImages DeltaX_Coarse DeltaY_Coarse MaxValue_First SubBoutonArray] = ReadGoodImages_LapseRegXY_ArrayRegIndBoutSel_Crop(StackSaveName, StackFileName, GoodImages, FilterSize, FilterSigma, AlignRegion, MaxShiftX, MaxShiftY, SubBoutonArray, MaxShift, MinCorrValue, Jitters, Crop_Props); % not using MinCorrValue for now
            %No jitters and new fine subpixel correction
            %[ImageArrayReg_AllImages DeltaX_Coarse DeltaY_Coarse MaxValue_First SubBoutonArray] = ReadGoodImages_LapseRegXY_ArrayRegIndBoutSel_Crop_Fine(StackSaveName, StackFileName, GoodImages, FilterSize, FilterSigma, AlignRegion, MaxShiftX, MaxShiftY, SubBoutonArray, MaxShift, MinCorrValue, Jitters, Crop_Props); % not using MinCorrValue for now
            %[ImageArrayReg_AllImages DeltaX_Coarse DeltaY_Coarse MaxValue_First SubBoutonArray] = ReadGoodImages_LapseRegXY_ArrayRegIndBoutSel_Crop_Parallel(StackFileName, GoodImages, FilterSize, FilterSigma, AlignRegion, MaxShiftX, MaxShiftY, SubBoutonArray, MaxShift, MinCorrValue, Jitters, Crop_Props); % not using MinCorrValue for now
        elseif RegistrationSettings.RegistrationMethod==2
            error('Not up to date currently ...')
            %DFT subpixel registration on whole image and each bouton separately
            %     [ImageArrayReg_AllImages, DeltaX_DFTReg_Whole, DeltaY_DFTReg_Whole, DeltaX_DFTReg_Bouton, DeltaY_DFTReg_Bouton] = ReadGoodImages_AlignWhole_AlignBouton_DFTReg(StackSaveName, StackFileName, GoodImages, FilterSize, FilterSigma, SubBoutonArray, Crop_Props,FlipLR,DemonReg.BorderBufferPixelSize);
        elseif RegistrationSettings.RegistrationMethod==3
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Coarse Registration
            if DemonReg.CoarseTranslation
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
                if DemonReg.CoarseTranslationMode==0
                    fprintf('Calculating Coarse Translation for All Frames...')
                    [ImageArrayCoarseReg_AllImages DeltaX_Coarse DeltaY_Coarse MaxValue_First] =...
                        Coarse_Reg(cat(3,RegistrationSettings.OverallReferenceImage,ImageArray),...
                        RegistrationSettings.AlignRegion, RegistrationSettings.CoarseReg_MaxShiftX, RegistrationSettings.CoarseReg_MaxShiftY,...
                        RegistrationSettings.CoarseReg_MinCorrValue); % not using MinCorrValue for now
                    ImageArrayCoarseReg_AllImages=ImageArrayCoarseReg_AllImages(:,:,2:ImagingInfo.TotalNumFrames+1);
                    DeltaX_Coarse=DeltaX_Coarse(:,2:ImagingInfo.TotalNumFrames+1);
                    DeltaY_Coarse=DeltaY_Coarse(:,2:ImagingInfo.TotalNumFrames+1);
                    clear TempArray
                    fprintf('Finished!\n')
                elseif DemonReg.CoarseTranslationMode==1
                    fprintf('Calculating Coarse Translation for FIRST Episode Frames...')
                    [ImageArrayCoarseReg_FirstImages DeltaX_Coarse DeltaY_Coarse MaxValue_First] =...
                        Coarse_Reg(cat(3,RegistrationSettings.OverallReferenceImage,ImageArray_FirstImages),...
                        RegistrationSettings.AlignRegion, RegistrationSettings.CoarseReg_MaxShiftX, RegistrationSettings.CoarseReg_MaxShiftY,...
                        RegistrationSettings.CoarseReg_MinCorrValue); % not using MinCorrValue for now
                    ImageArrayCoarseReg_FirstImages=ImageArrayCoarseReg_FirstImages(:,:,2:ImagingInfo.NumEpisodes+1);
                    DeltaX_Coarse=DeltaX_Coarse(:,2:ImagingInfo.NumEpisodes+1);
                    DeltaY_Coarse=DeltaY_Coarse(:,2:ImagingInfo.NumEpisodes+1);
                    clear TempArray
                    ImageCount=0;
                    for EpisodeNumber=1:ImagingInfo.NumEpisodes
                        TempEpisodeImages = [(EpisodeNumber-1)*ImagingInfo.FramesPerEpisode+1:...
                            EpisodeNumber*ImagingInfo.FramesPerEpisode];
                        for EpisodeImageNumber=1:ImagingInfo.FramesPerEpisode 
                            ImageCount=ImageCount+1;
                            TempImage1=ImageArray(:,:,TempEpisodeImages(EpisodeImageNumber));
                            se = translate(strel(1), [DeltaY_Coarse(EpisodeNumber) DeltaX_Coarse(EpisodeNumber)]);
                            TempImage1 = imdilate(TempImage1, se);
                            ImageArrayCoarseReg_AllImages(:,:,ImageCount)=TempImage1;
                            clear TempImage1
                        end
                    end
                    fprintf('Finished!\n')
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
                fprintf('Cleaning Coarse Registered Array...\n')        
                %clean up motion correction edges
                progressbar('ImageNumber')
                for ImageNumber=1:ImagingInfo.TotalNumFrames 
                    progressbar(ImageNumber/ImagingInfo.TotalNumFrames)
                    TempImage1 = ImageArrayCoarseReg_AllImages(:,:,ImageNumber);
                    EdgeMask=zeros(size(TempImage1));
                    if DemonReg.CoarseTranslationMode==0
                        XShift=ceil(DeltaX_Coarse(ImageNumber));
                        YShift=ceil(DeltaY_Coarse(ImageNumber));
                    elseif DemonReg.CoarseTranslationMode==1
                        EpisodeNumber=0;
                        for e=1:ImagingInfo.NumEpisodes
                            TempEpisodeImages = [(e-1)*ImagingInfo.FramesPerEpisode+1:...
                                e*ImagingInfo.FramesPerEpisode];
                            if any(ImageNumber==TempEpisodeImages)
                                EpisodeNumber=e;
                            end
                        end
                        XShift=ceil(DeltaX_Coarse(EpisodeNumber));
                        YShift=ceil(DeltaY_Coarse(EpisodeNumber));
                    end
                    if XShift<0
                        XShift=XShift-1;
                        EdgeMask(:,size(EdgeMask,2)+XShift:size(EdgeMask,2))=1;
                    elseif XShift>0
                        XShift=XShift+1;
                        EdgeMask(:,1:XShift)=1;
                    end
                    if YShift<0
                        YShift=YShift-1;
                        EdgeMask(size(EdgeMask,1)+YShift:size(EdgeMask,1),:)=1;
                    elseif YShift>0
                        YShift=YShift+1;
                        EdgeMask(1:YShift,:)=1;
                    end
                    if DemonReg.PadValue_Method==1
                        DFT_Fix_Value=median(TempImage1(:));
                    elseif PadValueMethod==2
                        DFT_Fix_Value=mean(TempImage1(:));
                    elseif PadValueMethod==3
                        DFT_Fix_Value=min(TempImage1(:));
                    else
                        DFT_Fix_Value=0;
                    end
                    TempImage1(logical(EdgeMask))=DFT_Fix_Value;
                    ImageArrayCoarseReg_AllImages(:,:,ImageNumber)=uint16(TempImage1);
                end
                fprintf('Finished!\n')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
            else
                warning('Skipping Coarse Registration...')
                ImageArrayCoarseReg_AllImages=ImageArray;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [ImageArrayDFTReg_AllImages,DeltaX_DFTReg_Whole,DeltaY_DFTReg_Whole]=...
                Stream_DFT_Reg(RunParallel,myPool,StackSaveName,...
                    ImageArray,ImageArrayCoarseReg_AllImages,...
                    ReferenceImage_FFT,ReferenceImage_Padded_Masked_Filtered_Enhanced_FFT,...
                    AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,BorderLine_Orig,Crop_Props,...
                    ImagingInfo,RegEnhancement,DemonReg,DFT_UpScaleFactor);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('Calculating Translation Derivatives...')
            fprintf('Finished!\n')
            if DemonReg.CoarseTranslation
                if DemonReg.CoarseTranslationMode==0
                    ImageCount=0;
                    for EpisodeNumber=1:ImagingInfo.NumEpisodes
                        TempEpisodeImages = [(EpisodeNumber-1)*ImagingInfo.FramesPerEpisode+1:...
                            EpisodeNumber*ImagingInfo.FramesPerEpisode];
                        for EpisodeImageNumber=1:ImagingInfo.FramesPerEpisode 
                            ImageCount=ImageCount+1;
                        end
                        clear TempImage1
                    end
                elseif DemonReg.CoarseTranslationMode==1
                    for ImageNumber=1:ImagingInfo.TotalNumFrames 
                        EpisodeNumber=0;
                        for e=1:ImagingInfo.NumEpisodes
                            TempEpisodeImages = [(e-1)*ImagingInfo.FramesPerEpisode+1:...
                                e*ImagingInfo.FramesPerEpisode];
                            if any(ImageNumber==TempEpisodeImages)
                                EpisodeNumber=e;
                            end
                        end
                        DeltaX_All_Translations(ImageNumber)=DeltaX_Coarse(EpisodeNumber)+DeltaX_DFTReg_Whole(ImageNumber);        
                        DeltaY_All_Translations(ImageNumber)=DeltaY_Coarse(EpisodeNumber)+DeltaY_DFTReg_Whole(ImageNumber);
                    end
                end
            else
                for ImageNumber=1:ImagingInfo.TotalNumFrames 
                    DeltaX_All_Translations(ImageNumber)=DeltaX_DFTReg_Whole(ImageNumber);        
                    DeltaY_All_Translations(ImageNumber)=DeltaY_DFTReg_Whole(ImageNumber);
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [ImageArrayDemonReg_AllImages,demonDispFields]=Stream_Block_Demon_Reg(RunParallel,myPool,StackSaveName,ImageArrayDFTReg_AllImages,...
                    ReferenceImage_Padded_Masked_Filtered_Enhanced,...
                    AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,BorderLine_Orig,Crop_Props,...
                    ImagingInfo,RegistrationSettings,RegEnhancement,DemonReg,IsDFTMoving,SaveDemonField,TempScratchSaveDir);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Refinement to remove any remaining jitters from demon Crop
            ImageArrayReg_Intermediate_Crop1=ArrayCrop(ImageArrayDemonReg_AllImages,DemonReg.Intermediate_Crop_Props.BoundingBox);
            ReferenceImage_Intermediate_Crop=imcrop(RegistrationSettings.OverallReferenceImage,DemonReg.Intermediate_Crop_Props.BoundingBox);        
            %clear ImageArrayDemonReg_AllImages
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Second Round of DFT subpixel registration refinement on small region        
            TimeHandle1=tic;
            DeltaX_DFTReg_Intermediate_Crop=zeros(1, ImagingInfo.TotalNumFrames); 
            DeltaY_DFTReg_Intermediate_Crop=zeros(1, ImagingInfo.TotalNumFrames); 
            if DemonReg.BoutonRefinement
                DeltaX_DFTReg_Bouton_Intermediate_Crop=zeros(size(SubBoutonArray,2),ImagingInfo.TotalNumFrames);
                DeltaY_DFTReg_Bouton_Intermediate_Crop=zeros(size(SubBoutonArray,2),ImagingInfo.TotalNumFrames);
            end
            ReferenceImage_Intermediate_Crop=uint16(ReferenceImage_Intermediate_Crop);
            %figure, imshow(ReferenceImage.*uint16(AllBoutonsRegion_Orig),[]);
            ReferenceImage_Intermediate_Crop_FFT=fft2(ReferenceImage_Intermediate_Crop);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ImageArrayReg_Intermediate_Crop=zeros(size(ReferenceImage_Intermediate_Crop,1),size(ReferenceImage_Intermediate_Crop,2),ImagingInfo.TotalNumFrames);
            fprintf('Intermediate Cropped Data DFT Refinement...\n')
            if RunParallel
                ppm = ParforProgMon([StackSaveName,' || Intermediate Cropped Data DFT Refinement || '], ImagingInfo.TotalNumFrames, 1, 1200, 80);
                parfor ImageNumber=1:ImagingInfo.TotalNumFrames 
                    TempImage_FFT=fft2(uint16(ImageArrayReg_Intermediate_Crop1(:,:,ImageNumber)));
                    [OutputParams TempFFTOutput] = dftregistration(ReferenceImage_Intermediate_Crop_FFT,TempImage_FFT,DFT_UpScaleFactor);
                    DeltaX_DFTReg_Intermediate_Crop(ImageNumber)=OutputParams(4);
                    DeltaY_DFTReg_Intermediate_Crop(ImageNumber)=OutputParams(3);
                    TempDFTCorrectedImage=double(real(ifft2(TempFFTOutput)));
                    ImageArrayReg_Intermediate_Crop(:,:,ImageNumber)=uint16(TempDFTCorrectedImage);
                    ppm.increment();
                end
            else
                progressbar('Intermediate Cropped Data DFT Refinement')
                for ImageNumber=1:ImagingInfo.TotalNumFrames
                    progressbar(ImageNumber/ImagingInfo.TotalNumFrames)
                    TempImage_FFT=fft2(uint16(ImageArrayReg_Intermediate_Crop1(:,:,ImageNumber)));
                    [OutputParams TempFFTOutput] = dftregistration(ReferenceImage_Intermediate_Crop_FFT,TempImage_FFT,DFT_UpScaleFactor);
                    DeltaX_DFTReg_Intermediate_Crop(ImageNumber)=OutputParams(4);
                    DeltaY_DFTReg_Intermediate_Crop(ImageNumber)=OutputParams(3);
                    TempDFTCorrectedImage=double(real(ifft2(TempFFTOutput)));
                    ImageArrayReg_Intermediate_Crop(:,:,ImageNumber)=uint16(TempDFTCorrectedImage);
                end
            end
            clear ImageArrayReg_Intermediate_Crop1
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
            TimeInterval=toc(TimeHandle1);
            fprintf(['Intermediate DFT Refinement Took: ',num2str(round(TimeInterval*10)/10),' s\n']);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if DemonReg.BoutonRefinement&&exist('SubBoutonArray')
                if isempty(SubBoutonArray)
                    warning('Unable to perform BoutonRefinement')
                else
                    fprintf('Bouton DFT Refinement...\n')
                    TimeInterval=toc(TimeHandle);
                    PixelBorder=ones(DemonReg.BorderBufferPixelSize);%This adds buffer zone (10x10 works well most of the time) to boutons to avoid FFT artifacts, may cause problems with ROI too close to borders
                    LastBoutonNumber=length(SubBoutonArray);
                    for BoutonNumber=1:LastBoutonNumber        
                        TempBoutonStruct(BoutonNumber).Temp_ImageArray_Reg_Bouton=zeros(size(RegistrationSettings.ReferenceImage_Intermediate_Crop,1),size(RegistrationSettings.ReferenceImage_Intermediate_Crop,1),ImagingInfo.TotalNumFrames);
                    end

                    %Show Boutons
                    figure, imshow(ReferenceImage_Intermediate_Crop,[]);
                    hold on
                    for BoutonNumber=1:LastBoutonNumber        
                        plot(SubBoutonArray(BoutonNumber).TempBorderX-DemonReg.Intermediate_Crop_Props.BoundingBox(1), SubBoutonArray(BoutonNumber).TempBorderY-DemonReg.Intermediate_Crop_Props.BoundingBox(2),'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 1);
                    end
                    set(gcf,'units','normalized','position',[0.1,0.1,0.8,0.8]), drawnow, pause(0.0001)

                    progressbar('Bouton Refinement: Bouton #')
                    %progressbar('Bouton Refinement: Bouton #','Bouton Alignment: Image #')
                    for BoutonNumber=1:LastBoutonNumber
                        progressbar((BoutonNumber-1)/LastBoutonNumber)
                        AlignRegion_Bouton=ArrayCrop(SubBoutonArray(BoutonNumber).ImageArea,DemonReg.Intermediate_Crop_Props.BoundingBox);
                        %AlignRegion_Bouton = SubBoutonArray(BoutonNumber).ImageArea;
                        RegionsProps_Bouton = regionprops(double(AlignRegion_Bouton), 'BoundingBox', 'PixelIdxList');
                        %Add buffer region
                        AlignRegion_BoutonBorder_Thick = bwperim(AlignRegion_Bouton,8);
                        AlignRegion_BoutonBorder_Thick = imdilate(AlignRegion_BoutonBorder_Thick,PixelBorder);
                        AlignRegion_Bouton_Thick = logical(AlignRegion_Bouton+AlignRegion_BoutonBorder_Thick);clear AlignRegion_BoutonBorder_Thick
                        RegionsProps_Bouton_Thick = regionprops(double(AlignRegion_Bouton_Thick), 'BoundingBox', 'PixelIdxList');
                        RegionsProps_Bouton_Thick.BoundingBox=round(RegionsProps_Bouton_Thick.BoundingBox);
                        AlignRegion_Bouton_Crop=imcrop(AlignRegion_Bouton,[RegionsProps_Bouton_Thick.BoundingBox]);
                        ZerosImage1=zeros(size(ImageArrayReg_Intermediate_Crop_Reg,1),size(ImageArrayReg_Intermediate_Crop_Reg,2));
                        ZerosImage1=imcrop(ZerosImage1,[RegionsProps_Bouton_Thick.BoundingBox]);

                        %Remove buffered region data from ImageArray
                        TempImageArray=zeros(size(ZerosImage1,1),size(ZerosImage1,2),ImagingInfo.TotalNumFrames);
                        for ImageNumber=1:ImagingInfo.TotalNumFrames
                            TempImage1=ImageArrayReg_Intermediate_Crop_Reg(:,:,ImageNumber);
                            TempImageCrop=imcrop(TempImage1,[RegionsProps_Bouton_Thick.BoundingBox]);
                            TempImageArray(:,:,ImageNumber)=TempImageCrop;
                        end
                        TempBoutonStruct(BoutonNumber).Temp_ImageArray_Reg_Bouton=zeros(size(TempImageArray));
                        FirstImage_Bouton=imcrop(RegistrationSettings.OverallReferenceImage_Intermediate_Crop,[RegionsProps_Bouton_Thick.BoundingBox]);
                        TempBoutonStruct(BoutonNumber).ExpandYCoords=[RegionsProps_Bouton_Thick.BoundingBox(2):RegionsProps_Bouton_Thick.BoundingBox(2)+RegionsProps_Bouton_Thick.BoundingBox(4)];
                        TempBoutonStruct(BoutonNumber).ExpandXCoords=[RegionsProps_Bouton_Thick.BoundingBox(1):RegionsProps_Bouton_Thick.BoundingBox(1)+RegionsProps_Bouton_Thick.BoundingBox(3)];
                        TempBoutonStruct(BoutonNumber).AlignRegion_Bouton_Crop=AlignRegion_Bouton_Crop;
                        ReferenceImage_Intermediate_Crop_Bouton=uint16(FirstImage_Bouton);
                        ReferenceImage_Intermediate_Crop_Bouton_FFT=fft2(ReferenceImage_Intermediate_Crop_Bouton);
                        for ImageNumber=1:ImagingInfo.TotalNumFrames 
                            %progressbar((BoutonNumber-1)/LastBoutonNumber,ImageNumber/ImagingInfo.TotalNumFrames)
                            TempImage_Bouton = TempImageArray(:,:,ImageNumber);
                            %NEW Subpixel registration by crosscorrelation using DFTRegistration on whole image
                            TempImage_FFT=fft2(TempImage_Bouton);

                            [OutputParams TempFFTOutput] = dftregistration(ReferenceImage_Intermediate_Crop_Bouton_FFT,TempImage_FFT,DFT_UpScaleFactor);
                            DeltaX_DFTReg_Bouton_Intermediate_Crop(BoutonNumber,ImageNumber)=OutputParams(4);
                            DeltaY_DFTReg_Bouton_Intermediate_Crop(BoutonNumber,ImageNumber)=OutputParams(3);
                            TempDFTCorrectedImage=double(real(ifft2(TempFFTOutput)));
                            TempBoutonStruct(BoutonNumber).Temp_ImageArray_Reg_Bouton(:,:,ImageNumber)=TempDFTCorrectedImage;            
                            clear TempImage_FFT TempFFTOutput OutputParams TempDFTCorrectedImage
                        end
                        clear TempImageArray ReferenceImage_Intermediate_Crop_Bouton_FFT
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    TimeInterval=toc(TimeHandle);
                    fprintf(['Bouton DFT Refinement Took: ',num2str(round(TimeInterval*10)/10),' s\n']);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf('Reconstructing Image...\n')
                    ZerosImage1=zeros(size(ImageArrayReg_Intermediate_Crop,1),size(ImageArrayReg_Intermediate_Crop,2));  
                    for ImageNumber=1:ImagingInfo.TotalNumFrames
                        ImageArrayReg_Intermediate_Crop_BoutonRefined(:,:,ImageNumber)=uint16(ZerosImage1);
                    end
                    progressbar('Merging Data: Image #','Merging Data: Bouton #')
                    for ImageNumber=1:ImagingInfo.TotalNumFrames
                        TempFrame=ZerosImage1;
                        for BoutonNumber=1:LastBoutonNumber
                            TempImage_Expanded=ZerosImage1;
                            progressbar(ImageNumber/ImagingInfo.TotalNumFrames,(BoutonNumber-1)/LastBoutonNumber)
                            TempImage1=TempBoutonStruct(BoutonNumber).Temp_ImageArray_Reg_Bouton(:,:,ImageNumber);
                            TempImage1=TempImage1.*TempBoutonStruct(BoutonNumber).AlignRegion_Bouton_Crop;
                            TempImage_Expanded(TempBoutonStruct(BoutonNumber).ExpandYCoords,TempBoutonStruct(BoutonNumber).ExpandXCoords)=TempImage1;
                            TempFrame=max(TempFrame,TempImage_Expanded);
                            clear TempImage1 TempImage_Expanded
                        end
                        ImageArrayReg_Intermediate_Crop_BoutonRefined(:,:,ImageNumber)=uint16(TempFrame);
                        clear TempFrame
                    end
                end
            else
                warning('SKIPPING Bouton DFT Refinement...')
                ImageArrayReg_Intermediate_Crop_BoutonRefined=ImageArrayReg_Intermediate_Crop;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('Final Cropping ImageArrayReg_AllImages...')
            ImageArrayReg_AllImages=[];
            progressbar('ImageNumber')
            for ImageNumber=1:ImagingInfo.TotalNumFrames 
                ImageArrayReg_AllImages(:,:,ImageNumber)=uint16(ZerosImage_Crop);
                progressbar(ImageNumber/ImagingInfo.TotalNumFrames)
            end
            progressbar('ImageNumber')
            ImageArrayReg_FirstImages=[];
            FirstImageCount=0;
            EpisodeFrameCount=0;
            for ImageNumber=1:ImagingInfo.TotalNumFrames
                progressbar(ImageNumber/ImagingInfo.TotalNumFrames)
                EpisodeFrameCount=EpisodeFrameCount+1;
                ImageArrayReg_AllImages(:,:,ImageNumber)=uint16(imcrop(ImageArrayReg_Intermediate_Crop_BoutonRefined(:,:,ImageNumber),[DemonReg.Final_Crop_Props.BoundingBox]));
                %if any(ImageNumber==ImagingInfo.AllGoodFirstFrames)
                if EpisodeFrameCount==1
                    FirstImageCount=FirstImageCount+1;
                    ImageArrayReg_FirstImages(:,:,FirstImageCount)=ImageArrayReg_AllImages(:,:,ImageNumber);
                end
                if EpisodeFrameCount==ImagingInfo.FramesPerEpisode
                    EpisodeFrameCount=0;
                end
            end
            fprintf('Finished!\n')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('Masking ImageArrayReg_AllImages...')
            progressbar('ImageNumber')
            for ImageNumber=1:ImagingInfo.TotalNumFrames
                progressbar(ImageNumber/ImagingInfo.TotalNumFrames)
                ImageArrayReg_AllImages(:,:,ImageNumber)=uint16(double(ImageArrayReg_AllImages(:,:,ImageNumber)).*double(imcrop(AllBoutonsRegion_Orig,[Crop_Props.BoundingBox])));
            end
            fprintf('Finished!\n')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('Masking FirstImages...')
            for EpisodeNumber=1:ImagingInfo.NumEpisodes 
                ImageArrayReg_FirstImages(:,:,EpisodeNumber)=uint16(double(ImageArrayReg_FirstImages(:,:,EpisodeNumber)).*double(imcrop(AllBoutonsRegion_Orig,[Crop_Props.BoundingBox])));
            end    
            fprintf('Finished!\n')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 AutoPlaybackNew(ImageArrayReg_FirstImages,1,0.0001,[0 max(ImageArrayReg_FirstImages(:))*0.8],'jet');
%                 AutoPlaybackNew(ImageArrayReg_AllImages,1,0.0001,[0 max(ImageArrayReg_AllImages(:))*0.8],'jet');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('Finished Alignment!\n');
            fprintf(['====================================================\n'])
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('Deleting Temporary Files From Scratch Disk...')
            rmdir(TempScratchSaveDir,'s')
            fprintf('Finished!\n')
            TimeInterval=toc(TimeHandle);
            fprintf(['Demon Registration took: ',num2str((round(TimeInterval*10)/10)/60),' min or approx. ',num2str(((round(TimeInterval*10)/10))/ImagingInfo.TotalNumFrames),' s per image\n']);
            fprintf(['====================================================\n'])
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %elseif RegistrationSettings.RegistrationClass==3
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         if RegistrationSettings.RegistrationMethod==1
%             error('Not up to date currently ...')
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         elseif RegistrationSettings.RegistrationMethod==2
%             error('Not up to date currently ...')
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         elseif RegistrationSettings.RegistrationMethod==3
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             if SaveDemonField
%                 demonDispFields = cell(ImagingInfo.TotalNumFrames,1);
%             end
%             fprintf(['====================================================\n'])
%             fprintf('Loading Data and Applying Whole Image DFT Registration...\n')
%             parfor ImageNumber=1:ImagingInfo.TotalNumFrames 
%                 TempImage=ImageArray(:,:,ImageNumber);
%                 if DemonReg.DFT_Pad_Enhance
% 
%                     [~,TempImage_Padded_Masked_Filtered_Enhanced]=...
%                         RegistrationImageEnhancement(TempImage,AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,...
%                         BorderLine_Orig,Crop_Props,DemonReg,RegEnhancement,[],[],0,0);
%                     TempImage_Padded_Masked_Filtered_Enhanced_FFT=fft2(TempImage_Padded_Masked_Filtered_Enhanced);
% 
%                     [OutputParams TempFFTOutput] = dftregistration(ReferenceImage_Padded_Masked_Filtered_Enhanced_FFT,TempImage_Padded_Masked_Filtered_Enhanced_FFT,DFT_UpScaleFactor);
%                     DeltaX_DFTReg_Whole(ImageNumber)=OutputParams(4);
%                     DeltaY_DFTReg_Whole(ImageNumber)=OutputParams(3);
%                     Error_DFTReg_Whole(ImageNumber)=OutputParams(1); 
%                     Diffphase_DFTReg_Whole(ImageNumber)=OutputParams(2);          
%                     %TempDFTCorrectedImage=double(real(ifft2(TempFFTOutput)));
% 
%                     TempImage_Pad_Value=0;
%                     [nr,nc]=size(fft2(RegistrationSettings.OverallReferenceImage));
%                     Nr = ifftshift([-fix(nr/2):ceil(nr/2)-1]);
%                     Nc = ifftshift([-fix(nc/2):ceil(nc/2)-1]);
%                     [Nc,Nr] = meshgrid(Nc,Nr);
%                     %Apply DFT Shifts
%                     XShift=DeltaX_DFTReg_Whole(ImageNumber);
%                     YShift=DeltaY_DFTReg_Whole(ImageNumber);
%                     CorrectionField=exp(1i*2*pi*(-YShift*Nr/nr-XShift*Nc/nc));
%                     TempFFTOutput = fft2(TempImage).*CorrectionField;
%                     TempFFTOutput = TempFFTOutput*exp(1i*Diffphase_DFTReg_Whole(ImageNumber));
%                     TempDFTCorrectedImage=uint16(real(ifft2(TempFFTOutput)));
%                     ImageArrayReg_Whole(:,:,ImageNumber)=uint16(TempDFTCorrectedImage);
%                 else
%                     %NEW Subpixel registration by crosscorrelation using DFTRegistration on whole image
%                     TempImage_FFT=fft2(TempImage);
%                     TempImage_Padded_Masked_Filtered_Enhanced_FFT=[];
%                     [OutputParams TempFFTOutput] = dftregistration(ReferenceImage_FFT,TempImage_FFT,DFT_UpScaleFactor);
%                     DeltaX_DFTReg_Whole(ImageNumber)=OutputParams(4);
%                     DeltaY_DFTReg_Whole(ImageNumber)=OutputParams(3);
%                     Error_DFTReg_Whole(ImageNumber)=OutputParams(1); 
%                     Diffphase_DFTReg_Whole(ImageNumber)=OutputParams(2); 
%                     TempDFTCorrectedImage=double(real(ifft2(TempFFTOutput)));
%                     ImageArrayReg_Whole(:,:,ImageNumber)=uint16(TempDFTCorrectedImage);
%                 end
%             end
%         %         Zach_a_Stack_Viewer(ImageArrayReg_Whole)
%         %         AutoPlaybackNew(ImageArrayReg_Whole,1,0.0001,[0,max(abs(ImageArrayReg_Whole(:)))*0.5],'jet')
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %Demon registration
%             jheapcl    
%             fprintf(['====================================================\n'])
%             fprintf('Starting Diffeomorphic Demon Registration...\n') 
%             TimeHandle=tic;
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             fprintf('Cleaning DFT Registered Array...\n')        
%             %clean up motion correction edges
%             progressbar('ImageNumber')
%             for ImageNumber=1:ImagingInfo.TotalNumFrames 
%                 progressbar(ImageNumber/ImagingInfo.TotalNumFrames)
%                 TempImage1 = ImageArrayReg_Whole(:,:,ImageNumber);
%                 EdgeMask=zeros(size(TempImage1));
%                 XShift=ceil(DeltaX_DFTReg_Whole(ImageNumber));
%                 YShift=ceil(DeltaY_DFTReg_Whole(ImageNumber));
%                 if XShift<0
%                     XShift=XShift-1;
%                     EdgeMask(:,size(EdgeMask,2)+XShift:size(EdgeMask,2))=1;
%                 elseif XShift>0
%                     XShift=XShift+1;
%                     EdgeMask(:,1:XShift)=1;
%                 end
%                 if YShift<0
%                     YShift=YShift-1;
%                     EdgeMask(size(EdgeMask,1)+YShift:size(EdgeMask,1),:)=1;
%                 elseif YShift>0
%                     YShift=YShift+1;
%                     EdgeMask(1:YShift,:)=1;
%                 end
%                 if DemonReg.PadValue_Method==1
%                     DFT_Fix_Value=median(TempImage1(:));
%                 elseif PadValueMethod==2
%                     DFT_Fix_Value=mean(TempImage1(:));
%                 elseif PadValueMethod==3
%                     DFT_Fix_Value=min(TempImage1(:));
%                 else
%                     DFT_Fix_Value=0;
%                 end
%                 TempImage1(logical(EdgeMask))=DFT_Fix_Value;
%                 ImageArrayReg_Whole(:,:,ImageNumber)=uint16(TempImage1);
%             end       
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             fprintf('Starting DEMON Registration\n')
%             if isfield(RegEnhancement,'DemonMask')
%                 if ~isempty(DemonReg.DemonMask)||sum(DemonReg.DemonMask(:))>0
%                     fprintf('NOTE: Applying a Demon Mask to Remove Off-Target Fluorescence...\n')
%                     figure, imshow(DemonReg.DemonMask)
%                 end
%             else
%                 DemonReg.DemonMask=[];
%             end
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             parfor ImageNumber=1:ImagingInfo.TotalNumFrames
%                 %disp(['Start ',num2str(BlockNumber),' ',num2str(ImageNumber)])
%                 TempImage=ImageArrayReg_Whole(:,:,ImageNumber);
% 
%                 %Determine Value to use for filling Pad area
%                 if DemonReg.PadValue_Method==1
%                     TempImage_Pad_Value=median(TempImage(:));
%                 elseif PadValueMethod==2
%                     TempImage_Pad_Value=mean(TempImage(:));
%                 elseif PadValueMethod==3
%                     TempImage_Pad_Value=min(TempImage(:));
%                 else
%                     TempImage_Pad_Value=0;
%                 end
% 
%                 %Pad Border
%                 TempImage_Padded = padarray(TempImage,[DemonReg.Padding DemonReg.Padding],TempImage_Pad_Value);
% 
%                 %Smooth pad interface border
%                 BorderAdjust1=zeros(size(AllBoutonsRegion_Orig_Mask_Padded));
%                 BorderAdjust1(1+DemonReg.Padding-RegEnhancement.BorderAdjustSize/2:size(BorderAdjust1,1)-DemonReg.Padding+RegEnhancement.BorderAdjustSize/2,1+DemonReg.Padding-RegEnhancement.BorderAdjustSize/2:size(BorderAdjust1,2)-DemonReg.Padding+RegEnhancement.BorderAdjustSize/2)=1;
%                 BorderAdjust2=zeros(size(AllBoutonsRegion_Orig_Mask_Padded));
%                 BorderAdjust2(1+DemonReg.Padding+RegEnhancement.BorderAdjustSize/2:size(BorderAdjust2,1)-DemonReg.Padding-RegEnhancement.BorderAdjustSize/2,1+DemonReg.Padding+RegEnhancement.BorderAdjustSize/2:size(BorderAdjust2,2)-DemonReg.Padding-RegEnhancement.BorderAdjustSize/2)=1;
%                 BorderAdjust=BorderAdjust1+BorderAdjust2;
%                 BorderAdjust(BorderAdjust==0)=1;
%                 BorderAdjust(BorderAdjust==2)=0;
%                 TempImage_Padded= roifilt2(fspecial('disk', 10),double(TempImage_Padded),logical(BorderAdjust));
% 
%                 %Enhance once to set up ROIs
%                 Temp_TempImage_Enhanced=Zach_enhanceContrastForDemon(imfilter(uint16(TempImage_Padded), fspecial('gaussian', RegEnhancement.EnhanceFilterSize_px,  RegEnhancement.EnhanceFilterSigma_px)),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);
%                 TempImage_Enhanced_Mask=Temp_TempImage_Enhanced;
%                 TempImage_Enhanced_Mask(TempImage_Enhanced_Mask<RegEnhancement.MaskSplitPercentage*max(Temp_TempImage_Enhanced(:)))=0;
%                 TempImage_Enhanced_Mask(TempImage_Enhanced_Mask>=RegEnhancement.MaskSplitPercentage*max(Temp_TempImage_Enhanced(:)))=1;
%                 TempImage_Enhanced_Mask=imdilate(TempImage_Enhanced_Mask,ones(RegEnhancement.MaskSplitDilate));
% 
%                 %Pick Mask that overlaps with AllBoutonsRegion_Orig
%                 [~,NumRegions] = bwlabel(AllBoutonsRegion_Orig_Padded);
%                 AllBoutounsRegion_Padded_ROIs=bwconncomp(AllBoutonsRegion_Orig_Padded);
%                 AllBoutounsRegion_Padded_ROIs_RegionProps = regionprops(AllBoutounsRegion_Padded_ROIs,'PixelList');
%                 TempImage_Enhanced_Mask_MatchedROI=zeros(size(TempImage_Enhanced_Mask));
%                 MaskOverlay=TempImage_Enhanced_Mask+AllBoutonsRegion_Orig_Padded;
%                 for z=1:NumRegions
%                     cont=1;
%                     k=1;
%                     while cont
%                         %if MaskOverlay(AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,2),AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,1))>1
%                              TempROI = bwselect(TempImage_Enhanced_Mask, AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,1),AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList(k,2));
%                              if any(TempROI(:)>0)
%                                  TempImage_Enhanced_Mask_MatchedROI=logical(TempImage_Enhanced_Mask_MatchedROI+TempROI);
%                                 cont=0;
% 
%                              elseif k>=size(AllBoutounsRegion_Padded_ROIs_RegionProps(z).PixelList,1)
%                                  cont=0;
%                              else
%                                  k=k+1;
%                              end
%                     end
%                 end
% 
%                 %Set up Bias with the new ROIs
%                 TempImage_Enhanced_Mask_MatchedROI_Biased=ones(size(TempImage_Enhanced_Mask_MatchedROI));
%                 for j=1:RegEnhancement.BiasRatios
%                     Temp=imdilate(TempImage_Enhanced_Mask_MatchedROI,ones(j*RegEnhancement.BiasRatioDiv));
%                     TempImage_Enhanced_Mask_MatchedROI_Biased=TempImage_Enhanced_Mask_MatchedROI_Biased+Temp;
%                 end
%                 TempImage_Enhanced_Mask_MatchedROI_Biased=TempImage_Enhanced_Mask_MatchedROI_Biased/max(TempImage_Enhanced_Mask_MatchedROI_Biased(:));
%                 TempImage_Enhanced_Mask_MatchedROI_Biased=TempImage_Enhanced_Mask_MatchedROI_Biased*RegEnhancement.BiasProportion+(1-RegEnhancement.BiasProportion);
%                 %use the dilated region for filtereing anything outside the regions
%                 TempImage_Enhanced_Mask_MatchedROI_Biased_Mask=TempImage_Enhanced_Mask_MatchedROI_Biased;
%                 TempImage_Enhanced_Mask_MatchedROI_Biased_Mask(TempImage_Enhanced_Mask_MatchedROI_Biased_Mask==min(TempImage_Enhanced_Mask_MatchedROI_Biased_Mask(:)))=0;
%                 TempImage_Enhanced_Mask_MatchedROI_Biased_Mask=logical(TempImage_Enhanced_Mask_MatchedROI_Biased_Mask);
%                 %Apply bias
%                 if RegEnhancement.Bias_Region
%                     TempImage_Padded_Biased=double(TempImage_Padded).*double(TempImage_Enhanced_Mask_MatchedROI_Biased);
%                 else
%                     TempImage_Padded_Biased=TempImage_Padded;
%                 end
%                 %filter all pixels outside of the region
%                 TempImage_Padded_Masked_Filtered = roifilt2(fspecial('disk', 10),double(TempImage_Padded_Biased),~logical(TempImage_Enhanced_Mask_MatchedROI_Biased_Mask));
%                 TempImage_Padded_Masked_Filtered_Enhanced=Zach_enhanceContrastForDemon(imfilter(uint16(TempImage_Padded_Masked_Filtered), fspecial('gaussian', RegEnhancement.EnhanceFilterSize_px,  RegEnhancement.EnhanceFilterSigma_px)),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);
% 
%                 %%%%%%%%%%%%%
%                 dField=double(zeros(size(ReferenceImage_Padded_Masked_Filtered_Enhanced,1),size(ReferenceImage_Padded_Masked_Filtered_Enhanced,2),2));
%                 if ~isempty(DemonReg.DemonMask)||sum(DemonReg.DemonMask(:))>0
%                     Mov_Image=TempImage_Padded_Masked_Filtered_Enhanced;
%                     Ref_Image=ReferenceImage_Padded_Masked_Filtered_Enhanced;
%                     Mov_Image(logical(DemonReg.DemonMask))=0;
%                     Ref_Image(logical(DemonReg.DemonMask))=0;
%                 else
%                     Mov_Image=TempImage_Padded_Masked_Filtered_Enhanced;
%                     Ref_Image=ReferenceImage_Padded_Masked_Filtered_Enhanced;
%                 end
% 
%                 if str2num(Temp_MatlabVersionYear)<2016
%                     [dField,~] = imregdemons_ZN(Mov_Image,Ref_Image,DemonReg.Iterations,...
%                         'PyramidLevels',DemonReg.PyramidLevels,'AccumulatedFieldSmoothing',DemonReg.AccumulatedFieldSmoothing);  
%                 else
%                     [dField,~] = imregdemons(Mov_Image,Ref_Image,DemonReg.Iterations,...
%                         'PyramidLevels',DemonReg.PyramidLevels,'AccumulatedFieldSmoothing',DemonReg.AccumulatedFieldSmoothing, 'DisplayWaitbar',false); 
%                 end
% 
%                 %%%%%%%%%%%%%
%                 demonDispFields{ImageNumber}.dField=dField;
%                 %disp(['End ',num2str(BlockNumber),'-',num2str(ImageNumber)])
%             end
%             fprintf(['Finished Calculating Demon Fields!\n'])
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             if DemonReg.SmoothDemon
%                 if DemonReg.FastSmoothing
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     TotalSmoothingArea=DemonReg.Intermediate_Crop_Props.BoundingBox(3)*DemonReg.Intermediate_Crop_Props.BoundingBox(4);
%                     VerticalPixels=DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(4);
%                     HorizontalPixels=DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(3);
%                     [demonDispFields,myPool]=SmoothDemonField(myPool,demonDispFields,DemonReg.DemonSmoothSize,DemonReg.DynamicSmoothing,IsDFTMoving,0,[],...
%                         DemonReg.PixelBlockSize,TotalSmoothingArea,VerticalPixels,HorizontalPixels);
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 else
%                     fprintf(['Starting Demon Smoothing...\n'])
%                     %Extract all pixel traces
%                     clear PixelStruct
%                     progressbar('Splitting Demon Field: Pixel #')
%                     PixelCount=0;
%                     TotalSmoothingArea=DemonReg.Intermediate_Crop_Props.BoundingBox(3)*DemonReg.Intermediate_Crop_Props.BoundingBox(4);
%                     fprintf(['Splitting Demon Fields...\n'])
%                     for i=DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(4)
%                         for j=DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(3)
%                             PixelCount=PixelCount+1;
%                             progressbar(PixelCount/TotalSmoothingArea)
%                             PixelStruct(PixelCount).TempVector=zeros(2,length(demonDispFields));
%                             PixelStruct(PixelCount).i=i;
%                             PixelStruct(PixelCount).j=j;
%                             for l=1:length(demonDispFields)
%                                 for k=1:2
%                                     PixelStruct(PixelCount).TempVector(k,l)=demonDispFields{l}.dField(i,j,k);
%                                 end
%                             end
%                         end
%                     end
%                     %Smooth
%                     fprintf(['Smoothing Demon Fields...\n'])
%                     parfor PixelCount=1:TotalSmoothingArea
%                         for k=1:2
%                             for z=1:length(DemonReg.DemonSmoothSize)     
%                                 if DemonReg.DynamicSmoothing
%                                     PixelStruct(PixelCount).TempVector(k,:)=Zach_MovingAvgFilter_Exclusions(PixelStruct(PixelCount).TempVector(k,:),DemonReg.DemonSmoothSize(z),IsDFTMoving);
%                                 else
%                                     PixelStruct(PixelCount).TempVector(k,:)=Zach_MovingAvgFilter_Exclusions(PixelStruct(PixelCount).TempVector(k,:),DemonReg.DemonSmoothSize(z),zeros(size(PixelStruct(PixelCount).TempVector(k,:))));
%                                     %old smooth
%                                     %PixelStruct(PixelCount).TempVector(k,:)=smooth(PixelStruct(PixelCount).TempVector(k,:),DemonReg.DemonSmoothSize);
%                                 end
%                             end
%                         end
%                     end
%                     fprintf(['Reconstructing Demon Fields...\n'])
%                     progressbar('Reconstructing Demon Field: Pixel #')
%                     for PixelCount=1:TotalSmoothingArea
%                         progressbar(PixelCount/TotalSmoothingArea)
%                         for k=1:2
%                             for l=1:length(demonDispFields)
%                                 demonDispFields{l}.dField(PixelStruct(PixelCount).i,PixelStruct(PixelCount).j,k)=PixelStruct(PixelCount).TempVector(k,l);
%                             end
%                         end
%                     end
%                     clear PixelStruct
%                     fprintf(['FINISHED Smoothing Demon Fields...\n'])
%                 end
%             else
%                 warning('NOTE: NOT SMOOTHING DEMON FIELD TIME DOMAIN!')
%             end
%             fprintf(['Applying Demon Fields...\n'])
%             ImageArrayReg=zeros(size(ImageArrayReg_Whole));
%             for ImageNumber=1:ImagingInfo.TotalNumFrames    
%                 TempImage1=ImageArrayReg_Whole(:,:,ImageNumber);
%                 if DemonReg.PadValue_Method==1
%                     TempImage_Pad_Value=median(TempImage1(:));
%                 elseif PadValueMethod==2
%                     TempImage_Pad_Value=mean(TempImage1(:));
%                 elseif PadValueMethod==3
%                     TempImage_Pad_Value=min(TempImage1(:));
%                 else
%                     TempImage_Pad_Value=0;
%                 end
%                 CorrectedImage=imwarp(double(padarray(TempImage1,[DemonReg.Padding DemonReg.Padding],TempImage_Pad_Value)),demonDispFields{ImageNumber}.dField);
%                 FinalizedImage=CorrectedImage(DemonReg.Padding+1:size(RegistrationSettings.OverallReferenceImage,1)+DemonReg.Padding,DemonReg.Padding+1:size(RegistrationSettings.OverallReferenceImage,2)+DemonReg.Padding);
%                 ImageArrayReg(:,:,ImageNumber) = FinalizedImage;
%                 % AutoPlaybackNew(ImageArrayReg,1,0.0001,[0,max(abs(ImageArrayReg(:)))*0.5],'jet');
%             end
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             fprintf(['====================================================\n'])
%             jheapcl
%             TimeInterval=toc(TimeHandle);
%             fprintf(['Demon Registration took: ',num2str((round(TimeInterval*10)/10)/60),' min or approx. ',num2str(((round(TimeInterval*10)/10))/ImagingInfo.TotalNumFrames),' s per image\n']);
%             fprintf(['====================================================\n'])
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %Refinement to remove any remaining jitters from demon 
%             %Crop
%             ImageArrayReg_Intermediate_Crop=ArrayCrop(ImageArrayReg,DemonReg.Intermediate_Crop_Props.BoundingBox);
%             ReferenceImage_Intermediate_Crop=imcrop(RegistrationSettings.OverallReferenceImage,DemonReg.Intermediate_Crop_Props.BoundingBox);        
%             clear ImageArrayReg
%             %Second Round of DFT subpixel registration refinement on small region        
%             TimeHandle=tic;
%             DeltaX_DFTReg_Intermediate_Crop=zeros(1, ImagingInfo.TotalNumFrames); 
%             DeltaY_DFTReg_Intermediate_Crop=zeros(1, ImagingInfo.TotalNumFrames); 
%             DeltaX_DFTReg_Bouton_Intermediate_Crop=zeros(size(BoutonArray,2),ImagingInfo.TotalNumFrames);
%             DeltaY_DFTReg_Bouton_Intermediate_Crop=zeros(size(BoutonArray,2),ImagingInfo.TotalNumFrames);
%             ReferenceImage_Intermediate_Crop=uint16(ReferenceImage_Intermediate_Crop);
%             %figure, imshow(ReferenceImage.*uint16(AllBoutonsRegion_Orig),[]);
%             ReferenceImage_Intermediate_Crop_FFT=fft2(ReferenceImage_Intermediate_Crop);
%             ImageArrayReg_Intermediate_Crop_Reg=zeros(size(RegistrationSettings.ReferenceImage_Intermediate_Crop,1),size(RegistrationSettings.ReferenceImage_Intermediate_Crop,2),ImagingInfo.TotalNumFrames);
%             fprintf('Intermediate Cropped Data DFT Refinement...\n')
%              parfor ImageNumber=1:ImagingInfo.TotalNumFrames 
%                 %load and filter each image 
%                 %NEW Subpixel registration by crosscorrelation using DFTRegistration on whole image
%                 TempImage_FFT=fft2(uint16(ImageArrayReg_Intermediate_Crop(:,:,ImageNumber)));
% 
%                 [OutputParams TempFFTOutput] = dftregistration(ReferenceImage_Intermediate_Crop_FFT,TempImage_FFT,DFT_UpScaleFactor);
%                 DeltaX_DFTReg_Intermediate_Crop(ImageNumber)=OutputParams(4);
%                 DeltaY_DFTReg_Intermediate_Crop(ImageNumber)=OutputParams(3);
%                 TempDFTCorrectedImage=double(real(ifft2(TempFFTOutput)));
%                 ImageArrayReg_Intermediate_Crop_Reg(:,:,ImageNumber)=uint16(TempDFTCorrectedImage);
%              end
%             TimeInterval=toc(TimeHandle);
%             fprintf(['Intermediate DFT Refinement Took: ',num2str(round(TimeInterval*10)/10),' s\n']);
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             if DemonReg.BoutonRefinement
%                 fprintf('Bouton DFT Refinement...\n')
%                 TimeInterval=toc(TimeHandle);
%                 PixelBorder=ones(DemonReg.BorderBufferPixelSize);%This adds buffer zone (10x10 works well most of the time) to boutons to avoid FFT artifacts, may cause problems with ROI too close to borders
%                 LastBoutonNumber=length(BoutonArray);
%                 for BoutonNumber=1:LastBoutonNumber        
%                     TempBoutonStruct(BoutonNumber).Temp_ImageArray_Reg_Bouton=zeros(size(RegistrationSettings.ReferenceImage_Intermediate_Crop,1),size(RegistrationSettings.ReferenceImage_Intermediate_Crop,1),ImagingInfo.TotalNumFrames);
%                 end
% 
%                 %Show Boutons
%                 figure, imshow(ReferenceImage_Intermediate_Crop,[]);
%                 hold on
%                 for BoutonNumber=1:LastBoutonNumber        
%                     plot(BoutonArray(BoutonNumber).TempBorderX-DemonReg.Intermediate_Crop_Props.BoundingBox(1), BoutonArray(BoutonNumber).TempBorderY-DemonReg.Intermediate_Crop_Props.BoundingBox(2),'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 1);
%                 end
%                 set(gcf,'units','normalized','position',[0.1,0.1,0.8,0.8]), drawnow, pause(0.0001)
% 
%                 progressbar('Bouton Refinement: Bouton #')
%                 %progressbar('Bouton Refinement: Bouton #','Bouton Alignment: Image #')
%                 for BoutonNumber=1:LastBoutonNumber
%                     progressbar((BoutonNumber-1)/LastBoutonNumber)
%                     AlignRegion_Bouton=ArrayCrop(BoutonArray(BoutonNumber).ImageArea,DemonReg.Intermediate_Crop_Props.BoundingBox);
%                     %AlignRegion_Bouton = BoutonArray(BoutonNumber).ImageArea;
%                     RegionsProps_Bouton = regionprops(double(AlignRegion_Bouton), 'BoundingBox', 'PixelIdxList');
%                     %Add buffer region
%                     AlignRegion_BoutonBorder_Thick = bwperim(AlignRegion_Bouton,8);
%                     AlignRegion_BoutonBorder_Thick = imdilate(AlignRegion_BoutonBorder_Thick,PixelBorder);
%                     AlignRegion_Bouton_Thick = logical(AlignRegion_Bouton+AlignRegion_BoutonBorder_Thick);clear AlignRegion_BoutonBorder_Thick
%                     RegionsProps_Bouton_Thick = regionprops(double(AlignRegion_Bouton_Thick), 'BoundingBox', 'PixelIdxList');
%                     RegionsProps_Bouton_Thick.BoundingBox=round(RegionsProps_Bouton_Thick.BoundingBox);
%                     AlignRegion_Bouton_Crop=imcrop(AlignRegion_Bouton,[RegionsProps_Bouton_Thick.BoundingBox]);
%                     ZerosImage1=zeros(size(ImageArrayReg_Intermediate_Crop_Reg,1),size(ImageArrayReg_Intermediate_Crop_Reg,2));
%                     ZerosImage1=imcrop(ZerosImage1,[RegionsProps_Bouton_Thick.BoundingBox]);
% 
%                     %Remove buffered region data from ImageArray
%                     TempImageArray=zeros(size(ZerosImage1,1),size(ZerosImage1,2),ImagingInfo.TotalNumFrames);
%                     for ImageNumber=1:ImagingInfo.TotalNumFrames
%                         TempImage1=ImageArrayReg_Intermediate_Crop_Reg(:,:,ImageNumber);
%                         TempImageCrop=imcrop(TempImage1,[RegionsProps_Bouton_Thick.BoundingBox]);
%                         TempImageArray(:,:,ImageNumber)=TempImageCrop;
%                     end
%                     TempBoutonStruct(BoutonNumber).Temp_ImageArray_Reg_Bouton=zeros(size(TempImageArray));
%                     FirstImage_Bouton=imcrop(RegistrationSettings.OverallReferenceImage_Intermediate_Crop,[RegionsProps_Bouton_Thick.BoundingBox]);
%                     TempBoutonStruct(BoutonNumber).ExpandYCoords=[RegionsProps_Bouton_Thick.BoundingBox(2):RegionsProps_Bouton_Thick.BoundingBox(2)+RegionsProps_Bouton_Thick.BoundingBox(4)];
%                     TempBoutonStruct(BoutonNumber).ExpandXCoords=[RegionsProps_Bouton_Thick.BoundingBox(1):RegionsProps_Bouton_Thick.BoundingBox(1)+RegionsProps_Bouton_Thick.BoundingBox(3)];
%                     TempBoutonStruct(BoutonNumber).AlignRegion_Bouton_Crop=AlignRegion_Bouton_Crop;
%                     ReferenceImage_Intermediate_Crop_Bouton=uint16(FirstImage_Bouton);
%                     ReferenceImage_Intermediate_Crop_Bouton_FFT=fft2(ReferenceImage_Intermediate_Crop_Bouton);
%                     for ImageNumber=1:ImagingInfo.TotalNumFrames 
%                         %progressbar((BoutonNumber-1)/LastBoutonNumber,ImageNumber/ImagingInfo.TotalNumFrames)
%                         TempImage_Bouton = TempImageArray(:,:,ImageNumber);
%                         %NEW Subpixel registration by crosscorrelation using DFTRegistration on whole image
%                         TempImage_FFT=fft2(TempImage_Bouton);
% 
%                         [OutputParams TempFFTOutput] = dftregistration(ReferenceImage_Intermediate_Crop_Bouton_FFT,TempImage_FFT,DFT_UpScaleFactor);
%                         DeltaX_DFTReg_Bouton_Intermediate_Crop(BoutonNumber,ImageNumber)=OutputParams(4);
%                         DeltaY_DFTReg_Bouton_Intermediate_Crop(BoutonNumber,ImageNumber)=OutputParams(3);
%                         TempDFTCorrectedImage=double(real(ifft2(TempFFTOutput)));
%                         TempBoutonStruct(BoutonNumber).Temp_ImageArray_Reg_Bouton(:,:,ImageNumber)=TempDFTCorrectedImage;            
%                         clear TempImage_FFT TempFFTOutput OutputParams TempDFTCorrectedImage
%                     end
%                     clear TempImageArray ReferenceImage_Intermediate_Crop_Bouton_FFT
%                 end
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 fprintf('Reconstructing Image...\n')
%                 ZerosImage1=zeros(size(ImageArrayReg_Intermediate_Crop,1),size(ImageArrayReg_Intermediate_Crop,2));  
%                 for ImageNumber=1:ImagingInfo.TotalNumFrames
%                     ImageArrayReg_Intermediate_Crop_BoutonRefined(:,:,ImageNumber)=uint16(ZerosImage1);
%                 end
%                 progressbar('Merging Data: Image #','Merging Data: Bouton #')
%                 for ImageNumber=1:ImagingInfo.TotalNumFrames
%                     TempFrame=ZerosImage1;
%                     for BoutonNumber=1:LastBoutonNumber
%                         TempImage_Expanded=ZerosImage1;
%                         progressbar(ImageNumber/ImagingInfo.TotalNumFrames,(BoutonNumber-1)/LastBoutonNumber)
%                         TempImage1=TempBoutonStruct(BoutonNumber).Temp_ImageArray_Reg_Bouton(:,:,ImageNumber);
%                         TempImage1=TempImage1.*TempBoutonStruct(BoutonNumber).AlignRegion_Bouton_Crop;
%                         TempImage_Expanded(TempBoutonStruct(BoutonNumber).ExpandYCoords,TempBoutonStruct(BoutonNumber).ExpandXCoords)=TempImage1;
%                         TempFrame=max(TempFrame,TempImage_Expanded);
%                         clear TempImage1 TempImage_Expanded
%                     end
%                     ImageArrayReg_Intermediate_Crop_BoutonRefined(:,:,ImageNumber)=uint16(TempFrame);
%                     clear TempFrame
%                 end
%             else
%                 fprintf('SKIPPING Bouton DFT Refinement...\n')
%                 ImageArrayReg_Intermediate_Crop_BoutonRefined=ImageArrayReg_Intermediate_Crop_Reg;
%             end
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %Final Crop and mask
%             fprintf('Final Cropping ImageArrayReg_FirstImages...')
%             ImageArrayReg_FirstImages=[];
%             for EpisodeNumber=1:ImagingInfo.NumEpisodes 
%                 ImageArrayReg_FirstImages(:,:,EpisodeNumber)=uint16(ZerosImage_Crop);
%             end
%             for EpisodeNumber=1:ImagingInfo.NumEpisodes 
%                 ImageArrayReg_FirstImages(:,:,EpisodeNumber)=uint16(imcrop(ImageArrayDemonReg_FirstImages(:,:,EpisodeNumber),[Crop_Props.BoundingBox]));
%             end
%             fprintf('Masking FirstImages...')
%             for EpisodeNumber=1:ImagingInfo.NumEpisodes 
%                 ImageArrayReg_FirstImages(:,:,EpisodeNumber)=uint16(double(ImageArrayReg_FirstImages(:,:,EpisodeNumber)).*double(imcrop(AllBoutonsRegion_Orig,[Crop_Props.BoundingBox])));
%             end    
%             fprintf('Finished!\n')
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             fprintf('Final Cropping ImageArrayReg_AllImages...')
%             ImageArrayReg_AllImages=[];
%             for ImageNumber=1:ImagingInfo.TotalNumFrames 
%                 ImageArrayReg_AllImages(:,:,ImageNumber)=uint16(ZerosImage_Crop);
%             end
%             progressbar('ImageNumber')
%             for ImageNumber=1:ImagingInfo.TotalNumFrames
%                 progressbar(ImageNumber/ImagingInfo.TotalNumFrames)
%                 ImageArrayReg_AllImages(:,:,ImageNumber)=uint16(imcrop(ImageArrayDemonReg_AllImages(:,:,ImageNumber),[Crop_Props.BoundingBox]));
%             end
%             fprintf('Masking ImageArrayReg_AllImages...')
%             progressbar('ImageNumber')
%             for ImageNumber=1:ImagingInfo.TotalNumFrames
%                 progressbar(ImageNumber/ImagingInfo.TotalNumFrames)
%                 ImageArrayReg_AllImages(:,:,ImageNumber)=uint16(double(ImageArrayReg_AllImages(:,:,ImageNumber)).*double(imcrop(AllBoutonsRegion_Orig,[Crop_Props.BoundingBox])));
%             end
%             fprintf('Finished!\n')
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %                 AutoPlaybackNew(ImageArrayReg_FirstImages,1,0.0001,[0 max(ImageArrayReg_FirstImages(:))*0.8],'jet');
% %                 AutoPlaybackNew(ImageArrayReg_AllImages,1,0.0001,[0 max(ImageArrayReg_AllImages(:))*0.8],'jet');
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             fprintf('Finished Alignment!\n');
%             fprintf(['====================================================\n'])
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         end
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['==========================================================================================\n'])
    fprintf(['==========================================================================================\n'])
    fprintf(['==========================================================================================\n'])
    close all
    clear ImageArrayReg ImageArrayReg_Intermediate_Crop_BoutonRefined TempBoutonStruct ImageArrayReg_Intermediate_Crop ImageArrayReg_Intermediate_Crop_Reg
    clear ImageArray_Temp ImageArray_Temp_Delta RefStack
    if exist(TempScratchSaveDir)
        warning('Deleting Temp File Directory...')
        rmdir(TempScratchSaveDir);
    end
    if SaveDemonField
        fprintf('Saving Demon Fields...\n')
        FileSuffix='_DemonRegDispFields.mat'
        save([CurrentScratchDir,dc,StackSaveName,FileSuffix],'demonDispFields','FirstImage_demonDispFields'); 
        clear demonDispFields
        fprintf('Finished!\n')
    end
    FileSuffix='_RegistrationData.mat';
    fprintf(['Saving... ',StackSaveName,FileSuffix,'...']);
    save([CurrentScratchDir,dc,StackSaveName,FileSuffix],...
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
    fprintf(['==========================================================================================\n'])
    fprintf(['==========================================================================================\n'])
    fprintf(['==========================================================================================\n'])
    OverallTime=toc(OverallTimer);
    fprintf(['Registration took: ',num2str(round(OverallTime*10)/10),' s\n']);
    fprintf(['==========================================================================================\n'])
    fprintf(['==========================================================================================\n'])
    fprintf(['==========================================================================================\n'])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


