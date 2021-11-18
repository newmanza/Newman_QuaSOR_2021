
%To do
%Pause abort clear buttons
%Auto Sizing
%auto shut down when finished
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run('Batching_Tracker_Initialization.m')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[OS,dc,ServerCompName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(1);
if any(strfind(OS,'MAC'))
    CurrentIP='Unknown IP';
else
    try
        [status,result] = system('arp -a');
        Index1=strfind(result,'Interface: ');
        Index2=strfind(result,' --- ');
        CurrentIP=result(Index1+11:Index2-1);
    catch
        CurrentIP='Unknown IP';
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[PortChoice, checking] = listdlg('PromptString','Select a port:','SelectionMode','single','ListString',PortOptionsText,'ListSize', [600 600]);
Port=PortOptions(PortChoice);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CurrentDateNum=datenum(clock);
[CustomCutoff.YR,CustomCutoff.MO,CustomCutoff.DA,...
    CustomCutoff.HR,CustomCutoff.MN,CustomCutoff.SE]=datevec(CurrentDateNum);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('DateNumCutoff')
    TempDateTimeCutoff=datestr(DateNumCutoff);
else
    TempDateTimeCutoff=[];
end
CutoffChoice = questdlg({'Update Cutoff Timing?';['Previous Cutoff: ',TempDateTimeCutoff]},'Cutoff Time?','Current Time','Reuse Cutoff','Define Cutoff','Current Time');
if strcmp(CutoffChoice,'Current Time')
    DateNumCutoff=CurrentDateNum;
elseif strcmp(CutoffChoice,'Reuse Cutoff')
    if ~exist('DateNumCutoff')
        warning on
        warning('Missing DateNumCutoff, Setting to current time')
        DateNumCutoff=CurrentDateNum;
    else
        
        
    end
else
    prompt = {'Year','Month','Day','Hour','Minute','Second'};
    dlg_title = 'Set Cutoff time (in past)';
    num_lines = 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    def = {num2str(CustomCutoff.YR),num2str(CustomCutoff.MO),num2str(CustomCutoff.DA),...
        num2str(CustomCutoff.HR),num2str(CustomCutoff.MN),num2str(CustomCutoff.SE)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    CustomCutoff.YR=str2num(answer{1});
    CustomCutoff.MO=str2num(answer{2});
    CustomCutoff.DA=str2num(answer{3});
    CustomCutoff.HR=str2num(answer{4});
    CustomCutoff.MN=str2num(answer{5});
    CustomCutoff.SE=str2num(answer{6});
    DateNumCutoff=datenum(CustomCutoff.YR,CustomCutoff.MO,CustomCutoff.DA,CustomCutoff.HR,CustomCutoff.MN,CustomCutoff.SE);
end
DateTimeCutoff=datestr(DateNumCutoff);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
DateTimeCutoff=datestr(DateNumCutoff);
warning(['Cutoff: ',DateTimeCutoff,' (',num2str(DateNumCutoff),')'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Clear Current Running Statuses
        for RecNum=1:length(Server_Recording)
            TrackerDir=[Server_Recording(RecNum).dir,dc,'Trackers',dc];
            if exist([TrackerDir,Server_Recording(RecNum).StackSaveName,File2Check])
                fprintf(['Checking File # ',num2str(RecNum),': ',Server_Recording(RecNum).StackSaveName,'\n'])
                if exist([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                    FileInfo = dir([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat']);
                    TimeStamp = FileInfo.date;
                    TimeStampDateNum=FileInfo.datenum;
                    load([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'],'compName')
                    disp(['Currently Running.mat Tracking File Found Running...'])
                    disp(['On ',compName,' Last updated: ',TimeStamp])
                    DeleteFile=input(['Enter <1> to DELETE: ']);
                    clear compName
                    if DeleteFile
                        fprintf(['Deleting: ',Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                        delete([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                        if ~exist([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                            fprintf('Successfully Deleted!\n')
                        end
                    else
                        fprintf('NOT DELETING FILE\n')
                    end
                else
                    fprintf('Currently Running.mat Tracking File Not Found\n')
                end
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DetailedStatusUpdates=0;
BufferSize=1024;
TimeOut=inf;%inf
NumLoops=100;   
LastRecording=0;
HostIP=['0.0.0.0'];%to accept from any IP
LoopCount=0;
if length(Server_Recording)>200
    FigPosition=[0,0.1,0.9,0.9];
    ColumnHeight=50;
    ColumnVertSpacing=0.025;
    ColumnHorzSpacing=0.01;
    ColumnHorzPosAddition=0.1;
    PauseButtonPosition=[0.0 0.97 0.04 0.03];
    ClearButtonPosition=[0.04 0.97 0.04 0.03];
    AbortButtonPosition=[0.08 0.97 0.04 0.03];
elseif length(Server_Recording)>120
    FigPosition=[0,0.2,0.9,0.7];
    ColumnHeight=36;
    ColumnVertSpacing=0.025;
    ColumnHorzSpacing=0.01;
    ColumnHorzPosAddition=0.2;
    PauseButtonPosition=[0.0 0.97 0.04 0.03];
    ClearButtonPosition=[0.04 0.97 0.04 0.03];
    AbortButtonPosition=[0.08 0.97 0.04 0.03];
elseif length(Server_Recording)>80
    FigPosition=[0,0.2,0.9,0.7];
    ColumnHeight=36;
    ColumnVertSpacing=0.025;
    ColumnHorzSpacing=0.01;
    ColumnHorzPosAddition=0.3;
    PauseButtonPosition=[0.0 0.97 0.04 0.03];
    ClearButtonPosition=[0.04 0.97 0.04 0.03];
    AbortButtonPosition=[0.08 0.97 0.04 0.03];
elseif length(Server_Recording)>60
    FigPosition=[0,0.2,0.7,0.7];
    ColumnHeight=36;
    ColumnVertSpacing=0.025;
    ColumnHorzSpacing=0.01;
    ColumnHorzPosAddition=0.3;
    PauseButtonPosition=[0.0 0.97 0.04 0.03];
    ClearButtonPosition=[0.04 0.97 0.04 0.03];
    AbortButtonPosition=[0.08 0.97 0.04 0.03];
elseif length(Server_Recording)>30
    FigPosition=[0,0.2,0.5,0.7];
    ColumnHeight=36;
    ColumnVertSpacing=0.025;
    ColumnHorzSpacing=0.01;
    ColumnHorzPosAddition=0.5;
    PauseButtonPosition=[0.0 0.97 0.08 0.03];
    ClearButtonPosition=[0.08 0.97 0.08 0.03];
    AbortButtonPosition=[0.16 0.97 0.08 0.03];
else
    FigPosition=[0,0.2,0.3,0.7];
    ColumnHeight=36;
    ColumnVertSpacing=0.025;
    ColumnHorzSpacing=0.01;
    ColumnHorzPosAddition=0.5;
    PauseButtonPosition=[0.0 0.97 0.1 0.03];
    ClearButtonPosition=[0.1 0.97 0.1 0.03];
    AbortButtonPosition=[0.2 0.97 0.1 0.03];
end
FontSize=8;
warning on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Checking for directory access...')
for RecNum=1:length(Server_Recording)
    StackSaveName = Server_Recording(RecNum).StackSaveName;
    if exist([Server_Recording(RecNum).dir])
    else
        warning([' ',Server_Recording(RecNum).dir,' Missing!']);
        error('Misisng directory! CHECK CONNECTIONS!')
    end
end
fprintf('Finished!\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check all statuses
AllRecordingStatuses=[];
AllRecordingStatuses_Label=[];
for RecNum=1:length(Server_Recording)
    StackSaveName = Server_Recording(RecNum).StackSaveName;
    TrackerDir=[Server_Recording(RecNum).dir,dc,'Trackers',dc];
    fprintf(['CHECKING Recording # ',num2str(RecNum),'...'])
    if exist([TrackerDir,StackSaveName,File2Check])
        FileInfo = dir([TrackerDir,StackSaveName,File2Check]);
        TimeStamp = FileInfo.date;
        TimeStampDateNum=FileInfo.datenum;
        if exist([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
            load([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'],'compName')
            AllRecordingStatuses(RecNum)=2;
            AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Running: ',compName,' (',TimeStamp,')'];
            clear compName
        else
            if TimeStampDateNum>DateNumCutoff
                AllRecordingStatuses(RecNum)=1;
                AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Up to Date! (',TimeStamp,')'];
            else
                AllRecordingStatuses(RecNum)=0;
                AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' Pending...'];
            end
        end
        fprintf([AllRecordingStatuses_Label{RecNum},'\n']);
    else
        AllRecordingStatuses(RecNum)=0;
        AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Missing Tracking File: ',File2Check];
        warning([' ',AnalysisLabel,' ',AllRecordingStatuses_Label{RecNum}]);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
%Status Figure
StatusFigure=figure;
subtightplot(1,1,1,[0,0],[0,0],[0,0]),axis off, box off
set(gcf,'units','normalized','position',FigPosition)
PauseButtonHandle = uicontrol('Units','Normalized','Position', PauseButtonPosition,'style','togglebutton',...
    'string',['Pause?'],'callback','set(gcbo,''userdata'',1,''string'',''Paused!!'')', ...
    'userdata',0) ;
ClearButtonHandle = uicontrol('Units','Normalized','Position', ClearButtonPosition,'style','togglebutton',...
    'string',['Clear Status?'],'callback','set(gcbo,''userdata'',1,''string'',''Clearing!!'')', ...
    'userdata',0) ;
AbortButtonHandle = uicontrol('Units','Normalized','Position', AbortButtonPosition,'style','togglebutton',...
    'string',['Abort?'],'callback','set(gcbo,''userdata'',1,''string'',''Aborting!!'')', ...
    'userdata',0) ;
count1=1;
count2=0;
count1=count1+1;
text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Running: ',AnalysisLabel,' for ',num2str(length(Server_Recording)),' Recordings'],...
    'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
count1=count1+1;
text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Server Name: ',ServerCompName],...
    'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
count1=count1+1;
text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Server IP: ',CurrentIP],...
    'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
count1=count1+1;
text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Server Port: ',num2str(Port)],...
    'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
count1=count1+1;
text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Update Cutoff: ',DateTimeCutoff],...
    'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
for RecNum=1:length(Server_Recording)
    count1=count1+1;
    if AllRecordingStatuses(RecNum)==1
        if LastRecording==RecNum
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','g','FontWeight','bold','fontsize',FontSize)
        else
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','g','fontsize',FontSize)
        end
    elseif AllRecordingStatuses(RecNum)==2
        if LastRecording==RecNum
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','c','FontWeight','bold','fontsize',FontSize)
        else
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','b','fontsize',FontSize)
        end
    else
        if LastRecording==RecNum
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','c','FontWeight','bold','fontsize',FontSize)
        else
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','r','fontsize',FontSize)
        end
    end
    if count1==ColumnHeight
        count1=0;
        count2=count2+ColumnHorzPosAddition;
    end
end
drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StartingLastRecording=0;%Use this variable to break into middle of queue, but please dont change permanently
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
KeepRunning=1;
Paused=0;
while LoopCount<NumLoops&&KeepRunning
    LoopCount=LoopCount+1;
    fprintf(['Starting ',num2str(LoopCount),' of ',num2str(NumLoops),' Loops...\n'])
    %Update Status
    fprintf(['Updating File Statuses...\n']);
    for RecNum=1:length(Server_Recording)
        TrackerDir=[Server_Recording(RecNum).dir,dc,'Trackers',dc];
        if exist([TrackerDir,Server_Recording(RecNum).StackSaveName,File2Check])
            FileInfo = dir([TrackerDir,Server_Recording(RecNum).StackSaveName,File2Check]);
            TimeStamp = FileInfo.date;
            TimeStampDateNum=FileInfo.datenum;
            if exist([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                load([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'],'compName')
                AllRecordingStatuses(RecNum)=2;
                AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' Running: ',compName];
                clear compName
            else
                if TimeStampDateNum>DateNumCutoff
                    AllRecordingStatuses(RecNum)=1;
                    AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' Up to Date!'];
                else
                    AllRecordingStatuses(RecNum)=0;
                    AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' Pending...'];
                end
            end
        else
            AllRecordingStatuses(RecNum)=0;
            AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' Missing Tracking File: ',File2Check];
        end
    end
    LastRecording=StartingLastRecording;
    %%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%
    while any(AllRecordingStatuses~=1)&&KeepRunning
        fprintf('=========================================================\n')
        fprintf('=========================================================\n')
        fprintf('=========================================================\n')
        pause(0.1)
        tcpipServer = tcpip(HostIP,Port,'NetworkRole','Server','OutputBufferSize',BufferSize,'TimeOut',TimeOut);
        Status=get(tcpipServer,'status');
        if DetailedStatusUpdates
            fprintf(['Current Server Status: ',Status,'\n']);
        end
        fprintf(['Server Waiting For Connections from Clients...\n']);
        fopen(tcpipServer);
%         KeepChecking=1;
%         while KeepChecking&&KeepRunning
%             try
%                 fopen(tcpipServer);
%                 KeepChecking=0;
%             catch
%                 KeepChecking=1;
%                 if get(AbortButtonHandle,'userdata')
%                     warning on;warning('Aborting Loops...');warning off;
%                     KeepRunning=0;
%                     KeepChecking=0;
%                 end
%                 if KeepRunning
%                         Paused=get(PauseButtonHandle,'userdata');
%                         if Paused
%                             while Paused
%                                 pause(0.1)
%                                 figure(StatusFigure)
%                                 Paused=get(PauseButtonHandle,'userdata')
%                                 if ~Paused
%                                     Paused=0;
%                                 end
%                             end
%                         end
%                     
%                     if get(ClearButtonHandle,'userdata')
%                         %Check all statuses
%                         for RecNum=1:length(Server_Recording)
%                             StackSaveName = Server_Recording(RecNum).StackSaveName;
%                             TrackerDir=[Server_Recording(RecNum).dir,dc,'Trackers',dc];
%                             fprintf(['CHECKING Recording # ',num2str(RecNum),'...'])
%                             if exist([TrackerDir,StackSaveName,File2Check])
%                                 FileInfo = dir([TrackerDir,StackSaveName,File2Check]);
%                                 TimeStamp = FileInfo.date;
%                                 TimeStampDateNum=FileInfo.datenum;
%                                 if exist([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
%                                     load([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'],'compName')
%                                     AllRecordingStatuses(RecNum)=2;
%                                     AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Running: ',compName,' (',TimeStamp,')'];
%                                     clear compName
%                                 else
%                                     if TimeStampDateNum>DateNumCutoff
%                                         AllRecordingStatuses(RecNum)=1;
%                                         AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Up to Date! (',TimeStamp,')'];
%                                     else
%                                         AllRecordingStatuses(RecNum)=0;
%                                         AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' Pending...'];
%                                     end
%                                 end
%                                 fprintf([AllRecordingStatuses_Label{RecNum},'\n']);
%                             else
%                                 AllRecordingStatuses(RecNum)=0;
%                                 AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Missing Tracking File: ',File2Check];
%                                 warning([' ',AnalysisLabel,' ',AllRecordingStatuses_Label{RecNum}]);
%                             end
%                         end
%                         set(ClearButtonHandle,'userdata',0)
%                     end
%                 end
%             end
%         end
        if KeepRunning
            Status=get(tcpipServer,'status');
            if DetailedStatusUpdates
                fprintf(['Current Server Status: ',Status,'\n']);
            end
            pause(0.1)
            fprintf(['Client Requesting Access...\n']);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Update Status
            fprintf(['Updating File Statuses...\n']);
            for RecNum=1:length(Server_Recording)
                TrackerDir=[Server_Recording(RecNum).dir,dc,'Trackers',dc];
                %fprintf(['CHECKING Recording # ',num2str(RecNum),'...'])
                if exist([TrackerDir,Server_Recording(RecNum).StackSaveName,File2Check])
                    FileInfo = dir([TrackerDir,Server_Recording(RecNum).StackSaveName,File2Check]);
                    TimeStamp = FileInfo.date;
                    TimeStampDateNum=FileInfo.datenum;
                    if exist([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                        try
                            load([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'],'compName')
                            AllRecordingStatuses(RecNum)=2;
                            AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Running: ',compName,' (',TimeStamp,')'];
                            clear compName
                        catch
                            warning(['Problem accessing: ',Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                            AllRecordingStatuses(RecNum)=0;
                            AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Missing Tracking File: ',File2Check];
                        end
                    else
                        if TimeStampDateNum>DateNumCutoff
                            AllRecordingStatuses(RecNum)=1;
                            AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Up to Date! (',TimeStamp,')'];
                        else
                            AllRecordingStatuses(RecNum)=0;
                            AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' Pending...'];
                        end
                    end
                    %fprintf([AllRecordingStatuses_Label{RecNum},'\n']);
                else
                    AllRecordingStatuses(RecNum)=0;
                    AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Missing Tracking File: ',File2Check];
                    %warning([' ',AnalysisLabel,' ',AllRecordingStatuses_Label{RecNum}]);
                end
                if RecNum==LastRecording
                    AllRecordingStatuses_Label{RecNum}=[AllRecordingStatuses_Label{RecNum},' Requested!'];
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf(['Writing Status Data...\n']);
            fwrite(tcpipServer,[AllRecordingStatuses,LastRecording],'uint16');
            pause(0.1)
            Status=get(tcpipServer,'status');
            if DetailedStatusUpdates
                fprintf(['Current Server Status: ',Status,'\n']);
            end
            fprintf(['Reading Queue Position...\n']);
            pause(0.1)
            AllData=fread(tcpipServer,length(Server_Recording)+1,'uint16')';
            AllRecordingStatuses=AllData(1:length(Server_Recording));
            LastRecording=AllData(length(Server_Recording)+1);
            Status=get(tcpipServer,'status');
            if DetailedStatusUpdates
                fprintf(['Current Server Status: ',Status,'\n']);
            end
            fprintf(['Client Requested Access to Start Analysis on Recording: ',num2str(LastRecording),'\n']);
            pause(1)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf(['Updating File Statuses...\n']);
            for RecNum=1:length(Server_Recording)
                TrackerDir=[Server_Recording(RecNum).dir,dc,'Trackers',dc];
                %fprintf(['CHECKING Recording # ',num2str(RecNum),'...'])
                if exist([TrackerDir,Server_Recording(RecNum).StackSaveName,File2Check])
                    FileInfo = dir([TrackerDir,Server_Recording(RecNum).StackSaveName,File2Check]);
                    TimeStamp = FileInfo.date;
                    TimeStampDateNum=FileInfo.datenum;
                    if exist([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                        try
                            load([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'],'compName')
                            AllRecordingStatuses(RecNum)=2;
                            AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Running: ',compName,' (',TimeStamp,')'];
                            clear compName
                        catch
                            warning(['Problem accessing: ',Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                            AllRecordingStatuses(RecNum)=0;
                            AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Missing Tracking File: ',File2Check];
                        end
                    else
                        if TimeStampDateNum>DateNumCutoff
                            AllRecordingStatuses(RecNum)=1;
                            AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Up to Date! (',TimeStamp,')'];
                        else
                            AllRecordingStatuses(RecNum)=0;
                            AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' Pending...'];
                        end
                    end
                    %fprintf([AllRecordingStatuses_Label{RecNum},'\n']);
                else
                    AllRecordingStatuses(RecNum)=0;
                    AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Missing Tracking File: ',File2Check];
                    %warning([' ',AnalysisLabel,' ',AllRecordingStatuses_Label{RecNum}]);
                end
                if RecNum==LastRecording
                    AllRecordingStatuses_Label{RecNum}=[AllRecordingStatuses_Label{RecNum},' Requested!'];
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            figure(StatusFigure)
            clf
            subtightplot(1,1,1,[0,0],[0,0],[0,0]),axis off, box off
            set(gcf,'units','normalized','position',FigPosition)
            PauseButtonHandle = uicontrol('Units','Normalized','Position', PauseButtonPosition,'style','togglebutton',...
                'string',['Pause?'],'callback','set(gcbo,''userdata'',1,''string'',''Paused!!'')', ...
                'userdata',0) ;
            ClearButtonHandle = uicontrol('Units','Normalized','Position', ClearButtonPosition,'style','togglebutton',...
                'string',['Clear Status?'],'callback','set(gcbo,''userdata'',1,''string'',''Clearing!!'')', ...
                'userdata',0) ;
            AbortButtonHandle = uicontrol('Units','Normalized','Position', AbortButtonPosition,'style','togglebutton',...
                'string',['Abort?'],'callback','set(gcbo,''userdata'',1,''string'',''Aborting!!'')', ...
                'userdata',0) ;
            count1=1;
            count2=0;
            count1=count1+1;
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Running: ',AnalysisLabel,' for ',num2str(length(Server_Recording)),' Recordings'],...
                'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
            count1=count1+1;
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Server Name: ',ServerCompName],...
                'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
            count1=count1+1;
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Server IP: ',CurrentIP],...
                'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
            count1=count1+1;
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Server Port: ',num2str(Port)],...
                'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
            count1=count1+1;
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Update Cutoff: ',DateTimeCutoff],...
                'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
            for RecNum=1:length(Server_Recording)
                count1=count1+1;
                if AllRecordingStatuses(RecNum)==1
                    if LastRecording==RecNum
                        text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','g','FontWeight','bold','fontsize',FontSize)
                    else
                        text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','g','fontsize',FontSize)
                    end
                elseif AllRecordingStatuses(RecNum)==2
                    if LastRecording==RecNum
                        text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','c','FontWeight','bold','fontsize',FontSize)
                    else
                        text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','b','fontsize',FontSize)
                    end
                else
                    if LastRecording==RecNum
                        text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','c','FontWeight','bold','fontsize',FontSize)
                    else
                        text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','r','fontsize',FontSize)
                    end
                end
                if count1==ColumnHeight
                    count1=0;
                    count2=count2+ColumnHorzPosAddition;
                end
            end
            drawnow
            pause(0.1)
            fprintf(['Resetting Request Server...\n']);
            fclose(tcpipServer);
            Status=get(tcpipServer,'status');
            if DetailedStatusUpdates
                fprintf(['Current Server Status: ',Status,'\n']);
            end
            if LastRecording==length(Server_Recording)
                break
            end
        else
            break
        end
    end
    %%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%
    fprintf('=========================================================\n')
    fprintf('=========================================================\n')
    fprintf(['Finished Loop # ',num2str(LoopCount),' of ',num2str(NumLoops),' :::: NOTE Will Continue to Loop until stopped...Pausing for 1min\n'])
    pause(60)
    fprintf('=========================================================\n')
    fprintf('=========================================================\n')
    fprintf('=========================================================\n')
    fprintf('=========================================================\n')
    fprintf('=========================================================\n')
    fprintf('=========================================================\n')
    fprintf('=========================================================\n')
    fprintf('=========================================================\n')
    fprintf('=========================================================\n')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check all statuses
AllRecordingStatuses=[];
AllRecordingStatuses_Label=[];
for RecNum=1:length(Server_Recording)
    StackSaveName = Server_Recording(RecNum).StackSaveName;
    TrackerDir=[Server_Recording(RecNum).dir,dc,'Trackers',dc];
    fprintf(['CHECKING Recording # ',num2str(RecNum),'...'])
    if exist([TrackerDir,StackSaveName,File2Check])
        FileInfo = dir([TrackerDir,StackSaveName,File2Check]);
        TimeStamp = FileInfo.date;
        TimeStampDateNum=FileInfo.datenum;
        if exist([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
            load([TrackerDir,Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'],'compName')
            AllRecordingStatuses(RecNum)=2;
            AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Running: ',compName,' (',TimeStamp,')'];
            clear compName
        else
            if TimeStampDateNum>DateNumCutoff
                AllRecordingStatuses(RecNum)=1;
                AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Up to Date! (',TimeStamp,')'];
            else
                AllRecordingStatuses(RecNum)=0;
                AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' Pending...'];
            end
        end
        fprintf([AllRecordingStatuses_Label{RecNum},'\n']);
    else
        AllRecordingStatuses(RecNum)=0;
        AllRecordingStatuses_Label{RecNum}=[Server_Recording(RecNum).StackSaveName,' ',AnalysisLabel,' Missing Tracking File: ',File2Check];
        warning([' ',AnalysisLabel,' ',AllRecordingStatuses_Label{RecNum}]);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Status Figure
close all
StatusFigure=figure;
subtightplot(1,1,1,[0,0],[0,0],[0,0]),axis off, box off
set(gcf,'units','normalized','position',FigPosition)
count1=1;
count2=0;
count1=count1+1;
text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Running: ',AnalysisLabel,' for ',num2str(length(Server_Recording)),' Recordings'],...
    'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
count1=count1+1;
text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Server Name: ',ServerCompName],...
    'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
count1=count1+1;
text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Server IP: ',CurrentIP],...
    'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
count1=count1+1;
text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Server Port: ',num2str(Port)],...
    'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
count1=count1+1;
text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,['Update Cutoff: ',DateTimeCutoff],...
    'interpreter','none','color','k','FontWeight','bold','fontsize',FontSize+2)
for RecNum=1:length(Server_Recording)
    count1=count1+1;
    if AllRecordingStatuses(RecNum)==1
        if LastRecording==RecNum
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','g','FontWeight','bold','fontsize',FontSize)
        else
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','g','fontsize',FontSize)
        end
    elseif AllRecordingStatuses(RecNum)==2
        if LastRecording==RecNum
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','c','FontWeight','bold','fontsize',FontSize)
        else
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','b','fontsize',FontSize)
        end
    else
        if LastRecording==RecNum
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','c','FontWeight','bold','fontsize',FontSize)
        else
            text(count2+ColumnHorzSpacing,1-count1*ColumnVertSpacing,[num2str(RecNum),': ',AllRecordingStatuses_Label{RecNum}],'interpreter','none','color','r','fontsize',FontSize)
        end
    end
    if count1==ColumnHeight
        count1=0;
        count2=count2+ColumnHorzPosAddition;
    end
end
drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
