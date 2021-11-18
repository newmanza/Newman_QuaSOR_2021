function EpisodicImageChecker1(StatusFig,Flagged_Episodes,LastEpisodeNumber,Temp_ImageArray_FirstImages,Temp_ImageArray_Peak_DeltaF,Temp_ImageArray_End_DeltaF,MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector)

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

    if ~isempty(Flagged_Episodes)
        warning(['Flagged_Episodes = ',num2str(Flagged_Episodes)])
    end
    EpisodeNumber=1;
    PlayBack=0;
    PlayBackInterval=0.001;%in seconds
    Basal_ColorLimits=[0,max(Temp_ImageArray_FirstImages(:))*0.8];
    PeakDF_ColorLimits=[0,max(Temp_ImageArray_Peak_DeltaF(:))*0.4];
    EndDF_ColorLimits=[-2000,2000];



    %initialize figure
    EpisodicCheckerFigure=figure;
    set(EpisodicCheckerFigure,'units','normalized','position',[0 0 1 1],'name',['Episode #: ',num2str(EpisodeNumber)])
    EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);

    %Create UI elements
    if strfind(OS,'PC')
        % Create slider
        sld = uicontrol('Style', 'slider',...
            'Min',1,'Max',LastEpisodeNumber,'Value',1,...
            'SliderStep',[1/(LastEpisodeNumber- 1),10/(LastEpisodeNumber- 1)],...
            'units','normalized',...
            'Position', [0.8 0.98 0.2 0.02],...
            'Callback', @slider_callback);
        txt = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.77 0.98 0.025 0.015],...
            'String','Episode #');
    else
        % Create slider
        sld = uicontrol('Style', 'slider',...
            'Min',1,'Max',LastEpisodeNumber,'Value',1,...
            'SliderStep',[1/(LastEpisodeNumber- 1),10/(LastEpisodeNumber- 1)],...
            'units','normalized',...
            'Position', [0.8 0.95 0.2 0.05],...
            'Callback', @slider_callback);
        txt = uicontrol('Style','text',...
            'units','normalized',...
            'Position',[0.8 0.96 0.025 0.015],...
            'String','Episode #');
    end
    
    
    set(EpisodicCheckerFigure,'WindowKeyPressFcn',@Navigation_KeyPressFcn)

    
   % Create push button for flagging frames
    btn = uicontrol('Style', 'pushbutton', 'String', 'FLAG(ctl)',...
        'units','normalized',...
        'Position', [0.95 0.93 0.05 0.03],...
        'Callback', @flagEpisode_callback);  
   % Create push button for UNDO flag
    btn1 = uicontrol('Style', 'pushbutton', 'String', 'UNFLAG(del)',...
        'units','normalized',...
        'Position', [0.95 0.90 0.05 0.03],...
        'Callback', @UndoflagEpisode_callback);  
   % Create push button for exporting flagged frames
    btn2 = uicontrol('Style', 'pushbutton', 'String', 'EXPORT(end)',...
        'units','normalized',...
        'Position', [0.95 0.70 0.05 0.03],...
        'Callback', @Export_callback);
    
   % Create push button for playing stack
    btn3 = uicontrol('Style', 'pushbutton', 'String', 'PLAY',...
        'units','normalized',...
        'Position', [0.95 0.87 0.05 0.03],...
        'Callback', @StartPlayStack_callback);  
    
    btn4 = uicontrol('Style', 'pushbutton', 'String', 'PAUSE',...
        'units','normalized',...
        'Position', [0.95 0.84 0.05 0.03],...
        'Callback', @PausePlayStack_callback);  
   
    % Create field for setting Episode position
    Episode = uicontrol('Style', 'edit', 'string',num2str(EpisodeNumber),...
        'units','normalized',...
        'Position', [0.98 0.77 0.02 0.02]);      
    btn5 = uicontrol('Style', 'pushbutton', 'String', 'Jump to ^',...
        'units','normalized',...
        'Position', [0.95 0.74 0.05 0.03],...
        'Callback', @JumpToEpisode_callback);
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
            EpisodeNumber = get(sld,'Value');
            if EpisodeNumber<size(Temp_ImageArray_FirstImages,3)
                EpisodeNumber=round(EpisodeNumber)+1;
            end
            set(sld,'Value',EpisodeNumber);
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
            set(Episode,'String',num2str(EpisodeNumber))
        elseif isequal(evnt.Key,'leftarrow')
            EpisodeNumber = get(sld,'Value');
            if EpisodeNumber>1
                EpisodeNumber=round(EpisodeNumber)-1;
            end
            set(sld,'Value',EpisodeNumber);
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
            set(Episode,'String',num2str(EpisodeNumber))
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
            flagEpisode_callback
        elseif isequal(evnt.Key,'delete')
            UndoflagEpisode_callback
        elseif isequal(evnt.Key,'end')
            Export_callback
        end
    end

    function flagEpisode_callback(src,eventdata,arg1)
        Flagged_Episodes=[Flagged_Episodes,EpisodeNumber];
        disp(['Flagging Episode #: ',num2str(EpisodeNumber)])
        Flagged_Episodes=unique(Flagged_Episodes);
        Flagged_Episodes=sort(Flagged_Episodes);
        EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        set(sld,'Value',EpisodeNumber)
    end

    function UndoflagEpisode_callback(src,eventdata,arg1)
        if isempty(Flagged_Episodes)
            warning('Nothing Flagged Yet!')
        else
            NewFlagged_Episodes=[];
            for f=1:length(Flagged_Episodes)
                if Flagged_Episodes(f)==EpisodeNumber
                    warning(['Unflagging Episode ',num2str(EpisodeNumber)])
                else
                    NewFlagged_Episodes=[NewFlagged_Episodes,Flagged_Episodes(f)];
                end
            end
            Flagged_Episodes=NewFlagged_Episodes;
            clear NewFlagged_Episodes
            Flagged_Episodes=unique(Flagged_Episodes);
            Flagged_Episodes=sort(Flagged_Episodes);
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
            set(sld,'Value',EpisodeNumber)
        end
    end

    function Export_callback(src,eventdata,arg1)
        global FLAGGEDEPISODENUMBERS
        FLAGGEDEPISODENUMBERS=Flagged_Episodes;
        if exist('StatusFig')
            close(StatusFig)
            uiresume
        end
        close(EpisodicCheckerFigure)
    end

    function JumpToEpisode_callback(src,eventdata,arg1)
        EpisodeNumber=str2num(get(Episode,'String'));
        EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        set(sld,'Value',EpisodeNumber)
    end

    function slider_callback(src,eventdata,arg1)
        EpisodeNumber = get(src,'Value');
        EpisodeNumber=round(EpisodeNumber);
        EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        set(Episode,'String',num2str(EpisodeNumber))
    end

    function StartPlayStack_callback(src,eventdata,arg1)
        PlayBack=1;
        while PlayBack
            if EpisodeNumber==LastEpisodeNumber
                EpisodeNumber=1;
            else
                EpisodeNumber=EpisodeNumber+1;
            end
            set(sld,'Value',EpisodeNumber)
            set(Episode,'String',num2str(EpisodeNumber))
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
            pause(PlayBackInterval)
        end
    end
    function PausePlayStack_callback(src,eventdata,arg1)
        PlayBack=0;
    end




    
    function EpisodicImagePlotter(Current_EpisodeNumber,Current_Flagged_Episodes,Temp_Image_FirstImages,Temp_Image_Peak_DeltaF,Temp_Image_End_DeltaF,MeanStartingFluorescenceVector,Temp_Image_Peak_DeltaFMaxVector,Temp_Image_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits)
       
        set(EpisodicCheckerFigure,'name',['Episode #: ',num2str(Current_EpisodeNumber)])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subtightplot(2,3,1,[0,0])
        cla
        imagesc(Temp_Image_FirstImages),axis equal tight
        hold on
        if any(Current_Flagged_Episodes==Current_EpisodeNumber)
            text(10,10,'FLAGGED!','color','r','fontsize',16);
        end
        hold on
        caxis(Basal_ColorLimits)
        %colorbar
        hcb1=colorbar('location','East','position',[0.32 0.75 0.01 0.15],'color','k');
        set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
        title('F_0 (Check focus and position)');
        hold off
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subtightplot(2,3,2,[0,0])
        cla
        imagesc(Temp_Image_Peak_DeltaF),axis equal tight
        hold on
        if any(Current_Flagged_Episodes==Current_EpisodeNumber)
            text(10,10,'FLAGGED!','color','r','fontsize',16);
        end
        hold on
        caxis(PeakDF_ColorLimits)
        %colorbar
        hcb2=colorbar('location','East','position',[0.62 0.75 0.01 0.15],'color','k');
        set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
        title('\DeltaF Peak (check for failed release)')
        hold off
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subtightplot(2,3,3,[0,0]);
        cla
        imagesc(Temp_Image_End_DeltaF),axis equal tight
        hold on
        if any(Current_Flagged_Episodes==Current_EpisodeNumber)
            text(10,10,'FLAGGED!','color','r','fontsize',16);
        end
        hold on
        caxis(EndDF_ColorLimits)
        %colorbar
        hcb3=colorbar('location','East','position',[0.92 0.75 0.01 0.15],'color','k');
        set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
        title('\DeltaF End (check for contractions and mis-timed stimuli)');
        colormap(jet)
        hold off
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subtightplot(2,3,4,[0.05,0.05])
        cla
        plot([1:length(MeanStartingFluorescenceVector)],MeanStartingFluorescenceVector, '.','MarkerSize',10,'color','k');
        hold on;
        if ~isempty(Current_Flagged_Episodes)
