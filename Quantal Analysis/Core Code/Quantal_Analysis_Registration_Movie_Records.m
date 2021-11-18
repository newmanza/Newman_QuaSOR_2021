%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
if ImagingInfo.TotalNumFrames>5000
    ReferenceFrames=50;
    PlayBackSpeed=150;
else
    ReferenceFrames=40;
    PlayBackSpeed=100;
end
if ImagingInfo.NumEpisodes>100
    PlayBackSpeed1=30;
else
    PlayBackSpeed1=20;
end
QuickCheckInterval=10;
MovieRepeats=3;
NumIntervals=ImagingInfo.TotalNumFrames/QuickCheckInterval;
clear IntervalsNums
for i=1:NumIntervals
    IntervalsNums(i)=(i-1)*QuickCheckInterval+1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
ScaleFactor=1;
ImageWidth=size(RegistrationSettings.OverallReferenceImage,2);
ImageHeight=size(RegistrationSettings.OverallReferenceImage,1);
FigureSize=[ImageWidth*2*ScaleFactor,ImageHeight*1*ScaleFactor];
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
ScaleFactor_Crop=2;
ImageWidth_Crop=size(imcrop(RegistrationSettings.OverallReferenceImage,Crop_Props.BoundingBox),2);
ImageHeight_Crop=size(imcrop(RegistrationSettings.OverallReferenceImage,Crop_Props.BoundingBox),1);
FigureSize_Crop=[ImageWidth_Crop*1*ScaleFactor_Crop,ImageHeight_Crop*1*ScaleFactor_Crop];
if FigureSize_Crop(2)>ScreenSize(4)-150
    ExportScalarModifier=(ScreenSize(4)-150)/FigureSize_Crop(2);
    warning(['Adjusting Vertical ExportSize by ',num2str(ExportScalarModifier),' to fit Monitor!'])
    FigureSize_Crop=round(FigureSize_Crop*ExportScalarModifier);
end
if FigureSize_Crop(1)>ScreenSize(3)
    ExportScalarModifier=ScreenSize(3)/FigureSize_Crop(1);
    warning(['Adjusting Horizontal ExportSize by ',num2str(ExportScalarModifier),' to fit Monitor!'])
    FigureSize_Crop=round(FigureSize_Crop*ExportScalarModifier);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
MovieQuality=75;
ColorScalar=1;
OverlayColor=[0.3 0.3,0.3];
ColorMap='gray';
UseBorderLine=1;
BorderThickness=0.5;    
LowPercent=0;
HighPercent=0.6;
LabelLocation=[5,12];
MaxIntensity=max(ImageArrayReg_AllImages(:));
MinIntensity=min(ImageArrayReg_AllImages(:));
ColorLimits=double([MinIntensity*LowPercent,MaxIntensity*HighPercent]);
close all
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
MovieFig=figure('name',StackSaveName);
set(MovieFig,'units','Pixels','position',[0,40,FigureSize]);
set(MovieFig, 'color', 'white');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MovieFig_Crop=figure('name',StackSaveName);
set(MovieFig_Crop,'units','Pixels','position',[ImageWidth*2*ScaleFactor,40,FigureSize_Crop]);
set(MovieFig_Crop, 'color', 'white');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MovieOptions=[1];
MovieName_AllImages=[StackSaveName , ' Registration Record All Images with RAW.avi'];
if exist([MoviesScratchDir,dc,MovieName_AllImages])
    delete([MoviesScratchDir,dc,MovieName_AllImages])
end
disp(['Exporting: ',MovieName_AllImages,'...'])
Movie_AllImages = VideoWriter([MoviesScratchDir,dc,MovieName_AllImages],'Motion JPEG AVI');
Movie_AllImages.FrameRate = PlayBackSpeed;
Movie_AllImages.Quality = MovieQuality;
open(Movie_AllImages);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MovieName_Crop_AllImages=[StackSaveName , ' Registration Record All Images.avi'];
if exist([MoviesScratchDir,dc,MovieName_Crop_AllImages])
    delete([MoviesScratchDir,dc,MovieName_Crop_AllImages])
