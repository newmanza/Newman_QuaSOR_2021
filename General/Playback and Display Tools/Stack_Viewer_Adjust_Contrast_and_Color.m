function [ContrastedImageColor]=...
    Stack_Viewer_Adjust_Contrast_and_Color(InputImage,cMap_Contrasted,ContrastLow,ContrastHigh,ValueAdjust,ColorScalar)

    if any(isnan(InputImage(:)))
        InputImage(isnan(InputImage))=min(InputImage(:));
    end
    ContrastedImage=single(round((InputImage+ValueAdjust)*ColorScalar)+1);
    ContrastedImage(ContrastedImage>=ContrastHigh)=ContrastHigh;
    ContrastedImage(ContrastedImage<=ContrastLow)=ContrastLow;
    ContrastedImage=(ContrastedImage-ContrastLow);
    ContrastedImage(ContrastedImage<=0)=1;
    SavePixel(1)=ContrastedImage(1,1);
    SavePixel(2)=ContrastedImage(1,2);
    SavePixel(3)=1;
    SavePixel(4)=round(ContrastHigh-ContrastLow);
    ContrastedImage(1,1)=1;
    ContrastedImage(1,2)=round(ContrastHigh-ContrastLow);

    [l,~] = size(cMap_Contrasted);
    ci = ceil(l*ContrastedImage/max(ContrastedImage(:))); 
    ci(isnan(ci))=1;
    [il,iw] = size(ContrastedImage);
    r = zeros(il,iw,'single'); 
    g = zeros(il,iw,'single');
    b = zeros(il,iw,'single');
    r(:) = cMap_Contrasted(ci,1);
    g(:) = cMap_Contrasted(ci,2);
    b(:) = cMap_Contrasted(ci,3);
    ContrastedImageColor = zeros(il,iw,3,'single');
    ContrastedImageColor(:,:,1) = r; 
    ContrastedImageColor(:,:,2) = g; 
    ContrastedImageColor(:,:,3) = b;

    ci = ceil(l*SavePixel/max(SavePixel(:))); 
    ci(isnan(ci))=1;
    [il,iw] = size(SavePixel);
    r = zeros(il,iw,'single'); 
    g = zeros(il,iw,'single');
    b = zeros(il,iw,'single');
    r(:) = cMap_Contrasted(ci,1);
    g(:) = cMap_Contrasted(ci,2);
    b(:) = cMap_Contrasted(ci,3);
    SavePixelContrastColor = zeros(il,iw,3,'single');
    SavePixelContrastColor(:,:,1) = r; 
    SavePixelContrastColor(:,:,2) = g; 
    SavePixelContrastColor(:,:,3) = b;

    ContrastedImageColor(1,1,:)=SavePixelContrastColor(1,1,:);
    ContrastedImageColor(1,2,:)=SavePixelContrastColor(1,2,:);
end
