function [DataStructure]=LogFit_ZN(Xdata,Ydata,LogType)
    if size(Xdata,1)<=1&&size(Xdata,2)<=1&&size(Ydata,1)<=1&&size(Ydata,2)<=1
        warning('Need to provide more than one data point to fit!')
        DataStructure=[];
    elseif size(Xdata,1)~=size(Ydata,1)||size(Xdata,2)~=size(Ydata,2)
        warning('Need to provide equal sized input arrays!')
        DataStructure=[];
    else

        FitBuffer=0.2;
        FitDeviations=1000;
        %f(x) = a+b*log(x)

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
        DataStructure.FitType='Log10x';
    % 
    %     myfit = fittype('a + b*log(x)',...
    %         'dependent',{'y'},'independent',{'x'},...
    %         'coefficients',{'a','b'});
    %     DataStructure=fit(Xdata',Ydata',myfit);
    %         

            [...
            DataStructure.slope,...
            DataStructure.intercept,...
            DataStructure.MSE,...
            DataStructure.R2,...
            DataStructure.S] = logfitZN(Xdata',Ydata',LogType);

        clear TempX TempY
        TempX=TempMinX:FitIncrement:TempMaxX;
        for count=1:length(TempX) 
            TempY(count)=DataStructure.intercept+DataStructure.slope*log10(TempX(count));
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

        DataStructure.FitEquation_Text = strcat('y=',num2str(DataStructure.intercept,3),'+',num2str(DataStructure.slope,3),'*log(x)');
        DataStructure.RSquared_Text = strcat('R2=',num2str(DataStructure.R2,3));
        DataStructure.R_Text = [''];
        DataStructure.CorrCoef_R_Text = [''];
        DataStructure.CorrCoef_PValue_Text = [''];

    % myfittype=fittype('a+b*log(x)',...
    % 'dependent', {'y'}, 'independent',{'x'},...
    % 'coefficients', {'a,b'});
    % myfit=fit(Xdata',Ydata',myfittype);
    end
end
