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
warning('BaselineOption')
warning('BaselineOption (F0) 1: Single Frame')
warning('BaselineOption (F0) 2: Mean of Frames')
warning('BaselineOption (F0) 3: Max of Frames')
warning('BaselineOption (F0) 4: Min of Frames')
warning('BaselineOption (F0) 5: Mean of Min of Y Blocks by N frames')
warning('BaselineOption (F0) 6: Moving min of +/- N frames (NOTE: Current REC Mini and Mini Evoked)')
disp('=======================================================')
warning('BleachCorr_Option')
warning('BleachCorr_Option 0: Off')
warning('BleachCorr_Option 1: Linear')
warning('BleachCorr_Option 2: Single Exponential')
warning('BleachCorr_Option 3: Double Exponential')
warning('BleachCorr_Option 4: Running Subtraction')
disp('=======================================================')
disp('=======================================================')
disp('=======================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if TutorialNotes
    Instructions={'BaselineOption (1=Frame, 2=Mean, 3=Max, 4=Min, 5=MeanMin Blocks, 6=Moving Min)';...
            'BaselineNumFrames';...
            'BaselineFrames (array)';...
            'BaselineNumBlocks (ONLY for Option 5)';...
            'BleachCorr_Option (0=off 1=lin 2=SingleExp 3=DoubleExp)';...
            'BleachCorr_Outliers frames to exclude from fit (i.e.during stim)'};
    TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
    if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
        TutorialNotes=0;
    end
end
prompt = {  'BaselineOption (1=Frame, 2=Mean, 3=Max, 4=Min, 5=MeanMin Blocks, 6=Moving Min)',...
            'BaselineNumFrames',...
            'BaselineFrames (array)',...
            'BaselineNumBlocks (ONLY for Option 5)',...
            'BleachCorr_Option (0=off 1=lin 2=SingleExp 3=DoubleExp)',...
            'BleachCorr_Outliers frames to exclude from fit (i.e.during stim)'};
dlg_title = 'Confirm Protocol Details Part 3';
num_lines = 1;
if length(RegistrationSettings.BaselineFrames)>1
    BaselineFramesString=[mat2str(RegistrationSettings.BaselineFrames)];
elseif length(RegistrationSettings.BaselineFrames)==1
    BaselineFramesString=['[',mat2str(RegistrationSettings.BaselineFrames),']'];
else
    BaselineFramesString=['[]'];
end
if length(RegistrationSettings.BleachCorr_Outliers)>1
    BleachCorr_OutliersString=[mat2str(RegistrationSettings.BleachCorr_Outliers)];
elseif length(RegistrationSettings.BleachCorr_Outliers)==1
    BleachCorr_OutliersString=['[',mat2str(RegistrationSettings.BleachCorr_Outliers),']'];
else
    BleachCorr_OutliersString=['[]'];
end
def = {num2str(RegistrationSettings.BaselineOption),num2str(RegistrationSettings.BaselineNumFrames),BaselineFramesString,num2str(RegistrationSettings.BaselineNumBlocks),...
    num2str(RegistrationSettings.BleachCorr_Option),BleachCorr_OutliersString};
answer = inputdlgcolZN(prompt,dlg_title,num_lines,def,'on',1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegistrationSettings.BaselineOption=str2num(answer{1});
RegistrationSettings.BaselineNumFrames=str2num(answer{2});
RegistrationSettings.BaselineFrames=[];
RegistrationSettings.BaselineFrames=String2Array_Fixed(answer{3});
RegistrationSettings.BaselineNumBlocks=str2num(answer{4});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegistrationSettings.BleachCorr_Option=str2num(answer{5});
RegistrationSettings.BleachCorr_Outliers=[];
RegistrationSettings.BleachCorr_Outliers=String2Array_Fixed(answer{6});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear answer;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if RegistrationSettings.BaselineOption==1&&length(RegistrationSettings.BaselineFrames)>1
            warning('BaselineOption = 1 cant have more than one frame, switching to BaselineOption = 2 aka mean');
            warning('BaselineOption = 1 cant have more than one frame, switching to BaselineOption = 2 aka mean');
            warning('BaselineOption = 1 cant have more than one frame, switching to BaselineOption = 2 aka mean');
            warning('BaselineOption = 1 cant have more than one frame, switching to BaselineOption = 2 aka mean');
            warning('BaselineOption = 1 cant have more than one frame, switching to BaselineOption = 2 aka mean');
            RegistrationSettings.BaselineOption=2;
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if TutorialNotes
    Instructions={'We can define a custom set of outlier frames that will be ignored while doing';...
        'some of the bleach correction modes. Usually this will include frames where there was';...
        'a stimulus in a genotype with a moderate to high Pr. Outlier frames will still be bleach';...
        'corrected, however they will not contribute to generating the bleach correction trend/curve'};
    TutorialNotesAnswer=questdlg(Instructions,'Zach''s Hints!','Continue','Turn OFF Notes','Continue');
    if strcmp(TutorialNotesAnswer,'Turn OFF Notes')
        TutorialNotes=0;
    end
end
ManualOutlierAdjust=1;
while ManualOutlierAdjust
    figure
    hold on
    for i=1:size(ImagingInfo.TestDeltaFVectors,1)
        TempXData=[1:ImagingInfo.FramesPerEpisode];
        TempYData=ImagingInfo.TestDeltaFVectors(i,:);
        plot(TempXData,TempYData,'-','color','k','linewidth',1)
        hold on
        TempOutlierXData=zeros(size(TempXData));
        TempOutlierYData=zeros(size(TempYData));
        TempOutlierXData(RegistrationSettings.BleachCorr_Outliers)=1;
        TempOutlierYData(RegistrationSettings.BleachCorr_Outliers)=1;
        TempOutlierXData(TempOutlierXData==0)=NaN;
        TempOutlierYData(TempOutlierYData==0)=NaN;
        plot(TempXData.*TempOutlierXData,TempYData.*TempOutlierYData,'*-','color','r','linewidth',2)
    end
    xlabel('Episode frame #')
    ylabel('Test \DeltaF/F')
    title('DeltaF/F with OUTLIERS');
    XLimits=xlim;
    YLimits=ylim;
    OutlierChoice=questdlg('Edit Bleach Correction Exclusions/Outliers, Move ROI or Continue?','Outlier Adjustment','Adjust Outliers','Move ROI','Continue','Continue'); 
    switch OutlierChoice
        case 'Move ROI'
            ManualOutlierAdjust=1;
            SelectingTestROI=1;
            while SelectingTestROI
                close all
                figure,
                if exist('ImageArray_All_Raw')
                    imshow(ImageArray_All_Raw(:,:,1),[],'border','tight')
                else
                    imshow(ImageArray(:,:,1),[],'border','tight')
                end
                hold on
                text(10,10,'Select a test ROI to find overall DeltaF pattern','color','y','fontsize',14);
                TestROI=roipoly;
                EpisodeCount=1;
                FrameCount=1;
                ImagingInfo.TestDeltaFVectors=[];
                for ImageNumber=1:ImagingInfo.FramesPerEpisode*ImagingInfo.TestEpisodes
                    if rem(ImageNumber,ImagingInfo.FramesPerEpisode)==1
                        ImagingInfo.TestDeltaFVectors(EpisodeCount,FrameCount)=NaN;
                    else
                        if exist('ImageArray_All_Raw')
                            TempImage = (double(ImageArray_All_Raw(:,:,ImageNumber))-double(ImageArray_All_Raw(:,:,1)))./double(ImageArray_All_Raw(:,:,1));
                        else
                            TempImage = (double(ImageArray(:,:,ImageNumber))-double(ImageArray(:,:,1)))./double(ImageArray(:,:,1));
                        end
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
                close all
                figure
                hold on
                for i=1:size(ImagingInfo.TestDeltaFVectors,1)
                    TempXData=[1:ImagingInfo.FramesPerEpisode];
                    TempYData=ImagingInfo.TestDeltaFVectors(i,:);
                    plot(TempXData,TempYData,'-','color','k','linewidth',1)
                    hold on
                    TempOutlierXData=zeros(size(TempXData));
                    TempOutlierYData=zeros(size(TempYData));
                    TempOutlierXData(RegistrationSettings.BleachCorr_Outliers)=1;
                    TempOutlierYData(RegistrationSettings.BleachCorr_Outliers)=1;
                    TempOutlierXData(TempOutlierXData==0)=NaN;
                    TempOutlierYData(TempOutlierYData==0)=NaN;
                    plot(TempXData.*TempOutlierXData,TempYData.*TempOutlierYData,'*-','color','r','linewidth',2)
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
        case 'Adjust Outliers'
            ManualOutlierAdjust=1;
                AddOutlier=questdlg('Add Exclusion Region?','Add Outliers','Add','Delete','Add'); 
            switch AddOutlier
                case 'Add'
                    txt1=text(XLimits(1),YLimits(2),'Select left edge of range to ADD','fontsize',14,'color','r','verticalalignment','top','horizontalalignment','left');
                    Point1=ginput(1);
                    delete(txt1);
                    txt1=text(XLimits(1),YLimits(2),'Select right edge of range to ADD','fontsize',14,'color','r','verticalalignment','top','horizontalalignment','left');
                    Point2=ginput(1);
                    delete(txt1);
                    AddRange=round([Point1(1):Point2(1)]);
                    for i=1:length(AddRange)
                        if any(RegistrationSettings.BleachCorr_Outliers~=AddRange(i))
                            RegistrationSettings.BleachCorr_Outliers=[RegistrationSettings.BleachCorr_Outliers,AddRange(i)];
                        end
                    end
                    RegistrationSettings.BleachCorr_Outliers=[RegistrationSettings.BleachCorr_Outliers,AddRange];
                    AddRange=[];
                case 'Delete'
                    txt1=text(XLimits(1),YLimits(2),'Select left edge of range to DELETE','fontsize',14,'color','r','verticalalignment','top','horizontalalignment','left');
                    Point1=ginput(1);
                    delete(txt1);
                    txt1=text(XLimits(1),YLimits(2),'Select right edge of range to DELETE','fontsize',14,'color','r','verticalalignment','top','horizontalalignment','left');
                    Point2=ginput(1);
                    delete(txt1);
                    DeleteRange=round([Point1(1):Point2(1)]);
                    for i=length(RegistrationSettings.BleachCorr_Outliers):-1:1
                        if any(RegistrationSettings.BleachCorr_Outliers(i)==DeleteRange)
                            RegistrationSettings.BleachCorr_Outliers(i)=[];
                        end
                    end
                    DeleteRange=[];
            end
            close all
            figure
            hold on
            for i=1:size(ImagingInfo.TestDeltaFVectors,1)
                TempXData=[1:ImagingInfo.FramesPerEpisode];
                TempYData=ImagingInfo.TestDeltaFVectors(i,:);
                plot(TempXData,TempYData,'-','color','k','linewidth',1)
                hold on
                TempOutlierXData=zeros(size(TempXData));
                TempOutlierYData=zeros(size(TempYData));
                TempOutlierXData(RegistrationSettings.BleachCorr_Outliers)=1;
                TempOutlierYData(RegistrationSettings.BleachCorr_Outliers)=1;
                TempOutlierXData(TempOutlierXData==0)=NaN;
                TempOutlierYData(TempOutlierYData==0)=NaN;
                plot(TempXData.*TempOutlierXData,TempYData.*TempOutlierYData,'*-','color','r','linewidth',2)
            end
            xlabel('Episode frame #')
            ylabel('Test \DeltaF/F')
        case 'Continue'
            ManualOutlierAdjust=0;
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if RegistrationSettings.BaselineOption~=6
    if RegistrationSettings.BaselineNumFrames~=length(RegistrationSettings.BaselineFrames)
        warning('Size Mismatch between BaselineNumFrames and BaselineFrames')
        warning('Setting BaselineNumFrames to match the size of BaselineFrames')
        RegistrationSettings.BaselineNumFrames=length(RegistrationSettings.BaselineFrames);
    end
end
if RegistrationSettings.BaselineOption==5&&RegistrationSettings.BaselineNumBlocks==1
    RegistrationSettings.BaselineNumBlocks=InputWithVerification('BaselineNumBlocks: ',{[1:10000]},0);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
