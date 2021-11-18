function AllRegions = FindRegionsOneImage(Image, dilateSize, min_pixels, fudgeFactor)

if size(Image,1)*size(Image,2)>300000
    f = waitbar(0,'Large File! Please Wait While I Find Regions...');
end

% find threshold from Image, will use it in a few lines
% trying with 'log' edge detection method instead of 'sobel'
 %aG5=imfilter(Image,fspecial('gaussian',5,0.7)); %Filter a
aG5 = Image;
    [junk threshold] = edge(aG5, 'log'); %find edges (gradient) --> get threshold value
%  [junk threshold] = edge(aG5, 'sobel'); %find edges (gradient) --> get threshold value
if size(Image,1)*size(Image,2)>300000
    waitbar(0.1,f,'Large File! Please Wait While I Find Regions...');
end
% find regions of interest
    BWs = edge(aG5,'log', threshold * fudgeFactor); % find edges with threshold*fudgeFactor instead of threshold
   % BWs = edge(aG5,'sobel', threshold * fudgeFactor); % find edges with threshold*fudgeFactor instead of threshold
    %imtool(BWs);
if size(Image,1)*size(Image,2)>300000
    waitbar(0.2,f,'Large File! Please Wait While I Find Regions...');
end
  %  dilateSize = 3;   %a few sections to refine edges =7 for 'sobel'
    se90 = strel('line', dilateSize, 90);
    se0 = strel('line', dilateSize, 0);
    BWsdil = imdilate(BWs, [se90 se0]); %dilate edges - roi should be completely surrounded by edge
    %imtool(BWsdil);
if size(Image,1)*size(Image,2)>300000
    waitbar(0.4,f,'Large File! Please Wait While I Find Regions...');
end
    BWdfill = imfill(BWsdil, 'holes'); %fill holes - roi should be completely filled
    %figure, imshow(BWdfill);
if size(Image,1)*size(Image,2)>300000
    waitbar(0.7,f,'Large File! Please Wait While I Find Regions...');
end
    seD = strel('diamond',1); %eroding borders of roi - finer details
    BWfinal1 = imerode(BWdfill,seD);
    BWfinal1 = imerode(BWfinal1,seD);
    %figure, imshow(BWfinal), title('all rois'); %BWfinal is the resulting roi's
    BWfinal2 = imdilate(BWfinal1, [se90 se0]); %dialating again...added this for 'log'
if size(Image,1)*size(Image,2)>300000
    waitbar(0.8,f,'Large File! Please Wait While I Find Regions...');
end    
    % remove areas smaller than min_pixels
    BWfinal3 = bwareaopen(BWfinal2,min_pixels);
    
    AllRegions=BWfinal3;
if size(Image,1)*size(Image,2)>300000
    waitbar(0.9,f,'Large File! Please Wait While I Find Regions...');
end
   %show outline and filtered image. outline = perimeter of roi's
   BWoutline = bwperim(BWfinal3); 
   Segout = aG5;
   Segout(BWoutline) = 65536;
   %figure, imshow(Segout,[]);
if size(Image,1)*size(Image,2)>300000
    waitbar(1,f,'Large File! Please Wait While I Find Regions...');
    delete(f)
end

