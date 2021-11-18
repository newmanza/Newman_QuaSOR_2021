%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Server/Client Parameters (NOTE! this must match the server parameters)
[OS,dc,ClentCompName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(1);
[ServerIP,ServerName]=Server_Picker(LabDefaults);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[PortChoice, checking] = listdlg('PromptString','Select a port:','SelectionMode','single','ListString',PortOptionsText,'ListSize', [600 600]);
Port=PortOptions(PortChoice);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Proceed=questdlg({'Please Confirm the following settings';['Num Recordings: ',num2str(length(Client_Recording))];['Analysis: ',AnalysisLabel];['Server: ',ServerName];['IP: ',ServerIP];['IP: ',num2str(Port)]},...
    'Please Confirm the following settings','Proceed','Hold on','Proceed');
if strcmp(Proceed,'Proceed')
    disp(['Starting Network Client Mode for: ',AnalysisLabel])
else
    error('Holding!')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[myPool]=ParPoolManager([],myPool);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BufferSize=1024;
%TimeOut=inf;
TimeOut=1000;
NumLoops=10;%Will prevent from going on forever
ConnectionAttempts=10;
OverwriteData=1;
AllRecordingStatuses=zeros(1,length(Client_Recording));
LoopCount=0;
TestMode=0;
BrokeLoop=0;
AbortButton=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OverallTimeHandle=tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Run this on the Client
fprintf('=========================================================\n')
fprintf('=========================================================\n')
fprintf('=========================================================\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except myPool dc OS compName ClentCompName MatlabVersion MatlabVersionYear ScreenSize CurrentScratchDir ScratchDir LabDefaults...
    CurrentParentDir ParentDir ParentDir1 ParentDir2 ParentDir3...
    Recording Client_Recording Server_Recording currentFolder File2Check AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions BatchMode AnalysisPartsChoiceOptions AnalysisPartOptions RecordingChoiceOptions Function RecordingNum RecordingNum1 RecordingNums LastRecording...
    LoopCount File2Check AnalysisLabel AnalysisLabelShort Function ErrorTolerant BrokeLoop AbortButton BufferSize Port PortChoice PortOptions PortOptionsText PortRange PortChoice PortOptions PortOptionsText TimeOut NumLoops ServerIP ServerName BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
    RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode TestMode BrokeLoop AbortButton
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while LoopCount<NumLoops
    LoopCount=LoopCount+1;
    BadConnection=0;
    fprintf(['Starting ',num2str(LoopCount),' of ',num2str(NumLoops),' Loops...\n'])    
    while any(AllRecordingStatuses~=1)
        LastRecording=0;
        while LastRecording<length(Client_Recording)
            if BadConnection<ConnectionAttempts
                fprintf('=========================================================\n')
                fprintf('=========================================================\n')
                fprintf('=========================================================\n')
                tcpipClient = tcpip(ServerIP,Port,'NetworkRole','Client','InputBufferSize',BufferSize,'TimeOut',TimeOut);
                Status=get(tcpipClient,'status');
                %CHECK SERVER STATUS FIRST!
                fprintf(['Opening Server Connection...\n']);
                try
                    if ~exist('TestMode')
                        TestMode=0;
                    end
                    fopen(tcpipClient)
                    pause(0.1)
                    Status=get(tcpipClient,'status');
                    AvailableBytes=get(tcpipClient,'BytesAvailable');
                    ByteOrder=get(tcpipClient,'ByteOrder');
                    fprintf(['Server Connection Established...\n']);
                    fprintf(['Retrieving Data...\n']);
                    try
                        AllData=fread(tcpipClient,length(Client_Recording)+1,'uint16')';
                        AllRecordingStatuses=AllData(1:length(Client_Recording));
                        LastRecording=AllData(length(Client_Recording)+1);
                        LastRecording = LastRecording+1;
                        fprintf(['Starting Analysis on Recording: ',num2str(LastRecording),'\n']);
                        fwrite(tcpipClient,[AllRecordingStatuses,LastRecording],'uint16')
                        pause(0.1)
                        fprintf(['Closing Server Connection...\n']);
                        fclose(tcpipClient);
                        pause(2);
                        if LastRecording>0
                            fprintf(['CHECKING Recording # ',num2str(LastRecording),' File: ',Client_Recording(LastRecording).StackSaveName,'\n'])
                            TrackerDir=[Client_Recording(LastRecording).dir,dc,'Trackers',dc];
                            if exist([TrackerDir,Client_Recording(LastRecording).StackSaveName,File2Check])
                                FileInfo = dir([TrackerDir,Client_Recording(LastRecording).StackSaveName,File2Check]);
                                TimeStamp = FileInfo.date;
                                fprintf([AnalysisLabel,' Found (',TimeStamp,')\n']);
                            else
                                fprintf('\n');warning([' ',AnalysisLabel,' NOT Found']);fprintf('\n');
                            end
                        end
                    catch
                        fclose(tcpipClient);
                        fprintf('\n');fprintf('\n');fprintf('\n');
                        fprintf('\n');warning(['Error!!']);fprintf('\n');fprintf('\n');warning(['Error!!']);fprintf('\n');fprintf('\n');warning(['Error!!']);fprintf('\n');
                        warning('Connection request timed out!')
                        fprintf('\n');warning(['Function threw an Error Skipping but will return in next loop']);fprintf('\n');
                        fprintf('\n');warning(['Error!!']);fprintf('\n');fprintf('\n');warning(['Error!!']);fprintf('\n');fprintf('\n');warning(['Error!!']);fprintf('\n');
                        BrokeLoop=0;
                        error('Connection request timed out');
                    end
                    %Run the Analysis
                    if AllRecordingStatuses(LastRecording)==0
                        try
                            %Core Code here, should be able to swap
                            TrackerDir=[Client_Recording(LastRecording).dir,dc,'Trackers',dc];
                            if logical(exist([TrackerDir,Client_Recording(LastRecording).StackSaveName,File2Check])&&OverwriteData)
                                fprintf(['Starting Analysis for File # ',num2str(LastRecording),' ',Client_Recording(LastRecording).StackSaveName,'\n']);
                                disp([Client_Recording(LastRecording).dir]);
                                RecordingNum=LastRecording;
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                TimeStamp=datestr(now);
                                fprintf('Saving Currently Running Tracking File...')
                                TrackerDir=[Client_Recording(LastRecording).dir,dc,'Trackers',dc];
                                compName=ClentCompName;
                                save([TrackerDir,Client_Recording(LastRecording).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'],'TimeStamp','OS','compName','MatlabVersion','MatlabVersionYear')
                                fprintf('Finished!\n')
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                if TestMode==1
                                    warning('TEST MODE!')
                                elseif TestMode==2
                                    warning('TEST MODE!')
                                    error('Test Mode')
                                else
                                    run(Function)
                                end
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                fprintf(['Finished Recording # ',num2str(LastRecording),' ',Client_Recording(LastRecording).StackSaveName,'\n'])
                                fprintf(['Finished Recording # ',num2str(LastRecording),' ',Client_Recording(LastRecording).StackSaveName,'\n'])
                                fprintf(['Finished Recording # ',num2str(LastRecording),' ',Client_Recording(LastRecording).StackSaveName,'\n'])
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                SaveName=Client_Recording(LastRecording).SaveName;
                                StackSaveName=Client_Recording(LastRecording).StackSaveName;
                                ImageSetSaveName=Client_Recording(LastRecording).ImageSetSaveName;
                                ModalitySuffix=Client_Recording(LastRecording).ModalitySuffix;
                                BoutonSuffix=Client_Recording(LastRecording).BoutonSuffix;
                                LoadDir=Client_Recording(LastRecording).dir;
                                TrackerDir=[Client_Recording(LastRecording).dir,dc,'Trackers',dc];
                                if ~exist(TrackerDir)
                                    mkdir(TrackerDir)
                                end
                                fprintf(['Updating ',StackSaveName,File2Check,'...'])
                                Tracker=1;
                                [OS,dc,ClentCompName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(0);
                                compName=ClentCompName;
                                CurrentComputer=compName;
                                CurrentOS=OS;
                                BatchChoice=[];
                                save([TrackerDir,dc,StackSaveName,File2Check],'Tracker','CurrentComputer','CurrentOS','BatchChoice'); 
                                FileInfo = dir([TrackerDir,StackSaveName,File2Check]);
                                TimeStamp = FileInfo.date;
                                fprintf('Finished!\n')
                                disp([StackSaveName,File2Check,' Last updated: ',TimeStamp,' [',CurrentComputer,' (',CurrentOS,')]']);  
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %Removing Currently Running File...
                                TrackerDir=[Client_Recording(LastRecording).dir,dc,'Trackers',dc];
                                if exist([TrackerDir,Client_Recording(LastRecording).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                                    fprintf('Deleting Currently Running Tracking File...')
                                    delete([TrackerDir,Client_Recording(LastRecording).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                                    fprintf('Finished!\n')
                                end
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                clearvars -except myPool dc OS compName ClentCompName MatlabVersion MatlabVersionYear ScreenSize CurrentScratchDir ScratchDir LabDefaults...
                                    CurrentParentDir ParentDir ParentDir1 ParentDir2 ParentDir3...
                                    Recording Client_Recording Server_Recording currentFolder File2Check AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions BatchMode AnalysisPartsChoiceOptions AnalysisPartOptions RecordingChoiceOptions Function RecordingNum RecordingNum1 RecordingNums LastRecording...
                                    LoopCount File2Check AnalysisLabel AnalysisLabelShort Function ErrorTolerant BrokeLoop AbortButton BufferSize Port PortChoice PortOptions PortOptionsText PortRange PortChoice PortOptions PortOptionsText TimeOut NumLoops ServerIP ServerName BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
                                    RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode TestMode BrokeLoop AbortButton
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            else
                                fprintf(['Skipping File # ',num2str(LastRecording),' ',Client_Recording(LastRecording).StackSaveName,'\n']);
                            end
                        catch
                            if ErrorTolerant
                                fprintf('\n');fprintf('\n');fprintf('\n');
                                fprintf('\n');warning(['Error!!']);fprintf('\n');fprintf('\n');warning(['Error!!']);fprintf('\n');fprintf('\n');warning(['Error!!']);fprintf('\n');
                                fprintf('\n');warning(['Function threw an Error Skipping but will return in next loop']);fprintf('\n');
                                fprintf('\n');warning(['Error!!']);fprintf('\n');fprintf('\n');warning(['Error!!']);fprintf('\n');fprintf('\n');warning(['Error!!']);fprintf('\n');
                                TrackerDir=[Client_Recording(LastRecording).dir,dc,'Trackers',dc];
                                if exist([TrackerDir,Client_Recording(LastRecording).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                                    fprintf('\n');
                                    warning('Deleting Currently Running Tracking File...')
                                    delete([TrackerDir,Client_Recording(LastRecording).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                                    warning('Sucessfully Deleted!')
                                end
                                if exist([ScratchDir,Client_Recording(LastRecording).StackSaveName,dc,'TempFiles',dc])
                                    warning('Deleting Temp File Directory...')
                                    rmdir([ScratchDir,Client_Recording(LastRecording).StackSaveName,dc,'TempFiles',dc],'s');
                                    warning('Sucessfully Deleted!')
                                end
                                fprintf('\n');fprintf('\n');fprintf('\n');fprintf('\n');
                                BrokeLoop=1;
                            else
                                fprintf('\n');fprintf('\n');fprintf('\n');
                                fprintf('\n');warning(['Error!!']);fprintf('\n');fprintf('\n');warning(['Error!!']);fprintf('\n');fprintf('\n');warning(['Error!!']);fprintf('\n');
                                fprintf('\n');warning(['Function threw an Error Skipping but will return in next loop']);fprintf('\n');
                                fprintf('\n');warning(['Error!!']);fprintf('\n');fprintf('\n');warning(['Error!!']);fprintf('\n');fprintf('\n');warning(['Error!!']);fprintf('\n');
                                BrokeLoop=1;
                                error('Currently In Error Intolerant Mode: Breaking Loop')
                            end
                        end
                    elseif AllRecordingStatuses(LastRecording)==2
                        fprintf(['File # ',num2str(LastRecording),' ',Client_Recording(LastRecording).StackSaveName,' is being analyzed elsewhere! Moving on to next file...\n'])
                    else
                        fprintf(['File # ',num2str(LastRecording),' ',Client_Recording(LastRecording).StackSaveName,' is up to date! Moving on to next file...\n'])
                    end
                catch
                    if ErrorTolerant&&~BrokeLoop
                        BadConnection=BadConnection+1;
                        warning(['Unable to connect to server! (',num2str(ConnectionAttempts-BadConnection),' attempts remaining) Pausing for 2 min'])
                        pause(120)
                        break;
                    elseif ~ErrorTolerant&&~BrokeLoop
                        BadConnection=BadConnection+1;
                        warning(['Unable to connect to server! (',num2str(ConnectionAttempts-BadConnection),' attempts remaining) Pausing for 2 min'])
                        pause(120)
                        break;
                    elseif ErrorTolerant&&BrokeLoop
                        BadConnection=BadConnection+1;
                        warning(['Unable to connect to server! (',num2str(ConnectionAttempts-BadConnection),' attempts remaining) Pausing for 2 min'])
                        pause(120)
                        break;
                    elseif ~ErrorTolerant&&BrokeLoop
                        error('Currently In Error Intolerant Mode: Breaking Loop')
                    end
                end
            end
        end
        if BadConnection==ConnectionAttempts
             warning('Exiting Client Mode')
            break
        end
    end
    fprintf('=========================================================\n')
    fprintf('=========================================================\n')
    fprintf(['Finished ',num2str(LoopCount),' of ',num2str(NumLoops),' Loops...\n'])
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
