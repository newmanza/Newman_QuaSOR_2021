function OutputLim=LogLimRound(InputLim)
    %InputLim=[MinY,MaxY]
    MinLim=InputLim(1);
    MaxLim=InputLim(2);
    MinLimLog=log10(MinLim);
    MinLimLog=floor(MinLimLog);
    MaxLimLog=log10(MaxLim);
    MaxLimLog=ceil(MaxLimLog);
    OutputMin=10^MinLimLog;
    OutputMax=10^MaxLimLog;
    if OutputMin>=OutputMax
        error('Limit order or eqivalent problem!')
    end
    if OutputMin<=0
        error('Lower limit less than or equal to ZERO!')
    end
    OutputLim=[OutputMin,OutputMax];
    
    
end
    
    
    
    