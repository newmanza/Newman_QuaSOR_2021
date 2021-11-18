%I would recommend "collasping" all folds
cont=input('Do you really want to start from the beginning? ');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Zach's To-Do
%Bleach corr plot record
%Metadata loading
%release BF Reader
%widefield setting defaults
%Event and QuaSOR Tutorial annotations
%Demon setting explainer
%Notes
%Dataviewer to Flag
%edit feature
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STAGE 0 Data Intake and Analysis Preparation
% Before Running anything here make sure you have run Quantal_Analysis_Preparation.m
% you can below or in standalone mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STAGE 1 Bouton Type-Specifc Analysis
% Part 0: File Preparation
% Part 1: Movie Registration
% Part 2: Event Detection
% Part 3: QuaSOR Fitting
% Part 4: QuaSOR Evaluation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STAGE 2 Bouton-Type Merging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STAGE 3 Modality Merging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%              STAGE 1               %
%              Part 0                %
%            Preparation             %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%
AnalysisLabel='Preparation';
AnalysisLabelShort='Prep';
BatchMode='Off';
Function='Quantal_Analysis_Preparation.m';
if ~exist(Function)
    warning([Function,' is Missing!'])
    warning('Maybe Just Need to Update AddPath!')
    error([Function,' is Missing!'])
