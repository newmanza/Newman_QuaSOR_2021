function AllRegions = RemoveRegionArray(AllRegions) % draw a region, this region will be removed from the logical image array AllRegions

Region1 = roipoly; % draw a region on the current figure
Region1 = imcomplement(Region1);

LastImageNumber = size(AllRegions, 3);
for ImageNumber=1:LastImageNumber
    AllRegions(:,:,ImageNumber) = AllRegions(:,:,ImageNumber) .* Region1; % remove the region from AllRegions
end

figure, imshow(AllRegions(:,:,1));