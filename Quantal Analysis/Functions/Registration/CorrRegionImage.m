function [ypeak, xpeak, MaxValue] = CorrRegionImage(CroppedImage, Image, yMinRange, yMaxRange, xMinRange, xMaxRange)

if (nargin == 2) % Only two input arguments, search for max correlation over all image range 
   CC0 = normxcorr2(CroppedImage,Image); % correlate CroppedImage(small area) and BestImage(full image)
    [MaxValue, MaxIndex] = max(abs(CC0(:))); % find position of max correlation
    [ypeak, xpeak] = ind2sub(size(CC0),MaxIndex); % coordinates of max 
    
elseif (nargin == 6) % Six input arguments, search for max correlation in limited range
    CC0 = normxcorr2(CroppedImage,Image); % correlate template to image, will not be saving correlation result
    CCenter = zeros(size(CC0)); % look only at center of correlation result, limited by MaxShift
    CCenter(yMinRange:yMaxRange,xMinRange:xMaxRange) = CC0(yMinRange:yMaxRange,xMinRange:xMaxRange);
    [MaxValue, MaxIndex] = max(abs(CCenter(:))); % find location of max correlation
    [ypeak, xpeak] = ind2sub(size(CCenter),MaxIndex); % coordinates of max
    
else
    error('Wrong number of input arguments.');
end



