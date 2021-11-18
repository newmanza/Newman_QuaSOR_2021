function MeanData = MeanValues(ImageArray_Reg, Region1)

    LastImageNumber = size(ImageArray_Reg, 3);
    for ImageNumber=1:LastImageNumber
       TmpImage = ImageArray_Reg(:,:,ImageNumber);
       MeanData(ImageNumber) = mean(TmpImage(Region1));
    end
end