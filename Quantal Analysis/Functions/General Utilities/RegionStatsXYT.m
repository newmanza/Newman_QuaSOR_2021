function [RegionMean,RegionSTD,RegionSEM,RegionSize] = RegionStatsXYT(ImageArray, Region1)

LastImageNumber = size(ImageArray, 3);
RegionSize=sum(double(Region1(:)));
for ImageNumber=1:LastImageNumber
   TmpImage = ImageArray(:,:,ImageNumber);
   RegionMean(ImageNumber) = nanmean(TmpImage(Region1));
   RegionSTD(ImageNumber) = nanstd(TmpImage(Region1));
   RegionSEM(ImageNumber)=RegionSTD(ImageNumber)/sqrt(RegionSize);
end


end