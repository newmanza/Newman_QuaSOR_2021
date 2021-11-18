% align ImageArray and keep result in ImageArray_Reg
%[ImageArrayReg_AllImages DeltaX_First DeltaY_First MaxValue_First BoutonArray] = ReadGoodImages_LapseRegXY_ArrayRegIndBoutSel_Crop_Fine_DifFirst([StackSaveName,StackSaveNameSuffix], StackFileName, GoodImages, FilterSize, FilterSigma, AlignRegion, MaxShiftX, MaxShiftY, BoutonArray, MaxShift, MinCorrValue, Jitters, Crop_Props,FirstImageFileName); % not using MinCorrValue for now


function [ImageArray_Reg, DeltaX_DFTReg_Whole, DeltaY_DFTReg_Whole, DeltaX_DFTReg_Bouton, DeltaY_DFTReg_Bouton] = ReadGoodImages_AlignWhole_AlignBouton_DFTReg(StackSaveName, StackFileName, GoodImages, FilterSize, FilterSigma, BoutonArray, Crop_Props,FlipLR,BorderBufferPixelSize);
%FlipLR=1;

pwd;
currentFolder = pwd;
dc = '/';
warning off all
ProcessBlockSize=100;%not used right now
PixelBorder=ones(BorderBufferPixelSize);%This adds buffer zone (10x10 works well most of the time) to boutons to avoid FFT artifacts, may cause problems with ROI too close to borders



LastImageNumber = GoodImages(length(GoodImages));
LastBoutonNumber = size(BoutonArray, 2);
FirstImage = imread(StackFileName,'tif',1);
FirstImage = imfilter(FirstImage, fspecial('gaussian', FilterSize, FilterSigma));
if FlipLR
    FirstImage=fliplr(FirstImage);
end
DeltaX_DFTReg_Whole=zeros(1, LastImageNumber); 
DeltaY_DFTReg_Whole=zeros(1, LastImageNumber); 
DeltaX_DFTReg_Bouton=zeros(size(BoutonArray,2),LastImageNumber);
DeltaY_DFTReg_Bouton=zeros(size(BoutonArray,2),LastImageNumber);



 ImageArray_Reg_Whole=zeros(size(FirstImage,1),size(FirstImage,2),LastImageNumber);
 progressbar('Performing Initial Alignment')
 for ImageNumber=1:LastImageNumber 
     progressbar(ImageNumber/LastImageNumber)
    %load and filter each image 
    TempImage = imread(StackFileName,'tif',GoodImages(ImageNumber));
    if FlipLR
        TempImage=fliplr(TempImage);
    end
    TempImage = imfilter(TempImage, fspecial('gaussian', FilterSize, FilterSigma));
    %NEW Subpixel registration by crosscorrelation using DFTRegistration on whole image
    TempImage_FFT=fft2(TempImage);
    ReferenceImage=uint16(FirstImage);
    ReferenceImage_FFT=fft2(ReferenceImage);
    [OutputParams TempFFTOutput] = dftregistration(ReferenceImage_FFT,TempImage_FFT,100);
    DeltaX_DFTReg_Whole(ImageNumber)=OutputParams(4);
    DeltaY_DFTReg_Whole(ImageNumber)=OutputParams(3);
    TempDFTCorrectedImage=double(real(ifft2(TempFFTOutput)));
    ImageArray_Reg_Whole(:,:,ImageNumber)=uint16(TempDFTCorrectedImage);
    clear ReferenceImage TempImage_FFT ReferenceImage_FFT TempFFTOutput OutputParams TempDFTCorrectedImage
 end
ColorSet = varycolor(LastImageNumber);
figure('name',['Shfits for Whole Image']);
title(['Shfits for Whole Image']);
hold on
ylim([-1*max(abs(DeltaY_DFTReg_Whole)),max(abs(DeltaY_DFTReg_Whole))]); xlim([-1*max(abs(DeltaX_DFTReg_Whole)),max(abs(DeltaX_DFTReg_Whole))]);
ylabel('\DeltaY (px)');xlabel('\DeltaX (px)');
for ImageNumber=1:LastImageNumber 
    plot(DeltaX_DFTReg_Whole(ImageNumber),DeltaY_DFTReg_Whole(ImageNumber),'.','color',ColorSet(ImageNumber,:),'MarkerSize',10);
end
set(gcf, 'color', 'white');
box off
hold off
 
