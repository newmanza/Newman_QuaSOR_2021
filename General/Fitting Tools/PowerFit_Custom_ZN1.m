function DataStructure=PowerFit_Custom_ZN1(Xdata,Ydata,Power,FitOption)
    %Newer version includes different fit methods
    
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
        switch FitOption
            case 1
                beta0 = [1]; % Guess values to start with.  Just make your best guess.
                modelfun = @(b,x) b(1) * x(:, 1) .^ Power;
            case 2
                beta0 = [1, 0]; % Guess values to start with.  Just make your best guess.
                modelfun = @(b,x) b(1) * x(:, 1) .^ Power + b(2);
            case 3
                beta0=[1];
                modelfun=['a*x^',num2str(Power)];
            case 4
                beta0=[1 0];
                modelfun=['a*x^',num2str(Power),'+b'];

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
        switch FitOption
            case 1
                DataStructure.FitType='Custom Power-0';
            case 2
                DataStructure.FitType='Custom Power';
            case 3
                DataStructure.FitType='Custom Power-0 Alt';
            case 4
                DataStructure.FitType='Custom Power Alt';
        end
        try
            DataStructure.FitXValues=[];
            DataStructure.FitYValues=[];
            DataStructure.modelfun=modelfun;
            if FitOption==1||FitOption==2
                tbl = table(Xdata', Ydata');
                FitFxn = fitnlm(tbl, modelfun, beta0);
                DataStructure.Power_Fit_Model=FitFxn;
                DataStructure.Coefficients = DataStructure.Power_Fit_Model.Coefficients{:, 'Estimate'};
            elseif FitOption==3
                FitFxn = fit(Xdata',Ydata',modelfun,'startpoint',beta0);
                DataStructure.Power_Fit_Model=FitFxn;
                DataStructure.Coefficients(1) = DataStructure.Power_Fit_Model.a;
            elseif FitOption==4
                FitFxn = fit(Xdata',Ydata',modelfun,'startpoint',beta0);
                DataStructure.Power_Fit_Model=FitFxn;
                DataStructure.Coefficients(1) = DataStructure.Power_Fit_Model.a;
                DataStructure.Coefficients(2) = DataStructure.Power_Fit_Model.b;
            end
            clear TempX TempY
            TempX=TempMinX:FitIncrement:TempMaxX;
            switch FitOption
                case 1
                    for count=1:length(TempX) 
                        TempY(count)=DataStructure.Coefficients(1) * TempX(count).^Power;
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
                        DataStructure.yfit(count) = DataStructure.Coefficients(1) * Xdata(count) .^ Power;
                    end
                    DataStructure.FitEquation_Text = strcat('y=',num2str(DataStructure.Coefficients(1)),...
                        'x^{',num2str(Power),'}');
                case 2
                    for count=1:length(TempX) 
                        TempY(count)=DataStructure.Coefficients(1) * TempX(count).^Power + DataStructure.Coefficients(2);
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
                        DataStructure.yfit(count) = DataStructure.Coefficients(1) * Xdata(count) .^ Power + DataStructure.Coefficients(2);
                    end
                    if DataStructure.Coefficients(2)<0
                        DataStructure.FitEquation_Text = strcat('y=',num2str(DataStructure.Coefficients(1)),...
                            'x^{',num2str(Power),'}',num2str(DataStructure.Coefficients(2)));
                    elseif DataStructure.Coefficients(2)>0
                        DataStructure.FitEquation_Text = strcat('y=',num2str(DataStructure.Coefficients(1)),...
                            'x^{',num2str(Power),'}+',num2str(DataStructure.Coefficients(2)));
                    else
                        DataStructure.FitEquation_Text = strcat('y=',num2str(DataStructure.Coefficients(1)),...
                            'x^{',num2str(Power),'}');
                    end
                case 3
                    for count=1:length(TempX) 
                        TempY(count)=DataStructure.Coefficients(1) * TempX(count).^Power;
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
                        DataStructure.yfit(count) = DataStructure.Coefficients(1) * Xdata(count) .^ Power;
                    end
                    DataStructure.FitEquation_Text = strcat('y=',num2str(DataStructure.Coefficients(1)),...
                        'x^{',num2str(Power),'}');
                case 4
                    for count=1:length(TempX) 
                        TempY(count)=DataStructure.Coefficients(1) * TempX(count).^Power + DataStructure.Coefficients(2);
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
                        DataStructure.yfit(count) = DataStructure.Coefficients(1) * Xdata(count) .^ Power + DataStructure.Coefficients(2);
                    end
                    if DataStructure.Coefficients(2)<0
                        DataStructure.FitEquation_Text = strcat('y=',num2str(DataStructure.Coefficients(1)),...
                            'x^{',num2str(Power),'}',num2str(DataStructure.Coefficients(2)));
                    elseif DataStructure.Coefficients(2)>0
                        DataStructure.FitEquation_Text = strcat('y=',num2str(DataStructure.Coefficients(1)),...
                            'x^{',num2str(Power),'}+',num2str(DataStructure.Coefficients(2)));
                    else
                        DataStructure.FitEquation_Text = strcat('y=',num2str(DataStructure.Coefficients(1)),...
                            'x^{',num2str(Power),'}');
                    end
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
                    Temp_a=DataStructure.Coefficients(1);
                    if abs(Temp_a)>=1
                        Temp_a=round(Temp_a);
                    elseif abs(Temp_a)<1&&abs(Temp_a)>=0.1
                        Temp_a=round(Temp_a*10)/10;
                    elseif abs(Temp_a)<0.1&&abs(Temp_a)>=0.01
                        Temp_a=round(Temp_a*100)/100;
                    elseif abs(Temp_a)<0.01&&abs(Temp_a)>=0.001
                        Temp_a=round(Temp_a*1000)/1000;
                    elseif abs(Temp_a)<0.001&&abs(Temp_a)>=0.0001
                        Temp_a=round(Temp_a*10000)/10000;
                    elseif abs(Temp_a)<0.0001&&abs(Temp_a)>=0.00001
                        Temp_a=round(Temp_a*100000)/100000;
                    end
                    Temp_b=Power;
                    if abs(Temp_b)>=1
                        Temp_b=round(Temp_b);
                    elseif abs(Temp_b)<1&&abs(Temp_b)>=0.1
                        Temp_b=round(Temp_b*10)/10;
                    elseif abs(Temp_b)<0.1&&abs(Temp_b)>=0.01
                        Temp_b=round(Temp_b*100)/100;
                    elseif abs(Temp_b)<0.01&&abs(Temp_b)>=0.001
                        Temp_b=round(Temp_b*1000)/1000;
                    elseif abs(Temp_b)<0.001&&abs(Temp_b)>=0.0001
                        Temp_b=round(Temp_b*10000)/10000;
                    elseif abs(Temp_b)<0.0001&&abs(Temp_b)>=0.00001
                        Temp_b=round(Temp_b*100000)/100000;
                    end
                    DataStructure.CorrCoef_PValue_Text = ...
                        [num2str(Temp_a),...
                        'x^{',num2str(Temp_b),'}'];
                case 2
                    Temp_a=DataStructure.Coefficients(1);
                    if abs(Temp_a)>=1
                        Temp_a=round(Temp_a);
                    elseif abs(Temp_a)<1&&abs(Temp_a)>=0.1
                        Temp_a=round(Temp_a*10)/10;
                    elseif abs(Temp_a)<0.1&&abs(Temp_a)>=0.01
                        Temp_a=round(Temp_a*100)/100;
                    elseif abs(Temp_a)<0.01&&abs(Temp_a)>=0.001
                        Temp_a=round(Temp_a*1000)/1000;
                    elseif abs(Temp_a)<0.001&&abs(Temp_a)>=0.0001
                        Temp_a=round(Temp_a*10000)/10000;
                    elseif abs(Temp_a)<0.0001&&abs(Temp_a)>=0.00001
                        Temp_a=round(Temp_a*100000)/100000;
                    end
                    Temp_b=Power;
                    if abs(Temp_b)>=1
                        Temp_b=round(Temp_b);
                    elseif abs(Temp_b)<1&&abs(Temp_b)>=0.1
                        Temp_b=round(Temp_b*10)/10;
                    elseif abs(Temp_b)<0.1&&abs(Temp_b)>=0.01
                        Temp_b=round(Temp_b*100)/100;
                    elseif abs(Temp_b)<0.01&&abs(Temp_b)>=0.001
                        Temp_b=round(Temp_b*1000)/1000;
                    elseif abs(Temp_b)<0.001&&abs(Temp_b)>=0.0001
                        Temp_b=round(Temp_b*10000)/10000;
                    elseif abs(Temp_b)<0.0001&&abs(Temp_b)>=0.00001
                        Temp_b=round(Temp_b*100000)/100000;
                    end
                    Temp_c=DataStructure.Coefficients(2);
                    if abs(Temp_c)>=1
                        Temp_c=round(abs(Temp_c));
                    elseif abs(Temp_c)<1&&abs(Temp_c)>=0.1
                        Temp_c=round(abs(Temp_c*10)/10);
                    elseif abs(Temp_c)<0.1&&abs(Temp_c)>=0.01
                        Temp_c=round(abs(Temp_c*100)/100);
                    elseif abs(Temp_c)<0.01&&abs(Temp_c)>=0.001
                        Temp_c=round(abs(Temp_c*1000)/1000);
                    elseif abs(Temp_c)<0.001&&abs(Temp_c)>=0.0001
                        Temp_c=round(abs(Temp_c*10000)/10000);
                    elseif abs(Temp_c)<0.0001&&abs(Temp_c)>=0.00001
                        Temp_c=round(abs(Temp_c*100000)/100000);
                    end
                    if DataStructure.Coefficients(2)<0
                        DataStructure.CorrCoef_PValue_Text = ...
                            [num2str(Temp_a),...
                            'x^{',num2str(Temp_b),'}-',...
                            num2str(Temp_c)];
                    elseif DataStructure.Coefficients(2)>0
                        DataStructure.CorrCoef_PValue_Text = ...
                            [num2str(Temp_a),...
                            'x^{',num2str(Temp_b),'}+',...
                            num2str(Temp_c)];
                    else
                        DataStructure.CorrCoef_PValue_Text = ...
                            [num2str(Temp_a),...
                            'x^{',num2str(Temp_b),'}',];
                    end
                case 3
                    Temp_a=DataStructure.Coefficients(1);
                    if abs(Temp_a)>=1
                        Temp_a=round(Temp_a);
                    elseif abs(Temp_a)<1&&abs(Temp_a)>=0.1
                        Temp_a=round(Temp_a*10)/10;
                    elseif abs(Temp_a)<0.1&&abs(Temp_a)>=0.01
                        Temp_a=round(Temp_a*100)/100;
                    elseif abs(Temp_a)<0.01&&abs(Temp_a)>=0.001
                        Temp_a=round(Temp_a*1000)/1000;
                    elseif abs(Temp_a)<0.001&&abs(Temp_a)>=0.0001
                        Temp_a=round(Temp_a*10000)/10000;
                    elseif abs(Temp_a)<0.0001&&abs(Temp_a)>=0.00001
                        Temp_a=round(Temp_a*100000)/100000;
                    end
                    Temp_b=Power;
                    if abs(Temp_b)>=1
                        Temp_b=round(Temp_b);
                    elseif abs(Temp_b)<1&&abs(Temp_b)>=0.1
                        Temp_b=round(Temp_b*10)/10;
                    elseif abs(Temp_b)<0.1&&abs(Temp_b)>=0.01
                        Temp_b=round(Temp_b*100)/100;
                    elseif abs(Temp_b)<0.01&&abs(Temp_b)>=0.001
                        Temp_b=round(Temp_b*1000)/1000;
                    elseif abs(Temp_b)<0.001&&abs(Temp_b)>=0.0001
                        Temp_b=round(Temp_b*10000)/10000;
                    elseif abs(Temp_b)<0.0001&&abs(Temp_b)>=0.00001
                        Temp_b=round(Temp_b*100000)/100000;
                    end
                    DataStructure.CorrCoef_PValue_Text = ...
                        [num2str(Temp_a),...
                        'x^{',num2str(Temp_b),'}'];
                case 4
                    Temp_a=DataStructure.Coefficients(1);
                    if abs(Temp_a)>=1
                        Temp_a=round(Temp_a);
                    elseif abs(Temp_a)<1&&abs(Temp_a)>=0.1
                        Temp_a=round(Temp_a*10)/10;
                    elseif abs(Temp_a)<0.1&&abs(Temp_a)>=0.01
                        Temp_a=round(Temp_a*100)/100;
                    elseif abs(Temp_a)<0.01&&abs(Temp_a)>=0.001
                        Temp_a=round(Temp_a*1000)/1000;
                    elseif abs(Temp_a)<0.001&&abs(Temp_a)>=0.0001
                        Temp_a=round(Temp_a*10000)/10000;
                    elseif abs(Temp_a)<0.0001&&abs(Temp_a)>=0.00001
                        Temp_a=round(Temp_a*100000)/100000;
                    end
                    Temp_b=Power;
                    if abs(Temp_b)>=1
                        Temp_b=round(Temp_b);
                    elseif abs(Temp_b)<1&&abs(Temp_b)>=0.1
                        Temp_b=round(Temp_b*10)/10;
                    elseif abs(Temp_b)<0.1&&abs(Temp_b)>=0.01
                        Temp_b=round(Temp_b*100)/100;
                    elseif abs(Temp_b)<0.01&&abs(Temp_b)>=0.001
                        Temp_b=round(Temp_b*1000)/1000;
                    elseif abs(Temp_b)<0.001&&abs(Temp_b)>=0.0001
                        Temp_b=round(Temp_b*10000)/10000;
                    elseif abs(Temp_b)<0.0001&&abs(Temp_b)>=0.00001
                        Temp_b=round(Temp_b*100000)/100000;
                    end
                    Temp_c=DataStructure.Coefficients(2);
                    if abs(Temp_c)>=1
                        Temp_c=round(abs(Temp_c));
                    elseif abs(Temp_c)<1&&abs(Temp_c)>=0.1
                        Temp_c=round(abs(Temp_c*10)/10);
                    elseif abs(Temp_c)<0.1&&abs(Temp_c)>=0.01
                        Temp_c=round(abs(Temp_c*100)/100);
                    elseif abs(Temp_c)<0.01&&abs(Temp_c)>=0.001
                        Temp_c=round(abs(Temp_c*1000)/1000);
                    elseif abs(Temp_c)<0.001&&abs(Temp_c)>=0.0001
                        Temp_c=round(abs(Temp_c*10000)/10000);
                    elseif abs(Temp_c)<0.0001&&abs(Temp_c)>=0.00001
                        Temp_c=round(abs(Temp_c*100000)/100000);
                    end
                    if DataStructure.Coefficients(2)<0
                        DataStructure.CorrCoef_PValue_Text = ...
                            [num2str(Temp_a),...
                            'x^{',num2str(Temp_b),'}-',...
                            num2str(Temp_c)];
                    elseif DataStructure.Coefficients(2)>0
                        DataStructure.CorrCoef_PValue_Text = ...
                            [num2str(Temp_a),...
                            'x^{',num2str(Temp_b),'}+',...
                            num2str(Temp_c)];
                    else
                        DataStructure.CorrCoef_PValue_Text = ...
                            [num2str(Temp_a),...
                            'x^{',num2str(Temp_b),'}',];
                    end
            end

        catch

            DataStructure.Power_Fit_Model=[];
            DataStructure.Power_Fit=[];
            DataStructure.RSqu=NaN;
            DataStructure.R2=NaN;
            DataStructure.R=NaN;
            DataStructure.RSquared_Text = 'R2=NaN';
            DataStructure.R_Text = ['NaN'];
            warning on
            warning('unable to complete Power law fit...')
        end


        warning on

    end
         
end




