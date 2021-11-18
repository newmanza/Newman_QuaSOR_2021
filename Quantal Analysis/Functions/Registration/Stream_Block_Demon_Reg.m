function [ImageArrayDemonReg_AllImages,demonDispFields]=Stream_Block_Demon_Reg(RunParallel,myPool,StackSaveName,ImageArrayDFTReg_AllImages,...
        ReferenceImage_Padded_Masked_Filtered_Enhanced,...
        AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,BorderLine_Orig,Crop_Props,...
        ImagingInfo,RegistrationSettings,RegEnhancement,DemonReg,IsDFTMoving,SaveDemonField,TempScratchSaveDir)
    %Demon registration
    jheapcl    
    close all
    fprintf(['====================================================\n'])
    fprintf('Starting Blocked Diffeomorphic Demon Registration...\n') 
    MatlabVersion=version('-release');
    Temp_MatlabVersionYear=MatlabVersion(1:4);
    TimeHandle=tic;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if SaveDemonField
        demonDispFields = cell(ImagingInfo.TotalNumFrames,1);
    else
        demonDispFields=[];
    end
    %Split Data into blocks to save memory overhead
    fprintf('Saving Temporary Files...')
    clear BlockedImageNumbers
    if ((ImagingInfo.NumEpisodes<4&&ImagingInfo.TotalNumFrames>2500)||...
            (ImagingInfo.NumEpisodes<2&&ImagingInfo.TotalNumFrames>1200))&&...
            ImagingInfo.ModalityType==2
        warning('Forcing SPONTANEOUS Imaging Block Split To make easier to run!')
        if ImagingInfo.NumEpisodes==1
            warning('One Episode present so forcing DemonReg.CarryOver_DemonField_Smoothing on to ensure good block merge')
            DemonReg.CarryOver_DemonField_Smoothing=1;
        end
        BlockSize=600;
        NumBlocks=ceil(ImagingInfo.TotalNumFrames/BlockSize);
        BlockNumber=1;
        BlockCount=0;
        for ImageNumber=1:ImagingInfo.TotalNumFrames
            if BlockCount<BlockSize
                BlockCount=BlockCount+1;
                BlockedImageNumbers(BlockNumber).ImageNumbers(BlockCount)=ImageNumber;
            else
                BlockNumber=BlockNumber+1;
                BlockCount=0;
                BlockCount=BlockCount+1;
                BlockedImageNumbers(BlockNumber).ImageNumbers(BlockCount)=ImageNumber;
            end
        end
    else
        BlockSize=ImagingInfo.FramesPerEpisode;
        NumBlocks=ImagingInfo.NumEpisodes;
        for BlockNumber=1:NumBlocks
            BlockedImageNumbers(BlockNumber).ImageNumbers=[1:BlockSize]+(BlockNumber-1)*BlockSize;
        end
    end
    for BlockNumber=1:NumBlocks
        BlockedImageNumbers(BlockNumber).BlockSize=length(BlockedImageNumbers(BlockNumber).ImageNumbers);
    end
    progressbar('Splitting Block')
    for BlockNumber=1:NumBlocks
        progressbar(BlockNumber/NumBlocks)
        ImageArrayDemonReg_AllImages_Block=ImageArrayDFTReg_AllImages(:,:,BlockedImageNumbers(BlockNumber).ImageNumbers);
        save([TempScratchSaveDir,'Temp_ImageArrayDemonReg_AllImages_Block_',num2str(BlockNumber),'.mat'],'ImageArrayDemonReg_AllImages_Block');
        clear ImageArrayDemonReg_AllImages_Block
    end
    clear ImageArrayDemonReg_AllImages BlockdemonDispFields ImageArrayDFTReg_AllImages
    fprintf('Finished!\n')
    fprintf(['====================================================\n'])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Starting DEMON Registration\n')
    if isfield(RegEnhancement,'DemonMask')
        if ~isempty(DemonReg.DemonMask)||sum(DemonReg.DemonMask(:))>0
            fprintf('NOTE: Applying a Demon Mask to Remove Off-Target Fluorescence...\n')
        end
    else
        DemonReg.DemonMask=[];
    end
    for BlockNumber=1:NumBlocks
        BlockTimer=tic;
        jheapcl
        fprintf(['Loading Data for Block #',num2str(BlockNumber),' of ',num2str(NumBlocks),'\n'])
        load([TempScratchSaveDir,'Temp_ImageArrayDemonReg_AllImages_Block_',num2str(BlockNumber),'.mat'],'ImageArrayDemonReg_AllImages_Block')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        CurrentBlockSize=BlockedImageNumbers(BlockNumber).BlockSize;
        BlockdemonDispFields = cell(CurrentBlockSize,1);
        for BlockPosition=1:BlockedImageNumbers(BlockNumber).BlockSize
            BlockdemonDispFields{BlockPosition}.dField=double(zeros(size(ReferenceImage_Padded_Masked_Filtered_Enhanced,1),size(ReferenceImage_Padded_Masked_Filtered_Enhanced,2),2));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['Calculating Demon Fields for Block #',num2str(BlockNumber),' of ',num2str(NumBlocks),' (',num2str(CurrentBlockSize),' Current Frames in this Block}...'])
        ppm = ParforProgMon([StackSaveName,' || Calculating Demon Fields for Block #',num2str(BlockNumber),' of ',num2str(NumBlocks),' (',num2str(CurrentBlockSize),' Current Frames in this Block) || '], CurrentBlockSize, 1, 1200, 80);
        if RunParallel
            parfor BlockPosition=1:CurrentBlockSize
                %disp(['Start ',num2str(BlockNumber),' ',num2str(BlockPosition)])
                ImageNumber=BlockedImageNumbers(BlockNumber).ImageNumbers(BlockPosition);
                %TempImage1=ImageArrayDemonReg_AllImages(:,:,ImageNumber);
                TempImage1=ImageArrayDemonReg_AllImages_Block(:,:,BlockPosition);

                [TempImage_Padded,TempImage_Padded_Masked_Filtered_Enhanced]=...
                    RegistrationImageEnhancement(TempImage1,AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,...
                    BorderLine_Orig,Crop_Props,DemonReg,RegEnhancement,[],[],0,0);

                %%%%%%%%%%%%%
                dField=double(zeros(size(ReferenceImage_Padded_Masked_Filtered_Enhanced,1),size(ReferenceImage_Padded_Masked_Filtered_Enhanced,2),2));
                if ~isempty(DemonReg.DemonMask)||sum(DemonReg.DemonMask(:))>0
                    Mov_Image=TempImage_Padded_Masked_Filtered_Enhanced;
                    Ref_Image=ReferenceImage_Padded_Masked_Filtered_Enhanced;
                    Mov_Image(logical(DemonReg.DemonMask))=0;
                    Ref_Image(logical(DemonReg.DemonMask))=0;
                else
                    Mov_Image=TempImage_Padded_Masked_Filtered_Enhanced;
                    Ref_Image=ReferenceImage_Padded_Masked_Filtered_Enhanced;
                end
                if BlockPosition==1
                    IterationEnhance=100;
                else
                    IterationEnhance=0;
                end
                if str2num(Temp_MatlabVersionYear)<2016
                    [dField,~] = imregdemons_ZN(Mov_Image,Ref_Image,DemonReg.Iterations+IterationEnhance,...
                        'PyramidLevels',DemonReg.PyramidLevels,'AccumulatedFieldSmoothing',DemonReg.AccumulatedFieldSmoothing);  
                else
                    [dField,~] = imregdemons(Mov_Image,Ref_Image,DemonReg.Iterations+IterationEnhance,...
                        'PyramidLevels',DemonReg.PyramidLevels,'AccumulatedFieldSmoothing',DemonReg.AccumulatedFieldSmoothing, 'DisplayWaitbar',false); 
                end
                %%%%%%%%%%%%%
                BlockdemonDispFields{BlockPosition}.dField=dField;
                %disp(['End ',num2str(BlockNumber),'-',num2str(BlockPosition)])

                ppm.increment();
            end
        else
            error('Tell Zach to Update Stream_Block_Demon_Reg.m');
        end
        fprintf(['Finished Calculating Demon Fields for Block #',num2str(BlockNumber),' of ',num2str(NumBlocks),'\n'])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if DemonReg.SmoothDemon
            if DemonReg.FastSmoothing    
                if DemonReg.CarryOver_DemonField_Smoothing&&BlockNumber>1
                    warning(['Merging Carry Over Demon Fields with Current Block Demon Fields...'])
                    BlockdemonDispFields_withCarryOver=CarryOver_BlockdemonDispFields;
                    CarryOverCount2=DemonReg.CarryOverFrames+1;
                    for l=1:length(BlockdemonDispFields)
                        BlockdemonDispFields_withCarryOver{CarryOverCount2}.dField=BlockdemonDispFields{l}.dField;
                        CarryOverCount2=CarryOverCount2+1;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    TotalSmoothingArea=DemonReg.Intermediate_Crop_Props.BoundingBox(3)*DemonReg.Intermediate_Crop_Props.BoundingBox(4);
                    VerticalPixels=DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(4);
                    HorizontalPixels=DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(3);
                    [BlockdemonDispFields_withCarryOver,myPool]=SmoothDemonField(myPool,BlockdemonDispFields_withCarryOver,DemonReg.DemonSmoothSize,0,[],0,[],...
                        DemonReg.PixelBlockSize,TotalSmoothingArea,VerticalPixels,HorizontalPixels);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    warning('Removing Carry Over Demon Fields...')
                    CarryOverCount3=1;
                    for l=DemonReg.CarryOverFrames+1:length(BlockdemonDispFields_withCarryOver)
                        BlockdemonDispFields{CarryOverCount3}.dField=BlockdemonDispFields_withCarryOver{l}.dField;
                        CarryOverCount3=CarryOverCount3+1;
                    end
                    clear CarryOver_BlockdemonDispFields BlockdemonDispFields_withCarryOver
                    warning('Temporarily Storing Carry Over Demon Fields')
                    CarryOverCount=1;
                    for l=length(BlockdemonDispFields)-DemonReg.CarryOverFrames+1:length(BlockdemonDispFields)
                        CarryOver_BlockdemonDispFields{CarryOverCount}.dField=BlockdemonDispFields{l}.dField;
                        CarryOverCount=CarryOverCount+1;
                    end
                else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    TotalSmoothingArea=DemonReg.Intermediate_Crop_Props.BoundingBox(3)*DemonReg.Intermediate_Crop_Props.BoundingBox(4);
                    VerticalPixels=DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(4);
                    HorizontalPixels=DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(3);
                    [BlockdemonDispFields,myPool]=SmoothDemonField(myPool,BlockdemonDispFields,DemonReg.DemonSmoothSize,0,[],0,[],...
                        DemonReg.PixelBlockSize,TotalSmoothingArea,VerticalPixels,HorizontalPixels);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    clear CarryOver_BlockdemonDispFields
                    if DemonReg.CarryOver_DemonField_Smoothing
                        warning('Temporarily Storing Carry Over Demon Fields')
                        CarryOverCount=1;
                        for l=length(BlockdemonDispFields)-DemonReg.CarryOverFrames+1:length(BlockdemonDispFields)
                            CarryOver_BlockdemonDispFields{CarryOverCount}.dField=BlockdemonDispFields{l}.dField;
                            CarryOverCount=CarryOverCount+1;
                        end
                    end
                end
            else
                if DemonReg.CarryOver_DemonField_Smoothing&&BlockNumber>1

                    warning(['Merging Carry Over Demon Fields with Current Block Demon Fields...'])
                    BlockdemonDispFields_withCarryOver=CarryOver_BlockdemonDispFields;
                    CarryOverCount2=DemonReg.CarryOverFrames+1;
                    for l=1:length(BlockdemonDispFields)
                        BlockdemonDispFields_withCarryOver{CarryOverCount2}.dField=BlockdemonDispFields{l}.dField;
                        CarryOverCount2=CarryOverCount2+1;
                    end

                    fprintf(['Smoothing Demon Fields...\n'])
                    %Extract all pixel traces
                    clear PixelStruct
                    progressbar('Splitting Demon Field: Pixel #')
                    PixelCount=0;
                    TotalSmoothingArea=DemonReg.Intermediate_Crop_Props.BoundingBox(3)*DemonReg.Intermediate_Crop_Props.BoundingBox(4);
                    for i=DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(4)
                        for j=DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(3)
                            PixelCount=PixelCount+1;
                            progressbar(PixelCount/TotalSmoothingArea)
                            PixelStruct(PixelCount).TempVector=zeros(2,length(BlockdemonDispFields_withCarryOver));
                            PixelStruct(PixelCount).i=i;
                            PixelStruct(PixelCount).j=j;
                            for l=1:length(BlockdemonDispFields_withCarryOver)
                                for k=1:2
                                    PixelStruct(PixelCount).TempVector(k,l)=BlockdemonDispFields_withCarryOver{l}.dField(i,j,k);
                                end
                            end
                        end
                    end
                    %Smooth
                    %ppm = ParforProgMon(['Smoothing Demon Fields ',num2str(TotalSmoothingArea),' Pixels ',num2str(length(BlockdemonDispFields_withCarryOver),' Frames for Block #',num2str(BlockNumber),' of ',num2str(NumBlocks)], TotalSmoothingArea, 1, 1200, 80);
                    parfor PixelCount=1:TotalSmoothingArea
                        for k=1:2
                            for z=1:length(DemonReg.DemonSmoothSize)    
                                PixelStruct(PixelCount).TempVector(k,:)=smooth(PixelStruct(PixelCount).TempVector(k,:),DemonReg.DemonSmoothSize(z));
                            end
                        end
                        %ppm.increment();
                    end
                    progressbar('Reconstructing Demon Field: Pixel #')
                    for PixelCount=1:TotalSmoothingArea
                        progressbar(PixelCount/TotalSmoothingArea)
                        for k=1:2
                            for l=1:length(BlockdemonDispFields_withCarryOver)
                                BlockdemonDispFields_withCarryOver{l}.dField(PixelStruct(PixelCount).i,PixelStruct(PixelCount).j,k)=PixelStruct(PixelCount).TempVector(k,l);
                            end
                        end
                    end

                    warning('Removing Carry Over Demon Fields...')
                    CarryOverCount3=1;
                    for l=DemonReg.CarryOverFrames+1:length(BlockdemonDispFields_withCarryOver)
                        BlockdemonDispFields{CarryOverCount3}.dField=BlockdemonDispFields_withCarryOver{l}.dField;
                        CarryOverCount3=CarryOverCount3+1;
                    end
                    clear CarryOver_BlockdemonDispFields BlockdemonDispFields_withCarryOver

                    warning('Temporarily Storing Carry Over Demon Fields')
                    CarryOverCount=1;
                    for l=length(BlockdemonDispFields)-DemonReg.CarryOverFrames+1:length(BlockdemonDispFields)
                        CarryOver_BlockdemonDispFields{CarryOverCount}.dField=BlockdemonDispFields{l}.dField;
                        CarryOverCount=CarryOverCount+1;
                    end

                else
                    fprintf(['Smoothing Demon Fields...\n'])
                    %Extract all pixel traces
                    clear PixelStruct
                    progressbar('Splitting Demon Field: Pixel #')
                    PixelCount=0;
                    TotalSmoothingArea=DemonReg.Intermediate_Crop_Props.BoundingBox(3)*DemonReg.Intermediate_Crop_Props.BoundingBox(4);
                    for i=DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(4)
                        for j=DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(3)
                            PixelCount=PixelCount+1;
                            progressbar(PixelCount/TotalSmoothingArea)
                            PixelStruct(PixelCount).TempVector=zeros(2,length(BlockdemonDispFields));
                            PixelStruct(PixelCount).i=i;
                            PixelStruct(PixelCount).j=j;
                            for l=1:length(BlockdemonDispFields)
                                for k=1:2
                                    PixelStruct(PixelCount).TempVector(k,l)=BlockdemonDispFields{l}.dField(i,j,k);
                                end
                            end
                        end
                    end
                    %Smooth
                    %ppm = ParforProgMon(['Smoothing Demon Fields ',num2str(TotalSmoothingArea),' Pixels ',num2str(length(BlockdemonDispFields_withCarryOver),' Frames for Block #',num2str(BlockNumber),' of ',num2str(NumBlocks)], TotalSmoothingArea, 1, 1200, 80);
                    for PixelCount=1:TotalSmoothingArea
                        for k=1:2
                            for z=1:length(DemonReg.DemonSmoothSize)     
                                PixelStruct(PixelCount).TempVector(k,:)=smooth(PixelStruct(PixelCount).TempVector(k,:),DemonReg.DemonSmoothSize(z));
                            end
                        end
                        %ppm.increment();
                    end
                    progressbar('Reconstructing Demon Field: Pixel #')
                    for PixelCount=1:TotalSmoothingArea
                        progressbar(PixelCount/TotalSmoothingArea)
                        for k=1:2
                            for l=1:length(BlockdemonDispFields)
                                BlockdemonDispFields{l}.dField(PixelStruct(PixelCount).i,PixelStruct(PixelCount).j,k)=PixelStruct(PixelCount).TempVector(k,l);
                            end
                        end
                    end
                    clear PixelStruct
                    clear CarryOver_BlockdemonDispFields
                    if DemonReg.CarryOver_DemonField_Smoothing
                        warning('Temporarily Storing Carry Over Demon Fields')
                        CarryOverCount=1;
                        for l=length(BlockdemonDispFields)-DemonReg.CarryOverFrames+1:length(BlockdemonDispFields)
                            CarryOver_BlockdemonDispFields{CarryOverCount}.dField=BlockdemonDispFields{l}.dField;
                            CarryOverCount=CarryOverCount+1;
                        end
                    end
                end
            end
        else
            warning('NOTE: NOT SMOOTHING DEMON FIELD TIME DOMAIN!')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['Applying Demon Fields...\n'])
        ImageArrayReg=zeros(size(ImageArrayDemonReg_AllImages_Block));
        progressbar('Applying Demon Field: ImageNumber')
        for BlockPosition=1:BlockedImageNumbers(BlockNumber).BlockSize    
            progressbar(BlockPosition/BlockedImageNumbers(BlockNumber).BlockSize)
            ImageNumber=BlockedImageNumbers(BlockNumber).ImageNumbers(BlockPosition);

            TempImage1=ImageArrayDemonReg_AllImages_Block(:,:,BlockPosition);
            if DemonReg.PadValue_Method==1
                TempImage_Pad_Value=median(TempImage1(:));
            elseif PadValueMethod==2
                TempImage_Pad_Value=mean(TempImage1(:));
            elseif PadValueMethod==3
                TempImage_Pad_Value=min(TempImage1(:));
            else
                TempImage_Pad_Value=0;
            end
            CorrectedImage=imwarp(double(padarray(TempImage1,[DemonReg.Padding DemonReg.Padding],TempImage_Pad_Value)),BlockdemonDispFields{BlockPosition}.dField);
            FinalizedImage=CorrectedImage(DemonReg.Padding+1:size(RegistrationSettings.OverallReferenceImage,1)+DemonReg.Padding,DemonReg.Padding+1:size(RegistrationSettings.OverallReferenceImage,2)+DemonReg.Padding);
            ImageArrayReg(:,:,BlockPosition) = FinalizedImage;
            % AutoPlaybackNew(ImageArrayReg,1,0.0001,[0,max(abs(ImageArrayReg(:)))*0.5],'jet');

            if SaveDemonField
                demonDispFields{ImageNumber,1}=BlockdemonDispFields{BlockPosition}.dField;
            end
        end
        clear ImageArrayDemonReg_AllImages_Block BlockdemonDispFields
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['Saving Data to Scratch Disk...\n'])
        if exist('CarryOver_BlockdemonDispFields')
            save([TempScratchSaveDir,'Temp_ImageArrayDemonReg_AllImages_Block_',num2str(BlockNumber),'.mat'],'ImageArrayReg','CarryOver_BlockdemonDispFields');
        else
            save([TempScratchSaveDir,'Temp_ImageArrayDemonReg_AllImages_Block_',num2str(BlockNumber),'.mat'],'ImageArrayReg');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(['Finished Block #',num2str(BlockNumber),' of ',num2str(NumBlocks),'\n'])
        BlockTime=toc(BlockTimer);
        fprintf(['Block #',num2str(BlockNumber),' Took ',num2str(BlockTime/60),'min ETA ',...
            num2str(round((BlockTime*(NumBlocks-BlockNumber)/3600)*100)/100),'hr\n'])
        fprintf(['====================================================\n'])

        clear ImageArrayReg
    end
    fprintf(['====================================================\n'])
    fprintf(['====================================================\n'])
    fprintf(['====================================================\n'])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Merging Block Data...')
    for ImageNumber=1:ImagingInfo.TotalNumFrames 
        ImageArrayDemonReg_AllImages(:,:,ImageNumber)=double(zeros(size(RegistrationSettings.OverallReferenceImage,1),size(RegistrationSettings.OverallReferenceImage,2)));
    end
    for BlockNumber=1:NumBlocks
        load([TempScratchSaveDir,'Temp_ImageArrayDemonReg_AllImages_Block_',num2str(BlockNumber),'.mat'],'ImageArrayReg');
        ImageArrayDemonReg_AllImages(:,:,BlockedImageNumbers(BlockNumber).ImageNumbers)=double(ImageArrayReg);
        clear ImageArrayReg
    end       
    fprintf('Finished!\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ImageArrayDemonReg_AllImages=uint16(ImageArrayDemonReg_AllImages);
    fprintf(['Finished Demon Registration Calculations\n'])
    TimeInterval=toc(TimeHandle);
    fprintf(['Demon Registration took: ',num2str((round(TimeInterval*10)/10)/60),' min or approx. ',num2str(((round(TimeInterval*10)/10))/ImagingInfo.TotalNumFrames),' s per image\n']);
    fprintf(['====================================================\n'])
end