end
disp(['Exporting: ',MovieName_Crop_AllImages,'...'])
Movie_Crop_AllImages = VideoWriter([MoviesScratchDir,dc,MovieName_Crop_AllImages],'Motion JPEG AVI');
Movie_Crop_AllImages.FrameRate = PlayBackSpeed;
Movie_Crop_AllImages.Quality = MovieQuality;
open(Movie_Crop_AllImages);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ImagingInfo.NumEpisodes>1
    MovieOptions=[MovieOptions,2];
    MovieName_FirstImages=[StackSaveName , ' Registration Record First Images with RAW.avi'];
    if exist([MoviesScratchDir,dc,MovieName_FirstImages])
        delete([MoviesScratchDir,dc,MovieName_FirstImages])
    end
    disp(['Exporting: ',MovieName_FirstImages,'...'])
    Movie_FirstImages = VideoWriter([MoviesScratchDir,dc,MovieName_FirstImages],'Motion JPEG AVI');
    Movie_FirstImages.FrameRate = PlayBackSpeed1;
    Movie_FirstImages.Quality = MovieQuality;
    open(Movie_FirstImages);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MovieName_Crop_FirstImages=[StackSaveName , ' Registration Record First Images.avi'];
    if exist([MoviesScratchDir,dc,MovieName_Crop_FirstImages])
        delete([MoviesScratchDir,dc,MovieName_Crop_FirstImages])
    end
    disp(['Exporting: ',MovieName_Crop_FirstImages,'...'])
    Movie_Crop_FirstImages = VideoWriter([MoviesScratchDir,dc,MovieName_Crop_FirstImages],'Motion JPEG AVI');
    Movie_Crop_FirstImages.FrameRate = PlayBackSpeed1;
    Movie_Crop_FirstImages.Quality = MovieQuality;
    open(Movie_Crop_FirstImages);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ImagingInfo.TotalNumFrames>400&&RegistrationSettings.RegistrationClass~=1
    MovieOptions=[MovieOptions,3];
    MovieName_QuickCheck=[StackSaveName , ' Registration Record Quick Check with RAW.avi'];
    if exist([MoviesScratchDir,dc,MovieName_QuickCheck])
        delete([MoviesScratchDir,dc,MovieName_QuickCheck])
    end
    disp(['Exporting: ',MovieName_QuickCheck,'...'])
    Movie_QuickCheck = VideoWriter([MoviesScratchDir,dc,MovieName_QuickCheck],'Motion JPEG AVI');
    Movie_QuickCheck.FrameRate = PlayBackSpeed1;
    Movie_QuickCheck.Quality = MovieQuality;
    open(Movie_QuickCheck);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MovieName_Crop_QuickCheck=[StackSaveName , ' Registration Record Quick Check.avi'];
    if exist([MoviesScratchDir,dc,MovieName_Crop_QuickCheck])
        delete([MoviesScratchDir,dc,MovieName_Crop_QuickCheck])
    end
    disp(['Exporting: ',MovieName_Crop_QuickCheck,'...'])
    Movie_Crop_QuickCheck = VideoWriter([MoviesScratchDir,dc,MovieName_Crop_QuickCheck],'Motion JPEG AVI');
    Movie_Crop_QuickCheck.FrameRate = PlayBackSpeed1;
    Movie_Crop_QuickCheck.Quality = MovieQuality;
    open(Movie_Crop_QuickCheck);
end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,TempContrastedImageColor1,~]=Adjust_Contrast_and_Color(double(RegistrationSettings.OverallReferenceImage),ColorLimits(1),ColorLimits(2),ColorMap,ColorScalar);
[~,TempContrastedImageColor2,~]=...
    Adjust_Contrast_and_Color(double(imcrop(RegistrationSettings.OverallReferenceImage,Crop_Props.BoundingBox)),ColorLimits(1),ColorLimits(2),ColorMap,ColorScalar);
