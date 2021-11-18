%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isfield(ImagingInfo,'TestDeltaFVectors')
    SelectingTestROI=1;
    while SelectingTestROI
        close all
        Test_FilterSize_px=11;
        Test_FilterSigma_px=1;
        TempVector=[];
        if length(ImagingInfo.GoodEpisodeNumbers)>4
            ImagingInfo.TestEpisodes=5;
        elseif length(ImagingInfo.GoodEpisodeNumbers)>3
            ImagingInfo.TestEpisodes=4;
        elseif length(ImagingInfo.GoodEpisodeNumbers)>2
            ImagingInfo.TestEpisodes=3;
        elseif length(ImagingInfo.GoodEpisodeNumbers)>1
            ImagingInfo.TestEpisodes=2;
        else
            ImagingInfo.TestEpisodes=1;
        end
        figure,
        imshow(ImageArray_All_Raw(:,:,1),[],'border','tight')
        hold on
        text(10,10,'Select a test ROI to find overall DeltaF pattern','color','y','fontsize',14);
        TestROI=roipoly;
        close all
        EpisodeCount=1;
        FrameCount=1;
        ImagingInfo.TestDeltaFVectors=[];
        for ImageNumber=1:ImagingInfo.FramesPerEpisode*ImagingInfo.TestEpisodes
            if rem(ImageNumber,ImagingInfo.FramesPerEpisode)==1
                ImagingInfo.TestDeltaFVectors(EpisodeCount,FrameCount)=NaN;
            else
                TempImage = (double(ImageArray_All_Raw(:,:,ImageNumber))-double(ImageArray_All_Raw(:,:,1)))./double(ImageArray_All_Raw(:,:,1));
                ImagingInfo.TestDeltaFVectors(EpisodeCount,FrameCount) = mean(TempImage(TestROI));
                clear TempImage
            end
            if FrameCount<ImagingInfo.FramesPerEpisode
                FrameCount=FrameCount+1;
            else
                FrameCount=1;
                EpisodeCount=EpisodeCount+1;
            end
        end
        figure
        hold on
        for i=1:size(ImagingInfo.TestDeltaFVectors,1)
            plot([1:ImagingInfo.FramesPerEpisode],ImagingInfo.TestDeltaFVectors(i,:),'*-')
        end
        xlabel('Episode frame #')
        ylabel('Test \DeltaF/F')
        SelectingChoice=questdlg('Move ROI?','Move ROI?','Move','Good','Good');
        switch SelectingChoice
            case 'Move'
                SelectingTestROI=1;
            case 'Good'
                SelectingTestROI=0;
        end

    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DefaultLoadLabel='Protocol Input';
LabDefaults=[];
if exist(LabDefaults)
    LoadLabDefaultsChoice = questdlg([LabDefaults,' Exist...Load: ',DefaultLoadLabel,'?'],'Load Lab Defaults?','Load','Skip','Load');
    switch LoadLabDefaultsChoice
        case 'Load'
            run(LabDefaults)
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ModalityType Selection
AllModalityChoices=[];
for mm=1:length(ModalityChoices)
    AllModalityChoices{mm}=ModalityChoices(mm).Option;
end
if TutorialNotes
    Instructions={'We only have a few preset Modality Defaults set up';...
        'But it is not hard to add more so please let me know when you';...
        'use a new protocol and I can add settings here to save you';...
        'lots of time!';...
        'Though note that in general Modality types include: ';...
        '1 = SHORT Episodic LF Evoked generally 10-20 frames per stim';...
        '2 = SPONT ONLY Streaming NO Stimulation';...
        '3 = Streaming with Stimulation any longer imaging with low or';...
        '     high frequency stimulation'};
    TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
    if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
        TutorialNotes=0;
    end
end
SelectModality=1;
if isfield(ImagingInfo,'ModalityChoice')
    SelectModChoice = questdlg('Reselect Modality Information from Defaults?','Reselect Modality Info','Reselect','Skip','Skip');
    if strcmp(SelectModChoice,'Reselect')
        SelectModality=1;
    else
        SelectModality=0;
    end
else
    SelectModality=1;
