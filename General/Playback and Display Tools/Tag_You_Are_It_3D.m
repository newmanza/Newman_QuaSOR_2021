%To Do

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Tag_You_Are_It_3D(StatusFig,SaveName,ZoomStack,StartingZ,...
    CoordList,DeleteCount,DeleteCoords,AddCount,AddCoords,VoxelSize,ZScalar,...
    TagColor,StartingContrast,FigPosition,FigPosition2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Airy_MarkerOn=1;
        YProjection=max(ZoomStack,[],1);
        YProjection1(:,:)=YProjection(1,:,:);
        YProjection2=[];
        pos=0;
        for zz=1:size(YProjection1,2)
            for yy=1:ZScalar
                pos=pos+1;
                for xx=1:size(YProjection1,1)
                    YProjection2(xx,pos)=YProjection1(xx,zz);
                end
            end
        end
        YProjection2=YProjection2';
        %%%%%%%%%%%%
        XProjection=max(ZoomStack,[],2);
        XProjection1(:,:)=XProjection(:,1,:);
        XProjection2=[];
        pos=0;
        for zz=1:size(XProjection1,2)
            for xx=1:ZScalar
                pos=pos+1;
                for yy=1:size(XProjection1,1)
                    XProjection2(yy,pos)=XProjection1(yy,zz);
                end
            end
        end
        ZProjection=[];
        ZProjection=max(ZoomStack,[],3);

       HighContrast=StartingContrast;
       NumZSlices=size(ZoomStack,3);
       StackMax=max(ZoomStack(:))*2;
       NumIntervals=40;
       z=StartingZ;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
        FigName=['3D Tagging ',SaveName];
        
        SummaryFig=figure('name',FigName);
        imshow(ZProjection,[],'border','tight')
        set(gcf, 'color', 'white');
        hold on
        if Airy_MarkerOn
            for i=1:size(CoordList,1)
                if ~isempty(DeleteCoords)
                    if any(DeleteCoords(:,1)==CoordList(i,1))&&any(DeleteCoords(:,2)==CoordList(i,2))&&any(DeleteCoords(:,3)==CoordList(i,3))
                        plot(CoordList(i,2),CoordList(i,1),'x','color','r','markersize',12)
                    else
                        plot(CoordList(i,2),CoordList(i,1),'o','color',TagColor,'markersize',12)
                    end
                else
                    plot(CoordList(i,2),CoordList(i,1),'o','color',TagColor,'markersize',12);
                end
            end
            for i=1:size(AddCoords,1)
                plot(AddCoords(i,2),AddCoords(i,1),'.','color','g','markersize',26);
            end
        end
        set(gcf,'units','normalized','position',FigPosition2)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SelectionFig=figure('name',FigName);
        set(gcf, 'color', 'white');
        set(gcf,'units','normalized','position',FigPosition)
        AX1=subtightplot(2,2,1,[0,0],[0.05,0.05],[0.05,0.05]);
        AX2=subtightplot(2,2,2,[0,0],[0.05,0.05],[0.05,0.05]);
        imshow(XProjection2,[0,(HighContrast)*StackMax],'border','tight');
        hold on
        PX=plot([z*ZScalar,z*ZScalar],[1,size(XProjection2,1)],'-','color','m','linewidth',1);
        AX3=subtightplot(2,2,3,[0,0],[0.05,0.05],[0.05,0.05]);
        imshow(YProjection2,[0,(HighContrast)*StackMax],'border','tight');
        hold on
        PY=plot([1,size(YProjection2,2)],[z*ZScalar,z*ZScalar],'-','color','m','linewidth',1);
        %set(AX1,'units','normalized','position',[0.05,0.25,0.7,0.7])
        set(AX2,'units','normalized','position',[0.7,0.25,0.2,0.7])
        set(AX3,'units','normalized','position',[0.05,0,0.7,0.225])
        set(AX1,'units','normalized','position',[0.05,0.25,0.7,0.7])
        fprintf('Ready for selections...\n');
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %UI Elements
    for zzz=1:1
       DisplayAiryMarkerButton = uicontrol('Style', 'togglebutton', 'String', 'AZ Marker (alt)',...
        'units','normalized',...
        'value',Airy_MarkerOn,...
        'Position', [0.0 0.97 0.06 0.03],...
        'Callback', @DisplayAiryMarker);   
       DeleteCoordButton = uicontrol('Style', 'pushbutton', 'String', 'Delete (del)',...
        'units','normalized',...
        'Position', [0.18 0.97 0.07 0.03],...
        'Callback', @DeleteCoord);  
       AddCoordButton = uicontrol('Style', 'pushbutton', 'String', 'Add (ctl)',...
        'units','normalized',...
        'Position', [0.07 0.97 0.07 0.03],...
        'Callback', @AddCoord);   
       ShiftCoordButton = uicontrol('Style', 'pushbutton', 'String', 'Shift (shift)',...
        'units','normalized',...
        'Position', [0.07 0.94 0.07 0.03],...
        'Callback', @ShiftCoord);   
       UndoDeleteCoordButton = uicontrol('Style', 'pushbutton', 'String', 'UndoDel',...
        'units','normalized',...
        'Position', [0.25 0.97 0.04 0.03],...
        'Callback', @UndoDeleteCoord);  
       UndoAddCoordButton = uicontrol('Style', 'pushbutton', 'String', 'UndoAdd',...
        'units','normalized',...
        'Position', [0.14 0.97 0.04 0.03],...
        'Callback', @UndoAddCoord);   
       UndoShiftCoordButton = uicontrol('Style', 'pushbutton', 'String', 'UndoShift',...
        'units','normalized',...
        'Position', [0.14 0.94 0.04 0.03],...
        'Callback', @UndoShiftCoord);   
       FinishedButton = uicontrol('Style', 'pushbutton', 'String', 'Finished (End)',...
        'units','normalized',...
        'Position', [0.85 0.97 0.06 0.03],...
        'Callback', @Finished);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ContrastSlider = uicontrol('Style', 'slider',...
            'Min',1/NumIntervals,'Max',1,'Value',HighContrast,...
            'SliderStep',[1/NumIntervals,1/NumIntervals],...
            'units','normalized',...
            'Position', [0.7 0.985 0.15 0.015],...
            'Callback', @Contrast_Slider_callback);
        ContrastSliderText = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.7 0.97 0.15 0.015],...
            'String',['Contrast ',num2str(HighContrast)]);
        ZSlider = uicontrol('Style', 'slider',...
            'Min',0,'Max',1,'Value',z/NumZSlices,...
            'SliderStep',[1/NumZSlices,5/NumZSlices],...
            'units','normalized',...
            'Position', [0.3 0.985 0.3 0.015],...
            'Callback', @Z_Slider_callback);
        ZSliderText = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.3 0.97 0.06 0.015],...
            'String',['Z: ',num2str(z),'/',num2str(NumZSlices)]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         ForwardText = uicontrol('Style','text',...
%             'units','normalized',...
%             'Position',[0.53 0.97 0.02 0.015],...
%             'String','c>');
%         ReverseText = uicontrol('Style','text',...
%             'units','normalized',...
%             'Position',[0.45 0.97 0.02 0.015],...
%             'String','<x');
        zControl = uicontrol('Style', 'edit', 'string',num2str(z),...
            'units','normalized',...
            'Position', [0.6 0.98 0.04 0.02]);      
        zJump2Button = uicontrol('Style', 'pushbutton', 'String', 'Jump>z',...
            'units','normalized',...
            'Position', [0.64 0.98 0.05 0.02],...
            'Callback', @Jump2z);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        set(SelectionFig,'WindowKeyPressFcn',@Navigation_KeyPressFcn)
        UpdateImage
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Navigation_KeyPressFcn(src, evnt)
        if isequal(evnt.Key,'rightarrow')
            if z<NumZSlices
                z=z+1;    
            else
                z=1;
            end
            set(ZSlider,'Value',z/NumZSlices)
            set(ZSliderText,'String',['Z: ',num2str(z),'/',num2str(NumZSlices)])
            set(zControl,'String',num2str(z))
            UpdateImage
        elseif isequal(evnt.Key,'leftarrow')
            if z>1
                z=z-1;    
            else
                z=NumZSlices;
            end
            set(ZSlider,'Value',z/NumZSlices)
            set(ZSliderText,'String',['Z: ',num2str(z),'/',num2str(NumZSlices)])
            set(zControl,'String',num2str(z))
            UpdateImage
        elseif isequal(evnt.Key,'uparrow')
            HighContrast=HighContrast+1/NumIntervals;
            if HighContrast>1
                HighContrast=1;
            end
            set(ContrastSlider,'Value',HighContrast)
            set(ContrastSliderText,'String',['Contrast ',num2str(HighContrast)]);
            AX1=subtightplot(2,2,1,[0,0],[0.05,0.05],[0.05,0.05]);
            imshow(ZoomStack(:,:,z),[0,(HighContrast)*StackMax],'border','tight');
            AX2=subtightplot(2,2,2,[0,0],[0.05,0.05],[0.05,0.05]);
            imshow(XProjection2,[0,(HighContrast)*StackMax],'border','tight');
            hold on
            PX=plot([z*ZScalar,z*ZScalar],[1,size(XProjection2,1)],'-','color','m','linewidth',1);
            AX3=subtightplot(2,2,3,[0,0],[0.05,0.05],[0.05,0.05]);
            imshow(YProjection2,[0,(HighContrast)*StackMax],'border','tight');
            hold on
            PY=plot([1,size(YProjection2,2)],[z*ZScalar,z*ZScalar],'-','color','m','linewidth',1);
            %set(AX1,'units','normalized','position',[0.05,0.25,0.7,0.7])
            set(AX2,'units','normalized','position',[0.7,0.25,0.2,0.7])
            set(AX3,'units','normalized','position',[0.05,0,0.7,0.225])
            set(AX1,'units','normalized','position',[0.05,0.25,0.7,0.7])
            %UpdateImage
            
        elseif isequal(evnt.Key,'downarrow')
            HighContrast=HighContrast-1/NumIntervals;
            if HighContrast<=1/NumIntervals
                HighContrast=1/NumIntervals;
            end
            set(ContrastSlider,'Value',HighContrast)
            set(ContrastSliderText,'String',['Contrast ',num2str(HighContrast)]);
            AX1=subtightplot(2,2,1,[0,0],[0.05,0.05],[0.05,0.05]);
            imshow(ZoomStack(:,:,z),[0,(HighContrast)*StackMax],'border','tight');
            AX2=subtightplot(2,2,2,[0,0],[0.05,0.05],[0.05,0.05]);
            imshow(XProjection2,[0,(HighContrast)*StackMax],'border','tight');
            hold on
            PX=plot([z*ZScalar,z*ZScalar],[1,size(XProjection2,1)],'-','color','m','linewidth',1);
            AX3=subtightplot(2,2,3,[0,0],[0.05,0.05],[0.05,0.05]);
            imshow(YProjection2,[0,(HighContrast)*StackMax],'border','tight');
            hold on
            PY=plot([1,size(YProjection2,2)],[z*ZScalar,z*ZScalar],'-','color','m','linewidth',1);
            %set(AX1,'units','normalized','position',[0.05,0.25,0.7,0.7])
            set(AX2,'units','normalized','position',[0.7,0.25,0.2,0.7])
            set(AX3,'units','normalized','position',[0.05,0,0.7,0.225])
            set(AX1,'units','normalized','position',[0.05,0.25,0.7,0.7])
            %UpdateImage
        elseif isequal(evnt.Key,'end')
            Finished
        elseif isequal(evnt.Key,'control')
            AddCoord
        elseif isequal(evnt.Key,'shift')
            ShiftCoord
        elseif isequal(evnt.Key,'delete')
            DeleteCoord
        elseif isequal(evnt.Key,'alt')
            Airy_MarkerOn=~Airy_MarkerOn;
            set(DisplayAiryMarkerButton,'value',Airy_MarkerOn)
            UpdateImage
        elseif isequal(evnt.Key,'z')
        elseif isequal(evnt.Key,'v')
        elseif isequal(evnt.Key,'c')
        elseif isequal(evnt.Key,'x')
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdateSummary
        figure(SummaryFig)
        cla
        imshow(ZProjection,[],'border','tight')
        set(gcf, 'color', 'white');
        hold on
        if Airy_MarkerOn
            for i=1:size(CoordList,1)
                if ~isempty(DeleteCoords)
                    if any(DeleteCoords(:,1)==CoordList(i,1))&&any(DeleteCoords(:,2)==CoordList(i,2))&&any(DeleteCoords(:,3)==CoordList(i,3))
                        plot(CoordList(i,2),CoordList(i,1),'x','color','r','markersize',12)
                    else
                        plot(CoordList(i,2),CoordList(i,1),'o','color',TagColor,'markersize',12)
                    end
                else
                    plot(CoordList(i,2),CoordList(i,1),'o','color',TagColor,'markersize',12);
                end
            end
            for i=1:size(AddCoords,1)
                plot(AddCoords(i,2),AddCoords(i,1),'.','color','g','markersize',26);
            end
        end
        figure(SelectionFig)
    end
    function UpdateImage
        
        figure(SelectionFig)
        FigName=['3D Tagging ',SaveName];
        set(gcf,'name',FigName);
        axes(AX2);
        delete(PX);
        hold on
        PX=plot([z*ZScalar,z*ZScalar],[1,size(XProjection2,1)],'-','color','m','linewidth',1);
        axes(AX3);
        delete(PY);
        hold on
        PY=plot([1,size(YProjection2,2)],[z*ZScalar,z*ZScalar],'-','color','m','linewidth',1);
        if exist('AX1')
            cla(AX1)
        end
        %clf
        AX1=subtightplot(2,2,1,[0,0],[0.05,0.05],[0.05,0.05]);
        imshow(ZoomStack(:,:,z),[0,(HighContrast)*StackMax],'border','tight');
        set(AX1,'units','normalized','position',[0.05,0.25,0.7,0.7]);
        hold on
        if Airy_MarkerOn
            for i=1:size(CoordList,1)
                if CoordList(i,3)==z
                    if ~isempty(DeleteCoords)
                        if any(DeleteCoords(:,1)==CoordList(i,1))&&any(DeleteCoords(:,2)==CoordList(i,2))&&any(DeleteCoords(:,3)==CoordList(i,3))
                            plot(CoordList(i,2),CoordList(i,1),'x','color','r','markersize',12)
                        else
                            plot(CoordList(i,2),CoordList(i,1),'o','color',TagColor,'markersize',12)
                        end
                    else
                        plot(CoordList(i,2),CoordList(i,1),'o','color',TagColor,'markersize',12);
                    end
                end
            end
            for i=1:size(AddCoords,1)
                if AddCoords(i,3)==z
                    plot(AddCoords(i,2),AddCoords(i,1),'.','color','g','markersize',26);
                end
            end
        end
        figure(SelectionFig);
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
    %Contrast Settings
    function Contrast_Slider_callback(src,eventdata,arg1)
        HighContrast = get(src,'Value');
        AX1=subtightplot(2,2,1,[0,0],[0.05,0.05],[0.05,0.05]);
        imshow(ZoomStack(:,:,z),[0,(HighContrast)*StackMax],'border','tight');
        AX2=subtightplot(2,2,2,[0,0],[0.05,0.05],[0.05,0.05]);
        imshow(XProjection2,[0,(HighContrast)*StackMax],'border','tight');
        hold on
        PX=plot([z*ZScalar,z*ZScalar],[1,size(XProjection2,1)],'-','color','m','linewidth',1);
        AX3=subtightplot(2,2,3,[0,0],[0.05,0.05],[0.05,0.05]);
        imshow(YProjection2,[0,(HighContrast)*StackMax],'border','tight');
        hold on
        PY=plot([1,size(YProjection2,2)],[z*ZScalar,z*ZScalar],'-','color','m','linewidth',1);
        %set(AX1,'units','normalized','position',[0.05,0.25,0.7,0.7])
        set(AX2,'units','normalized','position',[0.7,0.25,0.2,0.7])
        set(AX3,'units','normalized','position',[0.05,0,0.7,0.225])
        set(AX1,'units','normalized','position',[0.05,0.25,0.7,0.7])
        %UpdateImage

        %UpdateImage
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %z Navigation Controls
    function Z_Slider_callback(src,eventdata,arg1)
        z = round(get(src,'Value')*NumZSlices);
        if z<1
            z=NumZSlices;
            set(ZSlider,'Value',z/NumZSlices)
            set(ZSliderText,'String',['Z: ',num2str(z),'/',num2str(NumZSlices)])
            set(zControl,'String',num2str(z))
            UpdateImage
        elseif z>NumZSlices
            z=1;
            set(ZSlider,'Value',z/NumZSlices)
            set(ZSliderText,'String',['Z: ',num2str(z),'/',num2str(NumZSlices)])
            set(zControl,'String',num2str(z))
            UpdateImage
        else
            z=round(z);
            set(ZSlider,'Value',z/NumZSlices)
            set(ZSliderText,'String',['Z: ',num2str(z),'/',num2str(NumZSlices)])
            set(zControl,'String',num2str(z))
            UpdateImage
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Jump2z(src,eventdata,arg1)
        z1=round(str2num(get(zControl,'String')));
        if z1<=NumZSlices&&z1>0
            z=z1;
            set(ZSlider,'Value',z/NumZSlices)
            set(ZSliderText,'String',['Z: ',num2str(z),'/',num2str(NumZSlices)])
            set(zControl,'String',num2str(z))
            UpdateImage
        else
            fprintf('\n')
            warning('Unable to move to that z!')
            set(ZSlider,'Value',z/NumZSlices)
            set(ZSliderText,'String',['Z: ',num2str(z),'/',num2str(NumZSlices)])
            set(zControl,'String',num2str(z))
            UpdateImage
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DisplayAiryMarker(src,eventdata,arg1)
        Airy_MarkerOn = get(src,'Value'); 
        UpdateImage
        UpdateSummary
    end
    function AddCoord(src,eventdata,arg1)
        txt=text(20,10,'Select Site To Add','fontsize',14,'color','g');
        AZCenter=ginput_w(1);
        AddCount=AddCount+1;
        AddCoords(AddCount,:)=[AZCenter(2),AZCenter(1),z];
        delete(txt)
        clear AZCenter
        UpdateImage
        UpdateSummary
    end
    function UndoAddCoord(src,eventdata,arg1)
        if AddCount>0
            AddCoords(AddCount,:)=[];
            AddCount=AddCount-1;
            UpdateImage
            UpdateSummary
        else
            warning('Nothing to undo!')
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function DeleteCoord(src,eventdata,arg1)
        txt=text(20,10,'Select Site To Remove','fontsize',14,'color','r');
        AZCenter=ginput_w(1);
        Index2Delete=dsearchn(CoordList(:,1:2),fliplr(AZCenter));
        DeleteCount=DeleteCount+1;
        DeleteCoords(DeleteCount,:)=CoordList(Index2Delete,:);
        delete(txt)
        clear Index2Delete
        UpdateImage
        UpdateSummary
    end
    function UndoDeleteCoord(src,eventdata,arg1)
        if DeleteCount>0
            DeleteCoords(DeleteCount,:)=[];
            DeleteCount=DeleteCount-1;
            UpdateImage
            UpdateSummary
        else
            warning('Nothing to undo!')
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    function ShiftCoord(src,eventdata,arg1)
        txt=text(20,10,'Select Site To Shift','fontsize',14,'color','y');
        AZCenter=ginput_w(1);
        Index2Delete=dsearchn(CoordList(:,1:2),fliplr(AZCenter));
        DeleteCount=DeleteCount+1;
        TempPlot1=plot(CoordList(Index2Delete,2),CoordList(Index2Delete,1),'o','color','y','markersize',12);
        TempPlot2=plot(CoordList(Index2Delete,2),CoordList(Index2Delete,1),'*','color','y','markersize',6);
        DeleteCoords(DeleteCount,:)=CoordList(Index2Delete,:);
        delete(txt)
        clear Index2Delete
        txt=text(20,10,'Select NEW Site position','fontsize',14,'color','y');
        AZCenter=ginput_w(1);
        AddCount=AddCount+1;
        AddCoords(AddCount,:)=[AZCenter(2),AZCenter(1),z];
        delete(txt)
        delete(TempPlot1)
        delete(TempPlot2)
        clear AZCenter
        UpdateImage
        UpdateSummary
    end
    function UndoShiftCoord(src,eventdata,arg1)
        if AddCount>0
            AddCoords(AddCount,:)=[];
            AddCount=AddCount-1;
        else
            warning('Nothing to undo!')
        end
        if DeleteCount>0
            DeleteCoords(DeleteCount,:)=[];
            DeleteCount=DeleteCount-1;
        else
            warning('Nothing to undo!')
        end
        UpdateImage
        UpdateSummary
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
    function Finished(src,eventdata,arg1)

            global DELETECOUNT
            DELETECOUNT=DeleteCount;
            global DELETECOORDS
            DELETECOORDS=DeleteCoords;
            global ADDCOUNT
            ADDCOUNT=AddCount;
            global ADDCOORDS
            ADDCOORDS=AddCoords;
            fprintf('Finished! ')
            fprintf(['Adding: ',num2str(AddCount),' Coordinates | '])
            fprintf(['Deleting: ',num2str(DeleteCount),' Coordinates\n'])
            close(SelectionFig)
            close(SummaryFig)
            close(StatusFig)
            uiresume
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end
