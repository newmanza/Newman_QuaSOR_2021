function DataStructure=LinearFit_ZN2(Xdata,Ydata)
    if size(Xdata,1)<=1&&size(Xdata,2)<=1&&size(Ydata,1)<=1&&size(Ydata,2)<=1
        warning('Need to provide more than one data point to fit!')
        DataStructure=[];
    elseif size(Xdata,1)~=size(Ydata,1)||size(Xdata,2)~=size(Ydata,2)
        warning('Need to provide equal sized input arrays!')
        DataStructure=[];
    else
        warning off    
        FitBuffer=0.2;
        FitDeviations=1000;
        if size(Xdata,2)>size(Xdata,1)
        else
            Xdata=Xdata';
            Ydata=Ydata';
        end
        if any(isnan(Xdata))||any(isnan(Ydata))
            warning on
            warning('Removing NaNs...')
            warning off
            Xdata1=[];
            Ydata1=[];
            for i=1:length(Xdata)
                if any(isnan(Xdata(i)))||any(isnan(Ydata(i)))
                else
                    Xdata1=[Xdata1,Xdata(i)];
                    Ydata1=[Ydata1,Ydata(i)];
                end
            end
            Xdata=Xdata1;clear Xdata1
            Ydata=Ydata1;clear Ydata1
        end

        DataStructure.FitType='Linear';
        [DataStructure.CorrelationCoefficient,DataStructure.Correlation_p]=corrcoef(Xdata,Ydata);
        DataStructure.FitValues=polyfit(Xdata,Ydata,1);
        if any(Xdata<0)
            TempMinX=min(Xdata(:));
            TempMaxX=max(Xdata(:));
            TempMinX=TempMinX-FitBuffer*abs(TempMaxX);
            if TempMinX<0
                TempMinX=0;
            end
            TempMaxX=TempMaxX+FitBuffer*abs(TempMaxX);
        else
            TempMinX=0;
            TempMaxX=max(Xdata(:));
            TempMinX=TempMinX-FitBuffer*abs(TempMaxX);
            if TempMinX<0
                TempMinX=0;
            end
            TempMaxX=TempMaxX+FitBuffer*abs(TempMaxX);
        end
        if any(Ydata<0)
            TempMinY=min(Ydata(:));
            TempMaxY=max(Ydata(:));
            TempMinY=TempMinY-FitBuffer*abs(TempMaxY);
    %         if TempMinY<0
    %             TempMinY=0;
    %         end
            TempMaxY=TempMaxY+FitBuffer*abs(TempMaxY);
        else
            TempMinY=0;
            TempMaxY=max(Ydata(:));
            TempMinY=TempMinY-FitBuffer*abs(TempMaxY);
            if TempMinY<0
                TempMinY=0;
            end
            TempMaxY=TempMaxY+FitBuffer*abs(TempMaxY);
        end

        FitIncrement=TempMaxX/FitDeviations;
        clear TempX TempY
        TempX=TempMinX:FitIncrement:TempMaxX;
        for count=1:length(TempX) 
            TempY(count)=DataStructure.FitValues(1)*TempX(count)+DataStructure.FitValues(2);
        end
        fixvals=0;
        DataStructure.FitXValues=[];
        DataStructure.FitYValues=[];
        for count=1:length(TempX) 
            if TempX(count)>=TempMinX&&TempX(count)<=TempMaxX&&...
               TempY(count)>=TempMinY&&TempY(count)<=TempMaxY  
                fixvals=fixvals+1;
                DataStructure.FitXValues(fixvals)=TempX(count);
                DataStructure.FitYValues(fixvals)=TempY(count);
            end
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
        DataStructure.R2=DataStructure.RSqu;
        DataStructure.FitEquation_Text = strcat('y=',num2str(DataStructure.FitValues(1),3),'x+',num2str(DataStructure.FitValues(2),3));
        DataStructure.RSquared_Text = strcat('R2=',num2str(DataStructure.RSqu,3));
        DataStructure.R_Text = strcat('R=',num2str(DataStructure.R,3));
        DataStructure.CorrCoef_R_Text = strcat('R=',num2str(DataStructure.CorrCoef_R,3));
        DataStructure.CorrCoef_PValue_Text = strcat('P= ',num2str(DataStructure.CorrCoef_P,3));

         warning on
    end
  
end




