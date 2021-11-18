
function MarkerPlotter(StackSaveName,YLocation,YTextLocation,BinDimension,XMultiplier)
if exist([StackSaveName '_MarkerSet.mat'])==2
    %disp('Plotting marker')
    load([StackSaveName '_MarkerSet.mat'],'MarkerSetInfo')
    try
    if ~isfield(MarkerSetInfo,'MarkerTextOn')
        MarkerSetInfo.MarkerTextOn=1;
    end
    
    if ~isfield(MarkerSetInfo,'NumMarkers')
        MarkerSetInfo.NumMarkers=size(MarkerSetInfo.MarkerStarts);
    end
    
    for MarkerCount=1:MarkerSetInfo.NumMarkers
        
        if BinDimension==1
            if MarkerSetInfo.MarkerStyles(MarkerCount)==2
                if length(MarkerSetInfo.MarkerSet{MarkerCount}.MarkerYData)==1
                    plot([MarkerSetInfo.MarkerSet{MarkerCount}.MarkerXData*XMultiplier MarkerSetInfo.MarkerSet{MarkerCount}.MarkerXData*XMultiplier],[0,MarkerSetInfo.MarkerSet{MarkerCount}.MarkerYData*YLocation], 'LineWidth', MarkerSetInfo.MarkerLineThickness(MarkerCount), 'color', MarkerSetInfo.MarkerColors{MarkerCount},'LineStyle', MarkerSetInfo.MarkerLineType{MarkerCount});
                else
                    plot([MarkerSetInfo.MarkerSet{MarkerCount}.MarkerXData*XMultiplier MarkerSetInfo.MarkerSet{MarkerCount}.MarkerXData*XMultiplier],MarkerSetInfo.MarkerSet{MarkerCount}.MarkerYData*YLocation, 'LineWidth', MarkerSetInfo.MarkerLineThickness(MarkerCount), 'color', MarkerSetInfo.MarkerColors{MarkerCount},'LineStyle', MarkerSetInfo.MarkerLineType{MarkerCount});
                end
            elseif MarkerSetInfo.MarkerStyles(MarkerCount)==3 %use a two element YLocation to define top and bottom of markers, this will not plot any horizontal distance
                plot([MarkerSetInfo.MarkerSet{MarkerCount}.MarkerXData*XMultiplier MarkerSetInfo.MarkerSet{MarkerCount}.MarkerXData*XMultiplier],[MarkerSetInfo.MarkerSet{MarkerCount}.MarkerYData*YLocation(1),MarkerSetInfo.MarkerSet{MarkerCount}.MarkerYData*YLocation(2)], 'LineWidth', MarkerSetInfo.MarkerLineThickness(MarkerCount), 'color', MarkerSetInfo.MarkerColors{MarkerCount},'LineStyle', MarkerSetInfo.MarkerLineType{MarkerCount});
            elseif MarkerSetInfo.MarkerStyles(MarkerCount)==1 
                plot(MarkerSetInfo.MarkerSet{MarkerCount}.MarkerXData*XMultiplier,MarkerSetInfo.MarkerSet{MarkerCount}.MarkerYData*YLocation, 'LineWidth', MarkerSetInfo.MarkerLineThickness(MarkerCount), 'color', MarkerSetInfo.MarkerColors{MarkerCount},'LineStyle', MarkerSetInfo.MarkerLineType{MarkerCount});
            end
            if ~isempty(YTextLocation)
                if isempty(MarkerSetInfo.MarkerLabels{MarkerCount})
                else
                    if MarkerSetInfo.MarkerTextOn==1
                        text(MarkerSetInfo.MarkerSet{MarkerCount}.MarkerXData(1)*XMultiplier,YTextLocation,MarkerSetInfo.MarkerLabels{MarkerCount},'FontSize',10);
                    end
                end
            end
        else
            if MarkerSetInfo.MarkerStyles(MarkerCount)==2
                XCoord=[MarkerSetInfo.MarkerSet{MarkerCount}.MarkerXData*XMultiplier MarkerSetInfo.MarkerSet{MarkerCount}.MarkerXData*XMultiplier];
                XCoord=(XCoord+MarkerSetInfo.XOffset)/BinDimension-MarkerSetInfo.XOffset;
                plot(XCoord,MarkerSetInfo.MarkerSet{MarkerCount}.MarkerYData*YLocation, 'LineWidth', MarkerSetInfo.MarkerLineThickness(MarkerCount), 'color', MarkerSetInfo.MarkerColors{MarkerCount},'LineStyle', MarkerSetInfo.MarkerLineType{MarkerCount});
            elseif MarkerSetInfo.MarkerStyles(MarkerCount)==1 
                XCoord=MarkerSetInfo.MarkerSet{MarkerCount}.MarkerXData*XMultiplier;
                XCoord=(XCoord+MarkerSetInfo.XOffset)/BinDimension-MarkerSetInfo.XOffset;
                plot(XCoord,MarkerSetInfo.MarkerSet{MarkerCount}.MarkerYData*YLocation, 'LineWidth', MarkerSetInfo.MarkerLineThickness(MarkerCount), 'color', MarkerSetInfo.MarkerColors{MarkerCount},'LineStyle', MarkerSetInfo.MarkerLineType{MarkerCount});
            end
            if ~isempty(YTextLocation)
                if isempty(MarkerSetInfo.MarkerLabels{MarkerCount})
                else
                    if MarkerSetInfo.MarkerTextOn==1
                        text(XCoord(1)*XMultiplier,YTextLocation,MarkerSetInfo.MarkerLabels{MarkerCount},'FontSize',10);
                    end
                end
            end
        end

    end
    
    
    
    set(gca,'children',flipud(get(gca,'children')))
    catch
       warning on
       warning('Unable to plot marker!')
    end
    
else
end
end