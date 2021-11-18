function frameOut = Zach_enhanceContrastForDemon(inputFrame,weinerParams,openParams,StretchLimParams)  
          
    frameIn=inputFrame;
    if isempty(StretchLimParams)
        StretchLimParams=[0.01,0.99];
    end
    frameInA = imadjust(frameIn,stretchlim(frameIn,StretchLimParams));

    frameIn = wiener2(frameInA,weinerParams);
%             frameIn = imhistmatch(frameIn,refContrast);
    background = imopen(frameIn,strel('disk',openParams));
%             H = fspecial('disk',60);
%             background = imfilter(background,H,'replicate');
    %frameIn = frameInA - background;
    frameIn = uint16(double(frameInA) - double(background));
    frameIn = imadjust(frameIn,stretchlim(frameIn,StretchLimParams));
    frameIn = wiener2(frameIn,weinerParams);
    frameOut=double(frameIn);
%             imshow(frameOut)

end