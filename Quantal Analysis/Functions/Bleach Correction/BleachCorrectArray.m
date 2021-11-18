

function ImageArrayRegBC_NoStim = BleachCorrectArray(ImageArrayReg_NoStim, Vector_AllNoStim_GFPAvg, AllBoutonsRegion)

ImagesPerSequence = length(Vector_AllNoStim_GFPAvg);
NumOfSequences = size(ImageArrayReg_NoStim, 3) / ImagesPerSequence;

for SeqNumber=1:NumOfSequences
        FirstIndex = (ImagesPerSequence * (SeqNumber - 1)) + 1;
        SecondIndex = ImagesPerSequence * SeqNumber;
        
        TmpImage = ImageArrayReg_NoStim(:,:,FirstIndex);
        MeanGFP_FirstImage = mean(TmpImage(AllBoutonsRegion));
        
        Vector_Index = 1;
        for ImageNumber=FirstIndex:SecondIndex
            ImageArrayRegBC_NoStim(:,:,ImageNumber) = (ImageArrayReg_NoStim(:,:,ImageNumber)) / MeanGFP_FirstImage / Vector_AllNoStim_GFPAvg(Vector_Index);          
            Vector_Index = Vector_Index + 1;
        end        
end
