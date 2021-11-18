function cMap=UniversalColorMap(ColorCode,TempContrastLow,TempContrastHigh)
    if (TempContrastHigh-TempContrastLow)<=0
        warning on
        warning('Provide UniversalColorMap with separated contrast values!')
        error('Provide UniversalColorMap with separated contrast values!')
    end
    if ischar(ColorCode)
        if length(ColorCode)==1
            cMap=makeColorMap([0 0 0],ColorDefinitions(ColorCode),round(TempContrastHigh-TempContrastLow));
        else
            if any(contains(ColorCode,'gray'))||any(contains(ColorCode,'grays'))
                cMap=gray(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'jet'))
                cMap=jet(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'parula'))
                cMap=parula(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'hsv'))
                cMap=hsv(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'hot'))
                cMap=hot(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'cool'))
                cMap=cool(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'spring'))
                cMap=spring(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'summer'))
                cMap=summer(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'autumn'))
                cMap=autumn(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'winter'))
                cMap=winter(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'bone'))
                cMap=bone(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'copper'))
                cMap=copper(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'pink'))
                cMap=pink(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'lines'))
                cMap=lines(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'colorcube'))
                cMap=colorcube(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'prism'))
                cMap=prism(round(TempContrastHigh-TempContrastLow));
            elseif any(contains(ColorCode,'flag'))
                cMap=flag(round(TempContrastHigh-TempContrastLow));
            else
                warning('Missing Color Code Needs to be [0,1,1], r or jet/parula/hot/gray')
                error('Fix Color Code...')
            end
        end
    elseif length(ColorCode)==3
        cMap=makeColorMap([0 0 0],ColorCode,round(TempContrastHigh-TempContrastLow));
    else
        warning('Missing Color Code Needs to be [0,1,1], r or jet/parula/hot/gray')
        error('Fix Color Code...')
    end
end

