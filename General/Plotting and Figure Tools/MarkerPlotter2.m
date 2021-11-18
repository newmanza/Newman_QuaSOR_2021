
function MarkerPlotter(StackSaveName,YLocation,YTextLocation,BinDimension,XMultiplier)
if exist([StackSaveName '_MarkerSet2.mat'])==2
    disp('Plotting marker')
    load([StackSaveName '_MarkerSet2.mat'],'MarkerSetInfo2')
    
    if ~isfield(MarkerSetInfo2,'MarkerTextOn')
        MarkerSetInfo2.MarkerTextOn=1;
    end
    
    if ~isfield(MarkerSetInfo2,'NumMarkers')
        MarkerSetInfo2.NumMarkers=size(MarkerSetInfo2.MarkerStarts);
    end
    
    for MarkerCount=1:MarkerSetInfo2.NumMarkers
        
        if BinDimension==1
            if MarkerSetInfo2.MarkerStyles(MarkerCount)==2
                if length(MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerYData)==1
                    plot([MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerXData*XMultiplier MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerXData*XMultiplier],[0,MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerYData*YLocation], 'LineWidth', MarkerSetInfo2.MarkerLineThickness(MarkerCount), 'color', MarkerSetInfo2.MarkerColors{MarkerCount},'LineStyle', MarkerSetInfo2.MarkerLineType{MarkerCount});
                else
                    plot([MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerXData*XMultiplier MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerXData*XMultiplier],MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerYData*YLocation, 'LineWidth', MarkerSetInfo2.MarkerLineThickness(MarkerCount), 'color', MarkerSetInfo2.MarkerColors{MarkerCount},'LineStyle', MarkerSetInfo2.MarkerLineType{MarkerCount});
                end
            elseif MarkerSetInfo2.MarkerStyles(MarkerCount)==3 %use a two element YLocation to define top and bottom of markers, this will not plot any horizontal distance
                plot([MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerXData*XMultiplier MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerXData*XMultiplier],[MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerYData*YLocation(1),MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerYData*YLocation(2)], 'LineWidth', MarkerSetInfo2.MarkerLineThickness(MarkerCount), 'color', MarkerSetInfo2.MarkerColors{MarkerCount},'LineStyle', MarkerSetInfo2.MarkerLineType{MarkerCount});
            elseif MarkerSetInfo2.MarkerStyles(MarkerCount)==1 
                plot(MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerXData*XMultiplier,MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerYData*YLocation, 'LineWidth', MarkerSetInfo2.MarkerLineThickness(MarkerCount), 'color', MarkerSetInfo2.MarkerColors{MarkerCount},'LineStyle', MarkerSetInfo2.MarkerLineType{MarkerCount});
            end
            if ~isempty(YTextLocation)
                if isempty(MarkerSetInfo2.MarkerLabels{MarkerCount})
                else
                    if MarkerSetInfo2.MarkerTextOn==1
                        text(MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerXData(1)*XMultiplier,YTextLocation,MarkerSetInfo2.MarkerLabels{MarkerCount},'FontSize',10);
                    end
                end
            end
        else
            if MarkerSetInfo2.MarkerStyles(MarkerCount)==2
                XCoord=[MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerXData*XMultiplier MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerXData*XMultiplier];
                XCoord=(XCoord+MarkerSetInfo2.XOffset)/BinDimension-MarkerSetInfo2.XOffset;
                plot(XCoord,MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerYData*YLocation, 'LineWidth', MarkerSetInfo2.MarkerLineThickness(MarkerCount), 'color', MarkerSetInfo2.MarkerColors{MarkerCount},'LineStyle', MarkerSetInfo2.MarkerLineType{MarkerCount});
            elseif MarkerSetInfo2.MarkerStyles(MarkerCount)==1 
                XCoord=MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerXData*XMultiplier;
                XCoord=(XCoord+MarkerSetInfo2.XOffset)/BinDimension-MarkerSetInfo2.XOffset;
                plot(XCoord,MarkerSetInfo2.MarkerSet{MarkerCount}.MarkerYData*YLocation, 'LineWidth', MarkerSetInfo2.MarkerLineThickness(MarkerCount), 'color', MarkerSetInfo2.MarkerColors{MarkerCount},'LineStyle', MarkerSetInfo2.MarkerLineType{MarkerCount});
            end
            if ~isempty(YTextLocation)
                if isempty(MarkerSetInfo2.MarkerLabels{MarkerCount})
                else
                    if MarkerSetInfo2.MarkerTextOn==1
                        text(XCoord(1)*XMultiplier,YTextLocation,MarkerSetInfo2.MarkerLabels{MarkerCount},'FontSize',10);
                    end
                end
            end
        end

    end
    
    
    
    set(gca,'children',flipud(get(gca,'children')))
else
end
end