%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Distributed Network Analysis
%Server/Client Parameters (NOTE! this must match the server parameters)
File2Check='_RegistrationTracker.mat';
AnalysisLabel='Registration';
Function='Enhanced_Muli_Method_Tetanus_Registration.m';
BufferSize=50000;
Port=4020;
TimeOut=inf;
NumLoops=10;%Will prevent from going on forever
[ServerIP,ServerName]=Server_Picker;
ConnectionAttempts=10;
OverwriteData=1;
AllRecordingStatuses=zeros(1,length(Recording));
LoopCount=0;
StackSaveNameSuffix=[];%use to rename the saved files
OverallTimeHandle=tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegistrationMethod=3;
RegisterToReference=1;
ID_Suffix={ '_5Hz20s','_5Hz20s_1','_5Hz20s_2','_5Hz20s_3','_5Hz20s_4','_5Hz20s_5',...
            '_5Hz40s','_5Hz40s_1','_5Hz40s_2','_5Hz40s_3','_5Hz40s_4','_5Hz40s_5',...
            '_10Hz20s','_5Hz40s',...
            '_1Hz10s','_1Hz10s_1','_1Hz10s_2',...
            '_2Hz10s','_2Hz10s_1','_2Hz10s_2',...
            '_5Hz10s','_5Hz10s_1','_5Hz10s_2',...
            '_10Hz10s','_10Hz10s_1','_10Hz10s_2',...
            '_15Hz10s','_15Hz10s_1','_15Hz10s_2',...
            '_20Hz10s','_20Hz10s_1','_20Hz10s_2',....
            '_40Hz10s','_40Hz10s_1','_40Hz10s_2'};
Suffix_Ib='_Ib';
Suffix_Is='_Is';
PlayBackFPS=60
PlayBackQuality=80
ScaleFactor=2
ReferenceFrames=100
QuickCheckInterval=1
NumLoops=2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Run this on the Client
fprintf('=========================================================\n')
fprintf('=========================================================\n')
fprintf('=========================================================\n')
clearvars -except myPool myPool LastRecording TemplateDir ScratchDir currentFolder Recording ParentDir ParentDir1 ParentDir2 ParentDir3 ParentDir1 RecordingNum dc...
    IntraStimAlign AlignMethod ID_Suffix Suffix_Ib Suffix_Is LoopCount File2Check AnalysisLabel Function...
    BufferSize Port TimeOut NumLoops ServerIP BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses LoopCount...
    StackSaveNameSuffixID_Suffix Suffix_Ib Suffix_Is NumSequences FramesPerSequence ParentDir ParentDir1 ParentDir2 ParentDir3 TemplateDir ScratchDir Recording currentFolder RecordingNum...
    dc RunningTimeHandle OverallTimeHandle RegistrationMethod SaveDemonField RegisterToReference FlipLR PlayBackFPS PlayBackQuality ScaleFactor ReferenceFrames QuickCheckInterval NumLoops
if exist('myPool')
    try
        if isempty(myPool.IdleTimeout)
            disp('Parpool timed out! Restarting now...')
            delete(gcp('nocreate'))
            myPool=parpool;%
        else
            disp('Parpool active...')
        end
    catch
        disp('Parpool timed out! Restarting now...')
        delete(gcp('nocreate'))
        myPool=parpool;%
    end
else
    delete(gcp('nocreate'))
    myPool=parpool;
