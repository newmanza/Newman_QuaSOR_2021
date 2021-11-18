% Count number of responses (individual spots) in input array
% (ImageArray_DeltaGFPnMax_Reg2)
% count only responses that are in the chosen region (AllBoutonsRegion)

function RFNum_AllNMJ = CountResponses2(ImageArray_DeltaGFPnMax_Reg2, AllBoutonsRegion)

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
end
