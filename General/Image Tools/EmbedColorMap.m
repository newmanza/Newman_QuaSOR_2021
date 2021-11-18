function Image_wColorMap=EmbedColorMap(Image,Orientation,Location,Height,Width,ColorLimits)
%Image=TempDeltaFF0;
Image_wColorMap=Image;
%Location=[120,80]
%Orientation=1;
%Height=20;
%Width=100;

DivisionSize=(ColorLimits(2)-ColorLimits(1))/Width;

for i=1:Width
    for j=1:Height
        CurrentPixel=[Location(2)+j,Location(1)+i];
        Image_wColorMap(CurrentPixel(1),CurrentPixel(2))=ColorLimits(1)+i*DivisionSize;
    end
end

%figure, imagesc(Image_wColorMap), axis equal tight, caxis(ColorLimits),colorbar

end
