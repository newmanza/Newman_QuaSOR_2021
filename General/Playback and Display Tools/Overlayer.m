
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Overlayer(FigPosition,StackMode,Overlayer_Images,PixelSize,ColorMapOptions,ColorMapOptions1,MaxValueScalar,Zoom_BoxSize_um,Max_Zoom_BoxSize_um,BorderLines,Markers,FigSaveName,FigSaveDir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    OS=computer;
    if strcmp(OS,'MACI64')
        dc='/';
    else
        dc='\';
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    global AX1
    global S1
    global M1
    global T1
    global TXT1
    global TXT2
    global CURRENTIMAGE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Initial Parameters
    Scroll_Interval_um=Zoom_BoxSize_um/20;
    ZoomOn=0;
    ScaleOn=1;
    GridOn=0;
    ScaleBar_um=10;
    ScaleBar_px=ScaleBar_um/PixelSize;
    if Zoom_BoxSize_um>2
        ScaleRange_um=1;
    else
        ScaleRange_um=0.1;
    end
    ScaleRange_px=ScaleRange_um/PixelSize;
    ImageHeight=size(Overlayer_Images(1).Image,1);
    ImageWidth=size(Overlayer_Images(1).Image,2);
    NumIntervals=200;
    XLims=[0,ImageWidth];
    YLims=[0,ImageHeight];
    Zoom_Coord=[ImageWidth/2,ImageHeight/2];
    Zoom_BoxSize_px=ceil((Zoom_BoxSize_um)/PixelSize);
    Scroll_Interval_px=ceil((Scroll_Interval_um)/PixelSize);
    CurrentZ=1;
    NumZSlices=1;
    if StackMode
        warning('3D Mode Engaged!')
        NumZSlices=size(Overlayer_Images(1).Image,3);
        CurrentZ=round(NumZSlices/2);
        
    end
    BorderOptions=ones(1,length(BorderLines));
    BorderOptions_Labels=[];
    for Border=1:length(BorderLines)
        BorderOptions_Labels{Border}=BorderLines(Border).Label;
    end
    BorderLayers=[];
    MarkerOptions=ones(1,length(Markers));
    MarkerOptions_Labels=[];
    for Marker=1:length(Markers)
        MarkerOptions_Labels{Marker}=Markers(Marker).Label;
    end
    MarkerLayers=[];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Pre-process the images
    Current_Color_Selections=zeros(1,length(ColorMapOptions));
    ContrastIndices=ones(1,length(ColorMapOptions));
    ContrastIndices=ContrastIndices*NumIntervals/2;
    fprintf('Starting with: ')
    for c=1:length(ColorMapOptions)
        for x=1:length(Overlayer_Images)
            if Overlayer_Images(x).DefaultOn
                if strcmp(Overlayer_Images(x).Color,ColorMapOptions{c})
                    fprintf([Overlayer_Images(x).Label,' --> ',Overlayer_Images(x).Color,' | '])
                    Current_Color_Selections(c)=x+1;
                    TempVal=Overlayer_Images(x).DefaultContrast;
                    if TempVal>2
                        warning('adjusting contrast value...')
                        TempVal=2;
                    end
                    ContrastIndices(c)=round((NumIntervals/2)*TempVal);
                    clear TempVal
                else
                end
            else
            end
        end
    end
    Current_Color_Selections(Current_Color_Selections==0)=1;
    fprintf('\n')
    Image_Options{1}=['none'];
    for x=1:length(Overlayer_Images)
        Overlayer_Images(x).MaxValue=max(Overlayer_Images(x).Image(:));
        Image_Options{x+1}=Overlayer_Images(x).Label;
        if ImageHeight~=size(Overlayer_Images(x).Image,1)||ImageWidth~=size(Overlayer_Images(x).Image,2)
            warning(['Size mismatch in: ',Overlayer_Images(x).Label,'!!!!'])
            warning(['Size mismatch in: ',Overlayer_Images(x).Label,'!!!!'])
            warning(['Size mismatch in: ',Overlayer_Images(x).Label,'!!!!'])
            error('I am sorry but all files must be same size for this to work currently...')
        end
        if Overlayer_Images(x).MaxValue<=0
            warning(['Missing Data in: ',Overlayer_Images(x).Label,'!!!!'])
            warning(['Missing Data in: ',Overlayer_Images(x).Label,'!!!!'])
            warning(['Missing Data in: ',Overlayer_Images(x).Label,'!!!!'])
            error('I am sorry but all files must contain some values for this to work currently...')
        end
    end
    ExportCount=0;
    ExportFileList=dir(FigSaveDir);
    for i=1:length(ExportFileList)
        if any(strfind(ExportFileList(i).name,FigSaveName))&&any(strfind(ExportFileList(i).name,'tif'))&&any(strfind(ExportFileList(i).name,'Export'))
            ExportCount=ExportCount+1;
        end
    end
    fprintf(['Found ',num2str(ExportCount),' Files in the Export directory already...\n'])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    %Initialize Figure
    FigName=[FigSaveName];
    OverlayerFig=figure('name',FigName);
    set(OverlayerFig, 'color', 'white');
    set(OverlayerFig,'units','normalized','position',FigPosition)
    AX1=subtightplot(1,1,1,[0,0],[0.05,0.05],[0.05,0.05]);
    axis off
    box off
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %UI Elements
    UpdateImageButton = uicontrol('Style', 'pushbutton', 'String', {'Update Image (shift)'},...
        'units','normalized',...
        'Position', [0.80 0.95 0.08 0.05],...
        'Callback', @UpdateImage); 
    FinishedButton = uicontrol('Style', 'pushbutton', 'String', {'Finished (ctrl)'},...
        'units','normalized',...
        'Position', [0.94 0.95 0.06 0.05],...
        'Callback', @Finished);
    ExportButton = uicontrol('Style', 'pushbutton', 'String', 'Export',...
        'units','normalized',...
        'Position', [0.88 0.95 0.06 0.05],...
        'Callback', @ExportImage);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Color Options
    VertPos=0.95;
    for zzzz=1:1
        %Color _1
        VertPos=0.95;
        Image_Selection_Text_1 = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.00 VertPos-0.05 0.025 0.025],...
            'String',ColorMapOptions1{1},'foregroundcolor',ColorMapOptions1{1});
        Image_Selection_1=...
            uicontrol('Style', 'popup',...
            'String', Image_Options,...
            'units','normalized',...
            'Position',[0.025 VertPos-0.075 0.075 0.05],...
            'Callback', @Select_Image_1);
        set(Image_Selection_1,'Value',Current_Color_Selections(1))
        ContrastSlider_1 = uicontrol('Style', 'slider',...
            'Min',1/NumIntervals,'Max',1,'Value',ContrastIndices(1)/NumIntervals,...
            'SliderStep',[1/NumIntervals,1/NumIntervals],...
            'units','normalized',...
            'Position',[0.025 VertPos-0.065 0.075 0.015],...
            'Callback', @Contrast_Slider_1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Color _2
        VertPos=VertPos-0.05;
        Image_Selection_Text_2 = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.00 VertPos-0.05 0.025 0.025],...
            'String',ColorMapOptions1{2},'foregroundcolor',ColorMapOptions1{2});
        Image_Selection_2=...
            uicontrol('Style', 'popup',...
            'String', Image_Options,...
            'units','normalized',...
            'Position',[0.025 VertPos-0.075 0.075 0.05],...
            'Callback', @Select_Image_2);
        set(Image_Selection_2,'Value',Current_Color_Selections(2))
        ContrastSlider_2 = uicontrol('Style', 'slider',...
            'Min',1/NumIntervals,'Max',1,'Value',ContrastIndices(2)/NumIntervals,...
            'SliderStep',[1/NumIntervals,1/NumIntervals],...
            'units','normalized',...
            'Position',[0.025 VertPos-0.065 0.075 0.015],...
            'Callback', @Contrast_Slider_2);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %Color _3
        VertPos=VertPos-0.05;
        Image_Selection_Text_3 = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.00 VertPos-0.05 0.025 0.025],...
            'String',ColorMapOptions1{3},'foregroundcolor',ColorMapOptions1{3});
        Image_Selection_3=...
            uicontrol('Style', 'popup',...
            'String', Image_Options,...
            'units','normalized',...
            'Position',[0.025 VertPos-0.075 0.075 0.05],...
            'Callback', @Select_Image_3);
        set(Image_Selection_3,'Value',Current_Color_Selections(3))
        ContrastSlider_3 = uicontrol('Style', 'slider',...
            'Min',1/NumIntervals,'Max',1,'Value',ContrastIndices(3)/NumIntervals,...
            'SliderStep',[1/NumIntervals,1/NumIntervals],...
            'units','normalized',...
            'Position',[0.025 VertPos-0.065 0.075 0.015],...
            'Callback', @Contrast_Slider_3);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        %Color _4
        VertPos=VertPos-0.05;
        Image_Selection_Text_4 = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.00 VertPos-0.05 0.025 0.025],...
            'String',ColorMapOptions1{4},'foregroundcolor',ColorMapOptions1{4});
        Image_Selection_4=...
            uicontrol('Style', 'popup',...
            'String', Image_Options,...
            'units','normalized',...
            'Position',[0.025 VertPos-0.075 0.075 0.05],...
            'Callback', @Select_Image_4);
        set(Image_Selection_4,'Value',Current_Color_Selections(4))
        ContrastSlider_4 = uicontrol('Style', 'slider',...
            'Min',1/NumIntervals,'Max',1,'Value',ContrastIndices(4)/NumIntervals,...
            'SliderStep',[1/NumIntervals,1/NumIntervals],...
            'units','normalized',...
            'Position',[0.025 VertPos-0.065 0.075 0.015],...
            'Callback', @Contrast_Slider_4);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
        %Color _5
        VertPos=VertPos-0.05;
        Image_Selection_Text_5 = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.00 VertPos-0.05 0.025 0.025],...
            'String',ColorMapOptions1{5},'foregroundcolor',ColorMapOptions1{5});
        Image_Selection_5=...
            uicontrol('Style', 'popup',...
            'String', Image_Options,...
            'units','normalized',...
            'Position',[0.025 VertPos-0.075 0.075 0.05],...
            'Callback', @Select_Image_5);
        set(Image_Selection_5,'Value',Current_Color_Selections(5))
        ContrastSlider_5 = uicontrol('Style', 'slider',...
            'Min',1/NumIntervals,'Max',1,'Value',ContrastIndices(5)/NumIntervals,...
            'SliderStep',[1/NumIntervals,1/NumIntervals],...
            'units','normalized',...
            'Position',[0.025 VertPos-0.065 0.075 0.015],...
            'Callback', @Contrast_Slider_5);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        %Color _6
        VertPos=VertPos-0.05;
        Image_Selection_Text_6 = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.00 VertPos-0.05 0.025 0.025],...
            'String',ColorMapOptions1{6},'foregroundcolor',ColorMapOptions1{6});
        Image_Selection_6=...
            uicontrol('Style', 'popup',...
            'String', Image_Options,...
            'units','normalized',...
            'Position',[0.025 VertPos-0.075 0.075 0.05],...
            'Callback', @Select_Image_6);
        set(Image_Selection_6,'Value',Current_Color_Selections(6))
        ContrastSlider_6 = uicontrol('Style', 'slider',...
            'Min',1/NumIntervals,'Max',1,'Value',ContrastIndices(1)/NumIntervals,...
            'SliderStep',[1/NumIntervals,1/NumIntervals],...
            'units','normalized',...
            'Position',[0.025 VertPos-0.065 0.075 0.015],...
            'Callback', @Contrast_Slider_6);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Color _7
        VertPos=VertPos-0.05;
        Image_Selection_Text_7 = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.00 VertPos-0.05 0.025 0.025],...
            'String',ColorMapOptions1{7});
        Image_Selection_7=...
            uicontrol('Style', 'popup',...
            'String', Image_Options,...
            'units','normalized',...
            'Position',[0.025 VertPos-0.075 0.075 0.05],...
            'Callback', @Select_Image_7);
        set(Image_Selection_7,'Value',Current_Color_Selections(7))
        ContrastSlider_7 = uicontrol('Style', 'slider',...
            'Min',1/NumIntervals,'Max',1,'Value',ContrastIndices(7)/NumIntervals,...
            'SliderStep',[1/NumIntervals,1/NumIntervals],...
            'units','normalized',...
            'Position',[0.025 VertPos-0.065 0.075 0.015],...
            'Callback', @Contrast_Slider_7);
        hcb(7)=colorbar();
        colormap(hcb(7),ColorMapOptions1{7})
        set(hcb(7),'location','southoutside','position',[0.00 VertPos-0.05-0.02 0.02 0.02],'ytick',[])
        hcb_pos(7,:)=[0.00 VertPos-0.05-0.02 0.02 0.02];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
        %Color _8
        VertPos=VertPos-0.05;
        Image_Selection_Text_8 = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.00 VertPos-0.05 0.025 0.025],...
            'String',ColorMapOptions1{8});
        Image_Selection_8=...
            uicontrol('Style', 'popup',...
            'String', Image_Options,...
            'units','normalized',...
            'Position',[0.025 VertPos-0.075 0.075 0.05],...
            'Callback', @Select_Image_8);
        set(Image_Selection_8,'Value',Current_Color_Selections(8))
        ContrastSlider_8 = uicontrol('Style', 'slider',...
            'Min',1/NumIntervals,'Max',1,'Value',ContrastIndices(8)/NumIntervals,...
            'SliderStep',[1/NumIntervals,1/NumIntervals],...
            'units','normalized',...
            'Position',[0.025 VertPos-0.065 0.075 0.015],...
            'Callback', @Contrast_Slider_8);
        hcb(8)=colorbar();
        colormap(hcb(8),ColorMapOptions1{8})
        set(hcb(8),'location','southoutside','position',[0.00 VertPos-0.05-0.02 0.02 0.02],'ytick',[])
        hcb_pos(8,:)=[0.00 VertPos-0.05-0.02 0.02 0.02];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
        %Color _9
        VertPos=VertPos-0.05;
        Image_Selection_Text_9 = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.00 VertPos-0.05 0.025 0.025],...
            'String',ColorMapOptions1{9});
        Image_Selection_9=...
            uicontrol('Style', 'popup',...
            'String', Image_Options,...
            'units','normalized',...
            'Position',[0.025 VertPos-0.075 0.075 0.05],...
            'Callback', @Select_Image_9);
        set(Image_Selection_9,'Value',Current_Color_Selections(9))
        ContrastSlider_9 = uicontrol('Style', 'slider',...
            'Min',1/NumIntervals,'Max',1,'Value',ContrastIndices(9)/NumIntervals,...
            'SliderStep',[1/NumIntervals,1/NumIntervals],...
            'units','normalized',...
            'Position',[0.025 VertPos-0.065 0.075 0.015],...
            'Callback', @Contrast_Slider_9);
        hcb(9)=colorbar();
        colormap(hcb(9),ColorMapOptions1{9})
        set(hcb(9),'location','southoutside','position',[0.00 VertPos-0.05-0.02 0.02 0.02],'ytick',[])
        hcb_pos(9,:)=[0.00 VertPos-0.05-0.02 0.02 0.02];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
        %Color _10
        VertPos=VertPos-0.05;
        Image_Selection_Text_10 = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.00 VertPos-0.05 0.025 0.025],...
            'String',ColorMapOptions1{10});
        Image_Selection_10=...
            uicontrol('Style', 'popup',...
            'String', Image_Options,...
            'units','normalized',...
            'Position',[0.025 VertPos-0.075 0.075 0.05],...
            'Callback', @Select_Image_10);
        set(Image_Selection_10,'Value',Current_Color_Selections(10))
        ContrastSlider_10 = uicontrol('Style', 'slider',...
            'Min',1/NumIntervals,'Max',1,'Value',ContrastIndices(10)/NumIntervals,...
            'SliderStep',[1/NumIntervals,1/NumIntervals],...
            'units','normalized',...
            'Position',[0.025 VertPos-0.065 0.075 0.015],...
            'Callback', @Contrast_Slider_10);
        hcb(10)=colorbar();
        colormap(hcb(10),ColorMapOptions1{10})
        set(hcb(10),'location','southoutside','position',[0.00 VertPos-0.05-0.02 0.02 0.02],'ytick',[])
        hcb_pos(10,:)=[0.00 VertPos-0.05-0.02 0.02 0.02];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Overlay Options
    VertPos=VertPos-0.05;
    BorderText= uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.00 VertPos-0.05 0.1 0.025],...
        'String','Borders');
    for Border=1:length(BorderLines)
        VertPos=VertPos-0.025;
        BorderChkBx(Border) = uicontrol('Style', 'checkbox', 'String', BorderOptions_Labels{Border},...
            'units','normalized',...
            'value',BorderOptions(Border),...
            'Position', [0.00 VertPos-0.05 0.1 0.025],...
            'Callback', {@ToggleBorder,Border}); 
    end
    VertPos=VertPos-0.025;
    MarkerText= uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.00 VertPos-0.05 0.1 0.025],...
        'String','Markers');
    for Marker=1:length(Markers)
        VertPos=VertPos-0.025;
        MarkerChkBx(Marker) = uicontrol('Style', 'checkbox', 'String', MarkerOptions_Labels{Marker},...
            'units','normalized',...
            'value',MarkerOptions(Marker),...
            'Position', [0.00 VertPos-0.05 0.1 0.025],...
            'Callback', {@ToggleMarker,Marker}); 
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ZoomInButton = uicontrol('Style', 'pushbutton', 'String', '+Zoom(pgup)',...
        'units','normalized',...
        'Position', [0.0 0.97 0.05 0.03],...
        'Callback', @ZoomIn);   
    ZoomOutButton = uicontrol('Style', 'pushbutton', 'String', '-Zoom(pgdn)',...
        'units','normalized',...
        'Position', [0.05 0.97 0.05 0.03],...
        'Callback', @ZoomOut);   
    ZoomSize_Slider = uicontrol('Style', 'slider',...
        'Min',0,'Max',1,'Value',Zoom_BoxSize_um/Max_Zoom_BoxSize_um,...
        'SliderStep',[1/Max_Zoom_BoxSize_um,5/Max_Zoom_BoxSize_um],...
        'units','normalized',...
        'Position', [0.00 0.955 0.08 0.015],...
        'Callback', @ZoomSize_Slider_callback);
    ZoomSize_Text = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.00 0.94 0.08 0.015],...
        'String',['ZoomBox: ',num2str(Zoom_BoxSize_um),'um']);
    ScaleButton = uicontrol('Style', 'togglebutton', 'String', 'Scale',...
        'units','normalized',...
        'value',ScaleOn,...
        'Position', [0.1 0.97 0.04 0.03],...
        'Callback', @ToggleScale); 
