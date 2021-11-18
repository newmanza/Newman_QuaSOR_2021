function [Mean_Out, STD_Out, SEM_Out, Num_Out]=Mean_STD_SEM2(MeanDimension,InputData)

    InputData(InputData==Inf)=NaN;

    if any(isnan(InputData(:)))
        Mean_Out=nanmean(InputData,MeanDimension);
        STD_Out=nanstd(InputData,0,MeanDimension);
        Num_Out=sum(~isnan(InputData));
        SEM_Out=STD_Out./sqrt(Num_Out);
    else
        Mean_Out=mean(InputData,MeanDimension);
        STD_Out=std(InputData,0,MeanDimension);
        Num_Out=size(InputData,MeanDimension);
        SEM_Out=STD_Out./sqrt(Num_Out);
    end
end