progressbar('Bouton Alignment: Bouton #','Bouton Alignment: Image #')
for BoutonNumber=1:LastBoutonNumber

        AlignRegion_Bouton = BoutonArray(BoutonNumber).ImageArea;
        RegionsProps_Bouton = regionprops(double(AlignRegion_Bouton), 'BoundingBox', 'PixelIdxList');
        %Add buffer region
        AlignRegion_BoutonBorder_Thick = bwperim(AlignRegion_Bouton,8);
        AlignRegion_BoutonBorder_Thick = imdilate(AlignRegion_BoutonBorder_Thick,PixelBorder);
        AlignRegion_Bouton_Thick = logical(AlignRegion_Bouton+AlignRegion_BoutonBorder_Thick);clear AlignRegion_BoutonBorder_Thick
        RegionsProps_Bouton_Thick = regionprops(double(AlignRegion_Bouton_Thick), 'BoundingBox', 'PixelIdxList');
        RegionsProps_Bouton_Thick.BoundingBox=round(RegionsProps_Bouton_Thick.BoundingBox);
        AlignRegion_Bouton_Crop=imcrop(AlignRegion_Bouton,[RegionsProps_Bouton_Thick.BoundingBox]);
        ZerosImage=zeros(size(FirstImage));
        ZerosImage=imcrop(ZerosImage,[RegionsProps_Bouton_Thick.BoundingBox]);
        
        %Remove buffered region data from ImageArray
        TempImageArray=zeros(size(ZerosImage,1),size(ZerosImage,2),LastImageNumber);
        for ImageNumber=1:LastImageNumber
            TempImage=ImageArray_Reg_Whole(:,:,ImageNumber);
            TempImageCrop=imcrop(TempImage,[RegionsProps_Bouton_Thick.BoundingBox]);
            TempImageArray(:,:,ImageNumber)=TempImageCrop;
        end
        TempBoutonStruct(BoutonNumber).Temp_ImageArray_Reg_Bouton=zeros(size(TempImageArray));
        FirstImage_Bouton=imcrop(FirstImage,[RegionsProps_Bouton_Thick.BoundingBox]);
        TempBoutonStruct(BoutonNumber).ExpandYCoords=[RegionsProps_Bouton_Thick.BoundingBox(2):RegionsProps_Bouton_Thick.BoundingBox(2)+RegionsProps_Bouton_Thick.BoundingBox(4)];
        TempBoutonStruct(BoutonNumber).ExpandXCoords=[RegionsProps_Bouton_Thick.BoundingBox(1):RegionsProps_Bouton_Thick.BoundingBox(1)+RegionsProps_Bouton_Thick.BoundingBox(3)];
        TempBoutonStruct(BoutonNumber).AlignRegion_Bouton_Crop=AlignRegion_Bouton_Crop;
        for ImageNumber=1:LastImageNumber 
            progressbar((BoutonNumber-1)/LastBoutonNumber,ImageNumber/LastImageNumber)
            TempImage_Bouton = TempImageArray(:,:,ImageNumber);
            %NEW Subpixel registration by crosscorrelation using DFTRegistration on whole image
            TempImage_FFT=fft2(TempImage_Bouton);
            ReferenceImage=uint16(FirstImage_Bouton);
            ReferenceImage_FFT=fft2(ReferenceImage);
            [OutputParams TempFFTOutput] = dftregistration(ReferenceImage_FFT,TempImage_FFT,100);
            DeltaX_DFTReg_Bouton(BoutonNumber,ImageNumber)=OutputParams(4);
            DeltaY_DFTReg_Bouton(BoutonNumber,ImageNumber)=OutputParams(3);
            TempDFTCorrectedImage=double(real(ifft2(TempFFTOutput)));
            TempBoutonStruct(BoutonNumber).Temp_ImageArray_Reg_Bouton(:,:,ImageNumber)=TempDFTCorrectedImage;            
            clear ReferenceImage TempImage_FFT ReferenceImage_FFT TempFFTOutput OutputParams TempDFTCorrectedImage
        end
end        
        
ZerosImage=zeros(size(ImageArray_Reg_Whole,1),size(ImageArray_Reg_Whole,2));  
for ImageNumber=1:LastImageNumber
    ImageArray_Reg(:,:,ImageNumber)=uint16(imcrop(ZerosImage,[Crop_Props.BoundingBox]));
end
progressbar('Merging Data: Image #','Merging Data: Bouton #')
for ImageNumber=1:LastImageNumber
    TempFrame=ZerosImage;
    for BoutonNumber=1:LastBoutonNumber
        TempImage_Expanded=ZerosImage;
        progressbar(ImageNumber/LastImageNumber,(BoutonNumber-1)/LastBoutonNumber)
        TempImage=TempBoutonStruct(BoutonNumber).Temp_ImageArray_Reg_Bouton(:,:,ImageNumber);
        TempImage=TempImage.*TempBoutonStruct(BoutonNumber).AlignRegion_Bouton_Crop;
        TempImage_Expanded(TempBoutonStruct(BoutonNumber).ExpandYCoords,TempBoutonStruct(BoutonNumber).ExpandXCoords)=TempImage;
        TempFrame=max(TempFrame,TempImage_Expanded);
        clear TempImage TempImage_Expanded
    end
    ImageArray_Reg(:,:,ImageNumber)=uint16(imcrop(TempFrame,[Crop_Props.BoundingBox]));
    clear TempFrame
 end

%  imlook3d(ImageArray_Reg)
%  AutoPlayback(ImageArray_Reg,0.01,[0 MaxStack(ImageArray_Reg)-MaxStack(ImageArray_Reg)*0.3])

 %checking
 ColorSet = varycolor(LastImageNumber);
 for BoutonNumber=1:LastBoutonNumber
    figure('name',['Shfits for Bouton ',num2str(BoutonNumber)]);
    title(['Shfits for Bouton ',num2str(BoutonNumber)]);
    hold on
    ylim([-1*max(abs(DeltaY_DFTReg_Bouton(BoutonNumber,:))),max(abs(DeltaY_DFTReg_Bouton(BoutonNumber,:)))]); xlim([-1*max(abs(DeltaX_DFTReg_Bouton(BoutonNumber,:))),max(abs(DeltaX_DFTReg_Bouton(BoutonNumber,:)))]);
    ylabel('\DeltaY (px)');xlabel('\DeltaX (px)');
    for ImageNumber=1:LastImageNumber 
        plot(DeltaX_DFTReg_Bouton(BoutonNumber,ImageNumber),DeltaY_DFTReg_Bouton(BoutonNumber,ImageNumber),'.','color',ColorSet(ImageNumber,:),'MarkerSize',10);
    end
    set(gcf, 'color', 'white');
    box off
    hold off
    
 end

 disp('Finished Alignment');
 
end
