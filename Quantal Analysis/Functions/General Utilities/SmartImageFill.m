function FilledImage=SmartImageFill(Image,XCoords,YCoords,FillImage)
%     
% Image=STORM_Images{length(STORM_Images)}.STORM_Image;
% XCoords=[1286 7536]
% YCoords=[144 6939]
% FillImage=ones(6250,6250);
error('DOESNT WORK!')

    XCoords=round(XCoords);
    YCoords=round(YCoords);
        
    ImageHeight=size(Image,1);
    ImageWidth=size(Image,2);
    ImageDepth=size(Image,3);
    FillImageHeight=size(FillImage,1);
    FillImageWidth=size(FillImage,2);
    FillImageDepth=size(FillImage,3);
    FilledImage=Image;
    
    
    Fill_XMin=1;
    Fill_XMax=XCoords(length(XCoords))-XCoords(1);
    Fill_YMin=1;
    Fill_YMax=YCoords(length(YCoords))-YCoords(1);
    
    Filling_XMin=XCoords(1)+1;
    if Filling_XMin<1
        Filling_XMin=1;
        Fill_XMin=abs(XCoords(1))+1;
    end
    
    Filling_XMax=XCoords(length(XCoords));
    if Filling_XMax>FillImageWidth
        Filling_XMax=FillImageWidth;
        Fill_XMax=length(Filling_XMin:Filling_XMax);
    end
    
    Filling_YMin=YCoords(1)+1;
    if Filling_YMin<1
        Filling_YMin=1;
        Fill_YMin=abs(YCoords(1))+1;
    end
    
    Filling_YMax=YCoords(length(YCoords));
    if Filling_YMax>ImageHeight
        Filling_YMax=FillImageHeight;
        Fill_YMax=length(Filling_YMin:Filling_YMax);
    end
    
    if Fill_XMax-Fill_XMin~=Filling_XMax-Filling_XMin
        error('Problem with X Coordinates')
    end
    if Fill_YMax-Fill_YMin~=Filling_YMax-Filling_YMin
        error('Problem with Y Coordinates')
    end
    
    if ImageDepth>1
        FilledImage(Filling_YMin:Filling_YMax,Filling_XMin:Filling_XMax,:)=FillImage(Fill_YMin:Fill_YMax,Fill_XMin:Fill_XMax,:);
    else
        FilledImage(Filling_YMin:Filling_YMax,Filling_XMin:Filling_XMax)=FillImage(Fill_YMin:Fill_YMax,Fill_XMin:Fill_XMax);
    end

end