end
if SelectModality
    disp('===================================================================')
    disp('===================================================================')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [ModChoice, checking] = listdlg('PromptString','Select a modality type:','SelectionMode','single','ListString',AllModalityChoices,'ListSize', [500 500]);
    if isempty(ModalityChoices(ModChoice).ImagingInfo)
        [TemFile, TempPath, ~] = uigetfile(...
            {'*_Analysis_Setup.mat','_Analysis_Setup.mat'},'Load Previous ImagingInfo and RegistrationSettings from _Analysis_Setup.mat');
        ImagingInfo.Modality_Setting_Input_FileName=TemFile;
        ImagingInfo.Modality_Setting_Input_FileDir=TempPath;
        CurrentImagingInfo=ImagingInfo;
        clear ImagingInfo
        load([TempPath,TemFile],'ImagingInfo','RegistrationSettings')
        LoadImagingInfo=ImagingInfo;
        ImagingInfo=CurrentImagingInfo;
        clear CurrentImagingInfo
        %%%%%%%
        ImagingInfo.ModalityType=LoadImagingInfo.Type;
        ImagingInfo.Option=LoadImagingInfo.Option;
        ImagingInfo.ModalitySuffix=LoadImagingInfo.ModalitySuffix;
        %%%%%%%
        ImagingInfo.ImagingFrequency=LoadImagingInfo.ImagingFrequency;
        ImagingInfo.ImagingExposureTime=LoadImagingInfo.ImagingExposureTime;
        if isfield(LoadImagingInfo,'InterEpisodeFrequency')
            ImagingInfo.InterEpisodeFrequency=LoadImagingInfo.InterEpisodeFrequency;
        else
            ImagingInfo.InterEpisodeFrequency=NaN;
        end
        if isfield(LoadImagingInfo,'StimuliPerEpisode')
            ImagingInfo.StimuliPerEpisode=LoadImagingInfo.StimuliPerEpisode;
        else
            ImagingInfo.StimuliPerEpisode=NaN;
        end
        if isfield(LoadImagingInfo,'FramesPerStimulus')
            ImagingInfo.FramesPerStimulus=LoadImagingInfo.FramesPerStimulus;
        else
            ImagingInfo.FramesPerStimulus=NaN;
        end
        if isfield(LoadImagingInfo,'IntraEpisode_StimulusFrequency')
            ImagingInfo.IntraEpisode_StimulusFrequency=LoadImagingInfo.IntraEpisode_StimulusFrequency;
        else
            ImagingInfo.IntraEpisode_StimulusFrequency=NaN;
        end
        if isfield(LoadImagingInfo,'IntraEpisode_StimuliFrames')
            ImagingInfo.IntraEpisode_StimuliFrames=LoadImagingInfo.IntraEpisode_StimuliFrames;
        else
            ImagingInfo.IntraEpisode_StimuliFrames=[];
        end
        if isfield(LoadImagingInfo,'IntraEpisode_Evoked_ActiveFrames')
            ImagingInfo.IntraEpisode_Evoked_ActiveFrames=LoadImagingInfo.IntraEpisode_Evoked_ActiveFrames;
        else
            ImagingInfo.IntraEpisode_Evoked_ActiveFrames=[];
        end
        clear LoadImagingInfo
    else
        ImagingInfo.Modality_Setting_Input_FileName=[];
        ImagingInfo.Modality_Setting_Input_FileDir=[];
        ImagingInfo.ModalityType=ModalityChoices(ModChoice).Type;
        ImagingInfo.Option=ModalityChoices(ModChoice).Option;
        ImagingInfo.ModalitySuffix=ModalityChoices(ModChoice).ImagingInfo.ModalitySuffix;
        %%%%%%%
        ImagingInfo.ImagingFrequency=ModalityChoices(ModChoice).ImagingInfo.ImagingFrequency;
        ImagingInfo.ImagingExposureTime=ModalityChoices(ModChoice).ImagingInfo.ImagingExposureTime;
        ImagingInfo.InterEpisodeFrequency=ModalityChoices(ModChoice).ImagingInfo.InterEpisodeFrequency;
        ImagingInfo.StimuliPerEpisode=ModalityChoices(ModChoice).ImagingInfo.StimuliPerEpisode;
        ImagingInfo.FramesPerStimulus=ModalityChoices(ModChoice).ImagingInfo.FramesPerStimulus;
        ImagingInfo.IntraEpisode_StimulusFrequency=ModalityChoices(ModChoice).ImagingInfo.IntraEpisode_StimulusFrequency;
        ImagingInfo.IntraEpisode_StimuliFrames=ModalityChoices(ModChoice).ImagingInfo.IntraEpisode_StimuliFrames;
        ImagingInfo.IntraEpisode_Evoked_ActiveFrames=ModalityChoices(ModChoice).ImagingInfo.IntraEpisode_Evoked_ActiveFrames;
        %%%%%%%
        RegistrationSettings.ReferenceImageMethod=ModalityChoices(ModChoice).RegistrationSettings.ReferenceImageMethod;
        RegistrationSettings.ReferenceImageNumbers=ModalityChoices(ModChoice).RegistrationSettings.ReferenceImageNumbers;
        RegistrationSettings.RegistrationClass=ModalityChoices(ModChoice).RegistrationSettings.RegistrationClass;
        RegistrationSettings.RegistrationMethod=ModalityChoices(ModChoice).RegistrationSettings.RegistrationMethod;
        RegistrationSettings.BaselineOption=ModalityChoices(ModChoice).RegistrationSettings.BaselineOption;
        RegistrationSettings.BaselineNumFrames=ModalityChoices(ModChoice).RegistrationSettings.BaselineNumFrames;
        RegistrationSettings.BaselineFrames=ModalityChoices(ModChoice).RegistrationSettings.BaselineFrames;
        RegistrationSettings.BaselineNumBlocks=ModalityChoices(ModChoice).RegistrationSettings.BaselineNumBlocks;
        RegistrationSettings.BleachCorr_Option=ModalityChoices(ModChoice).RegistrationSettings.BleachCorr_Option;
        RegistrationSettings.BleachCorr_Outliers=ModalityChoices(ModChoice).RegistrationSettings.BleachCorr_Outliers;
        %%%%%%%
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['You have chosen ModalitySuffix = ',ImagingInfo.ModalitySuffix])
    disp(['Note here which replicate if any'])
    
    if TutorialNotes
        Instructions={...
            'Id recommend that if you are analyzing replicate identical protocols';...
            'for the same NMJ separately to use a Replicate # to make sure they get';...
            'labeled in an unique way by adding a value to the Modality_Suffix variable';...
        };
        TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
        if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
            TutorialNotes=0;
        end
    end
    
    
    ImagingInfo.ModalitySuffixReplicate=[];
    FixSuffix=1;
    while FixSuffix
        FixSuffixChoice = questdlg({'Is this dataset a replicate recording being analyzed separately?';'If so we need to enter a replicate #'},...
            'Replicate #?','Not Replicate','Replicate','Not Replicate');
        switch FixSuffixChoice
            case 'Replicate'
                ImagingInfo.ModalitySuffixReplicate=input('Recording Replicate #, enter if not needed: ');
                disp(['Is this correct: ',SaveName,ImagingInfo.ModalitySuffix,ImagingInfo.ModalitySuffixReplicate])
                %FixSuffix=InputWithVerification('<1> to repeat: ',{[],[1]},0);
                RepeatSelection = questdlg(['Do you want to fix Replicate #?'],'Repeat?','Repeat','Continue','Continue');
                switch RepeatSelection
                    case 'Repeat'
                        FixSuffix=1;
                    case 'Continue'
                        FixSuffix=0;
                end

            case 'Not Replicate'
                ImagingInfo.ModalitySuffixReplicate=[];
                FixSuffix=0;
        end
    end
    ImagingInfo.ModalitySuffix=[ImagingInfo.ModalitySuffix,ImagingInfo.ModalitySuffixReplicate];
