function [OutputArray]=String2Array3(InputString)
    %Handles Negatives and Decimals
       
    NumChar=length(InputString);
    OutputArray=[];
    Count=0;
    position=2;
    NegVal=0;
    DecimalCount=0;
    DecimalOn=0;
    while position<=NumChar
        isvalue=1;
        CurrentNum=[];
        while isvalue
            CurrentValue=str2num(InputString(position));
            if ~isempty(CurrentValue)
                isvalue=1;
                CurrentNum=horzcat(CurrentNum,num2str(CurrentValue));
                if DecimalOn
                    DecimalCount=DecimalCount+1;
                end
            else
                if strcmp(InputString(position),'-')
                    NegVal=1;
                elseif strcmp(InputString(position),'.')
                    DecimalOn=1;
                else
                    isvalue=0;
                    Count=Count+1;
                    if ~DecimalOn
                        if NegVal
                            OutputArray(Count)=str2num(CurrentNum)*-1;
                        else
                            OutputArray(Count)=str2num(CurrentNum);
                        end
                    else
                        if NegVal
                            OutputArray(Count)=str2num(CurrentNum)*-1*10^(-1*DecimalCount);
                        else
                            OutputArray(Count)=str2num(CurrentNum)*10^(-1*DecimalCount);
                        end
                    end
                    NegVal=0;
                    DecimalCount=0;
                    DecimalOn=0;
                end
            end
            position=position+1;
        end
    end
    
end