TempContrastedImageColor2=ColorMasking(TempContrastedImageColor2,~AllBoutonsRegion,OverlayColor);
EpisodeNumbers=[];
ImageCount=0;
for e=1:ImagingInfo.NumEpisodes
    for i=1:ImagingInfo.FramesPerEpisode
        ImageCount=ImageCount+1;
        EpisodeNumbers(ImageCount)=e;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(MovieFig);
clf
subtightplot(1,2,1,[0.01,0.01],[0,0],[0,0])
imshow(TempContrastedImageColor1,[],'border','tight')
caxis(ColorLimits)
colormap(ColorMap)
hold all
text(LabelLocation(1),LabelLocation(2),'Reference','color','w','FontName','Arial','FontSize',10)
set(gca,'XTick', []); set(gca,'YTick', []);
%%%%%%%%%%%
subtightplot(1,2,2,[0.01,0.01],[0,0],[0,0])
imshow(TempContrastedImageColor2,[],'border','tight')
hold on
if UseBorderLine
    for j=1:length(BorderLine)
        plot(BorderLine{j}.BorderLine(:,2),...
            BorderLine{j}.BorderLine(:,1),...
            '-','color',Color,'linewidth',BorderThickness)
    end
end
text(LabelLocation(1),LabelLocation(2),'Reference','color','w','FontName','Arial','FontSize',10)
plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',1);
hold on
set(gca,'XTick', []); set(gca,'YTick', []);
%%%%%%%%%%%%%
figure(MovieFig);
drawnow
set(MovieFig,'units','Pixels','position',[0,40,FigureSize]);
OneFrame = getframe(MovieFig);
for i=1:ReferenceFrames
    if any(MovieOptions==1)
        writeVideo(Movie_AllImages,OneFrame);
    end
    if any(MovieOptions==2)
        writeVideo(Movie_FirstImages,OneFrame);
    end     
    if any(MovieOptions==3)
        writeVideo(Movie_QuickCheck,OneFrame);
    end     
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(MovieFig_Crop);
clf
subtightplot(1,1,1,[0.01,0.01],[0,0],[0,0])
imshow(TempContrastedImageColor2,[],'border','tight')
hold on
if UseBorderLine
    for j=1:length(BorderLine)
        plot(BorderLine{j}.BorderLine(:,2),...
            BorderLine{j}.BorderLine(:,1),...
            '-','color',Color,'linewidth',BorderThickness)
    end
