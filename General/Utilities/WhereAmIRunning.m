function [OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(DisplayOn)

    MatlabVersion=version('-release');
    MatlabVersionYear=MatlabVersion(1:4);
    OS=computer;
    if strcmp(OS,'MACI64')
        dc='/';
    else
        dc='\';
    end

    [ret, compName] = system('hostname');   

    if ret ~= 0
       if ispc
          compName = getenv('COMPUTERNAME');
       else      
          compName = getenv('HOSTNAME');      
       end
    end
    
    compName = lower(compName);
    compName=cellstr(compName);
    compName=compName{1};
    
    ScreenSize=get(0,'ScreenSize');

    if DisplayOn
        disp(['=========================================================================================='])
        disp(['=========================================================================================='])
        disp(['Computer Name: ',compName])
        disp(['OS: ',OS])
        disp(['Matlab Version: ',MatlabVersion]);
        disp(['Screen Size: ',num2str(ScreenSize(3)),'x',num2str(ScreenSize(4)),' px'])
        disp(['=========================================================================================='])
        disp(['=========================================================================================='])
    end
end
