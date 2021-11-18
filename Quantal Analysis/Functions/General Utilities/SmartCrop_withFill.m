function Image_Crop=SmartCrop_withFill(Image,Crop_XCoords,Crop_YCoords,FillValue)
%     
% Image=UltraHighRes_Contrasted_Color_Merge_ROI_Overlay;
% Crop_XCoords=[-100,3000]
% Crop_YCoords=[-400,2700]
% FillValue=[0.5,0.5,0.5]


    Crop_XCoords=round(Crop_XCoords);
    Crop_YCoords=round(Crop_YCoords);
        
    ImageHeight=size(Image,1);
    ImageWidth=size(Image,2);
    ImageDepth=size(Image,3);
    
    Image_Crop=ones(Crop_YCoords(length(Crop_YCoords))-Crop_YCoords(1),Crop_XCoords(length(Crop_XCoords))-Crop_XCoords(1),ImageDepth);
    
    if length(FillValue)==1
        Image_Crop=Image_Crop*FillValue;
    else
        Image_Crop(:,:,1)=Image_Crop(:,:,1)*FillValue(1);
        Image_Crop(:,:,2)=Image_Crop(:,:,2)*FillValue(2);
        Image_Crop(:,:,3)=Image_Crop(:,:,3)*FillValue(3);
    end
    
    Crop_XMin=1;
    Crop_XMax=Crop_XCoords(length(Crop_XCoords))-Crop_XCoords(1);
    Crop_YMin=1;
    Crop_YMax=Crop_YCoords(length(Crop_YCoords))-Crop_YCoords(1);
    
    Fixed_XMin=Crop_XCoords(1)+1;
    if Fixed_XMin<1
        Fixed_XMin=1;
        Crop_XMin=abs(Crop_XCoords(1))+1;
    end
    
    Fixed_XMax=Crop_XCoords(length(Crop_XCoords));
    if Fixed_XMax>ImageWidth
        Fixed_XMax=ImageWidth;
        Crop_XMax=length(Fixed_XMin:Fixed_XMax);
    end
    
    Fixed_YMin=Crop_YCoords(1)+1;
    if Fixed_YMin<1
        Fixed_YMin=1;
        Crop_YMin=abs(Crop_YCoords(1))+1;
    end
    
    Fixed_YMax=Crop_YCoords(length(Crop_YCoords));
    if Fixed_YMax>ImageHeight
        Fixed_YMax=ImageHeight;
        Crop_YMax=length(Fixed_YMin:Fixed_YMax);
    end
    
    if Crop_XMax-Crop_XMin~=Fixed_XMax-Fixed_XMin
        error('Problem with X Coordinates')
    end
    if Crop_YMax-Crop_YMin~=Fixed_YMax-Fixed_YMin
        error('Problem with Y Coordinates')
    end
    
    if ImageDepth>1
        Image_Crop(Crop_YMin:Crop_YMax,Crop_XMin:Crop_XMax,:)=Image(Fixed_YMin:Fixed_YMax,Fixed_XMin:Fixed_XMax,:);
    else
        Image_Crop(Crop_YMin:Crop_YMax,Crop_XMin:Crop_XMax)=Image(Fixed_YMin:Fixed_YMax,Fixed_XMin:Fixed_XMax);
    end

end