% BoutonArray is a structure: BoutonArray(BotuonNumber).Field with fields
% .ImageArea, .ImageDeltaGFP, etc. The function will add fields .DeltaX and .DeltaY

% BeforeGFPImageArray(y-coord, x-coord, ImageNumber)

function BoutonArray = ArrayReg(BoutonArray, BeforeGFPImageArray, MaxShift, MinCorrValue, Jitters);

LastImageNumber = size(BeforeGFPImageArray,3);
LastBoutonNumber = size(BoutonArray, 2);

BestImage = BeforeGFPImageArray(:,:,1); % 'BestImage will be the first in the image array
progressbar('Registering | Bouton #')
for BoutonNumber=1:LastBoutonNumber
    progressbar(BoutonNumber/LastBoutonNumber)
    AlignRegion = BoutonArray(BoutonNumber).ImageArea;
%     AlignRegion = bwmorph(AlignRegion, 'thicken', 2); % thicken AlignRegion (to have edges for alignment)
    RegionsProps = regionprops(double(AlignRegion), 'BoundingBox', 'PixelIdxList');

    DeltaX = zeros(1, LastImageNumber); % Keeping results of DeltaX, DeltaY shifts for all images and regions
    DeltaY = zeros(1, LastImageNumber);
    MaxValue = zeros(1, LastImageNumber);

    CroppedImage = imcrop(BestImage,[RegionsProps.BoundingBox]);

    % This would be the position of CroppedImage in the following correlation matrix (if there was no movement),
    % will use later to compare to neighboring images in stack.
    xpeakBest = ceil(RegionsProps.BoundingBox(1) + RegionsProps.BoundingBox(3));
    ypeakBest = ceil(RegionsProps.BoundingBox(2) + RegionsProps.BoundingBox(4));
 
    yMinRange = max(0, ypeakBest - MaxShift); % coordinates for allowed range of movement for correlation with the rest of the images
    yMaxRange = min(size(AlignRegion, 1), ypeakBest + MaxShift);
    xMinRange = max(0, xpeakBest - MaxShift);
    xMaxRange = min(size(AlignRegion, 2), xpeakBest + MaxShift);
 
 
    for ImageNumber=2:LastImageNumber     
    
        %Correlate CroppedImage with Image and find position of max correlation
        [ypeakNew, xpeakNew, MaxValue(ImageNumber)] = CorrRegionImage(CroppedImage,BeforeGFPImageArray(:,:,ImageNumber), yMinRange, yMaxRange, xMinRange, xMaxRange);
        DeltaX(ImageNumber) = xpeakBest - xpeakNew; % find deltaX and deltaY shifts
        DeltaY(ImageNumber) = ypeakBest - ypeakNew;
   
      % translate image according to correlation result 
%         TmpImage = TranslateImage(BeforeGFPImageArray(:,:,ImageNumber), DeltaY(ImageNumber), DeltaX(ImageNumber)); 
    
        % prepare for next round. Using this line - correlation function will be
        % between image i+1 and image i (but DeltaX, DeltaY, are relative
        % to the first image). Registration is not good when using this
        % line...??
        % Probably because of spontanuous activity in the 'before' images.
        % Not using this line - correlation function is always to the first image.
%         CroppedImage = imcrop(TmpImage,[RegionsProps.BoundingBox]); % change CroppedImage
       
    end
    
    % correct jitter
    DeltaX = CorrectJitter(DeltaX, Jitters);
    DeltaY = CorrectJitter(DeltaY, Jitters);
    
    %Write Deltax, DeltaY to BoutonArray
    BoutonArray(BoutonNumber).DeltaX = DeltaX;
    BoutonArray(BoutonNumber).DeltaY = DeltaY;
    
end
