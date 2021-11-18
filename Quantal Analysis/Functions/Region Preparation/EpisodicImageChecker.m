function EpisodicImageChecker(StatusFig,LastIndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector)

    warning on all
    warning off verbose
    warning off backtrace
    
    
    OS=computer;
    if strcmp(OS,'MACI64')
        dc='/';
    else
        dc='\';
    end
    pwd;
    currentFolder = pwd;
    [upperPath, deepestFolder] = fileparts(currentFolder);

    [ret, compName] = system('hostname');   

    if ret ~= 0,
       if ispc
          compName = getenv('COMPUTERNAME');
       else      
          compName = getenv('HOSTNAME');      
       end
    end
    compName = lower(compName);
    compName=cellstr(compName);
    compName=compName{1};

    Flagged_Indices=[];
    IndexNumber=1;
    PlayBack=0;
    PlayBackInterval=0.001;%in seconds
    Basal_ColorLimits=[0,max(Temp_ImageArray_FirstImages(:))*0.8];
    PeakDF_ColorLimits=[0,max(Peak_TempDeltaF(:))*0.4];
    EndDF_ColorLimits=[-2000,2000];



    %initialize figure
    EpisodicCheckerFigure=figure;
    set(EpisodicCheckerFigure,'units','normalized','position',[0 0 1 1],'name',['Index #: ',num2str(IndexNumber)])
    EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);

    %Create UI elements
    if strfind(OS,'PC')
        % Create slider
        sld = uicontrol('Style', 'slider',...
            'Min',1,'Max',LastIndexNumber,'Value',1,...
            'SliderStep',[1/(LastIndexNumber- 1),10/(LastIndexNumber- 1)],...
            'units','normalized',...
            'Position', [0.8 0.98 0.2 0.02],...
            'Callback', @slider_callback);
        txt = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.77 0.98 0.025 0.015],...
            'String','Index #');
    else
        % Create slider
        sld = uicontrol('Style', 'slider',...
            'Min',1,'Max',LastIndexNumber,'Value',1,...
            'SliderStep',[1/(LastIndexNumber- 1),10/(LastIndexNumber- 1)],...
            'units','normalized',...
            'Position', [0.8 0.95 0.2 0.05],...
            'Callback', @slider_callback);
        txt = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.8 0.96 0.025 0.015],...
            'String','Index #');
    end
    
    
    set(EpisodicCheckerFigure,'WindowKeyPressFcn',@Navigation_KeyPressFcn)

    
   % Create push button for flagging frames
    btn = uicontrol('Style', 'pushbutton', 'String', 'FLAG?',...
        'units','normalized',...
        'Position', [0.96 0.93 0.04 0.03],...
        'Callback', @flagIndex_callback);  
   % Create push button for exporting flagged frames
    btn2 = uicontrol('Style', 'pushbutton', 'String', 'EXPORT',...
        'units','normalized',...
        'Position', [0.96 0.77 0.04 0.03],...
        'Callback', @Export_callback);
    
   % Create push button for playing stack
    btn3 = uicontrol('Style', 'pushbutton', 'String', 'PLAY',...
        'units','normalized',...
        'Position', [0.96 0.90 0.04 0.03],...
        'Callback', @StartPlayStack_callback);  
    
    btn4 = uicontrol('Style', 'pushbutton', 'String', 'PAUSE',...
        'units','normalized',...
        'Position', [0.96 0.87 0.04 0.03],...
        'Callback', @PausePlayStack_callback);  
   
    % Create field for setting index position
    index = uicontrol('Style', 'edit', 'string',num2str(IndexNumber),...
        'units','normalized',...
        'Position', [0.98 0.83 0.02 0.02]);      
    btn5 = uicontrol('Style', 'pushbutton', 'String', 'Jump to ^',...
        'units','normalized',...
        'Position', [0.96 0.80 0.04 0.03],...
        'Callback', @JumpToIndex_callback);
    if strfind(OS,'PC')
    % Create Contrast Sliders
    BasalHighSld = uicontrol('Style', 'slider',...
        'Min',0,'Max',2^16-1,'Value',Basal_ColorLimits(2),...
        'SliderStep',[500/(2^16- 1),1000/(2^16- 1)],...
        'units','normalized',...
        'Position', [0.34,0.51 0.01 0.15],...
        'Callback', @Basal_HighContrast_callback);
    BasalHightxt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.34,0.495 0.01 0.015],...
        'String','H');
    BasalLowSld = uicontrol('Style', 'slider',...
        'Min',0,'Max',2^16-1,'Value',Basal_ColorLimits(1),...
        'SliderStep',[500/(2^16- 1),1000/(2^16- 1)],...
        'units','normalized',...
        'Position', [0.33,0.51 0.01 0.15],...
        'Callback', @Basal_LowContrast_callback);
    BasalLowtxt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.33,0.495 0.01 0.015],...
        'String','L'); 
    PeakHighSld = uicontrol('Style', 'slider',...
        'Min',-2^16-1,'Max',2^16-1,'Value',PeakDF_ColorLimits(2),...
        'SliderStep',[200/(2^16- 1),1000/(2^16- 1)],...
        'units','normalized',...
        'Position', [0.64,0.51 0.01 0.15],...
        'Callback', @Peak_HighContrast_callback);
    PeakHightxt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.64,0.495 0.01 0.015],...
        'String','H');
    PeakLowSld = uicontrol('Style', 'slider',...
        'Min',-2^16-1,'Max',2^16-1,'Value',PeakDF_ColorLimits(1),...
        'SliderStep',[200/(2^16- 1),1000/(2^16- 1)],...
        'units','normalized',...
        'Position', [0.63,0.51 0.01 0.15],...
        'Callback', @Peak_LowContrast_callback);
    PeakLowtxt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.63,0.495 0.01 0.015],...
        'String','L');
    EndHighSld = uicontrol('Style', 'slider',...
        'Min',-2^16-1,'Max',2^16-1,'Value',EndDF_ColorLimits(2),...
        'SliderStep',[100/(2^16- 1),200/(2^16- 1)],...
        'units','normalized',...
        'Position', [0.94,0.51 0.01 0.15],...
        'Callback', @End_HighContrast_callback);
    EndHightxt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.94,0.495 0.01 0.015],...
        'String','H');
    EndLowSld = uicontrol('Style', 'slider',...
        'Min',-2^16-1,'Max',2^16-1,'Value',EndDF_ColorLimits(1),...
        'SliderStep',[100/(2^16- 1),200/(2^16- 1)],...
        'units','normalized',...
        'Position', [0.93,0.51 0.01 0.15],...
        'Callback', @End_LowContrast_callback);
    EndLowtxt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.93,0.495 0.01 0.015],...
        'String','L');
    else   
    % Create Contrast Sliders
    BasalHighSld = uicontrol('Style', 'slider',...
        'Min',0,'Max',2^16-1,'Value',Basal_ColorLimits(2),...
        'SliderStep',[500/(2^16- 1),1000/(2^16- 1)],...
        'units','normalized',...
        'Position', [0.3,0.51 0.05 0.15],...
        'Callback', @Basal_HighContrast_callback);
    BasalHightxt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.34,0.495 0.01 0.015],...
        'String','H');
    BasalLowSld = uicontrol('Style', 'slider',...
        'Min',0,'Max',2^16-1,'Value',Basal_ColorLimits(1),...
        'SliderStep',[500/(2^16- 1),1000/(2^16- 1)],...
        'units','normalized',...
        'Position', [0.29,0.51 0.05 0.15],...
        'Callback', @Basal_LowContrast_callback);
    BasalLowtxt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.33,0.495 0.01 0.015],...
        'String','L'); 
    PeakHighSld = uicontrol('Style', 'slider',...
        'Min',-2^16-1,'Max',2^16-1,'Value',PeakDF_ColorLimits(2),...
        'SliderStep',[200/(2^16- 1),1000/(2^16- 1)],...
        'units','normalized',...
        'Position', [0.6,0.51 0.05 0.15],...
        'Callback', @Peak_HighContrast_callback);
    PeakHightxt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.64,0.495 0.01 0.015],...
        'String','H');
    PeakLowSld = uicontrol('Style', 'slider',...
        'Min',-2^16-1,'Max',2^16-1,'Value',PeakDF_ColorLimits(1),...
        'SliderStep',[200/(2^16- 1),1000/(2^16- 1)],...
        'units','normalized',...
        'Position', [0.59,0.51 0.05 0.15],...
        'Callback', @Peak_LowContrast_callback);
    PeakLowtxt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.63,0.495 0.01 0.015],...
        'String','L');
    EndHighSld = uicontrol('Style', 'slider',...
        'Min',-2^16-1,'Max',2^16-1,'Value',EndDF_ColorLimits(2),...
        'SliderStep',[100/(2^16- 1),200/(2^16- 1)],...
        'units','normalized',...
        'Position', [0.9,0.51 0.05 0.15],...
        'Callback', @End_HighContrast_callback);
    EndHightxt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.94,0.495 0.01 0.015],...
        'String','H');
    EndLowSld = uicontrol('Style', 'slider',...
        'Min',-2^16-1,'Max',2^16-1,'Value',EndDF_ColorLimits(1),...
        'SliderStep',[100/(2^16- 1),200/(2^16- 1)],...
        'units','normalized',...
        'Position', [0.89,0.51 0.05 0.15],...
        'Callback', @End_LowContrast_callback);
    EndLowtxt = uicontrol('Style','text',...
        'units','normalized',...
        'Position',[0.93,0.495 0.01 0.015],...
        'String','L');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Navigation_KeyPressFcn(src, evnt)
        if isequal(evnt.Key,'rightarrow')
            IndexNumber = get(sld,'Value');
            if IndexNumber<size(Temp_ImageArray_FirstImages,3)
                IndexNumber=round(IndexNumber)+1;
            end
            set(sld,'Value',IndexNumber);
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
            set(index,'String',num2str(IndexNumber))
        elseif isequal(evnt.Key,'leftarrow')
            IndexNumber = get(sld,'Value');
            if IndexNumber>1
                IndexNumber=round(IndexNumber)-1;
            end
            set(sld,'Value',IndexNumber);
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
            set(index,'String',num2str(IndexNumber))
        elseif isequal(evnt.Key,'uparrow')
            
            warning('Not ready yet...')
            
        elseif isequal(evnt.Key,'downarrow')
            
            warning('Not ready yet...')
            
        elseif isequal(evnt.Key,'space')
            if PlayBack
                PausePlayStack_callback
            else
                StartPlayStack_callback
            end
        elseif isequal(evnt.Key,'control')
            flagIndex_callback
        end
    end

    function flagIndex_callback(src,eventdata,arg1)
        Flagged_Indices=[Flagged_Indices,IndexNumber];
        disp(['Flagging Index #: ',num2str(IndexNumber)])
        Flagged_Indices=unique(Flagged_Indices);
        Flagged_Indices=sort(Flagged_Indices);
        global FLAGGEDINDEXNUMBERS
        FLAGGEDINDEXNUMBERS=Flagged_Indices;
    end
  
    function Export_callback(src,eventdata,arg1)
        if exist('StatusFig')
            close(StatusFig)
            uiresume
        end
        close(EpisodicCheckerFigure)
    end

    function JumpToIndex_callback(src,eventdata,arg1)
        IndexNumber=str2num(get(index,'String'));
        EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        set(sld,'Value',IndexNumber)

    end

    function slider_callback(src,eventdata,arg1)
        IndexNumber = get(src,'Value');
        IndexNumber=round(IndexNumber);
        EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
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
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
            pause(PlayBackInterval)
        end
    end
    function PausePlayStack_callback(src,eventdata,arg1)
        PlayBack=0;
    end

    function EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits)
        set(EpisodicCheckerFigure,'name',['Index #: ',num2str(IndexNumber)])
        subtightplot(2,3,1,[0,0])
        cla
        imagesc(Temp_ImageArray_FirstImages(:,:,IndexNumber)),axis equal tight
        hold on
        caxis(Basal_ColorLimits)
        %colorbar
        hcb1=colorbar('location','East','position',[0.32 0.75 0.01 0.15],'color','m');
        set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
        title('F_0 (Check focus and position)');
        hold off
        subtightplot(2,3,2,[0,0])
        cla
        imagesc(Peak_TempDeltaF(:,:,IndexNumber)),axis equal tight
        hold on
        caxis(PeakDF_ColorLimits)
        %colorbar
        hcb2=colorbar('location','East','position',[0.62 0.75 0.01 0.15],'color','m');
        set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
        title('\DeltaF Peak (check for failed release)')
        hold off
        subtightplot(2,3,3,[0,0]);
        cla
        imagesc(End_TempDeltaF(:,:,IndexNumber)),axis equal tight
        hold on
        caxis(EndDF_ColorLimits)
        %colorbar
        hcb3=colorbar('location','East','position',[0.92 0.75 0.01 0.15],'color','m');
        set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
        title('\DeltaF End (check for contractions and mis-timed stimuli)');
        colormap(jet)
        hold off
        subtightplot(2,3,4,[0.05,0.05])
        cla
        plot(MeanStartingFluorescenceVector, '.','MarkerSize',15,'color','k');hold on;xlabel('Index number'), ylabel('F (AU)'), title('Mean Basal F_0');set(gcf, 'color', 'white');ylim([0,max(MeanStartingFluorescenceVector)+max(MeanStartingFluorescenceVector)*0.2]);box off;plot(IndexNumber,MeanStartingFluorescenceVector(IndexNumber), '.','MarkerSize',25,'color','r');hold off;
        subtightplot(2,3,5,[0.05,0.05])
        cla
        plot(Peak_TempDeltaFMaxVector,'.','MarkerSize',15,'color','k');ylim([0,max(Peak_TempDeltaFMaxVector)]);hold on;plot(IndexNumber,Peak_TempDeltaFMaxVector(IndexNumber),'.','MarkerSize',25,'color','r');title('Mean \DeltaF/F PEAK FRAME'),box off
        subtightplot(2,3,6,[0.05,0.05])
        cla
        plot(End_TempDeltaFMaxVector,'.','MarkerSize',15,'color','k');ylim([0,max(End_TempDeltaFMaxVector)]);hold on;plot(IndexNumber,End_TempDeltaFMaxVector(IndexNumber),'.','MarkerSize',25,'color','r'),title('Mean \DeltaF/F END FRAME'),box off
        drawnow;
    end
    function Basal_HighContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if temp<=Basal_ColorLimits(1)
            warning('Not possible')
            set(src,'Value',Basal_ColorLimits(2))
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        else
            Basal_ColorLimits(2)=temp;clear temp
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        end
    end
    function Basal_LowContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if Basal_ColorLimits(2)<=temp
            warning('Not possible')
            set(src,'Value',Basal_ColorLimits(1))
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        else
            Basal_ColorLimits(1)=temp;clear temp
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        end
    end
    function Peak_HighContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if temp<=PeakDF_ColorLimits(1)
            warning('Not possible')
            set(src,'Value',PeakDF_ColorLimits(2))
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        else
            PeakDF_ColorLimits(2)=temp;clear temp
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        end
    end
    function Peak_LowContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if PeakDF_ColorLimits(2)<=temp
            warning('Not possible')
            set(src,'Value',PeakDF_ColorLimits(1))
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        else
            PeakDF_ColorLimits(1)=temp;clear temp
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        end
    end
    function End_HighContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if temp<=EndDF_ColorLimits(1)
            warning('Not possible')
            set(src,'Value',EndDF_ColorLimits(2))
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        else
            EndDF_ColorLimits(2)=temp;clear temp
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        end
    end
    function End_LowContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if EndDF_ColorLimits(2)<=temp
            warning('Not possible')
            set(src,'Value',EndDF_ColorLimits(1))
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        else
            EndDF_ColorLimits(1)=temp;clear temp
            EpisodicImagePlotter(IndexNumber,Temp_ImageArray_FirstImages,Peak_TempDeltaF,End_TempDeltaF,MeanStartingFluorescenceVector,Peak_TempDeltaFMaxVector,End_TempDeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        end
    end



  end