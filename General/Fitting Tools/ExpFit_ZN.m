function DataStructure=ExpFit_ZN(Xdata,Ydata)
    if size(Xdata,1)<=1&&size(Xdata,2)<=1&&size(Ydata,1)<=1&&size(Ydata,2)<=1
        warning('Need to provide more than one data point to fit!')
        DataStructure=[];
    elseif size(Xdata,1)~=size(Ydata,1)||size(Xdata,2)~=size(Ydata,2)
        warning('Need to provide equal sized input arrays!')
        DataStructure=[];
    else
        FitBuffer=0.2;
        FitDeviations=1000;
        %f(x) = a*exp(b*x)
        %f2(x) = a*exp(b*x) + c*exp(d*x)
        if size(Xdata,2)>size(Xdata,1)
        else
            Xdata=Xdata';
            Ydata=Ydata';
        end
        if any(isnan(Xdata))||any(isnan(Ydata))
            warning on
            warning('Removing NaNs...')
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        try
            DataStructure.exp1_Fit.Model = fit(Xdata',Ydata','exp1');
            DataStructure.exp1_Fit.FitType='Exp1';
            clear TempX TempY
            TempX=TempMinX:FitIncrement:TempMaxX;
            for count=1:length(TempX) 
                TempY(count) = DataStructure.exp1_Fit.Model.a*exp(DataStructure.exp1_Fit.Model.b*TempX(count));
            end
            fixvals=0;
            for count=1:length(TempX) 
                if TempX(count)>=TempMinX&&TempX(count)<=TempMaxX&&...
                   TempY(count)>=TempMinY&&TempY(count)<=TempMaxY  
                    fixvals=fixvals+1;
                    DataStructure.exp1_Fit.FitXValues(fixvals)=TempX(count);
                    DataStructure.exp1_Fit.FitYValues(fixvals)=TempY(count);
                end
            end

    %         figure
    %         plot(Xdata,Ydata,'.')
    %         hold on
    %         plot(TempX,DataStructure.exp1_Fit.FitYValues,'-','color','g')
    % 

            for count=1:length(Xdata) 
                DataStructure.exp1_Fit.yfit(count) = DataStructure.exp1_Fit.Model.a*exp(DataStructure.exp1_Fit.Model.b*Xdata(count));
            end

            DataStructure.exp1_Fit.yresid = Ydata - DataStructure.exp1_Fit.yfit;
            DataStructure.exp1_Fit.SSresid = sum(DataStructure.exp1_Fit.yresid.^2);
            DataStructure.exp1_Fit.SStotal = (length(Ydata)-1) * var(Ydata);
            DataStructure.exp1_Fit.RSqu = 1 - DataStructure.exp1_Fit.SSresid/DataStructure.exp1_Fit.SStotal;
            DataStructure.exp1_Fit.R=sqrt(DataStructure.exp1_Fit.RSqu);
        %     [DataStructure.exp1_Fit.CorrelationCoefficient,DataStructure.exp1_Fit.Correlation_p]=corrcoef(Xdata,Ydata);
        %     DataStructure.exp1_Fit.CorrCoef_R=DataStructure.exp1_Fit.CorrelationCoefficient(1,2);
        %     DataStructure.exp1_Fit.CorrCoef_P=DataStructure.exp1_Fit.Correlation_p(1,2);
            DataStructure.exp1_Fit.CorrelationCoefficient=[];
            DataStructure.exp1_Fit.Correlation_p=[];
            DataStructure.exp1_Fit.CorrCoef_R=[];
            DataStructure.exp1_Fit.CorrCoef_P=[];
            DataStructure.exp1_Fit.R2=DataStructure.exp1_Fit.RSqu;

            DataStructure.exp1_Fit.FitEquation_Text = strcat('y=',num2str(DataStructure.exp1_Fit.Model.a),...
                'e^{',num2str(DataStructure.exp1_Fit.Model.b),'x}');
            DataStructure.exp1_Fit.RSquared_Text = strcat('R2=',num2str(DataStructure.exp1_Fit.RSqu,3));
            DataStructure.exp1_Fit.R_Text = [''];
            DataStructure.exp1_Fit.CorrCoef_R_Text = [''];
            DataStructure.exp1_Fit.CorrCoef_PValue_Text = [''];
            DataStructure.exp1_Fit.Model=DataStructure.exp1_Fit.Model;

            Temp_a=DataStructure.exp1_Fit.Model.a;
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
            Temp_b=DataStructure.exp1_Fit.Model.b;
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
            DataStructure.exp1_Fit.CorrCoef_PValue_Text = ...
                [num2str(Temp_a),...
                    'e^{',num2str(Temp_b),'x}'];

        catch
            DataStructure.exp1_Fit.Model=[];
            DataStructure.exp1_Fit=[];
            DataStructure.exp1_Fit.RSqu=NaN;
            warning on
            warning('unable to complete single exponential fit...')
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        try    
            DataStructure.exp2_Fit.Model = fit(Xdata',Ydata','exp2');
            DataStructure.exp2_Fit.FitType='Exp2';

            clear TempX TempY
            TempX=TempMinX:FitIncrement:TempMaxX;
            for count=1:length(TempX) 
                TempY(count) = DataStructure.exp2_Fit.Model.a*exp(DataStructure.exp2_Fit.Model.b*TempX(count))+...
                    DataStructure.exp2_Fit.Model.c*exp(DataStructure.exp2_Fit.Model.d*TempX(count));
            end
            fixvals=0;
            for count=1:length(TempX) 
                if TempX(count)>=TempMinX&&TempX(count)<=TempMaxX&&...
                   TempY(count)>=TempMinY&&TempY(count)<=TempMaxY  
                    fixvals=fixvals+1;
                    DataStructure.exp2_Fit.FitXValues(fixvals)=TempX(count);
                    DataStructure.exp2_Fit.FitYValues(fixvals)=TempY(count);
                end
            end

    %         figure
    %         plot(Xdata,Ydata,'.')
    %         hold on
    %         plot(TempX,TempY,'-','color','r')


            for count=1:length(Xdata) 
                DataStructure.exp2_Fit.yfit(count) = DataStructure.exp2_Fit.Model.a*exp(DataStructure.exp2_Fit.Model.b*Xdata(count))+...
                    DataStructure.exp2_Fit.Model.c*exp(DataStructure.exp2_Fit.Model.d*Xdata(count));
            end


            DataStructure.exp2_Fit.yresid = Ydata - DataStructure.exp2_Fit.yfit;
            DataStructure.exp2_Fit.SSresid = sum(DataStructure.exp2_Fit.yresid.^2);
            DataStructure.exp2_Fit.SStotal = (length(Ydata)-1) * var(Ydata);
            DataStructure.exp2_Fit.RSqu = 1 - DataStructure.exp2_Fit.SSresid/DataStructure.exp2_Fit.SStotal;
            DataStructure.exp2_Fit.R=sqrt(DataStructure.exp2_Fit.RSqu);
        %     [DataStructure.exp2_Fit.CorrelationCoefficient,DataStructure.exp2_Fit.Correlation_p]=corrcoef(Xdata,Ydata);
        %     DataStructure.exp2_Fit.CorrCoef_R=DataStructure.exp2_Fit.CorrelationCoefficient(1,2);
        %     DataStructure.exp2_Fit.CorrCoef_P=DataStructure.exp2_Fit.Correlation_p(1,2);
            DataStructure.exp2_Fit.CorrelationCoefficient=[];
            DataStructure.exp2_Fit.Correlation_p=[];
            DataStructure.exp2_Fit.CorrCoef_R=[];
            DataStructure.exp2_Fit.CorrCoef_P=[];
            DataStructure.exp2_Fit.R2=DataStructure.exp2_Fit.RSqu;
            DataStructure.exp2_Fit.FitEquation_Text = strcat('y=',num2str(DataStructure.exp2_Fit.Model.a),...
                'e^{',num2str(DataStructure.exp2_Fit.Model.b),'x}',...
                ' + ',num2str(DataStructure.exp2_Fit.Model.c),...
                'e^{',num2str(DataStructure.exp2_Fit.Model.d),'x}');
            DataStructure.exp2_Fit.RSquared_Text = strcat('R2=',num2str(DataStructure.exp2_Fit.RSqu,3));
            DataStructure.exp2_Fit.R_Text = [''];
            DataStructure.exp2_Fit.CorrCoef_R_Text = [''];
            DataStructure.exp2_Fit.CorrCoef_PValue_Text = [''];
            DataStructure.exp2_Fit.exp2_Fit.Model=DataStructure.exp2_Fit.Model;

            Temp_a=DataStructure.exp2_Fit.Model.a;
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
            Temp_b=DataStructure.exp2_Fit.Model.b;
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
            Temp_c=DataStructure.exp2_Fit.Model.c;
            if abs(Temp_c)>=1
                Temp_c=round(Temp_c);
            elseif abs(Temp_c)<1&&abs(Temp_c)>=0.1
                Temp_c=round(Temp_c*10)/10;
            elseif abs(Temp_c)<0.1&&abs(Temp_c)>=0.01
                Temp_c=round(Temp_c*100)/100;
            elseif abs(Temp_c)<0.01&&abs(Temp_c)>=0.001
                Temp_c=round(Temp_c*1000)/1000;
            elseif abs(Temp_c)<0.001&&abs(Temp_c)>=0.0001
                Temp_c=round(Temp_c*10000)/10000;
            elseif abs(Temp_c)<0.0001&&abs(Temp_c)>=0.00001
                Temp_c=round(Temp_c*100000)/100000;
            end
            Temp_d=DataStructure.exp2_Fit.Model.d;
            if abs(Temp_d)>=1
                Temp_d=round(Temp_d);
            elseif abs(Temp_d)<1&&abs(Temp_d)>=0.1
                Temp_d=round(Temp_d*10)/10;
            elseif abs(Temp_d)<0.1&&abs(Temp_d)>=0.01
                Temp_d=round(Temp_d*100)/100;
            elseif abs(Temp_d)<0.01&&abs(Temp_d)>=0.001
                Temp_d=round(Temp_d*1000)/1000;
            elseif abs(Temp_d)<0.001&&abs(Temp_d)>=0.0001
                Temp_d=round(Temp_d*10000)/10000;
            elseif abs(Temp_d)<0.0001&&abs(Temp_d)>=0.00001
                Temp_d=round(Temp_d*100000)/100000;
            end

            DataStructure.exp2_Fit.CorrCoef_PValue_Text = ...
                [num2str(Temp_a),...
                    'e^{',num2str(Temp_b),'x}',...
                    ' + ',num2str(Temp_c),...
                    'e^{',num2str(Temp_d),'x}'];
        catch
            DataStructure.exp2_Fit.Model=[];
            DataStructure.exp2_Fit=[];
            DataStructure.exp2_Fit.RSqu=NaN;
            warning on
            warning('unable to complete double exponential fit...')
        end


    end
         
end




