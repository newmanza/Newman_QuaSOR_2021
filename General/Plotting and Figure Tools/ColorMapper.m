function [OutputColorMap]=ColorMapper(InputData,InputColorMap)

    MinData=min(InputData(:));
    MaxData=max(InputData(:));
    if MaxData==MinData
        warning on
        warning('No separation for colormap, trying to fix!')
        MaxData=MaxData+1;
    end
    L = size(InputColorMap,1);
    Map_s = round(interp1(linspace(MinData,MaxData,L),1:L,InputData));
    OutputColorMap = reshape(InputColorMap(Map_s,:),[size(Map_s) 3]);
end