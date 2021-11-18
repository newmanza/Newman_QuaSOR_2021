function [OutputArray]=String2Array_Fixed(varargin)
    Delimiters=[];
    StartCap=[];
    EndCap=[];
    switch nargin
        case 1
            InputString=varargin{1};
        case 2
            InputString=varargin{1};
            Delimiters=varargin{2};
        case 3
            InputString=varargin{1};
            Delimiters=varargin{2};
            StartCap=varargin{3};
        case 4
            InputString=varargin{1};
            Delimiters=varargin{2};
            StartCap=varargin{3};
            EndCap=varargin{4};
    end

    if ~exist('Delimiters')
        Delimiters={' ',','};
    end
    if isempty(Delimiters)
        Delimiters={' ',','};
    end
    if ~exist('StartCap')
        StartCap='[';
    end
    if isempty(StartCap)
        StartCap='[';
    end
    if ~exist('EndCap')
        EndCap=']';
    end
    if isempty(EndCap)
        EndCap=']';
    end

    NumChar=length(InputString);
    OutputArray=[];
    OutputElement=0;
    TempString=[];
    FinishedElement=0;
    for i=1:NumChar
        TempDigit=InputString(i);
        if ~strcmp(TempDigit,StartCap)
            GoodEntry=1;
            for j=1:length(Delimiters)
                if strcmp(TempDigit,Delimiters{j})
                    GoodEntry=0;
                    FinishedElement=1;
                elseif strcmp(TempDigit,EndCap)
                    GoodEntry=0;
                    FinishedElement=1;
                end
            end
            if GoodEntry
                TempString=strcat(TempString,TempDigit);
            end
        end
        if FinishedElement
            OutputElement=OutputElement+1;
            if ischar(TempString)
            OutputArray(OutputElement)=str2num(TempString);
            end
            TempString=[];
            FinishedElement=0;
        end
    end
    
end