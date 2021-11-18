                
function [BorderLine]=FindROIBorders(Region,DilateRegion)
    BorderLine=[];
    if ~isempty(DilateRegion)
        [B,L] = bwboundaries(imdilate(logical(Region),DilateRegion),'noholes');
    else
        [B,L] = bwboundaries(logical(Region),'noholes');
    end
    for j=1:length(B)
        for k = 1:length(B{j})
            BorderLine{j}.BorderLine(k,:) = B{j}(k,:);
        end
    end
end
