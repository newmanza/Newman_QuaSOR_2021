
function ImageArray_WithStim_DeltaGFP = Get_BCDeltaGFP(ImageArrayRegBC_WithStim, ImagesPerSequence)


NumOfSequences = size(ImageArrayRegBC_WithStim, 3) / ImagesPerSequence;

for SeqNumber=1:NumOfSequences
        FirstIndex = (ImagesPerSequence * (SeqNumber - 1)) + 1;
        SecondIndex = ImagesPerSequence * SeqNumber;
        
        FirstImage = ImageArrayRegBC_WithStim(:,:,FirstIndex);
        
        for ImageNumber=FirstIndex:SecondIndex
            ImageArray_WithStim_DeltaGFP(:,:,ImageNumber) = ImageArrayRegBC_WithStim(:,:,ImageNumber) - FirstImage;       
        end        
end