function ImageArray_Reg1 = TranslateArrayParallel(ImageArray_Reg, DeltaX1, DeltaY1);


LastImageNumber = size(ImageArray_Reg, 3);

% this if is for when DeltaX, DeltaY are just one vector each (translate whole
% array by these two vectors, instead of separate DeltaX, DeltaY for each
% image)
if (length(DeltaX1)==1)
   DeltaX1(1:LastImageNumber) = DeltaX1;
   DeltaY1(1:LastImageNumber) = DeltaY1;
end

parfor ImageNumber=1:LastImageNumber
    
    ImageArray_Reg1(:,:,ImageNumber) = TranslateImage(ImageArray_Reg(:,:,ImageNumber), DeltaY1(ImageNumber), DeltaX1(ImageNumber)); %DeltaX, DeltaY are in opposite order here...this is correct
    
end
%OffsetImage = TranslateImage(Image, DeltaY, DeltaX)