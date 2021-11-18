
function [TempContrastedImage,TempContrastedImageColor,cMap_Contrasted]=Adjust_Contrast_and_Color_wMask(Temp,TempContrastLow,TempContrastHigh,ColorCode,ColorScalar,MaskIDNum,MaskColor)
    
    WarningStatus=warning;
    if isempty(ColorScalar)
        ColorScalar=1;
    end
    if length(MaskIDNum)==1
        [Mask_rows,Mask_cols,Mask_vals]=find(Temp==MaskIDNum);
        Temp(Temp==MaskIDNum)=0;
    else
        [Mask_rows,Mask_cols,Mask_vals]=find(Temp>=MaskIDNum(1) & Temp<MaskIDNum(2));
        Temp(Temp>=MaskIDNum(1) & Temp<MaskIDNum(2))=0;
    end
    if ColorScalar==1&&(TempContrastHigh-TempContrastLow)<10
        if strcmp(WarningStatus.state,'off')
            warning on
        end
        warning('Not enough colors deviations, increasing ColorScalar to accomodate!')
        if strcmp(WarningStatus.state,'off')
            warning off
        end
        ColorScalar=10;
    end
    if any(isnan(Temp(:)))&&any(~isnan(Temp(:)))
        if strcmp(WarningStatus.state,'off')
            warning on
        end
        warning('Some NaN values present Setting to Minimum Value!')
        if strcmp(WarningStatus.state,'off')
            warning off
        end
        %error('Some NaN values present!')
        Temp(isnan(Temp))=min(Temp(:));

    end
    if sum(Temp(:))==0||isnan(sum(Temp(:)))
%         if strcmp(WarningStatus.state,'off')
%             warning on
%         end
%          warning('Empty Input Image!');
%         if strcmp(WarningStatus.state,'off')
%             warning off
%         end
        TempContrastedImage=zeros(size(Temp,1),size(Temp,2));

        SavePixel(1)=TempContrastedImage(1,1);
        SavePixel(2)=TempContrastedImage(1,2);
        TempContrastedImage(1,1)=0;
        TempContrastedImage(1,2)=2;

        cMap_Contrasted=UniversalColorMap(ColorCode,0,2);

        TempContrastedImageColor = grs2rgb(round(TempContrastedImage),cMap_Contrasted);
        SavePixel(3)=0;
        SavePixel(4)=2;
        SavePixelContrastColor=grs2rgb(round(SavePixel),cMap_Contrasted);
        TempContrastedImageColor(1,1,:)=SavePixelContrastColor(1,1,:);
        TempContrastedImageColor(1,2,:)=SavePixelContrastColor(1,2,:);

    elseif TempContrastLow<0
        ValueAdjust=abs(TempContrastLow);
        TempContrastHigh=TempContrastHigh+ValueAdjust;
        TempContrastLow=TempContrastLow+ValueAdjust;
        Temp=Temp+ValueAdjust;
        TempContrastedImage=round(Temp*ColorScalar);
        TempContrastHigh=round(TempContrastHigh*ColorScalar);
        TempContrastLow=round(TempContrastLow*ColorScalar);
        TempContrastedImage(TempContrastedImage>=TempContrastHigh)=TempContrastHigh;
        TempContrastedImage(TempContrastedImage<=TempContrastLow)=TempContrastLow;
        TempContrastedImage=(TempContrastedImage-TempContrastLow);
        TempContrastedImage(TempContrastedImage<0)=0;
        SavePixel(1)=TempContrastedImage(1,1);
        SavePixel(2)=TempContrastedImage(1,2);
        TempContrastedImage(1,1)=TempContrastLow;
        TempContrastedImage(1,2)=TempContrastHigh;

        cMap_Contrasted=UniversalColorMap(ColorCode,TempContrastLow,TempContrastHigh);

        TempContrastedImageColor = grs2rgb(round(TempContrastedImage),cMap_Contrasted);
        SavePixel(3)=0;
        SavePixel(4)=round(TempContrastHigh-TempContrastLow);
        SavePixelContrastColor=grs2rgb(round(SavePixel),cMap_Contrasted);
        TempContrastedImageColor(1,1,:)=SavePixelContrastColor(1,1,:);
        TempContrastedImageColor(1,2,:)=SavePixelContrastColor(1,2,:);
    
    else
        TempContrastedImage=round(Temp*ColorScalar);
        TempContrastHigh=round(TempContrastHigh*ColorScalar);
        TempContrastLow=round(TempContrastLow*ColorScalar);
        TempContrastedImage(TempContrastedImage>=TempContrastHigh)=TempContrastHigh;
        TempContrastedImage(TempContrastedImage<=TempContrastLow)=TempContrastLow;
        TempContrastedImage=(TempContrastedImage-TempContrastLow);
        TempContrastedImage(TempContrastedImage<0)=0;
        SavePixel(1)=TempContrastedImage(1,1);
        SavePixel(2)=TempContrastedImage(1,2);
        TempContrastedImage(1,1)=TempContrastLow;
        TempContrastedImage(1,2)=TempContrastHigh;

        cMap_Contrasted=UniversalColorMap(ColorCode,TempContrastLow,TempContrastHigh);

        TempContrastedImageColor = grs2rgb(round(TempContrastedImage),cMap_Contrasted);
        SavePixel(3)=0;
        SavePixel(4)=round(TempContrastHigh-TempContrastLow);
        SavePixelContrastColor=grs2rgb(round(SavePixel),cMap_Contrasted);
        TempContrastedImageColor(1,1,:)=SavePixelContrastColor(1,1,:);
        TempContrastedImageColor(1,2,:)=SavePixelContrastColor(1,2,:);
    end
    for i=1:length(Mask_rows)
        TempContrastedImageColor(Mask_rows(i),Mask_cols(i),:)=MaskColor;
    end
    
end
