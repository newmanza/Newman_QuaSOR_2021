function FitStructure=FitSwitch2D(varargin)
    nin=nargin;
    switch nin
        case 1
            error('need more info')
        case 2
            error('need more info')
        case 3
            Xdata=varargin{1};
            Ydata=varargin{2};
            FitType=varargin{3};
        case 4
            Xdata=varargin{1};
            Ydata=varargin{2};
            FitType=varargin{3};
            FitParams=varargin{4};
    end
%     Xdata=XVals_Mean(:,r)
%     Ydata=YVals_Mean(:,r)
%     FitType=FitType{f}
%     FitParams=FitParams{r}
    
    if iscell(FitType)
        warning('Must Provide Single FitType!')
        warning('Must Provide Single FitType!')
        warning('Must Provide Single FitType!')
        warning('Must Provide Single FitType!')
        FitStructure=[];
    else
        if any(size(Xdata)~=size(Ydata))
            error(['Size Mismatch: Xdata ',num2str(size(Xdata)),' Ydata ',num2str(size(Ydata))])
        elseif size(Xdata,1)==1&&size(Xdata,2)==1&&size(Ydata,1)==1&&size(Ydata,2)==1
            warning('Must Provide more than one data point to fit!')
            warning('Must Provide more than one data point to fit!')
            warning('Must Provide more than one data point to fit!')
            warning('Must Provide more than one data point to fit!')
            warning('Must Provide more than one data point to fit!')
            FitStructure=[];
        else
        
            if strcmp(FitType,'Linear')||strcmp(FitType,'linear')||strcmp(FitType,'Lin')||strcmp(FitType,'lin')
                FitStructure=LinearFit_ZN2(Xdata,Ydata);
            elseif strcmp(FitType,'Exponential1')||strcmp(FitType,'exponential1')||strcmp(FitType,'Exp1')||strcmp(FitType,'exp1')
                TempFitStructure=ExpFit_ZN(Xdata,Ydata);
                FitStructure=TempFitStructure.exp1_Fit;
            elseif strcmp(FitType,'Exponential2')||strcmp(FitType,'exponential2')||strcmp(FitType,'Exp2')||strcmp(FitType,'exp2')
                TempFitStructure=ExpFit_ZN(Xdata,Ydata);
                FitStructure=TempFitStructure.exp2_Fit;
            elseif strcmp(FitType,'Log10x')||strcmp(FitType,'log10x')
                FitStructure=LogFit_ZN(Xdata,Ydata,'logx');
            elseif strcmp(FitType,'CustomPowerPlusAlt')||strcmp(FitType,'custompowerplusalt')||strcmp(FitType,'CPowPA')||strcmp(FitType,'cpowpa')
                FitStructure=PowerFit_Custom_ZN1(Xdata,Ydata,FitParams,4);
            elseif strcmp(FitType,'CustomPowerAlt')||strcmp(FitType,'custompoweralt')||strcmp(FitType,'CPowA')||strcmp(FitType,'cpowa')
                FitStructure=PowerFit_Custom_ZN1(Xdata,Ydata,FitParams,3);
            elseif strcmp(FitType,'CustomPowerPlus')||strcmp(FitType,'custompowerplus')||strcmp(FitType,'CPowP')||strcmp(FitType,'cpowp')
                FitStructure=PowerFit_Custom_ZN1(Xdata,Ydata,FitParams,2);
            elseif strcmp(FitType,'CustomPower')||strcmp(FitType,'custompower')||strcmp(FitType,'CPow')||strcmp(FitType,'cpow')
                FitStructure=PowerFit_Custom_ZN1(Xdata,Ydata,FitParams,1);
            elseif strcmp(FitType,'PowerPlusAlt')||strcmp(FitType,'powerplusalt')||strcmp(FitType,'PowPA')||strcmp(FitType,'powpa')
                FitStructure=PowerFit_ZN(Xdata,Ydata,4);
            elseif strcmp(FitType,'PowerAlt')||strcmp(FitType,'poweralt')||strcmp(FitType,'PowA')||strcmp(FitType,'powa')
                FitStructure=PowerFit_ZN(Xdata,Ydata,3);
            elseif strcmp(FitType,'PowerPlus')||strcmp(FitType,'powerplus')||strcmp(FitType,'PowP')||strcmp(FitType,'powp')
                FitStructure=PowerFit_ZN(Xdata,Ydata,2);
            elseif strcmp(FitType,'Power')||strcmp(FitType,'power')||strcmp(FitType,'Pow')||strcmp(FitType,'pow')
                FitStructure=PowerFit_ZN(Xdata,Ydata,1);
            elseif strcmp(FitType,'Sig')||strcmp(FitType,'Sigm')||strcmp(FitType,'Sigmoid')||strcmp(FitType,'Sigmoidal')||strcmp(FitType,'sig')||strcmp(FitType,'sigm')||strcmp(FitType,'sigmoid')||strcmp(FitType,'sigmoidal')
                FitStructure=SigmoidFit_ZN(Xdata,Ydata,1);
            else
                error('Cant figure out what type of FitType you want to do!')

            end
            try
                FitStructure.PreFormattedLabel=['(R2 = ',num2str(FitStructure.RSqu),'; ',FitStructure.FitEquation_Text,')'];
                disp(FitStructure.PreFormattedLabel)
            catch
                FitStructure.PreFormattedLabel=[];
            end
        end
    end
   


end