end
text(LabelLocation(1),LabelLocation(2),'Reference','color','w','FontName','Arial','FontSize',10)
plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',1);
hold on
set(gca,'XTick', []); set(gca,'YTick', []);
%%%%%%%%%%%%%
figure(MovieFig_Crop);
drawnow
set(MovieFig_Crop,'units','Pixels','position',[ImageWidth*2*ScaleFactor,40,FigureSize_Crop]);
OneFrame = getframe(MovieFig_Crop);
for i=1:ReferenceFrames
    if any(MovieOptions==1)
        writeVideo(Movie_Crop_AllImages,OneFrame);
    end
    if any(MovieOptions==2)
        writeVideo(Movie_Crop_FirstImages,OneFrame);
    end     
    if any(MovieOptions==3)
        writeVideo(Movie_Crop_QuickCheck,OneFrame);
    end     
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AbortMovie=0;
ImageNumber=1;
while ~AbortMovie&&ImageNumber<=ImagingInfo.TotalNumFrames  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EpisodeNumber=EpisodeNumbers(ImageNumber);

    [~,TempContrastedImageColor1,~]=...
        Adjust_Contrast_and_Color(double(ImageArray(:,:,ImageNumber)),ColorLimits(1),ColorLimits(2),ColorMap,ColorScalar);
    [~,TempContrastedImageColor2,~]=...
        Adjust_Contrast_and_Color(double(ImageArrayReg_AllImages(:,:,ImageNumber)),ColorLimits(1),ColorLimits(2),ColorMap,ColorScalar);
    TempContrastedImageColor2=ColorMasking(TempContrastedImageColor2,~AllBoutonsRegion,OverlayColor);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(MovieFig);
    clf
    %%%%%%%%%%%
    subtightplot(1,2,1,[0.01,0.01],[0,0],[0,0])
    imshow(TempContrastedImageColor1,[],'border','tight')
    hold all
    if UseBorderLine&&RegistrationSettings.RegistrationClass==1
        TempBoundingBox=Crop_Props.BoundingBox;
        if RegistrationSettings.RegistrationClass==1
            TempBoundingBox(1)=TempBoundingBox(1)-DeltaX_All_Translations(EpisodeNumber);
            TempBoundingBox(2)=TempBoundingBox(2)-DeltaY_All_Translations(EpisodeNumber);
        else
            TempBoundingBox(1)=TempBoundingBox(1)-DeltaX_All_Translations(ImageNumber);
            TempBoundingBox(2)=TempBoundingBox(2)-DeltaY_All_Translations(ImageNumber);
        end
        PlotBox(TempBoundingBox,'-','y',BorderThickness,[],15,'y')
    elseif UseBorderLine
        TempBoundingBox=Crop_Props.BoundingBox;
        if RegistrationSettings.RegistrationClass==1
            TempBoundingBox(1)=TempBoundingBox(1)-DeltaX_All_Translations(ImageNumber);
            TempBoundingBox(2)=TempBoundingBox(2)-DeltaY_All_Translations(ImageNumber);
        else
            TempBoundingBox(1)=TempBoundingBox(1)-DeltaX_All_Translations(ImageNumber);
            TempBoundingBox(2)=TempBoundingBox(2)-DeltaY_All_Translations(ImageNumber);
        end
        PlotBox(TempBoundingBox,'-','y',BorderThickness,[],15,'y')
    end
    hold on
    text(LabelLocation(1),LabelLocation(2),['Ep',num2str(EpisodeNumber),' Im',num2str(ImageNumber)],'color','w','FontName','Arial','FontSize',10)
    set(gca,'XTick', []); set(gca,'YTick', []);
    %%%%%%%%%%%
    subtightplot(1,2,2,[0.01,0.01],[0,0],[0,0])
    imshow(TempContrastedImageColor2,[],'border','tight')
    hold on
    if UseBorderLine
        for j=1:length(BorderLine)
            plot(BorderLine{j}.BorderLine(:,2),...
                BorderLine{j}.BorderLine(:,1),...
                '-','color',Color,'linewidth',BorderThickness)
        end
    end
    plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',1);
    hold on
    text(LabelLocation(1),LabelLocation(2),['Ep',num2str(EpisodeNumber),' Im',num2str(ImageNumber)],'color','w','FontName','Arial','FontSize',10)
    set(gca,'XTick', []); set(gca,'YTick', []);
    %%%%%%%%%%%%%
    figure(MovieFig);
    drawnow
    set(MovieFig,'units','Pixels','position',[0,40,FigureSize]);
    figure(MovieFig);
    OneFrame = getframe(MovieFig);
    if any(MovieOptions==1)
        writeVideo(Movie_AllImages,OneFrame);
    end
    if any(MovieOptions==2)&&any(ImageNumber==ImagingInfo.AllGoodFirstFrames)
        writeVideo(Movie_FirstImages,OneFrame);
    end     
    if any(MovieOptions==3)&&any(IntervalsNums==ImageNumber)
        writeVideo(Movie_QuickCheck,OneFrame);
    end     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(MovieFig_Crop);
    clf
    %%%%%%%%%%%
    subtightplot(1,1,1,[0.01,0.01],[0,0],[0,0])
    imshow(TempContrastedImageColor2,[],'border','tight')
    hold on
    if UseBorderLine
        for j=1:length(BorderLine)
            plot(BorderLine{j}.BorderLine(:,2),...
                BorderLine{j}.BorderLine(:,1),...
                '-','color',Color,'linewidth',BorderThickness)
        end
    end
    plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',1);
    hold on
    text(LabelLocation(1),LabelLocation(2),['Ep',num2str(EpisodeNumber),' Im',num2str(ImageNumber)],'color','w','FontName','Arial','FontSize',10)
    set(gca,'XTick', []); set(gca,'YTick', []);
    %%%%%%%%%%%%%
    figure(MovieFig_Crop);
    drawnow
    set(MovieFig_Crop,'units','Pixels','position',[ImageWidth*2*ScaleFactor,40,FigureSize_Crop]);
    figure(MovieFig_Crop);
    OneFrame = getframe(MovieFig_Crop);
    if any(MovieOptions==1)
        writeVideo(Movie_Crop_AllImages,OneFrame);
    end
    if any(MovieOptions==2)&&any(ImageNumber==ImagingInfo.AllGoodFirstFrames)
        writeVideo(Movie_Crop_FirstImages,OneFrame);
    end     
    if any(MovieOptions==3)&&any(IntervalsNums==ImageNumber)
        writeVideo(Movie_Crop_QuickCheck,OneFrame);
    end     
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close(MovieFig)
close(MovieFig_Crop)
if any(MovieOptions==1)
    close(Movie_AllImages);
    close(Movie_Crop_AllImages);
