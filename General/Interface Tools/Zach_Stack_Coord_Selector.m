function Zach_Stack_Coord_Selector(ImageArray,SelectionData)
        disp('=============================================================================================');
        disp('=============================================================================================');
        ImageArrayDimensions=size(ImageArray);
        if length(ImageArrayDimensions)>3
            warning('Color Stack Settings')
            if ImageArrayDimensions(3)~=3
                error('Must put color axis in 3rd dimension')
            end
            ColorStack=1;
        elseif length(ImageArrayDimensions)==3
            ColorStack=0;
        else
            error('must provide at least 3 dimension stack!') 
        end

        warning on all
        warning off verbose
        warning off backtrace

        DataClass=class(ImageArray);

        
        disp('Welcome to the Stack Viewer!');
        disp(['Image Stack Class: ',DataClass]);
        disp('Instructions: ');
        disp('     <L/R Arrows> will navigate frames');
        disp('     <U/D Arrows> will alter the upper contrast limits');
        disp('     <SPACE> will Play/Pause');
        disp('     <SHIFT> will TAG');
        disp('     <CTRL> will EXIT');
        disp('     Manual Controls: For Manually Adjusting <FPS>, <INDEX>,');
        disp('                      <H>(High Contrast), <L>(Low Contrast)');
        disp('                      Type in the desired value within the box');
        disp('                      and then click the respective button');
        disp('                      to register the change');
        disp('                      which should occur immediately');
        disp('                      even during playback');
        disp('     Zooming: Clicking Zoom will provide an ROI selection tool');
        disp('              to define the Zoom area');
        disp('              Select a region by connecting the dots.');
        disp('              When a complete region is selected');
        disp('              right click and select create mask to establish the ROI');
        disp('              and when the Zoom button is pressed again it will return');
        disp('              to the original un-zoomed image');
        disp('     NOTE: FPS is not accurate, more of a relative guide to playback speed');
        disp('=============================================================================================');
        disp('=============================================================================================');

        if ColorStack
            LastIndexNumber=size(ImageArray,4);
        else
            LastIndexNumber=size(ImageArray,3);
        end
        ImageHeight=size(ImageArray,1);
        ImageWidth=size(ImageArray,2);

        IndexNumber=1;
        PlayBack=0;
        FPS=20;
        Point_Marker='o';
        Point_Color='m';
        Point_MarkerSize=10;
        if strcmp(DataClass,'double')||strcmp(DataClass,'single')
            ContrastOptions=[min(ImageArray(:))-max(ImageArray(:))*0.5,max(ImageArray(:))*1.5];
            StepUnits=[0.05,0.1];
        elseif strcmp(DataClass,'uint64')||strcmp(DataClass,'int64')
            ContrastOptions=[0,2^64-1];
            StepUnits=[0.01,0.05];
        elseif strcmp(DataClass,'uint32')||strcmp(DataClass,'int32')
            ContrastOptions=[0,2^32-1];
            StepUnits=[0.01,0.05];
        elseif strcmp(DataClass,'uint16')||strcmp(DataClass,'int16')
            ContrastOptions=[0,2^16-1];
            StepUnits=[0.01,0.05];
        elseif strcmp(DataClass,'uint8')||strcmp(DataClass,'int8')
            ContrastOptions=[0,2^8-1];
            StepUnits=[0.01,0.05];
        elseif strcmp(DataClass,'logical')
            ContrastOptions=[0,1];
            StepUnits=[0.01,0.05];
        else
            error('Unknown File Type')
        end


        ZoomOn=0;
        
        InitialContrastScalar=0.5;
        Display_Limits=[0,max(ImageArray(:))*InitialContrastScalar];
        MaxVal=max(ImageArray(:));
        DisplayColorMap=1;
        ColorMapOptions={'jet','parula','gray','hsv','hot','cool','spring','summer','autumn','winter','bone','copper','pink','lines','colorcube','prism','flag','white'};

        ZoomRegion_Props.BoundingBox=[1,1,ImageWidth,ImageHeight];

        for i=1:length(SelectionData)
            SelectionData(i).XCoords_Adjusted=SelectionData(i).XCoords-(ZoomRegion_Props.BoundingBox(1)-1);
            SelectionData(i).YCoords_Adjusted=SelectionData(i).YCoords-(ZoomRegion_Props.BoundingBox(2)-1);
            SelectionData(i).ZCoords_Adjusted=SelectionData(i).ZCoords;
        end

        
        %initialize figure
        ViewerFig=figure;
        set(ViewerFig,'units','normalized','position',[0.05 0.05 0.8 0.8],'name',['Index #: ',num2str(IndexNumber)])
        if ColorStack
            CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
        else
            CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
        end
        ImageDisplay(CurrentImage);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Create UI elements
            for zzzzzz=1:1
            Instructions = uicontrol('Style','text',...
                'units','normalized',...
                'Position',[0.01 0.985 0.75 0.015],...
                'String','Instructions: <L/R Arrows> navigate, <U/D Arrows> Contrast, <SPACE> Play/Pause, <Shift> Tag <CTRL> will EXIT');

            % Create slider
            sld = uicontrol('Style', 'slider',...
                'Min',1,'Max',LastIndexNumber,'Value',1,...
                'SliderStep',[1/(LastIndexNumber- 1),10/(LastIndexNumber- 1)],...
                'units','normalized',...
                'Position', [0.85 0.985 0.15 0.015],...
                'Callback', @slider_callback);
            txt = uicontrol('Style','text',...
                'units','normalized',...
                'Position',[0.85 0.97 0.025 0.015],...
                'String','Index #');
           % Create push button for playing stack
            btn3 = uicontrol('Style', 'pushbutton', 'String', 'PLAY',...
                'units','normalized',...
                'Position', [0.94 0.95 0.03 0.03],...
                'Callback', @StartPlayStack_callback);  
             % Create field for setting speed
            FPS_Ctl = uicontrol('Style', 'edit', 'string',num2str(FPS),...
                'units','normalized',...
                'Position', [0.98 0.93 0.02 0.02]);      
            btn6 = uicontrol('Style', 'pushbutton', 'String', '~FPS ^',...
                'units','normalized',...
                'Position', [0.96 0.90 0.035 0.025],...
                'Callback', @ChangeSpeed_callback); 

            btn4 = uicontrol('Style', 'pushbutton', 'String', 'PAUSE',...
                'units','normalized',...
                'Position', [0.97 0.95 0.03 0.03],...
                'Callback', @PausePlayStack_callback);  

            btn5 = uicontrol('Style', 'togglebutton', 'String', 'Zoom',...
                'units','normalized',...
                'value',0,...
                'Position', [0.95 0.925 0.03 0.025],...
                'Callback', @Zoom_callback);   
            % Create field for setting index position
            index = uicontrol('Style', 'edit', 'string',num2str(IndexNumber),...
                'units','normalized',...
                'Position', [0.96 0.88 0.04 0.02]);      
            btn5 = uicontrol('Style', 'pushbutton', 'String', 'Index^',...
                'units','normalized',...
                'Position', [0.97 0.85 0.03 0.03],...
                'Callback', @JumpToIndex_callback);
            % Create pop-up menu
             popup1 = uicontrol('Style', 'popup',...
                   'String', ColorMapOptions,...
                    'units','normalized',...
                    'Position', [0.955 0.79 0.045 0.05],...
                   'Callback', @setmap);    
            % Create Contrast Sliders
            if ~ColorStack
                HighSld = uicontrol('Style', 'slider',...
                    'Min',ContrastOptions(1),'Max',ContrastOptions(2),'Value',Display_Limits(2),...
                    'SliderStep',StepUnits,...
                    'units','normalized',...
                    'Position', [0.985,0.65 0.015 0.15],...
                    'Callback', @HighContrast_callback);
                HighDisp = uicontrol('Style', 'edit', 'string',num2str(Display_Limits(2)),...
                    'units','normalized',...
                    'Position', [0.95,0.63 0.05 0.02]);      
                btn5 = uicontrol('Style', 'pushbutton', 'String', 'H^',...
                    'units','normalized',...
                    'Position', [0.98 0.605 0.02 0.02],...
                    'Callback', @SetHighContrast_callback);
                LowSld = uicontrol('Style', 'slider',...
                    'Min',ContrastOptions(1),'Max',ContrastOptions(2),'Value',Display_Limits(1),...
                    'SliderStep',StepUnits,...
                    'units','normalized',...
                    'Position', [0.985,0.45 0.015 0.15],...
                    'Callback', @LowContrast_callback);
                LowDisp = uicontrol('Style', 'edit', 'string',num2str(Display_Limits(1)),...
                    'units','normalized',...
                    'Position', [0.95 0.43 0.05 0.02]);      
                btn5 = uicontrol('Style', 'pushbutton', 'String', 'L^',...
                    'units','normalized',...
                    'Position', [0.98 0.405 0.02 0.02],...
                    'Callback', @SetLowContrast_callback);
            end
            btn10 = uicontrol('Style', 'pushbutton', 'String', 'Tag',...
                'units','normalized',...
                'Position', [0.96 0.03 0.04 0.03],...
                'Callback', @TagPoints);
            btn0 = uicontrol('Style', 'pushbutton', 'String', 'Exit',...
                'units','normalized',...
                'Position', [0.96 0 0.04 0.03],...
                'Callback', @Exit_Callback);
            set(ViewerFig,'WindowKeyPressFcn',@Navigation_KeyPressFcn)
            end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            function setmap(source,event)
                DisplayColorMap = source.Value;
                if DisplayColorMap<1||DisplayColorMap>length(ColorMapOptions)
                    warning('Not possible')
                else
                    ImageDisplay(CurrentImage);
                    set(sld,'Value',IndexNumber)
                end
            end
            function JumpToIndex_callback(src,eventdata,arg1)
                IndexNumber=str2num(get(index,'String'));
                if ZoomOn
                    if ColorStack
                        CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    else
                        CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    end
                else
                    if ColorStack
                        CurrentImage=ImageArray(:,:,:,IndexNumber);
                    else
                        CurrentImage=ImageArray(:,:,IndexNumber);
                    end
                end
                ImageDisplay(CurrentImage);
                set(sld,'Value',IndexNumber)

            end
            function ChangeSpeed_callback(src,eventdata,arg1)
                FPS=str2num(get(index,'String'));
                set(FPS_Ctl,'Value',FPS)
                if ZoomOn
                    if ColorStack
                        CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    else
                        CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    end
                    ImageDisplay(CurrentImage);
                else
                    if ColorStack
                        ImageDisplay(ImageArray(:,:,:,IndexNumber));
                    else
                        ImageDisplay(ImageArray(:,:,IndexNumber));
                    end
                end
            end
            function slider_callback(src,eventdata,arg1)
                IndexNumber = get(src,'Value');
                IndexNumber=round(IndexNumber);
                if ZoomOn
                    if ColorStack
                        CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    else
                        CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    end
                    ImageDisplay(CurrentImage);
                else
                    if ColorStack
                        ImageDisplay(ImageArray(:,:,:,IndexNumber));
                    else
                        ImageDisplay(ImageArray(:,:,IndexNumber));
                    end
                end
                set(index,'String',num2str(IndexNumber))
            end
            function StartPlayStack_callback(src,eventdata,arg1)
                PlayBack=1;
                while PlayBack
                    if IndexNumber==LastIndexNumber
                        IndexNumber=1;
                    else
                        IndexNumber=IndexNumber+1;
                    end
                    set(sld,'Value',IndexNumber)
                    set(index,'String',num2str(IndexNumber))
                    if ZoomOn
                        if ColorStack
                            CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        else
                            CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        end
                        ImageDisplay(CurrentImage);
                    else
                        if ColorStack
                            ImageDisplay(ImageArray(:,:,:,IndexNumber));
                        else
                            ImageDisplay(ImageArray(:,:,IndexNumber));
                        end
                    end
                    pause(1/FPS)
                end
            end
            function PausePlayStack_callback(src,eventdata,arg1)
                PlayBack=0;
            end
            function Zoom_callback(src,eventdata,arg1)
               ZoomIn = get(src,'Value');    
               WasPlaying=PlayBack;
               if WasPlaying
                   PausePlayStack_callback;
               end
                if ZoomIn
                    ZoomOn=1;
                    drawnow;
                    ZoomRegion = roipoly;
                    ZoomRegion_Props = regionprops(double(ZoomRegion), 'BoundingBox');clear ZoomRegion
                    SelectionData(i).XCoords_Adjusted=[];
                    SelectionData(i).YCoords_Adjusted=[];
                    SelectionData(i).ZCoords_Adjusted=[];
                    for iii=1:length(SelectionData)
                        for jjj=1:length(SelectionData(i).XCoords)
                            TempXCoord=SelectionData(i).XCoords(jjj)-(ZoomRegion_Props.BoundingBox(1)-1);
                            TempYCoord=SelectionData(i).YCoords(jjj)-(ZoomRegion_Props.BoundingBox(2)-1);
                            if TempXCoord>0&&TempXCoord<=ZoomRegion_Props.BoundingBox(3)&&...
                                    TempYCoord>0&&TempYCoord<=ZoomRegion_Props.BoundingBox(4)
                                SelectionData(i).XCoords_Adjusted=[SelectionData(i).XCoords_Adjusted,TempXCoord];
                                SelectionData(i).YCoords_Adjusted=[SelectionData(i).YCoords_Adjusted,TempYCoord];
                                SelectionData(i).ZCoords_Adjusted=[SelectionData(i).ZCoords_Adjusted,SelectionData(i).ZCoords(jjj)];
                            end
                        end
                    end
                else
                    ZoomOn=0;
                    ZoomRegion_Props.BoundingBox=[1,1,ImageHeight,ImageWidth];
                    SelectionData(i).XCoords_Adjusted=[];
                    SelectionData(i).YCoords_Adjusted=[];
                    SelectionData(i).ZCoords_Adjusted=[];
                    for iii=1:length(SelectionData)
                        for jjj=1:length(SelectionData(i).XCoords)
                            TempXCoord=SelectionData(i).XCoords(jjj)-(ZoomRegion_Props.BoundingBox(1)-1);
                            TempYCoord=SelectionData(i).YCoords(jjj)-(ZoomRegion_Props.BoundingBox(2)-1);
                            if TempXCoord>0&&TempXCoord<=ZoomRegion_Props.BoundingBox(3)&&...
                                    TempYCoord>0&&TempYCoord<=ZoomRegion_Props.BoundingBox(4)
                                SelectionData(i).XCoords_Adjusted=[SelectionData(i).XCoords_Adjusted,TempXCoord];
                                SelectionData(i).YCoords_Adjusted=[SelectionData(i).YCoords_Adjusted,TempYCoord];
                                SelectionData(i).ZCoords_Adjusted=[SelectionData(i).ZCoords_Adjusted,SelectionData(i).ZCoords(jjj)];
                            end
                        end
                    end
                end
                if ZoomOn
                    if ColorStack
                        CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    else
                        CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    end
                    ImageDisplay(CurrentImage);
                else
                    if ColorStack
                        ImageDisplay(ImageArray(:,:,:,IndexNumber));
                    else
                        ImageDisplay(ImageArray(:,:,IndexNumber));
                    end
                end
                if WasPlaying
                    StartPlayStack_callback;
                end
            end
            function ImageDisplay(CurrentImage)
                set(ViewerFig,'name',['Index #: ',num2str(IndexNumber)])
                cla
                subtightplot(1,1,1,[0.01,0.01],[0.01,0.05],[0.01,0.05])
                if ~ColorStack
                    imagesc(CurrentImage),axis equal tight
                    hold on
                    for ii=1:length(SelectionData)
                        if ZoomOn
                            for jj=1:length(SelectionData(ii).XCoords_Adjusted)
                                if SelectionData(ii).ZCoords_Adjusted(jj)==IndexNumber
                                    if ~isempty(SelectionData(ii).MarkerStyle)&&isempty(SelectionData(ii).LineStyle)
                                        plot(SelectionData(ii).XCoords_Adjusted(jj),SelectionData(ii).YCoords_Adjusted(jj),...
                                            SelectionData(ii).MarkerStyle,'markersize',SelectionData(ii).MarkerSize,'color',SelectionData(ii).Color);
                                    elseif ~isempty(SelectionData(ii).LineStyle)
                                        plot(SelectionData(ii).XCoords_Adjusted(jj),SelectionData(ii).YCoords_Adjusted(jj),...
                                            SelectionData(ii).LineStyle,'linewidth',SelectionData(ii).LineWidth,'color',SelectionData(ii).Color);
                                    else
                                        plot(SelectionData(ii).XCoords_Adjusted(jj),SelectionData(ii).YCoords_Adjusted(jj),...
                                            [SelectionData(ii).MarkerStyle,SelectionData(ii).LineStyle],...
                                            'markersize',SelectionData(ii).MarkerSize,...
                                            'linewidth',SelectionData(ii).LineWidth,'color',SelectionData(ii).Color);
                                    end
                                end
                            end
                        else
                            for jj=1:length(SelectionData(ii).XCoords)
                                if SelectionData(ii).ZCoords(jj)==IndexNumber
                                    if ~isempty(SelectionData(ii).MarkerStyle)&&isempty(SelectionData(ii).LineStyle)
                                        plot(SelectionData(ii).XCoords(jj),SelectionData(ii).YCoords(jj),...
                                            SelectionData(ii).MarkerStyle,'markersize',SelectionData(ii).MarkerSize,'color',SelectionData(ii).Color);
                                    elseif ~isempty(SelectionData(ii).LineStyle)
                                        plot(SelectionData(ii).XCoords(jj),SelectionData(ii).YCoords(jj),...
                                            SelectionData(ii).LineStyle,'linewidth',SelectionData(ii).LineWidth,'color',SelectionData(ii).Color);
                                    else
                                        plot(SelectionData(ii).XCoords(jj),SelectionData(ii).YCoords(jj),...
                                            [SelectionData(ii).MarkerStyle,SelectionData(ii).LineStyle],...
                                            'markersize',SelectionData(ii).MarkerSize,...
                                            'linewidth',SelectionData(ii).LineWidth,'color',SelectionData(ii).Color);
                                    end
                                end
                            end
                        end
                    end
                    colormap(ColorMapOptions{DisplayColorMap});
                    caxis(Display_Limits);
                    hcb2=colorbar('location','East','position',[0.98 0.20 0.01 0.15],'color','k','axislocation','in');
                    set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
                    hold off
                    drawnow;
                else
                    imshow(CurrentImage,[])
                    hold on
                    for ii=1:length(SelectionData)
                        if ZoomOn
                            for jj=1:length(SelectionData(ii).XCoords_Adjusted)
                                if SelectionData(ii).ZCoords_Adjusted(jj)==IndexNumber
                                    if ~isempty(SelectionData(ii).MarkerStyle)&&isempty(SelectionData(ii).LineStyle)
                                        plot(SelectionData(ii).XCoords_Adjusted(jj),SelectionData(ii).YCoords_Adjusted(jj),...
                                            SelectionData(ii).MarkerStyle,'markersize',SelectionData(ii).MarkerSize,'color',SelectionData(ii).Color);
                                    elseif ~isempty(SelectionData(ii).LineStyle)
                                        plot(SelectionData(ii).XCoords_Adjusted(jj),SelectionData(ii).YCoords_Adjusted(jj),...
                                            SelectionData(ii).LineStyle,'linewidth',SelectionData(ii).LineWidth,'color',SelectionData(ii).Color);
                                    else
                                        plot(SelectionData(ii).XCoords_Adjusted(jj),SelectionData(ii).YCoords_Adjusted(jj),...
                                            [SelectionData(ii).MarkerStyle,SelectionData(ii).LineStyle],...
                                            'markersize',SelectionData(ii).MarkerSize,...
                                            'linewidth',SelectionData(ii).LineWidth,'color',SelectionData(ii).Color);
                                    end
                                end
                            end
                        else
                            for jj=1:length(SelectionData(ii).XCoords)
                                if SelectionData(ii).ZCoords(jj)==IndexNumber
                                    if ~isempty(SelectionData(ii).MarkerStyle)&&isempty(SelectionData(ii).LineStyle)
                                        plot(SelectionData(ii).XCoords(jj),SelectionData(ii).YCoords(jj),...
                                            SelectionData(ii).MarkerStyle,'markersize',SelectionData(ii).MarkerSize,'color',SelectionData(ii).Color);
                                    elseif ~isempty(SelectionData(ii).LineStyle)
                                        plot(SelectionData(ii).XCoords(jj),SelectionData(ii).YCoords(jj),...
                                            SelectionData(ii).LineStyle,'linewidth',SelectionData(ii).LineWidth,'color',SelectionData(ii).Color);
                                    else
                                        plot(SelectionData(ii).XCoords(jj),SelectionData(ii).YCoords(jj),...
                                            [SelectionData(ii).MarkerStyle,SelectionData(ii).LineStyle],...
                                            'markersize',SelectionData(ii).MarkerSize,...
                                            'linewidth',SelectionData(ii).LineWidth,'color',SelectionData(ii).Color);
                                    end
                                end
                            end
                        end
                    end
                    colormap(ColorMapOptions{DisplayColorMap});
                    caxis(Display_Limits);
                    hcb2=colorbar('location','East','position',[0.98 0.20 0.01 0.15],'color','k','axislocation','in');
                    set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
                    hold off
                    drawnow;
                end
                figure(ViewerFig);
            end
            function HighContrast_callback(src,eventdata,arg1)
                temp = get(src,'Value');
                if temp<=Display_Limits(1)
                    warning('Not possible')
                    set(src,'Value',Display_Limits(2))
                    if ZoomOn
                        if ColorStack
                            CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        else
                            CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        end
                        ImageDisplay(CurrentImage);
                    else
                        if ColorStack
                            ImageDisplay(ImageArray(:,:,:,IndexNumber));
                        else
                            ImageDisplay(ImageArray(:,:,IndexNumber));
                        end
                    end
                else
                    Display_Limits(2)=temp;clear temp
                    set(HighDisp,'String',num2str(Display_Limits(2)))
                    if ZoomOn
                        if ColorStack
                            CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        else
                            CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        end
                        ImageDisplay(CurrentImage);
                    else
                        if ColorStack
                            ImageDisplay(ImageArray(:,:,:,IndexNumber));
                        else
                            ImageDisplay(ImageArray(:,:,IndexNumber));
                        end
                    end
                end
            end
            function SetHighContrast_callback(src,eventdata,arg1)
                temp = str2num(get(index,'String'));
                if temp<=Display_Limits(1)
                    warning('Not possible')
                    if ColorStack
                        CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    else
                        CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    end
                    ImageDisplay(CurrentImage);
                else
                    Display_Limits(2)=temp;clear temp
                    set(HighDisp,'String',num2str(Display_Limits(2)))
                    if ZoomOn
                        ImageDisplay(CurrentImage);
                    else
                        if ColorStack
                            ImageDisplay(ImageArray(:,:,:,IndexNumber));
                        else
                            ImageDisplay(ImageArray(:,:,IndexNumber));
                    end
                    end
                end
            end
            function LowContrast_callback(src,eventdata,arg1)
                temp = get(src,'Value');
                if Display_Limits(2)<=temp
                    warning('Not possible')
                    if ZoomOn
                        if ColorStack
                            CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        else
                            CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        end
                        ImageDisplay(CurrentImage);
                    else
                        if ColorStack
                            ImageDisplay(ImageArray(:,:,:,IndexNumber));
                        else
                            ImageDisplay(ImageArray(:,:,IndexNumber));
                        end
                    end
                else
                    Display_Limits(1)=temp;clear temp
                    set(LowDisp,'String',num2str(Display_Limits(1)))
                    if ZoomOn
                        if ColorStack
                            CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        else
                            CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        end
                        ImageDisplay(CurrentImage);
                    else
                        if ColorStack
                            ImageDisplay(ImageArray(:,:,:,IndexNumber));
                        else
                            ImageDisplay(ImageArray(:,:,IndexNumber));
                        end
                    end
                end
            end
            function SetLowContrast_callback(src,eventdata,arg1)
                temp = str2num(get(index,'String'));
                if Display_Limits(2)<=temp
                    warning('Not possible')
                    if ZoomOn
                        if ColorStack
                            CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        else
                            CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        end
                        ImageDisplay(CurrentImage);
                    else
                        if ColorStack
                            ImageDisplay(ImageArray(:,:,:,IndexNumber));
                        else
                            ImageDisplay(ImageArray(:,:,IndexNumber));
                        end
                    end
                else
                    Display_Limits(1)=temp;clear temp
                    set(LowDisp,'String',num2str(Display_Limits(1)))
                    if ZoomOn
                        if ColorStack
                            CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        else
                            CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        end
                        ImageDisplay(CurrentImage);
                    else
                        if ColorStack
                            ImageDisplay(ImageArray(:,:,:,IndexNumber));
                        else
                            ImageDisplay(ImageArray(:,:,IndexNumber));
                        end
                    end
                end
            end
            function Exit_Callback(src,eventdata,arg1)
                PlayBack=0;   
                global SELECTIONDATA
                SELECTIONDATA=SelectionData;
                clear ImageArray
                close(ViewerFig)
    %             if ~isempty(which('MatlabGarbageCollector.jar'))    
    %                 org.dt.matlab.utilities.JavaMemoryCleaner.clear(0)
    %             end

            end
            function Navigation_KeyPressFcn(src, evnt)
                if isequal(evnt.Key,'rightarrow')
                    FrameAdvance
                elseif isequal(evnt.Key,'leftarrow')
                    FrameRetreat
                elseif isequal(evnt.Key,'uparrow')
                    ReduceContrast
                elseif isequal(evnt.Key,'downarrow')
                    EnhanceContrast
                elseif isequal(evnt.Key,'shift')
                    TagPoints
                elseif isequal(evnt.Key,'space')
                    if PlayBack
                        PausePlayStack_callback
                    else
                        StartPlayStack_callback
                    end
                elseif isequal(evnt.Key,'control')||isequal(evnt.Key,'escape')
                    Exit_Callback
                end
            end
            function FrameAdvance
                if IndexNumber==LastIndexNumber
                    IndexNumber=1;
                else
                    IndexNumber=IndexNumber+1;
                end
                set(sld,'Value',IndexNumber)
                set(index,'String',num2str(IndexNumber))
                if ZoomOn
                    if ColorStack
                        CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    else
                        CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    end
                    ImageDisplay(CurrentImage);
                else
                    if ColorStack
                        ImageDisplay(ImageArray(:,:,:,IndexNumber));
                    else
                        ImageDisplay(ImageArray(:,:,IndexNumber));
                    end
                end
            end
            function FrameRetreat
                if IndexNumber==1
                    IndexNumber=LastIndexNumber;
                else
                    IndexNumber=IndexNumber-1;
                end
                set(sld,'Value',IndexNumber)
                set(index,'String',num2str(IndexNumber))
                if ZoomOn
                    if ColorStack
                        CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    else
                        CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                    end
                    ImageDisplay(CurrentImage);
                else
                    if ColorStack
                        ImageDisplay(ImageArray(:,:,:,IndexNumber));
                    else
                        ImageDisplay(ImageArray(:,:,IndexNumber));
                    end
                end
            end
            function ReduceContrast
                temp = Display_Limits(2)+StepUnits(1)*MaxVal;
                if temp<=Display_Limits(1)
                    warning('Not possible')
                    set(HighSld,'Value',Display_Limits(2))
                    set(HighDisp,'String',num2str(Display_Limits(2)))
                    if ZoomOn
                        if ColorStack
                            CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        else
                            CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        end
                        ImageDisplay(CurrentImage);
                    else
                        if ColorStack
                            ImageDisplay(ImageArray(:,:,:,IndexNumber));
                        else
                            ImageDisplay(ImageArray(:,:,IndexNumber));
                        end
                    end
                else
                    Display_Limits(2)=temp;clear temp
                    set(HighSld,'Value',Display_Limits(2))
                    set(HighDisp,'String',num2str(Display_Limits(2)))
                    if ZoomOn
                        if ColorStack
                            CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        else
                            CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        end
                        ImageDisplay(CurrentImage);
                    else
                        if ColorStack
                            ImageDisplay(ImageArray(:,:,:,IndexNumber));
                        else
                            ImageDisplay(ImageArray(:,:,IndexNumber));
                        end
                    end
                end
            end
            function EnhanceContrast
                temp = Display_Limits(2)-StepUnits(1)*MaxVal;
                if temp<=Display_Limits(1)
                    warning('Not possible')
                    set(HighSld,'Value',Display_Limits(2))
                    set(HighDisp,'String',num2str(Display_Limits(2)))
                    if ZoomOn
                        if ColorStack
                            CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        else
                            CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        end
                        ImageDisplay(CurrentImage);
                    else
                        if ColorStack
                            ImageDisplay(ImageArray(:,:,:,IndexNumber));
                        else
                            ImageDisplay(ImageArray(:,:,IndexNumber));
                        end
                    end
                else
                    Display_Limits(2)=temp;clear temp
                    set(HighSld,'Value',Display_Limits(2))
                    set(HighDisp,'String',num2str(Display_Limits(2)))
                    if ZoomOn
                        if ColorStack
                            CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        else
                            CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                        end
                        ImageDisplay(CurrentImage);
                    else
                        if ColorStack
                            ImageDisplay(ImageArray(:,:,:,IndexNumber));
                        else
                            ImageDisplay(ImageArray(:,:,IndexNumber));
                        end
                    end
                end
            end    
            function TagPoints(src,eventdata,arg1)
                ExitSelection=0;
                cont=1;
                while cont
                    Temp_Coords=[];
                    while isempty(Temp_Coords)
                        Temp_Coords=ginput_w(1);
                        if isempty(Temp_Coords)
                            warning('Must Make Selection!!')
                        end
                    end
                    clear TempCoordList
                    hold on;P1=plot(Temp_Coords(1),Temp_Coords(2),Point_Marker,'color',Point_Color,'MarkerSize',Point_MarkerSize);
                    if ZoomOn
                        txt1=text(ZoomRegion_Props.BoundingBox(1)+10,ZoomRegion_Props.BoundingBox(2)+10,'<ENTER> to Accept Point <1> to Delete','color',Point_Color,'fontsize',20);
                    else
                        txt1=text(20,20,'<ENTER> to Accept Point <1> to Delete','color',Point_Color,'fontsize',20);
                    end
                    cont=InputWithVerification('<ENTER> to Accept Point or <1> to clear selection: ',{[],[1]},0);
                    delete(txt1);delete(P1)
                    if cont
                        clear Temp_Coords
                        if ZoomOn
                            txt3=text(ZoomRegion_Props.BoundingBox(1)+10,ZoomRegion_Props.BoundingBox(2)+10,'<ENTER> to Add Another Point or <1> to EXIT','color',Point_Color,'fontsize',20);
                        else
                            txt3=text(20,20,'<ENTER> to Add Another Point or <1> to EXIT','color',Point_Color,'fontsize',20);
                        end
                        ExitSelection=InputWithVerification('<ENTER> to Add Another Point or <1> to EXIT selection mode: ',{[],[1]},0);
                        if ExitSelection
                            cont=0;
                        end
                        delete(txt3);
                    else
                        %IMPORTANT ADDING TO NEW STRUCTURE!!
                        Point=length(SelectionData);
                        Point=Point+1;
                        if ZoomOn
                            SelectionData(Point).XCoords=round(Temp_Coords(1))+(ZoomRegion_Props.BoundingBox(1)-1);
                            SelectionData(Point).YCoords=round(Temp_Coords(2))+(ZoomRegion_Props.BoundingBox(2)-1);
                            SelectionData(Point).ZCoords=IndexNumber;
                        else
                            SelectionData(Point).XCoords=round(Temp_Coords(1));
                            SelectionData(Point).YCoords=round(Temp_Coords(2));
                            SelectionData(Point).ZCoords=IndexNumber;
                        end
                        if ZoomOn
                            SelectionData(Point).XCoords_Adjusted=SelectionData(Point).XCoords-(ZoomRegion_Props.BoundingBox(1)-1);
                            SelectionData(Point).YCoords_Adjusted=SelectionData(Point).YCoords-(ZoomRegion_Props.BoundingBox(2)-1);
                            SelectionData(Point).ZCoords_Adjusted=SelectionData(Point).ZCoords;
                        else
                            SelectionData(Point).XCoords_Adjusted=[];
                            SelectionData(Point).YCoords_Adjusted=[];
                            SelectionData(Point).ZCoords_Adjusted=[];
                        end
                        SelectionData(Point).MarkerStyle=Point_Marker;
                        SelectionData(Point).MarkerSize=Point_MarkerSize;
                        SelectionData(Point).Color=Point_Color;
                        SelectionData(Point).LineStyle=[];
                        SelectionData(Point).LineWidth=[];
                        clear Temp_Coords
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        fprintf(['Successfully Added! Number of Points: ',num2str(length(SelectionData)),'\n'])
                        if ZoomOn
                            if ColorStack
                                CurrentImage=imcrop(ImageArray(:,:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                            else
                                CurrentImage=imcrop(ImageArray(:,:,IndexNumber),ZoomRegion_Props.BoundingBox);
                            end
                        else
                            if ColorStack
                                CurrentImage=ImageArray(:,:,:,IndexNumber);
                            else
                                CurrentImage=ImageArray(:,:,IndexNumber);
                            end
                        end
                        ImageDisplay(CurrentImage);
                        set(sld,'Value',IndexNumber)
                    end            
                end
            end
  end