else
    disp([' ModalitySuffix = ',ImagingInfo.ModalitySuffix])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ImagingInfo.IntraEpisode_Spont_ActiveFrames=[];
for i=1:ImagingInfo.FramesPerEpisode
    if ~any(i==ImagingInfo.IntraEpisode_Evoked_ActiveFrames)
        ImagingInfo.IntraEpisode_Spont_ActiveFrames=...
            [ImagingInfo.IntraEpisode_Spont_ActiveFrames,i];
    end
end
if ImagingInfo.ModalityType==1||ImagingInfo.ModalityType==3
    warning('You Selected an evoked protocol you will want to check stim timings...')
    warning(['IntraEpisode_StimuliFrames = ',num2str(ImagingInfo.IntraEpisode_StimuliFrames)])
    warning(['FramesPerStimulus = ',num2str(ImagingInfo.FramesPerStimulus)])
    warning(['IntraEpisode_Evoked_ActiveFrames = ',num2str(ImagingInfo.IntraEpisode_Evoked_ActiveFrames)])
    %PlayImageArray=InputWithVerification('<1> to view ImageArray: ',{[],[1]},0);
    ViewSelection = questdlg(['Do you want to view data?'],'View Data?','View','Skip','Skip');
    switch ViewSelection
        case 'View'
            PlayImageArray=1;
        case 'Skip'
            PlayImageArray=0;
    end

    if PlayImageArray
        Stack_Viewer(ImageArray,[],'YXT')
        RepeatSelection = questdlg(['Do you want to repeat viewing Data?'],'Repeat?','Repeat','Continue','Continue');
        switch RepeatSelection
            case 'Repeat'
                PlayImageArray=1;
            case 'Continue'
                PlayImageArray=0;
        end
        
    end
    close all
    if ImagingInfo.StimuliPerEpisode>0
        ImagingInfo.StimInfo=[];
        for s=1:ImagingInfo.StimuliPerEpisode
            ImagingInfo.StimInfo(s).IntraEpisode_StimNum=s;
            ImagingInfo.StimInfo(s).IntraEpisode_StimulusSortingFrames=...
                [ImagingInfo.IntraEpisode_StimuliFrames(s):...
                ImagingInfo.IntraEpisode_StimuliFrames(s)+ImagingInfo.FramesPerStimulus-1];
        end
        
        figure
        hold on
        plot([-10,-10],[0,0],'s-','color','k')
        plot([-10,-10],[0,0],'o-','color','c')    
        plot([-10,-10],[0,0],'o-','color','r')  
        plot([-10,-10],[0,0],'*-','color','m')
        plot([-10,-10],[0,0],'x-','color','g')
        plot([ImagingInfo.PeakFrame,ImagingInfo.PeakFrame],[-0.2,max(ImagingInfo.TestDeltaFVectors(:))],':','color','b')
        plot([1:ImagingInfo.FramesPerEpisode],-0*ones(1,ImagingInfo.FramesPerEpisode),'s-','color','k')
        plot(ImagingInfo.IntraEpisode_Evoked_ActiveFrames,-0.05*ones(1,length(ImagingInfo.IntraEpisode_Evoked_ActiveFrames)),'o-','color','c')    
        plot(ImagingInfo.IntraEpisode_Spont_ActiveFrames,-0.05*ones(1,length(ImagingInfo.IntraEpisode_Spont_ActiveFrames)),'o-','color','r')    
        for s=1:length(ImagingInfo.StimInfo)
            plot([ImagingInfo.IntraEpisode_StimuliFrames(s),ImagingInfo.IntraEpisode_StimuliFrames(s)],...
                [-0.1,-0.2],'*-','color','m')
            plot([ImagingInfo.StimInfo(s).IntraEpisode_StimulusSortingFrames],...
                -0.15*ones(1,length(ImagingInfo.StimInfo(s).IntraEpisode_StimulusSortingFrames)),'x-','color','g')
        end
        hold on
        for i=1:size(ImagingInfo.TestDeltaFVectors,1)
            plot([1:ImagingInfo.FramesPerEpisode],ImagingInfo.TestDeltaFVectors(i,:),'*-')
        end
        xlabel('Episode frame #')
        ylabel('Test \DeltaF/F')
        xlim([-1,ImagingInfo.FramesPerEpisode+3])
        YLimits=ylim;
        ylim([-0.2,YLimits(2)])
        legend({'Episode Frames','Evoked Active Frames','Spont. Active Frames','Stimuli Frames','Stimulus Sorting Frames','Peak Frame'},'location','no')
        set(gcf,'position',[0,80,800,500])
    else
        ImagingInfo.StimInfo=[];
    end

