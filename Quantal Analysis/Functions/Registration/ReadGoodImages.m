% Read "GoodImages" from StackFileName
function ImageArray = ReadGoodImages(StackFileName, GoodImages);

NumOfSelected = length(GoodImages);

for ImageNumber=1:NumOfSelected
    ImageArray(:,:, ImageNumber) = imread(StackFileName,'tif',GoodImages(ImageNumber));
end