function Image_Crop=SmartCrop(Image,Crop_XCoords,Crop_YCoords)
    Crop_XCoords=round(Crop_XCoords);
    Crop_YCoords=round(Crop_YCoords);
    ImageHeight=size(Image,1);
    ImageWidth=size(Image,2);
    ImageDepth=size(Image,3);

    Fixed_XMin=Crop_XCoords(1);
    if Fixed_XMin<1
        Fixed_XMin=1;
    end
    Fixed_XMax=Crop_XCoords(length(Crop_XCoords));
    if Fixed_XMin>ImageWidth
        Fixed_XMin=ImageWidth;
    end
    Fixed_YMin=Crop_YCoords(1);
    if Fixed_YMin<1
        Fixed_YMin=1;
    end
    Fixed_YMax=Crop_YCoords(length(Crop_YCoords));
    if Fixed_YMin>ImageHeight
        Fixed_YMin=ImageHeight;
    end
    if ImageDepth>1
        Image_Crop=Image(Fixed_YMin:1:Fixed_YMax,Fixed_XMin:1:Fixed_XMax,:);
    else
        Image_Crop=Image(Fixed_YMin:1:Fixed_YMax,Fixed_XMin:1:Fixed_XMax);
    end



end