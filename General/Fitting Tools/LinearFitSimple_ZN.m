function DataStructure=LinearFitSimple_ZN(Xdata,Ydata)

    if size(Xdata,1)<=1&&size(Xdata,2)<=1&&size(Ydata,1)<=1&&size(Ydata,2)<=1
        warning('Need to provide more than one data point to fit!')
        DataStructure=[];
    elseif size(Xdata,1)~=size(Ydata,1)||size(Xdata,2)~=size(Ydata,2)
        warning('Need to provide equal sized input arrays!')
        DataStructure=[];
    else

         %R
         %[DataStructure.CorrelationCoefficient,DataStructure.Correlation_p]=corrcoef(Xdata,Ydata);

        
        DataStructure.FitValues=Xdata\Ydata;
        DataStructure.FitXValues=0:0.01:max(Xdata);
        for count=1:length(DataStructure.FitXValues) 
            DataStructure.FitYValues(count)=DataStructure.FitValues*DataStructure.FitXValues(count);
        end
        for count=1:size(Xdata)
            DataStructure.YValueResidual(count)=Ydata(count)-(DataStructure.FitValues*Xdata(count));
        end
        
         DataStructure.SSresid = sum(DataStructure.YValueResidual.^2);
         DataStructure.SStotal = (length(Ydata)-1) * var(Ydata);
         DataStructure.RSqu = 1 - DataStructure.SSresid/DataStructure.SStotal;
         DataStructure.RSqu_Adjusted=1 - DataStructure.SSresid/DataStructure.SStotal * (length(Ydata)-1)/(length(Ydata)-length(Xdata)-1);
 
         DataStructure.FitEquation = strcat('y=',num2str(DataStructure.FitValues,3),'x');
         DataStructure.RSquared = strcat('R2 value: ',num2str(DataStructure.RSqu,3));
         %DataStructure.RValue = strcat('Corr Coeff: ',num2str(DataStructure.CorrelationCoefficient(1,2),3));

    end
end