end
while LoopCount<NumLoops
    LoopCount=LoopCount+1;
    BadConnection=0;
    fprintf(['Starting ',num2str(LoopCount),' of ',num2str(NumLoops),' Loops...\n'])    
    while any(AllRecordingStatuses~=1)
        LastRecording=0;
        while LastRecording<length(Recording)
            if BadConnection<ConnectionAttempts
                fprintf('=========================================================\n')
                fprintf('=========================================================\n')
                fprintf('=========================================================\n')
                tcpipClient = tcpip(ServerIP,Port,'NetworkRole','Client','OutputBufferSize',BufferSize,'InputBufferSize',BufferSize,'TimeOut',TimeOut);
                Status=get(tcpipClient,'status');
                %CHECK SERVER STATUS FIRST!
                fprintf(['Opening Server Connection...\n']);
                try
                    fopen(tcpipClient)
                    Status=get(tcpipClient,'status');
                    AvailableBytes=get(tcpipClient,'BytesAvailable');
                    ByteOrder=get(tcpipClient,'ByteOrder');
                    fprintf(['Server Connection Established...\n']);
                    fprintf(['Retrieving Data...\n']);
                    AllData=fread(tcpipClient,length(Recording)+1,'uint16')';
                    AllRecordingStatuses=AllData(1:length(Recording));
                    LastRecording=AllData(length(Recording)+1);
                    LastRecording = LastRecording+1;
                    fprintf(['Starting Analysis on Recording: ',num2str(LastRecording),'\n']);
                    fwrite(tcpipClient,[AllRecordingStatuses,LastRecording],'uint16')
                    fprintf(['Closing Server Connection...\n']);
                    fclose(tcpipClient);
                    pause(2);
                    if LastRecording>0
                        StackSaveName = [Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix];
                        fprintf(['CHECKING Recording # ',num2str(LastRecording),' File: ',Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,'\n'])
                        if exist([Recording(LastRecording).dir,dc,Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,File2Check])
                            FileInfo = dir([Recording(LastRecording).dir,dc,StackSaveName,File2Check]);
                            TimeStamp = FileInfo.date;
                            fprintf([' ',AnalysisLabel,' Found (',TimeStamp,')\n']);
                        else
                            fprintf('\n');warning([' ',AnalysisLabel,' NOT Found']);fprintf('\n');
                        end
                    end
                    %Run the Analysis
                    if AllRecordingStatuses(LastRecording)==0
                        try
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Core Code here, should be able to swap
                            if logical(exist([Recording(LastRecording).dir,dc,Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,'_HighFreqContinuousImagingAnalysis.mat'])&&OverwriteData)
                                fprintf(['Starting Analysis for File # ',num2str(LastRecording),' ',Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,'\n']);
                                RecordingNum=LastRecording;
                                cd([Recording(RecordingNum).dir]);
                                fprintf(['==========================================================================================\n'])
                                fprintf(['==========================================================================================\n'])
                                MatlabVersion=version('-release');MatlabVersionYear=MatlabVersion(1:4);
                                StackSaveName=Recording(RecordingNum).StackSaveName;
                                StackSaveNameSuffix = Recording(RecordingNum).StackSaveNameSuffix;
                                ReferenceStackSaveName=Recording(RecordingNum).ReferenceStackSaveName;
                                ReferenceStackFileName=Recording(RecordingNum).FirstImageFileName;
                                TestPath=[Recording(RecordingNum).dir,dc,StackSaveName,StackSaveNameSuffix,' Summary Figures',dc,StackSaveName,StackSaveNameSuffix];
                                if length(TestPath)>200
                                    warning('Using Short Path')
                                    SaveDir=[StackSaveName(length(StackSaveName)-4:length(StackSaveName)),StackSaveNameSuffix,' Figs'];
                                    if ~exist(SaveDir)
                                        mkdir(SaveDir)
                                    end
                                else
                                    SaveDir=strcat(StackSaveName,StackSaveNameSuffix,' Summary Figures');
                                end
                                TimeStamp=datestr(now);
                                save([Recording(RecordingNum).dir,dc,Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,' ',AnalysisLabel,' Currently Running.mat'],'TimeStamp')
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

File_is_Ib=0;
for IDCheck=1:length(ID_Suffix)
    StackSaveNameSuffix_Ib=[Suffix_Ib,ID_Suffix{IDCheck}];
    if any(strfind([StackSaveName,StackSaveNameSuffix], StackSaveNameSuffix_Ib))
        File_is_Ib=1;
    end
end

