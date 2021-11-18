function Image_Contrast=ContrastImage(Image,LowPercent,HighPercent,BitDepth)

Temp=Image;

Image_Max=max(Image(:));
Image_Min=min(Image(:));
ContrastHigh=Image_Max-HighPercent*Image_Max;
ContrastLow=Image_Min-LowPercent*Image_Min;



        Temp(Temp>=ContrastHigh)=ContrastHigh;
        Temp(Temp<=ContrastLow)=ContrastLow;
        Temp=(Temp-ContrastLow);
        TempNorm=double(Temp);
        TempNorm=TempNorm/max(max(TempNorm));
        TempNorm=TempNorm*(2^BitDepth);
        Image_Contrast=single(TempNorm);
        

        
end
