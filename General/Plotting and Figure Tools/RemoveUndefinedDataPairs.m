function [XData_Clean,YData_Clean,NumRemoved]=RemoveUndefinedDataPairs(XData,YData)
    XData_Clean=[];
    YData_Clean=[];
    CleanCount=0;
    NumRemoved=0;
    if any(size(XData)~=size(YData))
        error('data must be the same size...')
    end
    if size(XData,2)>size(XData,1)
        NumEntries=size(XData,2);
        for i=1:NumEntries
            if isnan(XData(i))||XData(i)==Inf||isnan(YData(i))||YData(i)==Inf
                NumRemoved=NumRemoved+1;
            else
                CleanCount=CleanCount+1;
                XData_Clean(CleanCount)=XData(i);
                YData_Clean(CleanCount)=YData(i);
            end
        end
    else
        NumEntries=size(XData,1);
        for i=1:NumEntries
            if isnan(XData(i,1))||XData(i,1)==Inf||isnan(YData(i,1))||YData(i,1)==Inf
                NumRemoved=NumRemoved+1;
            else
                CleanCount=CleanCount+1;
                XData_Clean(CleanCount,1)=XData(i,1);
                YData_Clean(CleanCount,1)=YData(i,1);
            end
        end
    end
    





end