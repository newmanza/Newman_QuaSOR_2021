%To Do

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Zach_Point_Selection_Tool(FigPosition,FigPosition2,...
    Coord_Struct,ControlPoint_MarkerColor,DefaultZoomBoxSize_um,...
    Images,Image_Options,Markers,...
    Default_Image,Default_Contrast,Height,Width,PixelSize_nm,...
    Borders,Circle_Radius_um,ScaleBar)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    global AX1
    %close all     
    fprintf('Initializing...')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Initial Parameters
        Circle_Radius=((Circle_Radius_um*1000)/PixelSize_nm);
        Marker_On_Default_Zoom=1;
        PointLayers=[];
        MarkerLayers=[];
        DataType=Default_Image;
        BorderOn=1;
        Point_On=1;
        Scale_On=1;
        Marker_On=0;
        Zoom_BoxSize_um=DefaultZoomBoxSize_um;
        LineWidth=0.5;
        HighContrast=Default_Contrast;
        Scroll_Interval_um=Zoom_BoxSize_um/10;
        R=0;
        G=0;
        B=0;
        %%%%%%%
        %%%%%%%
        Max_Zoom_BoxSize_um=100;
        Max_Circle_Radius_um=20;
        Min_Circle_Radius_um=0.005;
        PointMarker={'o'};
        PointMarkerSize_Zoom=16;
        ZoomOn=0;
        NumbersOn=0;
        NumberOffset_Zoom=0;
        PointFontSize_Zoom=18;
        Selecting=0;
        Paring=0;
        Point_Overlay_Color=ControlPoint_MarkerColor;
        Point_Overlay_Current_Color=ControlPoint_MarkerColor;
        if Coord_Struct.NumCoords>0
            Point=0;
        else
            Point=1;
        end
        if isempty(FigPosition2)
            PointTrackerFigPosition=[FigPosition(3),0.4,1-FigPosition(3),0.5];
        else
            PointTrackerFigPosition=FigPosition2;
        end
        PT1=[];
        PT2=[];
        PT3=[];
        PT4=[];
        Zoom_Region=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
        if Coord_Struct.NumCoords>0
            FigName=[': ',Images{DataType}.Label,' Num Points: ',num2str(size(Coord_Struct.Coords,1))];
        else
            FigName=[': ',Images{DataType}.Label,' NO PointS YET!'];
            Coord_Struct.Coords=[];
        end
        
        PointTracker=figure('name',FigName);
        set(PointTracker,'units','normalized','position',PointTrackerFigPosition)


        SelectionFig=figure('name',FigName);
        set(gcf, 'color', 'white');
        set(gcf,'units','normalized','position',FigPosition)
        AX1=subtightplot(1,1,1,[0,0],[0.05,0.05],[0.05,0.05]);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        Image=Images{DataType}.Image;
        XLims=[0,size(Image,2)];
        YLims=[0,size(Image,1)];
        Zoom_Coord=[size(Image,2)/2,size(Image,1)/2];
        Zoom_BoxSize_px=ceil((Zoom_BoxSize_um*1000)/PixelSize_nm);
        Scroll_Interval_px=ceil((Scroll_Interval_um*1000)/PixelSize_nm);
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
        Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.2 0.02 0.1 0.03],...
            'String',[' Image'],'FontSize',16);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        DeleteCoordButton = uicontrol('Style', 'togglebutton', 'String', 'MultiDelete(del)',...
            'units','normalized',...
            'Position', [0.63 0.97 0.05 0.03],...
            'Callback', @Delete);      
        ShiftCoordButton = uicontrol('Style', 'togglebutton', 'String', 'Shift(shift)',...
            'units','normalized',...
            'Position', [0.63 0.94 0.05 0.03],...
            'Callback', @Shift);      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        DeletePointsButton = uicontrol('Style', 'pushbutton', 'String', 'Delete Point #',...
            'units','normalized',...
            'Position', [0.37 0.97 0.05 0.03],...
            'Callback', @DeletePoints);  
        DeleteRangeButton = uicontrol('Style', 'pushbutton', 'String', 'Delete Range',...
            'units','normalized',...
            'Position', [0.37 0.94 0.05 0.03],...
            'Callback', @DeleteRange); 
        TagPointsButton = uicontrol('Style', 'pushbutton', 'String', 'Tag Points',...
            'units','normalized',...
            'Position', [0.42 0.97 0.05 0.03],...
            'Callback', @TagPoints);   
        MultiTagPointsButton = uicontrol('Style', 'pushbutton', 'String', 'MultiTag (Ctrl)',...
            'units','normalized',...
            'Position', [0.42 0.94 0.05 0.03],...
            'Callback', @MultiTagPoints);   
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SelectingButton = uicontrol('Style', 'togglebutton', 'String', 'Selecting',...
            'units','normalized',...
            'value',Selecting,...
            'Position', [0.57 0.97 0.05 0.03],...
            'Callback', @ForceChangeSelecting); 
        UpdateImageButton = uicontrol('Style', 'pushbutton', 'String', 'Update(Space)',...
            'units','normalized',...
            'Position', [0.49 0.94 0.06 0.03],...
            'Callback', @ForceUpdateImage);   
        FinishedButton = uicontrol('Style', 'pushbutton', 'String', 'Finished(END)',...
            'units','normalized',...
            'Position', [0.87 0.94 0.06 0.06],...
            'Callback', @Finished);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        DisplayMarkerButton = uicontrol('Style', 'togglebutton', 'String', 'Marker',...
            'units','normalized',...
            'value',Marker_On,...
            'Position', [0.0 0.97 0.05 0.03],...
            'Callback', @DisplayMarker);   
        DisplayPointButton = uicontrol('Style', 'togglebutton', 'String', 'Point',...
            'units','normalized',...
            'value',Point_On,...
            'Position', [0.05 0.97 0.05 0.03],...
            'Callback', @DisplayPoint);   
        DisplayBordersButton = uicontrol('Style', 'togglebutton', 'String', 'Bord',...
            'units','normalized',...
            'value',BorderOn,...
            'Position', [0.015 0.94 0.035 0.03],...
            'Callback', @DisplayBorders);      
        DisplayNumbersButton = uicontrol('Style', 'togglebutton', 'String', 'Numbers',...
            'units','normalized',...
            'value',NumbersOn,...
            'Position', [0.1 0.97 0.05 0.03],...
            'Callback', @DisplayNumbers);   
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        MarkerRadiusSlider = uicontrol('Style', 'slider',...
            'Min',0,'Max',1,'Value',(Circle_Radius_um/Max_Circle_Radius_um),...
            'SliderStep',[Min_Circle_Radius_um/Max_Circle_Radius_um,(Min_Circle_Radius_um*20)/Max_Circle_Radius_um],...
            'units','normalized',...
            'Position', [0.05 0.955 0.1 0.015],...
            'Callback', @MarkerRadius_Slider_callback);
        MarkerRadiusSliderText = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.06 0.94 0.08 0.015],...
            'String',['Marker Rad: ',num2str(Circle_Radius_um),'um']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Image_Selection = uicontrol('Style', 'popup',...
           'String', Image_Options,...
            'units','normalized',...
            'Position', [0.15 0.95 0.1 0.05],...
           'Callback', @Select_Image);
        set(Image_Selection,'Value',DataType)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Contrast_Slider = uicontrol('Style', 'slider',...
            'Min',0,'Max',1,'Value',HighContrast,...
            'SliderStep',[0.01,0.05],...
            'units','normalized',...
            'Position', [0.15 0.955 0.1 0.015],...
            'Callback', @Contrast_Slider_callback);
        Contrast_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.15 0.94 0.1 0.015],...
            'String',[' Max%: ',num2str(HighContrast*100),'%']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        R_Control = uicontrol('Style', 'edit', 'string',num2str(R),...
            'units','normalized',...
            'Position', [0.2725 0.98 0.0175 0.02]);
        R_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.2625 0.98 0.01 0.02],...
            'String','R');
        G_Control = uicontrol('Style', 'edit', 'string',num2str(G),...
            'units','normalized',...
            'Position', [0.2725 0.96 0.0175 0.02]);      
        G_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.2625 0.96 0.01 0.02],...
            'String','G');
        B_Control = uicontrol('Style', 'edit', 'string',num2str(B),...
            'units','normalized',...
            'Position', [0.2725 0.94 0.0175 0.02]);      
        B_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.2625 0.94 0.01 0.02],...
            'String','B');
        ColorBalanceControl = uibutton('Style', 'pushbutton', 'String', 'RGB',...
            'units','normalized','rotation',90,...
            'Position', [0.25 0.94 0.015 0.06],...
            'Callback', @ColorBalance);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            'Min',0,'Max',1,'Value',Zoom_BoxSize_um/Max_Zoom_BoxSize_um,...
            'SliderStep',[1/Max_Zoom_BoxSize_um,5/Max_Zoom_BoxSize_um],...
            'units','normalized',...
            'Position', [0.29 0.955 0.08 0.015],...
            'Callback', @ZoomSize_Slider_callback);
        ZoomSize_Text = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.29 0.94 0.08 0.015],...
            'String',['ZoomBox: ',num2str(Zoom_BoxSize_um),'um']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %XY Adjustments
        X_Scroll = uicontrol('Style', 'slider',...
            'Min',0,'Max',1,'Value',Zoom_Coord(1)/size(Image,2),...
            'SliderStep',[Scroll_Interval_px/size(Image,2),(Scroll_Interval_px*5)/size(Image,2)],...
            'units','normalized',...
            'Position', [0.015 0 0.985 0.015],...
            'Callback', @X_Scroll_callback);
        Y_Scroll = uicontrol('Style', 'slider',...
            'Min',0,'Max',1,'Value',1-Zoom_Coord(2)/size(Image,1),...
            'SliderStep',[Scroll_Interval_px/size(Image,1),(Scroll_Interval_px*5)/size(Image,1)],...
            'units','normalized',...
            'Position', [0 0.015 0.015 0.95],...
            'Callback', @Y_Scroll_callback);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if size(Coord_Struct.Coords,1)>0
            PointSlider = uicontrol('Style', 'slider',...
                'Min',0,'Max',1,'Value',Point/size(Coord_Struct.Coords,1),...
                'SliderStep',[1/size(Coord_Struct.Coords,1),5/size(Coord_Struct.Coords,1)],...
                'units','normalized',...
                'Position', [0.47 0.985 0.1 0.015],...
                'Callback', @Point_Slider_callback);
        else
            PointSlider = uicontrol('Style', 'slider',...
                'Min',0,'Max',1,'Value',0,...
                'units','normalized',...
                'Position', [0.47 0.985 0.1 0.015],...
                'Callback', @Point_Slider_callback);
        end
        SliderText = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.49 0.97 0.06 0.015],...
            'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);
        %PointNav=uicontrol('Style','Edit','String','matlab','KeyPressFCN',@PointNavigation_KeyPressFcn);
        ForwardText = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.55 0.97 0.02 0.015],...
            'String','c>');
        ReverseText = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.47 0.97 0.02 0.015],...
            'String','<x');
        PointControl = uicontrol('Style', 'edit', 'string',num2str(Point),...
            'units','normalized',...
            'Position', [0.59 0.95 0.04 0.02]);      
        PointJump2Button = uicontrol('Style', 'pushbutton', 'String', 'Point>',...
            'units','normalized',...
            'Position', [0.57 0.95 0.03 0.02],...
            'Callback', @Jump2Point);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        set(SelectionFig,'WindowKeyPressFcn',@Navigation_KeyPressFcn)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Status_TL = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.02 0.925 0.03 0.015],...
            'BackgroundColor','g',...
            'String',['Status: ']);
        Status_TR = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.93 0.985 0.07 0.015],...
            'BackgroundColor','g',...
            'String',['Status: ']);       
        Status_BL = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.02 0.02 0.07 0.015],...
            'BackgroundColor','g',...
            'String',['Status: ']);           
        Status_BR = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.93 0.02 0.07 0.015],...
            'BackgroundColor','g',...
            'String',['Status: ']);
        SelectionStatus_TR = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.93 0.97 0.07 0.015],...
            'BackgroundColor','g',...
            'String',['Selecting: OFF']);
        SelectionStatus_TL = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.02 0.91 0.03 0.015],...
            'BackgroundColor','g',...
            'String',['Selecting: OFF']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    figure(SelectionFig)
    UpdateImage(Image)
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
                figure(SelectionFig)
                Zoom_Coord(1) = Zoom_Coord(1)+Scroll_Interval_px;
                XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
                YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
                set(X_Scroll,'value',Zoom_Coord(1)/size(Image,2))
                axes(AX1)
                xlim(XLims),ylim(YLims)
                figure(SelectionFig)
                PlotPoints
                figure(SelectionFig)
                if ZoomOn
                    figure(PointTracker)
                    if exist('PT1')
                        delete(PT1);delete(PT2);delete(PT3);delete(PT4);
                    end
                    Zoom_Region=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(2)-Zoom_BoxSize_px/2,...
                        Zoom_BoxSize_px,Zoom_BoxSize_px];
                    [PT1,PT2,PT3,PT4,~]=PlotBox2(Zoom_Region,'-','w',1,[],[],[]);
                end
                figure(SelectionFig)
                axes(AX1)
                
            end
        elseif isequal(evnt.Key,'leftarrow')
            if ZoomOn
                figure(SelectionFig)
                Zoom_Coord(1) = Zoom_Coord(1)-Scroll_Interval_px;
                XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
                YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
                set(X_Scroll,'value',Zoom_Coord(1)/size(Image,2))
                axes(AX1)
                xlim(XLims),ylim(YLims)
                figure(SelectionFig)
                PlotPoints
                figure(SelectionFig)
                if ZoomOn
                    figure(PointTracker)
                    if exist('PT1')
                        delete(PT1);delete(PT2);delete(PT3);delete(PT4);
                    end
                    Zoom_Region=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(2)-Zoom_BoxSize_px/2,...
                        Zoom_BoxSize_px,Zoom_BoxSize_px];
                    [PT1,PT2,PT3,PT4,~]=PlotBox2(Zoom_Region,'-','w',1,[],[],[]);
                end
                figure(SelectionFig)
                axes(AX1)
            end
        elseif isequal(evnt.Key,'uparrow')
            if ZoomOn
                figure(SelectionFig)
                Zoom_Coord(2) = Zoom_Coord(2)-Scroll_Interval_px;
                XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
                YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
                set(Y_Scroll,'value',Zoom_Coord(2)/size(Image,1))
                axes(AX1)
                xlim(XLims),ylim(YLims)
                figure(SelectionFig)
                PlotPoints
                axes(AX1)
                figure(SelectionFig)
                if ZoomOn
                    figure(PointTracker)
                    if exist('PT1')
                        delete(PT1);delete(PT2);delete(PT3);delete(PT4);
                    end
                    Zoom_Region=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(2)-Zoom_BoxSize_px/2,...
                        Zoom_BoxSize_px,Zoom_BoxSize_px];
                    [PT1,PT2,PT3,PT4,~]=PlotBox2(Zoom_Region,'-','w',1,[],[],[]);
                end
                figure(SelectionFig)
                axes(AX1)
            end
        elseif isequal(evnt.Key,'downarrow')
            if ZoomOn
                figure(SelectionFig)
                Zoom_Coord(2) = Zoom_Coord(2)+Scroll_Interval_px;
                XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
                YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
                set(Y_Scroll,'value',Zoom_Coord(2)/size(Image,1))
                axes(AX1)
                xlim(XLims),ylim(YLims)
                figure(SelectionFig)
                PlotPoints
                figure(SelectionFig)
                if ZoomOn
                    figure(PointTracker)
                    if exist('PT1')
                        delete(PT1);delete(PT2);delete(PT3);delete(PT4);
                    end
                    Zoom_Region=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(2)-Zoom_BoxSize_px/2,...
                        Zoom_BoxSize_px,Zoom_BoxSize_px];
                    [PT1,PT2,PT3,PT4,~]=PlotBox2(Zoom_Region,'-','w',1,[],[],[]);
                end
                figure(SelectionFig)
                axes(AX1)
            end
        elseif isequal(evnt.Key,'shift')
            Shift
        elseif isequal(evnt.Key,'delete')
            Delete
        elseif isequal(evnt.Key,'q')
            Shift
        elseif isequal(evnt.Key,'c')
            PointAdvance
        elseif isequal(evnt.Key,'x')
            PointRetreat
        elseif isequal(evnt.Key,'control')
            MultiTagPoints
        elseif isequal(evnt.Key,'pageup')
            ZoomIn
        elseif isequal(evnt.Key,'pagedown')
            ZoomOut
        elseif isequal(evnt.Key,'end')
            Finished
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
    function UpdateImage(Image)
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        FigName=[': ',Images{DataType}.Label,' Num Points: ',num2str(size(Coord_Struct.Coords,1))];
        set(gcf,'name',FigName)
                
        if Point~=0
            set(PointControl, 'string',num2str(Point))
            set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1),...
                    'SliderStep',[1/size(Coord_Struct.Coords,1),5/size(Coord_Struct.Coords,1)])
            set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
        end
        cla(AX1)
        figure(SelectionFig)
        %clf
        AX1=subtightplot(1,1,1,[0,0],[0.05,0.05],[0.05,0.05]);
        %imshow(Image)
        imshow(imadjust(Image,...
            [0,0,0;(1-HighContrast)*(1-R),(1-HighContrast)*(1-G),(1-HighContrast)*(1-B)]),[]);
        set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        if Point_On
            PlotPoints
        end
        if Marker_On
            PlotMarkers
        end
        set(Status_TR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        if BorderOn
            hold on
            BorderLayers=[];
            count=0;
            for Border=1:length(Borders)
                for j=1:length(Borders(Border).BorderLine)
                    count=count+1;
                    BorderLayers(count)=plot(Borders(Border).BorderLine{j}.BorderLine(:,2),...
                        Borders(Border).BorderLine{j}.BorderLine(:,1),...
                        Borders(Border).LineStyle,'color',Borders(Border).Color,...
                        'linewidth',Borders(Border).LineWidth);
                end
            end

        end
        if Scale_On
            hold on
            plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',ScaleBar.Width);
        end
        hold on
        xlim(XLims),ylim(YLims)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        set(Status_TR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        UpdatePointTracker
        figure(SelectionFig)
        PlotMarkers;;
        figure(SelectionFig)

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdatePointTracker
        figure(PointTracker)
        clf
        hold on
        set(PointTracker,'color','k')
        set(gca,'color','k')
        axis off
        box off
        set(gca,'ydir','reverse')
        axis equal tight
        xlim([0,max([Width])])
        ylim([0,max([Height])])
        if ~isempty(Coord_Struct.Coords)
            if isfield(Coord_Struct,'Coords')
                for i=1:size(Coord_Struct.Coords,1)
                    if Point_On
                        plot([Coord_Struct.Coords(i,1)],...
                            [Coord_Struct.Coords(i,2)],...
                            '-','color','y','linewidth',0.25);
                    end
                    if Point_On
                        plot(Coord_Struct.Coords(i,1),Coord_Struct.Coords(i,2),...
                            '.','color','g','markersize',5);
                    end
                end
            end
        end
        if ZoomOn
            figure(PointTracker)
            if exist('PT1')
                delete(PT1);delete(PT2);delete(PT3);delete(PT4);
            end
            Zoom_Region=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(2)-Zoom_BoxSize_px/2,...
                Zoom_BoxSize_px,Zoom_BoxSize_px];
            [PT1,PT2,PT3,PT4,~]=PlotBox2(Zoom_Region,'-','w',1,[],[],[]);
        else
            [PT1,PT2,PT3,PT4,~]=PlotBox2([0,0,Width,Height],'-','w',1,[],[],[]);
        end
        pause(0.1)
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function PlotPoints
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        figure(SelectionFig)
        hold on
        %Remove layers
        if ~isempty(PointLayers)
            for Point1=1:length(PointLayers)
                if ~isempty(PointLayers(Point1).MarkerHandle)
                    delete(PointLayers(Point1).MarkerHandle)
                end
                if ~isempty(PointLayers(Point1).TextHandle)
                    delete(PointLayers(Point1).TextHandle)
                end
            end
            PointLayers=[];
        end
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        figure(SelectionFig)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Add Layers
        PointLayers=[];
        if Point_On
            count=0;
            figure(SelectionFig)
            hold on 
            axes(AX1)
            for Point1=1:size(Coord_Struct.Coords,1)
                if Coord_Struct.Coords(Point1,1)>=XLims(1)&&...
                    Coord_Struct.Coords(Point1,1)<=XLims(2)&&...
                    Coord_Struct.Coords(Point1,2)>=YLims(1)&&...
                    Coord_Struct.Coords(Point1,2)<=YLims(2)
                    if Point==Point1
                        count=count+1;
                        hold on;
                        PointLayers(count).MarkerHandle=Plot_Circle2(Coord_Struct.Coords(Point1,1),...
                            Coord_Struct.Coords(Point1,2),...
                            Circle_Radius,'-',LineWidth+2,Point_Overlay_Current_Color);
                        if NumbersOn
                            PointLayers(count).TextHandle=text(Coord_Struct.Coords(Point1,1)+NumberOffset_Zoom,...
                                Coord_Struct.Coords(Point1,2),num2str(Point1),...
                                'color',Point_Overlay_Current_Color,'FontSize',PointFontSize_Zoom,'FontWeight','bold');
                        else
                            PointLayers(count).TextHandle=[];
                        end
                    else
                        count=count+1;
                        hold on;
                        PointLayers(count).MarkerHandle=Plot_Circle2(Coord_Struct.Coords(Point1,1),...
                            Coord_Struct.Coords(Point1,2),...
                            Circle_Radius,'-',LineWidth,Point_Overlay_Color);
                        if NumbersOn
                            PointLayers(count).TextHandle=text(Coord_Struct.Coords(Point1,1)+NumberOffset_Zoom,...
                                Coord_Struct.Coords(Point1,2),num2str(Point1),...
                                'color',Point_Overlay_Color,'FontSize',PointFontSize_Zoom);
                        else
                            PointLayers(count).TextHandle=[];
                        end
                    end
                end
            end
            figure(SelectionFig)
            set(Status_TR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_TL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_BR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
            set(Status_BL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
        end
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function PlotMarkers
        figure(SelectionFig)
        set(Status_TR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);

        hold on
        %Remove layers
        if ~isempty(MarkerLayers)
            for Marker1=1:length(MarkerLayers)
                if ~isempty(MarkerLayers(Marker1).MarkerHandle)
                    delete(MarkerLayers(Marker1).MarkerHandle)
                end
                if ~isempty(MarkerLayers(Marker1).TextHandle)
                    delete(MarkerLayers(Marker1).TextHandle)
                end
            end
            MarkerLayers=[];
        end
        set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Add Layers
        MarkerLayers=[];
        if Marker_On
            count=0;
            figure(SelectionFig)
            hold on 
            axes(AX1)
            MarkerLayers=[];
            for Marker=1:length(Markers)
                for m=1:length(Markers(Marker).MarkerCoords)
                    count=count+1;
                    MarkerLayers(count).MarkerHandle=plot(Markers(Marker).MarkerCoords(m,2),...
                        Markers(Marker).MarkerCoords(m,1),...
                        Markers(Marker).MarkerStyle,'color',Markers(Marker).Color,...
                        'markerSize',Markers(Marker).MarkerSize);
                    MarkerLayers(count).TextHandle=[];
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ZoomIn(src,eventdata,arg1)
        figure(SelectionFig)
        %Select Zoom 
        ZoomOn=1;
        cont=1;
        XLims1=XLims;
        YLims1=YLims;
        while cont
            axes(AX1)
            txt1=text(50,50,'Select Zoom Center Here','color',Point_Overlay_Color,'fontsize',20);
            Zoom_Coord=ginput_ZN('w',1);
            axes(AX1)
            hold on
            Zoom_Region=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(2)-Zoom_BoxSize_px/2,...
                Zoom_BoxSize_px,Zoom_BoxSize_px];
            [P1,P2,P3,P4,~]=PlotBox2(Zoom_Region,'-',Point_Overlay_Color,2,[],[],[]);
            delete(txt1)
            txt1=text(50,50,'<ENTER> to accept','color',Point_Overlay_Color,'fontsize',20);
            cont=[];
            %cont=InputWithVerification('<ENTER> to Accept Zoom Region: ',{[],[1]},0);
            if cont
                delete(txt1);delete(P1);delete(P2);delete(P3);delete(P4);
                XLims=[0,size(Image,2)];
                YLims=[0,size(Image,1)];
            else
                delete(txt1);
                XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
                YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
            end            
        end
        %Zoom
        axes(AX1)
        delete(P1);delete(P2);delete(P3);delete(P4);
        xlim(XLims),ylim(YLims)
        set(X_Scroll,'value',Zoom_Coord(1)/size(Image,2))
        set(Y_Scroll,'value',1-Zoom_Coord(2)/size(Image,1))
%         NumbersOn=1;
%         set(DisplayNumbersButton,'value',NumbersOn);
        if Marker_On_Default_Zoom
            if ~Marker_On
                Marker_On=1;
            end
        end
        PlotPoints;
        PlotMarkers;
        figure(SelectionFig)
        if ZoomOn
            figure(PointTracker)
            if exist('PT1')
                delete(PT1);delete(PT2);delete(PT3);delete(PT4);
            end
            Zoom_Region=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(2)-Zoom_BoxSize_px/2,...
                Zoom_BoxSize_px,Zoom_BoxSize_px];
            [PT1,PT2,PT3,PT4,~]=PlotBox2(Zoom_Region,'-','w',1,[],[],[]);
        end
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ZoomOut(src,eventdata,arg1)
        figure(SelectionFig)
        %UN-Zoom
        ZoomOn=0;
        Zoom_Coord=[size(Image,2)/2,size(Image,1)/2];
        XLims=[0,size(Image,2)];
        YLims=[0,size(Image,1)];
        UpdateImage(Image)
        axes(AX1)
        xlim(XLims),ylim(YLims)
        set(X_Scroll,'value',Zoom_Coord(1)/size(Image,2))
        set(Y_Scroll,'value',1-Zoom_Coord(2)/size(Image,1))
        NumbersOn=0;
        set(DisplayNumbersButton,'value',NumbersOn);
        if Marker_On_Default_Zoom
            Marker_On=0;
        end
        PlotPoints;
        PlotMarkers;
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Zoom Slider
    function ZoomSize_Slider_callback(src,eventdata,arg1)
        figure(SelectionFig)
        Zoom_BoxSize_um = get(src,'Value')*Max_Zoom_BoxSize_um;
        set(ZoomSize_Text,'String',['Zoom Box Size: ',num2str(Zoom_BoxSize_um),'um']);
        Zoom_BoxSize_px=ceil((Zoom_BoxSize_um*1000)/PixelSize_nm);
        Scroll_Interval_px=ceil((Scroll_Interval_um*1000)/PixelSize_nm);
        if ZoomOn
            XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
            YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
            set(X_Scroll,'value',Zoom_Coord(1)/size(Image,2))
            set(Y_Scroll,'value',1-Zoom_Coord(2)/size(Image,1))
            axes(AX1)
            xlim(XLims),ylim(YLims)
        end
        set(DisplayNumbersButton,'value',NumbersOn);
        PlotPoints;
        figure(SelectionFig)
        if ZoomOn
            figure(PointTracker)
            if exist('PT1')
                delete(PT1);delete(PT2);delete(PT3);delete(PT4);
            end
            Zoom_Region=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(2)-Zoom_BoxSize_px/2,...
                Zoom_BoxSize_px,Zoom_BoxSize_px];
            [PT1,PT2,PT3,PT4,~]=PlotBox2(Zoom_Region,'-','w',1,[],[],[]);
        end
        figure(SelectionFig)
        axes(AX1)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DisplayMarker(src,eventdata,arg1)
        figure(SelectionFig)
        Marker_On = get(src,'Value'); 
        PlotMarkers;
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DisplayPoint(src,eventdata,arg1)
        figure(SelectionFig)
        Point_On = get(src,'Value'); 
        PlotPoints;
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DisplayBorders(src,eventdata,arg1)
        figure(SelectionFig)
        BorderOn = get(src,'Value'); 
        UpdateImage(Image)
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DisplayNumbers(src,eventdata,arg1)
       figure(SelectionFig)
       NumbersOn = get(src,'Value'); 
       PlotPoints;
       figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Select_Image(source,event)
        figure(SelectionFig)
        DataType = source.Value;
        set(Image_Selection,'Value',DataType)
        Image=Images{DataType}.Image;
        UpdateImage(Image)
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function MarkerRadius_Slider_callback(src,eventdata,arg1)
        figure(SelectionFig)
        Circle_Radius_um = get(src,'Value')*Max_Circle_Radius_um;
        if Circle_Radius_um<Min_Circle_Radius_um
            warning('Circle marker too small!')
            Circle_Radius_um=Min_Circle_Radius_um;
        end
        set(MarkerRadiusSlider,'Value',Circle_Radius_um/Max_Circle_Radius_um);
        Circle_Radius=((Circle_Radius_um*1000)/PixelSize_nm);
        set(MarkerRadiusSliderText,'String',['Marker Rad: ',num2str(Circle_Radius_um),'um']);
        PlotPoints;
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Contrast Settings
    function Contrast_Slider_callback(src,eventdata,arg1)
        figure(SelectionFig)
        HighContrast = get(src,'Value');
        HighContrast=round(HighContrast*100)/100;
        if HighContrast==0
            HighContrast=0.01;
        elseif HighContrast==1
            HighContrast=0.99;
        end
        set(Contrast_Text,'String',[' Max%: ',num2str(HighContrast*100),'%']);
        UpdateImage(Image)
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % RGB Balance
    function ColorBalance(src,eventdata,arg1)
        figure(SelectionFig)
        R=(str2num(get(R_Control,'String')));
        G=(str2num(get(G_Control,'String')));
        B=(str2num(get(B_Control,'String')));
        if R>1
            warning('Max R = 1')
            R=1;
        end
        if G>1
            warning('Max G = 1')
            G=1;
        end
        if B>1
            warning('Max B = 1')
            B=1;
        end
        if R<0
            warning('Min R = 0')
            R=0;
        end
        if G<0
            warning('Min G = 0')
            G=0;
        end
        if B<0
            warning('Min B = 0')
            B=0;
        end
        UpdateImage(Image)
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Position Adjustments
    function X_Scroll_callback(src,eventdata,arg1)
        figure(SelectionFig)
        if ZoomOn
            TempValue = get(X_Scroll,'Value');
            %TempValue= 1 - TempValue;
            Zoom_Coord(1) = TempValue*size(Image,2);
            XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
            YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
            %set(X_Scroll,'Value',Zoom_Coord(1)/size(Image,2))
            axes(AX1)
            xlim(XLims),ylim(YLims)
        else
            set(X_Scroll,'value',Zoom_Coord(1)/size(Image,2))
        end
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Y_Scroll_callback(src,eventdata,arg1)
        figure(SelectionFig)
        if ZoomOn
            TempValue = get(Y_Scroll,'Value');
            TempValue= 1 - TempValue;
            Zoom_Coord(2) = TempValue*size(Image,1);
            XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
            YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
            %set(Y_Scroll,'Value',Zoom_Coord(2)/size(Image,1))
            axes(AX1)
            xlim(XLims),ylim(YLims)
        else
            set(Y_Scroll,'value',Zoom_Coord(2)/size(Image,1))
        end
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Point Navigation Controls
    function Point_Slider_callback(src,eventdata,arg1)
        figure(SelectionFig)
        if isempty(Selecting)||Selecting
            fprintf('\n')
            warning('EXIT SELECTION MODE!!!!')
            set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1))
        else
            Point = round(get(src,'Value')*size(Coord_Struct.Coords,1));
            if Point<1
                fprintf('\n')
                warning('Unable to go to that Point...')
                Point=1;
                Zoom_Coord=Coord_Struct.Coords(Point,:);
                XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
                YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
                fprintf(['Current Point: ',num2str(Point)])
                set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
                PlotPoints;
                axes(AX1)
                xlim(XLims),ylim(YLims)
            elseif Point>size(Coord_Struct.Coords,1)
                fprintf('\n')
                warning('Unable to go to that Point...')
                Point=size(Coord_Struct.Coords,1);
                Zoom_Coord=Coord_Struct.Coords(Point,:);
                XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
                YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
                fprintf(['Current Point: ',num2str(Point)])
                set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
                PlotPoints;
                axes(AX1)
                xlim(XLims),ylim(YLims)
            else
                Point=round(Point);
                fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>'),fprintf(num2str(Point));fprintf('\n')
                Zoom_Coord=Coord_Struct.Coords(Point,:);
                XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
                YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
                fprintf(['Current Point: ',num2str(Point)])
                set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
                PlotPoints;
                axes(AX1)
                xlim(XLims),ylim(YLims)
                
            end
        end
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function PointAdvance
        figure(SelectionFig)
        if Point<size(Coord_Struct.Coords,1)
            Point=Point+1;
            set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1))
            fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>'),fprintf(num2str(Point));fprintf('\n')
            Zoom_Coord=Coord_Struct.Coords(Point,:);
            XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
            YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
            fprintf(['Current Point: ',num2str(Point)])
            set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
            PlotPoints;
            axes(AX1)
            xlim(XLims),ylim(YLims)
            
        else
            fprintf('\n')
            warning('Unable to move to NEXT Point')
            set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1))
            Zoom_Coord=Coord_Struct.Coords(Point,:);
            XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
            YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
            fprintf(['Current Point: ',num2str(Point)])
            set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
            PlotPoints;
            axes(AX1)
            xlim(XLims),ylim(YLims)
        end
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function PointRetreat
        figure(SelectionFig)
        if Point>1
            Point=Point-1;
            set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1))
            fprintf('<');pause(0.02);fprintf('<');pause(0.02);fprintf('<');pause(0.02);fprintf('<'),fprintf(num2str(Point));fprintf('\n')
            Zoom_Coord=Coord_Struct.Coords(Point,:);
            XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
            YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
            fprintf(['Current Point: ',num2str(Point)])
            set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
            PlotPoints;
            axes(AX1)
            xlim(XLims),ylim(YLims)
            
        else
            fprintf('\n')
            warning('Unable to move to PREVIOUS Point')
            set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1))
            Zoom_Coord=Coord_Struct.Coords(Point,:);
            XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
            YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
            fprintf(['Current Point: ',num2str(Point)])
            set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
            PlotPoints;
            axes(AX1)
            xlim(XLims),ylim(YLims)
            
        end
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Jump2Point(src,eventdata,arg1)
        figure(SelectionFig)
        Point1=round(str2num(get(PointControl,'String')));
        if Point1<=size(Coord_Struct.Coords,1)
            Point=Point1;
            set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1))
            fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>');pause(0.02);fprintf('>'),fprintf(num2str(Point));fprintf('\n')
            Zoom_Coord=Coord_Struct.Coords(Point,:);
            XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
            YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
            fprintf(['Current Point: ',num2str(Point)])
            set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
            PlotPoints;
            axes(AX1)
            xlim(XLims),ylim(YLims)
            
        else
            fprintf('\n')
            warning('Unable to move to that Point!')
            set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1))
            Zoom_Coord=Coord_Struct.Coords(Point,:);
            XLims=[Zoom_Coord(1)-Zoom_BoxSize_px/2,Zoom_Coord(1)+Zoom_BoxSize_px/2];
            YLims=[Zoom_Coord(2)-Zoom_BoxSize_px/2,Zoom_Coord(2)+Zoom_BoxSize_px/2];
            fprintf(['Current Point: ',num2str(Point)])
            set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
            PlotPoints;
            axes(AX1)
            xlim(XLims),ylim(YLims)
            
        end
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function MultiTagPoints(src,eventdata,arg1)
        figure(SelectionFig)
        Selecting=1;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','r','String',['Selecting: ON']);set(SelectionStatus_TL,'BackgroundColor','r','String',['Selecting: ON']);
        ExitSelection=0;
        while Selecting
            cont=1;
            while cont
                axes(AX1)
                Temp_Coords=[];
                while isempty(Temp_Coords)
                    Temp_Coords=ginput_ZN('g');
                    if isempty(Temp_Coords)
                        warning('Must Make Selection!!')
                    end
                end
                clear TempCoordList
                for addpoint=1:size(Temp_Coords)
                    axes(AX1)
                    hold on;
                    P1(addpoint)=plot(Temp_Coords(addpoint,1),Temp_Coords(addpoint,2),PointMarker{1},'color',Point_Overlay_Color,'MarkerSize',PointMarkerSize_Zoom);
                end
                axes(AX1)
                txt1=text(XLims(1)+20,YLims(1)+20,'<ENTER> to Accept ALL Points <1> to Delete','color',Point_Overlay_Color,'fontsize',20);

                cont=InputWithVerification('<ENTER> to Accept Points or <1> to clear selection: ',{[],[1]},0);
                axes(AX1);delete(txt1);
                for addpoint=1:size(Temp_Coords)
                    delete(P1(addpoint))
                end
                if cont
                    clear Temp_Coords
                    axes(AX1)
                    ExitSelection=1;
                    cont=0;
                    axes(AX1);
                else
                    set(Status_TR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
                    set(Status_TL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
                    set(Status_BR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
                    set(Status_BL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
                    %IMPORTANT ADDING TO NEW STRUCTURE!!
                    for addpoint=1:size(Temp_Coords)
                        Point=size(Coord_Struct.Coords,1);
                        Point=Point+1;
                        Coord_Struct.Coords(Point,1)=round(Temp_Coords(addpoint,1));
                        Coord_Struct.Coords(Point,2)=round(Temp_Coords(addpoint,2));
                    end
                    clear Temp_Coords
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    set(Status_TR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
                    set(Status_TL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
                    set(Status_BR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
                    set(Status_BL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
                    set(PointControl, 'string',num2str(Point))
                    set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1),...
                            'SliderStep',[1/size(Coord_Struct.Coords,1),5/size(Coord_Struct.Coords,1)])
                    set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
                    clear Temp_Coords 
                    fprintf(['Successfully Added! Number of Points: ',num2str(size(Coord_Struct.Coords,1)),'\n'])
                    Selecting=1;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','r','String',['Selecting: ON']);set(SelectionStatus_TL,'BackgroundColor','r','String',['Selecting: ON']);
%                     if rem(size(Coord_Struct.Coords,1),SaveInterval)==0
%                         warning('Saving Temp Backup File...')
%                         save('TempPointData.mat','size(Coord_Struct.Coords,1)','Coord_Struct');
%                     end
                    PlotPoints;
                end            
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            Coord_Struct.NumCoords=size(Coord_Struct.Coords,1);
            UpdatePointTracker
            figure(SelectionFig)
            set(PointControl, 'string',num2str(Point))
            set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1),...
                    'SliderStep',[1/size(Coord_Struct.Coords,1),5/size(Coord_Struct.Coords,1)])
            set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
            Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
            set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
            set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
            set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
            set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
            figure(SelectionFig)
            Pointing=0;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function TagPoints(src,eventdata,arg1)
        figure(SelectionFig)
        Selecting=1;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','r','String',['Selecting: ON']);set(SelectionStatus_TL,'BackgroundColor','r','String',['Selecting: ON']);
        ExitSelection=0;
        while Selecting
            cont=1;
            while cont
                axes(AX1)
                Temp_Coords=[];
                while isempty(Temp_Coords)
                    Temp_Coords=ginput_ZN('g',1);
                    if isempty(Temp_Coords)
                        warning('Must Make Selection!!')
                    end
                end
                clear TempCoordList
                hold on;P1=plot(Temp_Coords(1),Temp_Coords(2),PointMarker{1},'color',Point_Overlay_Color,'MarkerSize',PointMarkerSize_Zoom);
                axes(AX1)
                txt1=text(XLims(1)+20,YLims(1)+20,'<ENTER> to Accept Point <1> to Delete','color',Point_Overlay_Color,'fontsize',20);

                cont=InputWithVerification('<ENTER> to Accept Point or <1> to clear selection: ',{[],[1]},0);
                axes(AX1);delete(txt1);delete(P1)
                if cont
                    clear Temp_Coords
                    axes(AX1)
                    txt3=text(XLims(1)+10,YLims(1)+Zoom_BoxSize_px/2,'<ENTER> to Add Another Point or <1> to EXIT','color',Point_Overlay_Color,'fontsize',20);
                    ExitSelection=InputWithVerification('<ENTER> to Add Another Point or <1> to EXIT selection mode: ',{[],[1]},0);
                    if ExitSelection
                        cont=0;
                    end
                    axes(AX1);delete(txt3);
                else
                    set(Status_TR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
                    set(Status_TL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
                    set(Status_BR,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
                    set(Status_BL,'String',['Status: Busy'],'BackgroundColor','r');pause(0.0001);
                    %IMPORTANT ADDING TO NEW STRUCTURE!!
                    Point=size(Coord_Struct.Coords,1);
                    Point=Point+1;
                    Coord_Struct.Coords(Point,1)=round(Temp_Coords(1));
                    Coord_Struct.Coords(Point,2)=round(Temp_Coords(2));
                    clear Temp_Coords
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    set(Status_TR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
                    set(Status_TL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
                    set(Status_BR,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
                    set(Status_BL,'String',['Status: Busy...'],'BackgroundColor','r');pause(0.0001);
                    set(PointControl, 'string',num2str(Point))
                    set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1),...
                            'SliderStep',[1/size(Coord_Struct.Coords,1),5/size(Coord_Struct.Coords,1)])
                    set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
                    clear Temp_Coords 
                    fprintf(['Successfully Added! Number of Points: ',num2str(size(Coord_Struct.Coords,1)),'\n'])
                    Selecting=1;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','r','String',['Selecting: ON']);set(SelectionStatus_TL,'BackgroundColor','r','String',['Selecting: ON']);
%                     if rem(size(Coord_Struct.Coords,1),SaveInterval)==0
%                         warning('Saving Temp Backup File...')
%                         save('TempPointData.mat','size(Coord_Struct.Coords,1)','Coord_Struct');
%                     end
                    PlotPoints;
                end            
            end
            
            if ExitSelection
                Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
            else
                axes(AX1)
                txt3=text(XLims(1)+10,YLims(1)+Zoom_BoxSize_px/2,'<ENTER> to Add Another Point or <1> to EXIT','color',Point_Overlay_Color,'fontsize',20);
                AddMore=InputWithVerification('<ENTER> to Add Another Point or <1> to EXIT selection mode: ',{[],[1]},0);
                if isempty(AddMore)
                    Selecting=1;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','r','String',['Selecting: ON']);set(SelectionStatus_TL,'BackgroundColor','r','String',['Selecting: ON']);
                else
                    Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
                end
                axes(AX1);delete(txt3);
            end
            %Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Coord_Struct.NumCoords=size(Coord_Struct.Coords,1);
        UpdatePointTracker
        figure(SelectionFig)
        set(PointControl, 'string',num2str(Point))
        set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1),...
                'SliderStep',[1/size(Coord_Struct.Coords,1),5/size(Coord_Struct.Coords,1)])
        set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
        Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        figure(SelectionFig)
        Pointing=0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DeletePoints(src,eventdata,arg1)
        figure(SelectionFig)
        Selecting=1;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','r','String',['Selecting: ON']);set(SelectionStatus_TL,'BackgroundColor','r','String',['Selecting: ON']);
        if ~NumbersOn
            NumbersOn=1;
            set(DisplayNumbersButton,'Value',NumbersOn); 
            PlotPoints;
        end
        
        CurrentPoint=Point;
        fprintf(['Number of Points: ',num2str(size(Coord_Struct.Coords,1)),'\n'])
        Point2Delete=InputWithVerification('Point # To Delete (<Enter> Skips): ',{[],[1:size(Coord_Struct.Coords,1)]},0);
        if ~isempty(Point2Delete)
            set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            disp(['Deleting Point #',num2str(Point2Delete)])
            count=0;
            clear TempStruct
            TempStruct=[];
            for i=1:size(Coord_Struct.Coords,1)
                if i~=Point2Delete
                    count=count+1;
                    TempStruct.Coords(count,:)=Coord_Struct.Coords(i,:);
                else
                    warning(['Removing Point #',num2str(i)])
                end
            end
            if length(TempStruct.Coords)~=size(Coord_Struct.Coords,1)-1
                error('Deletion did not work...')
            else
                Coord_Struct=TempStruct;
                clear TempStruct
                fprintf(['Number of Points AFTER DELETING: ',num2str(size(Coord_Struct.Coords,1)),'\n'])
            end
        end
        set(Status_TR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        Coord_Struct.NumCoords=size(Coord_Struct.Coords,1);
        if CurrentPoint>size(Coord_Struct.Coords,1)
            Point=size(Coord_Struct.Coords,1);
        else
           Point=CurrentPoint; 
        end
        clear CurrentPoint
        UpdatePointTracker
        figure(SelectionFig)
        set(PointControl, 'string',num2str(Point))
        set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1),...
                'SliderStep',[1/size(Coord_Struct.Coords,1),5/size(Coord_Struct.Coords,1)])
        set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))

        Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        PlotPoints;
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DeleteRange(src,eventdata,arg1)
        figure(SelectionFig)
        if ~NumbersOn
            NumbersOn=1;
            set(DisplayNumbersButton,'Value',NumbersOn); 
            PlotPoints;
        end
        Selecting=1;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','r','String',['Selecting: ON']);set(SelectionStatus_TL,'BackgroundColor','r','String',['Selecting: ON']);
        CurrentPoint=Point;
        fprintf(['Number of Points: ',num2str(size(Coord_Struct.Coords,1)),'\n'])
        commandwindow
        fprintf('Deleting a range of Points...\n')
        %disp('First Point # To Delete: ')
        FirstPoint2Delete=InputWithVerification('First Point # To Delete: ',{[],[1:size(Coord_Struct.Coords,1)]},0);
        %disp('Last Point # To Delete: ')
        LastPoint2Delete=InputWithVerification('Last Point # To Delete: ',{[],[1:size(Coord_Struct.Coords,1)]},0);
        if ~isempty(FirstPoint2Delete)&&~isempty(LastPoint2Delete)
            if LastPoint2Delete>FirstPoint2Delete
                Points2Delete=[FirstPoint2Delete:LastPoint2Delete];
                %Points2Delete=fliplr(Points2Delete);
            else
                Points2Delete=[];
            end
        else
            Points2Delete=[];
        end
        if ~isempty(Points2Delete)
            set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
            disp(['Deleting Points: ',num2str(Points2Delete)])
            count=0;
            clear TempStruct
            TempStruct=[];
            for i=1:size(Coord_Struct.Coords,1)
                if i~=Points2Delete
                    count=count+1;
                    TempStruct.Coords(count,:)=Coord_Struct.Coords(i,:);
                else
                    warning(['Removing Point #',num2str(i)])
                end
            end
            if length(TempStruct.Coords)~=size(Coord_Struct.Coords,1)-length(Points2Delete)
                error('Deletion did not work...')
            else
                Coord_Struct=TempStruct;
                clear TempStruct
                fprintf(['Number of Points AFTER DELETING: ',num2str(size(Coord_Struct.Coords,1)),'\n'])
            end
        end
        set(Status_TR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_TL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        set(Status_BL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
        Coord_Struct.NumCoords=size(Coord_Struct.Coords,1);
        if CurrentPoint>size(Coord_Struct.Coords,1)
            Point=size(Coord_Struct.Coords,1);
        else
           Point=CurrentPoint; 
        end
        clear CurrentPoint
        UpdatePointTracker
        figure(SelectionFig)
        set(PointControl, 'string',num2str(Point))
        set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1),...
                'SliderStep',[1/size(Coord_Struct.Coords,1),5/size(Coord_Struct.Coords,1)])
        set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))

        Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        PlotPoints;
        figure(SelectionFig)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Delete(src,eventdata,arg1)
        CurrentPoint=Point;
        figure(SelectionFig)
        axes(AX1)
        FindCoord=ginput_ZN('r');
        TempPlots=[];
        PlotCount=0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for del=1:size(FindCoord,1)
            TempDistances=[];
            for Point2=1:size(Coord_Struct.Coords,1)
                TempDistances(Point2)=...
                    sqrt((Coord_Struct.Coords(Point2,1)-FindCoord(del,1))^2+(Coord_Struct.Coords(Point2,2)-FindCoord(del,2))^2);
            end
            [~,FindPoint] = min(TempDistances);
            axes(AX1)
            hold on
            PlotCount=PlotCount+1;
            TempPlots(PlotCount)=plot(Coord_Struct.Coords(FindPoint,1),Coord_Struct.Coords(FindPoint,2),'*','color','r','markersize',12);

            if ~isempty(FindPoint)
                set(Status_TR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
                set(Status_TL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
                set(Status_BR,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
                set(Status_BL,'String',['Status: Busy.'],'BackgroundColor','r');pause(0.0001);
                disp(['Deleting Point #',num2str(FindPoint)])
                count=0;
                clear TempStruct
                TempStruct=[];
                for i=1:size(Coord_Struct.Coords,1)
                    if i~=FindPoint
                        count=count+1;
                        TempStruct.Coords(count,:)=Coord_Struct.Coords(i,:);
                    else
                        warning(['Removing Point #',num2str(i)])
                    end
                end
                if length(TempStruct.Coords)~=size(Coord_Struct.Coords,1)-1
                    error('Deletion did not work...')
                else
                    Coord_Struct=TempStruct;
                    clear TempStruct
                    fprintf(['Number of Points AFTER DELETING: ',num2str(size(Coord_Struct.Coords,1)),'\n'])
                end
            end
            set(Status_TR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
            set(Status_TL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
            set(Status_BR,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
            set(Status_BL,'String',['Status: Busy..'],'BackgroundColor','r');pause(0.0001);
            Coord_Struct.NumCoords=size(Coord_Struct.Coords,1);
            if CurrentPoint>size(Coord_Struct.Coords,1)
                Point=size(Coord_Struct.Coords,1);
            else
               Point=CurrentPoint; 
            end
            clear CurrentPoint
            UpdatePointTracker
            figure(SelectionFig)
            set(PointControl, 'string',num2str(Point))
            set(PointSlider,'Value',Point/size(Coord_Struct.Coords,1),...
                    'SliderStep',[1/size(Coord_Struct.Coords,1),5/size(Coord_Struct.Coords,1)])
            set(SliderText,'String',['Point: ',num2str(Point),'/',num2str(size(Coord_Struct.Coords,1))]);set(PointControl,'String',num2str(Point))
            clear NewCoord TempDistances FindPoint
            CurrentPoint=Point;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Selecting=0;set(SelectingButton,'value',Selecting);set(SelectionStatus_TR,'BackgroundColor','g','String',['Selecting: OFF']);set(SelectionStatus_TL,'BackgroundColor','g','String',['Selecting: OFF']);
        set(Status_TR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_TL,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BR,'String',['Status: Waiting'],'BackgroundColor','g');
        set(Status_BL,'String',['Status: Waiting'],'BackgroundColor','g');
        PlotPoints;
        for p=1:length(TempPlots)
            delete(TempPlots(p))
        end
        figure(SelectionFig)
        xlim(XLims),ylim(YLims)
        clear FindCoord TempPlots
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Shift(src,eventdata,arg1)
        figure(SelectionFig)
        axes(AX1)
        FindCoord=ginput_ZN('y',1);
        TempDistances=[];
        for Point2=1:size(Coord_Struct.Coords,1)
            TempDistances(Point2)=...
                sqrt((Coord_Struct.Coords(Point2,1)-FindCoord(1))^2+(Coord_Struct.Coords(Point2,2)-FindCoord(2))^2);
        end
        [~,FindPoint] = min(TempDistances);
        axes(AX1)
        hold on
        TempPlot1=plot(Coord_Struct.Coords(FindPoint,1),Coord_Struct.Coords(FindPoint,2),'*','color','k','markersize',13);
        TempPlot2=plot(Coord_Struct.Coords(FindPoint,1),Coord_Struct.Coords(FindPoint,2),'o','color','k','markersize',6);
        TempPlot3=plot(Coord_Struct.Coords(FindPoint,1),Coord_Struct.Coords(FindPoint,2),'*','color','y','markersize',13);
        TempPlot4=plot(Coord_Struct.Coords(FindPoint,1),Coord_Struct.Coords(FindPoint,2),'*','color','y','markersize',5);
        NewCoord=ginput_ZN('y',1);
        Coord_Struct.Coords(FindPoint,:)=NewCoord;
        delete(TempPlot1);delete(TempPlot2);delete(TempPlot3);delete(TempPlot4)
        figure(SelectionFig)
        axes(AX1)
        xlim(XLims),ylim(YLims)
        
        PlotPoints
        
        clear FindCoord NewCoord TempDistances FindPoint
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ForceUpdateImage(src,eventdata,arg1)
        UpdateImage(Image)
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
            SureExit=InputWithVerification('Are you sure you want to exit? <1> will return...',{[],[1]},0);
            if isempty(SureExit)
                SureExit=0;
            end
            if SureExit
            else
                global CIRCLE_RADIUS_UM
                CIRCLE_RADIUS_UM=Circle_Radius_um;

                global COORD_STRUCT
                COORD_STRUCT=Coord_Struct;
                
                close(SelectionFig)
                close(PointTracker)
                jheapcl
                fprintf(['Exiting Function...\n'])
                fprintf(['Number of Points: ',num2str(size(Coord_Struct.Coords,1)),'\n'])
                warning('Press master switch when finished to finalize changes!')
                warning('Press master switch when finished to finalize changes!')
                warning('Press master switch when finished to finalize changes!')
                warning('Press master switch when finished to finalize changes!')
                warning('Press master switch when finished to finalize changes!')
                warning('Press master switch when finished to finalize changes!')
                warning('Press master switch when finished to finalize changes!')
            end
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
