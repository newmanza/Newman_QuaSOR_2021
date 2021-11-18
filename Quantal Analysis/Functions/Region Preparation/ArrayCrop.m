% imcrop for an array
% ImageArray(y-coord, x-coord, ImageNumber)

function CroppedArray = ArrayCrop(ImageArray, BoundingBox)

LastImageNumber = size(ImageArray, 3);

for ImageNumber=1:LastImageNumber
   CroppedArray(:,:, ImageNumber) = imcrop(ImageArray(:,:, ImageNumber), BoundingBox); 
end