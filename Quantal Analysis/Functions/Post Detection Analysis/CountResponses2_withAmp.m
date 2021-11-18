% Count number of responses (individual spots) in input array
% (ImageArray_DeltaGFPnMax_Reg2)
% count only responses that are in the chosen region (AllBoutonsRegion)

function [RFNum_AllNMJ, RF_CorrAmp_AllNMJ] = CountResponses2_withAmp(ImageArray_DeltaGFPnMax_Reg2, ImageArray_CorrAmp_norm, AllBoutonsRegion)

LastImageNumber = size(ImageArray_DeltaGFPnMax_Reg2,3);
%progressbar('Index Number')
for ImageNumber=1:LastImageNumber 
    %progressbar(ImageNumber/LastImageNumber)
    OneImage = ImageArray_DeltaGFPnMax_Reg2(:,:,ImageNumber);
    OneImage = imfill(OneImage, 'holes'); % fill holes, for next steps to work
    OneImage = bwmorph(OneImage, 'shrink', Inf); % Shrink each maxima to one pixel, to make a clear decision whether it is in the chosen region
    OneImage = OneImage .* AllBoutonsRegion; % Only consider maxima that are in the chosen region
    [Labels Num] = bwlabel(OneImage, 4);  
    RFNum_AllNMJ(ImageNumber) = Num;
    if Num>0
        OneImage_CorrAmp_Norm=ImageArray_CorrAmp_norm(:,:,ImageNumber);
        OneImage_CorrAmp_Norm=OneImage_CorrAmp_Norm.*AllBoutonsRegion;
        RF_CorrAmp_AllNMJ(ImageNumber) = max(max(OneImage_CorrAmp_Norm));
    else
        RF_CorrAmp_AllNMJ(ImageNumber) = NaN;
    end
    
    
end
