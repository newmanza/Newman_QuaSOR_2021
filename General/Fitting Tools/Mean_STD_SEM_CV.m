function [Mean_Out, STD_Out, SEM_Out, CV_Out, Num_Out]=Mean_STD_SEM_CV(InputData)

    InputData(InputData==Inf)=NaN;

    if any(isnan(InputData(:)))
        Mean_Out=nanmean(InputData);
        STD_Out=nanstd(InputData);
        Num_Out=sum(~isnan(InputData));
        SEM_Out=STD_Out./sqrt(Num_Out);
        CV_Out=STD_Out./Mean_Out;
    else
        Mean_Out=mean(InputData);
        STD_Out=std(InputData);
        if size(InputData,1)>size(InputData,2)
            Num_Out=size(InputData,1);
        else
            Num_Out=size(InputData,2);
        end
        SEM_Out=STD_Out./sqrt(Num_Out);
        CV_Out=STD_Out./Mean_Out;
    end
end