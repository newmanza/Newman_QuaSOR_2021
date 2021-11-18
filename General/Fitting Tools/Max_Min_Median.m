function [Max_Out, Min_Out, Median_Out]=Max_Min_Median(InputData)

    InputData(InputData==Inf)=NaN;
        
    InputData_Clean=[];
    
    if size(InputData,1)>size(InputData,2)
        for i=1:size(InputData,1)
            if ~isnan(InputData(i,1))
                InputData_Clean=[InputData_Clean,InputData(i,1)];
            end
        end
    else
        for i=1:size(InputData,2)
            if ~isnan(InputData(1,i))
                InputData_Clean=[InputData_Clean,InputData(1,i)];
            end
        end
    end

    Max_Out=max(InputData);
    Min_Out=min(InputData);
    Median_Out=median(InputData);
end