end
if any(MovieOptions==2)
    close(Movie_FirstImages);
    if MovieRepeats>1
        warning(['Adding Repeats for ',MovieName_FirstImages])
        [TempArray,AVI_Info,FPS]=AVI_Import([MoviesScratchDir,dc,MovieName_FirstImages]);
        open(Movie_FirstImages);
        progressbar([MovieName_FirstImages,' Repeat'],'Frame')
        for r=1:MovieRepeats
            for i=1:size(TempArray,4)
                progressbar(r/MovieRepeats,i/size(TempArray,4))
                writeVideo(Movie_FirstImages,TempArray(:,:,:,i));
            end
        end
        close(Movie_FirstImages);
        clear TempArray AVI_Info FPS
    end
    %%%%%%%%%%%%%%%%%%%%%%%
    close(Movie_Crop_FirstImages);
    if MovieRepeats>1
        warning(['Adding Repeats for ',MovieName_Crop_FirstImages])
        [TempArray,AVI_Info,FPS]=AVI_Import([MoviesScratchDir,dc,MovieName_Crop_FirstImages]);
        open(Movie_Crop_FirstImages);
        progressbar([MovieName_Crop_FirstImages,' Repeat'],'Frame')
        for r=1:MovieRepeats
            for i=1:size(TempArray,4)
                progressbar(r/MovieRepeats,i/size(TempArray,4))
                writeVideo(Movie_Crop_FirstImages,TempArray(:,:,:,i));
            end
        end
        close(Movie_Crop_FirstImages);
        clear TempArray AVI_Info FPS
    end
end     
if any(MovieOptions==3)
    close(Movie_QuickCheck);
    if MovieRepeats>1
        warning(['Adding Repeats for ',MovieName_QuickCheck])
        [TempArray,AVI_Info,FPS]=AVI_Import([MoviesScratchDir,dc,MovieName_QuickCheck]);
        open(Movie_QuickCheck);
        progressbar([MovieName_QuickCheck,' Repeat'],'Frame')
        for r=1:MovieRepeats
            for i=1:size(TempArray,4)
                progressbar(r/MovieRepeats,i/size(TempArray,4))
                writeVideo(Movie_QuickCheck,TempArray(:,:,:,i));
            end
        end
        close(Movie_QuickCheck);
        clear TempArray AVI_Info FPS
    end
    %%%%%%%%%%%%%%%%%%%%%%%
    close(Movie_Crop_QuickCheck);
    if MovieRepeats>1
        warning(['Adding Repeats for ',MovieName_Crop_QuickCheck])
        [TempArray,AVI_Info,FPS]=AVI_Import([MoviesScratchDir,dc,MovieName_Crop_QuickCheck]);
        open(Movie_Crop_QuickCheck);
        progressbar([MovieName_Crop_QuickCheck,' Repeat'],'Frame')
        for r=1:MovieRepeats
            for i=1:size(TempArray,4)
                progressbar(r/MovieRepeats,i/size(TempArray,4))
                writeVideo(Movie_Crop_QuickCheck,TempArray(:,:,:,i));
            end
        end
        close(Movie_Crop_QuickCheck);
        clear TempArray AVI_Info FPS
    end
