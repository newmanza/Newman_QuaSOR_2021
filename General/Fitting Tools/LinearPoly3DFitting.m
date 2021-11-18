function [FitDetails]=LinearPoly3DFitting(TempXData,TempYData,TempZData)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    clear FitDetails


    FitDetails.XRange=[min(TempXData(:)):max(TempXData(:))/1000:max(TempXData(:))];
    FitDetails.YRange=[min(TempYData(:)):max(TempYData(:))/1000:max(TempYData(:))];
    [FitDetails.SurfaceXData,FitDetails.SurfaceYData]=meshgrid(FitDetails.XRange,FitDetails.YRange);

    XMax=max(TempXData(:));
    YMax=max(TempYData(:));
    ZMax=max(TempZData(:));
    XMin=min(TempXData(:));
    YMin=min(TempYData(:));
    ZMin=min(TempZData(:));
    
    if any(isnan(TempXData))
        warning on
        warning('X value NaN, setting to zero!')
    end
    if any(isnan(TempYData))
        warning on
        warning('Y value NaN, setting to zero!')
    end
    if any(isnan(TempZData))
        warning on
        warning('Z value NaN, setting to zero!')
    end    
    
    TempXData_NoNaN=TempXData;
    TempXData_NoNaN(isnan(TempXData_NoNaN))=0;
    TempYData_NoNaN=TempYData;
    TempYData_NoNaN(isnan(TempYData_NoNaN))=0;
    TempZData_NoNaN=TempZData;
    TempZData_NoNaN(isnan(TempZData_NoNaN))=0;
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FitDetails.FitType(1).Label='Linear Polynomial Surface';
    [FitDetails.FitType(1).FitObject,...
        FitDetails.FitType(1).GoodnessOfFit,...
        FitDetails.FitType(1).Output]=...
        fit([TempXData_NoNaN',TempYData_NoNaN'],TempZData_NoNaN','poly11');
%     FitDetails.FitType(1).Label
%     FitDetails.FitType(1).FitObject
%     FitDetails.FitType(1).GoodnessOfFit
%     FitDetails.FitType(1).Output
    FitDetails.FitType(1).SurfaceZData=...
        FitDetails.FitType(1).FitObject.p00 + ...
        FitDetails.FitType(1).FitObject.p10*FitDetails.SurfaceXData + ...
        FitDetails.FitType(1).FitObject.p01*FitDetails.SurfaceYData;
    FitDetails.FitType(1).SurfaceEquation=...
        ['z=',num2str(FitDetails.FitType(1).FitObject.p00),'+',...
        num2str(FitDetails.FitType(1).FitObject.p10),'x+',...
        num2str(FitDetails.FitType(1).FitObject.p01),'y'];

 
end


