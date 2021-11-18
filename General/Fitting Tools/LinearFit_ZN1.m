function DataStructure=LinearFit_ZN1(Xdata,Ydata)
    if size(Xdata,1)<=1&&size(Xdata,2)<=1&&size(Ydata,1)<=1&&size(Ydata,2)<=1
        warning('Need to provide more than one data point to fit!')
        DataStructure=[];
    elseif size(Xdata,1)~=size(Ydata,1)||size(Xdata,2)~=size(Ydata,2)
        warning('Need to provide equal sized input arrays!')
        DataStructure=[];
    else
        [DataStructure.CorrelationCoefficient,DataStructure.Correlation_p]=corrcoef(Xdata,Ydata);
        DataStructure.FitValues=polyfit(Xdata,Ydata,1);
        TempMinX=min(Xdata(:));
        TempMaxX=max(Xdata(:));
        TempMinX=TempMinX-0.1*TempMaxX;
        if TempMinX<0
            TempMinX=0;
        end
        TempMaxX=TempMaxX+0.1*TempMaxX;
        
        FitIncrement=TempMaxX/100;

        DataStructure.FitXValues=TempMinX:FitIncrement:TempMaxX;
        for count=1:length(DataStructure.FitXValues) 
            DataStructure.FitYValues(count)=DataStructure.FitValues(1)*DataStructure.FitXValues(count)+DataStructure.FitValues(2);
        end

%         for count=1:size(Xdata)
%             DataStructure.YValueResidual(count)=Ydata(count)-(DataStructure.FitValues(1)*Xdata(count)+DataStructure.FitValues(2));
%         end
%          DataStructure.SSresid = sum(DataStructure.YValueResidual.^2);
%          DataStructure.SStotal = (length(Ydata)-1) * var(Ydata);
%          DataStructure.RSqu = 1 - DataStructure.SSresid/DataStructure.SStotal;
%          DataStructure.RSqu_Adjusted=1 - DataStructure.SSresid/DataStructure.SStotal * (length(Ydata)-1)/(length(Ydata)-length(Xdata)-1);
%  


        DataStructure.yfit = polyval(DataStructure.FitValues,Xdata);
        DataStructure.yresid = Ydata - DataStructure.yfit;
        DataStructure.SSresid = sum(DataStructure.yresid.^2);
        DataStructure.SStotal = (length(Ydata)-1) * var(Ydata);
        DataStructure.RSqu = 1 - DataStructure.SSresid/DataStructure.SStotal;
        DataStructure.R=sqrt(DataStructure.RSqu);
        DataStructure.CorrCoef_R=DataStructure.CorrelationCoefficient(1,2);
        DataStructure.CorrCoef_P=DataStructure.Correlation_p(1,2);
        
        DataStructure.FitEquation_Text = strcat('y=',num2str(DataStructure.FitValues(1),3),'x+',num2str(DataStructure.FitValues(2),3));
        DataStructure.RSquared_Text = strcat('R2=',num2str(DataStructure.RSqu,3));
        DataStructure.R_Text = strcat('R=',num2str(DataStructure.R,3));
        DataStructure.CorrCoef_R_Text = strcat('R=',num2str(DataStructure.CorrCoef_R,3));
        DataStructure.CorrCoef_PValue_Text = strcat('P= ',num2str(DataStructure.CorrCoef_P,3));
    end
         

         
         
end