else
    ImagingInfo.StimInfo=[];
end
if ~isfield(ImagingInfo,'PeakFrame')
    ImagingInfo.PeakFrame=round((ImagingInfo.FramesPerEpisode/2));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('=======================================================')
disp('=======================================================')
disp('=======================================================')
warning(['ModalityType: '])
warning(['              1=Evoked Episodic'])
warning(['              2=STREAMING Spont. ONLY '])
warning(['              3=STREAMING with Stim.'])
disp('=======================================================')
disp('=======================================================')
disp('=======================================================')
if TutorialNotes
    Instructions={...
    'ModalityType (1-3)';...
    'ModalitySuffix';...
    'ImagingFrequency (FPS)';...
    'ImagingExposureTime (ms)';...
    'InterEpisodeFrequency (Hz)';...
    'StimuliPerEpisode';...
    'FramesPerStimulus';...
    'IntraEpisode_StimulusFrequency (Hz)';...
    'IntraEpisode_StimuliFrames';...
    'IntraEpisode_Evoked_ActiveFrames';...
    'Peak Frame';...
    };
    TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
    if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
        TutorialNotes=0;
    end
end
prompt = {'ModalityType (1-3)',...
    'ModalitySuffix',...
    'ImagingFrequency (FPS)',...
    'ImagingExposureTime (ms)',...
    'InterEpisodeFrequency (Hz)',...
    'StimuliPerEpisode',...
    'FramesPerStimulus',...
    'IntraEpisode_StimulusFrequency (Hz)',...
    'IntraEpisode_StimuliFrames',...
    'IntraEpisode_Evoked_ActiveFrames',...
    'Peak Frame'};
dlg_title = 'Confirm Protocol Details Part 1';
num_lines = 1;
if length(ImagingInfo.IntraEpisode_StimuliFrames)>1
    IntraEpisode_StimuliFramesString=[mat2str(ImagingInfo.IntraEpisode_StimuliFrames)];
elseif length(ImagingInfo.IntraEpisode_StimuliFrames)==1
    IntraEpisode_StimuliFramesString=['[',mat2str(ImagingInfo.IntraEpisode_StimuliFrames),']'];
else
    IntraEpisode_StimuliFramesString=['[]'];
end
if length(ImagingInfo.IntraEpisode_Evoked_ActiveFrames)>1
    IntraEpisode_Evoked_ActiveFramesString=[mat2str(ImagingInfo.IntraEpisode_Evoked_ActiveFrames)];
elseif length(ImagingInfo.IntraEpisode_Evoked_ActiveFrames)==1
    IntraEpisode_Evoked_ActiveFramesString=['[',mat2str(ImagingInfo.IntraEpisode_Evoked_ActiveFrames),']'];
else
    IntraEpisode_Evoked_ActiveFramesString=['[]'];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
def = {num2str(ImagingInfo.ModalityType),num2str(ImagingInfo.ModalitySuffix),...
    num2str(ImagingInfo.ImagingFrequency),num2str(ImagingInfo.ImagingExposureTime),...
    num2str(ImagingInfo.InterEpisodeFrequency),...
    num2str(ImagingInfo.StimuliPerEpisode),...
    num2str(ImagingInfo.FramesPerStimulus),...
    num2str(ImagingInfo.IntraEpisode_StimulusFrequency),...
    IntraEpisode_StimuliFramesString,...
    IntraEpisode_Evoked_ActiveFramesString,...
    num2str(ImagingInfo.PeakFrame)};
answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ImagingInfo.ModalityType=str2num(answer{1});
ImagingInfo.ModalitySuffix=answer{2};
ImagingInfo.ImagingFrequency=str2num(answer{3});
ImagingInfo.ImagingExposureTime=str2num(answer{4});
ImagingInfo.InterEpisodeFrequency=str2num(answer{5});
ImagingInfo.StimuliPerEpisode=str2num(answer{6});
ImagingInfo.FramesPerStimulus=str2num(answer{7});
ImagingInfo.IntraEpisode_StimulusFrequency=str2num(answer{8});
ImagingInfo.IntraEpisode_StimuliFrames=[];
ImagingInfo.IntraEpisode_StimuliFrames=String2Array_Fixed(answer{9});
ImagingInfo.IntraEpisode_Evoked_ActiveFrames=[];
ImagingInfo.IntraEpisode_Evoked_ActiveFrames=String2Array_Fixed(answer{10});
ImagingInfo.PeakFrame=str2num(answer{11});
clear answer;
disp('===================================================================')
disp('===================================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if TutorialNotes
    Instructions={...
        'When setting up registration we have three options to choose from';...
        'You can just define the refernce image from scratch from the current dataset';...
        'If you have multiple protocols from the same NMJ then you will want to decide';...
        'which will be the master file and just use define once';...
        'for all the other datasets from that NMJ you can Select the registraiton';...
        'reference data from that file and load in. just be careful when setting up';...
        'the registraiton in a later prep state to make sure to leave the reference';...
        'enhancemnets the same if possible. Using Current will skip the adjustments';...
        'from this step and is only used if you are runnign preparation again or in';...
        'a piecemeal mode';...
    };
    TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
    if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
        TutorialNotes=0;
    end
end
SelectingReference=1;
while SelectingReference
    close all
    if ~isfield(RegistrationSettings,'Reference')
        RegistrationSettings.Reference.FileName=[];
        RegistrationSettings.Reference.Dir=[];
        RegistrationSettings.Reference.SaveName=[];
        RegistrationSettings.Reference.ImageSetSaveName=[];
        RegistrationSettings.Reference.RegistrationSettings=[];
        RegistrationSettings.Reference.ImagingInfo=[];
    end
    questdlg({'Current Reference Info:';...
        ['Reference.SaveName=',RegistrationSettings.Reference.SaveName];...
        ['Reference.ImageSetSaveName=',RegistrationSettings.Reference.ImageSetSaveName];...
        ['Reference.FileName=',RegistrationSettings.Reference.FileName];...
        ['Reference.Dir=',RegistrationSettings.Reference.Dir]},...
        'Current Reference Info','Continue','Continue');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RefChoice = questdlg('Register to Seprate Reference File?','RegisterToReference','Define','Select','Current','Define');
    if strcmp(RefChoice,'Define')
        RegistrationSettings.RegisterToReference=0;
        RegistrationSettings.Reference.FileName=[];
        RegistrationSettings.Reference.Dir=[];
        RegistrationSettings.Reference.SaveName=[];
        RegistrationSettings.Reference.ImageSetSaveName=[];
        RegistrationSettings.Reference.RegistrationSettings=[];
        RegistrationSettings.Reference.ImagingInfo=[];
        SelectingReference=0;
    elseif strcmp(RefChoice,'Current')
        SelectingReference=0;
    elseif strcmp(RefChoice,'Select')
        Current_SaveName=SaveName;
        if exist('ImageSetSaveName')
            Current_ImageSetSaveName=ImageSetSaveName;
        else
            Current_ImageSetSaveName=[];
        end
        Current_RegistrationSettings=RegistrationSettings;
        Current_ImagingInfo=ImagingInfo;
        %clear SaveName ImageSetSaveName RegistrationSettings ImagingInfo
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [Current_Reference.FileName, Current_Reference.Dir, ~] = uigetfile(...
            {'*_Analysis_Setup.mat','_Analysis_Setup.mat'},'Pick REFERENCE _Analysis_Setup.mat');
        load([Current_Reference.Dir,Current_Reference.FileName],'SaveName','RegistrationSettings','ImagingInfo','BoutonArray','BoutonMerge')
        RegistrationSettings.Reference.FileName=Current_Reference.FileName;
        RegistrationSettings.Reference.Dir=Current_Reference.Dir;
        RegistrationSettings.Reference.SaveName=SaveName;
        RegistrationSettings.Reference.ImageSetSaveName=[SaveName,ImagingInfo.ModalitySuffix];
        RegistrationSettings.Reference.BoutonArray=BoutonArray;
        RegistrationSettings.Reference.BoutonMerge=BoutonMerge;
        RegistrationSettings.Reference.RegistrationSettings=RegistrationSettings;
        RegistrationSettings.Reference.ImagingInfo=ImagingInfo;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SaveName=Current_SaveName;
        ImageSetSaveName=Current_ImageSetSaveName;
        RegistrationSettings.RegisterToReference=1;
        %RegistrationSettings=Current_RegistrationSettings;
        ImagingInfo=Current_ImagingInfo;
        RegistrationSettings.RegistrationClass=Current_RegistrationSettings.RegistrationClass;
        RegistrationSettings.RegistrationMethod=Current_RegistrationSettings.RegistrationMethod;
        RegistrationSettings.BaselineOption=Current_RegistrationSettings.BaselineOption;
        RegistrationSettings.BaselineNumFrames=Current_RegistrationSettings.BaselineNumFrames;
        RegistrationSettings.BaselineFrames=Current_RegistrationSettings.BaselineFrames;
        RegistrationSettings.BaselineNumBlocks=Current_RegistrationSettings.BaselineNumBlocks;
        RegistrationSettings.BleachCorr_Option=Current_RegistrationSettings.BleachCorr_Option;
        RegistrationSettings.BleachCorr_Outliers=Current_RegistrationSettings.BleachCorr_Outliers;
        RegistrationSettings.RegistrationClass=Current_RegistrationSettings.RegistrationClass;
        RegistrationSettings.RegistrationMethod=Current_RegistrationSettings.RegistrationMethod;
        RegistrationSettings.CoarseReg_MinCorrValue=Current_RegistrationSettings.CoarseReg_MinCorrValue;
        RegistrationSettings.CoarseReg_MaxShiftX=Current_RegistrationSettings.CoarseReg_MaxShiftX;
        RegistrationSettings.CoarseReg_MaxShiftY=Current_RegistrationSettings.CoarseReg_MaxShiftY;
        RegistrationSettings.OverallReferenceImage=RegistrationSettings.Reference.RegistrationSettings.OverallReferenceImage;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        clear Current_SaveName Current_ImageSetSaveName Current_RegistrationSettings Current_ImagingInfo
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        close all
        figure
        imshow(RegistrationSettings.OverallReferenceImage,[],'Border','tight')
        hold on
        for Bouton=1:length(BoutonArray)
            for j=1:length(BoutonArray(Bouton).BorderLine_Orig)
                plot(BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,2),...
                    BoutonArray(Bouton).BorderLine_Orig{j}.BorderLine(:,1),...
                    '-','color',BoutonArray(Bouton).Color,'linewidth',1)
            end
            plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1),BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2),BoutonArray(Bouton).Crop_Props.BoundingBox(2)],':','color',BoutonArray(Bouton).Color,'LineWidth',1);
            plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1),BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4),BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4)],':','color',BoutonArray(Bouton).Color,'LineWidth',1);
            plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1),BoutonArray(Bouton).Crop_Props.BoundingBox(1)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2),BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4)],':','color',BoutonArray(Bouton).Color,'LineWidth',1);
            plot([BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3),BoutonArray(Bouton).Crop_Props.BoundingBox(1)+BoutonArray(Bouton).Crop_Props.BoundingBox(3)],[BoutonArray(Bouton).Crop_Props.BoundingBox(2),BoutonArray(Bouton).Crop_Props.BoundingBox(2)+BoutonArray(Bouton).Crop_Props.BoundingBox(4)],':','color',BoutonArray(Bouton).Color,'LineWidth',1); 
        end
        questdlg({'Current Reference Info:';...
            ['Reference.SaveName=',RegistrationSettings.Reference.SaveName];...
            ['Reference.ImageSetSaveName=',RegistrationSettings.Reference.ImageSetSaveName];...
            ['ReferenceFileName=',RegistrationSettings.Reference.FileName];...
            ['ReferenceDir=',RegistrationSettings.Reference.Dir]},...
            'Current Reference Info','Continue','Continue');
        %SelectingReference=InputWithVerification('<1> to Redo selection: ',{[],[1]},0);
        RepeatSelection = questdlg(['Do you want to repeate REFERENCE image selection?'],'Repeat?','Repeat','Continue','Continue');
        switch RepeatSelection
            case 'Repeat'
                SelectingReference=1;
            case 'Continue'
                SelectingReference=0;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('=======================================================')
