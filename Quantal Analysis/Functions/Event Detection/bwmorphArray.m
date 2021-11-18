% use bwmorph an array of images ImageArray(ycoord, xcoord, ImageNumber)
% operation can be 'thicken', 'shrink', 'bridge', etc.

function BWArray = bwmorphArray(ImageArray, operation, repeats)
    
    LastImageNumber = size(ImageArray, 3);
    
    for ImageNumber = 1:LastImageNumber
        BWArray(:,:,ImageNumber) = bwmorph(ImageArray(:,:,ImageNumber), operation, repeats);
    end
    