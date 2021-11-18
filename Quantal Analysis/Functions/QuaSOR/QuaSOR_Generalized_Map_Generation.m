function QuaSOR_Generalized_Map_Generation(StackSaveName,StackSaveNameSuffix,IbIs,myPool,...
    QuaSOR_Gaussian_Filter_Sigmas,QuaSOR_Gaussian_Filter_SizeBuffer,QuaSOR_Gaussian_Filter_Sizes,...
    QuaSOR_TemporalColorizations,QuaSOR_Overlay_FilterIndex,QuaSOR_Overlay_ContrastIndex,QuaSOR_Overlay_Color,...
    OQA_Gaussian_Filter_Sigmas,OQA_Gaussian_Filter_SizeBuffer,OQA_Gaussian_Filter_Sizes,...
    OQA_TemporalColorizations,OQA_Overlay_FilterIndex,OQA_Overlay_ContrastIndex,OQA_Overlay_Color,...
    SpotNormalization,ExportColorMap,ExportBorderColor,ContrastEnhancements,Bouton_Region_Mask_Background_Color,ExportImages,...
    IbIs_CoordinateAdjust)
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%     StackSaveName='CpxRNAi_42017_OK6_GC6_25C_MiniEvoked_1_Mini2_Ib_I_Mini';
%     StackSaveName='CpxRNAi_42017_OK6_GC6_25C_MiniEvoked_1_Evoked2_Ib_I_02Hz';
% 
%     QuaSOR_Gaussian_Filter_Sigmas=[0,1,2,3,4,5];
%     QuaSOR_Gaussian_Filter_SizeBuffer=7;            %Only needed if autogenerating gaussian filter size
%     QuaSOR_Gaussian_Filter_Sizes=[];                %populate if you want to manually control filter size
%     QuaSOR_TemporalColorizations=[0,0,0,0,0,0];
%     QuaSOR_Overlay_FilterIndex=2;
%     QuaSOR_Overlay_ContrastIndex=4;
%     QuaSOR_Overlay_Color='y';
%     
%     OQA_Gaussian_Filter_Sigmas=[0,0.6,0.8,1.0,1.2];
%     OQA_Gaussian_Filter_SizeBuffer=3;            %Only needed if autogenerating gaussian filter size
%     OQA_Gaussian_Filter_Sizes=[];                %populate if you want to manually control filter size
%     OQA_TemporalColorizations=[0,0,0,0,0];
%     OQA_Overlay_FilterIndex=4;
%     OQA_Overlay_ContrastIndex=5;
%     OQA_Overlay_Color='b';
% 
%     SpotNormalization=true;
%     ExportColorMap='jet';
%     ExportBorderColor='w';
%     ContrastEnhancements=[1 0.8 0.6 0.5 0.4 0.2 0.1];
%     Bouton_Region_Mask_Background_Color=[0.3,0.3,0.3];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Some other less important defaults
    ScreenSize=get(0,'ScreenSize');
    QuaSOR_BorderLine_Width=2;
    QuaSOR_Color_Scalar=10000;
    QuaSOR_PixelSizeScalar=1;
    OQA_BorderLine_Width=1;
    OQA_Color_Scalar=10000;
    OQA_PixelSizeScalar=2;
    DisplayIntermediates=0;
    CheckForRegCoord=1;
    GPU_Memory_Miniumum=5e9;
    RemoveDuplicates=1;
    %IbIs_CoordinateAdjust=-1; %Use in conjunction with UpScale_Fix_Adjust from original mapping
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    OverallTimer=tic;
    [OS,dc,ParentDir,ParentDir1,ParentDir2,ParentDir3,TemplateDir,ScratchDir]=BatchStartup;
    CurrentDir=cd;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    warning('Trying to intialize GPU...')
    try
        GPU_Device=gpuDevice;
        GPU_Accelerate=true;
        disp(['GPU Processing using the ',GPU_Device.Name,' is ENGAGED!'])
        disp(['GPU: ',num2str(round(GPU_Device.AvailableMemory/1e9*100)/100),'/',...
            num2str(round(GPU_Device.TotalMemory/1e9*100)/100),' GB Memory | ',...
            num2str(GPU_Device.MultiprocessorCount),' Processors | ',...
            num2str(GPU_Device.MaxThreadsPerBlock),' Threads/Block'])
        if GPU_Device.TotalMemory<GPU_Memory_Miniumum
            warning('Total GPU memory may be too small so turning off GPU Acceleration!')
            GPU_Accelerate=false;
        end
    catch
        warning('NO GPU WITH CUDA AVAILABlE!!')
        GPU_Device=[];
        GPU_Accelerate=false;
    end
    if exist('myPool')&&myPool.Connected~=0
        disp('Parpool active...')
    else
        delete(gcp('nocreate'))
        myPool=parpool;%
    end
    close all
    warning on all
    warning off backtrace
    warning off verbose
    jheapcl
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('=======================================================================')
    disp('New Quantal Analysis Map Processing...')    
    disp(['ID = ',StackSaveName,StackSaveNameSuffix])
    SaveDir=[CurrentDir,dc,StackSaveName,StackSaveNameSuffix,' QuaSOR Figs'];
    
    if length([SaveDir])>180
        warning on
        warning('Using short SaveDir...')
        warning('Using short SaveDir...')
        warning('Using short SaveDir...')
        warning('Using short SaveDir...')
        warning('Using short SaveDir...')
        warning('Using short SaveDir...')
        SaveDir=[CurrentDir,dc,StackSaveName(length(StackSaveName)-2:length(StackSaveName)),StackSaveNameSuffix,' QuaSOR Figs'];
    end
        
    if ~exist(SaveDir)
        mkdir(SaveDir)
    end
    PooledSaveDir=[ParentDir,dc,'Pooled QuaSOR Maps'];
    if ~exist(PooledSaveDir)
        mkdir(PooledSaveDir)
    end
    
    if IbIs
        fprintf('Checking that this is actually IbIs file!  ')
        if ~exist([StackSaveName,StackSaveNameSuffix,'_IbIs_Merged_Data.mat'])
            warning('File missing reverting to non IbIs...')
            IbIs=0;
        else
            fprintf('OK!\n')
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('=======================================================================')
    disp('Traditional OQA Map Processing...')
    if IbIs
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('IbIs Merged Data Selection Active...')
        
        fprintf('Loading OQA IbIs_Merged_Data...')
        warning off
        load([StackSaveName,StackSaveNameSuffix,'_IbIs_Merged_Data.mat'],...
            'ImageArray_Max_Sharp_IbIs_Merge',...
            'ImageArray_HighFreq_Max_Sharp_IbIsMerge',...
            'ImageArray_NoStim_Max_Sharp_IbIsMerge',...
            'AllBoutonsRegion_Ib_Crop','AllBoutonsRegion_Is_Crop',...
            'ScaleBar')
        warning on
        AllBoutonsRegion_IbIs_Crop=logical(AllBoutonsRegion_Ib_Crop+AllBoutonsRegion_Is_Crop);
        fprintf('FINISHED!\n')
   
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Identifying Experiment Type...')
        if exist('ImageArray_Max_Sharp_IbIs_Merge')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            disp('Looks like a low frequency evoked experiment...')
            ExpType='Evoked';
            ImageArray_Max_Sharp=ImageArray_Max_Sharp_IbIs_Merge;
            ImageArray_Max_Sharp(isnan(ImageArray_Max_Sharp))=0;
            fprintf('Finding Traditional Quantal Coordinates...')
            progressbar('Finding Traditional Quantal Coordinates ||| Frame #')
            OQA_NumFrames=size(ImageArray_Max_Sharp,3);
            OQA_All_Location_Coords=[];
            for Frame=1:OQA_NumFrames
                progressbar(Frame/OQA_NumFrames)
                [TempY,TempX]=find(ImageArray_Max_Sharp(:,:,Frame));
                TempT=ones(size(TempY))*Frame;
                Temp_Location_Coords=horzcat(TempY,TempX);
                Temp_Location_Coords=horzcat(Temp_Location_Coords,TempT);
                OQA_All_Location_Coords=vertcat(OQA_All_Location_Coords,Temp_Location_Coords);
                clear Temp_Location_Coords TempX TempY TempT
            end
            fprintf('FINISHED!\n')
            fprintf('Calculating Traditional Quantal Maps Sizes...\n')
            if size(ImageArray_Max_Sharp,1)~=size(AllBoutonsRegion_IbIs_Crop,1)||...
                size(ImageArray_Max_Sharp,2)~=size(AllBoutonsRegion_IbIs_Crop,2)
                error('Size mismatch between ImageArray and AllBoutonsRegion_IbIs_Crop!')
            end
            OQA_ImageHeight=size(ImageArray_Max_Sharp,1);
            OQA_ImageWidth=size(ImageArray_Max_Sharp,2);
            OQA_UpScaleFactor=1;
            clear ImageArray_Max_Sharp_IbIs_Merge ImageArray_Max_Sharp
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\        
        elseif exist('ImageArray_HighFreq_Max_Sharp_IbIsMerge')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            disp(['Looks like a high frequency evoked experiment (',StackSaveNameSuffix,')...'])
            ExpType=['HF',StackSaveNameSuffix];
            ImageArray_Max_Sharp=ImageArray_HighFreq_Max_Sharp_IbIsMerge;
            ImageArray_Max_Sharp(isnan(ImageArray_Max_Sharp))=0;
            fprintf('Finding Traditional Quantal Coordinates...')
            progressbar('Finding Traditional Quantal Coordinates ||| Frame #')
            OQA_NumFrames=size(ImageArray_Max_Sharp,3);
            OQA_All_Location_Coords=[];
            for Frame=1:OQA_NumFrames
                progressbar(Frame/OQA_NumFrames)
                [TempY,TempX]=find(ImageArray_Max_Sharp(:,:,Frame));
                TempT=ones(size(TempY))*Frame;
                Temp_Location_Coords=horzcat(TempY,TempX);
                Temp_Location_Coords=horzcat(Temp_Location_Coords,TempT);
                OQA_All_Location_Coords=vertcat(OQA_All_Location_Coords,Temp_Location_Coords);
                clear Temp_Location_Coords TempX TempY TempT
            end
            fprintf('FINISHED!\n')
            fprintf('Calculating Traditional Quantal Maps Sizes...\n')
            if size(ImageArray_Max_Sharp,1)~=size(AllBoutonsRegion_IbIs_Crop,1)||...
                size(ImageArray_Max_Sharp,2)~=size(AllBoutonsRegion_IbIs_Crop,2)
                error('Size mismatch between ImageArray and AllBoutonsRegion_IbIs_Crop!')
            end
            OQA_ImageHeight=size(ImageArray_Max_Sharp,1);
            OQA_ImageWidth=size(ImageArray_Max_Sharp,2);
            OQA_UpScaleFactor=1;
            clear ImageArray_HighFreq_Max_Sharp_IbIsMerge ImageArray_Max_Sharp
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif exist('ImageArray_NoStim_Max_Sharp_IbIsMerge')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            disp('Looks like a spontaneous experiment...')
            ExpType='Spont';
            ImageArray_Max_Sharp=ImageArray_NoStim_Max_Sharp_IbIsMerge;
            ImageArray_Max_Sharp(isnan(ImageArray_Max_Sharp))=0;
            fprintf('Finding Traditional Quantal Coordinates...')
            progressbar('Finding Traditional Quantal Coordinates ||| Frame #')
            OQA_NumFrames=size(ImageArray_Max_Sharp,3);
            OQA_All_Location_Coords=[];
            for Frame=1:OQA_NumFrames
                progressbar(Frame/OQA_NumFrames)
                [TempY,TempX]=find(ImageArray_Max_Sharp(:,:,Frame));
                TempT=ones(size(TempY))*Frame;
                Temp_Location_Coords=horzcat(TempY,TempX);
                Temp_Location_Coords=horzcat(Temp_Location_Coords,TempT);
                OQA_All_Location_Coords=vertcat(OQA_All_Location_Coords,Temp_Location_Coords);
                clear Temp_Location_Coords TempX TempY TempT
            end
            fprintf('FINISHED!\n')
            fprintf('Calculating Traditional Quantal Maps Sizes...\n')
            if size(ImageArray_Max_Sharp,1)~=size(AllBoutonsRegion_IbIs_Crop,1)||...
                size(ImageArray_Max_Sharp,2)~=size(AllBoutonsRegion_IbIs_Crop,2)
                error('Size mismatch between ImageArray and AllBoutonsRegion!')
            end
            OQA_ImageHeight=size(ImageArray_Max_Sharp,1);
            OQA_ImageWidth=size(ImageArray_Max_Sharp,2);
            OQA_UpScaleFactor=1;
            clear ImageArray_NoStim_Max_Sharp_IbIsMerge ImageArray_Max_Sharp
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        else
            error('unknown experiment type!')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif exist([StackSaveName,StackSaveNameSuffix,'_ImageArrayReg_AllImages_DeltaGFP_1.mat'])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Looks like a spontaneous experiment...')
        ExpType='Spont';
        %Find All Associated files
        FileList=dir([StackSaveName,StackSaveNameSuffix,'_ImageArrayReg_AllImages_DeltaGFP_*.*']);
        NumFiles=length(FileList);
        disp(['Found ',num2str(NumFiles),' ',StackSaveName,StackSaveNameSuffix,'_ImageArrayReg_AllImages_DeltaGFP_X.mat Files'])
        try
            fprintf(['Loading OQA Data from: ',StackSaveName,StackSaveNameSuffix,'_ImageArrayReg_AllImages_DeltaGFP_1.mat...\n'])
            load([StackSaveName,StackSaveNameSuffix,'_ContinuousImagingAnalysis.mat'],'AllBoutonsRegion','Crop_Props')
            if ~exist('AllBoutonsRegion')
                error('Missing AllBoutonsRegion!')
            end
            ImageArray_Max_Sharp=[];
            progressbar('File')
            for FileNum=1:NumFiles
                progressbar(FileNum/NumFiles)
                fprintf(['Loading ImageArray_NoStim_Max_Sharp from: ',StackSaveName,StackSaveNameSuffix,'_ImageArrayReg_AllImages_DeltaGFP_',num2str(FileNum),'.mat...'])
                load([StackSaveName,StackSaveNameSuffix,'_ImageArrayReg_AllImages_DeltaGFP_',num2str(FileNum),'.mat'],'ImageArray_NoStim_Max_Sharp')
                
                if ~exist('ImageArray_NoStim_Max_Sharp')
                    try
                        disp(['Loading and processing <ImageArray_NoStim_Max_Sharp> for File # ',num2str(FileNum)]);
                        load([StackSaveName,StackSaveNameSuffix,'_ImageArrayReg_AllImages_DeltaGFP_',num2str(FileNum),'.mat'],'ImageArray_NoStim_CorrAmp_thresh_filtered');
                        ImageArray_NoStim_CorrAmp_thresh_filtered=imfilter(ImageArray_NoStim_CorrAmp_thresh, fspecial('gaussian', PreMax_FilterSize, PreMax_FilterSigma));
                        ImageArray_NoStim_BW = ThreshArray(ImageArray_NoStim_CorrAmp_thresh_filtered, threshold_1);
                        ImageArray_NoStim_Max = ExtendedMaxArray(ImageArray_NoStim_CorrAmp_thresh_filtered, threshold);
                        ImageArray_NoStim_Max = ImageArray_NoStim_Max .* ImageArray_NoStim_BW;
                        ImageArray_NoStim_Max = imclose(ImageArray_NoStim_Max, se);
                        ImageArray_NoStim_Max_Sharp=zeros(size(ImageArray_NoStim_Max));
                        for ImageNumber=1:FramesPerSequence 
                            TempImage = ImageArray_NoStim_Max(:,:,ImageNumber);
                            TempImage = imfill(TempImage, 'holes'); % fill holes, for next steps to work
                            TempImage = bwmorph(TempImage, 'shrink', Inf); % Shrink each maxima to one pixel, to make a clear decision whether it is in the chosen region
                            ImageArray_NoStim_Max_Sharp(:,:,ImageNumber)=TempImage;
                        end
                        disp(['Index#',num2str(IndexNumber),' # Prelim Max = ',num2str(sum(ImageArray_NoStim_Max_Sharp(:)))])

                        clear ImageArray_NoStim_CorrAmp_thresh_filtered ImageArray_NoStim_Max
                        ImageArray_Max_Sharp=ImageArray_NoStim_Max_Sharp;
                        clear ImageArray_NoStim_Max_Sharp

                    catch
                       error('Still cant find OQA Data!') 
                    end
                end
                
                
                ImageArray_Max_Sharp=cat(3,ImageArray_Max_Sharp,ImageArray_NoStim_Max_Sharp);
                clear ImageArray_NoStim_Max_Sharp
                fprintf('FINISHED!\n')
            end
        catch
            warning('Unable to find ImageArray_NoStim_Max_Sharp... Trying alternative...')
            try
                fprintf(['Loading OQA Data from: ',StackSaveName,StackSaveNameSuffix,'_Results1.mat...\n'])
                load([StackSaveName,StackSaveNameSuffix,'_ContinuousImagingAnalysis.mat'],'AllBoutonsRegion','Crop_Props')
                load([StackSaveName,StackSaveNameSuffix,'_Results1.mat'],'ImageArray_NoStim_Max_Sharp')
                if ~exist('AllBoutonsRegion')
                   error('Missing AllBoutonsRegion!')
                end
                ImageArray_Max_Sharp=ImageArray_NoStim_Max_Sharp;
                clear ImageArray_NoStim_Max_Sharp
            catch
                error('Still Having a Problem finding OQA...')
            end
        end
        fprintf('Finding Traditional Quantal Coordinates...')
        progressbar('Finding Traditional Quantal Coordinates ||| Frame #')
        OQA_NumFrames=size(ImageArray_Max_Sharp,3);
        OQA_All_Location_Coords=[];
        for Frame=1:OQA_NumFrames
            progressbar(Frame/OQA_NumFrames)
            [TempY,TempX]=find(ImageArray_Max_Sharp(:,:,Frame));
            TempT=ones(size(TempY))*Frame;
            Temp_Location_Coords=horzcat(TempY,TempX);
            Temp_Location_Coords=horzcat(Temp_Location_Coords,TempT);
            OQA_All_Location_Coords=vertcat(OQA_All_Location_Coords,Temp_Location_Coords);
            clear Temp_Location_Coords TempX TempY TempT
        end
        fprintf('FINISHED!\n')
        fprintf('Calculating Traditional Quantal Maps Sizes...\n')
        if size(ImageArray_Max_Sharp,1)~=size(AllBoutonsRegion,1)||...
            size(ImageArray_Max_Sharp,2)~=size(AllBoutonsRegion,2)
            error('Size mismatch between ImageArray and AllBoutonsRegion!')
        end
        OQA_ImageHeight=size(ImageArray_Max_Sharp,1);
        OQA_ImageWidth=size(ImageArray_Max_Sharp,2);
        OQA_UpScaleFactor=1;
        clear ImageArray_NoStim_Max_Sharp ImageArray_Max_Sharp
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    elseif exist([StackSaveName,StackSaveNameSuffix,'_HighFreqContinuousImagingAnalysis.mat'])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp(['Looks like a high frequency evoked experiment (',StackSaveNameSuffix,')...'])
        ExpType=['HF',StackSaveNameSuffix];
        try
            fprintf(['Loading OQA Data from: ',StackSaveName,StackSaveNameSuffix,'_Results1.mat...\n'])
            load([StackSaveName,StackSaveNameSuffix,'_HighFreqContinuousImagingAnalysis.mat'],'AllBoutonsRegion','Crop_Props')
            load([StackSaveName,StackSaveNameSuffix,'_Results1.mat'],'ImageArray_HighFreq_Max_Sharp')
            if ~exist('AllBoutonsRegion')
               error('Missing AllBoutonsRegion!')
            end
            ImageArray_Max_Sharp=ImageArray_HighFreq_Max_Sharp;
            clear ImageArray_HighFreq_Max_Sharp
        catch
            error('Still Having a Problem finding OQA...')
        end        
        fprintf('Finding Traditional Quantal Coordinates...')
        progressbar('Finding Traditional Quantal Coordinates ||| Frame #')
        OQA_NumFrames=size(ImageArray_Max_Sharp,3);
        OQA_All_Location_Coords=[];
        for Frame=1:OQA_NumFrames
            progressbar(Frame/OQA_NumFrames)
            [TempY,TempX]=find(ImageArray_Max_Sharp(:,:,Frame));
            TempT=ones(size(TempY))*Frame;
            Temp_Location_Coords=horzcat(TempY,TempX);
            Temp_Location_Coords=horzcat(Temp_Location_Coords,TempT);
            OQA_All_Location_Coords=vertcat(OQA_All_Location_Coords,Temp_Location_Coords);
            clear Temp_Location_Coords TempX TempY TempT
        end
        fprintf('FINISHED!\n')
        fprintf('Calculating Traditional Quantal Maps Sizes...\n')
        if size(ImageArray_Max_Sharp,1)~=size(AllBoutonsRegion,1)||...
            size(ImageArray_Max_Sharp,2)~=size(AllBoutonsRegion,2)
            error('Size mismatch between ImageArray and AllBoutonsRegion!')
        end
        OQA_ImageHeight=size(ImageArray_Max_Sharp,1);
        OQA_ImageWidth=size(ImageArray_Max_Sharp,2);
        OQA_UpScaleFactor=1;
        clear ImageArray_HighFreq_Max_Sharp ImageArray_Max_Sharp
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif exist([StackSaveName,StackSaveNameSuffix,'_First.mat'])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Looks like a low frequency evoked experiment...')
        ExpType='Evoked';
        try
            fprintf(['Loading OQA Data from: ',StackSaveName,StackSaveNameSuffix,'_Results1.mat...\n'])
            load([StackSaveName,StackSaveNameSuffix,'_Results1.mat'],'ImageArray_Max_Sharp')
            load([StackSaveName,StackSaveNameSuffix,'_First.mat'],'AllBoutonsRegion','Crop_Props')
            
            if ~exist('AllBoutonsRegion')
                warning('Loading AllBoutonsRegion from alternative file...')
                load([StackSaveName,StackSaveNameSuffix,'_GFPs_1.mat'],'AllBoutonsRegion','Crop_Props')
                if ~exist('AllBoutonsRegion')
                    error('Missing AllBoutonsRegion!')
                end
                if size(ImageArray_Max_Sharp,1)~=size(AllBoutonsRegion,1)||...
                    size(ImageArray_Max_Sharp,2)~=size(AllBoutonsRegion,2)
                    warning('Size Mistmatch! Trying to crop AllBoutonsRegion')
                    AllBoutonsRegion=imcrop(AllBoutonsRegion,Crop_Props.BoundingBox);
                end
            else
                if size(ImageArray_Max_Sharp,1)~=size(AllBoutonsRegion,1)||...
                    size(ImageArray_Max_Sharp,2)~=size(AllBoutonsRegion,2)
                    warning('Size Mistmatch! Trying to crop AllBoutonsRegion')
                    AllBoutonsRegion=imcrop(AllBoutonsRegion,Crop_Props.BoundingBox);
                end
            end
        catch
            error('Problem finding OQA...')
        end
        fprintf('Finding Traditional Quantal Coordinates...')
        progressbar('Finding Traditional Quantal Coordinates ||| Frame #')
        OQA_NumFrames=size(ImageArray_Max_Sharp,3);
        disp(['Prelim Num Events = ',sum(ImageArray_Max_Sharp(:))])
        OQA_All_Location_Coords=[];
        for Frame=1:OQA_NumFrames
            progressbar(Frame/OQA_NumFrames)
            [TempY,TempX]=find(ImageArray_Max_Sharp(:,:,Frame));
            TempT=ones(size(TempY))*Frame;
            Temp_Location_Coords=horzcat(TempY,TempX);
            Temp_Location_Coords=horzcat(Temp_Location_Coords,TempT);
            OQA_All_Location_Coords=vertcat(OQA_All_Location_Coords,Temp_Location_Coords);
            clear Temp_Location_Coords TempX TempY TempT
        end
        fprintf('FINISHED!\n')
        fprintf('Calculating Traditional Quantal Maps Sizes...\n')
        if size(ImageArray_Max_Sharp,1)~=size(AllBoutonsRegion,1)||...
            size(ImageArray_Max_Sharp,2)~=size(AllBoutonsRegion,2)
            error('Size mismatch between ImageArray and AllBoutonsRegion!')
        end
        OQA_ImageHeight=size(ImageArray_Max_Sharp,1);
        OQA_ImageWidth=size(ImageArray_Max_Sharp,2);
        OQA_UpScaleFactor=1;
        clear ImageArray_Max_Sharp
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf([num2str(size(OQA_All_Location_Coords,1)),' Traditional Quantal Event Localizations to Render\n'])
    fprintf(['From ',num2str(OQA_NumFrames),' Timepoints\n'])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['OQA Image ',num2str(OQA_UpScaleFactor),'X Upscaling Dimensions = ',...
        num2str(OQA_ImageHeight),'(H) X ',num2str(OQA_ImageWidth),'(W)'])
    OQA_ZerosImage=zeros(OQA_ImageHeight,OQA_ImageWidth);
    OQA_ZerosImage_Color=zeros(OQA_ImageHeight,OQA_ImageWidth,3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Colormap for color projection
    R = linspace(0,1,OQA_NumFrames);
    B = linspace(1,0,OQA_NumFrames);
    G = zeros(size(R));
    OQA_Temporal_Colormap=( [R(:), G(:), B(:)] );
    clear R B G
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Colormap for versus
    OQA_Colormap=makeColorMap([0 0 0],ColorDefinitions(OQA_Overlay_Color),2^16);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Calculating OQA Event Filtering Parameters...\n')
    if isempty(OQA_Gaussian_Filter_Sizes)
        OQA_Gaussian_Filter_Sizes=zeros(size(OQA_Gaussian_Filter_Sigmas));
        for z=1:length(OQA_Gaussian_Filter_Sigmas)
            if OQA_Gaussian_Filter_Sigmas(z)~=0
                OQA_Gaussian_Filter_Sizes(z)=2*ceil(OQA_Gaussian_Filter_Sigmas(z)*2)+OQA_Gaussian_Filter_SizeBuffer;
            end
        end
    end
    for z=1:length(OQA_Gaussian_Filter_Sigmas)
        disp(['Event Gaussian Filter SIZE = ',num2str(OQA_Gaussian_Filter_Sizes(z)),' SIGMA = ',num2str(OQA_Gaussian_Filter_Sigmas(z))])
        OQA_HighRes_Maps(z).GaussianParticleSize=OQA_Gaussian_Filter_Sizes(z);
        OQA_HighRes_Maps(z).GaussianParticleSigma=OQA_Gaussian_Filter_Sigmas(z);
        TestImage=zeros(max(OQA_Gaussian_Filter_Sizes));
        TestImage(ceil(max(OQA_Gaussian_Filter_Sizes)/2),ceil(max(OQA_Gaussian_Filter_Sizes)/2))=1;
        if OQA_Gaussian_Filter_Sigmas(z)~=0
            TestImage=imgaussfilt(double(TestImage), OQA_Gaussian_Filter_Sigmas(z),'FilterSize',OQA_Gaussian_Filter_Sizes(z));
        end
        OQA_HighRes_Maps(z).GaussianParticle_Image=TestImage;        
        OQA_HighRes_Maps(z).OQA_Image=double(OQA_ZerosImage);
        if OQA_TemporalColorizations(z)
            OQA_HighRes_Maps(z).OQA_Image_TemporalColors=double(OQA_ZerosImage_Color);
        else
            OQA_HighRes_Maps(z).OQA_Image_TemporalColors=[];
        end
    end
    figure('name','OQA Filters')
    for z=1:length(OQA_Gaussian_Filter_Sigmas)
        subplot(3,3,z)
        imagesc(OQA_HighRes_Maps(z).GaussianParticle_Image)
        axis equal tight,title(['SIZE = ',num2str(OQA_Gaussian_Filter_Sizes(z)),' SIGMA = ',num2str(OQA_Gaussian_Filter_Sigmas(z))])
    end
    export_fig( [SaveDir,dc, 'OQA Filters', '.eps'], '-eps','-tif','-nocrop','-transparent');        
    pause(2)
    close all
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('======================================')
    fprintf('Making OQA Maps...\n')
    for z=1:length(OQA_Gaussian_Filter_Sigmas)
        disp(['Making OQA Map #',num2str(z),' for Gaussian Filter SIZE = ',num2str(OQA_Gaussian_Filter_Sizes(z)),' SIGMA = ',num2str(OQA_Gaussian_Filter_Sigmas(z))])

        OQA_Gaussian_Filter_Size=OQA_Gaussian_Filter_Sizes(z);
        OQA_Gaussian_Filter_Sigma=OQA_Gaussian_Filter_Sigmas(z);
        OQA_TemporalColorization=OQA_TemporalColorizations(z);
        
        [OQA_HighRes_Maps(z).OQA_Image,OQA_HighRes_Maps(z).OQA_Image_TemporalColors,myPool]=QuaSOR_Map_Maker(myPool,GPU_Accelerate,OQA_UpScaleFactor,OQA_ImageHeight,OQA_ImageWidth,...
            OQA_All_Location_Coords,OQA_Gaussian_Filter_Size,OQA_Gaussian_Filter_Sigma,...
            SpotNormalization,OQA_TemporalColorization,OQA_Temporal_Colormap,0);

        disp('==================')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    disp('=======================================================================')
    disp('QuaSOR Map Processing...')
    if IbIs
        if exist([StackSaveName,StackSaveNameSuffix,'_IbIs_Merged_Data2.mat'])
            fprintf(['Loading SOQA/QuaSOR Data from: ',StackSaveName,StackSaveNameSuffix,'_IbIs_Merged_Data2.mat...\n'])
            try
                warning off
                load([StackSaveName,StackSaveNameSuffix,'_IbIs_Merged_Data2.mat'],'UpScaleRatio','ScaleBar_Upscale',...
                    'All_Location_Coords_Ib','All_ReMapped_IbIs_Location_Coords_Ib','All_ReMapped_IbIs_Location_Coords_Ib_Reg',...
                    'All_Location_Coords_Is','All_ReMapped_IbIs_Location_Coords_Is','All_ReMapped_IbIs_Location_Coords_Is_Reg',...
                    'AllBoutonsRegion_Upscale_Ib_Crop','AllBoutonsRegion_Upscale_Is_Crop',...
                    'NEW_Crop_Props_Upscale')
                warning on

                if IbIs_CoordinateAdjust~=0
                    warning('Fixing QuaSOR Coordinates to Remove Coordinate Adjust')
                    warning('Fixing QuaSOR Coordinates to Remove Coordinate Adjust')
                    warning('Fixing QuaSOR Coordinates to Remove Coordinate Adjust')
                    warning('Fixing QuaSOR Coordinates to Remove Coordinate Adjust')
                    warning(['IbIs_CoordinateAdjust = ',num2str(IbIs_CoordinateAdjust)])
                    warning(['IbIs_CoordinateAdjust = ',num2str(IbIs_CoordinateAdjust)])
                    warning(['IbIs_CoordinateAdjust = ',num2str(IbIs_CoordinateAdjust)])
                    warning(['IbIs_CoordinateAdjust = ',num2str(IbIs_CoordinateAdjust)])
                    All_Location_Coords_Ib(:,1)=All_Location_Coords_Ib(:,1)+IbIs_CoordinateAdjust;
                    All_Location_Coords_Ib(:,2)=All_Location_Coords_Ib(:,2)+IbIs_CoordinateAdjust;
                    if ~isempty(All_Location_Coords_Is)
                        All_Location_Coords_Is(:,1)=All_Location_Coords_Is(:,1)+IbIs_CoordinateAdjust;
                        All_Location_Coords_Is(:,2)=All_Location_Coords_Is(:,2)+IbIs_CoordinateAdjust;
                    end
                    All_ReMapped_IbIs_Location_Coords_Ib(:,1)=All_ReMapped_IbIs_Location_Coords_Ib(:,1)+IbIs_CoordinateAdjust;
                    All_ReMapped_IbIs_Location_Coords_Ib(:,2)=All_ReMapped_IbIs_Location_Coords_Ib(:,2)+IbIs_CoordinateAdjust;
                    if ~isempty(All_Location_Coords_Is)
                        All_ReMapped_IbIs_Location_Coords_Is(:,1)=All_ReMapped_IbIs_Location_Coords_Is(:,1)+IbIs_CoordinateAdjust;
                        All_ReMapped_IbIs_Location_Coords_Is(:,2)=All_ReMapped_IbIs_Location_Coords_Is(:,2)+IbIs_CoordinateAdjust;                    
                    end   
                end

                All_ReMapped_IbIs_Location_Coords_Ib=horzcat(All_ReMapped_IbIs_Location_Coords_Ib,All_Location_Coords_Ib(:,3));
                if ~isempty(All_Location_Coords_Is)
                    All_ReMapped_IbIs_Location_Coords_Is=horzcat(All_ReMapped_IbIs_Location_Coords_Is,All_Location_Coords_Is(:,3));
                end
                UpScaleFactor=UpScaleRatio;
                QuaSOR_UpScaleFactor=UpScaleFactor;
            catch

            end
            if CheckForRegCoord
                if exist('All_ReMapped_IbIs_Location_Coords_Ib_Reg')
                    warning('Using Registered QuaSOR Coordinates!')
                    warning('Using Registered QuaSOR Coordinates!')
                    warning('Using Registered QuaSOR Coordinates!')
                    warning('Using Registered QuaSOR Coordinates!')
                    warning('Using Registered QuaSOR Coordinates!')
                    Registered_QuaSOR_Coord=1;
                    All_ReMapped_IbIs_Location_Coords_Ib_Reg=horzcat(All_ReMapped_IbIs_Location_Coords_Ib_Reg,All_Location_Coords_Ib(:,3));
                    All_ReMapped_IbIs_Location_Coords_Is_Reg=horzcat(All_ReMapped_IbIs_Location_Coords_Is_Reg,All_Location_Coords_Is(:,3));

                    QuaSOR_All_Location_Coords=cat(1,All_ReMapped_IbIs_Location_Coords_Ib_Reg,All_ReMapped_IbIs_Location_Coords_Is_Reg);
                else
                    Registered_QuaSOR_Coord=0;
                    
                    if ~isempty(All_ReMapped_IbIs_Location_Coords_Is)&&size(All_ReMapped_IbIs_Location_Coords_Ib,2)~=size(All_ReMapped_IbIs_Location_Coords_Is,2)
                        warning('Size Mismatch between All_ReMapped_IbIs_Location_Coords_Ib and All_ReMapped_IbIs_Location_Coords_Is!!!')
                        warning('Size Mismatch between All_ReMapped_IbIs_Location_Coords_Ib and All_ReMapped_IbIs_Location_Coords_Is!!!')
                        warning('Size Mismatch between All_ReMapped_IbIs_Location_Coords_Ib and All_ReMapped_IbIs_Location_Coords_Is!!!')
                        warning('Size Mismatch between All_ReMapped_IbIs_Location_Coords_Ib and All_ReMapped_IbIs_Location_Coords_Is!!!')
                        warning('Size Mismatch between All_ReMapped_IbIs_Location_Coords_Ib and All_ReMapped_IbIs_Location_Coords_Is!!!')
                        QuaSOR_All_Location_Coords=cat(1,All_ReMapped_IbIs_Location_Coords_Ib(:,1:2),All_ReMapped_IbIs_Location_Coords_Is(:,1:2));
                    elseif isempty(All_ReMapped_IbIs_Location_Coords_Is)&&size(All_ReMapped_IbIs_Location_Coords_Ib,2)~=size(All_ReMapped_IbIs_Location_Coords_Is,2)
                        QuaSOR_All_Location_Coords=All_ReMapped_IbIs_Location_Coords_Ib;
                    else
                        QuaSOR_All_Location_Coords=cat(1,All_ReMapped_IbIs_Location_Coords_Ib,All_ReMapped_IbIs_Location_Coords_Is);
                    end
                end
            else
                Registered_QuaSOR_Coord=0;
                if exist('All_ReMapped_IbIs_Location_Coords_Ib')
                    QuaSOR_All_Location_Coords=cat(1,All_ReMapped_IbIs_Location_Coords_Ib,All_ReMapped_IbIs_Location_Coords_Is);
                else
                    QuaSOR_All_Location_Coords=[];
                end
            end
            clear All_Location_Coords_Ib All_Location_Coords_Is All_ReMapped_IbIs_Location_Coords_Ib All_ReMapped_IbIs_Location_Coords_Is All_ReMapped_IbIs_Location_Coords_Ib_Reg All_ReMapped_IbIs_Location_Coords_Is_Reg
        else
            error('No SOQA_Data2!')
        end
    else
        if exist([StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat'])
            fprintf(['Loading SOQA/QuaSOR Data from: ',StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat...\n'])
            try
                load([StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat'],...
                    'All_Location_Coords','All_Location_Coords_Reg','UpScaleRatio','OneImage_WithStim_SOQA_Upscale_Sharp_Prob','OneImage_NoStim_SOQA_Upscale_Sharp_Prob','OneImage_HighFreq_SOQA_Upscale_Sharp_Prob')
            catch

            end
            if CheckForRegCoord
                if exist('All_Location_Coords_Reg')
                    warning('Using Registered QuaSOR Coordinates!')
                    warning('Using Registered QuaSOR Coordinates!')
                    warning('Using Registered QuaSOR Coordinates!')
                    warning('Using Registered QuaSOR Coordinates!')
                    warning('Using Registered QuaSOR Coordinates!')
                    Registered_QuaSOR_Coord=1;
                    QuaSOR_All_Location_Coords=All_Location_Coords_Reg;
                    QuaSOR_All_Location_Coords(:,3)=All_Location_Coords(:,3);
                else
                    Registered_QuaSOR_Coord=0;
                    QuaSOR_All_Location_Coords=All_Location_Coords;
                end
            else
                Registered_QuaSOR_Coord=0;
                if exist('All_Location_Coords')
                    QuaSOR_All_Location_Coords=All_Location_Coords;
                else
                    QuaSOR_All_Location_Coords=[];
                end
            end
            clear All_Location_Coords All_Location_Coords_Reg
        else
            error('No SOQA_Data2!')
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf([num2str(size(QuaSOR_All_Location_Coords,1)),' QuaSOR Event Localizations to Render\n'])
    
    disp('=====================================================================')
    disp('=====================================================================')
    disp('=====================================================================')
    disp('=====================================================================')
    warning('Checking For Duplicate Coordinates! NEEDS FIXING')
    [   DuplicateCoords,...
        DuplicateIndices,...
        DuplicateCount]=...
        DuplicateFinder(QuaSOR_All_Location_Coords);
    if DuplicateCount>0
       warning(['QuaSOR_All_Location_Coords has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_All_Location_Coords,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_All_Location_Coords has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_All_Location_Coords,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_All_Location_Coords has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_All_Location_Coords,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_All_Location_Coords has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_All_Location_Coords,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_All_Location_Coords has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_All_Location_Coords,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_All_Location_Coords has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_All_Location_Coords,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_All_Location_Coords has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_All_Location_Coords,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_All_Location_Coords has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_All_Location_Coords,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_All_Location_Coords has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_All_Location_Coords,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_All_Location_Coords has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_All_Location_Coords,1)),' Duplicate QuaSOR Coordinates!']) 
       if RemoveDuplicates
           
       end
       
       
    end
    disp('=====================================================================')
    disp('=====================================================================')
    disp('=====================================================================')
    disp('=====================================================================')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    
    if size(QuaSOR_All_Location_Coords,1)>1
        QuaSOR_NumFrames=max(QuaSOR_All_Location_Coords(:,3));
    else
        QuaSOR_NumFrames=0;
    end
    fprintf(['From ',num2str(QuaSOR_NumFrames),' Timepoints\n'])
    fprintf('Calculating QuaSOR Maps Sizes...\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if IbIs
        QuaSOR_ImageHeight=size(imresize(AllBoutonsRegion_Ib_Crop,QuaSOR_UpScaleFactor,'nearest'),1);
        QuaSOR_ImageWidth=size(imresize(AllBoutonsRegion_Ib_Crop,QuaSOR_UpScaleFactor,'nearest'),2);
    else
        if exist('OneImage_WithStim_SOQA_Upscale_Sharp_Prob')
            QuaSOR_ImageHeight=size(OneImage_WithStim_SOQA_Upscale_Sharp_Prob,1);
            QuaSOR_ImageWidth=size(OneImage_WithStim_SOQA_Upscale_Sharp_Prob,2);
        elseif exist('OneImage_NoStim_SOQA_Upscale_Sharp_Prob')
            QuaSOR_ImageHeight=size(OneImage_NoStim_SOQA_Upscale_Sharp_Prob,1);
            QuaSOR_ImageWidth=size(OneImage_NoStim_SOQA_Upscale_Sharp_Prob,2);
        elseif exist('OneImage_HighFreq_SOQA_Upscale_Sharp_Prob')
            QuaSOR_ImageHeight=size(OneImage_HighFreq_SOQA_Upscale_Sharp_Prob,1);
            QuaSOR_ImageWidth=size(OneImage_HighFreq_SOQA_Upscale_Sharp_Prob,2);
        else
            error('No OneImage_?????_SOQA_Upscale_Sharp_Prob Map Available...')
        end
    end
    QuaSOR_UpScaleFactor=UpScaleRatio;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['QuaSOR Image ',num2str(QuaSOR_UpScaleFactor),'X Upscaling Dimensions = ',...
        num2str(QuaSOR_ImageHeight),'(H) X ',num2str(QuaSOR_ImageWidth),'(W)'])
    QuaSOR_ZerosImage=zeros(QuaSOR_ImageHeight,QuaSOR_ImageWidth);
    QuaSOR_ZerosImage_Color=zeros(QuaSOR_ImageHeight,QuaSOR_ImageWidth,3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Colormap for color projection
    R = linspace(0,1,QuaSOR_NumFrames);
    B = linspace(1,0,QuaSOR_NumFrames);
    G = zeros(size(R));
    QuaSOR_Temporal_Colormap=( [R(:), G(:), B(:)] );
    clear R B G
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Colormap for versus
    QuaSOR_Colormap=makeColorMap([0 0 0],ColorDefinitions(QuaSOR_Overlay_Color),2^16);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Calculating QuaSOR Event Filtering Parameters...\n')
    if isempty(QuaSOR_Gaussian_Filter_Sizes)
        QuaSOR_Gaussian_Filter_Sizes=zeros(size(QuaSOR_Gaussian_Filter_Sigmas));
        for z=1:length(QuaSOR_Gaussian_Filter_Sigmas)
            if QuaSOR_Gaussian_Filter_Sigmas(z)~=0
                QuaSOR_Gaussian_Filter_Sizes(z)=2*ceil(QuaSOR_Gaussian_Filter_Sigmas(z)*2)+QuaSOR_Gaussian_Filter_SizeBuffer;
            end
        end
    end
    for z=1:length(QuaSOR_Gaussian_Filter_Sigmas)
        disp(['Event Gaussian Filter SIZE = ',num2str(QuaSOR_Gaussian_Filter_Sizes(z)),' SIGMA = ',num2str(QuaSOR_Gaussian_Filter_Sigmas(z))])
        QuaSOR_HighRes_Maps(z).GaussianParticleSize=QuaSOR_Gaussian_Filter_Sizes(z);
        QuaSOR_HighRes_Maps(z).GaussianParticleSigma=QuaSOR_Gaussian_Filter_Sigmas(z);
        TestImage=zeros(max(QuaSOR_Gaussian_Filter_Sizes));
        TestImage(ceil(max(QuaSOR_Gaussian_Filter_Sizes)/2),ceil(max(QuaSOR_Gaussian_Filter_Sizes)/2))=1;
        if QuaSOR_Gaussian_Filter_Sigmas(z)~=0
            TestImage=imgaussfilt(double(TestImage), QuaSOR_Gaussian_Filter_Sigmas(z),'FilterSize',QuaSOR_Gaussian_Filter_Sizes(z));
        end
        QuaSOR_HighRes_Maps(z).GaussianParticle_Image=TestImage;        
        QuaSOR_HighRes_Maps(z).QuaSOR_Image=double(QuaSOR_ZerosImage);
        QuaSOR_HighRes_Maps(z).QuaSOR_Image_TemporalColors=double(QuaSOR_ZerosImage_Color);
        if QuaSOR_TemporalColorizations(z)
            QuaSOR_HighRes_Maps(z).QuaSOR_Image_TemporalColors=double(QuaSOR_ZerosImage_Color);
        else
            QuaSOR_HighRes_Maps(z).QuaSOR_Image_TemporalColors=[];
        end
    end
    figure('name','QuaSOR Filters')
    for z=1:length(QuaSOR_Gaussian_Filter_Sigmas)
        subplot(3,3,z)
        imagesc(QuaSOR_HighRes_Maps(z).GaussianParticle_Image)
        axis equal tight,title(['SIZE = ',num2str(QuaSOR_Gaussian_Filter_Sizes(z)),' SIGMA = ',num2str(QuaSOR_Gaussian_Filter_Sigmas(z))])
    end
    export_fig( [SaveDir,dc, 'QuaSOR Filters', '.eps'], '-eps','-tif','-nocrop','-transparent');        
    pause(2)
    close all
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('======================================')
    fprintf('Making QuaSOR Maps...\n')
    if size(QuaSOR_All_Location_Coords,1)>1
        for z=1:length(QuaSOR_Gaussian_Filter_Sigmas)
            disp('======================================')
            disp(['Making QuaSOR Map #',num2str(z),' for Gaussian Filter SIZE = ',num2str(QuaSOR_Gaussian_Filter_Sizes(z)),' SIGMA = ',num2str(QuaSOR_Gaussian_Filter_Sigmas(z))])

            QuaSOR_Gaussian_Filter_Size=QuaSOR_Gaussian_Filter_Sizes(z);
            QuaSOR_Gaussian_Filter_Sigma=QuaSOR_Gaussian_Filter_Sigmas(z);
            QuaSOR_TemporalColorization=QuaSOR_TemporalColorizations(z);
            Repeats=0;
            if GPU_Accelerate
                try
                    [QuaSOR_HighRes_Maps(z).QuaSOR_Image,QuaSOR_HighRes_Maps(z).QuaSOR_Image_TemporalColors,myPool]=QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_UpScaleFactor,QuaSOR_ImageHeight,QuaSOR_ImageWidth,...
                        QuaSOR_All_Location_Coords,QuaSOR_Gaussian_Filter_Size,QuaSOR_Gaussian_Filter_Sigma,...
                        SpotNormalization,QuaSOR_TemporalColorization,QuaSOR_Temporal_Colormap,0);
                catch
                    warning('GPU Accelerated QuaSOR_Map_Maker Crashed, Sometimes this can be resolved with a restart so trying again in 60s')
                    pause(60)
                    try
                        [QuaSOR_HighRes_Maps(z).QuaSOR_Image,QuaSOR_HighRes_Maps(z).QuaSOR_Image_TemporalColors,myPool]=QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_UpScaleFactor,QuaSOR_ImageHeight,QuaSOR_ImageWidth,...
                            QuaSOR_All_Location_Coords,QuaSOR_Gaussian_Filter_Size,QuaSOR_Gaussian_Filter_Sigma,...
                            SpotNormalization,QuaSOR_TemporalColorization,QuaSOR_Temporal_Colormap,0);
                    catch
                        warning('GPU Accelerated QuaSOR_Map_Maker Crashed Again Trying ONE More Time Without GPU')
                        try
                            [QuaSOR_HighRes_Maps(z).QuaSOR_Image,QuaSOR_HighRes_Maps(z).QuaSOR_Image_TemporalColors,myPool]=QuaSOR_Map_Maker(myPool,0,QuaSOR_UpScaleFactor,QuaSOR_ImageHeight,QuaSOR_ImageWidth,...
                                QuaSOR_All_Location_Coords,QuaSOR_Gaussian_Filter_Size,QuaSOR_Gaussian_Filter_Sigma,...
                                SpotNormalization,QuaSOR_TemporalColorization,QuaSOR_Temporal_Colormap,0);
                        catch
                            error('I give up! Exiting....')
                        end
                    end
                end
            else
                [QuaSOR_HighRes_Maps(z).QuaSOR_Image,QuaSOR_HighRes_Maps(z).QuaSOR_Image_TemporalColors,myPool]=QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_UpScaleFactor,QuaSOR_ImageHeight,QuaSOR_ImageWidth,...
                    QuaSOR_All_Location_Coords,QuaSOR_Gaussian_Filter_Size,QuaSOR_Gaussian_Filter_Sigma,...
                    SpotNormalization,QuaSOR_TemporalColorization,QuaSOR_Temporal_Colormap,0);
            end
            if GPU_Accelerate
                try
                    warning('Resetting GPU...')
                    GPU_Device=gpuDevice;
                    GPU_Accelerate=true;
                    disp(['GPU Processing using the ',GPU_Device.Name,' is ENGAGED!'])
                    disp(['GPU: ',num2str(round(GPU_Device.AvailableMemory/1e9*100)/100),'/',...
                        num2str(round(GPU_Device.TotalMemory/1e9*100)/100),' GB Memory | ',...
                        num2str(GPU_Device.MultiprocessorCount),' Processors | ',...
                        num2str(GPU_Device.MaxThreadsPerBlock),' Threads/Block'])
                        if GPU_Device.TotalMemory<GPU_Memory_Miniumum
                            warning('Total GPU memory may be too small so turning off GPU Acceleration!')
                            GPU_Accelerate=false;
                        end

                catch
                    warning('NO GPU WITH CUDA AVAILABlE!!')
                    GPU_Device=[];
                    GPU_Accelerate=false;
                end
            end
        end
    else
        warning on
        warning('No events to render!')
        warning('No events to render!')
        warning('No events to render!')
        warning('No events to render!')
        warning('No events to render!')
        for z=1:length(QuaSOR_Gaussian_Filter_Sigmas)

            QuaSOR_Gaussian_Filter_Size=QuaSOR_Gaussian_Filter_Sizes(z);
            QuaSOR_Gaussian_Filter_Sigma=QuaSOR_Gaussian_Filter_Sigmas(z);
            QuaSOR_TemporalColorization=QuaSOR_TemporalColorizations(z);
            QuaSOR_HighRes_Maps(z).QuaSOR_Image=QuaSOR_ZerosImage;
            QuaSOR_HighRes_Maps(z).QuaSOR_Image_TemporalColors=[];

        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    disp('=======================================================================')
    close all
    if DisplayIntermediates
        disp('Displaying Results...')
        DisplayMaxSaturation=0.5;
        for z=1:length(OQA_Gaussian_Filter_Sigmas)
            figure, imagesc(OQA_HighRes_Maps(z).OQA_Image)
            axis equal tight, caxis([0,max(OQA_HighRes_Maps(z).OQA_Image(:))*DisplayMaxSaturation]);
            colorbar;
            title(['OQA | Filter SIZE = ',num2str(OQA_Gaussian_Filter_Sizes(z)),...
                ' SIGMA = ',num2str(OQA_Gaussian_Filter_Sigmas(z))])
        end
        for z=1:length(QuaSOR_Gaussian_Filter_Sigmas)
            figure, imagesc(QuaSOR_HighRes_Maps(z).QuaSOR_Image)
            axis equal tight, caxis([0,max(QuaSOR_HighRes_Maps(z).QuaSOR_Image(:))*DisplayMaxSaturation])
            colorbar;
            title(['QuaSOR | Filter SIZE = ',num2str(QuaSOR_Gaussian_Filter_Sizes(z)),...
                ' SIGMA = ',num2str(QuaSOR_Gaussian_Filter_Sigmas(z))])
        end
        pause(5)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    disp('======================================')
    disp('Fixing Bouton Border Lines...')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    QuaSOR_HighResBoutonDilateRegion=strel('disk',15);
    QuaSOR_HighResBoutonDilateRegion2=strel('disk',5);
    QuaSOR_HighResBoutonErodeRegion=strel('disk',15);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if IbIs
        load([StackSaveName,StackSaveNameSuffix,'_IbIs_Merged_Data.mat'],...
            'BorderColor_Ib','BorderColor_Is')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Remaking Ib OQA Borders...')
        OQA_Ib_Bouton_Mask_BorderLine=[];
        [B,L] = bwboundaries(AllBoutonsRegion_Ib_Crop,'noholes');
        count=0;
        LineCount=1;
        for j=1:length(B)
            for k = 1:length(B{j})
                if B{j}(k,1)~=1&&B{j}(k,2)~=1&&B{j}(k,1)~=size(AllBoutonsRegion_Ib_Crop,1)&&B{j}(k,2)~=size(AllBoutonsRegion_Ib_Crop,2)
                    count=count+1;
                    OQA_Ib_Bouton_Mask_BorderLine{LineCount}.BorderLine(count,:) = B{j}(k,:);
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Remaking Is OQA Borders...')
        OQA_Is_Bouton_Mask_BorderLine=[];
        [B,L] = bwboundaries(AllBoutonsRegion_Is_Crop,'noholes');
        count=0;
        LineCount=1;
        for j=1:length(B)
            for k = 1:length(B{j})
                if B{j}(k,1)~=1&&B{j}(k,2)~=1&&B{j}(k,1)~=size(AllBoutonsRegion_Is_Crop,1)&&B{j}(k,2)~=size(AllBoutonsRegion_Is_Crop,2)
                    count=count+1;
                    OQA_Is_Bouton_Mask_BorderLine{LineCount}.BorderLine(count,:) = B{j}(k,:);
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure,
        imshow(AllBoutonsRegion_IbIs_Crop,[])
        hold on;         
        for j=1:length(OQA_Ib_Bouton_Mask_BorderLine)
            plot(OQA_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                OQA_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Ib,'linewidth',1)
        end
        for j=1:length(OQA_Is_Bouton_Mask_BorderLine)
            plot(OQA_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                OQA_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Is,'linewidth',1)
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Fixing High Res QuaSOR Ib Bouton Borders...')
        disp('Upscaling Bouton Borders...')
        QuaSOR_Ib_Bouton_Mask=imresize(AllBoutonsRegion_Ib_Crop,QuaSOR_UpScaleFactor,'nearest');
        QuaSOR_Ib_Bouton_Mask(QuaSOR_Ib_Bouton_Mask<0)=0;
        QuaSOR_Ib_Bouton_Mask(QuaSOR_Ib_Bouton_Mask>0)=1;
        QuaSOR_Ib_Bouton_Mask=logical(QuaSOR_Ib_Bouton_Mask);
        disp('Dilating...')
        QuaSOR_Ib_Bouton_Mask=imdilate(QuaSOR_Ib_Bouton_Mask,QuaSOR_HighResBoutonDilateRegion);
        QuaSOR_Ib_Bouton_Mask=imdilate(QuaSOR_Ib_Bouton_Mask,QuaSOR_HighResBoutonDilateRegion2);
        disp('Eroding...')
        QuaSOR_Ib_Bouton_Mask=imerode(QuaSOR_Ib_Bouton_Mask,QuaSOR_HighResBoutonErodeRegion);
        QuaSOR_Ib_Bouton_Mask_BorderLine=[];
        [B,L] = bwboundaries(QuaSOR_Ib_Bouton_Mask,'noholes');
        count=0;
        LineCount=1;
        for j=1:length(B)
            for k = 1:length(B{j})
                if B{j}(k,1)~=1&&B{j}(k,2)~=1&&B{j}(k,1)~=size(QuaSOR_Ib_Bouton_Mask,1)&&B{j}(k,2)~=size(QuaSOR_Ib_Bouton_Mask,2)
                    count=count+1;
                    QuaSOR_Ib_Bouton_Mask_BorderLine{LineCount}.BorderLine(count,:) = B{j}(k,:);
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Fixing High Res QuaSOR Is Bouton Borders...')
        disp('Upscaling Bouton Borders...')
        QuaSOR_Is_Bouton_Mask=imresize(AllBoutonsRegion_Is_Crop,QuaSOR_UpScaleFactor,'nearest');
        QuaSOR_Is_Bouton_Mask(QuaSOR_Is_Bouton_Mask<0)=0;
        QuaSOR_Is_Bouton_Mask(QuaSOR_Is_Bouton_Mask>0)=1;
        QuaSOR_Is_Bouton_Mask=logical(QuaSOR_Is_Bouton_Mask);
        disp('Dilating...')
        QuaSOR_Is_Bouton_Mask=imdilate(QuaSOR_Is_Bouton_Mask,QuaSOR_HighResBoutonDilateRegion);
        QuaSOR_Is_Bouton_Mask=imdilate(QuaSOR_Is_Bouton_Mask,QuaSOR_HighResBoutonDilateRegion2);
        disp('Eroding...')
        QuaSOR_Is_Bouton_Mask=imerode(QuaSOR_Is_Bouton_Mask,QuaSOR_HighResBoutonErodeRegion);
        QuaSOR_Is_Bouton_Mask_BorderLine=[];
        [B,L] = bwboundaries(QuaSOR_Is_Bouton_Mask,'noholes');
        count=0;
        LineCount=1;
        for j=1:length(B)
            for k = 1:length(B{j})
                if B{j}(k,1)~=1&&B{j}(k,2)~=1&&B{j}(k,1)~=size(QuaSOR_Is_Bouton_Mask,1)&&B{j}(k,2)~=size(QuaSOR_Is_Bouton_Mask,2)
                    count=count+1;
                    QuaSOR_Is_Bouton_Mask_BorderLine{LineCount}.BorderLine(count,:) = B{j}(k,:);
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        QuaSOR_Bouton_Mask=logical(QuaSOR_Ib_Bouton_Mask+QuaSOR_Is_Bouton_Mask);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        warning off
        figure, 
        imshow(uint8(QuaSOR_Ib_Bouton_Mask)+uint8(imresize(AllBoutonsRegion_Ib_Crop,QuaSOR_UpScaleFactor,'nearest'))+...
            uint8(QuaSOR_Is_Bouton_Mask)+uint8(imresize(AllBoutonsRegion_Is_Crop,QuaSOR_UpScaleFactor,'nearest')),[])
        hold on;         
        for j=1:length(QuaSOR_Ib_Bouton_Mask_BorderLine)
            plot(QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Ib,'linewidth',3)
        end
        for j=1:length(QuaSOR_Is_Bouton_Mask_BorderLine)
            plot(QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Is,'linewidth',3)
        end
        warning on
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Remaking OQA Borders...')
        OQA_Bouton_Mask_BorderLine=[];
        [B,L] = bwboundaries(AllBoutonsRegion,'noholes');
        count=0;
        LineCount=1;
        for j=1:length(B)
            for k = 1:length(B{j})
                if B{j}(k,1)~=1&&B{j}(k,2)~=1&&B{j}(k,1)~=size(AllBoutonsRegion,1)&&B{j}(k,2)~=size(AllBoutonsRegion,2)
                    count=count+1;
                    OQA_Bouton_Mask_BorderLine{LineCount}.BorderLine(count,:) = B{j}(k,:);
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
        figure, 
        imshow(AllBoutonsRegion,[])
        hold on;         
        for j=1:length(OQA_Bouton_Mask_BorderLine)
            plot(OQA_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                OQA_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color','r','linewidth',1)
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Fixing High Res QuaSOR Bouton Borders...')
        disp('Upscaling Bouton Borders...')
        QuaSOR_Bouton_Mask=imresize(AllBoutonsRegion,QuaSOR_UpScaleFactor,'nearest');
        QuaSOR_Bouton_Mask(QuaSOR_Bouton_Mask<0)=0;
        QuaSOR_Bouton_Mask(QuaSOR_Bouton_Mask>0)=1;
        QuaSOR_Bouton_Mask=logical(QuaSOR_Bouton_Mask);
        disp('Dilating...')
        QuaSOR_Bouton_Mask=imdilate(QuaSOR_Bouton_Mask,QuaSOR_HighResBoutonDilateRegion);
        QuaSOR_Bouton_Mask=imdilate(QuaSOR_Bouton_Mask,QuaSOR_HighResBoutonDilateRegion2);
        disp('Eroding...')
        QuaSOR_Bouton_Mask=imerode(QuaSOR_Bouton_Mask,QuaSOR_HighResBoutonErodeRegion);
        QuaSOR_Bouton_Mask_BorderLine=[];
        [B,L] = bwboundaries(QuaSOR_Bouton_Mask,'noholes');
        count=0;
        LineCount=1;
        for j=1:length(B)
            for k = 1:length(B{j})
                if B{j}(k,1)~=1&&B{j}(k,2)~=1&&B{j}(k,1)~=size(QuaSOR_Bouton_Mask,1)&&B{j}(k,2)~=size(QuaSOR_Bouton_Mask,2)
                    count=count+1;
                    QuaSOR_Bouton_Mask_BorderLine{LineCount}.BorderLine(count,:) = B{j}(k,:);
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
        warning off
        figure, 
        imshow(uint8(QuaSOR_Bouton_Mask)+uint8(imresize(AllBoutonsRegion,QuaSOR_UpScaleFactor,'nearest')),[])
        hold on;         
        for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
            plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color','r','linewidth',3)
        end
        warning on
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('======================================')
        disp('Adjusting ScaleBar...')
        load([StackSaveName,StackSaveNameSuffix,'_ScaleBar.mat'])
        ScaleBar_Upscale=ScaleBar;
        ScaleBar_Upscale.ScaleFactor=ScaleBar_Upscale.ScaleFactor/QuaSOR_UpScaleFactor;
        ScaleBar_Upscale.XCoordinate=ScaleBar_Upscale.XCoordinate*QuaSOR_UpScaleFactor;
        ScaleBar_Upscale.YCoordinate=ScaleBar_Upscale.YCoordinate*QuaSOR_UpScaleFactor;
        ScaleBar_Upscale.XData=ScaleBar_Upscale.XData*QuaSOR_UpScaleFactor;
        ScaleBar_Upscale.YData=ScaleBar_Upscale.YData*QuaSOR_UpScaleFactor;
        ScaleBar_Upscale.PixelLength=ScaleBar_Upscale.PixelLength*QuaSOR_UpScaleFactor;
        ScaleBar_Upscale.PixelWidth=ScaleBar_Upscale.PixelWidth*QuaSOR_UpScaleFactor;
        ScaleBar_Upscale.ScaleBarMask=imresize(ScaleBar_Upscale.ScaleBarMask,QuaSOR_UpScaleFactor,'nearest');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    disp('======================================')
    fprintf('Adjusting OQA Contrast and Colors...')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    close all
    if IbIs
        AllBoutonsRegion=AllBoutonsRegion_IbIs_Crop;
        QuaSOR_Bouton_Mask=logical(QuaSOR_Ib_Bouton_Mask+QuaSOR_Is_Bouton_Mask);
    end
    progressbar('Filter','Contrast')
    for z=1:length(OQA_Gaussian_Filter_Sigmas)
        for x=1:length(ContrastEnhancements)
            progressbar(z/length(OQA_Gaussian_Filter_Sigmas),x/length(ContrastEnhancements))
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            OQA_HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement=ContrastEnhancements(x);
            if size(QuaSOR_All_Location_Coords,1)>1
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                    (ceil(max(OQA_HighRes_Maps(z).OQA_Image(:))*OQA_Color_Scalar));
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                    ceil(OQA_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*...
                    OQA_HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement);
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).Heatmap=...
                    jet(OQA_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont);
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).Colormap=...
                    makeColorMap([0 0 0],ColorDefinitions(OQA_Overlay_Color),...
                    OQA_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                TempImage=OQA_HighRes_Maps(z).OQA_Image;
                TempImage(TempImage>OQA_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont)=...
                    OQA_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).OQA_Image_Heatmap=...
                    ind2rgb(round(TempImage*OQA_Color_Scalar),OQA_HighRes_Maps(z).ContrastedOutputImages(x).Heatmap);
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).OQA_Image_Heatmap=...
                    ColorMasking(OQA_HighRes_Maps(z).ContrastedOutputImages(x).OQA_Image_Heatmap,...
                    ~AllBoutonsRegion,Bouton_Region_Mask_Background_Color);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).OQA_Image_Color=...
                    ind2rgb(round(TempImage*OQA_Color_Scalar),...
                    OQA_HighRes_Maps(z).ContrastedOutputImages(x).Colormap);
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).OQA_Image_Color=...
                    ColorMasking(OQA_HighRes_Maps(z).ContrastedOutputImages(x).OQA_Image_Color,...
                    ~AllBoutonsRegion,Bouton_Region_Mask_Background_Color);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Old method
                %OQA_HighRes_Maps(z).ContrastedOutputImages(x).OQA_Image_Color=...
                %   grs2rgb(uint16(TempImage/...
                %   OQA_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont*(2^16)),OQA_Colormap);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                clear TempImage
            else
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=0;
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=.0;
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).Heatmap=[];
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).Colormap=[];
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).OQA_Image_Heatmap=[];
                OQA_HighRes_Maps(z).ContrastedOutputImages(x).OQA_Image_Color=OQA_ZerosImage_Color;
            end
        end 
    end
    fprintf('FINISHED!\n');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('======================================')
    fprintf('Adjusting QuaSOR Contrast and Colors...')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    close all
    progressbar('Filter','Contrast')
    for z=1:length(QuaSOR_Gaussian_Filter_Sigmas)
        for x=1:length(ContrastEnhancements)
            progressbar(z/length(QuaSOR_Gaussian_Filter_Sigmas),x/length(ContrastEnhancements))
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement=ContrastEnhancements(x);
            if size(QuaSOR_All_Location_Coords,1)>1
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                    (ceil(max(QuaSOR_HighRes_Maps(z).QuaSOR_Image(:))*QuaSOR_Color_Scalar));
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                    ceil(QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*...
                    QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement);
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).Heatmap=...
                    jet(QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont);
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).Colormap=...
                    makeColorMap([0 0 0],ColorDefinitions(QuaSOR_Overlay_Color),...
                    QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                TempImage=QuaSOR_HighRes_Maps(z).QuaSOR_Image;
                TempImage(TempImage>QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont)=...
                    QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap=...
                    ind2rgb(round(TempImage*QuaSOR_Color_Scalar),QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).Heatmap);
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap=...
                    ColorMasking(QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap,...
                    ~QuaSOR_Bouton_Mask,Bouton_Region_Mask_Background_Color);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color=...
                    ind2rgb(round(TempImage*QuaSOR_Color_Scalar),...
                    QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).Colormap);
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color=...
                    ColorMasking(QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color,...
                    ~QuaSOR_Bouton_Mask,Bouton_Region_Mask_Background_Color);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Old method
                %QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color=...
                %   grs2rgb(uint16(TempImage/...
                %   QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont*(2^16)),QuaSOR_Colormap);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                clear TempImage
            else
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=0;
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=0;
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).Heatmap=[];
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).Colormap=[];
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap=[];
                QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color=QuaSOR_ZerosImage_Color;
            end
        end 
    end
    fprintf('FINISHED!\n');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    disp('======================================')
    fprintf('Making OQA vs QuaSOR Images...')
    OQA_Upscale_Mask=logical(imresize(AllBoutonsRegion,...
                QuaSOR_UpScaleFactor,'nearest'));
    MaskDiff=single(OQA_Upscale_Mask)+single(QuaSOR_Bouton_Mask);
    MaskDiff(MaskDiff>1)=0;
    MaskDiff(MaskDiff==1)=1;
    MaskDiff=logical(MaskDiff);
    
    if size(QuaSOR_All_Location_Coords,1)>1
    
        OQA_Resize_Image_HeatMap=imresize(OQA_HighRes_Maps(OQA_Overlay_FilterIndex).ContrastedOutputImages(OQA_Overlay_ContrastIndex).OQA_Image_Heatmap,...
            QuaSOR_UpScaleFactor,'nearest');    
        OQA_Resize_Image_Color=imresize(OQA_HighRes_Maps(OQA_Overlay_FilterIndex).ContrastedOutputImages(OQA_Overlay_ContrastIndex).OQA_Image_Color,...
            QuaSOR_UpScaleFactor,'nearest');

        QuaSOR_vs_OQA_Image=OQA_Resize_Image_Color+...
            QuaSOR_HighRes_Maps(QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Color;
        QuaSOR_vs_OQA_Image=ColorMasking(QuaSOR_vs_OQA_Image,...
                    MaskDiff,[0,0,0]);
        QuaSOR_vs_OQA_Image=ColorMasking(QuaSOR_vs_OQA_Image,...
                    ~QuaSOR_Bouton_Mask,Bouton_Region_Mask_Background_Color);

        QuaSOR_vs_OQA_Image_WithHeatMaps=OQA_Resize_Image_HeatMap;
        QuaSOR_vs_OQA_Image_WithHeatMaps=vertcat(QuaSOR_vs_OQA_Image_WithHeatMaps,...
            QuaSOR_HighRes_Maps(QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Heatmap);
        QuaSOR_vs_OQA_Image_WithHeatMaps=vertcat(QuaSOR_vs_OQA_Image_WithHeatMaps,QuaSOR_vs_OQA_Image);

        QuaSOR_vs_OQA_Image_WithColors=OQA_Resize_Image_Color;
        QuaSOR_vs_OQA_Image_WithColors=vertcat(QuaSOR_vs_OQA_Image_WithColors,...
            QuaSOR_HighRes_Maps(QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Color);
        QuaSOR_vs_OQA_Image_WithColors=vertcat(QuaSOR_vs_OQA_Image_WithColors,QuaSOR_vs_OQA_Image);

        fprintf('FINISHED!\n')
    else
        OQA_Resize_Image_HeatMap=QuaSOR_ZerosImage_Color;
        OQA_Resize_Image_Color=QuaSOR_ZerosImage_Color;
        QuaSOR_vs_OQA_Image=QuaSOR_ZerosImage_Color;
        QuaSOR_vs_OQA_Image_WithHeatMaps=QuaSOR_ZerosImage_Color;
        QuaSOR_vs_OQA_Image_WithColors=QuaSOR_ZerosImage_Color;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    disp('======================================')
    fprintf('Saving Data...')
    close all
    save([StackSaveName,StackSaveNameSuffix,'_QuaSOR_Data.mat'],'-regexp','^(?!(LastRecording|ID_Suffix|Suffix_Ib|Suffix_Is|LoopCount|File2Check|AnalysisLabelFunction|BufferSize|Port|TimeOut|NumLoops|ServerIP|BadConnection|ConnectionAttempts|OverwriteData|AllRecordingStatuses|ServerIP|currentFolder|TemplateDir|ScratchDir|ParentDir1|ParentDir|Recording|dc|SaveDir)$).')
    fprintf('FINISHED!\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    if ExportImages
        disp('======================================')
        disp('Exporting OQA Images...')
        warning off
        for z=1:length(OQA_Gaussian_Filter_Sigmas)
            SigLabel1=floor(OQA_Gaussian_Filter_Sigmas(z));
            SigLabel2=floor(OQA_Gaussian_Filter_Sigmas(z)*10)-SigLabel1*10;
            SigLabel=[num2str(SigLabel1),'_',num2str(SigLabel2)];
            for x=1:length(ContrastEnhancements)
                ContLabel1=floor(ContrastEnhancements(x));
                ContLabel2=floor(ContrastEnhancements(x)*100)-ContLabel1*100;
                ContLabel=[num2str(ContLabel1),'_',num2str(ContLabel2)];

                FigName=[ExpType,'_OQA_H_Sig',SigLabel,'Cont',ContLabel];
                fprintf(['Exporting: ',FigName,' Figures...']);

                imwrite(OQA_HighRes_Maps(z).ContrastedOutputImages(x).OQA_Image_Heatmap,[SaveDir,dc,FigName,'.tif'])

                figure('name',FigName)
                imshow(OQA_HighRes_Maps(z).ContrastedOutputImages(x).OQA_Image_Heatmap)
                hold on;
                if IbIs
                    for j=1:length(OQA_Ib_Bouton_Mask_BorderLine)
                        plot(OQA_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            OQA_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Ib,'linewidth',1)
                    end
                    for j=1:length(OQA_Is_Bouton_Mask_BorderLine)
                        plot(OQA_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            OQA_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Is,'linewidth',1)
                    end
                else
                    for j=1:length(OQA_Bouton_Mask_BorderLine)
                        plot(OQA_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            OQA_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',ExportBorderColor,'linewidth',OQA_BorderLine_Width)
                    end
                end
                plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',OQA_BorderLine_Width);
                set(gcf, 'color', 'white');
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gca,'units','normalized','position',[0,0,1,1])
                pause(1)
                set(gcf,'units','pixels','position',[ScreenSize(3)+100,ScreenSize(4)+100,...
                    round(OQA_PixelSizeScalar*OQA_ImageWidth),round(OQA_PixelSizeScalar*OQA_ImageHeight)])
                export_fig( [SaveDir,dc, FigName, ' Bord', '.eps'], '-eps','-nocrop','-transparent','-q101','-native');        

                %And just Color Image
                FigName=[ExpType,'_OQA_C_Sig',SigLabel,'Cont',ContLabel];            
                imwrite(OQA_HighRes_Maps(z).ContrastedOutputImages(x).OQA_Image_Color,[SaveDir,dc,FigName,'.tif'])

                fprintf('FINISHED!\n');
            end
            close all
        end
        warning on
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        disp('======================================')
        disp('Exporting QuaSOR Images...')
        warning off
        for z=1:length(QuaSOR_Gaussian_Filter_Sigmas)
            SigLabel1=floor(QuaSOR_Gaussian_Filter_Sigmas(z));
            SigLabel2=floor(QuaSOR_Gaussian_Filter_Sigmas(z)*10)-SigLabel1*10;
            SigLabel=[num2str(SigLabel1),'_',num2str(SigLabel2)];
            for x=1:length(ContrastEnhancements)
                ContLabel1=floor(ContrastEnhancements(x));
                ContLabel2=floor(ContrastEnhancements(x)*100)-ContLabel1*100;
                ContLabel=[num2str(ContLabel1),'_',num2str(ContLabel2)];

                FigName=[ExpType,'_QuaSOR_H_Sig',SigLabel,'Cont',ContLabel];
                fprintf(['Exporting: ',FigName,' Figures...']);

                imwrite(QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap,[SaveDir,dc,FigName,'.tif'])

                figure('name',FigName)
                imshow(QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap)
                hold on;        
                if IbIs
                    for j=1:length(QuaSOR_Ib_Bouton_Mask_BorderLine)
                        plot(QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Ib,'linewidth',3)
                    end
                    for j=1:length(QuaSOR_Is_Bouton_Mask_BorderLine)
                        plot(QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Is,'linewidth',3)
                    end
                else
                    for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
                        plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
                    end
                end
                plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',QuaSOR_BorderLine_Width);
                set(gcf, 'color', 'white');
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gca,'units','normalized','position',[0,0,1,1])
                pause(1)
                set(gcf,'units','pixels','position',[ScreenSize(3)+100,ScreenSize(4)+100,...
                    round(QuaSOR_PixelSizeScalar*QuaSOR_ImageWidth),round(QuaSOR_PixelSizeScalar*QuaSOR_ImageHeight)])
                export_fig( [SaveDir,dc, FigName, ' Bord', '.eps'], '-eps','-nocrop','-transparent','-q101','-native');        

                %And just Color Image
                FigName=[ExpType,'_QuaSOR_C_Sig',SigLabel,'Cont',ContLabel];            
                imwrite(QuaSOR_HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color,[SaveDir,dc,FigName,'.tif'])

                fprintf('FINISHED!\n');
            end
            close all
        end
        warning on
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    else
        warning on
        warning('NOT EXPORTING ALL IMAGES!')
        warning('NOT EXPORTING ALL IMAGES!')
        warning('NOT EXPORTING ALL IMAGES!')
        warning('NOT EXPORTING ALL IMAGES!')
        warning('NOT EXPORTING ALL IMAGES!')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    disp('======================================')
    disp('Exporting QuaSOR vs OQA Images...')
    if size(QuaSOR_All_Location_Coords,1)>1
        warning off
        SigLabel1=floor(QuaSOR_Gaussian_Filter_Sigmas(QuaSOR_Overlay_FilterIndex));
        SigLabel2=floor(QuaSOR_Gaussian_Filter_Sigmas(QuaSOR_Overlay_FilterIndex)*10)-SigLabel1*10;
        SigLabel=[num2str(SigLabel1),'_',num2str(SigLabel2)];
        ContLabel1=floor(ContrastEnhancements(QuaSOR_Overlay_ContrastIndex));
        ContLabel2=floor(ContrastEnhancements(QuaSOR_Overlay_ContrastIndex)*100)-ContLabel1*100;
        ContLabel=[num2str(ContLabel1),'_',num2str(ContLabel2)];
        FigName=[ExpType,'_Comp_QuaSOR_H_Sig',SigLabel,'Cont',ContLabel];
        FigName2=[ExpType,'_Comp_QuaSOR_C_Sig',SigLabel,'Cont',ContLabel];            
        FigName2a=[ExpType,'_Comp_QuaSOR_H_Sig',SigLabel,'Cont',ContLabel];            
        FigName3=[ExpType,'_Comp_QuaSOR_HC_Sig',SigLabel,'Cont',ContLabel];
        FigName3a=[ExpType,'_Comp_QuaSOR_CC_Sig',SigLabel,'Cont',ContLabel];

        SigLabel1=floor(OQA_Gaussian_Filter_Sigmas(OQA_Overlay_FilterIndex));
        SigLabel2=floor(OQA_Gaussian_Filter_Sigmas(OQA_Overlay_FilterIndex)*10)-SigLabel1*10;
        SigLabel=[num2str(SigLabel1),'_',num2str(SigLabel2)];
        ContLabel1=floor(ContrastEnhancements(OQA_Overlay_ContrastIndex));
        ContLabel2=floor(ContrastEnhancements(OQA_Overlay_ContrastIndex)*100)-ContLabel1*100;
        ContLabel=[num2str(ContLabel1),'_',num2str(ContLabel2)];
        FigName=[FigName,'_v_OQA_Sig',SigLabel,'Cont',ContLabel];
        FigName2b=[ExpType,'_Comp_OQA_C_Sig',SigLabel,'Cont',ContLabel];            
        FigName2c=[ExpType,'_Comp_OQA_H_Sig',SigLabel,'Cont',ContLabel];            
        FigName3=[FigName3,'_v_OQA_Sig',SigLabel,'Cont',ContLabel];
        FigName3a=[FigName3a,'_v_OQA_Sig',SigLabel,'Cont',ContLabel];

        fprintf(['Exporting: ',FigName,' Figures...']);
        imwrite(QuaSOR_vs_OQA_Image,[SaveDir,dc,FigName,'.tif'])

        figure('name',FigName)
        imshow(QuaSOR_vs_OQA_Image)
        hold on;         
        if IbIs
            for j=1:length(QuaSOR_Ib_Bouton_Mask_BorderLine)
                plot(QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Ib,'linewidth',3)
            end
            for j=1:length(QuaSOR_Is_Bouton_Mask_BorderLine)
                plot(QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Is,'linewidth',3)
            end
        else
            for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
                plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
            end
        end
        plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',QuaSOR_BorderLine_Width);
        set(gcf, 'color', 'white');
        set(gca,'XTick', []); set(gca,'YTick', []);
        set(gca,'units','normalized','position',[0,0,1,1])
        pause(1)
        set(gcf,'units','pixels','position',[ScreenSize(3)+100,ScreenSize(4)+100,...
            round(QuaSOR_PixelSizeScalar*QuaSOR_ImageWidth),round(QuaSOR_PixelSizeScalar*QuaSOR_ImageHeight)])
        export_fig( [SaveDir,dc, FigName, ' Bord', '.eps'], '-eps','-nocrop','-transparent','-q101','-native');        
        fprintf('FINISHED!\n');

        %And just Color Image
        fprintf(['Exporting: ',FigName2,' Figure...']);
        imwrite(QuaSOR_HighRes_Maps(QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Color,[SaveDir,dc,FigName2,'.tif'])
        fprintf('FINISHED!\n');

        fprintf(['Exporting: ',FigName2a,' Figure...']);
        imwrite(QuaSOR_HighRes_Maps(QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Heatmap,[SaveDir,dc,FigName2a,'.tif'])
        fprintf('FINISHED!\n');

        fprintf(['Exporting: ',FigName2b,' Figure...']);
        imwrite(OQA_Resize_Image_Color,[SaveDir,dc,FigName2b,'.tif'])
        fprintf('FINISHED!\n');

        fprintf(['Exporting: ',FigName2c,' Figure...']);
        imwrite(OQA_Resize_Image_HeatMap,[SaveDir,dc,FigName2c,'.tif'])
        fprintf('FINISHED!\n');

        fprintf(['Exporting: ',FigName3,' Figure...']);
        imwrite(QuaSOR_vs_OQA_Image_WithHeatMaps,[SaveDir,dc,FigName3,'.tif'])
        fprintf('FINISHED!\n');

        fprintf(['Exporting: ',FigName3a,' Figure...']);
        imwrite(QuaSOR_vs_OQA_Image_WithColors,[SaveDir,dc,FigName3a,'.tif'])
        fprintf('FINISHED!\n');


        %And Save To Pooled Dir

        fprintf(['Exporting: ',StackSaveName,StackSaveNameSuffix,'_',FigName3,' Figure...']);
        imwrite(QuaSOR_vs_OQA_Image_WithHeatMaps,...
            [PooledSaveDir,dc,StackSaveName,StackSaveNameSuffix,'_',FigName3,'.tif'])
        fprintf('FINISHED!\n');

        fprintf(['Exporting: ',StackSaveName,StackSaveNameSuffix,'_',FigName3a,' Figure...']);
        imwrite(QuaSOR_vs_OQA_Image_WithColors,...
            [PooledSaveDir,dc,StackSaveName,StackSaveNameSuffix,'_',FigName3a,'.tif'])
        fprintf('FINISHED!\n');

        figure('name',[StackSaveName,StackSaveNameSuffix,'_',FigName])
        imshow(QuaSOR_vs_OQA_Image)
        hold on;         
        if IbIs
            for j=1:length(QuaSOR_Ib_Bouton_Mask_BorderLine)
                plot(QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Ib,'linewidth',3)
            end
            for j=1:length(QuaSOR_Is_Bouton_Mask_BorderLine)
                plot(QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Is,'linewidth',3)
            end
        else
            for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
                plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
            end
        end
        plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',QuaSOR_BorderLine_Width);
        set(gcf, 'color', 'white');
        set(gca,'XTick', []); set(gca,'YTick', []);
        set(gca,'units','normalized','position',[0,0,1,1])
        pause(1)
        set(gcf,'units','pixels','position',[ScreenSize(3)+100,ScreenSize(4)+100,...
            round(QuaSOR_PixelSizeScalar*QuaSOR_ImageWidth),round(QuaSOR_PixelSizeScalar*QuaSOR_ImageHeight)])
        export_fig( [PooledSaveDir,dc,StackSaveName,StackSaveNameSuffix,'_',FigName, ' Bord', '.eps'], '-eps','-nocrop','-transparent','-q101','-native');    


        fprintf(['Exporting: ',StackSaveName,StackSaveNameSuffix,'_',FigName,' Figure...']);
        imwrite(QuaSOR_vs_OQA_Image,...
            [PooledSaveDir,dc,StackSaveName,StackSaveNameSuffix,'_',FigName,'.tif'])
        fprintf('FINISHED!\n');
    else
       warning('Not exporting any images because no events...') 
       warning('Not exporting any images because no events...') 
       warning('Not exporting any images because no events...') 
       warning('Not exporting any images because no events...') 
       warning('Not exporting any images because no events...') 
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('FINISHED Exporting Images!\n');
    OverallTime=toc(OverallTimer);
    fprintf(['Rendering and Exporting All QuaSOR Data Took: ',num2str(OverallTime/60),'min\n'])
    close all
    disp('======================================')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %Just Display Final Comp Maps
    if size(QuaSOR_All_Location_Coords,1)>1
        warning off

        figure('name',FigName)
        imshow(QuaSOR_vs_OQA_Image)
        hold on
        if IbIs
            for j=1:length(QuaSOR_Ib_Bouton_Mask_BorderLine)
                plot(QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Ib_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Ib,'linewidth',3)
            end
            for j=1:length(QuaSOR_Is_Bouton_Mask_BorderLine)
                plot(QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Is_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',BorderColor_Is,'linewidth',3)
            end
        else
            for j=1:length(QuaSOR_Bouton_Mask_BorderLine)
                plot(QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color',ExportBorderColor,'linewidth',QuaSOR_BorderLine_Width)
            end
        end
        plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',QuaSOR_BorderLine_Width);
        set(gcf, 'color', 'white');
        set(gca,'XTick', []); set(gca,'YTick', []);
        set(gca,'units','normalized','position',[0,0,1,1])

        figure('name',FigName3)
        imshow(QuaSOR_vs_OQA_Image_WithHeatMaps)
        set(gcf, 'color', 'white');
        set(gca,'XTick', []); set(gca,'YTick', []);
        set(gca,'units','normalized','position',[0,0,1,1])
        set(gcf,'units','normalized','position',[0.1,0.1,0.4,0.8])

        figure('name',FigName3a)
        imshow(QuaSOR_vs_OQA_Image_WithColors)
        set(gcf, 'color', 'white');
        set(gca,'XTick', []); set(gca,'YTick', []);
        set(gca,'units','normalized','position',[0,0,1,1])
        set(gcf,'units','normalized','position',[0.5,0.1,0.4,0.8])
        warning on    

        pause(10)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

end