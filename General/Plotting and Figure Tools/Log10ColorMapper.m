function [OutputColorMap]=Log10ColorMapper(InputData,InputColorMap)
    InputData=(log10(InputData));
    MinData=min(InputData(:));
    MaxData=max(InputData(:));
    MinData1=abs(MinData-MinData);
    MaxData1=abs(MaxData-MinData);
    InputData1=abs(InputData-MinData);
    if MaxData==MinData
        warning on
        warning('No separation for colormap, trying to fix!')
        MaxData=MaxData+1;
    end
    L = size(InputColorMap,1);
    Map_s = round(interp1(linspace(MinData1,MaxData1,L),1:L,InputData1));
    OutputColorMap = reshape(InputColorMap(Map_s,:),[size(Map_s) 3]);
end