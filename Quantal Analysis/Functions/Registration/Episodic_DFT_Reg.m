function [ImageArrayDFTReg_FirstImages,DeltaX_DFTReg_Whole,DeltaY_DFTReg_Whole]=...
    Episodic_DFT_Reg(RunParallel,myPool,StackSaveName,...
        ImageArray_FirstImages,ImageArrayCoarseReg_FirstImages,...
        ReferenceImage_FFT,ReferenceImage_Padded_Masked_Filtered_Enhanced_FFT,...
        AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,BorderLine_Orig,Crop_Props,...
        ImagingInfo,RegEnhancement,DemonReg,DFT_UpScaleFactor)
    %NEW Subpixel registration by crosscorrelation using DFTRegistration on whole image
    fprintf(['====================================================\n'])
    fprintf('Calculating and Applying Whole Image DFT Registration...')
    TimeHandle=tic;
    ImageArrayDFTReg_FirstImages=zeros(size(ImageArrayCoarseReg_FirstImages));
    if RunParallel&&~isempty(myPool)
        ppm = ParforProgMon([StackSaveName,' || DFT Registration (',num2str(ImagingInfo.NumEpisodes),' Episodes) || '], ImagingInfo.NumEpisodes, 1, 1200, 80);
        parfor EpisodeNumber=1:ImagingInfo.NumEpisodes 
            TempImage=ImageArrayCoarseReg_FirstImages(:,:,EpisodeNumber);
            if DemonReg.DFT_Pad_Enhance
                warning off
                [TempImage_Padded,TempImage_Padded_Masked_Filtered_Enhanced]=...
                    RegistrationImageEnhancement(TempImage,AllBoutonsRegion_Orig_Padded,AllBoutonsRegion_Orig_Mask_Padded,...
                    BorderLine_Orig,Crop_Props,DemonReg,RegEnhancement,[],[],0,0);
                TempImage_Padded_Masked_Filtered_Enhanced_FFT=fft2(TempImage_Padded_Masked_Filtered_Enhanced);

                [OutputParams TempFFTOutput] = dftregistration(ReferenceImage_Padded_Masked_Filtered_Enhanced_FFT,TempImage_Padded_Masked_Filtered_Enhanced_FFT,DFT_UpScaleFactor);
                DeltaX_DFTReg_Whole(EpisodeNumber)=OutputParams(4);
                DeltaY_DFTReg_Whole(EpisodeNumber)=OutputParams(3);
                Error_DFTReg_Whole(EpisodeNumber)=OutputParams(1); 
                Diffphase_DFTReg_Whole(EpisodeNumber)=OutputParams(2);          
                %TempDFTCorrectedImage=double(real(ifft2(TempFFTOutput)));

                TempImage_Pad_Value=0;
                [nr,nc]=size(ReferenceImage_FFT);
                Nr = ifftshift([-fix(nr/2):ceil(nr/2)-1]);
                Nc = ifftshift([-fix(nc/2):ceil(nc/2)-1]);
                [Nc,Nr] = meshgrid(Nc,Nr);
                %Apply DFT Shifts
                XShift=DeltaX_DFTReg_Whole(EpisodeNumber);
                YShift=DeltaY_DFTReg_Whole(EpisodeNumber);
                CorrectionField=exp(1i*2*pi*(-YShift*Nr/nr-XShift*Nc/nc));
                TempFFTOutput = fft2(TempImage).*CorrectionField;
                TempFFTOutput = TempFFTOutput*exp(1i*Diffphase_DFTReg_Whole(EpisodeNumber));
                TempDFTCorrectedImage1=uint16(real(ifft2(TempFFTOutput)));
                ImageArrayDFTReg_FirstImages(:,:,EpisodeNumber)=uint16(TempDFTCorrectedImage1);
            else
                %NEW Subpixel registration by crosscorrelation using DFTRegistration on whole image
                TempImage_FFT=fft2(TempImage);
                TempImage_Padded_Masked_Filtered_Enhanced_FFT=[];
                [OutputParams TempFFTOutput] = dftregistration(ReferenceImage_FFT,TempImage_FFT,DFT_UpScaleFactor);
                DeltaX_DFTReg_Whole(EpisodeNumber)=OutputParams(4);
                DeltaY_DFTReg_Whole(EpisodeNumber)=OutputParams(3);
                Error_DFTReg_Whole(EpisodeNumber)=OutputParams(1); 
                Diffphase_DFTReg_Whole(EpisodeNumber)=OutputParams(2); 
                TempDFTCorrectedImage=double(real(ifft2(TempFFTOutput)));
                ImageArrayDFTReg_FirstImages(:,:,EpisodeNumber)=uint16(TempDFTCorrectedImage);
            end
            ppm.increment();
        end
    else
        error('Copy from above here!')

    end
    fprintf('Finished!\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
    fprintf('Cleaning DFT Registered Array...')        
    %clean up motion correction edges
    progressbar('Episode')
    for EpisodeNumber=1:ImagingInfo.NumEpisodes 
        progressbar(EpisodeNumber/ImagingInfo.NumEpisodes)
        TempImage1 = ImageArrayDFTReg_FirstImages(:,:,EpisodeNumber);
        TempImage2 = ImageArray_FirstImages(:,:,EpisodeNumber);
        EdgeMask=zeros(size(TempImage1));
        XShift=ceil(DeltaX_DFTReg_Whole(EpisodeNumber));
        YShift=ceil(DeltaY_DFTReg_Whole(EpisodeNumber));
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
            DFT_Fix_Value=median(TempImage2(:));
        elseif PadValueMethod==2
            DFT_Fix_Value=mean(TempImage2(:));
        elseif PadValueMethod==3
            DFT_Fix_Value=min(TempImage2(:));
        else
            DFT_Fix_Value=0;
        end
        TempImage1(logical(EdgeMask))=DFT_Fix_Value;
        ImageArrayDFTReg_FirstImages(:,:,EpisodeNumber)=uint16(TempImage1);
    end       
    fprintf('Finished!\n')
    TimeInterval=toc(TimeHandle);
    fprintf(['Whole Image DFT Registration took: ',num2str(round(TimeInterval*10)/10),' s\n']);
end