end
%%%%%%%%%%%%%%%%%%
%Define Analysis Parts
clear AnalysisPartsChoiceOptions AnalysisPartOptions
for zzzz=1:1
    a=0;
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Complete'];
           AnalysisPartOptions{a}=[1:9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Setup, find files and SAVE ONLY'];
           AnalysisPartOptions{a}=[1,9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Episode Checking And Basic Info and SAVE ONLY'];
           AnalysisPartOptions{a}=[2,9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Protocol Info and SAVE ONLY'];
           AnalysisPartOptions{a}=[3,9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Analysis Region Selection and SAVE ONLY'];
           AnalysisPartOptions{a}=[4,9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Registration Setup and SAVE ONLY'];
           AnalysisPartOptions{a}=[5,9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Treatment Marker and SAVE ONLY'];
           AnalysisPartOptions{a}=[6,9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' IbIs Merge and SAVE ONLY'];
           AnalysisPartOptions{a}=[7,9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Batch File List Export ONLY'];
           AnalysisPartOptions{a}=[8];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Save ONLY'];
           AnalysisPartOptions{a}=[9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Episode Checking And Basic Info to END'];
           AnalysisPartOptions{a}=[2:9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Protocol Info to END'];
           AnalysisPartOptions{a}=[3:9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Analysis Region Selection to END'];
           AnalysisPartOptions{a}=[4:9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Registration Setup to END'];
           AnalysisPartOptions{a}=[5:9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Treatment Marker to END'];
           AnalysisPartOptions{a}=[6:9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' IbIs Merge to END'];
           AnalysisPartOptions{a}=[7:9];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Batch File List Export And SAVE ONLY'];
           AnalysisPartOptions{a}=[8:9];
    %%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunningPreparation=1;
while RunningPreparation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    run('Quantal_Analysis_Preparation.m')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RepeatPrep = questdlg('Redo Quantal Analysis Preparation?','Redo Preparation?','Continue','Redo','Cancel','Continue');
    if strcmp(RepeatPrep,'Continue')
        RunningPreparation=0;
    elseif strcmp(RepeatPrep,'Redo')
        RunningPreparation=1;
    else strcmp(RepeatPrep,'Cancel')
        error('Stopping!');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %JUST Cleanup ScratchDir
                            for RecordingNum=1:length(Recording)
                                warning(['Cleanup for Rec#',num2str(RecordingNum)])
                                if exist([ScratchDir,Recording(RecordingNum).StackSaveName,dc,'TempFiles',dc])
                                    warning('Deleting Temp File Directory...')
                                    rmdir([ScratchDir,Recording(RecordingNum).StackSaveName,dc,'TempFiles',dc],'s');
                                end
                                if exist([ScratchDir,Recording(RecordingNum).StackSaveName,dc])
                                    warning('Deleting StackSaveName-Specific ScrachDir Directory...')
                                    rmdir([ScratchDir,Recording(RecordingNum).StackSaveName,dc],'s');
                                end
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                clearvars -except myPool dc OS compName ClentCompName MatlabVersion MatlabVersionYear ScreenSize CurrentScratchDir ScratchDir LabDefaults...
                                    CurrentParentDir ParentDir ParentDir1 ParentDir2 ParentDir3...
                                    Recording Client_Recording Server_Recording currentFolder File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions BatchMode AnalysisPartsChoiceOptions RecordingChoiceOptions Function RecordingNum LastRecording...
                                    LoopCount File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort Function ErrorTolerant BrokeLoop AbortButton AdjustOnly BufferSize Port PortChoice PortOptions PortOptionsText PortRange PortChoice PortOptions PortOptionsText TimeOut NumLoops ServerIP ServerName DateNumCutoff DateTimeCutoff BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
                                    RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode AdjustOnly
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%               STAGE 1              %
%               Part 1               %
%               Movie                %
%            Registration            %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%
File2Check='_RegistrationTracker.mat';
AnalysisLabel='Registration';
AnalysisLabelShort='Reg';
BatchMode='Complete';
Function='Quantal_Analysis_Registration.m';
PortRange=[4001:4010];
if ~exist(Function)
    warning([Function,' is Missing!'])
    warning('Maybe Just Need to Update AddPath!')
    error([Function,' is Missing!'])
end
if ~exist('Recording')
    warning('You Must LOAD a Recording List first!')
    error('You Must LOAD a Recording List first!')
end
%%%%%%%%%%%%%%%%%%
%Define Analysis Parts
clear AnalysisPartsChoiceOptions AnalysisPartOptions
for zzzz=1:1
    a=0;
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Complete Registration, BleachCorr/DeltaF, Figures, and Movies'];
           AnalysisPartOptions{a}=[1:4];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Complete Registration, BleachCorr/DeltaF, Figures, Movies, and Evaluation'];
           AnalysisPartOptions{a}=[1:5];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Adjust Registration Settings'];
           AnalysisPartOptions{a}=[0];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' BleachCorr/DeltaF, Figures and Movies ONLY'];
           AnalysisPartOptions{a}=[2:4];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Figures and Movies Only'];
           AnalysisPartOptions{a}=[3:4];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Registration Only'];
           AnalysisPartOptions{a}=[1];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' BleachCorr/DeltaF Only'];
           AnalysisPartOptions{a}=[2];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Figures Only'];
           AnalysisPartOptions{a}=[3];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Movies Only'];
           AnalysisPartOptions{a}=[4];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Evaluate Registration'];
           AnalysisPartOptions{a}=[5];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Adjust Settings, Complete Registration, BleachCorr/DeltaF, Figures, and Movies'];
           AnalysisPartOptions{a}=[0:4];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Adjust Settings, Complete Registration, BleachCorr/DeltaF, Figures, Movies, and Evaluation'];
           AnalysisPartOptions{a}=[0:5];
    %%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main Batch Handling
run('Batching_Script.m')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %IMPORTANT If you manually break the loop in NETWORK MODE run this to make sure file is available for other clients!
                            ClearFiles=input('<1> to delete Trackers and ScratchDir Files? ');
                            if ClearFiles
                                warning on
                                TrackerDir=[Recording(RecordingNum).dir,dc,'Trackers',dc];
                                if exist([TrackerDir,dc,Recording(RecordingNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                                    fprintf('\n');
                                    warning('Deleting Tracking File...')
                                    delete([TrackerDir,dc,Recording(RecordingNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                                    fprintf('\n');
                                end
                                if exist([ScratchDir,Recording(RecordingNum).StackSaveName,dc,'TempFiles',dc])
                                    warning('Deleting Temp File Directory...')
                                    rmdir([ScratchDir,Recording(RecordingNum).StackSaveName,dc,'TempFiles',dc],'s');
                                end
                                if exist([ScratchDir,Recording(RecordingNum).StackSaveName,dc])
                                    warning('Deleting StackSaveName-Specific ScrachDir Directory...')
                                    rmdir([ScratchDir,Recording(RecordingNum).StackSaveName,dc],'s');
                                end
                            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%               STAGE 1              %
%               Part 2               %
%               Event                %
%              Detection             %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Event Detection
%%%%%%%%%%%%%%%%%%
File2Check='_EventDetectionTracker.mat';
AnalysisLabel='EventDetection';
AnalysisLabelShort='Detect';
BatchMode='Complete';
Function='Quantal_Analysis_Event_Detection.m';
PortRange=[4011:4020];
if ~exist(Function)
    warning([Function,' is Missing!'])
    warning('Maybe Just Need to Update AddPath!')
    error([Function,' is Missing!'])
end
if ~exist('Recording')
    warning('You Must LOAD a Recording List first!')
    error('You Must LOAD a Recording List first!')
end
%%%%%%%%%%%%%%%%%%
%Define Analysis Parts
clear AnalysisPartsChoiceOptions AnalysisPartOptions
for zzzz=1:1
    a=0;
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Define/Edit Settings Only (MUST RUN FIRST)'];
           AnalysisPartOptions{a}=[0];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Run Detection, Pixel Max Mapping, Movies'];
           AnalysisPartOptions{a}=[1,4];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Run Detection and Manual Cleanup'];
           AnalysisPartOptions{a}=[1:2];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Pixel Max Mapping ONLY and Movies'];
           AnalysisPartOptions{a}=[3,4];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Manual Cleanup, Pixel Max Mapping, and Movies'];
           AnalysisPartOptions{a}=[2,3,4];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Movies Only'];
           AnalysisPartOptions{a}=[4];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Run Detection Only'];
           AnalysisPartOptions{a}=[1];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Manual Cleanup Only'];
           AnalysisPartOptions{a}=[2];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Pixel Max Mapping ONLY'];
           AnalysisPartOptions{a}=[3];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Movies Only'];
           AnalysisPartOptions{a}=[4];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Evaluate Event Detection'];
           AnalysisPartOptions{a}=[5];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Detection, Pixel Max Mapping, Movies and Evaluation'];
           AnalysisPartOptions{a}=[1,4,5];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Run Setup, Detection, Pixel Max Mapping, Movies and Evaluation'];
           AnalysisPartOptions{a}=[0,1,4,5];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Run Setup, Detection, Manual Cleanup, Pixel Max Mapping, and Movies'];
           AnalysisPartOptions{a}=[0,1,2,3,4];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Run Setup, Detection, Manual Cleanup, Pixel Max Mapping, Movies and Evaluation NOT RECOMMENDED'];
           AnalysisPartOptions{a}=[0:5];
    %%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main Batch Handling
run('Batching_Script.m')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %IMPORTANT If you manually break the loop in NETWORK MODE run this to make sure file is available for other clients!
                            ClearFiles=input('<1> to delete Trackers and ScratchDir Files? ');
                            if ClearFiles
                                warning on
                                TrackerDir=[Recording(RecordingNum).dir,dc,'Trackers',dc];
                                if exist([TrackerDir,dc,Recording(RecordingNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                                    fprintf('\n');
                                    warning('Deleting Tracking File...')
                                    delete([TrackerDir,dc,Recording(RecordingNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                                    fprintf('\n');
                                end
                                if exist([ScratchDir,Recording(RecordingNum).StackSaveName,dc])
                                    warning('Deleting StackSaveName-Specific ScrachDir Directory...')
                                    rmdir([ScratchDir,Recording(RecordingNum).StackSaveName,dc],'s');
                                end
                            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%               STAGE 1              %
%               Part 3               %
%               QuaSOR               %
%               Fitting              %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%
File2Check='_QuaSOR_Tracker.mat';
AnalysisLabel='QuaSOR';
AnalysisLabelShort='QuaSOR';
BatchMode='Complete';
Function='Quantal_Analysis_QuaSOR.m';
PortRange=[4021:4030];
if ~exist(Function)
    warning([Function,' is Missing!'])
    warning('Maybe Just Need to Update AddPath!')
    error([Function,' is Missing!'])
end
if ~exist('Recording')
    warning('You Must LOAD a Recording List first!')
    error('You Must LOAD a Recording List first!')
end
%%%%%%%%%%%%%%%%%%
%Define Analysis Parts
clear AnalysisPartsChoiceOptions AnalysisPartOptions
for zzzz=1:1
    a=0;
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Define/Edit Settings Only (MUST RUN FIRST)'];
           AnalysisPartOptions{a}=[0];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Run QuaSOR, Maps, Auto AZ Detect, Fit Evaluation Calcs and Movies'];
           AnalysisPartOptions{a}=[1:5];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Run QuaSOR, Maps, Auto AZ Detect, Fit Evaluation Calcs, Movies and Evaluation'];
           AnalysisPartOptions{a}=[1:6];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Run QuaSOR and Maps'];
           AnalysisPartOptions{a}=[1:2];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Run QuaSOR, Maps, and Auto AZ Detect'];
           AnalysisPartOptions{a}=[1:3];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Maps, Auto AZ Detect and Fit Evaluation Calcs Only'];
           AnalysisPartOptions{a}=[2:4];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Maps, Auto AZ Detect, Fit Evaluation Calcs and Movies Only'];
           AnalysisPartOptions{a}=[2:5];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Fit Evaulation Calcs and Movies Only'];
           AnalysisPartOptions{a}=[4:5];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Run QuaSOR Only'];
           AnalysisPartOptions{a}=[1];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Maps Only'];
           AnalysisPartOptions{a}=[2];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Auto AZ Detect Only'];
           AnalysisPartOptions{a}=[3];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Fit Evaluation Calcs Only'];
           AnalysisPartOptions{a}=[4];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Movies Only'];
           AnalysisPartOptions{a}=[5];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Evaluate QuaSOR ONLY'];
           AnalysisPartOptions{a}=[6];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Custom Maps ONLY'];
           AnalysisPartOptions{a}=[7];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Run Setup, QuaSOR, Maps, Auto AZ Detect, Fit Evaluation Calcs and Movies'];
           AnalysisPartOptions{a}=[0:5];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Run Setup, QuaSOR, Maps, Auto AZ Detect, Fit Evaluation Calcs, Movies and Evaluation'];
           AnalysisPartOptions{a}=[0:6];
    %%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main Batch Handling
run('Batching_Script.m')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %IMPORTANT If you manually break the loop in NETWORK MODE run this to make sure file is available for other clients!
                            ClearFiles=input('<1> to delete Trackers and ScratchDir Files? ');
                            if ClearFiles
                                warning on
                                TrackerDir=[Recording(RecordingNum).dir,dc,'Trackers',dc];
                                if exist([TrackerDir,dc,Recording(RecordingNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                                    fprintf('\n');
                                    warning('Deleting Tracking File...')
                                    delete([TrackerDir,dc,Recording(RecordingNum).StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
                                    fprintf('\n');
                                end
                                if exist([ScratchDir,Recording(RecordingNum).StackSaveName,dc])
                                    warning('Deleting StackSaveName-Specific ScrachDir Directory...')
                                    rmdir([ScratchDir,Recording(RecordingNum).StackSaveName,dc],'s');
                                end
                            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %FORCE Update some settings manually
                            ForceUpdateChoice = questdlg(['Are you ABSOLUTELY sure you want to force update ',AnalysisLabel,' settings?'],...
                                'Force Update?','Nope','Force Update','Definitely Not','Nope');
                            switch ForceUpdateChoice
                                case 'Force Update'
                                    for RecordingNum=1:length(Recording)
                                        SaveName=Recording(RecordingNum).SaveName;
                                        StackSaveName=Recording(RecordingNum).StackSaveName;
                                        ImageSetSaveName=Recording(RecordingNum).ImageSetSaveName;
                                        ModalitySuffix=Recording(RecordingNum).ModalitySuffix;
                                        BoutonSuffix=Recording(RecordingNum).BoutonSuffix;
                                        LoadDir=Recording(RecordingNum).dir;
                                        SaveDir=[LoadDir,dc,ModalitySuffix,BoutonSuffix,dc];
                                        SaveDir1=[LoadDir,dc,ModalitySuffix,dc];
                                        SaveDir2=[LoadDir,dc];
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        FileSuffix='_QuaSOR_Data.mat';
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        ForceUpdateConfirm = questdlg({['Updating a ',AnalysisLabel,' Setting in:'];...
                                            ['File: ',FileSuffix];['For StackSaveName: ',StackSaveName];'OK to proceed?'},...
                                            'Force Update?','Nope','Force Update','Definitely Not','Nope');
                                        switch ForceUpdateConfirm
                                            case 'Force Update'
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                 fprintf(['Loading: ',StackSaveName,FileSuffix,'...'])
%                                                 load([SaveDir,dc,StackSaveName,FileSuffix],'QuaSOR_Parameters')
%                                                 fprintf('Finished!\n')
%                                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                 disp(['QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust = ',num2str(QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust)])
%                                                 commandwindow
%                                                 cont=input('<Enter> to Continue...');
%                                                 QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust=-1.5;
%                                                 disp(['QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust = ',num2str(QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust)])
%                                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                 fprintf(['Saving: ',StackSaveName,FileSuffix,'...'])
%                                                 save([SaveDir,dc,StackSaveName,FileSuffix],'QuaSOR_Parameters','-append')
%                                                 fprintf('Finished!\n')
%                                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                FileSuffix='_QuaSOR_AZs.mat';
                                                fprintf(['Loading: ',FileSuffix,'...'])
                                                load([SaveDir,dc,StackSaveName,FileSuffix],'QuaSOR_Auto_AZ_Settings')
                                                fprintf('Finished!\n')
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                disp(['QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index = ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index)])
                                                commandwindow
                                                cont=input('<Enter> to Continue...');
                                                QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index=8;
                                                disp(['QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index = ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index)])
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                fprintf(['Saving: ',StackSaveName,FileSuffix,'...'])
                                                save([SaveDir,dc,StackSaveName,FileSuffix],'QuaSOR_Auto_AZ_Settings','-append')
                                                fprintf('Finished!\n')
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        end
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        clearvars -except myPool dc OS compName ClentCompName MatlabVersion MatlabVersionYear ScreenSize CurrentScratchDir ScratchDir LabDefaults...
                                            CurrentParentDir ParentDir ParentDir1 ParentDir2 ParentDir3...
                                            Recording Client_Recording Server_Recording currentFolder File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions BatchMode AnalysisPartsChoiceOptions RecordingChoiceOptions Function RecordingNum LastRecording...
                                            LoopCount File2Check DateNumCutoff AnalysisLabel AnalysisLabelShort Function ErrorTolerant BrokeLoop AbortButton AdjustOnly BufferSize Port PortChoice PortOptions PortOptionsText PortRange PortChoice PortOptions PortOptionsText TimeOut NumLoops ServerIP ServerName DateNumCutoff DateTimeCutoff BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
                                            RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode AdjustOnly
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    end
                            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%               STAGE 1              %
%               Part 4               %
%               Overall              %
%             Evaluation             %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%
File2Check='_Quantal_Evaluation_Tracker.mat';
AnalysisLabel='Quantal Analysis Evaluation';
AnalysisLabelShort='QuantalEval';
BatchMode='Simple';
Function='Quantal_Analysis_Evaluation.m';
PortRange=[4031:4040];
if ~exist(Function)
    warning([Function,' is Missing!'])
    warning('Maybe Just Need to Update AddPath!')
    error([Function,' is Missing!'])
end
if ~exist('Recording')
    warning('You Must LOAD a Recording List first!')
    error('You Must LOAD a Recording List first!')
end
%%%%%%%%%%%%%%%%%%
%Define Analysis Parts
clear AnalysisPartsChoiceOptions AnalysisPartOptions
for zzzz=1:1
    a=0;
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel];
           AnalysisPartOptions{a}=[1];
    %%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main Batch Handling
run('Batching_Script.m')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%              STAGE 2               %
%              Part 1                %
%           IbIs Merging             %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%
File2Check='_Quantal_BoutonMerge_Tracker.mat';
AnalysisLabel='Bouton Merging';
AnalysisLabelShort='BoutonMerge';
BatchMode='Complete';
Function='Quantal_Analysis_BoutonMerging.m';
PortRange=[4041:4050];
if ~exist(Function)
    warning([Function,' is Missing!'])
    warning('Maybe Just Need to Update AddPath!')
    error([Function,' is Missing!'])
end
if ~exist('Recording')
    warning('You Must LOAD a Recording List first!')
    error('You Must LOAD a Recording List first!')
end
%%%%%%%%%%%%%%%%%%
%Define Analysis Parts
clear AnalysisPartsChoiceOptions AnalysisPartOptions
for zzzz=1:1
    a=0;
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Merge Bouton Data and Make BoutonMerge Maps'];
           AnalysisPartOptions{a}=[1,2];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Merge Bouton Data ONLY'];
           AnalysisPartOptions{a}=[1];
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Make BoutonMerge Maps ONLY'];
           AnalysisPartOptions{a}=[2];
    %%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main Batch Handling
run('Batching_Script.m')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        warning('I would recommend generating a new RecordingLists_Stage3_User.m file')
                        warning('You can just edit your Part2 list file entry as follows:')
                        warning('Recording structure now requires three new fields: ModalitySuffixes, IncludeSpont, SplitHighFreqMod')
                        warning('ex: ModalitySuffixes={''_0.2Hz''}; for each Protocol to merge')
                        warning('ex: IncludeSpont=[0]; (1/0) one value for each ModalitySuffix entry above')
                        warning('USE if you want to include spont from evoked protocol')
                        warning('ex: SplitHighFreqMod=1; (1/0) to activate defaults for multiple high freq protocols')
                        % 
                        % 
                        % RecNum=RecNum+1;
                        % Recording(RecNum).dir=               [CurrentParentDir,'201216 P1LA3M4 attP2_OK6_GC6_LFvHF_1'];
                        % Recording(RecNum).SaveName=          'attP2_OK6_GC6_LFvHF_1';
                        % Recording(RecNum).ModalitySuffix=    []; %MOVE TO ModalitySuffixes
                        % Recording(RecNum).BoutonSuffix=      []; %EMPTY
                        % Recording(RecNum).ImageSetSaveName=  []; %EMPTY
                        % Recording(RecNum).StackSaveName=     'attP2_OK6_GC6_LFvHF_1'; %Same as SaveName
                        % %%%%%%%%%%
                        % Recording(RecNum).ModalitySuffixes=  {'_02Hz','_5Hz20s'}; %INCLUDE ALL YOU WANT TO MERGE MUST BE CELL
                        % Recording(RecNum).IncludeSpont=      [0,1]; (0/1) for each suffix entry above ONLY NEEDED FOR Evoked, recommended for streaming with evoked not low freq episodice evoked
                        % Recording(RecNum).SplitHighFreqMod=  0; (1/0)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    %
%                                    %
%                                    %
%                                    %
%              STAGE 3               %
%              Part 1                %
%         Modality Merging           %
%                                    %
%                                    %
%                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%
File2Check='_Quantal_Modality_Merge_Tracker.mat';
AnalysisLabel='Modality Merge';
AnalysisLabelShort='Modality Merge';
BatchMode='Complete';
Function='Quantal_Analysis_Modality_Merge.m';
PortRange=[4051:4060];
if ~exist(Function)
    warning([Function,' is Missing!'])
    warning('Maybe Just Need to Update AddPath!')
    error([Function,' is Missing!'])
end
if ~exist('Recording')
    warning('You Must LOAD a Recording List first!')
    error('You Must LOAD a Recording List first!')
end
%%%%%%%%%%%%%%%%%%
%Define Analysis Parts
clear AnalysisPartsChoiceOptions AnalysisPartOptions
for zzzz=1:1
    a=0;
    %%%%%%%%%%%%%%%%%%
    a=a+1;
    AnalysisPartsChoiceOptions{a}=[AnalysisLabel,' Merge Modality Data'];
           AnalysisPartOptions{a}=[1,2];
    %%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main Batch Handling
run('Batching_Script.m')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
