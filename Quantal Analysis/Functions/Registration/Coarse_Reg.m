% align ImageArray and keep result in ImageArray_Reg
function [ImageArray_Reg DeltaX DeltaY MaxValue] = Coarse_Reg(ImageArray, AlignRegion, MaxShiftX, MaxShiftY, MinCorrValue)

LastImageNumber = size(ImageArray,3);
BestImage = ImageArray(:,:,1); % Best Image should be first in ImageArray

RegionsProps = regionprops(double(AlignRegion), 'BoundingBox', 'PixelIdxList');

DeltaX = zeros(1, LastImageNumber); % Keeping results of DeltaX, DeltaY shiftes for all images and regions
DeltaY = zeros(1, LastImageNumber);
MaxValue = zeros(1, LastImageNumber);

ImageArray_Reg = ImageArray;

% crop one region from BestImage
% [TmpRegion CroppedImage] = CropRegion(BestImage, RegionsProps, 1); %Crop best image to include region #1
 CroppedImage = imcrop(BestImage,[RegionsProps.BoundingBox]);

% This would be the position of CroppedImage in the following correlation matrix (if there was no movement),
 % will use later to compare to neighboring images in stack.
 xpeakBest = ceil(RegionsProps.BoundingBox(1) + RegionsProps.BoundingBox(3));
 ypeakBest = ceil(RegionsProps.BoundingBox(2) + RegionsProps.BoundingBox(4));
 
 yMinRange = max(0, ypeakBest - MaxShiftY); % coordinates for allowed range of movement for correlation with the rest of the images
 yMaxRange = min(size(AlignRegion, 1), ypeakBest + MaxShiftY);
 xMinRange = max(0, xpeakBest - MaxShiftX);
 xMaxRange = min(size(AlignRegion, 2), xpeakBest + MaxShiftX);
 
 progressbar('Coarse Reg...')
 for ImageNumber=2:LastImageNumber     
    progressbar(ImageNumber/LastImageNumber)
    %Correlate CroppedImage with Image and find position of max correlation
    [ypeakNew, xpeakNew, MaxValue(ImageNumber)] = CorrRegionImage(CroppedImage,ImageArray(:,:,ImageNumber), yMinRange, yMaxRange, xMinRange, xMaxRange);
    DeltaX(ImageNumber) = xpeakBest - xpeakNew; % find deltaX and deltaY shifts
    DeltaY(ImageNumber) = ypeakBest - ypeakNew;
   
    % translate image according to correlation result 
    ImageArray_Reg(:,:,ImageNumber) = TranslateImage(ImageArray_Reg(:,:,ImageNumber), DeltaY(ImageNumber), DeltaX(ImageNumber)); 
    
    % prepare for next round
%     CroppedImage = imcrop(ImageArray_Reg(:,:,ImageNumber),[RegionsProps.BoundingBox]); % change CroppedImage
       
end