%             for f=1:length(Current_Flagged_Episodes)
%                 if Current_Flagged_Episodes(f)==f
                    plot(Current_Flagged_Episodes,MeanStartingFluorescenceVector(Current_Flagged_Episodes),'.','MarkerSize',16,'color','r');
%                 end
%             end
        end
        plot(Current_EpisodeNumber,MeanStartingFluorescenceVector(Current_EpisodeNumber), '.','MarkerSize',20,'color','g');
        plot([Current_EpisodeNumber,Current_EpisodeNumber],[0,MeanStartingFluorescenceVector(Current_EpisodeNumber)],'-','linewidth',0.5,'color','g')
        title('Mean Basal F_0')
        xlabel('Episode number')
        ylabel('F (AU)')
        set(gcf, 'color', 'white');
        ylim([0,max(MeanStartingFluorescenceVector)+max(MeanStartingFluorescenceVector)*0.2]);
        hold off;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subtightplot(2,3,5,[0.05,0.05])
        cla
        plot([1:length(Temp_Image_Peak_DeltaFMaxVector)],Temp_Image_Peak_DeltaFMaxVector,'.','MarkerSize',10,'color','k');
        hold on
        if ~isempty(Current_Flagged_Episodes)
%             for f=1:length(Current_Flagged_Episodes)
%                 if Current_Flagged_Episodes(f)==f
                    plot(Current_Flagged_Episodes,Temp_Image_Peak_DeltaFMaxVector(Current_Flagged_Episodes),'.','MarkerSize',16,'color','r');