Enhanced_Muli_Method_Tetanus_Registration(StackSaveName,StackSaveNameSuffix,ReferenceStackSaveName,ReferenceStackFileName,SaveDir,RegisterToReference,File_is_Ib,RegistrationMethod)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Making Reference Movie...')
MovieDir='Registration Reference Movies';
    if ~exist(MovieDir)
        mkdir(MovieDir)
    end

    load([StackSaveName,StackSaveNameSuffix '_HighFreqContinuousImagingAnalysis.mat'],'ImageArrayReg_AllImages','ReferenceStackFileName','StackFileName','RegisterToReference','ReferenceStackSaveName','GoodImages',...
            'ReferenceImage','ReferenceImage_Crop','AllBoutonsRegion','Crop_Props','FilterSize','FilterSigma','FlipLR','DeltaX_DFTReg_Whole','DeltaY_DFTReg_Whole')
    
        
        
    ScreenSize=get(0,'ScreenSize');
    
    LastImageNumber = GoodImages(length(GoodImages));
    ImageArrayReg_Whole=zeros(size(ReferenceImage,1),size(ReferenceImage,2),LastImageNumber);
     parfor ImageNumber=1:LastImageNumber 
        %load and filter each image 
        TempImage = imread(StackFileName,'tif',GoodImages(ImageNumber));
        if FlipLR
            TempImage=fliplr(TempImage);
        end
        TempImage = imfilter(TempImage, fspecial('gaussian', FilterSize, FilterSigma));
        ImageArrayReg_Whole(:,:,ImageNumber)=uint16(TempImage);
     end
     
     if ~RegisterToReference
         ReferenceImage=ImageArrayReg_Whole(:,:,1);
         ReferenceImage_Crop=imcrop(ReferenceImage,Crop_Props.BoundingBox);
     end
     
     
     
    mov = VideoWriter([MovieDir,dc,StackSaveName,StackSaveNameSuffix , ' Registration Record.avi'],'Motion JPEG AVI');
    mov.FrameRate = 20;  % Default 30
    mov.Quality = 90;    % Default 75
    open(mov);

    ReferenceFrames=20;

    UseBorderLine=1;
    BorderThickness=0.5;    
    StandardPosition=[20,50,600,600];
    %ScaleFactor=0.75;
    LowPercent=0;
    HighPercent=0.8;
    LabelLocation=[5,12];


    ColorMap='gray';


    FinalFig=figure;
    %set(FinalFig,'units','normalized','position',[0,0.04,1,0.88])
    ImageWidth=size(ReferenceImage,2);
    ImageHeight=size(ReferenceImage,1);
    FigureSize=[ImageWidth*2*ScaleFactor,ImageHeight*1*ScaleFactor];
    set(FinalFig,'units','Pixels','position',[0,40,FigureSize]);
    set(FinalFig, 'color', 'white');
    pause(0.001)


    MaxIntensity=max(ReferenceImage(:));
    MinIntensity=min(ReferenceImage(:));
    ColorLimits=[MinIntensity*LowPercent,MaxIntensity*HighPercent];
    clf
    %%%%%%%%%%%
    subtightplot(1,2,1,[0.01,0.01],[0,0],[0,0])
    imagesc(ReferenceImage),axis equal tight,
    caxis(ColorLimits)
    colormap(ColorMap)
    hold all
    text(LabelLocation(1),LabelLocation(2),'Reference','color','w','FontName','Arial','FontSize',12)
    set(gca,'XTick', []); set(gca,'YTick', []);
    %%%%%%%%%%%
    subtightplot(1,2,2,[0.01,0.01],[0,0],[0,0])
    if size(ReferenceImage_Crop)~=size(AllBoutonsRegion)
        imagesc(ReferenceImage_Crop.*uint16(imcrop(AllBoutonsRegion,Crop_Props.BoundingBox)))
    else
        imagesc(ReferenceImage_Crop.*uint16(AllBoutonsRegion))
    end
    axis equal tight
    caxis(ColorLimits)
    colormap(ColorMap)
    %plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',1);
    %hold on
    %text(LabelLocation(1),LabelLocation(2),[num2str(ImageNumber)],'color','w','FontName','Arial','FontSize',24)
    set(gca,'XTick', []); set(gca,'YTick', []);
    %%%%%%%%%%%%%
    drawnow
    pause(0.001)
    OneFrame = getframe(FinalFig);
    for i=1:ReferenceFrames
        writeVideo(mov,OneFrame);
    end

    %%%%%%%%%%%%%%%%%%%%%%
    MaxIntensity=max(ImageArrayReg_AllImages(:));
    MinIntensity=min(ImageArrayReg_AllImages(:));
    ColorLimits=[MinIntensity*LowPercent,MaxIntensity*HighPercent];
    for ImageNumber=1:LastImageNumber

        clf
        %%%%%%%%%%%
        subtightplot(1,2,1,[0.01,0.01],[0,0],[0,0])
        imagesc(ImageArrayReg_Whole(:,:,ImageNumber)),axis equal tight,
        caxis(ColorLimits)
        colormap(ColorMap)
        hold all
        if UseBorderLine
            TempBoundingBox=Crop_Props.BoundingBox;
            TempBoundingBox(1)=TempBoundingBox(1)-DeltaX_DFTReg_Whole(ImageNumber);
            TempBoundingBox(2)=TempBoundingBox(2)-DeltaY_DFTReg_Whole(ImageNumber);
            PlotBox(TempBoundingBox,'-','y',BorderThickness,[],15,'y')

        end
        text(LabelLocation(1),LabelLocation(2),[num2str(ImageNumber)],'color','w','FontName','Arial','FontSize',12)
        set(gca,'XTick', []); set(gca,'YTick', []);
        %%%%%%%%%%%
        subtightplot(1,2,2,[0.01,0.01],[0,0],[0,0])
        imagesc(ImageArrayReg_AllImages(:,:,ImageNumber)),axis equal tight,
        caxis(ColorLimits)
        colormap(ColorMap)
        %plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',1);
        %hold on
        %text(LabelLocation(1),LabelLocation(2),[num2str(ImageNumber)],'color','w','FontName','Arial','FontSize',24)
        set(gca,'XTick', []); set(gca,'YTick', []);
        %%%%%%%%%%%%%
        drawnow
        pause(0.001)
        OneFrame = getframe(FinalFig);
        writeVideo(mov,OneFrame);
    end
    close(mov);
    close(FinalFig)
    disp('Finished Reference Movie...')            

        
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('======================================')
    disp('======================================')
    disp('======================================')
    disp('Prepping New Movies...')
    if any(size(ReferenceImage_Crop)~=size(AllBoutonsRegion))
        AllBoutonsRegion=imcrop(AllBoutonsRegion,Crop_Props.BoundingBox);
    end

    ColorMap='gray';
    UseBorderLine=1;
    BorderThickness=0.5;    
    StandardPosition=[20,50,600,600];
    F_LowPercent=0.5;
    F_HighPercent=0.2;
    DF_LowPercent=-0.6;
    DF_HighPercent=-0.6;

    LabelLocation=[5,12];
    ImageWidth=size(ReferenceImage,2);
    ImageHeight=size(ReferenceImage,1);
    FigureSize=[size(ReferenceImage_Crop,2)*ScaleFactor,size(ReferenceImage_Crop,1)*ScaleFactor];

    TotalNumFrames=size(ImageArrayReg_AllImages,3);
    
    NumIntervals=TotalNumFrames/QuickCheckInterval;
    IntervalsNums=[];
    for i=1:NumIntervals
        IntervalsNums(i)=(i-1)*QuickCheckInterval+1;
    end
    
    ScreenSize=get(0,'ScreenSize');
    
    disp('Loading Data...')
    LastImageNumber = GoodImages(length(GoodImages));
    ImageArrayReg_Whole=zeros(size(ReferenceImage,1),size(ReferenceImage,2),LastImageNumber);
    parfor ImageNumber=1:LastImageNumber 
        %load and filter each image 
        TempImage = imread(StackFileName,'tif',GoodImages(ImageNumber));
        if FlipLR
            TempImage=fliplr(TempImage);
        end
        TempImage = imfilter(TempImage, fspecial('gaussian', FilterSize, FilterSigma));
        ImageArrayReg_Whole(:,:,ImageNumber)=uint16(TempImage);
     end
     
     if ~RegisterToReference
         ReferenceImage=ImageArrayReg_Whole(:,:,1);
         ReferenceImage_Crop=imcrop(ReferenceImage,Crop_Props.BoundingBox);
     end

    disp('Calculating DeltaF...')
    F0=mean(double(ImageArrayReg_AllImages(:,:,1:5)),3);
    ImageArrayReg_AllImages_DeltaF=double(zeros(size(ImageArrayReg_AllImages)));
    for i=1:size(ImageArrayReg_AllImages,3)
        ImageArrayReg_AllImages_DeltaF(:,:,i)=double(ImageArrayReg_AllImages(:,:,i))-F0;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('======================================')
    disp('======================================')
    disp('======================================')
    disp('Making New Movies...')
   if ~exist('ScratchDir')
       [OS,dc,ParentDir,ParentDir1,ParentDir2,ParentDir3,TemplateDir,ScratchDir]=BatchStartup;
   end
    MovieName=[StackSaveName,StackSaveNameSuffix , ' Registration Record New.avi'];
    disp(['Making Movie: ',MovieName])
    mov = VideoWriter([ScratchDir,dc,MovieName],'Motion JPEG AVI');
    mov.FrameRate = PlayBackFPS;  % Default 30
    mov.Quality = PlayBackQuality;    % Default 75
    open(mov);

    FinalFig=figure;
    set(FinalFig,'units','Pixels','position',[0,40,FigureSize]);
    set(FinalFig, 'color', 'white');
    pause(0.001)
    for loop=1:NumLoops   
        clf
        %%%%%%%%%%%
        TempMaskedImage=uint16(ReferenceImage_Crop).*uint16(AllBoutonsRegion);
        TempMaskedImage=double(TempMaskedImage);
        TempMaskedImage(TempMaskedImage<1)=NaN;
        MaxIntensity=max(TempMaskedImage(:));
        MinIntensity=min(TempMaskedImage(:));
        ColorLimits=[MinIntensity+MinIntensity*F_LowPercent,MaxIntensity+MaxIntensity*F_HighPercent];
        subtightplot(1,1,1,[0.01,0.01],[0,0],[0,0])
        if size(ReferenceImage_Crop)~=size(AllBoutonsRegion)
            imagesc(uint16(ReferenceImage_Crop).*uint16(imcrop(AllBoutonsRegion,Crop_Props.BoundingBox)))
        else
            imagesc(uint16(ReferenceImage_Crop).*uint16(AllBoutonsRegion))
        end
        axis equal tight
        caxis(ColorLimits)
        colormap(ColorMap)
        text(LabelLocation(1),LabelLocation(2),'REF','color','c','FontName','Arial','FontSize',16)
        set(gca,'XTick', []); set(gca,'YTick', []);
        %%%%%%%%%%%%%
        drawnow
        pause(0.001)
        OneFrame = getframe(FinalFig);
        for i=1:ReferenceFrames
            writeVideo(mov,OneFrame);
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TempMaskedImage=uint16(ImageArrayReg_AllImages(:,:,1)).*uint16(AllBoutonsRegion);
        TempMaskedImage=double(TempMaskedImage);
        TempMaskedImage(TempMaskedImage<1)=NaN;
        MaxIntensity=max(TempMaskedImage(:));
        MinIntensity=min(TempMaskedImage(:));
        ColorLimits=[MinIntensity+MinIntensity*F_LowPercent,MaxIntensity+MaxIntensity*F_HighPercent];        
        for i=1:length(IntervalsNums)
            ImageNumber=IntervalsNums(i);
            clf
            %%%%%%%%%%%
            subtightplot(1,1,1,[0.01,0.01],[0,0],[0,0])
            imagesc(ImageArrayReg_AllImages(:,:,ImageNumber)),axis equal tight,
            caxis(ColorLimits)
            colormap(ColorMap)
            %plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',1);
            %hold on
            text(LabelLocation(1),LabelLocation(2),[num2str(ImageNumber)],'color','c','FontName','Arial','FontSize',16)
            text(LabelLocation(1)+40,LabelLocation(2),StackSaveNameSuffix,'color','c','FontName','Arial','FontSize',10,'interpreter','none')
            set(gca,'XTick', []); set(gca,'YTick', []);
            %%%%%%%%%%%%%
            drawnow
            pause(0.001)
            OneFrame = getframe(FinalFig);
            writeVideo(mov,OneFrame);
        end
    end
    close(mov);
    close(FinalFig)
    copyfile([ScratchDir,dc,MovieName],[MovieDir,dc,MovieName]);
    delete([ScratchDir,dc,MovieName]);
    disp('Finished Registration Record New')
    
    MovieName=[StackSaveName,StackSaveNameSuffix , ' DeltaF Registration Record.avi'];
    disp(['Making Movie: ',MovieName])
    mov = VideoWriter([ScratchDir,dc,MovieName],'Motion JPEG AVI');
    mov.FrameRate = PlayBackFPS;  % Default 30
    mov.Quality = PlayBackQuality;    % Default 75
    open(mov);

    FinalFig=figure;
    set(FinalFig,'units','Pixels','position',[0,40,FigureSize]);
    set(FinalFig, 'color', 'white');
    pause(0.001)
    for loop=1:NumLoops   
        clf


        MaxIntensity=max(ImageArrayReg_AllImages_DeltaF(:));
        MinIntensity=min(ImageArrayReg_AllImages_DeltaF(:));
        ColorLimits=[MinIntensity+MinIntensity*DF_LowPercent,MaxIntensity+MaxIntensity*DF_HighPercent];        
        for i=1:length(IntervalsNums)
            ImageNumber=IntervalsNums(i);
            clf
            %%%%%%%%%%%
            subtightplot(1,1,1,[0.01,0.01],[0,0],[0,0])
            imagesc(ImageArrayReg_AllImages_DeltaF(:,:,ImageNumber)),axis equal tight,
            caxis(ColorLimits)
            colormap('jet')
            %plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',1);
            %hold on
            text(LabelLocation(1),LabelLocation(2),[num2str(ImageNumber)],'color','w','FontName','Arial','FontSize',16)
            text(LabelLocation(1)+40,LabelLocation(2),StackSaveNameSuffix,'color','w','FontName','Arial','FontSize',10,'interpreter','none')
            set(gca,'XTick', []); set(gca,'YTick', []);
            %%%%%%%%%%%%%
            drawnow
            pause(0.001)
            OneFrame = getframe(FinalFig);
            writeVideo(mov,OneFrame);
        end
    end
    close(mov);
    close(FinalFig)
    copyfile([ScratchDir,dc,MovieName],[MovieDir,dc,MovieName]);
    delete([ScratchDir,dc,MovieName]);
    disp('Finished DeltaF Registration Record')
    disp('======================================')
    disp('======================================')
    disp('======================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                close all    
                                clearvars -except myPool myPool LastRecording TemplateDir ScratchDir currentFolder Recording ParentDir ParentDir1 ParentDir2 ParentDir3 ParentDir1 RecordingNum dc...
                                    IntraStimAlign AlignMethod ID_Suffix Suffix_Ib Suffix_Is LoopCount File2Check AnalysisLabel Function...
                                    BufferSize Port TimeOut NumLoops ServerIP BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses LoopCount...
                                    StackSaveNameSuffixID_Suffix Suffix_Ib Suffix_Is NumSequences FramesPerSequence ParentDir ParentDir1 ParentDir2 ParentDir3 TemplateDir ScratchDir Recording currentFolder RecordingNum...
                                    dc RunningTimeHandle OverallTimeHandle RegistrationMethod SaveDemonField RegisterToReference FlipLR PlayBackFPS PlayBackQuality ScaleFactor ReferenceFrames QuickCheckInterval NumLoops


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                fprintf(['Finished Recording # ',num2str(LastRecording),' ',Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,'\n'])
                                fprintf(['Finished Recording # ',num2str(LastRecording),' ',Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,'\n'])
                                fprintf(['Finished Recording # ',num2str(LastRecording),' ',Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,'\n'])
                                disp(['Updating  ',File2Check,' Tracker!'])
                                disp(['Updating  ',File2Check,' Tracker!'])
                                disp(['Updating  ',File2Check,' Tracker!'])
                                Tracker=1;
                                save([Recording(LastRecording).dir,dc,Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix, File2Check],'Tracker'); 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                if exist([Recording(LastRecording).dir,dc,Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,' ',AnalysisLabel,' Currently Running.mat'])
                                    fprintf('Deleting Tracking File...\n')
                                    delete([Recording(LastRecording).dir,dc,Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,' ',AnalysisLabel,' Currently Running.mat'])
                                end
                                cd(ParentDir)
                            else
                                fprintf(['Skipping File # ',num2str(LastRecording),' ',Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,'\n']);
                            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        catch
                            fprintf('\n');warning(['Error!!']);fprintf('\n');
                            fprintf('\n');warning(['Function threw an Error Skipping but will return in next loop']);fprintf('\n');
                            fprintf('\n');warning(['Error!!']);fprintf('\n');
                               if exist([Recording(LastRecording).dir,dc,Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,' ',AnalysisLabel,' Currently Running.mat'])
                                   fprintf('Deleting Tracking File...\n')
                                    delete([Recording(LastRecording).dir,dc,Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,' ',AnalysisLabel,' Currently Running.mat'])
                               end
                        end

                    elseif AllRecordingStatuses(LastRecording)==2
                        fprintf(['File # ',num2str(LastRecording),' ',Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,' is being analyzed elsewhere! Moving on to next file...\n'])
                    else
                        fprintf(['File # ',num2str(LastRecording),' ',Recording(LastRecording).StackSaveName,Recording(LastRecording).StackSaveNameSuffix,' is up to date! Moving on to next file...\n'])
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
                catch
                    BadConnection=BadConnection+1;
                    warning(['Unable to connect to server! (',num2str(ConnectionAttempts-BadConnection),' attempts remaining) Pausing for 2 min'])
                    pause(120)
                    break;
                end
            end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%