%     GridButton = uicontrol('Style', 'togglebutton', 'String', 'Grid',...
%         'units','normalized',...
%         'value',GridOn,...
%         'Position', [0.12 0.97 0.04 0.03],...
%         'Callback', @ToggleGrid); 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %XY Adjustments
    X_Scroll = uicontrol('Style', 'slider',...
        'Min',0,'Max',1,'Value',Zoom_Coord(1)/ImageWidth,...
        'SliderStep',[Scroll_Interval_px/ImageWidth,(Scroll_Interval_px*5)/ImageWidth],...
        'units','normalized',...
        'Position', [0 0 0.985 0.02],...
        'Callback', @X_Scroll_callback);
    Y_Scroll = uicontrol('Style', 'slider',...
        'Min',0,'Max',1,'Value',1-Zoom_Coord(2)/ImageHeight,...
        'SliderStep',[Scroll_Interval_px/ImageHeight,(Scroll_Interval_px*5)/ImageHeight],...
        'units','normalized',...
        'Position', [0.985 0.025 0.015 0.915],...
        'Callback', @Y_Scroll_callback);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Z Adjustments
    if StackMode
        Z_Slider = uicontrol('Style', 'slider',...
            'Min',0,'Max',1,'Value',CurrentZ/NumZSlices,...
            'SliderStep',[1/NumZSlices,5/NumZSlices],...
            'units','normalized',...
            'Position', [0.4 0.98 0.2 0.02],...
            'Callback', @Z_Slider_callback);
        Z_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.33 0.98 0.05 0.02],...
            'String',['Z: ',num2str(CurrentZ),'/',num2str(NumZSlices)]);
        ZControl = uicontrol('Style', 'edit', 'string',num2str(CurrentZ),...
            'units','normalized',...
            'Position', [0.66 0.98 0.02 0.02]);      
        Jump2ZButton = uicontrol('Style', 'pushbutton', 'String', 'Jump2Z>',...
            'units','normalized',...
            'Position', [0.62 0.98 0.04 0.02],...
            'Callback', @Jump2Z);
        UpText = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.6 0.98 0.02 0.02],...
            'String','c>');
        DownText = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.38 0.98 0.02 0.02],...
            'String','<x');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(OverlayerFig,'WindowKeyPressFcn',@Navigation_KeyPressFcn)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    UpdateImage;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Navigation_KeyPressFcn(src, evnt)
        if isequal(evnt.Key,'rightarrow')
            if ZoomOn
                Zoom_Coord(1) = Zoom_Coord(1)+Scroll_Interval_px;
                XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
                YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
                set(X_Scroll,'value',Zoom_Coord(1)/ImageWidth)
                axes(AX1)
                xlim(XLims),ylim(YLims)
                if ScaleOn
                    PlotScaleMarkers;
                end
            end
        elseif isequal(evnt.Key,'leftarrow')
            if ZoomOn
                Zoom_Coord(1) = Zoom_Coord(1)-Scroll_Interval_px;
                XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
                YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
                set(X_Scroll,'value',Zoom_Coord(1)/ImageWidth)
                axes(AX1)
                xlim(XLims),ylim(YLims)
                if ScaleOn
                    PlotScaleMarkers;
                end
            end
        elseif isequal(evnt.Key,'uparrow')
            if ZoomOn
                Zoom_Coord(2) = Zoom_Coord(2)-Scroll_Interval_px;
                XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
                YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
                set(Y_Scroll,'value',1-Zoom_Coord(2)/ImageHeight)
                axes(AX1)
                xlim(XLims),ylim(YLims)
                if ScaleOn
                    PlotScaleMarkers;
                end
            end
        elseif isequal(evnt.Key,'downarrow')
            if ZoomOn
                Zoom_Coord(2) = Zoom_Coord(2)+Scroll_Interval_px;
                XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
                YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
                set(Y_Scroll,'value',1-Zoom_Coord(2)/ImageHeight)
                axes(AX1)
                xlim(XLims),ylim(YLims)
                if ScaleOn
                    PlotScaleMarkers;
                end
            end
        elseif isequal(evnt.Key,'pageup')
            ZoomIn
        elseif isequal(evnt.Key,'pagedown')
            ZoomOut
        elseif isequal(evnt.Key,'shift')
            UpdateImage;
        elseif isequal(evnt.Key,'control')
            Finished;
        elseif isequal(evnt.Key,'x')
            if StackMode
                if CurrentZ>1
                    CurrentZ=CurrentZ-1;
                    set(Z_Text,'String',['Z: ',num2str(CurrentZ),'/',num2str(NumZSlices)]) 
                    set(ZControl,'String',num2str(CurrentZ))
                    set(Z_Slider,'Value',CurrentZ/NumZSlices)
                    UpdateZImage
                end
            end
        elseif isequal(evnt.Key,'c')
            if StackMode
                if CurrentZ<NumZSlices
                    CurrentZ=CurrentZ+1;
                    set(Z_Text,'String',['Z: ',num2str(CurrentZ),'/',num2str(NumZSlices)]) 
                    set(ZControl,'String',num2str(CurrentZ))
                    set(Z_Slider,'Value',CurrentZ/NumZSlices)
                    UpdateZImage
                end
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdateImage(src,eventdata,arg1)
        if StackMode
            warning('3D mode is currently active so updating image may take a while...')
        end
        fprintf('Generating Merged Image.')
        fprintf('.')
        if StackMode
            CURRENTIMAGE=zeros(ImageHeight,ImageWidth,3,NumZSlices,'single');
            for x=1:length(Overlayer_Images)
                if any(x==Current_Color_Selections-1)
                    CurrentColor=find(x==Current_Color_Selections-1);
                    MaxValue_Cont=ceil(single((Overlayer_Images(x).MaxValue)*MaxValueScalar...
                        *(ContrastIndices(CurrentColor)/NumIntervals)*Overlayer_Images(x).ColorScalar));
                    if length(ColorMapOptions{CurrentColor})==1
                        Colormap=makeColorMap([0 0 0],ColorDefinitions(ColorMapOptions{CurrentColor}),MaxValue_Cont);
                    elseif strcmp(ColorMapOptions{CurrentColor},'gray')
                        Colormap=gray(MaxValue_Cont);
                    elseif strcmp(ColorMapOptions{CurrentColor},'jet')
                        Colormap=jet(MaxValue_Cont);
                    elseif strcmp(ColorMapOptions{CurrentColor},'parula')
                        Colormap=parula(MaxValue_Cont);
                    elseif strcmp(ColorMapOptions{CurrentColor},'hot')
                        Colormap=hot(MaxValue_Cont);
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf('.')
                    progressbar(['Rendering Channel ',num2str(x),' ',Overlayer_Images(x).Label,' Z Slice'])
                    for z=1:NumZSlices
                        progressbar(z/NumZSlices)
                        TempImage=single(Overlayer_Images(x).Image(:,:,z))*Overlayer_Images(x).ColorScalar;
                        TempImage(TempImage>MaxValue_Cont)=MaxValue_Cont;
                        TempImage(1,1)=MaxValue_Cont;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        TempImage_Color=...
                            ind2rgb(round(TempImage),Colormap);
                        CURRENTIMAGE(:,:,1,z)=CURRENTIMAGE(:,:,1,z)+TempImage_Color(:,:,1);
                        CURRENTIMAGE(:,:,2,z)=CURRENTIMAGE(:,:,2,z)+TempImage_Color(:,:,2);
                        CURRENTIMAGE(:,:,3,z)=CURRENTIMAGE(:,:,3,z)+TempImage_Color(:,:,3);
                        clear TempImage TempImage_Color 
                    end
                    clear Colormap MaxValue_Cont CurrentColor
                end 
            end
        else
            CURRENTIMAGE=zeros(ImageHeight,ImageWidth,3,'single');
            for x=1:length(Overlayer_Images)
                if any(x==Current_Color_Selections-1)
                    CurrentColor=find(x==Current_Color_Selections-1);
                    MaxValue_Cont=ceil(single((Overlayer_Images(x).MaxValue)*MaxValueScalar*(ContrastIndices(CurrentColor)/NumIntervals)*Overlayer_Images(x).ColorScalar));
                    if length(ColorMapOptions{CurrentColor})==1
                        Colormap=makeColorMap([0 0 0],ColorDefinitions(ColorMapOptions{CurrentColor}),MaxValue_Cont);
                    elseif strcmp(ColorMapOptions{CurrentColor},'gray')
                        Colormap=gray(MaxValue_Cont);
                    elseif strcmp(ColorMapOptions{CurrentColor},'jet')
                        Colormap=jet(MaxValue_Cont);
                    elseif strcmp(ColorMapOptions{CurrentColor},'parula')
                        Colormap=parula(MaxValue_Cont);
                    elseif strcmp(ColorMapOptions{CurrentColor},'hot')
                        Colormap=hot(MaxValue_Cont);
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf('.')
                    TempImage=single(Overlayer_Images(x).Image)*Overlayer_Images(x).ColorScalar;
                    TempImage(TempImage>MaxValue_Cont)=MaxValue_Cont;
                    TempImage(1,1)=MaxValue_Cont;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    TempImage_Color=...
                        ind2rgb(round(TempImage),Colormap);
                    CURRENTIMAGE=CURRENTIMAGE+TempImage_Color;
                    clear TempImage TempImage_Color Colormap MaxValue_Cont CurrentColor
                end 
            end
        end
        fprintf('Finished!\n')
        figure(OverlayerFig)
        hold on
        %Remove layers
        if ~isempty(BorderLayers)
            for Border=1:length(BorderLayers)
                delete(BorderLayers(Border))
            end
            BorderLayers=[];
        end
        if ~isempty(MarkerLayers)
            for Marker=1:length(MarkerLayers)
                delete(MarkerLayers(Marker))
            end
            MarkerLayers=[];
        end
        FigName=[FigSaveName];
        set(OverlayerFig,'name',FigName)
        cla(AX1)
        
        %clf
        AX1=subtightplot(1,1,1,[0,0],[0.05,0.05],[0.05,0.05]);
        if StackMode
            imshow(double(CURRENTIMAGE(:,:,:,CurrentZ)),[],'border','tight')
        else
            imshow(double(CURRENTIMAGE),[],'border','tight')
        end
        hold on
        PlotOverlays;
        axes(AX1)
        xlim(XLims),ylim(YLims)
        if ScaleOn
            PlotScaleMarkers;
        else
            ClearOverlays
        end
        hcb(7)=colorbar();
        colormap(hcb(7),ColorMapOptions1{7})
        set(hcb(7),'location','southoutside','position',hcb_pos(7,:),'ytick',[])
        hcb(8)=colorbar();
        colormap(hcb(8),ColorMapOptions1{8})
        set(hcb(8),'location','southoutside','position',hcb_pos(8,:),'ytick',[])
        hcb(9)=colorbar();
        colormap(hcb(9),ColorMapOptions1{9})
        set(hcb(9),'location','southoutside','position',hcb_pos(9,:),'ytick',[])
        hcb(10)=colorbar();
        colormap(hcb(10),ColorMapOptions1{10})
        set(hcb(10),'location','southoutside','position',hcb_pos(10,:),'ytick',[])

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdateZImage(src,eventdata,arg1)
        figure(OverlayerFig)
        hold on
        %Remove layers
        if ~isempty(BorderLayers)
            for Border=1:length(BorderLayers)
                delete(BorderLayers(Border))
            end
            BorderLayers=[];
        end
        if ~isempty(MarkerLayers)
            for Marker=1:length(MarkerLayers)
                delete(MarkerLayers(Marker))
            end
            MarkerLayers=[];
        end
        FigName=[FigSaveName];
        set(OverlayerFig,'name',FigName)
        cla(AX1)
        %clf
        AX1=subtightplot(1,1,1,[0,0],[0.05,0.05],[0.05,0.05]);
        if StackMode
            imshow(double(CURRENTIMAGE(:,:,:,CurrentZ)),[],'border','tight')
        else
            imshow(double(CURRENTIMAGE),[],'border','tight')
        end
        hold on
        PlotOverlays;
        axes(AX1)
        xlim(XLims),ylim(YLims)
        if ScaleOn
            PlotScaleMarkers;
        else
            ClearOverlays
        end
        hcb(7)=colorbar();
        colormap(hcb(7),ColorMapOptions1{7})
        set(hcb(7),'location','southoutside','position',hcb_pos(7,:),'ytick',[])
        hcb(8)=colorbar();
        colormap(hcb(8),ColorMapOptions1{8})
        set(hcb(8),'location','southoutside','position',hcb_pos(8,:),'ytick',[])
        hcb(9)=colorbar();
        colormap(hcb(9),ColorMapOptions1{9})
        set(hcb(9),'location','southoutside','position',hcb_pos(9,:),'ytick',[])
        hcb(10)=colorbar();
        colormap(hcb(10),ColorMapOptions1{10})
        set(hcb(10),'location','southoutside','position',hcb_pos(10,:),'ytick',[])
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function PlotScaleMarkers
        ClearOverlays
        if ZoomOn
            Zoom_BoxSize_um=round(Zoom_BoxSize_um);
            if Zoom_BoxSize_um>5
                ScaleRange_um=1;
            elseif Zoom_BoxSize_um>=3
                ScaleRange_um=0.5;
            elseif Zoom_BoxSize_um>=2
                ScaleRange_um=0.2;
            else
                ScaleRange_um=0.1;
            end
            ScaleRange_px=ScaleRange_um/PixelSize;
            NumTicks=round((Zoom_BoxSize_um-ScaleRange_um)/ScaleRange_um);
            hold on
            M1=plot([XLims(1)+ScaleRange_px,XLims(2)-ScaleRange_px],...
                    [YLims(2)-ScaleRange_px*0.5,YLims(2)-ScaleRange_px*0.5],...
                    '-','color','w','LineWidth',3);
            T1=[];
            for tick=1:NumTicks
                T1(tick)=plot([XLims(1)+ScaleRange_px+ScaleRange_px*(tick-1),...
                            XLims(1)+ScaleRange_px+ScaleRange_px*(tick-1)],...
                           [YLims(2)-ScaleRange_px*0.5-ScaleRange_px*0.1,...
                            YLims(2)-ScaleRange_px*0.5+ScaleRange_px*0.1],...
                            '-','color','w','LineWidth',2);
            end
            TXT2=text(XLims(1)+ScaleRange_px*1.25,YLims(2)-ScaleRange_px*0.75,...
                [num2str(ScaleRange_um),'\mum'],...
                'color','w','fontsize',16);
       else
          hold on
          S1=plot(  [ImageWidth*0.05,ImageWidth*0.05+ScaleBar_px],...
                    [ImageHeight*0.98,ImageHeight*0.98],...
                    '-','color','w','LineWidth',3);
          TXT1=text(  ImageWidth*0.05,ImageHeight*0.95,[num2str(ScaleBar_um),'\mum'],...
              'color','w','fontsize',16);
       end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ClearOverlays
        try
            delete(M1)
        catch
        end
        for i=1:length(T1)
            try
                delete(T1(i))
            catch
            end
        end     
        try
            delete(TXT2)
        catch
        end
        try
            delete(S1)
            delete(TXT1)
        catch
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ToggleScale(src,eventdata,arg1)
        ScaleOn=get(src,'Value');
        ClearOverlays
        if ScaleOn
            PlotScaleMarkers;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ToggleGrid(src,eventdata,arg1)
        GridOn=get(src,'Value');
        ClearOverlays
        if GridOn
            PlotScaleMarkers;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Position Adjustments
    function X_Scroll_callback(src,eventdata,arg1)
        if ZoomOn
            TempValue = get(X_Scroll,'Value');
            Zoom_Coord(1) = TempValue*ImageWidth;
            XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
            YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
            xlim(XLims),ylim(YLims)
        else
            set(X_Scroll,'value',Zoom_Coord(1)/ImageWidth)
        end
        if ScaleOn
            PlotScaleMarkers;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Y_Scroll_callback(src,eventdata,arg1)
        if ZoomOn
            TempValue = get(Y_Scroll,'Value');
            TempValue= 1 - TempValue;
            Zoom_Coord(2) = TempValue*ImageHeight;
            XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
            YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
            xlim(XLims),ylim(YLims)
        else
            set(Y_Scroll,'value',Zoom_Coord(2)/ImageHeight)
        end
        if ScaleOn
            PlotScaleMarkers;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Z_Slider_callback(src,eventdata,arg1)
        TempValue = get(Z_Slider,'Value');
        CurrentZ=round(TempValue*NumZSlices);
        set(Z_Text,'String',['Z: ',num2str(CurrentZ),'/',num2str(NumZSlices)]) 
        set(ZControl,'String',num2str(CurrentZ))
        set(Z_Slider,'Value',CurrentZ/NumZSlices)
        UpdateZImage
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Jump2Z(src,eventdata,arg1)
        CurrentZ=round(str2num(get(ZControl,'String')));
        set(Z_Text,'String',['Z: ',num2str(CurrentZ),'/',num2str(NumZSlices)]) 
        set(ZControl,'String',num2str(CurrentZ))
        set(Z_Slider,'Value',CurrentZ/NumZSlices)
        UpdateZImage
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ZoomIn(src,eventdata,arg1)
        %Select Zoom Airy
        if ~ZoomOn
            ZoomOn=1;
            cont=1;
            %while cont
                axes(AX1)
                txt1=text(ImageWidth/50,ImageWidth/50,'Select Zoom Center','color','w','fontsize',20);
                Zoom_Coord=ginput_w(1);
                Zoom_Region=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(2)-Zoom_BoxSize_px/2,...
                    Zoom_BoxSize_px,Zoom_BoxSize_px];
                hold on
                delete(txt1);
                XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
                YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
