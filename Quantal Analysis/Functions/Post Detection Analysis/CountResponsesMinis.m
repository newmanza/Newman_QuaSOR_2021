% Count # of responses (non-zero areas) in input image array

function  Vector_RFNum = CountResponsesMinis(ImageArray_NoStim_CorrAmp_norm_fix);

LastImageNumber = size(ImageArray_NoStim_CorrAmp_norm_fix,3);

for ImageNumber=1:LastImageNumber 
    OneImage = ImageArray_NoStim_CorrAmp_norm_fix(:,:, ImageNumber);
    [Labels Num] = bwlabel(OneImage, 4);  
    Vector_RFNum(ImageNumber) = Num;
end







