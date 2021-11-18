function [OutputArray]=String2Array(InputString)

    NumChar=(length(InputString)-1)/2;
    OutputArray=[];
    
    for i=1:NumChar
        TempDigit=str2num(InputString(i*2));
            OutputArray(i)=TempDigit;
    end
    
end