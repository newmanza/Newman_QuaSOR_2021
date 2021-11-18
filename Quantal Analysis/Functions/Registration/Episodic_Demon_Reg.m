function [ImageArrayDemonReg_FirstImages,FirstImage_demonDispFields]=Episodic_Demon_Reg(RunParallel,myPool,StackSaveName,ImageArrayDFTReg_FirstImages,...
        ReferenceImage_Padded_Masked_Filtered_Enhanced,...
        AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,BorderLine_Orig,Crop_Props,...
        ImagingInfo,RegistrationSettings,RegEnhancement,DemonReg,IsDFTMoving)
    %Demon registration
    close all
    fprintf(['====================================================\n'])
    fprintf('Starting Episodic Diffeomorphic Demon Registration...\n') 
    MatlabVersion=version('-release');
    Temp_MatlabVersionYear=MatlabVersion(1:4);
    TimeHandle=tic;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FirstImage_demonDispFields = cell(ImagingInfo.NumEpisodes,1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isfield(RegEnhancement,'DemonMask')
        if ~isempty(RegEnhancement.DemonMask)||sum(RegEnhancement.DemonMask(:))>0
            fprintf('NOTE: Applying a Demon Mask to Remove Off-Target Fluorescence...\n')
        end
    else
        RegEnhancement.DemonMask=[];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['Calculating Demon Fields...'])
    ppm = ParforProgMon([StackSaveName,' || DEMON Registration (',num2str(ImagingInfo.NumEpisodes),' Episodes) || '], ImagingInfo.NumEpisodes, 1, 1200, 80);
    parfor EpisodeNumber=1:ImagingInfo.NumEpisodes

        TempImage=ImageArrayDFTReg_FirstImages(:,:,EpisodeNumber);
        [~,TempImage_Padded_Masked_Filtered_Enhanced]=...
            RegistrationImageEnhancement(TempImage,AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,...
            BorderLine_Orig,Crop_Props,DemonReg,RegEnhancement,[],[],0,0);

        %%%%%%%%%%%%%
        if DemonReg.DynamicSmoothing
            if IsDFTMoving(EpisodeNumber)
                TempAccumulatedFieldSmoothing=DemonReg.AccumulatedFieldSmoothing-DemonReg.DynamicSmoothing;
            else
                TempAccumulatedFieldSmoothing=DemonReg.AccumulatedFieldSmoothing;
            end
        else
            TempAccumulatedFieldSmoothing=DemonReg.AccumulatedFieldSmoothing;
        end
        dField=double(zeros(size(ReferenceImage_Padded_Masked_Filtered_Enhanced,1),size(ReferenceImage_Padded_Masked_Filtered_Enhanced,2),2));
        if ~isempty(RegEnhancement.DemonMask)||sum(RegEnhancement.DemonMask(:))>0
            Mov_Image=TempImage_Padded_Masked_Filtered_Enhanced;
            Ref_Image=ReferenceImage_Padded_Masked_Filtered_Enhanced;
            Mov_Image(logical(RegEnhancement.DemonMask))=0;
            Ref_Image(logical(RegEnhancement.DemonMask))=0;
        else
            Mov_Image=TempImage_Padded_Masked_Filtered_Enhanced;
            Ref_Image=ReferenceImage_Padded_Masked_Filtered_Enhanced;
        end

        if str2num(Temp_MatlabVersionYear)<2016
            [dField,~] = imregdemons_ZN(Mov_Image,Ref_Image,DemonReg.Iterations,...
                'PyramidLevels',DemonReg.PyramidLevels,'AccumulatedFieldSmoothing',TempAccumulatedFieldSmoothing);  
        else
            [dField,~] = imregdemons(Mov_Image,Ref_Image,DemonReg.Iterations,...
                'PyramidLevels',DemonReg.PyramidLevels,'AccumulatedFieldSmoothing',TempAccumulatedFieldSmoothing, 'DisplayWaitbar',false); 
        end
        %%%%%%%%%%%%%
        FirstImage_demonDispFields{EpisodeNumber}.dField=dField;
        ppm.increment();
    end
    fprintf(['Finished Calculating Demon Fields\n'])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if DemonReg.SmoothDemon
        if DemonReg.CircularFilter
            warning('Adding initial demon field vectors to end of recording to assist in filtering...')
        end
        if DemonReg.DynamicSmoothing
            warning('DemonReg.DynamicSmoothing is engaged...')
        end
        if DemonReg.FastSmoothing
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TotalSmoothingArea=DemonReg.Intermediate_Crop_Props.BoundingBox(3)*DemonReg.Intermediate_Crop_Props.BoundingBox(4);
            VerticalPixels=DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(4);
            HorizontalPixels=DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(3);
            [FirstImage_demonDispFields,myPool]=SmoothDemonField(myPool,FirstImage_demonDispFields,DemonReg.DemonSmoothSize,DemonReg.DynamicSmoothing,IsDFTMoving,DemonReg.CircularFilter,DemonReg.CircularFilterFrames,...
                DemonReg.PixelBlockSize,TotalSmoothingArea,VerticalPixels,HorizontalPixels);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        else
            fprintf(['Deconstructing Demon Fields...\n'])
            %Extract all pixel traces
            clear PixelStruct
            progressbar('Deconstructing Demon Field: Pixel #')
            PixelCount=0;
            TotalSmoothingArea=DemonReg.Intermediate_Crop_Props.BoundingBox(3)*DemonReg.Intermediate_Crop_Props.BoundingBox(4);
            for i=DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(2)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(4)
                for j=DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+1:DemonReg.Intermediate_Crop_Props.BoundingBox(1)+DemonReg.Padding+DemonReg.Intermediate_Crop_Props.BoundingBox(3)
                    PixelCount=PixelCount+1;
                    progressbar(PixelCount/TotalSmoothingArea)
                    PixelStruct(PixelCount).TempVector=zeros(2,length(FirstImage_demonDispFields));
                    PixelStruct(PixelCount).i=i;
                    PixelStruct(PixelCount).j=j;
                    for l=1:length(FirstImage_demonDispFields)
                        for k=1:2
                            PixelStruct(PixelCount).TempVector(k,l)=FirstImage_demonDispFields{l}.dField(i,j,k);
                        end
                    end
                end
            end
            if DemonReg.CircularFilter
                warning('Adding initial demon field vectors to end of recording to assist in filtering...')
                for PixelCount=1:TotalSmoothingArea
                    for k=1:2
                        PixelStruct2(PixelCount).TempVector(k,:)=cat(2,PixelStruct(PixelCount).TempVector(k,:),PixelStruct(PixelCount).TempVector(k,1:DemonReg.CircularFilterFrames));
                        PixelStruct2(PixelCount).i=PixelStruct(PixelCount).i;
                        PixelStruct2(PixelCount).j=PixelStruct(PixelCount).j;
                    end
                end
                PixelStruct=PixelStruct2;
                clear PixelStruct2
            end
            if DemonReg.DynamicSmoothing
                warning('DemonReg.DynamicSmoothing is engaged...')
            end
            disp('Smoothing Demon Fields...')
            %Smooth
            parfor PixelCount=1:TotalSmoothingArea
                for k=1:2
                    for z=1:length(DemonReg.DemonSmoothSize)     
                        if DemonReg.DynamicSmoothing
                            PixelStruct(PixelCount).TempVector(k,:)=Zach_MovingAvgFilter_Exclusions(PixelStruct(PixelCount).TempVector(k,:),DemonReg.DemonSmoothSize(z),IsDFTMoving);
                        else
                            PixelStruct(PixelCount).TempVector(k,:)=Zach_MovingAvgFilter_Exclusions(PixelStruct(PixelCount).TempVector(k,:),DemonReg.DemonSmoothSize(z),zeros(size(PixelStruct(PixelCount).TempVector(k,:))));
                            %old smooth
                            %PixelStruct(PixelCount).TempVector(k,:)=smooth(PixelStruct(PixelCount).TempVector(k,:),DemonReg.DemonSmoothSize);
                        end
                    end
                end
            end
            disp('Reconstructing Demon fields...')
            progressbar('Reconstructing Demon Field: Pixel #')
            for PixelCount=1:TotalSmoothingArea
                progressbar(PixelCount/TotalSmoothingArea)
                for k=1:2
                    for l=1:length(FirstImage_demonDispFields)
                        FirstImage_demonDispFields{l}.dField(PixelStruct(PixelCount).i,PixelStruct(PixelCount).j,k)=PixelStruct(PixelCount).TempVector(k,l);
                    end
                end
            end
            clear PixelStruct
        end
    else
        warning('NOTE: NOT SMOOTHING DEMON FIELD TIME DOMAIN!')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['Applying Demon Fields to First Images...\n'])
    ImageArrayDemonReg_FirstImages=zeros(size(RegistrationSettings.OverallReferenceImage,1),size(RegistrationSettings.OverallReferenceImage,2),ImagingInfo.NumEpisodes);
    progressbar('Applying Demon Field: ImageNumber')
    for EpisodeNumber=1:ImagingInfo.NumEpisodes    
        progressbar(EpisodeNumber/ImagingInfo.NumEpisodes)

        TempImage1=ImageArrayDFTReg_FirstImages(:,:,EpisodeNumber);
        %Pad Border if not already
        if size(TempImage1)>size(RegistrationSettings.OverallReferenceImage)
            TempImage_Padded=TempImage1;
        else
            %Determine Value to use for filling Pad area
            if DemonReg.PadValue_Method==1
                TempImage_Pad_Value=median(TempImage1(:));
            elseif PadValueMethod==2
                TempImage_Pad_Value=mean(TempImage1(:));
            elseif PadValueMethod==3
                TempImage_Pad_Value=min(TempImage1(:));
            else
                TempImage_Pad_Value=0;
            end
            TempImage_Padded = padarray(TempImage1,[DemonReg.Padding DemonReg.Padding],TempImage_Pad_Value);
        end
        CorrectedImage=imwarp(double(TempImage_Padded),FirstImage_demonDispFields{EpisodeNumber}.dField);
        FinalizedImage=CorrectedImage(DemonReg.Padding+1:size(RegistrationSettings.OverallReferenceImage,1)+DemonReg.Padding,DemonReg.Padding+1:size(RegistrationSettings.OverallReferenceImage,2)+DemonReg.Padding);
        ImageArrayDemonReg_FirstImages(:,:,EpisodeNumber) = FinalizedImage;
    end
    ImageArrayDemonReg_FirstImages=uint16(ImageArrayDemonReg_FirstImages);
    fprintf(['Finished Demon Registration Calculations\n'])
    TimeInterval=toc(TimeHandle);
    fprintf(['Demon Registration took: ',num2str((round(TimeInterval*10)/10)/60),' min or approx. ',num2str(((round(TimeInterval*10)/10))/ImagingInfo.NumEpisodes),' s per episode\n']);
    warning('DemonReg.BoutonRefinement and DFTReg_Intermediate_Crop are not currently being used in this registration mode!')
    fprintf(['====================================================\n'])
end