%                 end
%             end
        end
        plot(Current_EpisodeNumber,Temp_Image_Peak_DeltaFMaxVector(Current_EpisodeNumber),'.','MarkerSize',20,'color','g');
        plot([Current_EpisodeNumber,Current_EpisodeNumber],[min(Temp_Image_Peak_DeltaFMaxVector),Temp_Image_Peak_DeltaFMaxVector(Current_EpisodeNumber)],'-','linewidth',0.5,'color','g')
        title('Mean \DeltaF/F PEAK FRAME')
        xlabel('Episode number')
        ylabel('\DeltaF/F PEAK')
        set(gcf, 'color', 'white');
        ylim([min(Temp_Image_Peak_DeltaFMaxVector),max(Temp_Image_Peak_DeltaFMaxVector)])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subtightplot(2,3,6,[0.05,0.05])
        cla
        plot([1:length(Temp_Image_End_DeltaFMaxVector)],Temp_Image_End_DeltaFMaxVector,'.','MarkerSize',10,'color','k');
        hold on;
        if ~isempty(Current_Flagged_Episodes)
%             for f=1:length(Current_Flagged_Episodes)
%                 if Current_Flagged_Episodes(f)==f
                    plot(Current_Flagged_Episodes,Temp_Image_End_DeltaFMaxVector(Current_Flagged_Episodes),'.','MarkerSize',16,'color','r');
