%To Do

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Zach_Control_Point_Selection_Tool(FigPositionPrimary,FigPosition1,FigPosition2,...
    cpstruct,ControlPoint_MarkerColor,Fixed_Color,Moving_Color,DefaultZoomBoxSize_um,...
    Fixed_Images,Fixed_Image_Options,Fixed_Markers,...
    Fixed_Default_Image,Fixed_Default_Contrast,Fixed_Height,Fixed_Width,Fixed_PixelSize_nm,...
    Fixed_Borders,Fixed_Circle_Radius,Fixed_ScaleBar,...
    Moving_Images,Moving_Image_Options,Moving_Markers,...
    Moving_Default_Image,Moving_Default_Contrast,Moving_Height,Moving_Width,Moving_PixelSize_nm,...
    Moving_Borders,Moving_Circle_Radius,Moving_ScaleBar)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%DefaultZoomBoxSize_um=Zoom_BoxSize_um;Fixed_Images=Airy_Images;Fixed_Image_Options=Airy_Image_Options;Moving_Images=QuaSOR_Images;Moving_Image_Options=QuaSOR_Image_Options;Fixed_Default_Image=1;Moving_Default_Image=5;Fixed_Default_Contrast=0.5;Moving_Default_Contrast=0.7;Fixed_Height=Airy_Height;Fixed_Width=Airy_Width;Fixed_PixelSize_nm=Airy_Pixel_ScaleFactor_nm;Fixed_Borders=Airy_Borders;Fixed_Circle_Radius=Airy_Circle_Radius;Fixed_ScaleBar=Airy_ScaleBar;Moving_Height=size(QuaSOR_Alignment_Image_Resize,1);Moving_Width=size(QuaSOR_Alignment_Image_Resize,2);Moving_PixelSize_nm=QuaSOR_AiryMatch_PixelSize_nm;Moving_Borders=QuaSOR_Borders;Moving_Circle_Radius=QuaSOR_AiryMatch_Circle_Radius;Moving_ScaleBar=ScaleBar_Upscale_AiryMatch;


    global AX1
    global AX2
    %close all     
    fprintf('Initializing...')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Initial Parameters
        TempZoomCoords=[];
        Fixed_Marker_On_Default_Zoom=1;
        FixedPairLayers=[];
        FixedMarkerLayers=[];
        Fixed_DataType=Fixed_Default_Image;
        Fixed_BorderOn=1;
        Fixed_Pair_On=1;
        Fixed_Scale_On=1;
        Fixed_Marker_On=0;
        Fixed_Zoom_BoxSize_um=DefaultZoomBoxSize_um;
        Fixed_LineWidth=0.5;
        Fixed_HighContrast=Fixed_Default_Contrast;
        Fixed_Scroll_Interval_um=Fixed_Zoom_BoxSize_um/5;
        Fixed_R=0;
        Fixed_G=0;
        Fixed_B=0;
        %%%%%%%
        MovingPairLayers=[];
        MovingMarkerLayers=[];
        Moving_DataType=Moving_Default_Image;
        Moving_Pair_On=1;
        Moving_Marker_On=0;
        Moving_BorderOn=1;
        Moving_Scale_On=1;
        Moving_Zoom_BoxSize_um=DefaultZoomBoxSize_um;
        Moving_LineWidth=0.5;
        Moving_HighContrast=Moving_Default_Contrast;
        Moving_Scroll_Interval_um=Moving_Zoom_BoxSize_um/5;
        Moving_R=0;
        Moving_G=0;
        Moving_B=0;
        %%%%%%%
        Max_Zoom_BoxSize_um=50;
        PairMarker={'*','o'};
        PairMarkerSize_Zoom=30;
        ZoomOn=0;
        NumbersOn=0;
        NumberOffset_Zoom=0;
        PairFontSize_Zoom=10;
        Selecting=0;
        Paring=0;
        Pair_Overlay_Color=ControlPoint_MarkerColor;
        Pair_Overlay_Current_Color=ControlPoint_MarkerColor;
        Pair_Overlay_Flagged_Color='r';
        Pair_Overlay_Current_Flagged_Color='r';
        Moving_Pair_LineWidth=1;
        if isempty(cpstruct)
            Pair=0;
        else
            Pair=1;
        end
        if ~isfield(cpstruct,'Flagged')&&~isempty(cpstruct)
            cpstruct.Flagged=zeros(size(cpstruct.ids));
        end
        
        if isempty(FigPosition1)
            PairTrackerFigPosition=[FigPositionPrimary(3),0.4,1-FigPositionPrimary(3),0.5];
        else
            PairTrackerFigPosition=FigPosition1;
        end
        if isempty(FigPosition2)
            if FigPosition1(1)>0
                PairTracker2FigPosition=[PairTrackerFigPosition(1),PairTrackerFigPosition(2)-0.075-PairTrackerFigPosition(4),PairTrackerFigPosition(3),PairTrackerFigPosition(4)];
            else
                PairTracker2FigPosition=[PairTrackerFigPosition(1)-PairTrackerFigPosition(3),PairTrackerFigPosition(2),PairTrackerFigPosition(3),PairTrackerFigPosition(4)];
            end
        else
            PairTracker2FigPosition=FigPosition2;
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
        if ~isempty(cpstruct)
            FigName=['Fixed: ',Fixed_Images{Fixed_DataType}.Label,'  Moving: ',Moving_Images{Moving_DataType}.Label,' Num Pairs: ',num2str(length(cpstruct.ids))];
        else
            FigName=['Fixed: ',Fixed_Images{Fixed_DataType}.Label,'  Moving: ',Moving_Images{Moving_DataType}.Label,' NO PAIRS YET!'];
            cpstruct.ids=[];
        end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        PairTracker=figure('name',FigName);
        set(PairTracker,'units','normalized','position',PairTrackerFigPosition)
        set(PairTracker,'color','k')
        set(gca,'color','k')
        axis off
        box off
        set(gca,'ydir','reverse')
        hold on
        if Fixed_BorderOn
            Fixed_BorderLayers1=[];
            count=0;
            for Border=1:length(Fixed_Borders)
                for j=1:length(Fixed_Borders(Border).BorderLine)
                    count=count+1;
                    Fixed_BorderLayers1(count)=plot(Fixed_Borders(Border).BorderLine{j}.BorderLine(:,2),...
                        Fixed_Borders(Border).BorderLine{j}.BorderLine(:,1),...
                        '--','color',Fixed_Borders(Border).Color,...
                        'linewidth',0.25);
                end
            end
        end
        if Moving_BorderOn
            Moving_BorderLayers1=[];
            count=0;
            for Border=1:length(Moving_Borders)
                for j=1:length(Moving_Borders(Border).BorderLine)
                    count=count+1;
                    Moving_BorderLayers1(count)=plot(Moving_Borders(Border).BorderLine{j}.BorderLine(:,2),...
                        Moving_Borders(Border).BorderLine{j}.BorderLine(:,1),...
                        ':','color',Moving_Borders(Border).Color,...
                        'linewidth',0.25);
                end
            end
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        PairTracker2=figure('name',FigName);
        set(PairTracker2,'units','normalized','position',PairTracker2FigPosition)
        set(PairTracker2,'color','k')
        set(gca,'color','k')
        axis off
        box off
        set(gca,'ydir','reverse')
        hold on
        if Fixed_BorderOn
            Fixed_BorderLayers1=[];
            count=0;
            for Border=1:length(Fixed_Borders)
                for j=1:length(Fixed_Borders(Border).BorderLine)
                    count=count+1;
                    Fixed_BorderLayers1(count)=plot(Fixed_Borders(Border).BorderLine{j}.BorderLine(:,2),...
                        Fixed_Borders(Border).BorderLine{j}.BorderLine(:,1),...
                        '--','color',Fixed_Borders(Border).Color,...
                        'linewidth',0.25);
                end
            end
        end
        if Moving_BorderOn
            Moving_BorderLayers1=[];
            count=0;
            for Border=1:length(Moving_Borders)
                for j=1:length(Moving_Borders(Border).BorderLine)
                    count=count+1;
                    Moving_BorderLayers1(count)=plot(Moving_Borders(Border).BorderLine{j}.BorderLine(:,2),...
                        Moving_Borders(Border).BorderLine{j}.BorderLine(:,1),...
                        ':','color',Moving_Borders(Border).Color,...
                        'linewidth',0.25);
                end
            end
        end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        SelectionFig=figure('name',FigName);
        set(gcf, 'color', 'white');
        set(gcf,'units','normalized','position',FigPositionPrimary)
        AX1=subtightplot(1,2,1,[0,0],[0.05,0.05],[0.05,0.05]);
        AX2=subtightplot(1,2,1,[0,0],[0.05,0.05],[0.05,0.05]);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        NumUndoBuffer=5;
        for u=1:NumUndoBuffer
            UndoBuffer(u).cpstruct=[];
            UndoBuffer(u).CurrentPair=[];
        end
        Fixed_Image=Fixed_Images{Fixed_DataType}.Image;
        Moving_Image=Moving_Images{Moving_DataType}.Image;
        Fixed_XLims=[0,size(Fixed_Image,2)];
        Fixed_YLims=[0,size(Fixed_Image,1)];
        Fixed_Zoom_Coord=[size(Fixed_Image,2)/2,size(Fixed_Image,1)/2];
        Moving_XLims=[0,size(Moving_Image,2)];
        Moving_YLims=[0,size(Moving_Image,1)];
        Moving_Zoom_Coord=[size(Moving_Image,2)/2,size(Moving_Image,1)/2];
        Fixed_Zoom_BoxSize_px=ceil((Fixed_Zoom_BoxSize_um*1000)/Fixed_PixelSize_nm);
        Moving_Zoom_BoxSize_px=ceil((Moving_Zoom_BoxSize_um*1000)/Moving_PixelSize_nm);
        Fixed_Scroll_Interval_px=ceil((Fixed_Scroll_Interval_um*1000)/Fixed_PixelSize_nm);
        Moving_Scroll_Interval_px=ceil((Moving_Scroll_Interval_um*1000)/Moving_PixelSize_nm);
        ZoomBox_Fixed_P1=[];ZoomBox_Fixed_P2=[];ZoomBox_Fixed_P3=[];ZoomBox_Fixed_P4=[];
        ZoomBox_Moving_P1=[];ZoomBox_Moving_P2=[];ZoomBox_Moving_P3=[];ZoomBox_Moving_P4=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %UI Elements
    for zzz=1:1
        Fixed_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.2 0.02 0.1 0.03],...
            'String',['Fixed Image'],'FontSize',16);
        Moving_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.7 0.02 0.1 0.03],...
            'String',['Moving Image'],'FontSize',16);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Jump2PairButton = uicontrol('Style', 'pushbutton', 'String', 'Jump2Pair',...
            'units','normalized','fontsize',7,...
            'Position', [0.42 0.97 0.03 0.03],...
            'Callback', @Jump2Pair);  
        UndoButton = uicontrol('Style', 'pushbutton', 'String', 'UNDO',...
            'units','normalized','fontsize',8,...
            'Position', [0.42 0.94 0.03 0.03],...
            'Callback', @Undo);  
        DeletePairsQuickButton = uicontrol('Style', 'pushbutton', 'String', 'QuickDel(del)',...
            'units','normalized','fontsize',7,...
            'Position', [0.37 0.98 0.05 0.02],...
            'Callback', @QuickDelete);  
        DeletePairsButton = uicontrol('Style', 'pushbutton', 'String', 'Delete Pair#',...
            'units','normalized','fontsize',7,...
            'Position', [0.37 0.96 0.05 0.02],...
            'Callback', @DeletePairs);  
        DeleteRangeButton = uicontrol('Style', 'pushbutton', 'String', 'Delete Range',...
            'units','normalized','fontsize',7,...
            'Position', [0.37 0.94 0.05 0.02],...
            'Callback', @DeleteRange); 
        FlagPairsButton = uicontrol('Style', 'pushbutton', 'String', 'Flag(f)',...
            'units','normalized',...
            'Position', [0.45 0.94 0.05 0.03],...
            'Callback', @FlagPairs);   
        AddPairsButton = uicontrol('Style', 'pushbutton', 'String', 'Add(shift)',...
            'units','normalized',...
            'Position', [0.50 0.94 0.05 0.03],...
            'Callback', @AddPairs);   
        SelectingButton = uicontrol('Style', 'togglebutton', 'String', 'Selecting',...
            'units','normalized','fontsize',7,...
            'value',Selecting,...
            'Position', [0.58 0.97 0.03 0.03],...
            'Callback', @ForceChangeSelecting); 
        UpdateImageButton = uicontrol('Style', 'pushbutton', 'String', 'Force Update (Space)',...
            'units','normalized','fontsize',7,...
            'Position', [0.65 0.97 0.06 0.03],...
            'Callback', @ForceUpdateImage);   
        FinishedButton = uicontrol('Style', 'pushbutton', 'String', 'Finished (ctrl)',...
            'units','normalized',...
            'Position', [0.65 0.94 0.06 0.03],...
            'Callback', @Finished);
        DisplayNumbersButton = uicontrol('Style', 'togglebutton', 'String', 'Numbers',...
            'units','normalized','fontsize',7,...
            'value',NumbersOn,...
            'Position', [0.55 0.97 0.03 0.03],...
            'Callback', @DisplayNumbers);   
        Jump2FlagButton = uicontrol('Style', 'pushbutton', 'String', 'Jump2Flag',...
            'units','normalized','fontsize',7,...
            'Position', [0.61 0.97 0.04 0.03],...
            'Callback', @Jump2Flag);   
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if length(cpstruct.ids)>0
            PairSlider = uicontrol('Style', 'slider',...
                'Min',0,'Max',1,'Value',Pair/length(cpstruct.ids),...
                'SliderStep',[1/length(cpstruct.ids),5/length(cpstruct.ids)],...
                'units','normalized',...
                'Position', [0.45 0.985 0.1 0.015],...
                'Callback', @Pair_Slider_callback);
        else
            PairSlider = uicontrol('Style', 'slider',...
                'Min',0,'Max',1,'Value',0,...
                'units','normalized',...
                'Position', [0.45 0.985 0.1 0.015],...
                'Callback', @Pair_Slider_callback);
        end
        SliderText = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.47 0.97 0.06 0.015],...
            'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);
        %PairNav=uicontrol('Style','Edit','String','matlab','KeyPressFCN',@PairNavigation_KeyPressFcn);
        ForwardText = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.53 0.97 0.02 0.015],...
            'String','c>');
        ReverseText = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.45 0.97 0.02 0.015],...
            'String','<x');
        PairControl = uicontrol('Style', 'edit', 'string',num2str(Pair),...
            'units','normalized',...
            'Position', [0.57 0.94 0.03 0.03]);      
        PairJump2Button = uicontrol('Style', 'pushbutton', 'String', 'Pair>',...
            'units','normalized',...
            'Position', [0.55 0.94 0.02 0.03],...
            'Callback', @Jump2PairNum);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ShiftFixedCoordButton = uicontrol('Style', 'togglebutton', 'String', 'Shift Fixed (q)',...
            'units','normalized','fontsize',7,...
            'Position', [0.1 0.94 0.05 0.03],...
            'Callback', @ShiftFixed);      
        DisplayFixedMarkerButton = uicontrol('Style', 'togglebutton', 'String', 'Fixed Marker',...
            'units','normalized','fontsize',7,...
            'value',Fixed_Marker_On,...
            'Position', [0.0 0.97 0.05 0.03],...
            'Callback', @DisplayFixedMarker);   
        DisplayFixedPairButton = uicontrol('Style', 'togglebutton', 'String', 'Fixed Pair',...
            'units','normalized','fontsize',7,...
            'value',Fixed_Pair_On,...
            'Position', [0.05 0.97 0.05 0.03],...
            'Callback', @DisplayFixed_Pair);   
        DisplayFixedBordersButton = uicontrol('Style', 'togglebutton', 'String', 'Fixed Bord',...
            'units','normalized','fontsize',7,...
            'value',Fixed_BorderOn,...
            'Position', [0.1 0.97 0.05 0.03],...
            'Callback', @DisplayFixedBorders);      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ShiftMovingCoordButton = uicontrol('Style', 'pushbutton', 'String', 'Shift Moving (w)',...
            'units','normalized','fontsize',7,...
            'Position', [0.85 0.94 0.05 0.03],...
            'Callback', @ShiftMoving);          
        DisplayMoving_MarkerButton = uicontrol('Style', 'togglebutton', 'String', 'Moving Markers',...
            'units','normalized','fontsize',7,...
            'value',Moving_Marker_On,...
            'Position', [0.85 0.97 0.05 0.03],...
            'Callback', @DisplayMoving_Marker);          
        DisplayMovingBordersButton = uicontrol('Style', 'togglebutton', 'String', 'Moving Pair',...
            'units','normalized','fontsize',7,...
            'value',Moving_Pair_On,...
            'Position', [0.90 0.97 0.05 0.03],...
            'Callback', @DisplayMoving_Pair);          
        DisplayMovingBordersButton = uicontrol('Style', 'togglebutton', 'String', 'Moving Bord',...
            'units','normalized','fontsize',7,...
            'value',Moving_BorderOn,...
            'Position', [0.95 0.97 0.05 0.03],...
            'Callback', @DisplayMovingBorders);   
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Fixed_Image_Selection = uicontrol('Style', 'popup',...
           'String', Fixed_Image_Options,...
            'units','normalized',...
            'Position', [0.15 0.95 0.1 0.05],...
           'Callback', @Select_Fixed_Image);
        set(Fixed_Image_Selection,'Value',Fixed_DataType)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Fixed_Contrast_Slider = uicontrol('Style', 'slider',...
            'Min',0,'Max',1,'Value',Fixed_HighContrast,...
            'SliderStep',[0.05,0.1],...
            'units','normalized',...
            'Position', [0.15 0.955 0.1 0.015],...
            'Callback', @Fixed_Contrast_Slider_callback);
        Fixed_Contrast_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.15 0.94 0.1 0.015],...
            'String',['Fixed Max%: ',num2str(Fixed_HighContrast*100),'%']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Fixed_R_Control = uicontrol('Style', 'edit', 'string',num2str(Fixed_R),...
            'units','normalized',...
            'Position', [0.2725 0.98 0.0175 0.02]);
        Fixed_R_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.2625 0.98 0.01 0.02],...
            'String','R');
        Fixed_G_Control = uicontrol('Style', 'edit', 'string',num2str(Fixed_G),...
            'units','normalized',...
            'Position', [0.2725 0.96 0.0175 0.02]);      
        Fixed_G_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.2625 0.96 0.01 0.02],...
            'String','G');
        Fixed_B_Control = uicontrol('Style', 'edit', 'string',num2str(Fixed_B),...
            'units','normalized',...
            'Position', [0.2725 0.94 0.0175 0.02]);      
        Fixed_B_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.2625 0.94 0.01 0.02],...
            'String','B');
        FixedColorBalanceControl = uibutton('Style', 'pushbutton', 'String', 'RGB',...
            'units','normalized','rotation',90,...
            'Position', [0.255 0.94 0.01 0.055],...
            'Callback', @FixedColorBalance);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Moving_Image_Selection = uicontrol('Style', 'popup',...
           'String', Moving_Image_Options,...
            'units','normalized',...
            'Position', [0.71 0.95 0.10 0.05],...
           'Callback', @Select_Moving_Image);
        set(Moving_Image_Selection,'Value',Moving_DataType)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Moving_Contrast_Slider = uicontrol('Style', 'slider',...
            'Min',0,'Max',1,'Value',Moving_HighContrast,...
            'SliderStep',[0.05,0.1],...
            'units','normalized',...
            'Position', [0.71 0.955 0.1 0.015],...
            'Callback', @Moving_Contrast_Slider_callback);
        Moving_Contrast_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.71 0.94 0.1 0.015],...
            'String',['Moving Max%: ',num2str(Fixed_Default_Contrast*100),'%']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Moving_R_Control = uicontrol('Style', 'edit', 'string',num2str(Moving_R),...
            'units','normalized',...
            'Position', [0.8325 0.98 0.0175 0.02]);
        Moving_R_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.8225 0.98 0.01 0.02],...
            'String','R');
        Moving_G_Control = uicontrol('Style', 'edit', 'string',num2str(Moving_G),...
            'units','normalized',...
            'Position', [0.8325 0.96 0.0175 0.02]);      
        Moving_G_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.8225 0.96 0.01 0.02],...
            'String','G');
        Moving_B_Control = uicontrol('Style', 'edit', 'string',num2str(Moving_B),...
            'units','normalized',...
            'Position', [0.8325 0.94 0.0175 0.02]);      
        Moving_B_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.8225 0.94 0.01 0.02],...
            'String','B');
        MovingColorBalanceControl = uibutton('Style', 'pushbutton', 'String', 'RGB',...
            'units','normalized','rotation',90,...
            'Position', [0.815 0.94 0.01 0.055],...
            'Callback', @MovingColorBalance);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ZoomInButton = uicontrol('Style', 'pushbutton', 'String', '+Zoom(pgup)',...
            'units','normalized','FontSize',7,...
            'Position', [0.33 0.97 0.04 0.03],...
            'Callback', @ZoomIn);   
        ZoomOutButton = uicontrol('Style', 'pushbutton', 'String', '-Zoom(pgdn)',...
            'units','normalized','FontSize',7,...
            'Position', [0.29 0.97 0.04 0.03],...
            'Callback', @ZoomOut);   
        ZoomSize_Slider = uicontrol('Style', 'slider',...
            'Min',0,'Max',1,'Value',Fixed_Zoom_BoxSize_um/Max_Zoom_BoxSize_um,...
            'SliderStep',[1/Max_Zoom_BoxSize_um,5/Max_Zoom_BoxSize_um],...
            'units','normalized',...
            'Position', [0.29 0.955 0.08 0.015],...
            'Callback', @ZoomSize_Slider_callback);
        ZoomSize_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.29 0.94 0.08 0.015],...
            'String',['ZoomBox: ',num2str(Fixed_Zoom_BoxSize_um),'um']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %XY Adjustments
        Fixed_X_Scroll = uicontrol('Style', 'slider',...
            'Min',0,'Max',1,'Value',Fixed_Zoom_Coord(1)/size(Fixed_Image,2),...
            'SliderStep',[Fixed_Scroll_Interval_px/size(Fixed_Image,2),(Fixed_Scroll_Interval_px*5)/size(Fixed_Image,2)],...
            'units','normalized',...
            'Position', [0.015 0 0.485 0.015],...
            'Callback', @Fixed_X_Scroll_callback);
        Fixed_Y_Scroll = uicontrol('Style', 'slider',...
            'Min',0,'Max',1,'Value',1-Fixed_Zoom_Coord(2)/size(Fixed_Image,1),...
            'SliderStep',[Fixed_Scroll_Interval_px/size(Fixed_Image,1),(Fixed_Scroll_Interval_px*5)/size(Fixed_Image,1)],...
            'units','normalized',...
            'Position', [0 0.015 0.015 0.95],...
            'Callback', @Fixed_Y_Scroll_callback);
        Moving_X_Scroll = uicontrol('Style', 'slider',...
            'Min',0,'Max',1,'Value',Moving_Zoom_Coord(1)/size(Moving_Image,2),...
            'SliderStep',[Moving_Scroll_Interval_px/size(Moving_Image,2),(Moving_Scroll_Interval_px*5)/size(Moving_Image,2)],...
            'units','normalized',...
            'Position', [0.5 0 0.485 0.015],...
            'Callback', @Moving_X_Scroll_callback);
        Moving_Y_Scroll = uicontrol('Style', 'slider',...
            'Min',0,'Max',1,'Value',1-Moving_Zoom_Coord(2)/size(Moving_Image,1),...
            'SliderStep',[Moving_Scroll_Interval_px/size(Moving_Image,1),(Moving_Scroll_Interval_px*5)/size(Moving_Image,1)],...
            'units','normalized',...
            'Position', [0.985 0.015 0.015 0.95],...
            'Callback', @Moving_Y_Scroll_callback);    

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        set(SelectionFig,'WindowKeyPressFcn',@Navigation_KeyPressFcn)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Status_TR = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.02 0.95 0.07 0.015],...
            'BackgroundColor','g',...
            'String',['Status: ']);
        Status_TL = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.91 0.95 0.07 0.015],...
            'BackgroundColor','g',...
            'String',['Status: ']);       
        Status_BR = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.02 0.02 0.07 0.015],...
            'BackgroundColor','g',...
            'String',['Status: ']);           
        Status_BL = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.91 0.02 0.07 0.015],...
            'BackgroundColor','g',...
            'String',['Status: ']);
        SelectionStatus_TR = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.91 0.935 0.07 0.015],...
            'BackgroundColor','g',...
            'String',['Selecting: OFF']);
        SelectionStatus_TL = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.02 0.935 0.07 0.015],...
            'BackgroundColor','g',...
            'String',['Selecting: OFF']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    figure(SelectionFig)
    UpdateImage(Fixed_Image,Moving_Image)
    fprintf('Ready for selections...\n');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Navigation_KeyPressFcn(src, evnt)
        if isequal(evnt.Key,'rightarrow')
            if ZoomOn
                Fixed_Zoom_Coord(1) = Fixed_Zoom_Coord(1)+Fixed_Scroll_Interval_px;
                Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
                Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
                set(Fixed_X_Scroll,'value',Fixed_Zoom_Coord(1)/size(Fixed_Image,2))
                Moving_Zoom_Coord(1) = Moving_Zoom_Coord(1)+Moving_Scroll_Interval_px;
                Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
                Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
                set(Moving_X_Scroll,'value',Moving_Zoom_Coord(1)/size(Moving_Image,2))
                axes(AX1)
                xlim(Fixed_XLims),ylim(Fixed_YLims)
                axes(AX2)
                xlim(Moving_XLims),ylim(Moving_YLims)
                PlotFixedPairs
                PlotMovingPairs
                UpdatePairTrackerZoomBox;UpdatePairTracker2
                figure(SelectionFig)
            end
        elseif isequal(evnt.Key,'leftarrow')
            if ZoomOn
                Fixed_Zoom_Coord(1) = Fixed_Zoom_Coord(1)-Fixed_Scroll_Interval_px;
                Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
                Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
                set(Fixed_X_Scroll,'value',Fixed_Zoom_Coord(1)/size(Fixed_Image,2))
                Moving_Zoom_Coord(1) = Moving_Zoom_Coord(1)-Moving_Scroll_Interval_px;
                Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
                Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
                set(Moving_X_Scroll,'value',Moving_Zoom_Coord(1)/size(Moving_Image,2))
                axes(AX1)
                xlim(Fixed_XLims),ylim(Fixed_YLims)
                axes(AX2)
                xlim(Moving_XLims),ylim(Moving_YLims)
                PlotFixedPairs
                PlotMovingPairs
                UpdatePairTrackerZoomBox;UpdatePairTracker2
                figure(SelectionFig)
            end
        elseif isequal(evnt.Key,'uparrow')
            if ZoomOn
                Fixed_Zoom_Coord(2) = Fixed_Zoom_Coord(2)-Fixed_Scroll_Interval_px;
                Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
                Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
                set(Fixed_Y_Scroll,'value',Fixed_Zoom_Coord(2)/size(Fixed_Image,1))
                Moving_Zoom_Coord(2) = Moving_Zoom_Coord(2)-Moving_Scroll_Interval_px;
                Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
                Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
                set(Moving_Y_Scroll,'value',Moving_Zoom_Coord(2)/size(Moving_Image,1))
                axes(AX1)
                xlim(Fixed_XLims),ylim(Fixed_YLims)
                axes(AX2)
                xlim(Moving_XLims),ylim(Moving_YLims)
                PlotFixedPairs
                PlotMovingPairs
                UpdatePairTrackerZoomBox;UpdatePairTracker2
                figure(SelectionFig)
            end
        elseif isequal(evnt.Key,'downarrow')
            if ZoomOn
                Fixed_Zoom_Coord(2) = Fixed_Zoom_Coord(2)+Fixed_Scroll_Interval_px;
                Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
                Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
                set(Fixed_Y_Scroll,'value',Fixed_Zoom_Coord(2)/size(Fixed_Image,1))
                Moving_Zoom_Coord(2) = Moving_Zoom_Coord(2)+Moving_Scroll_Interval_px;
                Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
                Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
                set(Moving_Y_Scroll,'value',Moving_Zoom_Coord(2)/size(Moving_Image,1))
                axes(AX1)
                xlim(Fixed_XLims),ylim(Fixed_YLims)
                axes(AX2)
                xlim(Moving_XLims),ylim(Moving_YLims)
                PlotFixedPairs
                PlotMovingPairs
                UpdatePairTrackerZoomBox;UpdatePairTracker2
                figure(SelectionFig)
            end
        elseif isequal(evnt.Key,'shift')
            AddPairs
