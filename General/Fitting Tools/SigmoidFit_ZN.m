function DataStructure=SigmoidFit_ZN(Xdata,Ydata,FitOption)
    if size(Xdata,1)<=1&&size(Xdata,2)<=1&&size(Ydata,1)<=1&&size(Ydata,2)<=1
        warning('Need to provide more than one data point to fit!')
        DataStructure=[];
    elseif size(Xdata,1)~=size(Ydata,1)||size(Xdata,2)~=size(Ydata,2)
        warning('Need to provide equal sized input arrays!')
        DataStructure=[];
    else
        warning off
        %=Bottom + (Top-Bottom)/(1+10^((LogEC50-X)*HillSlope))
        FitBuffer=0.2;
        FitDeviations=1000;
        switch FitOption
            case 1
                beta0 = [1, 1, 1, 1]; % Guess values to start with.  Just make your best guess.
                modelfun = @(b,x) b(1)+(b(2)-b(1))./(1+10.^((b(3)-x)*b(4)));
        end
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

        if any(Xdata<0)
            TempMinX=min(Xdata(:));
            TempMaxX=max(Xdata(:));
            TempMinX=TempMinX-FitBuffer*TempMaxX;
            if TempMinX<0
                TempMinX=0;
            end
            TempMaxX=TempMaxX+FitBuffer*TempMaxX;
        else
            TempMinX=0;
            TempMaxX=max(Xdata(:));
            TempMinX=TempMinX-FitBuffer*TempMaxX;
            if TempMinX<0
                TempMinX=0;
            end
            TempMaxX=TempMaxX+FitBuffer*TempMaxX;
        end
        if any(Ydata<0)
            TempMinY=min(Ydata(:));
            TempMaxY=max(Ydata(:));
            TempMinY=TempMinY-FitBuffer*TempMaxY;
            if TempMinY<0
                TempMinY=0;
            end
            TempMaxY=TempMaxY+FitBuffer*TempMaxY;
        else
            TempMinY=0;
            TempMaxY=max(Ydata(:));
            TempMinY=TempMinY-FitBuffer*TempMaxY;
            if TempMinY<0
                TempMinY=0;
            end
            TempMaxY=TempMaxY+FitBuffer*TempMaxY;
        end

        FitIncrement=TempMaxX/FitDeviations;

        clear DataStructure
        DataStructure=[];
        DataStructure.FitType='Sigmoid';
        try
            DataStructure.FitXValues=[];
            DataStructure.FitYValues=[];
            DataStructure.modelfun=modelfun;
            tbl = table(Xdata', Ydata');
            [FitParam, FitStats]=sigm_fit(Xdata,Ydata,[],[],0);
            DataStructure.FitParam = FitParam;
            DataStructure.FitStats = FitStats;

            clear TempX TempY
            TempX=TempMinX:FitIncrement:TempMaxX;
            switch FitOption
                case 1
                    for count=1:length(TempX) 
                        TempY(count)=DataStructure.FitParam(1)+(DataStructure.FitParam(2)-DataStructure.FitParam(1))./(1+10.^((DataStructure.FitParam(3)-TempX(count))*DataStructure.FitParam(4)));
                    end
                    fixvals=0;
                    for count=1:length(TempX) 
                        if TempX(count)>=TempMinX&&TempX(count)<=TempMaxX&&...
                           TempY(count)>=TempMinY&&TempY(count)<=TempMaxY  
                            fixvals=fixvals+1;
                            DataStructure.FitXValues(fixvals)=TempX(count);
                            DataStructure.FitYValues(fixvals)=TempY(count);
                        end
                    end
                    for count=1:length(Xdata) 
                        DataStructure.yfit(count) = DataStructure.FitParam(1)+(DataStructure.FitParam(2)-DataStructure.FitParam(1))./(1+10.^((DataStructure.FitParam(3)-Xdata(count))*DataStructure.FitParam(4)));
                    end
                    DataStructure.Fit_min=DataStructure.FitParam(1);
                    DataStructure.Fit_max=DataStructure.FitParam(2);
                    DataStructure.Fit_EC50=DataStructure.FitParam(3);
                    DataStructure.Fit_Hill_Slope=DataStructure.FitParam(4);

                    DataStructure.FitEquation_Text = strcat('y=',num2str(DataStructure.FitParam(1)),'+(',...
                        num2str(DataStructure.FitParam(2)),'-',num2str(DataStructure.FitParam(1)),')/(1+10^((',...
                        num2str(DataStructure.FitParam(3)),'-x)*',num2str(DataStructure.FitParam(4)),'))');

            end


            DataStructure.yresid = Ydata - DataStructure.yfit;
            DataStructure.SSresid = sum(DataStructure.yresid.^2);
            DataStructure.SStotal = (length(Ydata)-1) * var(Ydata);
            DataStructure.RSqu = 1 - DataStructure.SSresid/DataStructure.SStotal;
            DataStructure.R=sqrt(DataStructure.RSqu);
        %     [DataStructure.CorrelationCoefficient,DataStructure.Correlation_p]=corrcoef(Xdata,Ydata);
        %     DataStructure.CorrCoef_R=DataStructure.CorrelationCoefficient(1,2);
        %     DataStructure.CorrCoef_P=DataStructure.Correlation_p(1,2);
            DataStructure.CorrelationCoefficient=[];
            DataStructure.Correlation_p=[];
            DataStructure.CorrCoef_R=[];
            DataStructure.CorrCoef_P=[];

            DataStructure.RSquared_Text = strcat('R2=',num2str(DataStructure.RSqu,3));
            DataStructure.R_Text = [''];
            DataStructure.CorrCoef_R_Text = [''];
            switch FitOption
                case 1
                    DataStructure.CorrCoef_PValue_Text = ...
                        ['EC50 = ',num2str(DataStructure.Fit_EC50),' Hill Slope = ',num2str(DataStructure.Fit_Hill_Slope)];
            end

        catch

            DataStructure.Power_Fit_Model=[];
            DataStructure.Power_Fit=[];

            warning on
            warning('unable to complete Sigmoidal fit...')
        end


        warning on
    end
         
         
end




