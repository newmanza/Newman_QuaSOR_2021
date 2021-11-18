function [TestImage_Round]=ImageRoundnessTest(TestImage,Round_Threshold)

TestImage_BW=logical(TestImage);
se = strel('disk',5);
TestImage_BW = imclose(TestImage_BW,se);

[B,L] = bwboundaries(TestImage_BW,'noholes');

stats = regionprops(L,'Area','Centroid','PixelList');


% loop over the boundaries
for k = 1:length(B)

  % obtain (X,Y) boundary coordinates corresponding to label 'k'
  boundary = B{k};

  % compute a simple estimate of the object's perimeter
  delta_sq = diff(boundary).^2;
  perimeter = sum(sqrt(sum(delta_sq,2)));

  % obtain the area calculation corresponding to label 'k'
  area = stats(k).Area;

  % compute the roundness metric
  metric = 4*pi*area/perimeter^2;

if metric<Round_Threshold
    for j=1:stats(k).Area
        TestImage_BW(stats(k).PixelList(j,2),stats(k).PixelList(j,1))=0;
    end
end
    
end

TestImage_Round=TestImage.*TestImage_BW;


end