%         elseif isequal(evnt.Key,'shift')&&~Paring
%             AddPairs
%         elseif isequal(evnt.Key,'shift')&&Paring
%             return
        elseif isequal(evnt.Key,'delete')
            QuickDelete
        elseif isequal(evnt.Key,'f')
            FlagPairs
        elseif isequal(evnt.Key,'q')
            ShiftFixed
        elseif isequal(evnt.Key,'w')
            ShiftMoving
        elseif isequal(evnt.Key,'c')
            PairAdvance
        elseif isequal(evnt.Key,'x')
            PairRetreat
        elseif isequal(evnt.Key,'control')
            Finished
        elseif isequal(evnt.Key,'pageup')
            ZoomIn
        elseif isequal(evnt.Key,'pagedown')
            ZoomOut
        elseif isequal(evnt.Key,'space')
            ForceUpdateImage
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdateImage(Fixed_Image,Moving_Image)
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        FigName=['Fixed: ',Fixed_Images{Fixed_DataType}.Label,'  Moving: ',Moving_Images{Moving_DataType}.Label,' Num Pairs: ',num2str(length(cpstruct.ids))];
        set(gcf,'name',FigName)
                
        if Pair~=0
            Moving_Details={['Pair#: ',num2str(Pair)]};
            set(PairControl, 'string',num2str(Pair))
            set(PairSlider,'Value',Pair/length(cpstruct.ids),...
                    'SliderStep',[1/length(cpstruct.ids),5/length(cpstruct.ids)])
            set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
        end
        cla(AX1)
        cla(AX2)
        figure(SelectionFig)
        %clf
        AX1=subtightplot(1,2,1,[0,0],[0.05,0.05],[0.05,0.05]);
        %imshow(Fixed_Image)
        imshow(imadjust(Fixed_Image,...
            [0,0,0;(1-Fixed_HighContrast)*(1-Fixed_R),(1-Fixed_HighContrast)*(1-Fixed_G),(1-Fixed_HighContrast)*(1-Fixed_B)]),[]);
        hold on
        set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        if Fixed_Pair_On
            PlotFixedPairs
        end
        if Fixed_Marker_On
            PlotFixed_Markers
        end
        set(Status_TR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        if Fixed_BorderOn
            hold on
            Fixed_BorderLayers=[];
            count=0;
            for Border=1:length(Fixed_Borders)
                for j=1:length(Fixed_Borders(Border).BorderLine)
                    count=count+1;
                    Fixed_BorderLayers(count)=plot(Fixed_Borders(Border).BorderLine{j}.BorderLine(:,2),...
                        Fixed_Borders(Border).BorderLine{j}.BorderLine(:,1),...
                        Fixed_Borders(Border).LineStyle,'color',Fixed_Borders(Border).Color,...
                        'linewidth',Fixed_Borders(Border).LineWidth);
                end
            end

        end
        if Fixed_Scale_On
            hold on
            plot(Fixed_ScaleBar.XData,Fixed_ScaleBar.YData,'-','color',Fixed_ScaleBar.Color,'LineWidth',Fixed_ScaleBar.Width);
        end
        hold on
        xlim(Fixed_XLims),ylim(Fixed_YLims)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        set(Status_TR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
        AX2=subtightplot(1,2,2,[0,0],[0.05,0.05],[0.05,0.05]);
        imshow(imadjust(Moving_Image,...
            [0,0,0;(1-Moving_HighContrast)*(1-Moving_R),(1-Moving_HighContrast)*(1-Moving_G),(1-Moving_HighContrast)*(1-Moving_B)]),[]);
        hold on
        if Moving_Pair_On
            PlotMovingPairs;
        end
        if Moving_Marker_On
            PlotMoving_Markers;
        end
        set(Status_TR,'String',['Status: Busy....'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy....'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy....'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy....'],'BackgroundColor','r');pause(0.0001);
        if Moving_BorderOn
            hold on
            Moving_BorderLayers=[];
            count=0;
            for Border=1:length(Moving_Borders)
                for j=1:length(Moving_Borders(Border).BorderLine)
                    count=count+1;
                    Moving_BorderLayers(count)=plot(Moving_Borders(Border).BorderLine{j}.BorderLine(:,2),...
                        Moving_Borders(Border).BorderLine{j}.BorderLine(:,1),...
                        Moving_Borders(Border).LineStyle,'color',Moving_Borders(Border).Color,...
                        'linewidth',Moving_Borders(Border).LineWidth);
                end
            end
        end
        if Moving_Scale_On
            hold on
            plot(Moving_ScaleBar.XData,Moving_ScaleBar.YData,'-','color',Moving_ScaleBar.Color,'LineWidth',Moving_ScaleBar.Width);
        end
        hold on
        xlim(Moving_XLims),ylim(Moving_YLims)
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        UpdatePairTracker
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
        PlotFixed_Markers;PlotMoving_Markers;
        figure(SelectionFig)

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdatePairTracker
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        figure(PairTracker)
        clf
        hold on
        if Fixed_BorderOn
            Fixed_BorderLayers1=[];
            count=0;
            for Border=1:length(Fixed_Borders)
                for j=1:length(Fixed_Borders(Border).BorderLine)
                    count=count+1;
                    Fixed_BorderLayers1(count)=plot(Fixed_Borders(Border).BorderLine{j}.BorderLine(:,2),...
                        Fixed_Borders(Border).BorderLine{j}.BorderLine(:,1),...
                        '--','color',Fixed_Borders(Border).Color,...
                        'linewidth',0.25);
                end
            end
        end
        if Moving_BorderOn
            Moving_BorderLayers1=[];
            count=0;
            for Border=1:length(Moving_Borders)
                for j=1:length(Moving_Borders(Border).BorderLine)
                    count=count+1;
                    Moving_BorderLayers1(count)=plot(Moving_Borders(Border).BorderLine{j}.BorderLine(:,2),...
                        Moving_Borders(Border).BorderLine{j}.BorderLine(:,1),...
                        ':','color',Moving_Borders(Border).Color,...
                        'linewidth',0.25);
                end
            end
        end
        set(PairTracker,'color','k')
        set(gca,'color','k')
        axis off
        box off
        set(gca,'ydir','reverse')
        axis equal tight
        xlim([0,max([Fixed_Width,Moving_Width])])
        ylim([0,max([Fixed_Height,Moving_Height])])
        figure(PairTracker)
        if ~isempty(cpstruct)
            if isfield(cpstruct,'basePoints')
                for i=1:size(cpstruct.basePoints,1)
                    if Fixed_Pair_On&&Moving_Pair_On
                        if cpstruct.Flagged(i)
                            if Pair==i
                                plot([cpstruct.inputPoints(i,1),cpstruct.basePoints(i,1)],...
                                    [cpstruct.inputPoints(i,2),cpstruct.basePoints(i,2)],...
                                    ':','color',Pair_Overlay_Current_Flagged_Color,'linewidth',1);
                            else
                                plot([cpstruct.inputPoints(i,1),cpstruct.basePoints(i,1)],...
                                    [cpstruct.inputPoints(i,2),cpstruct.basePoints(i,2)],...
                                    ':','color',Pair_Overlay_Flagged_Color,'linewidth',1);
                            end
                        else
                            if Pair==i
                                plot([cpstruct.inputPoints(i,1),cpstruct.basePoints(i,1)],...
                                    [cpstruct.inputPoints(i,2),cpstruct.basePoints(i,2)],...
                                    '-','color',Pair_Overlay_Current_Color,'linewidth',0.5);
                            else
                                plot([cpstruct.inputPoints(i,1),cpstruct.basePoints(i,1)],...
                                    [cpstruct.inputPoints(i,2),cpstruct.basePoints(i,2)],...
                                    '-','color',Pair_Overlay_Color,'linewidth',0.5);
                            end
                        end
                    end
                    if Moving_Pair_On
                        plot(cpstruct.inputPoints(i,1),cpstruct.inputPoints(i,2),...
                            '.','color',Moving_Color,'markersize',5);
                    end
                    if Fixed_Pair_On
                        plot(cpstruct.basePoints(i,1),cpstruct.basePoints(i,2),...
                            '.','color',Fixed_Color,'markersize',5);
                    end
                end
            end
        end
        pause(0.1)
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdatePairTrackerZoomBox
        figure(PairTracker)

        if exist('ZoomBox_Fixed_P1')
            if ~isempty(ZoomBox_Fixed_P1)
                delete(ZoomBox_Fixed_P1);delete(ZoomBox_Fixed_P2);delete(ZoomBox_Fixed_P3);delete(ZoomBox_Fixed_P4);
            end
        end
        if exist('ZoomBox_Moving_P1')
            if ~isempty(ZoomBox_Moving_P1)
                delete(ZoomBox_Moving_P1);delete(ZoomBox_Moving_P2);delete(ZoomBox_Moving_P3);delete(ZoomBox_Moving_P4);
            end
        end
        
        if ~ZoomOn&&~isempty(cpstruct)
            try
                Temp_Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
                Temp_Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
            catch
                Temp_Fixed_Zoom_Coord=Fixed_Zoom_Coord;
                Temp_Moving_Zoom_Coord=Moving_Zoom_Coord;
            end
        else
            Temp_Fixed_Zoom_Coord=Fixed_Zoom_Coord;
            Temp_Moving_Zoom_Coord=Moving_Zoom_Coord;
        end
        Fixed_Zoom_Region=[Temp_Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Temp_Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,...
            Fixed_Zoom_BoxSize_px,Fixed_Zoom_BoxSize_px];
        [ZoomBox_Fixed_P1,ZoomBox_Fixed_P2,ZoomBox_Fixed_P3,ZoomBox_Fixed_P4,~]=...
            PlotBox2(Fixed_Zoom_Region,':',Fixed_Color,1,[],[],[]);
        Moving_Zoom_Region=[Temp_Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Temp_Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,...
            Moving_Zoom_BoxSize_px,Moving_Zoom_BoxSize_px];
        [ZoomBox_Moving_P1,ZoomBox_Moving_P2,ZoomBox_Moving_P3,ZoomBox_Moving_P4,~]=...
            PlotBox2(Moving_Zoom_Region,'--',Moving_Color,1,[],[],[]);
        
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdatePairTracker2
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        figure(PairTracker2)
        clf
        hold on
        if Fixed_BorderOn
            Fixed_BorderLayers1=[];
            count=0;
            for Border=1:length(Fixed_Borders)
                for j=1:length(Fixed_Borders(Border).BorderLine)
                    count=count+1;
                    Fixed_BorderLayers1(count)=plot(Fixed_Borders(Border).BorderLine{j}.BorderLine(:,2),...
                        Fixed_Borders(Border).BorderLine{j}.BorderLine(:,1),...
                        '--','color',Fixed_Borders(Border).Color,...
                        'linewidth',0.25);
                end
            end
        end
        if Moving_BorderOn
            Moving_BorderLayers1=[];
            count=0;
            for Border=1:length(Moving_Borders)
                for j=1:length(Moving_Borders(Border).BorderLine)
                    count=count+1;
                    Moving_BorderLayers1(count)=plot(Moving_Borders(Border).BorderLine{j}.BorderLine(:,2),...
                        Moving_Borders(Border).BorderLine{j}.BorderLine(:,1),...
                        ':','color',Moving_Borders(Border).Color,...
                        'linewidth',0.25);
                end
            end
        end
        set(PairTracker2,'color','k')
        set(gca,'color','k')
        axis off
        box off
        set(gca,'ydir','reverse')
        axis equal tight
        if ~isempty(cpstruct)
            if isfield(cpstruct,'basePoints')
                if ZoomOn
                    Temp_Fixed_XLims=Fixed_XLims;
                    Temp_Fixed_YLims=Fixed_YLims;
                    Temp_Moving_XLims=Moving_XLims;
                    Temp_Moving_YLims=Moving_YLims;
                else
                    Temp_Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
                    Temp_Fixed_XLims=[Temp_Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Temp_Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
                    Temp_Fixed_YLims=[Temp_Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Temp_Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
                    Temp_Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
                    Temp_Moving_XLims=[Temp_Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Temp_Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
                    Temp_Moving_YLims=[Temp_Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Temp_Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
                end
                TempZoomCoords=[];
                for i=1:size(cpstruct.basePoints,1)
                    if Fixed_Pair_On&&Moving_Pair_On
                        if (cpstruct.inputPoints(i,1)>=Temp_Moving_XLims(1)&&...
                            cpstruct.inputPoints(i,1)<=Temp_Moving_XLims(2)&&...
                            cpstruct.inputPoints(i,2)>=Temp_Moving_YLims(1)&&...
                            cpstruct.inputPoints(i,2)<=Temp_Moving_YLims(2))||...
                            (cpstruct.basePoints(i,1)>=Temp_Fixed_XLims(1)&&...
                            cpstruct.basePoints(i,1)<=Temp_Fixed_XLims(2)&&...
                            cpstruct.basePoints(i,2)>=Temp_Fixed_YLims(1)&&...
                            cpstruct.basePoints(i,2)<=Temp_Fixed_YLims(2))

                            if cpstruct.Flagged(i)
                                if Pair==i
                                    plot([cpstruct.inputPoints(i,1),cpstruct.basePoints(i,1)],...
                                        [cpstruct.inputPoints(i,2),cpstruct.basePoints(i,2)],...
                                        ':','color',Pair_Overlay_Current_Flagged_Color,'linewidth',2);
                                else
                                    plot([cpstruct.inputPoints(i,1),cpstruct.basePoints(i,1)],...
                                        [cpstruct.inputPoints(i,2),cpstruct.basePoints(i,2)],...
                                        ':','color',Pair_Overlay_Flagged_Color,'linewidth',2);
                                end
                            else
                                if Pair==i
                                    plot([cpstruct.inputPoints(i,1),cpstruct.basePoints(i,1)],...
                                        [cpstruct.inputPoints(i,2),cpstruct.basePoints(i,2)],...
                                        '-','color',Pair_Overlay_Current_Color,'linewidth',0.5);
                                else
                                    plot([cpstruct.inputPoints(i,1),cpstruct.basePoints(i,1)],...
                                        [cpstruct.inputPoints(i,2),cpstruct.basePoints(i,2)],...
                                        '-','color',Pair_Overlay_Color,'linewidth',0.5);
                                end
                            end
                        end
                    end
                    if Moving_Pair_On
                        plot(cpstruct.inputPoints(i,1),cpstruct.inputPoints(i,2),...
                            'o','color',Moving_Color,'markersize',4);
                        if cpstruct.inputPoints(i,1)>Temp_Moving_XLims(1)&&cpstruct.inputPoints(i,2)>Temp_Moving_YLims(1)&&cpstruct.inputPoints(i,1)<Temp_Moving_XLims(2)&&cpstruct.inputPoints(i,2)<Temp_Moving_YLims(2)
                            TempZoomCoords=vertcat(TempZoomCoords,cpstruct.inputPoints(i,:));
                        end
                    end
                    if Fixed_Pair_On
                        plot(cpstruct.basePoints(i,1),cpstruct.basePoints(i,2),...
                            'o','color',Fixed_Color,'markersize',4);
                        if cpstruct.basePoints(i,1)>Temp_Fixed_XLims(1)&&cpstruct.basePoints(i,2)>Temp_Fixed_YLims(1)&&cpstruct.basePoints(i,1)<Temp_Fixed_XLims(2)&&cpstruct.basePoints(i,2)<Temp_Fixed_YLims(2)
                            TempZoomCoords=vertcat(TempZoomCoords,cpstruct.basePoints(i,:));
                        end
                    end
                end
            end
            if ~isempty(TempZoomCoords)
                TempXLim=[min(TempZoomCoords(:,1)),max(TempZoomCoords(:,1))];
                TempYLim=[min(TempZoomCoords(:,2)),max(TempZoomCoords(:,2))];
                if TempXLim(2)<=TempXLim(1)||TempYLim(2)<=TempYLim(1)
                    xlim([0,max([Fixed_Width,Moving_Width])])
                    ylim([0,max([Fixed_Height,Moving_Height])])
                else
                    xlim(TempXLim)
                    ylim(TempYLim)
                end
            else
                xlim([0,max([Fixed_Width,Moving_Width])])
                ylim([0,max([Fixed_Height,Moving_Height])])
            end
        end
        TempZoomCoords=[];
        pause(0.1)
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function PlotFixedPairs
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);

        hold on
        %Remove layers
        if ~isempty(FixedPairLayers)
            for Pair1=1:length(FixedPairLayers)
                if ~isempty(FixedPairLayers(Pair1).MarkerHandle)
                    delete(FixedPairLayers(Pair1).MarkerHandle)
                end
                if ~isempty(FixedPairLayers(Pair1).TextHandle)
                    delete(FixedPairLayers(Pair1).TextHandle)
                end
            end
            FixedPairLayers=[];
        end
        set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Add Layers
        FixedPairLayers=[];
        if Fixed_Pair_On
            count=0;
            figure(SelectionFig)
            hold on 
            axes(AX1)
            for Pair1=1:length(cpstruct.ids)
                if cpstruct.basePoints(Pair1,1)>=Fixed_XLims(1)&&...
                    cpstruct.basePoints(Pair1,1)<=Fixed_XLims(2)&&...
                    cpstruct.basePoints(Pair1,2)>=Fixed_YLims(1)&&...
                    cpstruct.basePoints(Pair1,2)<=Fixed_YLims(2)
                    if cpstruct.Flagged(Pair1)
                        if Pair==Pair1
                            count=count+1;
                            hold on;
                            FixedPairLayers(count).MarkerHandle=Plot_Circle2(cpstruct.basePoints(Pair1,1),...
                                cpstruct.basePoints(Pair1,2),...
                                Fixed_Circle_Radius,'-',Fixed_LineWidth+2,Pair_Overlay_Current_Flagged_Color);
                            if NumbersOn
                                FixedPairLayers(count).TextHandle=text(cpstruct.basePoints(Pair1,1)+NumberOffset_Zoom,...
                                    cpstruct.basePoints(Pair1,2),num2str(Pair1),...
                                    'color',Pair_Overlay_Current_Flagged_Color,'FontSize',PairFontSize_Zoom,'FontWeight','bold','horizontalalignment','center');
                            else
                                FixedPairLayers(count).TextHandle=[];
                            end
                        else
                            count=count+1;
                            hold on;
                            FixedPairLayers(count).MarkerHandle=Plot_Circle2(cpstruct.basePoints(Pair1,1),...
                                cpstruct.basePoints(Pair1,2),...
                                Fixed_Circle_Radius,'-',Fixed_LineWidth,Pair_Overlay_Flagged_Color);
                            if NumbersOn
                                FixedPairLayers(count).TextHandle=text(cpstruct.basePoints(Pair1,1)+NumberOffset_Zoom,...
                                    cpstruct.basePoints(Pair1,2),num2str(Pair1),...
                                    'color',Pair_Overlay_Flagged_Color,'FontSize',PairFontSize_Zoom,'horizontalalignment','center');
                            else
                                FixedPairLayers(count).TextHandle=[];
                            end
                        end
                    else
                        if Pair==Pair1
                            count=count+1;
                            hold on;
                            FixedPairLayers(count).MarkerHandle=Plot_Circle2(cpstruct.basePoints(Pair1,1),...
                                cpstruct.basePoints(Pair1,2),...
                                Fixed_Circle_Radius,'-',Fixed_LineWidth+2,Pair_Overlay_Current_Color);
                            if NumbersOn
                                FixedPairLayers(count).TextHandle=text(cpstruct.basePoints(Pair1,1)+NumberOffset_Zoom,...
                                    cpstruct.basePoints(Pair1,2),num2str(Pair1),...
                                    'color',Pair_Overlay_Current_Color,'FontSize',PairFontSize_Zoom,'FontWeight','bold','horizontalalignment','center');
                            else
                                FixedPairLayers(count).TextHandle=[];
                            end
                        else
                            count=count+1;
                            hold on;
                            FixedPairLayers(count).MarkerHandle=Plot_Circle2(cpstruct.basePoints(Pair1,1),...
                                cpstruct.basePoints(Pair1,2),...
                                Fixed_Circle_Radius,'-',Fixed_LineWidth,Pair_Overlay_Color);
                            if NumbersOn
                                FixedPairLayers(count).TextHandle=text(cpstruct.basePoints(Pair1,1)+NumberOffset_Zoom,...
                                    cpstruct.basePoints(Pair1,2),num2str(Pair1),...
                                    'color',Pair_Overlay_Color,'FontSize',PairFontSize_Zoom,'horizontalalignment','center');
                            else
                                FixedPairLayers(count).TextHandle=[];
                            end
                        end
                    end
                end
            end
            set(Status_TR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_TL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_BR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_BL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
        end
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function PlotMovingPairs
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);

        hold on
        %Remove layers
        if ~isempty(MovingPairLayers)
            for Pair1=1:length(MovingPairLayers)
                if ~isempty(MovingPairLayers(Pair1).MarkerHandle)
                    delete(MovingPairLayers(Pair1).MarkerHandle)
                end
                if ~isempty(MovingPairLayers(Pair1).TextHandle)
                    delete(MovingPairLayers(Pair1).TextHandle)
                end
            end
            MovingPairLayers=[];
        end
        set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Add Layers
        MovingPairLayers=[];
        if Moving_Pair_On

            count=0;
            figure(SelectionFig)
            hold on 
            axes(AX2)
            hold on
            for Pair1=1:length(cpstruct.ids)
                if cpstruct.inputPoints(Pair1,1)>=Moving_XLims(1)&&...
                        cpstruct.inputPoints(Pair1,1)<=Moving_XLims(2)&&...
                        cpstruct.inputPoints(Pair1,2)>=Moving_YLims(1)&&...
                        cpstruct.inputPoints(Pair1,2)<=Moving_YLims(2)
                    if cpstruct.Flagged(Pair1)
                        if Pair==Pair1
                            count=count+1;
                            hold on;
                            MovingPairLayers(count).MarkerHandle=Plot_Circle2(cpstruct.inputPoints(Pair1,1),...
                                cpstruct.inputPoints(Pair1,2),...
                                Moving_Circle_Radius,'-',Moving_LineWidth+2,Pair_Overlay_Current_Flagged_Color);
                            if NumbersOn
                                MovingPairLayers(count).TextHandle=text(cpstruct.inputPoints(Pair1,1)+NumberOffset_Zoom,...
                                    cpstruct.inputPoints(Pair1,2),num2str(Pair1),...
                                    'color',Pair_Overlay_Current_Flagged_Color,'FontSize',PairFontSize_Zoom,'FontWeight','bold','horizontalalignment','center');
                            else
                                MovingPairLayers(count).TextHandle=[];
                            end
                        else
                            count=count+1;
                            hold on;
                            MovingPairLayers(count).MarkerHandle=Plot_Circle2(cpstruct.inputPoints(Pair1,1),...
                                cpstruct.inputPoints(Pair1,2),...
                                Moving_Circle_Radius,'-',Moving_LineWidth,Pair_Overlay_Flagged_Color);
                            if NumbersOn
                                MovingPairLayers(count).TextHandle=text(cpstruct.inputPoints(Pair1,1)+NumberOffset_Zoom,...
                                    cpstruct.inputPoints(Pair1,2),num2str(Pair1),...
                                    'color',Pair_Overlay_Flagged_Color,'FontSize',PairFontSize_Zoom,'horizontalalignment','center');
                            else
                                MovingPairLayers(count).TextHandle=[];
                            end
                        end
                    else
                        if Pair==Pair1
                            count=count+1;
                            hold on;
                            MovingPairLayers(count).MarkerHandle=Plot_Circle2(cpstruct.inputPoints(Pair1,1),...
                                cpstruct.inputPoints(Pair1,2),...
                                Moving_Circle_Radius,'-',Moving_LineWidth+2,Pair_Overlay_Current_Color);
                            if NumbersOn
                                MovingPairLayers(count).TextHandle=text(cpstruct.inputPoints(Pair1,1)+NumberOffset_Zoom,...
                                    cpstruct.inputPoints(Pair1,2),num2str(Pair1),...
                                    'color',Pair_Overlay_Current_Color,'FontSize',PairFontSize_Zoom,'FontWeight','bold','horizontalalignment','center');
                            else
                                MovingPairLayers(count).TextHandle=[];
                            end
                        else
                            count=count+1;
                            hold on;
                            MovingPairLayers(count).MarkerHandle=Plot_Circle2(cpstruct.inputPoints(Pair1,1),...
                                cpstruct.inputPoints(Pair1,2),...
                                Moving_Circle_Radius,'-',Moving_LineWidth,Pair_Overlay_Color);
                            if NumbersOn
                                MovingPairLayers(count).TextHandle=text(cpstruct.inputPoints(Pair1,1)+NumberOffset_Zoom,...
                                    cpstruct.inputPoints(Pair1,2),num2str(Pair1),...
                                    'color',Pair_Overlay_Color,'FontSize',PairFontSize_Zoom,'horizontalalignment','center');
                            else
                                MovingPairLayers(count).TextHandle=[];
                            end
                        end
                    end
                end
            end
            set(Status_TR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_TL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_BR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_BL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
        end
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function PlotFixed_Markers
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);

        hold on
        %Remove layers
        if ~isempty(FixedMarkerLayers)
            for Marker1=1:length(FixedMarkerLayers)
                if ~isempty(FixedMarkerLayers(Marker1).MarkerHandle)
                    delete(FixedMarkerLayers(Marker1).MarkerHandle)
                end
                if ~isempty(FixedMarkerLayers(Marker1).TextHandle)
                    delete(FixedMarkerLayers(Marker1).TextHandle)
                end
            end
            FixedMarkerLayers=[];
        end
        set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Add Layers
        FixedMarkerLayers=[];
        if Fixed_Marker_On
            count=0;
            figure(SelectionFig)
            hold on 
            axes(AX1)
            hold on
            FixedMarkerLayers=[];
            for FixedMarker=1:length(Fixed_Markers)
                for m=1:length(Fixed_Markers(FixedMarker).MarkerCoords)
                    count=count+1;
                    hold on
                    FixedMarkerLayers(count).MarkerHandle=plot(Fixed_Markers(FixedMarker).MarkerCoords(m,2),...
                        Fixed_Markers(FixedMarker).MarkerCoords(m,1),...
                        Fixed_Markers(FixedMarker).MarkerStyle,'color',Fixed_Markers(FixedMarker).Color,...
                        'markerSize',Fixed_Markers(FixedMarker).MarkerSize);
                    FixedMarkerLayers(count).TextHandle=[];
                end
            end
            set(Status_TR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_TL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_BR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_BL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
        end
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function PlotMoving_Markers
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);

        hold on
        %Remove layers
        if ~isempty(MovingMarkerLayers)
            for Marker1=1:length(MovingMarkerLayers)
                if ~isempty(MovingMarkerLayers(Marker1).MarkerHandle)
                    delete(MovingMarkerLayers(Marker1).MarkerHandle)
                end
                if ~isempty(MovingMarkerLayers(Marker1).TextHandle)
                    delete(MovingMarkerLayers(Marker1).TextHandle)
                end
            end
            MovingMarkerLayers=[];
        end
        set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Add Layers
        MovingMarkerLayers=[];
        if Moving_Marker_On
            count=0;
            figure(SelectionFig)
            hold on 
            axes(AX2)
            hold on
            MovingMarkerLayers=[];
            for MovingMarker=1:length(Moving_Markers)
                for m=1:length(Moving_Markers(MovingMarker).MarkerCoords)
                    count=count+1;
                    hold on
                    MovingMarkerLayers(count).MarkerHandle=plot(Moving_Markers(MovingMarker).MarkerCoords(m,2),...
                        Moving_Markers(MovingMarker).MarkerCoords(m,1),...
                        Moving_Markers(MovingMarker).MarkerStyle,'color',Moving_Markers(MovingMarker).Color,...
                        'markerSize',Moving_Markers(MovingMarker).MarkerSize);
                    MovingMarkerLayers(count).TextHandle=[];
                end
            end
            set(Status_TR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_TL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_BR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_BL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
        end
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ZoomIn(src,eventdata,arg1)
        figure(SelectionFig)
        %Select Zoom Fixed
        ZoomOn=1;
        cont=1;
        Moving_XLims1=Moving_XLims;
        Moving_YLims1=Moving_YLims;
        Fixed_XLims1=Fixed_XLims;
        Fixed_YLims1=Fixed_YLims;
        while cont
            axes(AX2)
            hold on;txt2=text(Moving_XLims1(1)+20,Moving_YLims1(1)+20,'NOT HERE','color','r','fontsize',20);
            hold on;txt2a=text(Moving_XLims1(1)+20,Moving_YLims1(1)+Moving_Zoom_BoxSize_px/2,'NOT HERE','color','r','fontsize',20);
            hold on;txt2b=text(Moving_XLims1(1)+20,Moving_YLims1(2)-40,'NOT HERE','color','r','fontsize',20);
            hold on;Px1=plot([Moving_XLims1(1),Moving_XLims1(2)],[Moving_YLims1(2),Moving_YLims1(1)],'-','LineWidth',3,'color','r');
            hold on;Px2=plot([Moving_XLims1(1),Moving_XLims1(2)],[Moving_YLims1(1),Moving_YLims1(2)],'-','LineWidth',3,'color','r');
            axes(AX1)
            txt1=text(50,50,'Select Zoom Center Here','color',Pair_Overlay_Color,'fontsize',20);
            Fixed_Zoom_Coord=ginput_w(1);
            Fixed_Zoom_Region=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,...
                Fixed_Zoom_BoxSize_px,Fixed_Zoom_BoxSize_px];
            axes(AX2)
            delete(txt2);delete(txt2a);delete(txt2b);delete(Px1);delete(Px2)
            axes(AX1)
            hold on
            [P1,P2,P3,P4,~]=PlotBox2(Fixed_Zoom_Region,'-',Pair_Overlay_Color,2,[],[],[]);
            delete(txt1)
            txt1=text(50,50,'<ENTER> to accept','color',Pair_Overlay_Color,'fontsize',20);
            cont=[];
            %cont=InputWithVerification('<ENTER> to Accept Zoom Region: ',{[],[1]},0);
            if cont
                delete(txt1);delete(P1);delete(P2);delete(P3);delete(P4);
                Fixed_XLims=[0,size(Fixed_Image,2)];
                Fixed_YLims=[0,size(Fixed_Image,1)];
            else
                delete(txt1);
                Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
                Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            end            
        end
        %Select Zoom Moving
        cont=1;
        while cont
            axes(AX1)
            hold on;txt2=text(Fixed_XLims1(1)+20,Fixed_YLims1(1)+20,'NOT HERE','color','r','fontsize',20);
            hold on;txt2a=text(Fixed_XLims1(1)+20,Fixed_YLims1(1)+Fixed_Zoom_BoxSize_px/2,'NOT HERE','color','r','fontsize',20);
            hold on;txt2b=text(Fixed_XLims1(1)+20,Fixed_YLims1(2)-40,'NOT HERE','color','r','fontsize',20);
            hold on;Px1=plot([Fixed_XLims1(1),Fixed_XLims1(2)],[Fixed_YLims1(2),Fixed_YLims1(1)],'-','LineWidth',3,'color','r');
            hold on;Px2=plot([Fixed_XLims1(1),Fixed_XLims1(2)],[Fixed_YLims1(1),Fixed_YLims1(2)],'-','LineWidth',3,'color','r');
            axes(AX2)
            txt1=text(50,50,'Select Zoom Center Here','color',Pair_Overlay_Color,'fontsize',20);
            Moving_Zoom_Coord=ginput_w(1);
            Moving_Zoom_Region=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,...
                Moving_Zoom_BoxSize_px,Moving_Zoom_BoxSize_px];
            hold on
            axes(AX1)
            delete(txt2);delete(txt2a);delete(txt2b);delete(Px1);delete(Px2)
            axes(AX2)
            [P1a,P2a,P3a,P4a,~]=PlotBox2(Moving_Zoom_Region,'-',Pair_Overlay_Color,2,[],[],[]);
            delete(txt1)
            txt1=text(50,50,'<ENTER> to accept','color',Pair_Overlay_Color,'fontsize',20);
            cont=[];
            %cont=InputWithVerification('<ENTER> to Accept Zoom Region: ',{[],[1]},0);
            if cont
                delete(txt1);delete(P1a);delete(P2a);delete(P3a);delete(P4a);
                Moving_XLims=[0,size(Moving_Image,2)];
                Moving_YLims=[0,size(Moving_Image,1)];
            else
                delete(txt1);
                Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
                Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            end            
        end    
        %Zoom
        axes(AX1)
        delete(P1);delete(P2);delete(P3);delete(P4);
        xlim(Fixed_XLims),ylim(Fixed_YLims)
        axes(AX2)
        delete(P1a);delete(P2a);delete(P3a);delete(P4a);
        clear Moving_XLims1 Moving_YLims1 Fixed_XLims1 Fixed_YLims1
        xlim(Moving_XLims),ylim(Moving_YLims)
        set(Fixed_X_Scroll,'value',Fixed_Zoom_Coord(1)/size(Fixed_Image,2))
        set(Fixed_Y_Scroll,'value',1-Fixed_Zoom_Coord(2)/size(Fixed_Image,1))
        set(Moving_X_Scroll,'value',Moving_Zoom_Coord(1)/size(Moving_Image,2))
        set(Moving_Y_Scroll,'value',1-Moving_Zoom_Coord(2)/size(Moving_Image,1))
        %NumbersOn=1;
        set(DisplayNumbersButton,'value',NumbersOn);
        if Fixed_Marker_On_Default_Zoom
            if ~Fixed_Marker_On
                Fixed_Marker_On=1;
            end
        end
        PlotFixedPairs;PlotMovingPairs;
        PlotFixed_Markers;PlotMoving_Markers
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ZoomOut(src,eventdata,arg1)
        figure(SelectionFig)
        %UN-Zoom
        ZoomOn=0;
        Fixed_Zoom_Coord=[size(Fixed_Image,2)/2,size(Fixed_Image,1)/2];
        Moving_Zoom_Coord=[size(Moving_Image,2)/2,size(Moving_Image,1)/2];
        Fixed_XLims=[0,size(Fixed_Image,2)];
        Fixed_YLims=[0,size(Fixed_Image,1)];
        Moving_XLims=[0,size(Moving_Image,2)];
        Moving_YLims=[0,size(Moving_Image,1)];               
        UpdateImage(Fixed_Image,Moving_Image)
        axes(AX1)
        xlim(Fixed_XLims),ylim(Fixed_YLims)
        axes(AX2)
        xlim(Moving_XLims),ylim(Moving_YLims)
        set(Fixed_X_Scroll,'value',Fixed_Zoom_Coord(1)/size(Fixed_Image,2))
        set(Fixed_Y_Scroll,'value',1-Fixed_Zoom_Coord(2)/size(Fixed_Image,1))
        set(Moving_X_Scroll,'value',Moving_Zoom_Coord(1)/size(Moving_Image,2))
        set(Moving_Y_Scroll,'value',1-Moving_Zoom_Coord(2)/size(Moving_Image,1))
        %NumbersOn=0;
        set(DisplayNumbersButton,'value',NumbersOn);
        if Fixed_Marker_On_Default_Zoom
            Fixed_Marker_On=0;
        end
        PlotFixedPairs;PlotMovingPairs;
        PlotFixed_Markers;PlotMoving_Markers
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Zoom Slider
    function ZoomSize_Slider_callback(src,eventdata,arg1)
        figure(SelectionFig)
        Fixed_Zoom_BoxSize_um = get(src,'Value')*Max_Zoom_BoxSize_um;
        Moving_Zoom_BoxSize_um = Fixed_Zoom_BoxSize_um;
        set(ZoomSize_Text,'String',['Zoom Box Size: ',num2str(Fixed_Zoom_BoxSize_um),'um']);
        Fixed_Zoom_BoxSize_px=ceil((Fixed_Zoom_BoxSize_um*1000)/Fixed_PixelSize_nm);
        Moving_Zoom_BoxSize_px=ceil((Moving_Zoom_BoxSize_um*1000)/Moving_PixelSize_nm);
        Fixed_Scroll_Interval_px=ceil((Fixed_Scroll_Interval_um*1000)/Fixed_PixelSize_nm);
        Moving_Scroll_Interval_px=ceil((Moving_Scroll_Interval_um*1000)/Moving_PixelSize_nm);
        if ZoomOn
            Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
            Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
            Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            set(Fixed_X_Scroll,'value',Fixed_Zoom_Coord(1)/size(Fixed_Image,2))
            set(Fixed_Y_Scroll,'value',1-Fixed_Zoom_Coord(2)/size(Fixed_Image,1))
            set(Moving_X_Scroll,'value',Moving_Zoom_Coord(1)/size(Moving_Image,2))
            set(Moving_Y_Scroll,'value',1-Moving_Zoom_Coord(2)/size(Moving_Image,1))
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        end
        set(DisplayNumbersButton,'value',NumbersOn);
        PlotFixedPairs;PlotMovingPairs;
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DisplayFixedMarker(src,eventdata,arg1)
        figure(SelectionFig)
        Fixed_Marker_On = get(src,'Value'); 
        PlotFixed_Markers;
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DisplayFixed_Pair(src,eventdata,arg1)
        figure(SelectionFig)
        Fixed_Pair_On = get(src,'Value'); 
        PlotFixedPairs;
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DisplayFixedBorders(src,eventdata,arg1)
        figure(SelectionFig)
        Fixed_BorderOn = get(src,'Value'); 
        UpdateImage(Fixed_Image,Moving_Image)
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DisplayMoving_Marker(src,eventdata,arg1)
        figure(SelectionFig)
        Moving_Marker_On = get(src,'Value'); 
        PlotMoving_Markers;
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DisplayMoving_Pair(src,eventdata,arg1)
        figure(SelectionFig)
        Moving_Pair_On = get(src,'Value'); 
        PlotMovingPairs;
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DisplayMovingBorders(src,eventdata,arg1)
        figure(SelectionFig)
       Moving_BorderOn = get(src,'Value'); 
       UpdateImage(Fixed_Image,Moving_Image)
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DisplayNumbers(src,eventdata,arg1)
       figure(SelectionFig)
       NumbersOn = get(src,'Value'); 
       PlotFixedPairs;PlotMovingPairs;
       figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Select_Fixed_Image(source,event)
        figure(SelectionFig)
        Fixed_DataType = source.Value;
        set(Fixed_Image_Selection,'Value',Fixed_DataType)
        Fixed_Image=Fixed_Images{Fixed_DataType}.Image;
        UpdateImage(Fixed_Image,Moving_Image)
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Select_Moving_Image(source,event)
        figure(SelectionFig)
        Moving_DataType = source.Value;
        set(Moving_Image_Selection,'Value',Moving_DataType)
        Moving_Image=Moving_Images{Moving_DataType}.Image;
        UpdateImage(Fixed_Image,Moving_Image)
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Fixed Contrast Settings
    function Fixed_Contrast_Slider_callback(src,eventdata,arg1)
        figure(SelectionFig)
        Fixed_HighContrast = get(src,'Value');
        Fixed_HighContrast=round(Fixed_HighContrast*100)/100;
        if Fixed_HighContrast==0
            Fixed_HighContrast=0.01;
        elseif Fixed_HighContrast==1
            Fixed_HighContrast=0.99;
        end
        set(Fixed_Contrast_Text,'String',['Fixed Cont: ',num2str(Fixed_HighContrast*100),'%']);
        UpdateImage(Fixed_Image,Moving_Image)
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Fixed RGB Balance
    function FixedColorBalance(src,eventdata,arg1)
        figure(SelectionFig)
        Fixed_R=(str2num(get(Fixed_R_Control,'String')));
        Fixed_G=(str2num(get(Fixed_G_Control,'String')));
        Fixed_B=(str2num(get(Fixed_B_Control,'String')));
        if Fixed_R>1
            warning('Max R = 1')
            Fixed_R=1;
        end
        if Fixed_G>1
            warning('Max G = 1')
            Fixed_G=1;
        end
        if Fixed_B>1
            warning('Max B = 1')
            Fixed_B=1;
        end
        if Fixed_R<0
            warning('Min R = 0')
            Fixed_R=0;
        end
        if Fixed_G<0
            warning('Min G = 0')
            Fixed_G=0;
        end
        if Fixed_B<0
            warning('Min B = 0')
            Fixed_B=0;
        end
        UpdateImage(Fixed_Image,Moving_Image)
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Moving Contrast Settings
    function Moving_Contrast_Slider_callback(src,eventdata,arg1)
        figure(SelectionFig)
        Moving_HighContrast = get(src,'Value');
        Moving_HighContrast=round(Moving_HighContrast*100)/100;
        if Moving_HighContrast==0
            Moving_HighContrast=0.01;
        elseif Moving_HighContrast==1
            Moving_HighContrast=0.99;
        end
        set(Moving_Contrast_Text,'String',['Fixed Cont: ',num2str(Moving_HighContrast*100),'%']);
        UpdateImage(Fixed_Image,Moving_Image)
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Moving RGB Balance
    function MovingColorBalance(src,eventdata,arg1)
        figure(SelectionFig)
        Moving_R=(str2num(get(Moving_R_Control,'String')));
        Moving_G=(str2num(get(Moving_G_Control,'String')));
        Moving_B=(str2num(get(Moving_B_Control,'String')));
        if Moving_R>1
            warning('Max R = 1')
            Moving_R=1;
        end
        if Moving_G>1
            warning('Max G = 1')
            Moving_G=1;
        end
        if Moving_B>1
            warning('Max B = 1')
            Moving_B=1;
        end
        if Moving_R<0
            warning('Min R = 0')
            Moving_R=0;
        end
        if Moving_G<0
            warning('Min G = 0')
            Moving_G=0;
        end
        if Moving_B<0
            warning('Min B = 0')
            Moving_B=0;
        end
        UpdateImage(Fixed_Image,Moving_Image)
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Position Adjustments
    function Fixed_X_Scroll_callback(src,eventdata,arg1)
        figure(SelectionFig)
        if ZoomOn
            TempValue = get(Fixed_X_Scroll,'Value');
            %TempValue= 1 - TempValue;
            Fixed_Zoom_Coord(1) = TempValue*size(Fixed_Image,2);
            Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
            Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            %set(Fixed_X_Scroll,'Value',Fixed_Zoom_Coord(1)/size(Fixed_Image,2))
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        else
            set(Fixed_X_Scroll,'value',Fixed_Zoom_Coord(1)/size(Fixed_Image,2))
        end
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Fixed_Y_Scroll_callback(src,eventdata,arg1)
        figure(SelectionFig)
        if ZoomOn
            TempValue = get(Fixed_Y_Scroll,'Value');
            TempValue= 1 - TempValue;
            Fixed_Zoom_Coord(2) = TempValue*size(Fixed_Image,1);
            Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
            Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            %set(Fixed_Y_Scroll,'Value',Fixed_Zoom_Coord(2)/size(Fixed_Image,1))
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        else
            set(Fixed_Y_Scroll,'value',Fixed_Zoom_Coord(2)/size(Fixed_Image,1))
        end
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Moving_X_Scroll_callback(src,eventdata,arg1)
        figure(SelectionFig)
        if ZoomOn
            TempValue = get(Moving_X_Scroll,'Value');
            %TempValue= 1 - TempValue;
            Moving_Zoom_Coord(1) = TempValue*size(Moving_Image,2);
            Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
            Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            %set(Moving_X_Scroll,'Value',Moving_Zoom_Coord(1)/size(Moving_Image,2))
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        else
            set(Moving_X_Scroll,'value',Moving_Zoom_Coord(1)/size(Moving_Image,2))
        end
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Moving_Y_Scroll_callback(src,eventdata,arg1)
        figure(SelectionFig)
        if ZoomOn
            TempValue = get(Moving_Y_Scroll,'Value');
            TempValue= 1 - TempValue;
            Moving_Zoom_Coord(2) = TempValue*size(Moving_Image,1);
            Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
            Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            %set(Moving_Y_Scroll,'Value',Moving_Zoom_Coord(2)/size(Moving_Image,1))
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        else
            set(Moving_Y_Scroll,'value',Moving_Zoom_Coord(2)/size(Moving_Image,1))
        end
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Pair Navigation Controls
    function Pair_Slider_callback(src,eventdata,arg1)
        figure(SelectionFig)
        if isempty(Selecting)||Selecting
            fprintf('\n')
            warning('EXIT SELECTION MODE!!!!')
            set(PairSlider,'Value',Pair/length(cpstruct.ids))
        else
            Pair = round(get(src,'Value')*length(cpstruct.ids));
            if Pair<1
                fprintf('\n')
                warning('Unable to go to that pair...')
                Pair=1;
                Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
                Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
                Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
                Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
                Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
                Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
                fprintf(['Current Pair: ',num2str(Pair)])
                set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
                PlotFixedPairs;PlotMovingPairs;
                axes(AX1)
                xlim(Fixed_XLims),ylim(Fixed_YLims)
                axes(AX2)
                xlim(Moving_XLims),ylim(Moving_YLims)
            elseif Pair>length(cpstruct.ids)
                fprintf('\n')
                warning('Unable to go to that pair...')
                Pair=length(cpstruct.ids);
                Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
                Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
                Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
                Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
                Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
                Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
                fprintf(['Current Pair: ',num2str(Pair)])
                set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
                PlotFixedPairs;PlotMovingPairs;
                axes(AX1)
                xlim(Fixed_XLims),ylim(Fixed_YLims)
                axes(AX2)
                xlim(Moving_XLims),ylim(Moving_YLims)
            else
                Pair=round(Pair);
                fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>'),fprintf(num2str(Pair));fprintf('\n')
                Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
                Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
                Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
                Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
                Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
                Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
                fprintf(['Current Pair: ',num2str(Pair)])
                set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
                PlotFixedPairs;PlotMovingPairs;
                axes(AX1)
                xlim(Fixed_XLims),ylim(Fixed_YLims)
                axes(AX2)
                xlim(Moving_XLims),ylim(Moving_YLims)
            end
        end
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function PairAdvance
        figure(SelectionFig)
        if Pair<length(cpstruct.ids)
            Pair=Pair+1;
            set(PairSlider,'Value',Pair/length(cpstruct.ids))
            fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>'),fprintf(num2str(Pair));fprintf('\n')
            Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
            Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
            Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
            Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
            Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            fprintf(['Current Pair: ',num2str(Pair)])
            set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
            PlotFixedPairs;PlotMovingPairs;
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        else
            fprintf('\n')
            warning('Unable to move to NEXT Pair')
            set(PairSlider,'Value',Pair/length(cpstruct.ids))
            Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
            Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
            Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
            Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
            Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            fprintf(['Current Pair: ',num2str(Pair)])
            set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
            PlotFixedPairs;PlotMovingPairs;
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        end
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function PairRetreat
        figure(SelectionFig)
        if Pair>1
            Pair=Pair-1;
            set(PairSlider,'Value',Pair/length(cpstruct.ids))
            fprintf('<');pause(0.02);fprintf('<');pause(0.02);fprintf('<');pause(0.02);fprintf('<'),fprintf(num2str(Pair));fprintf('\n')
            Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
            Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
            Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
            Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
            Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            fprintf(['Current Pair: ',num2str(Pair)])
            set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
            PlotFixedPairs;PlotMovingPairs;
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        else
            fprintf('\n')
            warning('Unable to move to PREVIOUS Pair')
            set(PairSlider,'Value',Pair/length(cpstruct.ids))
            Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
            Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
            Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
            Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
            Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            fprintf(['Current Pair: ',num2str(Pair)])
            set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
            PlotFixedPairs;PlotMovingPairs;
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        end
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Jump2PairNum(src,eventdata,arg1)
        figure(SelectionFig)
        Pair1=round(str2num(get(PairControl,'String')));
        if Pair1<=length(cpstruct.ids)
            Pair=Pair1;
            set(PairSlider,'Value',Pair/length(cpstruct.ids))
            fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>'),fprintf(num2str(Pair));fprintf('\n')
            Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
            Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
            Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
            Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
            Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            fprintf(['Current Pair: ',num2str(Pair)])
            set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
            PlotFixedPairs;PlotMovingPairs;
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        else
            fprintf('\n')
            warning('Unable to move to that Pair!')
            set(PairSlider,'Value',Pair/length(cpstruct.ids))
            Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
            Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
            Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
            Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
            Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            fprintf(['Current Pair: ',num2str(Pair)])
            set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
            PlotFixedPairs;PlotMovingPairs;
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        end
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Jump2Pair(src,eventdata,arg1)
        figure(SelectionFig)
        axes(AX2)
        hold on;txt2=text(Moving_XLims(1)+20,Moving_YLims(1)+20,'NOT HERE','color','r','fontsize',20);
        hold on;txt2a=text(Moving_XLims(1)+20,Moving_YLims(1)+Moving_Zoom_BoxSize_px/2,'NOT HERE','color','r','fontsize',20);
        hold on;txt2b=text(Moving_XLims(1)+20,Moving_YLims(2)-40,'NOT HERE','color','r','fontsize',20);
        hold on;Px1=plot([Moving_XLims(1),Moving_XLims(2)],[Moving_YLims(2),Moving_YLims(1)],'-','LineWidth',3,'color','r');
        hold on;Px2=plot([Moving_XLims(1),Moving_XLims(2)],[Moving_YLims(1),Moving_YLims(2)],'-','LineWidth',3,'color','r');
        axes(AX1)
        FindCoord=ginput_w(1);
        axes(AX2)
        delete(txt2);delete(txt2a);delete(txt2b)
        delete(Px1);delete(Px2)
        TempDistances=[];
        for Pair2=1:size(cpstruct.inputPoints,1)
            TempDistances(Pair2)=...
                sqrt((cpstruct.basePoints(Pair2,1)-FindCoord(1))^2+(cpstruct.basePoints(Pair2,2)-FindCoord(2))^2);
        end
        [~,Pair] = min(TempDistances);
        if Pair<=length(cpstruct.ids)
            set(PairSlider,'Value',Pair/length(cpstruct.ids))
            fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>'),fprintf(num2str(Pair));fprintf('\n')
            Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
            Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
            Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
            Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
            Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            fprintf(['Current Pair: ',num2str(Pair)])
            set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
            PlotFixedPairs;PlotMovingPairs;
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        else
            fprintf('\n')
            warning('Unable to move to that Pair!')
            set(PairSlider,'Value',Pair/length(cpstruct.ids))
            Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
            Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
            Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
            Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
            Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            fprintf(['Current Pair: ',num2str(Pair)])
            set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
            PlotFixedPairs;PlotMovingPairs;
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        end
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Undo(src,eventdata,arg1)
        FoundUndo=0;
        UndoIndex=length(UndoBuffer);
        while ~FoundUndo&&UndoIndex>0
            if ~isempty(UndoBuffer(UndoIndex).cpstruct)
                FoundUndo=1;
            else
                FoundUndo=0;
                UndoIndex=UndoIndex-1;
            end
        end
        if FoundUndo    
            warning('Undoing!')
            cpstruct=UndoBuffer(UndoIndex).cpstruct;
            Pair=UndoBuffer(UndoIndex).CurrentPair;
            UndoBuffer(UndoIndex).cpstruct=[];
            UndoBuffer(UndoIndex).CurrentPair=[];
            if Pair<=length(cpstruct.ids)
                set(PairSlider,'Value',Pair/length(cpstruct.ids))
                fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>'),fprintf(num2str(Pair));fprintf('\n')
                Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
                Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
                Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
                Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
                Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
                Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
                fprintf(['Current Pair: ',num2str(Pair)])
                set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
                PlotFixedPairs;PlotMovingPairs;
                axes(AX1)
                xlim(Fixed_XLims),ylim(Fixed_YLims)
                axes(AX2)
                xlim(Moving_XLims),ylim(Moving_YLims)
            else
                fprintf('\n')
                warning('Unable to move to that Pair!')
                set(PairSlider,'Value',Pair/length(cpstruct.ids))
                Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
                Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
                Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
                Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
                Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
                Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
                fprintf(['Current Pair: ',num2str(Pair)])
                set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
                PlotFixedPairs;PlotMovingPairs;
                axes(AX1)
                xlim(Fixed_XLims),ylim(Fixed_YLims)
                axes(AX2)
                xlim(Moving_XLims),ylim(Moving_YLims)
            end
            UpdatePairTracker
            UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
        else
            warning('No available Undo!')
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function FlagPairs(src,eventdata,arg1)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Shuffeling UndoBuffer
        for u1=1:length(UndoBuffer)-1
            UndoBuffer(u1).cpstruct=UndoBuffer(u1+1).cpstruct;
            UndoBuffer(u1).CurrentPair=UndoBuffer(u1+1).CurrentPair;
        end
        %Adding to Undo Buffer     
        UndoBuffer(length(UndoBuffer)).cpstruct=cpstruct;
        UndoBuffer(length(UndoBuffer)).CurrentPair=Pair;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cpstruct.Flagged(Pair)=~cpstruct.Flagged(Pair);
        figure(SelectionFig)
        set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
        PlotFixedPairs;PlotMovingPairs;
        axes(AX1)
        xlim(Fixed_XLims),ylim(Fixed_YLims)
        axes(AX2)
        xlim(Moving_XLims),ylim(Moving_YLims)
        
        %UpdatePairTracker
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function AddPairs(src,eventdata,arg1)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Shuffeling UndoBuffer
        for u1=1:length(UndoBuffer)-1
            UndoBuffer(u1).cpstruct=UndoBuffer(u1+1).cpstruct;
            UndoBuffer(u1).CurrentPair=UndoBuffer(u1+1).CurrentPair;
        end
        %Adding to Undo Buffer     
        UndoBuffer(length(UndoBuffer)).cpstruct=cpstruct;
        UndoBuffer(length(UndoBuffer)).CurrentPair=Pair;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Paring=1;
        figure(SelectionFig)
        Selecting=1;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','r','String',['Selecting: ON']);set(SelectionStatus_TL,'BackgroundColor','r','String',['Selecting: ON']);
        ExitSelection=0;
        while Selecting
            cont=1;
            while cont
                axes(AX1)
                hold on;txt1=text(Fixed_XLims(1)+20,Fixed_YLims(1)+20,'Select Fixed Position Center Here','color','g','fontsize',20);
                hold on;txt1a=text(Fixed_XLims(1)+20,Fixed_YLims(2)-40,'Select Fixed Position Center Here','color','g','fontsize',20);
                axes(AX2)
                hold on;txt2=text(Moving_XLims(1)+20,Moving_YLims(1)+20,'NOT HERE','color','r','fontsize',20);
                hold on;txt2a=text(Moving_XLims(1)+20,Moving_YLims(1)+Moving_Zoom_BoxSize_px/2,'NOT HERE','color','r','fontsize',20);
                hold on;txt2b=text(Moving_XLims(1)+20,Moving_YLims(2)-40,'NOT HERE','color','r','fontsize',20);
                hold on;Px1=plot([Moving_XLims(1),Moving_XLims(2)],[Moving_YLims(2),Moving_YLims(1)],'-','LineWidth',3,'color','r');
                hold on;Px2=plot([Moving_XLims(1),Moving_XLims(2)],[Moving_YLims(1),Moving_YLims(2)],'-','LineWidth',3,'color','r');
                axes(AX1)
                Temp_Fixed_Coords=[];
                while isempty(Temp_Fixed_Coords)
                    Temp_Fixed_Coords=ginput_w(1);
                    if isempty(Temp_Fixed_Coords)
                        warning('Must Make Selection!!')
                    end
                end
                clear TempCoordList
                delete(txt1);delete(txt1a);delete(txt2);delete(txt2a);delete(txt2b);delete(Px1);delete(Px2)
                hold on;P1=plot(Temp_Fixed_Coords(1),Temp_Fixed_Coords(2),PairMarker{1},'color',Pair_Overlay_Color,'MarkerSize',PairMarkerSize_Zoom);
                hold on;P1a=plot(Temp_Fixed_Coords(1),Temp_Fixed_Coords(2),PairMarker{2},'color',Pair_Overlay_Color,'MarkerSize',PairMarkerSize_Zoom);
                axes(AX2)
                hold on;txt1=text(Moving_XLims(1)+20,Moving_YLims(1)+20,'Select Moving Position Center Here','color','g','fontsize',20);
                hold on;txt1a=text(Moving_XLims(1)+20,Moving_YLims(2)-40,'Select Moving Position Center Here','color','g','fontsize',20);
                axes(AX1)
                hold on;txt2=text(Fixed_XLims(1)+20,Fixed_YLims(1)+20,'NOT HERE','color','r','fontsize',20);
                hold on;txt2a=text(Fixed_XLims(1)+20,Fixed_YLims(1)+Fixed_Zoom_BoxSize_px/2,'NOT HERE','color','r','fontsize',20);
                hold on;txt2b=text(Fixed_XLims(1)+20,Fixed_YLims(2)-40,'NOT HERE','color','r','fontsize',20);
                hold on;Px1=plot([Fixed_XLims(1),Fixed_XLims(2)],[Fixed_YLims(2),Fixed_YLims(1)],'-','LineWidth',3,'color','r');
                hold on;Px2=plot([Fixed_XLims(1),Fixed_XLims(2)],[Fixed_YLims(1),Fixed_YLims(2)],'-','LineWidth',3,'color','r');
                axes(AX2)
                Temp_Moving_Coords=[];
                while isempty(Temp_Moving_Coords)
                    Temp_Moving_Coords=ginput_w(1);
                    if isempty(Temp_Moving_Coords)
                        warning('Must Make Selection!!')
                    end
                end
                delete(txt1);delete(txt1a);delete(txt2);delete(txt2a);delete(txt2b);delete(Px1);delete(Px2)
                hold on;
                P2=plot(Temp_Moving_Coords(1),Temp_Moving_Coords(2),PairMarker{1},'color',Pair_Overlay_Color,'MarkerSize',PairMarkerSize_Zoom);
                P2a=plot(Temp_Moving_Coords(1),Temp_Moving_Coords(2),PairMarker{2},'color',Pair_Overlay_Color,'MarkerSize',PairMarkerSize_Zoom);
%                 P2=plot(Temp_Moving_Coords(1,1),Temp_Moving_Coords(1,2),PairMarker{1},'color','r','MarkerSize',PairMarkerSize_Zoom);
%                 P2a=plot(Temp_Moving_Coords(1,1),Temp_Moving_Coords(1,2),PairMarker{2},'color','r','MarkerSize',PairMarkerSize_Zoom);
                axes(AX1)
                txt1=text(Fixed_XLims(1)+20,Fixed_YLims(1)+20,'<ENTER> to Accept Pair <1> to Delete','color',Pair_Overlay_Color,'fontsize',20);
                txt1a=text(Fixed_XLims(1)+20,Fixed_YLims(2)-40,'<ENTER> to Accept Pair <1> to Delete','color',Pair_Overlay_Color,'fontsize',20);
                axes(AX2)
                txt2=text(Moving_XLims(1)+20,Moving_YLims(1)+20,'<ENTER> to Accept Pair <1> to Delete','color',Pair_Overlay_Color,'fontsize',20);
                txt2a=text(Moving_XLims(1)+20,Moving_YLims(2)-40,'<ENTER> to Accept Pair <1> to Delete','color',Pair_Overlay_Color,'fontsize',20);

                cont=InputWithVerification('<ENTER> to Accept Pair or <1> to clear selection: ',{[],[1]},0);
                axes(AX1);delete(txt1);delete(txt1a);axes(AX2);delete(txt2);delete(txt2a);
                    axes(AX1);delete(P1),delete(P1a)
                    axes(AX2);delete(P2),delete(P2a)
                if cont
                    clear Temp_Fixed_Coords Temp_Moving_Coords
                    axes(AX1)
                    txt3=text(Fixed_XLims(1)+10,Fixed_YLims(1)+Fixed_Zoom_BoxSize_px/2,'<ENTER> to Add Another Pair or <1> to EXIT','color',Pair_Overlay_Color,'fontsize',20);
                    axes(AX2)
                    txt4=text(Moving_XLims(1)+10,Moving_YLims(1)+Moving_Zoom_BoxSize_px/2,'<ENTER> to Add Another Pair or <1> to EXIT','color',Pair_Overlay_Color,'fontsize',20);
                    ExitSelection=InputWithVerification('<ENTER> to Add Another Pair or <1> to EXIT selection mode: ',{[],[1]},0);
                    if ExitSelection
                        cont=0;
                    end
                    axes(AX1);delete(txt3);
                    axes(AX2);delete(txt4);
                else
                    set(Status_TR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
                    set(Status_TL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
                    set(Status_BR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
                    set(Status_BL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
                    %IMPORTANT ADDING TO NEW STRUCTURE!!
                    Pair=length(cpstruct.ids);
                    Pair=Pair+1;
                    cpstruct.inputPoints(Pair,:)=Temp_Moving_Coords;
                    cpstruct.basePoints(Pair,:)=Temp_Fixed_Coords;
                    cpstruct.inputBasePairs(Pair,:)=[Pair Pair];
                    cpstruct.Flagged(Pair)=0;
                    cpstruct.ids(Pair)=Pair;
                    cpstruct.inputIdPairs(Pair,:)=[Pair Pair];
                    cpstruct.baseIdPairs(Pair,:)=[Pair Pair];
                    cpstruct.isInputPredicted(Pair,:)=0;
                    cpstruct.isBasePredicted(Pair,:)= 0;
                    cpstruct.Flagged(Pair)=0;
                    clear Temp_Fixed_Coords Temp_Moving_Coords
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    set(Status_TR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
                    set(Status_TL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
                    set(Status_BR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
                    set(Status_BL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
                    set(PairControl, 'string',num2str(Pair))
                    set(PairSlider,'Value',Pair/length(cpstruct.ids),...
                            'SliderStep',[1/length(cpstruct.ids),5/length(cpstruct.ids)])
                    set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
                    clear Temp_Fixed_Coords Temp_Moving_Coords 
                    fprintf(['Successfully Added! Number of Pairs: ',num2str(length(cpstruct.ids)),'\n'])
                    Selecting=1;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','r','String',['Selecting: ON']);set(SelectionStatus_TL,'BackgroundColor','r','String',['Selecting: ON']);
%                     if rem(length(cpstruct.ids),SaveInterval)==0
%                         warning('Saving Temp Backup File...')
%                         save('TempPairData.mat','length(cpstruct.ids)','cpstruct');
%                     end
                    PlotFixedPairs;PlotMovingPairs;
                end            
            end
            
            if ExitSelection
                Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
            else
                axes(AX1)
                txt3=text(Fixed_XLims(1)+10,Fixed_YLims(1)+Fixed_Zoom_BoxSize_px/2,'<ENTER> to Add Another Pair or <1> to EXIT','color',Pair_Overlay_Color,'fontsize',20);
                axes(AX2)
                txt4=text(Moving_XLims(1)+10,Moving_YLims(1)+Moving_Zoom_BoxSize_px/2,'<ENTER> to Add Another Pair or <1> to EXIT','color',Pair_Overlay_Color,'fontsize',20);
                AddMore=InputWithVerification('<ENTER> to Add Another Pair or <1> to EXIT selection mode: ',{[],[1]},0);
                if isempty(AddMore)
                    Selecting=1;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','r','String',['Selecting: ON']);set(SelectionStatus_TL,'BackgroundColor','r','String',['Selecting: ON']);
                else
                    Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
                end
                axes(AX1);delete(txt3);axes(AX2);delete(txt4);
            end
            %Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        UpdatePairTracker
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
        set(PairControl, 'string',num2str(Pair))
        set(PairSlider,'Value',Pair/length(cpstruct.ids),...
                'SliderStep',[1/length(cpstruct.ids),5/length(cpstruct.ids)])
        set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
        Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        figure(SelectionFig)
        Pairing=0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Jump2Flag(src,eventdata,arg1)
        CurrentPair=Pair;
        HoldPair=Pair;
        FoundFlag=0;
        while CurrentPair<size(cpstruct.inputPoints,1)
            CurrentPair=CurrentPair+1;
            if cpstruct.Flagged(CurrentPair)&&~FoundFlag
                FoundFlag=1;
                Pair=CurrentPair;
            end
        end
        if ~FoundFlag
            CurrentPair=1;
            while CurrentPair<HoldPair
                CurrentPair=CurrentPair+1;
                if cpstruct.Flagged(CurrentPair)&&~FoundFlag
                    FoundFlag=1;
                    Pair=CurrentPair;
                end
            end
        end
        if Pair<=length(cpstruct.ids)
            set(PairSlider,'Value',Pair/length(cpstruct.ids))
            fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>'),fprintf(num2str(Pair));fprintf('\n')
            Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
            Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
            Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
            Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
            Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            fprintf(['Current Pair: ',num2str(Pair)])
            set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
            PlotFixedPairs;PlotMovingPairs;
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        else
            fprintf('\n')
            warning('Unable to move to that Pair!')
            set(PairSlider,'Value',Pair/length(cpstruct.ids))
            Fixed_Zoom_Coord=cpstruct.basePoints(Pair,:);
            Fixed_XLims=[Fixed_Zoom_Coord(1)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(1)+Fixed_Zoom_BoxSize_px/2];
            Fixed_YLims=[Fixed_Zoom_Coord(2)-Fixed_Zoom_BoxSize_px/2,Fixed_Zoom_Coord(2)+Fixed_Zoom_BoxSize_px/2];
            Moving_Zoom_Coord=cpstruct.inputPoints(Pair,:);
            Moving_XLims=[Moving_Zoom_Coord(1)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(1)+Moving_Zoom_BoxSize_px/2];
            Moving_YLims=[Moving_Zoom_Coord(2)-Moving_Zoom_BoxSize_px/2,Moving_Zoom_Coord(2)+Moving_Zoom_BoxSize_px/2];
            fprintf(['Current Pair: ',num2str(Pair)])
            set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))
            PlotFixedPairs;PlotMovingPairs;
            axes(AX1)
            xlim(Fixed_XLims),ylim(Fixed_YLims)
            axes(AX2)
            xlim(Moving_XLims),ylim(Moving_YLims)
        end
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function QuickDelete(src,eventdata,arg1)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Shuffeling UndoBuffer
        for u1=1:length(UndoBuffer)-1
            UndoBuffer(u1).cpstruct=UndoBuffer(u1+1).cpstruct;
            UndoBuffer(u1).CurrentPair=UndoBuffer(u1+1).CurrentPair;
        end
        %Adding to Undo Buffer     
        UndoBuffer(length(UndoBuffer)).cpstruct=cpstruct;
        UndoBuffer(length(UndoBuffer)).CurrentPair=Pair;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        CurrentPair=Pair;
        figure(SelectionFig)
        axes(AX2)
        hold on;txt2=text(Moving_XLims(1)+20,Moving_YLims(1)+20,'NOT HERE','color','r','fontsize',20);
        hold on;txt2a=text(Moving_XLims(1)+20,Moving_YLims(1)+Moving_Zoom_BoxSize_px/2,'NOT HERE','color','r','fontsize',20);
        hold on;txt2b=text(Moving_XLims(1)+20,Moving_YLims(2)-40,'NOT HERE','color','r','fontsize',20);
        hold on;Px1=plot([Moving_XLims(1),Moving_XLims(2)],[Moving_YLims(2),Moving_YLims(1)],'-','LineWidth',3,'color','r');
        hold on;Px2=plot([Moving_XLims(1),Moving_XLims(2)],[Moving_YLims(1),Moving_YLims(2)],'-','LineWidth',3,'color','r');
        axes(AX1)
        FindCoord=ginput_w(1);
        TempDistances=[];
        for Pair2=1:size(cpstruct.inputPoints,1)
            TempDistances(Pair2)=...
                sqrt((cpstruct.basePoints(Pair2,1)-FindCoord(1))^2+(cpstruct.basePoints(Pair2,2)-FindCoord(2))^2);
        end
        axes(AX2)
        delete(txt2);delete(txt2a);delete(txt2b)
        delete(Px1);delete(Px2)

        [~,Pair2Delete] = min(TempDistances);
        if ~isempty(Pair2Delete)
            set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            disp(['Deleting Pair #',num2str(Pair2Delete)])
            count=0;
            clear TempStruct
            TempStruct=[];
            for i=1:length(cpstruct.ids)
                if i~=Pair2Delete
                    count=count+1;
                    TempStruct.inputPoints(count,:)=cpstruct.inputPoints(i,:);
                    TempStruct.basePoints(count,:)=cpstruct.basePoints(i,:);
                    TempStruct.Flagged(count,:)=cpstruct.Flagged(i);
                    TempStruct.inputBasePairs(count,:)=[count count];
                    TempStruct.ids(count)=count;
                    TempStruct.inputIdPairs(count,:)=[count count];
                    TempStruct.baseIdPairs(count,:)=[count count];
                    TempStruct.isInputPredicted(count,:)=0;
                    TempStruct.isBasePredicted(count,:)= 0;
                else
                    warning(['Removing Pair #',num2str(i)])
                end
            end
            if length(TempStruct.ids)~=length(cpstruct.ids)-1
                error('Deletion did not work...')
            else
                cpstruct=TempStruct;
                clear TempStruct
                fprintf(['Number of Pairs AFTER DELETING: ',num2str(length(cpstruct.ids)),'\n'])
            end
        else
            warning('Not deleting anything')
        end
        set(Status_TR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        if CurrentPair>length(cpstruct.ids)
            Pair=length(cpstruct.ids);
        else
           Pair=CurrentPair; 
        end
        clear CurrentPair
        UpdatePairTracker
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
        set(PairControl, 'string',num2str(Pair))
        set(PairSlider,'Value',Pair/length(cpstruct.ids),...
                'SliderStep',[1/length(cpstruct.ids),5/length(cpstruct.ids)])
        set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))

        Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        PlotFixedPairs;PlotMovingPairs;
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DeletePairs(src,eventdata,arg1)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Shuffeling UndoBuffer
        for u1=1:length(UndoBuffer)-1
            UndoBuffer(u1).cpstruct=UndoBuffer(u1+1).cpstruct;
            UndoBuffer(u1).CurrentPair=UndoBuffer(u1+1).CurrentPair;
        end
        %Adding to Undo Buffer     
        UndoBuffer(length(UndoBuffer)).cpstruct=cpstruct;
        UndoBuffer(length(UndoBuffer)).CurrentPair=Pair;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure(SelectionFig)
        Selecting=1;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','r','String',['Selecting: ON']);set(SelectionStatus_TL,'BackgroundColor','r','String',['Selecting: ON']);
        if ~NumbersOn
            NumbersOn=1;
            set(DisplayNumbersButton,'Value',NumbersOn); 
            PlotFixedPairs;PlotMovingPairs;
        end
        
        CurrentPair=Pair;
        fprintf(['Number of Pairs: ',num2str(length(cpstruct.ids)),'\n'])
        Pair2Delete=InputWithVerification('Pair # To Delete (<Enter> Skips): ',{[],[1:length(cpstruct.ids)]},0);
        if ~isempty(Pair2Delete)
            set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            disp(['Deleting Pair #',num2str(Pair2Delete)])
            count=0;
            clear TempStruct
            TempStruct=[];
            for i=1:length(cpstruct.ids)
                if i~=Pair2Delete
                    count=count+1;
                    TempStruct.inputPoints(count,:)=cpstruct.inputPoints(i,:);
                    TempStruct.basePoints(count,:)=cpstruct.basePoints(i,:);
                    TempStruct.Flagged(count,:)=cpstruct.Flagged(i);
                    TempStruct.inputBasePairs(count,:)=[count count];
                    TempStruct.ids(count)=count;
                    TempStruct.inputIdPairs(count,:)=[count count];
                    TempStruct.baseIdPairs(count,:)=[count count];
                    TempStruct.isInputPredicted(count,:)=0;
                    TempStruct.isBasePredicted(count,:)= 0;
                else
                    warning(['Removing Pair #',num2str(i)])
                end
            end
            if length(TempStruct.ids)~=length(cpstruct.ids)-1
                error('Deletion did not work...')
            else
                cpstruct=TempStruct;
                clear TempStruct
                fprintf(['Number of Pairs AFTER DELETING: ',num2str(length(cpstruct.ids)),'\n'])
            end
        end
        set(Status_TR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        if CurrentPair>length(cpstruct.ids)
            Pair=length(cpstruct.ids);
        else
           Pair=CurrentPair; 
        end
        clear CurrentPair
        UpdatePairTracker
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
        set(PairControl, 'string',num2str(Pair))
        set(PairSlider,'Value',Pair/length(cpstruct.ids),...
                'SliderStep',[1/length(cpstruct.ids),5/length(cpstruct.ids)])
        set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))

        Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        PlotFixedPairs;PlotMovingPairs;
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DeleteRange(src,eventdata,arg1)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Shuffeling UndoBuffer
        for u1=1:length(UndoBuffer)-1
            UndoBuffer(u1).cpstruct=UndoBuffer(u1+1).cpstruct;
            UndoBuffer(u1).CurrentPair=UndoBuffer(u1+1).CurrentPair;
        end
        %Adding to Undo Buffer     
        UndoBuffer(length(UndoBuffer)).cpstruct=cpstruct;
        UndoBuffer(length(UndoBuffer)).CurrentPair=Pair;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure(SelectionFig)
        if ~NumbersOn
            NumbersOn=1;
            set(DisplayNumbersButton,'Value',NumbersOn); 
            PlotFixedPairs;PlotMovingPairs;
        end
        Selecting=1;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','r','String',['Selecting: ON']);set(SelectionStatus_TL,'BackgroundColor','r','String',['Selecting: ON']);
        CurrentPair=Pair;
        fprintf(['Number of Pairs: ',num2str(length(cpstruct.ids)),'\n'])
        commandwindow
        fprintf('Deleting a range of Pairs...\n')
        %disp('First Pair # To Delete: ')
        FirstPair2Delete=InputWithVerification('First Pair # To Delete: ',{[],[1:length(cpstruct.ids)]},0);
        %disp('Last Pair # To Delete: ')
        LastPair2Delete=InputWithVerification('Last Pair # To Delete: ',{[],[1:length(cpstruct.ids)]},0);
        if ~isempty(FirstPair2Delete)&&~isempty(LastPair2Delete)
            if LastPair2Delete>FirstPair2Delete
                Pairs2Delete=[FirstPair2Delete:LastPair2Delete];
                %Pairs2Delete=fliplr(Pairs2Delete);
            else
                Pairs2Delete=[];
            end
        else
            Pairs2Delete=[];
        end
        if ~isempty(Pairs2Delete)
            set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            disp(['Deleting Pairs: ',num2str(Pairs2Delete)])
            count=0;
            clear TempStruct
            TempStruct=[];
            for i=1:length(cpstruct.ids)
                if i~=Pairs2Delete
                    count=count+1;
                    TempStruct.inputPoints(count,:)=cpstruct.inputPoints(i,:);
                    TempStruct.basePoints(count,:)=cpstruct.basePoints(i,:);
                    TempStruct.Flagged(count,:)=cpstruct.Flagged(i);
                    TempStruct.inputBasePairs(count,:)=[count count];
                    TempStruct.ids(count)=count;
                    TempStruct.inputIdPairs(count,:)=[count count];
                    TempStruct.baseIdPairs(count,:)=[count count];
                    TempStruct.isInputPredicted(count,:)=0;
                    TempStruct.isBasePredicted(count,:)= 0;
                else
                    warning(['Removing Pair #',num2str(i)])
                end
            end
            if length(TempStruct.ids)~=length(cpstruct.ids)-length(Pairs2Delete)
                error('Deletion did not work...')
            else
                cpstruct=TempStruct;
                clear TempStruct
                fprintf(['Number of Pairs AFTER DELETING: ',num2str(length(cpstruct.ids)),'\n'])
            end
        end
        set(Status_TR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        if CurrentPair>length(cpstruct.ids)
            Pair=length(cpstruct.ids);
        else
           Pair=CurrentPair; 
        end
        clear CurrentPair
        UpdatePairTracker
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
        set(PairControl, 'string',num2str(Pair))
        set(PairSlider,'Value',Pair/length(cpstruct.ids),...
                'SliderStep',[1/length(cpstruct.ids),5/length(cpstruct.ids)])
        set(SliderText,'String',['Pair: ',num2str(Pair),'/',num2str(length(cpstruct.ids))]);set(PairControl,'String',num2str(Pair))

        Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        PlotFixedPairs;PlotMovingPairs;
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ShiftFixed(src,eventdata,arg1)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Shuffeling UndoBuffer
        for u1=1:length(UndoBuffer)-1
            UndoBuffer(u1).cpstruct=UndoBuffer(u1+1).cpstruct;
            UndoBuffer(u1).CurrentPair=UndoBuffer(u1+1).CurrentPair;
        end
        %Adding to Undo Buffer     
        UndoBuffer(length(UndoBuffer)).cpstruct=cpstruct;
        UndoBuffer(length(UndoBuffer)).CurrentPair=Pair;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure(SelectionFig)
        axes(AX2)
        hold on;txt2=text(Moving_XLims(1)+20,Moving_YLims(1)+20,'NOT HERE','color','r','fontsize',20);
        hold on;txt2a=text(Moving_XLims(1)+20,Moving_YLims(1)+Moving_Zoom_BoxSize_px/2,'NOT HERE','color','r','fontsize',20);
        hold on;txt2b=text(Moving_XLims(1)+20,Moving_YLims(2)-40,'NOT HERE','color','r','fontsize',20);
        hold on;Px1=plot([Moving_XLims(1),Moving_XLims(2)],[Moving_YLims(2),Moving_YLims(1)],'-','LineWidth',3,'color','r');
        hold on;Px2=plot([Moving_XLims(1),Moving_XLims(2)],[Moving_YLims(1),Moving_YLims(2)],'-','LineWidth',3,'color','r');
        axes(AX1)
        FindCoord=ginput_w(1);
        TempDistances=[];
        for Pair2=1:size(cpstruct.inputPoints,1)
            TempDistances(Pair2)=...
                sqrt((cpstruct.basePoints(Pair2,1)-FindCoord(1))^2+(cpstruct.basePoints(Pair2,2)-FindCoord(2))^2);
        end
        [~,FindPair] = min(TempDistances);
        axes(AX1)
        hold on
        TempPlot=plot(cpstruct.basePoints(FindPair,1),cpstruct.basePoints(FindPair,2),'*','color','r','markersize',12);
        NewCoord=ginput_w(1);
        cpstruct.basePoints(FindPair,:)=NewCoord;
        delete(TempPlot)
        figure(SelectionFig)
        axes(AX1)
        xlim(Fixed_XLims),ylim(Fixed_YLims)
        axes(AX2)
        xlim(Moving_XLims),ylim(Moving_YLims)
        delete(txt2);delete(txt2a);delete(txt2b)
        delete(Px1);delete(Px2)
        PlotFixedPairs
        PlotMovingPairs
        clear FindCoord NewCoord TempDistances FindPair
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    function ShiftMoving(src,eventdata,arg1)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Shuffeling UndoBuffer
        for u1=1:length(UndoBuffer)-1
            UndoBuffer(u1).cpstruct=UndoBuffer(u1+1).cpstruct;
            UndoBuffer(u1).CurrentPair=UndoBuffer(u1+1).CurrentPair;
        end
        %Adding to Undo Buffer     
        UndoBuffer(length(UndoBuffer)).cpstruct=cpstruct;
        UndoBuffer(length(UndoBuffer)).CurrentPair=Pair;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure(SelectionFig)
        axes(AX1)
        hold on;txt2=text(Fixed_XLims(1)+20,Fixed_YLims(1)+20,'NOT HERE','color','r','fontsize',20);
        hold on;txt2a=text(Fixed_XLims(1)+20,Fixed_YLims(1)+Fixed_Zoom_BoxSize_px/2,'NOT HERE','color','r','fontsize',20);
        hold on;txt2b=text(Fixed_XLims(1)+20,Fixed_YLims(2)-40,'NOT HERE','color','r','fontsize',20);
        hold on;Px1=plot([Fixed_XLims(1),Fixed_XLims(2)],[Fixed_YLims(2),Fixed_YLims(1)],'-','LineWidth',3,'color','r');
        hold on;Px2=plot([Fixed_XLims(1),Fixed_XLims(2)],[Fixed_YLims(1),Fixed_YLims(2)],'-','LineWidth',3,'color','r');
        axes(AX2)
        FindCoord=ginput_w(1);
        TempDistances=[];
        for Pair2=1:size(cpstruct.inputPoints,1)
            TempDistances(Pair2)=...
                sqrt((cpstruct.inputPoints(Pair2,1)-FindCoord(1))^2+(cpstruct.inputPoints(Pair2,2)-FindCoord(2))^2);
        end
        [~,FindPair] = min(TempDistances);
        axes(AX2)
        hold on
        TempPlot=plot(cpstruct.inputPoints(FindPair,1),cpstruct.inputPoints(FindPair,2),'*','color','r','markersize',12);
        NewCoord=ginput_w(1);
        cpstruct.inputPoints(FindPair,:)=NewCoord;
        delete(TempPlot)
        PlotMoving_Markers;
        figure(SelectionFig)
        axes(AX1)
        delete(txt2);delete(txt2a);delete(txt2b)
        delete(Px1);delete(Px2)
        xlim(Fixed_XLims),ylim(Fixed_YLims)
        axes(AX2)
        xlim(Moving_XLims),ylim(Moving_YLims)
        PlotFixedPairs
        PlotMovingPairs
        clear FindCoord NewCoord TempDistances FindPair
        UpdatePairTrackerZoomBox;UpdatePairTracker2
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ForceUpdateImage(src,eventdata,arg1)
        UpdateImage(Fixed_Image,Moving_Image)
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    function ForceChangeSelecting(src,eventdata,arg1)
        Selecting=get(src,'Value');
        if ~Selecting
            set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
        else
            set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','r','String',['Selecting: ON']);set(SelectionStatus_TL,'BackgroundColor','r','String',['Selecting: ON']);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function Finished(src,eventdata,arg1)
        if isempty(Selecting)
            warning('EXIT Selection MODE BEFORE EXITING!')
        else
            global CPSTRUCT
            CPSTRUCT=cpstruct;
            try
                close(SelectionFig)
                close(PairTracker)
                close(PairTracker2)
            catch
                warning('Problem closing figure windows!')
            end
            fprintf(['Exiting Function...\n'])
            fprintf(['Number of Pairs: ',num2str(length(cpstruct.ids)),'\n'])
            warning('Run Next section to extract pairs!')
            warning('Run Next section to extract pairs!')
            warning('Run Next section to extract pairs!')
            warning('Run Next section to extract pairs!')
            warning('Run Next section to extract pairs!')
            warning('Run Next section to extract pairs!')
            %PromptHandle=ZachPrompt({'Dont forget to extract pairs';'Run the next bit of code'},'Extract PAIRS',2);

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


end
