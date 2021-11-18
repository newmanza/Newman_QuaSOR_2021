function MeanYFP = SumValues(ImageArrayYFP_Reg, Region1);

LastImageNumber = size(ImageArrayYFP_Reg, 3);

for ImageNumber=1:LastImageNumber
   TmpImage = ImageArrayYFP_Reg(:,:,ImageNumber);
   MeanYFP(ImageNumber) = sum(TmpImage(Region1));
end