function [ImageArrayDFTReg_AllImages,DeltaX_DFTReg_Whole,DeltaY_DFTReg_Whole]=...
    Stream_DFT_Reg(RunParallel,myPool,StackSaveName,...
        ImageArray_AllImages,ImageArrayCoarseReg_AllImages,...
        ReferenceImage_FFT,ReferenceImage_Padded_Masked_Filtered_Enhanced_FFT,...
        AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,BorderLine_Orig,Crop_Props,...
        ImagingInfo,RegEnhancement,DemonReg,DFT_UpScaleFactor)

    %DFT subpixel registration on whole image        
    TimeHandle=tic;
    ImageArrayDFTReg_AllImages=zeros(size(ImageArray_AllImages));
    fprintf('Whole Image DFT Registration...\n')
    ppm = ParforProgMon([StackSaveName,' || DFT Registration (',num2str(ImagingInfo.TotalNumFrames),' Total Frames) || '], ImagingInfo.TotalNumFrames, 1, 1200, 80);
    parfor ImageNumber=1:ImagingInfo.TotalNumFrames 
        TempImage = ImageArrayCoarseReg_AllImages(:,:,ImageNumber);
        if DemonReg.DFT_Pad_Enhance

            [TempImage_Padded,TempImage_Padded_Masked_Filtered_Enhanced]=...
                RegistrationImageEnhancement(TempImage,AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,...
                BorderLine_Orig,Crop_Props,DemonReg,RegEnhancement,[],[],0,0);
            TempImage_Padded_Masked_Filtered_Enhanced_FFT=fft2(TempImage_Padded_Masked_Filtered_Enhanced);

%                         %filter all pixels outside of the region
%                         TempImage_Padded_Masked_Filtered = roifilt2(fspecial('disk', 10),double(TempImage_Padded_Biased),~logical(TempImage_Enhanced_Mask_MatchedROI_Biased_Mask));
%                         TempImage_Padded_Masked_Filtered_Enhanced=Zach_enhanceContrastForDemon(imfilter(uint16(TempImage_Padded_Masked_Filtered), fspecial('gaussian', RegEnhancement.EnhanceFilterSize_px,  RegEnhancement.EnhanceFilterSigma_px)),RegEnhancement.weinerParams,RegEnhancement.openParams,RegEnhancement.StretchLimParams);
%                         TempImage_Padded_Masked_Filtered_Enhanced_FFT=fft2(TempImage_Padded_Masked_Filtered_Enhanced);

            [OutputParams TempFFTOutput] = dftregistration(ReferenceImage_Padded_Masked_Filtered_Enhanced_FFT,TempImage_Padded_Masked_Filtered_Enhanced_FFT,DFT_UpScaleFactor);
            DeltaX_DFTReg_Whole(ImageNumber)=OutputParams(4);
            DeltaY_DFTReg_Whole(ImageNumber)=OutputParams(3);
            Error_DFTReg_Whole(ImageNumber)=OutputParams(1); 
            Diffphase_DFTReg_Whole(ImageNumber)=OutputParams(2);          

            TempImage_Pad_Value=0;
            [nr,nc]=size(ReferenceImage_FFT);
            Nr = ifftshift([-fix(nr/2):ceil(nr/2)-1]);
            Nc = ifftshift([-fix(nc/2):ceil(nc/2)-1]);
            [Nc,Nr] = meshgrid(Nc,Nr);
            %Apply DFT Shifts
            XShift=DeltaX_DFTReg_Whole(ImageNumber);
            YShift=DeltaY_DFTReg_Whole(ImageNumber);
            CorrectionField=exp(1i*2*pi*(-YShift*Nr/nr-XShift*Nc/nc));
            TempFFTOutput = fft2(TempImage).*CorrectionField;
            TempFFTOutput = TempFFTOutput*exp(1i*Diffphase_DFTReg_Whole(ImageNumber));
            TempDFTCorrectedImage=uint16(real(ifft2(TempFFTOutput)));
            ImageArrayDFTReg_AllImages(:,:,ImageNumber)=uint16(TempDFTCorrectedImage);
        else
            %NEW Subpixel registration by crosscorrelation using DFTRegistration on whole image
            TempImage_Padded_Masked_Filtered_Enhanced_FFT=[];
            TempImage_FFT=fft2(TempImage);
            [OutputParams TempFFTOutput] = dftregistration(ReferenceImage_FFT,TempImage_FFT,DFT_UpScaleFactor);
            DeltaX_DFTReg_Whole(ImageNumber)=OutputParams(4);
            DeltaY_DFTReg_Whole(ImageNumber)=OutputParams(3);
            Error_DFTReg_Whole(ImageNumber)=OutputParams(1); 
            Diffphase_DFTReg_Whole(ImageNumber)=OutputParams(2); 
            TempDFTCorrectedImage=double(real(ifft2(TempFFTOutput)));
            ImageArrayDFTReg_AllImages(:,:,ImageNumber)=uint16(TempDFTCorrectedImage);
        end
        ppm.increment();
    end
    fprintf('Cleaning DFT Registered Array...\n')        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %clean up motion correction edges
    progressbar('Cleaning DFT Registered Array || ImageNumber')
    for ImageNumber=1:ImagingInfo.TotalNumFrames 
        progressbar(ImageNumber/ImagingInfo.TotalNumFrames)
        TempImage1 = ImageArrayDFTReg_AllImages(:,:,ImageNumber);
        EdgeMask=zeros(size(TempImage1));
        XShift=ceil(DeltaX_DFTReg_Whole(ImageNumber));
        YShift=ceil(DeltaY_DFTReg_Whole(ImageNumber));
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
        ImageArrayDFTReg_AllImages(:,:,ImageNumber)=uint16(TempImage1);
    end       
    TimeInterval=toc(TimeHandle);
    fprintf(['Whole Image DFT Registration took: ',num2str((round(TimeInterval*10)/10)/60),' min\n']);
end