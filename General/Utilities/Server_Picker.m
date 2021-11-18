function [ServerIP,ServerName]=Server_Picker(LabDefaults)
    [OS,~,~,~,~,~]=WhereAmIRunning(1);
    if any(strfind(OS,'MAC'))
        CurrentIP='Unknown IP';
    else
        try
            [~,result] = system('arp -a');
            Index1=strfind(result,'Interface: ');
            Index2=strfind(result,' --- ');
            CurrentIP=result(Index1+11:Index2-1);
        catch
            CurrentIP='Unknown IP';
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DefaultLoadLabel='Server IPs';
    if exist('LabDefaults')
        if exist(LabDefaults)
            LoadLabDefaultsChoice = questdlg([LabDefaults,' Exist...Load: ',DefaultLoadLabel,'?'],'Load Lab Defaults?','Load','Skip','Load');
            switch LoadLabDefaultsChoice
                case 'Load'
                    run(LabDefaults)
            end
        end
    else
        warning('<LabDefaults> Variable Doesnt Exist...')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Auto Options
    AllServerChoices(1).ServerIP=[CurrentIP];
    AllServerChoices(1).ServerName='Current Computer';
    AllServerChoices=[AllServerChoices,ServerChoices];
    TempIndex=length(AllServerChoices);
    AllServerChoices(TempIndex+1).ServerIP=[''];
    AllServerChoices(TempIndex+1).ServerName='Manual Entry';
    for i=1:length(AllServerChoices)
        Options{i}=[AllServerChoices(i).ServerName,' (',AllServerChoices(i).ServerIP,')'];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Please Choose Server Hosting the Batch Queue: ')
    [ServerChoice, ~] = listdlg('PromptString','Select a Server IP:','SelectionMode','single','ListString',Options,'ListSize', [600 600]);
    ServerIP=AllServerChoices(ServerChoice).ServerIP;
    ServerName=AllServerChoices(ServerChoice).ServerName;
    if strcmp(ServerName,'Manual Entry')
        GoodIP=0;
        while ~GoodIP
            ServerIP=input('Type in server IP: ','s');
            if sum(ServerIP=='.')==3
                GoodIP=1;
            else
                warning('Incorrect IP format try again...') 
            end
        end
    end
    disp(['Selected: ',ServerName,' (',ServerIP,')'])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end