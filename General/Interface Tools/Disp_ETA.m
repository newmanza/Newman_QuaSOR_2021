%Include TimeHandle=tic; before for loop


function [TimeHandle]=Disp_ETA(Label,Number,Total,TimeHandle)
    TimeInterval=toc(TimeHandle);
    disp([Label,' # ',num2str(Number),' of ',num2str(Total), ' Time/Loop: ',num2str(round(TimeInterval*10)/10),' s ETA: ',num2str(round(((round(TimeInterval*10)/10*(Total-Number))/60)*10)/10),' min']);
    TimeHandle=tic;            
end
                
                
