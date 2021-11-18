function AllRegions = AddRegion(AllRegions) % draw a region, this region will be removed from the logical image AllRegions

Region1 = roipoly; % draw a region on the current figure
AllRegions = AllRegions | Region1; % Add region to AllRegions
figure, imshow(AllRegions);