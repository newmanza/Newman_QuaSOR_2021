function [OutputArray]=String2Array2(InputString)

    NumChar=length(InputString);
    OutputArray=[];
    if strcmp(InputString,'[]')
        OutputArray=[];
    else
        Count=0;
        position=2;
        while position<=NumChar
            isvalue=1;
            CurrentNum=[];
            while isvalue
                CurrentValue=str2num(InputString(position));
                if ~isempty(CurrentValue)
                    isvalue=1;
                    CurrentNum=horzcat(CurrentNum,num2str(CurrentValue));
                else
                    isvalue=0;
                    Count=Count+1;
                    OutputArray(Count)=str2num(CurrentNum);
                end
                position=position+1;
            end
        end
    end
end