end     
if AbortButton
    try
        close(AbortFig)
    end
end
fprintf(['Finished Exporting Registration Record Movies!\n'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Making DeltaF Movies...')
MovieQuality=75;
ColorScalar=1000;
ColorMap='jet';
UseBorderLine=1;
BorderThickness=0.5;    
StandardPosition=[20,50,600,600];
LowPercent=0;
HighPercent=0.25;
LabelLocation=[12,12];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if AbortButton
    %Safe Abort Figure
    AbortFig = figure('name',['Rec',num2str(RecordingNum),' ',StackSaveName]);set(gcf,'Units','normalized','Position',[0.8 0.8 0.2 0.1]);
    AbortText = uicontrol('Style','text',...
        'units','normalized',...
        'Fontsize',12,...
        'Position',[0.01 0.8 0.98 0.2],...
        'String',['Rec',num2str(RecordingNum),' ',StackSaveName]);
    AbortButtonHandle = uicontrol('Units','Normalized','Position', [0.05 0.05 0.9 0.75],'style','push',...
        'string',['Safe Abort Movies'],'callback','set(gcbo,''userdata'',1,''string'',''Aborting!!'')', ...
        'userdata',0) ;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MovieOptions=[1];
MovieName_AllImages=[StackSaveName , ' DeltaF Record All Images.avi'];
if exist([MoviesScratchDir,dc,MovieName_AllImages])
    delete([MoviesScratchDir,dc,MovieName_AllImages])
end
disp(['Exporting: ',MovieName_AllImages,'...'])
Movie_AllImages = VideoWriter([MoviesScratchDir,dc,MovieName_AllImages],'Motion JPEG AVI');
Movie_AllImages.FrameRate = PlayBackSpeed;
Movie_AllImages.Quality = MovieQuality;
open(Movie_AllImages);
%%%%%%%%%%%%%%%%%%%%%%
MovieFig_Crop=figure('name',StackSaveName);
set(MovieFig_Crop,'units','Pixels','position',[0,40,FigureSize_Crop]);
set(MovieFig_Crop, 'color', 'white');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if RegistrationSettings.RegistrationClass==1
    MovieOptions=[MovieOptions,2];
    MovieName_PeakFrames=[StackSaveName , ' DeltaF Record Peak Frames.avi'];
    if exist([MoviesScratchDir,dc,MovieName_PeakFrames])
        delete([MoviesScratchDir,dc,MovieName_PeakFrames])
    end
    disp(['Exporting: ',MovieName_PeakFrames,'...'])
    Movie_PeakFrames = VideoWriter([MoviesScratchDir,dc,MovieName_PeakFrames],'Motion JPEG AVI');
    Movie_PeakFrames.FrameRate = PlayBackSpeed1;
    Movie_PeakFrames.Quality = MovieQuality;
    open(Movie_PeakFrames);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if RegistrationSettings.RegistrationClass==1
    MovieOptions=[MovieOptions,3];
    MovieName_LastFrames=[StackSaveName , ' DeltaF Record Last Frames.avi'];
    if exist([MoviesScratchDir,dc,MovieName_LastFrames])
        delete([MoviesScratchDir,dc,MovieName_LastFrames])
    end
    disp(['Exporting: ',MovieName_LastFrames,'...'])
    Movie_LastFrames = VideoWriter([MoviesScratchDir,dc,MovieName_LastFrames],'Motion JPEG AVI');
    Movie_LastFrames.FrameRate = PlayBackSpeed1;
    Movie_LastFrames.Quality = MovieQuality;
    open(Movie_LastFrames);
end    
if ImagingInfo.TotalNumFrames>400&&RegistrationSettings.RegistrationClass~=1
    MovieOptions=[MovieOptions,4];
    MovieName_QuickCheck=[StackSaveName , ' DeltaF Record Quick Check.avi'];
    if exist([MoviesScratchDir,dc,MovieName_QuickCheck])
        delete([MoviesScratchDir,dc,MovieName_QuickCheck])
    end
    disp(['Exporting: ',MovieName_QuickCheck,'...'])
    Movie_QuickCheck = VideoWriter([MoviesScratchDir,dc,MovieName_QuickCheck],'Motion JPEG AVI');
    Movie_QuickCheck.FrameRate = PlayBackSpeed1;
    Movie_QuickCheck.Quality = MovieQuality;
    open(Movie_QuickCheck);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MaxIntensity=-10000000;
MinIntensity=10000000;
for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
    if SplitEpisodeFiles
        FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
        if ~exist([CurrentScratchDir,StackSaveName,FileSuffix])
            fprintf(['Copying: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
            [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
        end
        fprintf(['Loading: EpisodeStruct...'])
        load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
        EpisodeNumber=1;
    else
        EpisodeNumber=EpisodeNumber_Load;
    end
    TempFrames=EpisodeStruct(EpisodeNumber).Frames;
    TempStack=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaF;
    TempStack(isnan(TempStack))=0;
    MaxIntensity=max([MaxIntensity,max(TempStack(:))]);
    MinIntensity=min([MinIntensity,min(TempStack(:))]);
end
ColorLimits=double([MinIntensity*LowPercent,MaxIntensity*HighPercent]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EpisodeNumber_Load=1;
while ~AbortMovie&&EpisodeNumber_Load<=ImagingInfo.NumEpisodes
    if SplitEpisodeFiles
        FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
        fprintf(['Loading: EpisodeStruct...'])
        load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
        EpisodeNumber=1;
    else
        EpisodeNumber=EpisodeNumber_Load;
    end

    TempFrames=EpisodeStruct(EpisodeNumber).Frames;
    TempStack=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaF;
    TempStack(isnan(TempStack))=0;
    clf
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    AbortMovie=0;
    ImageNumber1=1;
    while ~AbortMovie&&ImageNumber1<=length(TempFrames)  
        ImageNumber=TempFrames(ImageNumber1);
        figure(MovieFig_Crop);
        clf
        %%%%%%%%%%%
        subtightplot(1,1,1,[0.01,0.01],[0,0],[0,0])
        [~,TempContrastedImageColor,~]=Adjust_Contrast_and_Color(double(TempStack(:,:,ImageNumber1)),ColorLimits(1),ColorLimits(2),ColorMap,ColorScalar);
        TempContrastedImageColor=ColorMasking(TempContrastedImageColor,~AllBoutonsRegion,OverlayColor);
        imshow(TempContrastedImageColor,[],'border','tight')
        hold on
        if UseBorderLine
            for j=1:length(BorderLine)
                plot(BorderLine{j}.BorderLine(:,2),...
                    BorderLine{j}.BorderLine(:,1),...
                    '-','color',Color,'linewidth',BorderThickness)
            end
        end
        plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',1);
        hold on
        text(LabelLocation(1),LabelLocation(2),['Ep',num2str(EpisodeNumber_Load),' Im',num2str(ImageNumber)],'color','w','FontName','Arial','FontSize',10)
        set(gca,'XTick', []); set(gca,'YTick', []);
        %%%%%%%%%%%%%
        drawnow
        figure(MovieFig_Crop);
        set(MovieFig_Crop,'units','Pixels','position',[0,40,FigureSize_Crop]);
        figure(MovieFig_Crop);
        OneFrame = getframe(MovieFig_Crop);
        if any(MovieOptions==1)
            writeVideo(Movie_AllImages,OneFrame);
        end
        if any(MovieOptions==2)&&any(EpisodeStruct(EpisodeNumber).Frames(ImagingInfo.PeakFrame)==ImageNumber)
            writeVideo(Movie_PeakFrames,OneFrame);
        end     
        if any(MovieOptions==3)&&any(EpisodeStruct(EpisodeNumber).Frames(ImagingInfo.FramesPerEpisode)==ImageNumber)
            writeVideo(Movie_LastFrames,OneFrame);
        end     
        if any(MovieOptions==4)&&any(IntervalsNums==ImageNumber)
            writeVideo(Movie_QuickCheck,OneFrame);
        end     
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if AbortButton
            if get(AbortButtonHandle,'userdata')
                warning on;warning('Aborting Movies...');warning off;
                AbortMovie=1;
            else
                ImageNumber1=ImageNumber1+1;
            end
        else
            ImageNumber1=ImageNumber1+1;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EpisodeNumber_Load=EpisodeNumber_Load+1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close(MovieFig_Crop)
if any(MovieOptions==1)
    close(Movie_AllImages);
end
if ~AbortButton
    if any(MovieOptions==2)
        close(Movie_PeakFrames);
        if MovieRepeats>1
            warning(['Adding Repeats for ',MovieName_PeakFrames])
            [TempArray,AVI_Info,FPS]=AVI_Import([MoviesScratchDir,dc,MovieName_PeakFrames]);
            open(Movie_PeakFrames);
            progressbar([MovieName_PeakFrames,' Repeat'],'Frame')
            for r=1:MovieRepeats
                for i=1:size(TempArray,4)
                    progressbar(r/MovieRepeats,i/size(TempArray,4))
                    writeVideo(Movie_PeakFrames,TempArray(:,:,:,i));
                end
            end
            close(Movie_PeakFrames);
            clear TempArray AVI_Info FPS
        end
    end     
    if any(MovieOptions==3)
        close(Movie_LastFrames);
        if MovieRepeats>1
            warning(['Adding Repeats for ',MovieName_LastFrames])
            [TempArray,AVI_Info,FPS]=AVI_Import([MoviesScratchDir,dc,MovieName_LastFrames]);
            open(Movie_LastFrames);
            progressbar([MovieName_LastFrames,' Repeat'],'Frame')
            for r=1:MovieRepeats
                for i=1:size(TempArray,4)
                    progressbar(r/MovieRepeats,i/size(TempArray,4))
                    writeVideo(Movie_LastFrames,TempArray(:,:,:,i));
                end
            end
            close(Movie_LastFrames);
            clear TempArray AVI_Info FPS
        end
    end     
    if any(MovieOptions==4)
        close(Movie_QuickCheck);
        if MovieRepeats>1
            warning(['Adding Repeats for ',MovieName_QuickCheck])
            [TempArray,AVI_Info,FPS]=AVI_Import([MoviesScratchDir,dc,MovieName_QuickCheck]);
            open(Movie_QuickCheck);
            progressbar([MovieName_QuickCheck,' Repeat'],'Frame')
            for r=1:MovieRepeats
                for i=1:size(TempArray,4)
                    progressbar(r/MovieRepeats,i/size(TempArray,4))
                    writeVideo(Movie_QuickCheck,TempArray(:,:,:,i));
                end
            end
            close(Movie_QuickCheck);
            clear TempArray AVI_Info FPS
        end
    end     
end
if AbortButton
    try
        close(AbortFig)
    end
end
fprintf(['Finished DeltaF Movies!\n'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
