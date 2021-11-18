%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if EventDetectionSettings.DetectionMethod==2
    close all
    MaxIntensity1=-10000000;
    MinIntensity1=10000000;
    MaxIntensity2=-10000000;
    MinIntensity2=10000000;
    EpisodeNumber=1;
    if SplitEpisodeFiles
        for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
            FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
            fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
            load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
            fprintf('Finished!\n')
            FileSuffix=['_EventDetectionData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
            fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
            load([CurrentScratchDir,StackSaveName,FileSuffix],'EventDetectionStruct')
            fprintf('Finished!\n')
            EpisodeNumber=1;
            switch EventDetectionSettings.DataType
                case 1
                    ImageArray_Input=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaF;
                    ImageArray_CorrAmp_Events=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events;
                    ImageArray_CorrAmp_Events_Thresh=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh;
                    ImageArray_CorrAmp_Events_Thresh_Clean=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean;
                case 2
                    ImageArray_Input=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaFF0;
                    ImageArray_CorrAmp_Events=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events;
                    ImageArray_CorrAmp_Events_Thresh=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh;
                    ImageArray_CorrAmp_Events_Thresh_Clean=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean_Norm;
            end
            MaxIntensity1=max([MaxIntensity1,max(ImageArray_Input(:))]);
            MinIntensity1=min([MinIntensity1,min(ImageArray_Input(:))]);
            IntensityRange1=abs(MaxIntensity1-MinIntensity1);
            MaxIntensity2=max([MaxIntensity2,max(ImageArray_CorrAmp_Events_Thresh_Clean(:))]);
            MinIntensity2=min([MinIntensity2,min(ImageArray_CorrAmp_Events_Thresh_Clean(:))]);
            IntensityRange2=abs(MaxIntensity2-MinIntensity2);
        end
    else
        FileSuffix=['_DeltaFData.mat'];
        fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
        load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
        fprintf('Finished!\n')
        FileSuffix=['_EventDetectionData.mat'];
        fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
        load([CurrentScratchDir,StackSaveName,FileSuffix],'EventDetectionStruct')
        fprintf('Finished!\n')
        for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
            EpisodeNumber=EpisodeNumber_Load;
            switch EventDetectionSettings.DataType
                case 1
                    ImageArray_Input=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaF;
                    ImageArray_CorrAmp_Events=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events;
                    ImageArray_CorrAmp_Events_Thresh=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh;
                    ImageArray_CorrAmp_Events_Thresh_Clean=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean;
                case 2
                    ImageArray_Input=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaFF0;
                    ImageArray_CorrAmp_Events=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events;
                    ImageArray_CorrAmp_Events_Thresh=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh;
                    ImageArray_CorrAmp_Events_Thresh_Clean=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean_Norm;
            end
            MaxIntensity1=max([MaxIntensity1,max(ImageArray_Input(:))]);
            MinIntensity1=min([MinIntensity1,min(ImageArray_Input(:))]);
            IntensityRange1=abs(MaxIntensity1-MinIntensity1);
            MaxIntensity2=max([MaxIntensity2,max(ImageArray_CorrAmp_Events_Thresh_Clean(:))]);
            MinIntensity2=min([MinIntensity2,min(ImageArray_CorrAmp_Events_Thresh_Clean(:))]);
            IntensityRange2=abs(MaxIntensity2-MinIntensity2);
        end 
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MovieQuality=0.8;
    if ImagingInfo.TotalNumFrames>5000
        PlayBackSpeed=40;
    else
        PlayBackSpeed=20;
    end
    if ImagingInfo.NumEpisodes>100
        PlayBackSpeed1=20;
    else
        PlayBackSpeed1=10;
    end
    MovieFrames=1;
    MovieQuality=90;
    ImageWidth=size(AllBoutonsRegion,2);
    ImageHeight=size(AllBoutonsRegion,1);
    if ImageHeight>2*ImageWidth
        HorzMovie=1;
        ScaleFactor=3;
        FigureSize=[ImageWidth*4*ScaleFactor,ImageHeight*1*ScaleFactor];
    else
        HorzMovie=0;
        ScaleFactor=2;
        FigureSize=[ImageWidth*2*ScaleFactor,ImageHeight*2*ScaleFactor];
    end
    if FigureSize(2)>ScreenSize(4)-150
        ExportScalarModifier=(ScreenSize(4)-150)/FigureSize(2);
        warning(['Adjusting Vertical ExportSize by ',num2str(ExportScalarModifier),' to fit Monitor!'])
        FigureSize=round(FigureSize*ExportScalarModifier);
    end
    if FigureSize(1)>ScreenSize(3)
        ExportScalarModifier=ScreenSize(3)/FigureSize(1);
        warning(['Adjusting Horizontal ExportSize by ',num2str(ExportScalarModifier),' to fit Monitor!'])
        FigureSize=round(FigureSize*ExportScalarModifier);
    end
    TimerInterval=100;
    OverlayColor=[0.3 0.3,0.3];
    ColorMap='jet';
    UseBorderLine=1;
    BorderThickness=0.5;    
    BorderColor='w';
    switch EventDetectionSettings.DataType
        %Higher stronger contrast
        case 1
            LowPercent1=0.1;
            HighPercent1=0.65;
            LowPercent2=0;
            HighPercent2=0.65;
        case 2
            LowPercent1=0.1;
            HighPercent1=0.5;
            LowPercent2=0;
            HighPercent2=0.5;
    end
    LabelLocation=[5,12];
    EmbedColorBars=0;
    ColorBar1Orientation=[];
    ColorBar1Location=[];
    ColorBar1Height=[];
    ColorBar1Width=[];
    ColorBar1Label_LowerLimitOffset=[];
    ColorBar1Label_UpperLimitOffset=[];
    ColorBar1Label_XOffset=[];
    ColorBar1Label_YOffset=[];
    ColorBar1Label=[];
    Circle_X_Adjust=0;
    Circle_Y_Adjust=0;
    CircleRadius=5;
    CircleLineStyle='-';
    CircleLineWidth=0.25;
    CoordColor='m';
    LabelFontSize=8;
    LabelVertAdjust=7;
    LabelColor='w';
    ForceDeltaFZero=1;
  
    if ScaleBar.XData(2)>ImageWidth/2&&strcmp(ScaleBar.PointerSide,'L')
        warning('Forcing ScaleBar to other side!')
        ScaleBar.PointerSide='R';
    end
    if strcmp(ScaleBar.PointerSide,'L')
LabelAlignment='left';
else
LabelAlignment='right';
    end
    switch EventDetectionSettings.DataType
        case 1
            InputLabel=['\DeltaF'];
            ColorScalar1=1;
            ColorScalar2=1;
        case 2
            InputLabel=['\DeltaF/F'];
            ColorScalar1=1000;
            ColorScalar2=1000;
    end
    if IntensityRange1*HighPercent1>MaxIntensity1
        ColorLimits1=double([MinIntensity1+IntensityRange1*LowPercent1,MaxIntensity1-IntensityRange1*(HighPercent1/2)]);
    else
        ColorLimits1=double([MinIntensity1+IntensityRange1*LowPercent1,MaxIntensity1-IntensityRange1*HighPercent1]);
    end
    if ColorLimits1(1)>0
        ColorLimits1(1)=0;
    end
    if ColorLimits1(2)<ColorLimits1(1)
        ColorLimits1(2)=MaxIntensity1;
    end
    if ColorLimits1(2)==ColorLimits1(1)&&ColorLimits1(1)==0
        if EventDetectionSettings.DataType==1
            ColorLimits1(2)=1000;
        else
            ColorLimits1(2)=1;
        end
    end
    if ForceDeltaFZero
        warning('Forcing Input Data Low Contrast Zero');
        ColorLimits1(1)=0;
    end
    if IntensityRange2*HighPercent2>MaxIntensity2
        ColorLimits2=double([MinIntensity2+IntensityRange2*LowPercent2,MaxIntensity2-IntensityRange2*(HighPercent2/2)]);
    else
        ColorLimits2=double([MinIntensity2+IntensityRange2*LowPercent2,MaxIntensity2-IntensityRange2*HighPercent2]);
    end
    ColorLimits2(1)=0;
    if ColorLimits2(2)<ColorLimits2(1)
        ColorLimits2(2)=MaxIntensity2;
    end
    if ColorLimits2(2)==ColorLimits2(1)&&ColorLimits2(1)==0
        if EventDetectionSettings.DataType==1
            ColorLimits2(2)=1000;
        else
            ColorLimits2(2)=1;
        end
    end

    if EventDetectionSettings.DataType==2
    if ColorLimits1(2)>2
        warning('Lowering Upper Contrast Limit 1')
        ColorLimits1(2)=2;
    end
    if ColorLimits2(2)>2
        warning('Lowering Upper Contrast Limit 2')
        ColorLimits2(2)=2;
    end
    end
    
    TestImageNumber=ceil(ImagingInfo.FramesPerEpisode/2);
    figure
    InputImage=double(ImageArray_Input(:,:,TestImageNumber));
    if ~any(InputImage(:)>0)
        InputImage_Color=EmptyMaskedImage;
    else
        [~,InputImage_Color,~]=Adjust_Contrast_and_Color(InputImage,ColorLimits1(1),ColorLimits1(2),ColorMap,ColorScalar1);
        InputImage_Color=ColorMasking(InputImage_Color,~AllBoutonsRegion,OverlayColor);
    end
    if EmbedColorBars
        InputImage_Color=EmbedColorMap_Color(InputImage_Color,ColorBar1Orientation,ColorBar1Location,ColorBar1Height,ColorBar1Width,ColorLimits1,ColorMap);
    end
    subplot(1,2,1)
    imshow(InputImage_Color,'Border','tight');

    TestImage=ImageArray_CorrAmp_Events(:,:,1);
    EmptyMaskedImage=zeros(size(TestImage));
    if ~any(EmptyMaskedImage(:)>0)
        EmptyMaskedImage(1,1)=ColorLimits2(2);
    end
    [~,EmptyMaskedImage,~]=Adjust_Contrast_and_Color(EmptyMaskedImage,ColorLimits2(1),ColorLimits2(2),ColorMap,ColorScalar1);
    EmptyMaskedImage=ColorMasking(EmptyMaskedImage,~AllBoutonsRegion,OverlayColor);
    
    CorrAmp=max(ImageArray_CorrAmp_Events(:,:,TestImageNumber),[],3);
    if ~any(CorrAmp(:)>0)
        CorrAmp_Color=EmptyMaskedImage;
    else
        [~,CorrAmp_Color,~]=Adjust_Contrast_and_Color(CorrAmp,ColorLimits2(1),ColorLimits2(2),ColorMap,ColorScalar1);
        CorrAmp_Color=ColorMasking(CorrAmp_Color,~AllBoutonsRegion,OverlayColor);
    end
    if EmbedColorBars
        CorrAmp_Color=EmbedColorMap_Color(CorrAmp_Color,ColorBar2Orientation,ColorBar2Location,ColorBar2Height,ColorBar2Width,ColorLimits2,ColorMap);
    end
    subplot(1,2,2)
    imshow(CorrAmp_Color,'Border','tight');    
    
    if ImagingInfo.ImagingFrequency<=20
    EventHighlight_PreFrames=3;
    EventHighlight_PostFrames=5;
    else
    EventHighlight_PreFrames=5;
    EventHighlight_PostFrames=10;
    end
    if ImagingInfo.ImagingFrequency<=20
    CorrAmp_PreFrames=1;
    CorrAmp_PostFrames=1;
    else
    CorrAmp_PreFrames=3;
    CorrAmp_PostFrames=3;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    close all
    clear mov
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Safe Abort Figure
    if AbortButton
        AbortFig = figure('name',['Rec',num2str(RecordingNum),' ',StackSaveName]);
        set(gcf,'Units','normalized','Position',[0.8 0.8 0.2 0.1]);
        AbortText = uicontrol('Style','text',...
            'units','normalized',...
            'Fontsize',12,...
            'Position',[0.01 0.8 0.98 0.2],...
            'String',[StackSaveName],'fontsize',8);
        AbortButtonHandle = uicontrol('Units','Normalized','Position', [0.05 0.05 0.9 0.75],'style','push',...
            'string',['Abort Rec',num2str(RecordingNum),' Movie'],'callback','set(gcbo,''userdata'',1,''string'',''Aborting!!'')', ...
            'userdata',0) ;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MovieName=[StackSaveName,' CorrAmp Record'];
    fprintf(['Exporting ',MovieName,'...\n'])
    mov = VideoWriter([MoviesScratchDir,dc,MovieName,'.avi'],'Motion JPEG AVI');
    mov.FrameRate = PlayBackSpeed;  % Default 30
    mov.Quality = MovieQuality;    % Default 75
    open(mov);
    MovieFig=figure('name',StackSaveName);
    set(MovieFig,'units','Pixels','position',[0,80,FigureSize]);
    set(MovieFig, 'color', 'white');
    pause(0.001)
    disp(['Making: ',MovieName,'.avi']);
    figure(MovieFig)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    StimCount=0;
    StimCount1=0;
    TimerCount=0;
    MovieTimes=[];
    OverallFrameCount=0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Initial Fancy Movie with all panels active
    AbortMovie=0;
    Movie_Timer=tic;
    Overall_Timer=tic;
    warning off
    EpisodeNumber=1;
    EpisodeNumber_Load=1;
    while ~AbortMovie&&EpisodeNumber_Load<=ImagingInfo.NumEpisodes
        if SplitEpisodeFiles
            EpisodeNumber=1;
            FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
            fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
            load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
            fprintf('Finished!\n')
            FileSuffix=['_EventDetectionData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
            fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
            load([CurrentScratchDir,StackSaveName,FileSuffix],'EventDetectionStruct')
            fprintf('Finished!\n')
        end
        switch EventDetectionSettings.DataType
            case 1
                ImageArray_Input=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaF;
                ImageArray_CorrAmp_Events=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events;
                ImageArray_CorrAmp_Events_Thresh=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh;
                ImageArray_CorrAmp_Events_Thresh_Clean=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean;
            case 2
                ImageArray_Input=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaFF0;
                ImageArray_CorrAmp_Events=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events;
                ImageArray_CorrAmp_Events_Thresh=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh;
                ImageArray_CorrAmp_Events_Thresh_Clean=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean_Norm;
        end
        ImageArray_Input(isnan(ImageArray_Input))=0;
        ImageArray_CorrAmp_Events(isnan(ImageArray_CorrAmp_Events))=0;
        ImageArray_CorrAmp_Events_Thresh(isnan(ImageArray_CorrAmp_Events_Thresh))=0;
        ImageArray_CorrAmp_Events_Thresh_Clean(isnan(ImageArray_CorrAmp_Events_Thresh_Clean))=0;
        %ImageArray_Max=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_Max;
        if ImagingInfo.ModalityType==1
            CorrAmp_Alt=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.Image_CorrAmp_Events_Thresh_Clean;
            if ~any(CorrAmp_Alt(:)>0)
                CorrAmp_Alt_Color=EmptyMaskedImage;
            else
                [~,CorrAmp_Alt_Color,~]=Adjust_Contrast_and_Color(CorrAmp_Alt,ColorLimits2(1),ColorLimits2(2),ColorMap,ColorScalar2);
                CorrAmp_Alt_Color=ColorMasking(CorrAmp_Alt_Color,~AllBoutonsRegion,OverlayColor);
            end
            if EmbedColorBars
                CorrAmp_Alt_Color=EmbedColorMap_Color(CorrAmp_Alt_Color,ColorBar2Orientation,ColorBar2Location,ColorBar2Height,ColorBar2Width,ColorLimits2,ColorMap);
            end
        else
            CorrAmp_Alt_Color=[];
        end
        All_Episode_Coords=EventDetectionStruct(EpisodeNumber).PixelMax_Output.All_Location_Coords_byFrame;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ImageNumber=1;
        while ~AbortMovie&&ImageNumber<=ImagingInfo.FramesPerEpisode
            OverallFrameCount=OverallFrameCount+1;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            IsStimFrame=0;
            if any(ImageNumber==ImagingInfo.IntraEpisode_StimuliFrames)
                IsStimFrame=1;
                StimCount=StimCount+1;
                StimCount1=StimCount1+1;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if rem((OverallFrameCount*1/ImagingInfo.ImagingFrequency),1)==0
                TimePoint=[num2str((OverallFrameCount)*(1/ImagingInfo.ImagingFrequency)),'.00s'];
            elseif rem((OverallFrameCount*10/ImagingInfo.ImagingFrequency),1)==0
                TimePoint=[num2str((OverallFrameCount)*(1/ImagingInfo.ImagingFrequency)),'0s'];
            else
                TimePoint=[num2str((OverallFrameCount)*(1/ImagingInfo.ImagingFrequency)),'s'];
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TempCoords=[];
            for i=1:size(All_Episode_Coords,1)
                if any(All_Episode_Coords(i,3)==...
                        [ImageNumber-EventHighlight_PreFrames:ImageNumber+EventHighlight_PostFrames])
                    TempCoords=vertcat(TempCoords,All_Episode_Coords(i,:));
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            EventPersistenceFrames=[ImageNumber-CorrAmp_PreFrames:ImageNumber+CorrAmp_PostFrames];
            GoodEventPersistenceFrames=[];
            for i=1:length(EventPersistenceFrames)
                if EventPersistenceFrames(i)>0&&EventPersistenceFrames(i)<=ImagingInfo.FramesPerEpisode
                    GoodEventPersistenceFrames=[GoodEventPersistenceFrames,EventPersistenceFrames(i)];
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            figure(MovieFig)
            clf
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Panel 1 InputArray
            if HorzMovie
                subtightplot(1,4,1,[0,0],[0,0],[0,0]);
            else
                subtightplot(2,2,1,[0,0],[0,0],[0,0]);
            end
            PanelLabel=InputLabel;
            for zzzzz=1:1
                InputImage=double(ImageArray_Input(:,:,ImageNumber));
                if ~any(InputImage(:)>0)
                    InputImage_Color=EmptyMaskedImage;
                else
                    [~,InputImage_Color,~]=Adjust_Contrast_and_Color(InputImage,ColorLimits1(1),ColorLimits1(2),ColorMap,ColorScalar1);
                    InputImage_Color=ColorMasking(InputImage_Color,~AllBoutonsRegion,OverlayColor);
                end
                if EmbedColorBars
                    InputImage_Color=EmbedColorMap_Color(InputImage_Color,ColorBar1Orientation,ColorBar1Location,ColorBar1Height,ColorBar1Width,ColorLimits1,ColorMap);
                end
                imshow(InputImage_Color,'Border','tight');
                hold on
                if UseBorderLine
                    for j=1:length(BorderLine)
                        plot(BorderLine{j}.BorderLine(:,2),...
                            BorderLine{j}.BorderLine(:,1),...
                            '-','color',BorderColor,'linewidth',BorderThickness)
                    end
                end
                if EmbedColorBars
                    [P1,P2,P3,P4,T1]=PlotBox2([ColorBar1Location(1),ColorBar1Location(2),ColorBar1Width,ColorBar1Height],'-','w',2,[],[],[]);
                    txt1a=text(ColorBar1Location(1)-ColorBar1Label_LowerLimitOffset,ColorBar1Location(2)+ColorBar1Height/2,num2str(ColorLimits1(1)),'color','w','FontSize',LabelFontSize,'FontName','Arial');
                    txt2a=text(ColorBar1Location(1)+ColorBar1Width+ColorBar1Label_UpperLimitOffset,ColorBar1Location(2)+ColorBar1Height/2,num2str(ColorLimits1(2)),'color','w','FontSize',LabelFontSize,'FontName','Arial');
                    txt3a=text(ColorBar1Location(1)+ColorBar1Width/2+ColorBar1Label_XOffset,ColorBar1Location(2)+ColorBar1Height+ColorBar1Label_YOffset,ColorBar1Label,'color','w','FontSize',LabelFontSize,'FontName','Arial');
                end
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gcf, 'color', 'white');
                plot(ScaleBar.XData,ScaleBar.YData,...
                    '-','color',ScaleBar.Color,'linewidth',ScaleBar.Width);
                if strcmp(ScaleBar.PointerSide,'L')
                    text(ScaleBar.XData(1),...
                        ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        [num2str(ScaleBar.Length),' \mum'],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(1),...
                       ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        PanelLabel,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(1),...
                       ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Ep',num2str(EpisodeNumber_Load)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if ~isempty(MarkerSetInfo.Markers)
                        for Marker=1:length(MarkerSetInfo.Markers)
                            if any(EpisodeNumber_Load==[MarkerSetInfo.Markers(Marker).MarkerStart:MarkerSetInfo.Markers(Marker).MarkerEnd])
                                text(ScaleBar.XData(1),...
                                   ScaleBar.YData(1)-(4)*LabelVertAdjust,...
                                    MarkerSetInfo.Markers(Marker).MarkerShortLabel,'FontSize',LabelFontSize,...
                                    'color',MarkerSetInfo.Markers(Marker).MarkerColor,...
                                    'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                            end
                        end
                    end
                    text(ScaleBar.XData(1)+abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                       ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        TimePoint,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(1)+abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        ['Stim',num2str(StimCount),' '],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if IsStimFrame                        
                        text(ScaleBar.XData(2),...
                            ScaleBar.YData(1)-(2.2)*LabelVertAdjust,...
                            ['*'],'FontSize',LabelFontSize*2,'color',LabelColor,...
                            'HorizontalAlignment','center','FontName','Arial')
                    end
                    text(ScaleBar.XData(1)+abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Im',num2str(ImageNumber)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                else
                    text(ScaleBar.XData(2),...
                        ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        [num2str(ScaleBar.Length),' \mum'],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(2),...
                       ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        PanelLabel,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(2),...
                       ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Ep',num2str(EpisodeNumber_Load)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if ~isempty(MarkerSetInfo.Markers)
                        for Marker=1:length(MarkerSetInfo.Markers)
                            if any(EpisodeNumber_Load==[MarkerSetInfo.Markers(Marker).MarkerStart:MarkerSetInfo.Markers(Marker).MarkerEnd])
                                text(ScaleBar.XData(2),...
                                   ScaleBar.YData(1)-(4)*LabelVertAdjust,...
                                    MarkerSetInfo.Markers(Marker).MarkerShortLabel,'FontSize',LabelFontSize,...
                                    'color',MarkerSetInfo.Markers(Marker).MarkerColor,...
                                    'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                            end
                        end
                    end
                    text(ScaleBar.XData(2)-abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                       ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        TimePoint,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(2)-abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        ['Stim',num2str(StimCount),' '],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if IsStimFrame                        
                        text(ScaleBar.XData(1),...
                            ScaleBar.YData(1)-(2.2)*LabelVertAdjust,...
                            ['*'],'FontSize',LabelFontSize*2,'color',LabelColor,...
                            'HorizontalAlignment','center','FontName','Arial')
                    end
                    text(ScaleBar.XData(2)-abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Im',num2str(ImageNumber)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                end
                if ~isempty(TempCoords)
                    for CircleNum=1:size(TempCoords,1)
                        Plot_Circle2(TempCoords(CircleNum,2)+Circle_X_Adjust,TempCoords(CircleNum,1)+Circle_Y_Adjust,...
                            CircleRadius,CircleLineStyle,CircleLineWidth,CoordColor);
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Panel 2 CorrAmp
            if HorzMovie
                subtightplot(1,4,2,[0,0],[0,0],[0,0]);
            else
                subtightplot(2,2,2,[0,0],[0,0],[0,0]);
            end
            PanelLabel='CorrAmp';
            for zzzzz=1:1
                CorrAmp=max(ImageArray_CorrAmp_Events(:,:,GoodEventPersistenceFrames),[],3);
                if ~any(CorrAmp(:)>0)
                    CorrAmp_Color=EmptyMaskedImage;
                else
                    [~,CorrAmp_Color,~]=Adjust_Contrast_and_Color(CorrAmp,ColorLimits2(1),ColorLimits2(2),ColorMap,ColorScalar1);
                    CorrAmp_Color=ColorMasking(CorrAmp_Color,~AllBoutonsRegion,OverlayColor);
                end
                if EmbedColorBars
                    CorrAmp_Color=EmbedColorMap_Color(CorrAmp_Color,ColorBar2Orientation,ColorBar2Location,ColorBar2Height,ColorBar2Width,ColorLimits2,ColorMap);
                end
                imshow(CorrAmp_Color,'Border','tight');
                hold on
                if UseBorderLine
                    for j=1:length(BorderLine)
                        plot(BorderLine{j}.BorderLine(:,2),...
                            BorderLine{j}.BorderLine(:,1),...
                            '-','color',BorderColor,'linewidth',BorderThickness)
                    end
                end
                if EmbedColorBars
                    [P1,P2,P3,P4,T1]=PlotBox2([ColorBar1Location(1),ColorBar1Location(2),ColorBar1Width,ColorBar1Height],'-','w',2,[],[],[]);
                    txt1a=text(ColorBar1Location(1)-ColorBar1Label_LowerLimitOffset,ColorBar1Location(2)+ColorBar1Height/2,num2str(ColorLimits1(1)),'color','w','FontSize',LabelFontSize,'FontName','Arial');
                    txt2a=text(ColorBar1Location(1)+ColorBar1Width+ColorBar1Label_UpperLimitOffset,ColorBar1Location(2)+ColorBar1Height/2,num2str(ColorLimits1(2)),'color','w','FontSize',LabelFontSize,'FontName','Arial');
                    txt3a=text(ColorBar1Location(1)+ColorBar1Width/2+ColorBar1Label_XOffset,ColorBar1Location(2)+ColorBar1Height+ColorBar1Label_YOffset,ColorBar1Label,'color','w','FontSize',LabelFontSize,'FontName','Arial');
                end
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gcf, 'color', 'white');
                plot(ScaleBar.XData,ScaleBar.YData,...
                    '-','color',ScaleBar.Color,'linewidth',ScaleBar.Width);
                if strcmp(ScaleBar.PointerSide,'L')
                    text(ScaleBar.XData(1),...
                        ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        [num2str(ScaleBar.Length),' \mum'],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(1),...
                       ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        PanelLabel,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(1),...
                       ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Ep',num2str(EpisodeNumber_Load)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if ~isempty(MarkerSetInfo.Markers)
                        for Marker=1:length(MarkerSetInfo.Markers)
                            if any(EpisodeNumber_Load==[MarkerSetInfo.Markers(Marker).MarkerStart:MarkerSetInfo.Markers(Marker).MarkerEnd])
                                text(ScaleBar.XData(1),...
                                   ScaleBar.YData(1)-(4)*LabelVertAdjust,...
                                    MarkerSetInfo.Markers(Marker).MarkerShortLabel,'FontSize',LabelFontSize,...
                                    'color',MarkerSetInfo.Markers(Marker).MarkerColor,...
                                    'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                            end
                        end
                    end
                    text(ScaleBar.XData(1)+abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                       ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        TimePoint,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(1)+abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        ['Stim',num2str(StimCount),' '],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if IsStimFrame                        
                        text(ScaleBar.XData(2),...
                            ScaleBar.YData(1)-(2.2)*LabelVertAdjust,...
                            ['*'],'FontSize',LabelFontSize*2,'color',LabelColor,...
                            'HorizontalAlignment','center','FontName','Arial')
                    end
                    text(ScaleBar.XData(1)+abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Im',num2str(ImageNumber)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                else
                    text(ScaleBar.XData(2),...
                        ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        [num2str(ScaleBar.Length),' \mum'],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(2),...
                       ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        PanelLabel,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(2),...
                       ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Ep',num2str(EpisodeNumber_Load)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if ~isempty(MarkerSetInfo.Markers)
                        for Marker=1:length(MarkerSetInfo.Markers)
                            if any(EpisodeNumber_Load==[MarkerSetInfo.Markers(Marker).MarkerStart:MarkerSetInfo.Markers(Marker).MarkerEnd])
                                text(ScaleBar.XData(2),...
                                   ScaleBar.YData(1)-(4)*LabelVertAdjust,...
                                    MarkerSetInfo.Markers(Marker).MarkerShortLabel,'FontSize',LabelFontSize,...
                                    'color',MarkerSetInfo.Markers(Marker).MarkerColor,...
                                    'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                            end
                        end
                    end
                    text(ScaleBar.XData(2)-abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                       ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        TimePoint,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(2)-abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        ['Stim',num2str(StimCount),' '],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if IsStimFrame                        
                        text(ScaleBar.XData(1),...
                            ScaleBar.YData(1)-(2.2)*LabelVertAdjust,...
                            ['*'],'FontSize',LabelFontSize*2,'color',LabelColor,...
                            'HorizontalAlignment','center','FontName','Arial')
                    end
                    text(ScaleBar.XData(2)-abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Im',num2str(ImageNumber)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                end
                if ~isempty(TempCoords)
                    for CircleNum=1:size(TempCoords,1)
                        Plot_Circle2(TempCoords(CircleNum,2)+Circle_X_Adjust,TempCoords(CircleNum,1)+Circle_Y_Adjust,...
                            CircleRadius,CircleLineStyle,CircleLineWidth,CoordColor);
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Panel 3 CorrAmp_Thresh
            if HorzMovie
                subtightplot(1,4,3,[0,0],[0,0],[0,0]);
            else
                subtightplot(2,2,3,[0,0],[0,0],[0,0]);
            end
            PanelLabel='Thresh';
            for zzzzz=1:1
                CorrAmp=max(ImageArray_CorrAmp_Events_Thresh(:,:,GoodEventPersistenceFrames),[],3);
                if ~any(CorrAmp(:)>0)
                    CorrAmp_Color=EmptyMaskedImage;
                else
                    [~,CorrAmp_Color,~]=Adjust_Contrast_and_Color(CorrAmp,ColorLimits2(1),ColorLimits2(2),ColorMap,ColorScalar1);
                    CorrAmp_Color=ColorMasking(CorrAmp_Color,~AllBoutonsRegion,OverlayColor);
                end
                if EmbedColorBars
                    CorrAmp_Color=EmbedColorMap_Color(CorrAmp_Color,ColorBar2Orientation,ColorBar2Location,ColorBar2Height,ColorBar2Width,ColorLimits2,ColorMap);
                end
                imshow(CorrAmp_Color,'Border','tight');
                hold on
                if UseBorderLine
                    for j=1:length(BorderLine)
                        plot(BorderLine{j}.BorderLine(:,2),...
                            BorderLine{j}.BorderLine(:,1),...
                            '-','color',BorderColor,'linewidth',BorderThickness)
                    end
                end
                if EmbedColorBars
                    [P1,P2,P3,P4,T1]=PlotBox2([ColorBar1Location(1),ColorBar1Location(2),ColorBar1Width,ColorBar1Height],'-','w',2,[],[],[]);
                    txt1a=text(ColorBar1Location(1)-ColorBar1Label_LowerLimitOffset,ColorBar1Location(2)+ColorBar1Height/2,num2str(ColorLimits1(1)),'color','w','FontSize',LabelFontSize,'FontName','Arial');
                    txt2a=text(ColorBar1Location(1)+ColorBar1Width+ColorBar1Label_UpperLimitOffset,ColorBar1Location(2)+ColorBar1Height/2,num2str(ColorLimits1(2)),'color','w','FontSize',LabelFontSize,'FontName','Arial');
                    txt3a=text(ColorBar1Location(1)+ColorBar1Width/2+ColorBar1Label_XOffset,ColorBar1Location(2)+ColorBar1Height+ColorBar1Label_YOffset,ColorBar1Label,'color','w','FontSize',LabelFontSize,'FontName','Arial');
                end
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gcf, 'color', 'white');
                plot(ScaleBar.XData,ScaleBar.YData,...
                    '-','color',ScaleBar.Color,'linewidth',ScaleBar.Width);
                if strcmp(ScaleBar.PointerSide,'L')
                    text(ScaleBar.XData(1),...
                        ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        [num2str(ScaleBar.Length),' \mum'],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(1),...
                       ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        PanelLabel,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(1),...
                       ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Ep',num2str(EpisodeNumber_Load)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if ~isempty(MarkerSetInfo.Markers)
                        for Marker=1:length(MarkerSetInfo.Markers)
                            if any(EpisodeNumber_Load==[MarkerSetInfo.Markers(Marker).MarkerStart:MarkerSetInfo.Markers(Marker).MarkerEnd])
                                text(ScaleBar.XData(1),...
                                   ScaleBar.YData(1)-(4)*LabelVertAdjust,...
                                    MarkerSetInfo.Markers(Marker).MarkerShortLabel,'FontSize',LabelFontSize,...
                                    'color',MarkerSetInfo.Markers(Marker).MarkerColor,...
                                    'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                            end
                        end
                    end
                    text(ScaleBar.XData(1)+abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                       ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        TimePoint,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(1)+abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        ['Stim',num2str(StimCount),' '],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if IsStimFrame                        
                        text(ScaleBar.XData(2),...
                            ScaleBar.YData(1)-(2.2)*LabelVertAdjust,...
                            ['*'],'FontSize',LabelFontSize*2,'color',LabelColor,...
                            'HorizontalAlignment','center','FontName','Arial')
                    end
                    text(ScaleBar.XData(1)+abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Im',num2str(ImageNumber)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                else
                    text(ScaleBar.XData(2),...
                        ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        [num2str(ScaleBar.Length),' \mum'],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(2),...
                       ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        PanelLabel,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(2),...
                       ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Ep',num2str(EpisodeNumber_Load)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if ~isempty(MarkerSetInfo.Markers)
                        for Marker=1:length(MarkerSetInfo.Markers)
                            if any(EpisodeNumber_Load==[MarkerSetInfo.Markers(Marker).MarkerStart:MarkerSetInfo.Markers(Marker).MarkerEnd])
                                text(ScaleBar.XData(2),...
                                   ScaleBar.YData(1)-(4)*LabelVertAdjust,...
                                    MarkerSetInfo.Markers(Marker).MarkerShortLabel,'FontSize',LabelFontSize,...
                                    'color',MarkerSetInfo.Markers(Marker).MarkerColor,...
                                    'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                            end
                        end
                    end
                    text(ScaleBar.XData(2)-abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                       ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        TimePoint,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(2)-abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        ['Stim',num2str(StimCount),' '],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if IsStimFrame                        
                        text(ScaleBar.XData(1),...
                            ScaleBar.YData(1)-(2.2)*LabelVertAdjust,...
                            ['*'],'FontSize',LabelFontSize*2,'color',LabelColor,...
                            'HorizontalAlignment','center','FontName','Arial')
                    end
                    text(ScaleBar.XData(2)-abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Im',num2str(ImageNumber)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                end
                if ~isempty(TempCoords)
                    for CircleNum=1:size(TempCoords,1)
                        Plot_Circle2(TempCoords(CircleNum,2)+Circle_X_Adjust,TempCoords(CircleNum,1)+Circle_Y_Adjust,...
                            CircleRadius,CircleLineStyle,CircleLineWidth,CoordColor);
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Panel 4 CorrAmp_Thresh_Clean
            if HorzMovie
                subtightplot(1,4,4,[0,0],[0,0],[0,0]);
            else
                subtightplot(2,2,4,[0,0],[0,0],[0,0]);
            end
            PanelLabel='Clean';
            for zzzzz=1:1
                if ImagingInfo.ModalityType~=1
                    CorrAmp=max(ImageArray_CorrAmp_Events_Thresh_Clean(:,:,GoodEventPersistenceFrames),[],3);
                    if ~any(CorrAmp(:)>0)
                        CorrAmp_Color=EmptyMaskedImage;
                    else
                        [~,CorrAmp_Color,~]=Adjust_Contrast_and_Color(CorrAmp,ColorLimits2(1),ColorLimits2(2),ColorMap,ColorScalar2);
                        CorrAmp_Color=ColorMasking(CorrAmp_Color,~AllBoutonsRegion,OverlayColor);
                    end
                    if EmbedColorBars
                        CorrAmp_Color=EmbedColorMap_Color(CorrAmp_Color,ColorBar2Orientation,ColorBar2Location,ColorBar2Height,ColorBar2Width,ColorLimits2,ColorMap);
                    end
                    imshow(CorrAmp_Color,'Border','tight');
                else
                    imshow(CorrAmp_Alt_Color,'Border','tight');
                end
                hold on
                if UseBorderLine
                    for j=1:length(BorderLine)
                        plot(BorderLine{j}.BorderLine(:,2),...
                            BorderLine{j}.BorderLine(:,1),...
                            '-','color',BorderColor,'linewidth',BorderThickness)
                    end
                end
                if EmbedColorBars
                    [P1,P2,P3,P4,T1]=PlotBox2([ColorBar1Location(1),ColorBar1Location(2),ColorBar1Width,ColorBar1Height],'-','w',2,[],[],[]);
                    txt1a=text(ColorBar1Location(1)-ColorBar1Label_LowerLimitOffset,ColorBar1Location(2)+ColorBar1Height/2,num2str(ColorLimits1(1)),'color','w','FontSize',LabelFontSize,'FontName','Arial');
                    txt2a=text(ColorBar1Location(1)+ColorBar1Width+ColorBar1Label_UpperLimitOffset,ColorBar1Location(2)+ColorBar1Height/2,num2str(ColorLimits1(2)),'color','w','FontSize',LabelFontSize,'FontName','Arial');
                    txt3a=text(ColorBar1Location(1)+ColorBar1Width/2+ColorBar1Label_XOffset,ColorBar1Location(2)+ColorBar1Height+ColorBar1Label_YOffset,ColorBar1Label,'color','w','FontSize',LabelFontSize,'FontName','Arial');
                end
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gcf, 'color', 'white');
                plot(ScaleBar.XData,ScaleBar.YData,...
                    '-','color',ScaleBar.Color,'linewidth',ScaleBar.Width);
                if strcmp(ScaleBar.PointerSide,'L')
                    text(ScaleBar.XData(1),...
                        ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        [num2str(ScaleBar.Length),' \mum'],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(1),...
                       ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        PanelLabel,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(1),...
                       ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Ep',num2str(EpisodeNumber_Load)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if ~isempty(MarkerSetInfo.Markers)
                        for Marker=1:length(MarkerSetInfo.Markers)
                            if any(EpisodeNumber_Load==[MarkerSetInfo.Markers(Marker).MarkerStart:MarkerSetInfo.Markers(Marker).MarkerEnd])
                                text(ScaleBar.XData(1),...
                                   ScaleBar.YData(1)-(4)*LabelVertAdjust,...
                                    MarkerSetInfo.Markers(Marker).MarkerShortLabel,'FontSize',LabelFontSize,...
                                    'color',MarkerSetInfo.Markers(Marker).MarkerColor,...
                                    'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                            end
                        end
                    end
                    text(ScaleBar.XData(1)+abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                       ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        TimePoint,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(1)+abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        ['Stim',num2str(StimCount),' '],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if IsStimFrame                        
                        text(ScaleBar.XData(2),...
                            ScaleBar.YData(1)-(2.2)*LabelVertAdjust,...
                            ['*'],'FontSize',LabelFontSize*2,'color',LabelColor,...
                            'HorizontalAlignment','center','FontName','Arial')
                    end
                    text(ScaleBar.XData(1)+abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Im',num2str(ImageNumber)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                else
                    text(ScaleBar.XData(2),...
                        ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        [num2str(ScaleBar.Length),' \mum'],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(2),...
                       ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        PanelLabel,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(2),...
                       ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Ep',num2str(EpisodeNumber_Load)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if ~isempty(MarkerSetInfo.Markers)
                        for Marker=1:length(MarkerSetInfo.Markers)
                            if any(EpisodeNumber_Load==[MarkerSetInfo.Markers(Marker).MarkerStart:MarkerSetInfo.Markers(Marker).MarkerEnd])
                                text(ScaleBar.XData(2),...
                                   ScaleBar.YData(1)-(4)*LabelVertAdjust,...
                                    MarkerSetInfo.Markers(Marker).MarkerShortLabel,'FontSize',LabelFontSize,...
                                    'color',MarkerSetInfo.Markers(Marker).MarkerColor,...
                                    'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                            end
                        end
                    end
                    text(ScaleBar.XData(2)-abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                       ScaleBar.YData(1)-(1)*LabelVertAdjust,...
                        TimePoint,'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    text(ScaleBar.XData(2)-abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(2)*LabelVertAdjust,...
                        ['Stim',num2str(StimCount),' '],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                    if IsStimFrame                        
                        text(ScaleBar.XData(1),...
                            ScaleBar.YData(1)-(2.2)*LabelVertAdjust,...
                            ['*'],'FontSize',LabelFontSize*2,'color',LabelColor,...
                            'HorizontalAlignment','center','FontName','Arial')
                    end
                    text(ScaleBar.XData(2)-abs(ScaleBar.XData(2)-ScaleBar.XData(1))/2,...
                        ScaleBar.YData(1)-(3)*LabelVertAdjust,...
                        ['Im',num2str(ImageNumber)],'FontSize',LabelFontSize,'color',LabelColor,...
                        'HorizontalAlignment',LabelAlignment,'FontName','Arial')
                end
                if ~isempty(TempCoords)
                    for CircleNum=1:size(TempCoords,1)
                        Plot_Circle2(TempCoords(CircleNum,2)+Circle_X_Adjust,TempCoords(CircleNum,1)+Circle_Y_Adjust,...
                            CircleRadius,CircleLineStyle,CircleLineWidth,CoordColor);
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            figure(MovieFig)
            set(MovieFig,'units','Pixels','position',[0,80,FigureSize]);
            drawnow
            pause(0.001)
            figure(MovieFig)
            OneFrame = getframe(MovieFig);
            for ii=1:MovieFrames
                writeVideo(mov,OneFrame);
            end
            if rem(OverallFrameCount,TimerInterval)==0&&OverallFrameCount<ImagingInfo.TotalNumFrames
                TimerCount=TimerCount+1;
                Movie_Time=toc(Movie_Timer);
                MovieTimes(TimerCount)=Movie_Time;
                FramesLeft=ImagingInfo.TotalNumFrames-OverallFrameCount;

                ETA_Time=(FramesLeft/TimerInterval)*mean(MovieTimes);
                disp(['Overall Frames ',num2str(OverallFrameCount-TimerInterval+1),'-',num2str(OverallFrameCount),...
                   ' Took ',num2str(round(Movie_Time)),'s ETA = ',num2str(round(ETA_Time/60)),'min...'])
               Movie_Timer=tic;
            end
            clear CorrAmp TempCoords TempFitImage_Color TempFitImage CorrAmp_Color
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if AbortButton
                if get(AbortButtonHandle,'userdata')
                    warning on;warning('Aborting Movies...');warning off;
                    AbortMovie=1;
                else
                    ImageNumber=ImageNumber+1;
                end
            else
                ImageNumber=ImageNumber+1;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        EpisodeNumber=EpisodeNumber+1;
        EpisodeNumber_Load=EpisodeNumber_Load+1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Overall_Time=toc(Overall_Timer);
    fprintf(['Finished ',MovieName,' Took ',num2str(Overall_Time),'s\n'])
    close(mov);
    close(MovieFig)
    close(AbortFig)
    TempName=[MoviesScratchDir,dc,MovieName,'.avi'];
    TempName1=[MovieName,'.avi'];
    % fprintf(['Copying ',TempName1,'...'])
    % [CopyStatus,CopyMessage]=copyfile(TempName,SaveDir);
    % if CopyStatus
    %     disp('Copy successful!')
    %     warning('Deleting MoviesScratchDir Version')
    %     delete(TempName);
    % else
    %     warning(CopyMessage)
    % end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
    
    error('Not ready yet!')


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
