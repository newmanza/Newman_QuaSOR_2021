function DataStructure=PowerFit3D_ZN(Xdata,Ydata,ZData)
    
    FitBuffer=0.2;
    FitDeviations=1000;
    beta0 = [1, 1, 0]; % Guess values to start with.  Just make your best guess.
    modelfun = @(b,x) b(1) * x(:, 1) .^ + b(2) + b(3);
    if size(Xdata,2)>size(Xdata,1)
    else
        Xdata=Xdata';
        Ydata=Ydata';
    end
    TempMinX=min(Xdata(:));
    TempMaxX=max(Xdata(:));
    TempMinX=TempMinX-FitBuffer*TempMaxX;
    if TempMinX<0
        TempMinX=0;
    end
    TempMaxX=TempMaxX+FitBuffer*TempMaxX;

    TempMinY=min(Ydata(:));
    TempMaxY=max(Ydata(:));
    TempMinY=TempMinY-FitBuffer*TempMaxY;
    if TempMinY<0
        TempMinY=0;
    end
    TempMaxY=TempMaxY+FitBuffer*TempMaxY;
        
    FitIncrement=TempMaxX/FitDeviations;

    clear DataStructure
    DataStructure=[];
    DataStructure.FitType='Power Law';
    try
        DataStructure.FitXValues=[];
        DataStructure.FitYValues=[];
        DataStructure.modelfun=modelfun;
        tbl = table(Xdata', Ydata');
        FitFxn = fitnlm(tbl, modelfun, beta0);
        DataStructure.Power_Fit_Model=FitFxn;
        DataStructure.Coefficients = DataStructure.Power_Fit_Model.Coefficients{:, 'Estimate'};
    
        clear TempX TempY
        TempX=TempMinX:FitIncrement:TempMaxX;
        for count=1:length(TempX) 
            TempY(count)=DataStructure.Coefficients(1) * TempX(count).^DataStructure.Coefficients(2) + DataStructure.Coefficients(3);
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
        
%         figure
%         plot(Xdata,Ydata,'.')
%         hold on
%         plot(TempX,DataStructure.FitYValues,'-','color','g')
% 

        for count=1:length(Xdata) 
            DataStructure.yfit(count) = DataStructure.Coefficients(1) * Xdata(count) .^ DataStructure.Coefficients(2) + DataStructure.Coefficients(3);
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

        DataStructure.FitEquation_Text = strcat('y=',num2str(DataStructure.Coefficients(1)),...
            'x^{',num2str(DataStructure.Coefficients(2)),'}+',num2str(DataStructure.Coefficients(3)));
        DataStructure.RSquared_Text = strcat('R2=',num2str(DataStructure.RSqu,3));
        DataStructure.R_Text = [''];
        DataStructure.CorrCoef_R_Text = [''];
        DataStructure.CorrCoef_PValue_Text = [''];
    
    
    catch
        
        DataStructure.Power_Fit_Model=[];
        DataStructure.Power_Fit=[];
        
        warning on
        warning('unable to complete Power law fit...')
    end




         
         
end




