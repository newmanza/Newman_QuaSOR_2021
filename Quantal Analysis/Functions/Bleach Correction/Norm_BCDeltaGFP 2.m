
function ImageArray_WithStim_DeltaGFPn = Norm_BCDeltaGFP(ImageArray_WithStim_DeltaGFP, ImageArrayRegBC_WithStim, ImagesPerSequence)


NumOfSequences = size(ImageArrayRegBC_WithStim, 3) / ImagesPerSequence;
warning off all

for SeqNumber=1:NumOfSequences
        FirstIndex = (ImagesPerSequence * (SeqNumber - 1)) + 1;
        SecondIndex = ImagesPerSequence * SeqNumber;
        
        FirstImage = ImageArrayRegBC_WithStim(:,:,FirstIndex);
        
        for ImageNumber=FirstIndex:SecondIndex
            TmpImage = ImageArray_WithStim_DeltaGFP(:,:,ImageNumber) ./ FirstImage;
            TmpImage(FirstImage==0) = 0;
            ImageArray_WithStim_DeltaGFPn(:,:,ImageNumber) = TmpImage;
        end        
end

warning on all