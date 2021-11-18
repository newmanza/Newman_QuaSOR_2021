% threshold an array of images ImageArray(ycoord, xcoord, ImageNumber)
% using imextendedmax

function BWArray = ExtendedMaxArray(ImageArray, threshold)
    
    LastImageNumber = size(ImageArray, 3);
    ImageArray(isnan(ImageArray)) = 0; % for the following to work, replace all NaN values in ImageArray with 0
    %progressbar('Image Number')
    for ImageNumber = 1:LastImageNumber
        %progressbar(ImageNumber/LastImageNumber)
        BWArray(:,:,ImageNumber) = imextendedmax(ImageArray(:,:,ImageNumber), threshold);
    end
    