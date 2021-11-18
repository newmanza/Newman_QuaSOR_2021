function Log3DPlotZeroCorrection(TempXData,TempYData,TempZData,Input_Color_Map,MarkerSize_3D,AdjustRatio)
    warning on all
    warning off verbose
    warning off backtrace
    if length(size(Input_Color_Map))>2
        for i=1:size(TempXData,2)
            Color_Map(i,:)=horzcat(Input_Color_Map(1,i,:));
        end
    else
        Color_Map=Input_Color_Map;
    end
    
    if min(TempXData)<=0
        warning('X data has a zero, fixing...')
        TempXData_NaN=TempXData;
        TempXData_NaN(TempXData_NaN==0)=NaN;
        MinXNotZero=min(TempXData_NaN);
        MinXNotZeroLog=log10(MinXNotZero);
        MinXZeroLog=floor(MinXNotZeroLog);
        MinXZero=10^MinXZeroLog;
        TempXData_ZeroFix=TempXData_NaN;
        MinXZeroAdjust=MinXZero*AdjustRatio;
        TempXData_ZeroFix(isnan(TempXData_ZeroFix))=MinXZeroAdjust;
    else
        TempXData_NaN=TempXData;
        TempXData_ZeroFix=TempXData;
    end

    if min(TempYData)<=0
        warning('Y data has a zero, fixing...')
        TempYData_NaN=TempYData;
        TempYData_NaN(TempYData_NaN==0)=NaN;
        MinYNotZero=min(TempYData_NaN);
        MinYNotZeroLog=log10(MinYNotZero);
        MinYZeroLog=floor(MinYNotZeroLog);
        MinYZero=10^MinYZeroLog;
        MinYZeroAdjust=MinYZero*AdjustRatio;
        TempYData_ZeroFix=TempYData_NaN;
        TempYData_ZeroFix(isnan(TempYData_ZeroFix))=MinYZeroAdjust;
    else
        TempYData_NaN=TempYData;
        TempYData_ZeroFix=TempYData;
    end

    if min(TempZData)<=0
        warning('Z data has a zero, fixing...')
        TempZData_NaN=TempZData;
        TempZData_NaN(TempZData_NaN==0)=NaN;
        MinZNotZero=min(TempZData_NaN);
        MinZNotZeroLog=log10(MinZNotZero);
        MinZZeroLog=floor(MinZNotZeroLog);
        MinZZero=10^MinZZeroLog;
        MinZZeroAdjust=MinZZero*AdjustRatio;
        TempZData_ZeroFix=TempZData_NaN;
        TempZData_ZeroFix(isnan(TempZData_ZeroFix))=MinZZeroAdjust;
    else
        TempZData_NaN=TempZData;
        TempZData_ZeroFix=TempZData;
    end
    hold on
    for i=1:length(TempZData_ZeroFix)
        if isnan(TempXData_NaN(i))||isnan(TempYData_NaN(i))||isnan(TempZData_NaN(i))
            if ~isempty(Color_Map)
                p=plot3(TempXData_ZeroFix(i),TempYData_ZeroFix(i),TempZData_ZeroFix(i),...
                    'o','color',Color_Map(i,:),'markersize',MarkerSize_3D/2);
            else
                p=plot3(TempXData_ZeroFix(i),TempYData_ZeroFix(i),TempZData_ZeroFix(i),...
                    'o','color','k','markersize',MarkerSize_3D/2);
            end
        else
            if ~isempty(Color_Map)
                p=plot3(TempXData_ZeroFix(i),TempYData_ZeroFix(i),TempZData_ZeroFix(i),...
                    '.','color',Color_Map(i,:),'markersize',MarkerSize_3D);
            else
                p=plot3(TempXData_ZeroFix(i),TempYData_ZeroFix(i),TempZData_ZeroFix(i),...
                    '.','color','k','markersize',MarkerSize_3D);
            end
        end
    end
end