%                 [P1,P2,P3,P4,~]=PlotBox2(Zoom_Region,'-','w',2,[],[],[]);
%                 delete(txt1)
%                 txt1=text(50,50,'<ENTER> to accept','color','w','fontsize',20);
%                 cont=InputWithVerification('<ENTER> to Accept Zoom Region: ',{[],[1]},0);
%                 if cont
%                     delete(txt1);delete(P1);delete(P2);delete(P3);delete(P4);
%                     XLims=[0,ImageWidth];
%                     YLims=[0,ImageHeight];
%                 else
%                     delete(txt1);
%                     XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
%                     YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
%                 end            
            %end
            %Zoom
            axes(AX1)
            %delete(P1);delete(P2);delete(P3);delete(P4);
            xlim(XLims),ylim(YLims)
            set(X_Scroll,'value',Zoom_Coord(1)/ImageWidth)
            set(Y_Scroll,'value',1-Zoom_Coord(2)/ImageHeight)
            figure(OverlayerFig)
            if ScaleOn
                PlotScaleMarkers;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ZoomOut(src,eventdata,arg1)
        %UN-Zoom
        ZoomOn=0;
        Zoom_Coord=[ImageWidth/2,ImageHeight/2];
        XLims=[0,ImageWidth];
        YLims=[0,ImageHeight];
        axes(AX1)
        xlim(XLims),ylim(YLims)
        set(X_Scroll,'value',Zoom_Coord(1)/ImageWidth)
        set(Y_Scroll,'value',1-Zoom_Coord(2)/ImageHeight)
        if ScaleOn
            PlotScaleMarkers;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Zoom Slider
    function ZoomSize_Slider_callback(src,eventdata,arg1)
        Zoom_BoxSize_um = get(src,'Value')*Max_Zoom_BoxSize_um;
        if Zoom_BoxSize_um<=0
            Zoom_BoxSize_um=1;
        end
        set(ZoomSize_Text,'String',['Zoom Box Size: ',num2str(Zoom_BoxSize_um),'um']);
        Zoom_BoxSize_px=ceil((Zoom_BoxSize_um)/PixelSize);
        Scroll_Interval_px=ceil((Scroll_Interval_um)/PixelSize);
        if ZoomOn
            XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
            YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
            set(X_Scroll,'value',Zoom_Coord(1)/ImageWidth)
            set(Y_Scroll,'value',1-Zoom_Coord(2)/ImageHeight)
            axes(AX1)
            xlim(XLims),ylim(YLims)
        end
        figure(OverlayerFig)
        if ScaleOn
            PlotScaleMarkers;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %All Image Selection Options
    function Select_Image_1(source,event)
        DataType = source.Value;
        set(Image_Selection_1,'Value',DataType)
        Current_Color_Selections(1)=DataType;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Select_Image_2(source,event)
        DataType = source.Value;
        set(Image_Selection_2,'Value',DataType)
        Current_Color_Selections(2)=DataType;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Select_Image_3(source,event)
        DataType = source.Value;
        set(Image_Selection_3,'Value',DataType)
        Current_Color_Selections(3)=DataType;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Select_Image_4(source,event)
        DataType = source.Value;
        set(Image_Selection_4,'Value',DataType)
        Current_Color_Selections(4)=DataType;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Select_Image_5(source,event)
        DataType = source.Value;
        set(Image_Selection_5,'Value',DataType)
        Current_Color_Selections(5)=DataType;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Select_Image_6(source,event)
        DataType = source.Value;
        set(Image_Selection_6,'Value',DataType)
        Current_Color_Selections(6)=DataType;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Select_Image_7(source,event)
        DataType = source.Value;
        set(Image_Selection_7,'Value',DataType)
        Current_Color_Selections(7)=DataType;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Select_Image_8(source,event)
        DataType = source.Value;
        set(Image_Selection_8,'Value',DataType)
        Current_Color_Selections(8)=DataType;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Select_Image_9(source,event)
        DataType = source.Value;
        set(Image_Selection_9,'Value',DataType)
        Current_Color_Selections(9)=DataType;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Select_Image_10(source,event)
        DataType = source.Value;
        set(Image_Selection_10,'Value',DataType)
        Current_Color_Selections(10)=DataType;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Contrast Settings
    function Contrast_Slider_1(src,eventdata,arg1)
        ContrastIndex = get(src,'Value');
        ContrastIndex=round(ContrastIndex*NumIntervals);
        ContrastIndices(1)=ContrastIndex;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Contrast_Slider_2(src,eventdata,arg1)
        ContrastIndex = get(src,'Value');
        ContrastIndex=round(ContrastIndex*NumIntervals);
        ContrastIndices(2)=ContrastIndex;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Contrast_Slider_3(src,eventdata,arg1)
        ContrastIndex = get(src,'Value');
        ContrastIndex=round(ContrastIndex*NumIntervals);
        ContrastIndices(3)=ContrastIndex;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Contrast_Slider_4(src,eventdata,arg1)
        ContrastIndex = get(src,'Value');
        ContrastIndex=round(ContrastIndex*NumIntervals);
        ContrastIndices(4)=ContrastIndex;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Contrast_Slider_5(src,eventdata,arg1)
        ContrastIndex = get(src,'Value');
        ContrastIndex=round(ContrastIndex*NumIntervals);
        ContrastIndices(5)=ContrastIndex;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Contrast_Slider_6(src,eventdata,arg1)
        ContrastIndex = get(src,'Value');
        ContrastIndex=round(ContrastIndex*NumIntervals);
        ContrastIndices(6)=ContrastIndex;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Contrast_Slider_7(src,eventdata,arg1)
        ContrastIndex = get(src,'Value');
        ContrastIndex=round(ContrastIndex*NumIntervals);
        ContrastIndices(7)=ContrastIndex;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Contrast_Slider_8(src,eventdata,arg1)
        ContrastIndex = get(src,'Value');
        ContrastIndex=round(ContrastIndex*NumIntervals);
        ContrastIndices(8)=ContrastIndex;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Contrast_Slider_9(src,eventdata,arg1)
        ContrastIndex = get(src,'Value');
        ContrastIndex=round(ContrastIndex*NumIntervals);
        ContrastIndices(9)=ContrastIndex;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Contrast_Slider_10(src,eventdata,arg1)
        ContrastIndex = get(src,'Value');
        ContrastIndex=round(ContrastIndex*NumIntervals);
        ContrastIndices(10)=ContrastIndex;
        figure(OverlayerFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ToggleBorder(hObject,eventData,Border)
        BorderOptions(Border)=get(hObject, 'value');
        PlotOverlays
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ToggleMarker(hObject,eventData,Marker)
        MarkerOptions(Marker)=get(hObject, 'value');
        PlotOverlays
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function PlotOverlays
        figure(OverlayerFig)
        hold on
        %Remove layers
        if ~isempty(BorderLayers)
            for Border=1:length(BorderLayers)
                delete(BorderLayers(Border))
            end
            BorderLayers=[];
        end
        if ~isempty(MarkerLayers)
            for Marker=1:length(MarkerLayers)
                delete(MarkerLayers(Marker))
            end
            MarkerLayers=[];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Add Layers
        BorderLayers=[];
        count=0;
        hold on
        for Border=1:length(BorderLines)
            if BorderOptions(Border)
                for j=1:length(BorderLines(Border).BorderLine)
                    count=count+1;
                    BorderLayers(count)=plot(BorderLines(Border).BorderLine{j}.BorderLine(:,2),...
                        BorderLines(Border).BorderLine{j}.BorderLine(:,1),...
                        BorderLines(Border).LineStyle,'color',BorderLines(Border).Color,...
                        'linewidth',BorderLines(Border).LineWidth);
                end
            end
        end
        count=0;
        hold on
        MarkerLayers=[];
        for Marker=1:length(Markers)
            if MarkerOptions(Marker)
                if StackMode&&size(Markers(Marker).MarkerCoords,2)>2
                    for m=1:length(Markers(Marker).MarkerCoords)
                        if Markers(Marker).MarkerCoords(m,3)==CurrentZ
                            count=count+1;
                            MarkerLayers(count)=plot(Markers(Marker).MarkerCoords(m,2),...
                                Markers(Marker).MarkerCoords(m,1),...
                                Markers(Marker).MarkerStyle,'color',Markers(Marker).Color,...
                                'markerSize',Markers(Marker).MarkerSize);
                        end
                    end
                else
                    for m=1:length(Markers(Marker).MarkerCoords)
                        count=count+1;
                        MarkerLayers(count)=plot(Markers(Marker).MarkerCoords(m,2),...
                            Markers(Marker).MarkerCoords(m,1),...
                            Markers(Marker).MarkerStyle,'color',Markers(Marker).Color,...
                            'markerSize',Markers(Marker).MarkerSize);
                    end
                end
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ExportImage(src,eventdata,arg1)
        fprintf(['Exporting Current Image...'])
        ExportCount=ExportCount+1;
        fprintf(['Export # ',num2str(ExportCount),'...'])
        fprintf('tif...')
        imwrite(double(CURRENTIMAGE),[FigSaveDir,dc,FigSaveName,' Export ',num2str(ExportCount),'.tif'])
        fprintf('png...')
        ExportLabelCount=0;
        ExportLabels=[];
        for x=1:length(Overlayer_Images)
            if any(x==Current_Color_Selections-1)
                CurrentColor=find(x==Current_Color_Selections-1);
                ExportLabelCount=ExportLabelCount+1;
                ExportLabels{ExportLabelCount}=[Overlayer_Images(x).Label,' | Color: ',Overlayer_Images(x).Color,' | Contrast: ',num2str(ContrastIndices(CurrentColor)/(NumIntervals)*2)];
            end 
        end
        if ZoomOn
           FigSize=[1*0.5625,1]*0.8;
        else
           FigSize=[ImageWidth/ImageHeight*0.5625,1]*0.8;
        end
        ExportFig=figure;
        set(ExportFig,'name',FigName,'units','normalized','position',[0.05 0.05 FigSize])
        AX1a=subtightplot(1,1,1,[0,0],[0,0],[0,0]);
        axis off
        box off
        imshow(double(CURRENTIMAGE),[],'border','tight')
        hold on
        for Border=1:length(BorderLines)
            if BorderOptions(Border)
                for j=1:length(BorderLines(Border).BorderLine)
                    plot(BorderLines(Border).BorderLine{j}.BorderLine(:,2),...
                        BorderLines(Border).BorderLine{j}.BorderLine(:,1),...
                        BorderLines(Border).LineStyle,'color',BorderLines(Border).Color,...
                        'linewidth',BorderLines(Border).LineWidth);
                end
            end
        end
        hold on
        for Marker=1:length(Markers)
            if MarkerOptions(Marker)
                for m=1:length(Markers(Marker).MarkerCoords)
                    plot(Markers(Marker).MarkerCoords(m,2),...
                        Markers(Marker).MarkerCoords(m,1),...
                        Markers(Marker).MarkerStyle,'color',Markers(Marker).Color,...
                        'markerSize',Markers(Marker).MarkerSize);
                end
            end
        end
        axes(AX1a)
        xlim(XLims),ylim(YLims)
        if ScaleOn
            PlotScaleMarkers;
        else
            ClearOverlays
        end
        hold on      
        for i=1:ExportLabelCount
            if ZoomOn
                text(XLims(1)+Zoom_BoxSize_px*0.05,YLims(1)+Zoom_BoxSize_px*0.2+i*(Zoom_BoxSize_px*0.05),...
                    ExportLabels{i},'fontsize',20,'color','w','fontname','arial')
            else
                text(ImageWidth*0.05,ImageHeight*0.8-i*(ImageHeight*0.05),...
                    ExportLabels{i},'fontsize',20,'color','w','fontname','arial')
            end
        end
        pause(1)
        drawnow
        pause(1)
        warning on 
        warning('Make sure to add overlays here!!!!!')
        warning('Make sure to add overlays here!!!!!')
        warning('Make sure to add overlays here!!!!!')
        warning('Make sure to add overlays here!!!!!')
        
        warning off
        export_fig([FigSaveDir,dc,FigSaveName,' Export ',num2str(ExportCount) '.png'],'-png','-nocrop','-q101','-native');          
        set(ExportFig, 'color', 'none');
        fprintf('eps...')
        export_fig([FigSaveDir,dc,FigSaveName,' Export ',num2str(ExportCount),'.eps'], '-eps','-nocrop','-transparent');        
        close(ExportFig)
        warning on
        fprintf('Finished!\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Finished(src,eventdata,arg1)
            close(OverlayerFig)
            jheapcl
            fprintf(['Exiting Overlayer...\n'])
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