disp('=======================================================')
disp('=======================================================')
warning on
warning('RegistrationClass')
warning('RegistrationClass 1: First Frames ONLY (for very short episodes)')
warning('RegistrationClass 2: All Images (with optional Blocks to register long spontaneous recordings)')
warning('RegistrationMethods')
warning('RegistrationMethod 1: OLD Reg')
warning('RegistrationMethod 2: Dft ONLY')
warning('RegistrationMethod 3: RECOMMMENDED DFT and Demons')
disp('=======================================================')
disp('=======================================================')
disp('=======================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ReferenceImageSelecting=1;
while ReferenceImageSelecting
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    warning('You need to check data for rotation/flipping, for reference images, baseline/F0 images, Bleach Corr Images and Limits')
    %PlayImageArray=InputWithVerification('<1> to view ImageArray: ',{[],[1]},0);
    ViewSelection = questdlg(['Do you want to view data?'],'View Data?','View','Skip','Skip');
    switch ViewSelection
        case 'View'
            PlayImageArray=1;
        case 'Skip'
            PlayImageArray=0;
    end
    if PlayImageArray
        Stack_Viewer(ImageArray,[],'YXT')
        RepeatSelection = questdlg(['Do you want to repeat viewing Data?'],'Repeat?','Repeat','Continue','Continue');
        switch RepeatSelection
            case 'Repeat'
                PlayImageArray=1;
            case 'Continue'
                PlayImageArray=0;
        end
    end
    close all
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if TutorialNotes
        Instructions={...
                'FlipLR (1/0)';...
                'FlipUD (1/0)';...
                'RotateAngle';...
                'RotateMethod (bilinear/bicubic)';...
                'FilterSigma_um (um)';...
                'FilterSize_um (um)';...
                'RegisterToReference (1/0)';...
                'ReferenceImageMethod (1 Mean, 2 Max, 3 Min)';...
                'ReferenceImageNumbers (array)';...
        };
        TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
        if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
            TutorialNotes=0;
        end
    end
    prompt = {  'FlipLR (1/0)',...
                'FlipUD (1/0)',...
                'RotateAngle',...
                'RotateMethod (bilinear/bicubic)',...
                'FilterSigma_um (um)',...
                'FilterSize_um (um)',...
                'RegisterToReference (1/0)',...
                'ReferenceImageMethod (1 Mean, 2 Max, 3 Min)',...
                'ReferenceImageNumbers (array)'};
    dlg_title = 'Confirm Protocol Details Part 2';
    num_lines = 1;
    if length(RegistrationSettings.ReferenceImageNumbers)>1
        ReferenceImageNumbersString=[mat2str(RegistrationSettings.ReferenceImageNumbers)];
    elseif length(RegistrationSettings.ReferenceImageNumbers)==1
        ReferenceImageNumbersString=['[',mat2str(RegistrationSettings.ReferenceImageNumbers),']'];
    else
        ReferenceImageNumbersString=['[]'];
    end
    def = {num2str(RegistrationSettings.FlipLR),...
        num2str(RegistrationSettings.FlipUD),...
        num2str(RegistrationSettings.RotateAngle),...
        num2str(RegistrationSettings.RotateMethod),...
        num2str(RegistrationSettings.FilterSigma_um),...
        num2str(RegistrationSettings.FilterSize_um),...
        num2str(RegistrationSettings.RegisterToReference),...
        num2str(RegistrationSettings.ReferenceImageMethod),...
        ReferenceImageNumbersString,...
        };
    answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RegistrationSettings.FlipLR=str2num(answer{1});
    RegistrationSettings.FlipUD=str2num(answer{2});
    RegistrationSettings.RotateAngle=str2num(answer{3});
    RegistrationSettings.RotateMethod=str2num(answer{4});
    RegistrationSettings.FilterSigma_um=str2num(answer{5});
    RegistrationSettings.FilterSize_um=str2num(answer{6});
    RegistrationSettings.FilterSigma_px=RegistrationSettings.FilterSigma_um/ImagingInfo.PixelSize;
    RegistrationSettings.FilterSize_px=ceil(RegistrationSettings.FilterSize_um/ImagingInfo.PixelSize);
    if rem(RegistrationSettings.FilterSize_px,2)==0
        RegistrationSettings.FilterSize_px=RegistrationSettings.FilterSize_px+1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RegistrationSettings.RegisterToReference=str2num(answer{7});
    RegistrationSettings.ReferenceImageMethod=str2num(answer{8});
    RegistrationSettings.ReferenceImageNumbers=[];
    RegistrationSettings.ReferenceImageNumbers=String2Array_Fixed(answer{9});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TempImage=ImageArray(:,:,1);
    if ~RegistrationSettings.RegisterToReference
        switch RegistrationSettings.ReferenceImageMethod
            case 1
                RegistrationSettings.OverallReferenceImage=mean(ImageArray(:,:,RegistrationSettings.ReferenceImageNumbers),3);
            case 2
                RegistrationSettings.OverallReferenceImage=max(ImageArray(:,:,RegistrationSettings.ReferenceImageNumbers),[],3);
            case 3
                RegistrationSettings.OverallReferenceImage=min(ImageArray(:,:,RegistrationSettings.ReferenceImageNumbers),[],3);
        end
    end
    if RegistrationSettings.FilterSigma_px~=0
        TempImage = imfilter(TempImage, fspecial('gaussian', RegistrationSettings.FilterSize_px, RegistrationSettings.FilterSigma_px));
        if ~RegistrationSettings.RegisterToReference
            RegistrationSettings.OverallReferenceImage = imfilter(RegistrationSettings.OverallReferenceImage, fspecial('gaussian', RegistrationSettings.FilterSize_px, RegistrationSettings.FilterSigma_px));
        end
    end
    if RegistrationSettings.FlipLR
        TempImage=fliplr(TempImage);
        if ~RegistrationSettings.RegisterToReference
            RegistrationSettings.OverallReferenceImage=fliplr(RegistrationSettings.OverallReferenceImage);
        end
    end
    if RegistrationSettings.FlipUD
        TempImage=flipud(TempImage);
        if ~RegistrationSettings.RegisterToReference
            RegistrationSettings.OverallReferenceImage=flipud(RegistrationSettings.OverallReferenceImage);
        end
    end
    if RegistrationSettings.RotateAngle~=0
        TempImage=imrotate(TempImage,RegistrationSettings.RotateAngle,RegistrationSettings.RotateMethod);
        if ~RegistrationSettings.RegisterToReference
            RegistrationSettings.OverallReferenceImage=imrotate(RegistrationSettings.OverallReferenceImage,RegistrationSettings.RotateAngle,RegistrationSettings.RotateMethod);
        end
    end
    figure('name',SaveName)
    subtightplot(1,2,1,[0 0],[0 0],[0,0])
    imshow(RegistrationSettings.OverallReferenceImage,[],'border','tight')
    hold on
    text(10,10,'ReferenceImage','color','y','fontsize',16);
    subtightplot(1,2,2,[0 0],[0 0],[0,0])
    imshow(TempImage,[],'border','tight')
    hold on
    text(10,10,'Sample Image Frame #1','color','y','fontsize',16);
    set(gcf,'position',[0 50 ImagingInfo.Image_Width*2 ImagingInfo.Image_Height])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %ReferenceImageSelecting=InputWithVerification('Are you satisfied with Reference Image Setting? <1> to repeat: ',{[],[1]},0);
    RepeatSelection = questdlg(['Do you want to repeat Reference Image Setting?'],'Repeat?','Repeat','Continue','Continue');
    switch RepeatSelection
        case 'Repeat'
            ReferenceImageSelecting=1;
        case 'Continue'
            ReferenceImageSelecting=0;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    close all
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('name',SaveName)
imshow(RegistrationSettings.OverallReferenceImage,[],'border','tight')
set(gcf,'position',[0 50 ImagingInfo.DisplaySize])
disp('===================================================================')
disp('===================================================================')
disp('===================================================================')
disp('===================================================================')
disp(['TotalNumFrames: ',num2str(ImagingInfo.TotalNumFrames)])
disp(['GoodEpisodeNumbers: ',num2str(ImagingInfo.GoodEpisodeNumbers)])
disp(['FramesPerEpisode: ',num2str(ImagingInfo.FramesPerEpisode)])
disp('===================================================================')
disp(['ModalityType: ',num2str(ImagingInfo.ModalityType)])
disp(['ModalitySuffix: ',num2str(ImagingInfo.ModalitySuffix)])
disp(['ImagingFrequency: ',num2str(ImagingInfo.ImagingFrequency)])
disp(['ImagingExposureTime: ',num2str(ImagingInfo.ImagingExposureTime)])
disp(['InterEpisodeFrequency: ',num2str(ImagingInfo.InterEpisodeFrequency)])
disp(['StimuliPerEpisode: ',num2str(ImagingInfo.StimuliPerEpisode)])
disp(['IntraEpisode_StimulusFrequency: ',num2str(ImagingInfo.IntraEpisode_StimulusFrequency)])
disp(['IntraEpisode_StimuliFrames: ',num2str(ImagingInfo.IntraEpisode_StimuliFrames)])
disp(['IntraEpisode_Evoked_ActiveFrames: ',num2str(ImagingInfo.IntraEpisode_Evoked_ActiveFrames)])
disp('===================================================================')
disp(['PixelSize: ',num2str(ImagingInfo.PixelSize)])
disp(['FlipLR: ',num2str(RegistrationSettings.FlipLR),' FlipUD: ',num2str(RegistrationSettings.FlipUD)])
disp(['RotateAngle: ',num2str(RegistrationSettings.RotateAngle),' RotateMethod: ',num2str(RegistrationSettings.RotateMethod)])
disp(['FilterSigma_um: ',num2str(RegistrationSettings.FilterSigma_um),' FilterSize_um: ',num2str(RegistrationSettings.FilterSize_um)])
disp(['FilterSigma_px: ',num2str(RegistrationSettings.FilterSigma_px),' FilterSize_px: ',num2str(RegistrationSettings.FilterSize_px)])
disp('===================================================================')
disp(['RegisterToReference: ',num2str(RegistrationSettings.RegisterToReference)])
disp(['ReferenceImageMethod: ',num2str(RegistrationSettings.ReferenceImageMethod)])
disp(['ReferenceImageNumbers: ',num2str(RegistrationSettings.ReferenceImageNumbers)])
disp('===================================================================')
disp('===================================================================')
disp('===================================================================')
disp('===================================================================')
disp('===================================================================')
disp('===================================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
