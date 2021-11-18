function [ColorBarMin,ColorBarMax]=ColorBarMaxMin(ImageData,sigDig)

TempMax=max(max(ImageData));
TempMin=min(min(ImageData));

if TempMax==0
    ColorBarMax=0;
elseif abs(TempMax)<1
    ColorBarMax=roundsd(TempMax,sigDig,'floor');
else
    ColorBarMax=TempMax;
end
if TempMin==0
    ColorBarMin=0;
elseif abs(TempMin)<1
    ColorBarMin=roundsd(TempMin,sigDig,'ceil');
else
    ColorBarMin=TempMin;
end


end