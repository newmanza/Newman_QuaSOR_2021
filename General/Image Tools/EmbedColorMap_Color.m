function Image_wColorMap=EmbedColorMap_Color(Image,Orientation,Location,Height,Width,ColorLimits,ColorMap)
%Image=TempDeltaFF0;
Image_wColorMap=Image;
%Location=[120,80]
%Orientation=1;
%Height=20;
%Width=100;
if Orientation==1
    DivisionSize=(ColorLimits(2)-ColorLimits(1))/Width;
    NumDivisions=Width;
else
    DivisionSize=(ColorLimits(2)-ColorLimits(1))/Height;
    NumDivisions=Height;
end

        if ischar(ColorMap)
            if length(ColorMap)==1
                Temp_cMap=makeColorMap([0 0 0],ColorDefinitions(ColorMap),NumDivisions);
            else
                if any(contains(ColorMap,'jet'))
                    Temp_cMap=jet(NumDivisions);
                elseif any(contains(ColorMap,'parula'))
                    Temp_cMap=parula(NumDivisions);
                elseif any(contains(ColorMap,'hot'))
                    Temp_cMap=hot(NumDivisions);
                elseif any(contains(ColorMap,'cool'))
                    Temp_cMap=cool(NumDivisions);
                elseif any(contains(ColorMap,'spring'))
                    Temp_cMap=spring(NumDivisions);
                elseif any(contains(ColorMap,'summer'))
                    Temp_cMap=summer(NumDivisions);
                elseif any(contains(ColorMap,'autumn'))
                    Temp_cMap=autumn(NumDivisions);
                elseif any(contains(ColorMap,'winter'))
                    Temp_cMap=winter(NumDivisions);
                elseif any(contains(ColorMap,'gray'))||any(contains(ColorMap,'grays'))
                    Temp_cMap=gray(NumDivisions);
                else
                    warning('Missing Color Code Needs to be [0,1,1], r or jet/parula/hot/gray')
                    error('Fix Color Code...')
                end
            end
        elseif length(ColorMap)==3
            Temp_cMap=makeColorMap([0 0 0],ColorMap,NumDivisions);
        else
            warning('Missing Color Code Needs to be [0,1,1], r or jet/parula/hot/gray')
            error('Fix Color Code...')
        end

if Orientation==1
    for i=1:Width
        for j=1:Height
            CurrentPixel=[Location(2)+j,Location(1)+i];
            Image_wColorMap(CurrentPixel(1),CurrentPixel(2),:)=Temp_cMap(i,:);
        end
    end
else
    for i=1:Width
        for j=1:Height
            CurrentPixel=[Location(2)+j,Location(1)+i];
            Image_wColorMap(CurrentPixel(1),CurrentPixel(2),:)=Temp_cMap(j,:);
        end
    end
end

%figure, imagesc(Image_wColorMap), axis equal tight, caxis(ColorLimits),colorbar

end