%                 end
%             end
        end
        plot(Current_EpisodeNumber,Temp_Image_End_DeltaFMaxVector(Current_EpisodeNumber),'.','MarkerSize',20,'color','g')
        plot([Current_EpisodeNumber,Current_EpisodeNumber],[min(Temp_Image_End_DeltaFMaxVector),Temp_Image_End_DeltaFMaxVector(Current_EpisodeNumber)],'-','linewidth',0.5,'color','g')
        title('Mean \DeltaF/F END FRAME')
        xlabel('Episode number')
        ylabel('\DeltaF/F END')
        set(gcf, 'color', 'white');
        ylim([min(Temp_Image_End_DeltaFMaxVector),max(Temp_Image_End_DeltaFMaxVector)]);
        drawnow;
    end
    function Basal_HighContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if temp<=Basal_ColorLimits(1)
            warning('Not possible')
            set(src,'Value',Basal_ColorLimits(2))
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        else
            Basal_ColorLimits(2)=temp;clear temp
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        end
    end
    function Basal_LowContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if Basal_ColorLimits(2)<=temp
            warning('Not possible')
            set(src,'Value',Basal_ColorLimits(1))
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        else
            Basal_ColorLimits(1)=temp;clear temp
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        end
    end
    function Peak_HighContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if temp<=PeakDF_ColorLimits(1)
            warning('Not possible')
            set(src,'Value',PeakDF_ColorLimits(2))
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        else
            PeakDF_ColorLimits(2)=temp;clear temp
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        end
    end
    function Peak_LowContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if PeakDF_ColorLimits(2)<=temp
            warning('Not possible')
            set(src,'Value',PeakDF_ColorLimits(1))
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        else
            PeakDF_ColorLimits(1)=temp;clear temp
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        end
    end
    function End_HighContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if temp<=EndDF_ColorLimits(1)
            warning('Not possible')
            set(src,'Value',EndDF_ColorLimits(2))
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        else
            EndDF_ColorLimits(2)=temp;clear temp
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        end
    end
    function End_LowContrast_callback(src,eventdata,arg1)
        temp = get(src,'Value');
        if EndDF_ColorLimits(2)<=temp
            warning('Not possible')
            set(src,'Value',EndDF_ColorLimits(1))
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        else
            EndDF_ColorLimits(1)=temp;clear temp
            EpisodicImagePlotter(EpisodeNumber,Flagged_Episodes,Temp_ImageArray_FirstImages(:,:,EpisodeNumber),Temp_ImageArray_Peak_DeltaF(:,:,EpisodeNumber),Temp_ImageArray_End_DeltaF(:,:,EpisodeNumber),MeanStartingFluorescenceVector,Temp_ImageArray_Peak_DeltaFMaxVector,Temp_ImageArray_End_DeltaFMaxVector,Basal_ColorLimits,PeakDF_ColorLimits,EndDF_ColorLimits);
        end
    end



  end