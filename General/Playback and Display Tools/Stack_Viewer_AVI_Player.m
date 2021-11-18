function Stack_Viewer_AVI_Player(MovieName,MovieDir)
    warning on all
    warning off verbose
    warning off backtrace
    ScaleFactor=4;
    FrameJumpPer=0.1;
    GridSpacing=50;
    GridColor=[1,1,0];
    MoviePlaybackControllerPos=[0 0.05 0.08 0.15];
    
    global FINISHED_PLAYBACK
    FINISHED_PLAYBACK=0;

    clear depVideoPlayer videoFReader
    warning off
    AVI_Info=aviinfo(MovieName);
    FPS=AVI_Info.FramesPerSecond;
    FrameInterval=1/FPS;
    ScreenSize=get(0,'ScreenSize');
    
    GridOn=0;
    PlayBack=1;
    GridMask=logical(zeros(AVI_Info.Height,AVI_Info.Width));
    NumVerticalGrids=round(AVI_Info.Width/GridSpacing);
    NumHorizontalGrids=round(AVI_Info.Height/GridSpacing);
    HorizontalLine=ones(AVI_Info.Width,1);
    VeritcalLine=ones(AVI_Info.Height,1);
    for i=1:NumVerticalGrids-1
        GridMask(:,i*GridSpacing*VeritcalLine)=1;
    end    
    for j=1:NumHorizontalGrids-1
        GridMask(j*GridSpacing*HorizontalLine,:)=1;
    end     
    FrameJump=round(AVI_Info.NumFrames*FrameJumpPer);
    
    fprintf(['Loading: ',MovieName,'\n'])
    disp(['Movie Size: ',num2str(AVI_Info.Height),' X ',num2str(AVI_Info.Width),' X 3 X ',num2str(AVI_Info.NumFrames)])
    videoFReader = vision.VideoFileReader(MovieName);
    try
        MovieArray=zeros(AVI_Info.Height,AVI_Info.Width,3,AVI_Info.NumFrames,'single');
        MovieArray_GRID=zeros(AVI_Info.Height,AVI_Info.Width,3,AVI_Info.NumFrames,'single');
    catch
        warning('Problem initializing data structure, trying alternative...')
        f = waitbar(0,['Initializing: ',MovieName]);
        f.Children.Title.Interpreter = 'none';
        for z=1:AVI_Info.NumFrames
            MovieArray(:,:,:,z)=zeros(AVI_Info.Height,AVI_Info.Width,3,'single');
            MovieArray_GRID(:,:,:,z)=zeros(AVI_Info.Height,AVI_Info.Width,3,'single');
            waitbar(z/AVI_Info.NumFrames,f,['Initializing...']);
        end
        fprintf('Finished!\n');
        waitbar(1,f,['Finished!']);
        close(f)
    end
    f = waitbar(0,['Loading: ',MovieName]);
    f.Children.Title.Interpreter = 'none';
    for z=1:AVI_Info.NumFrames
        MovieArray(:,:,:,z) = step(videoFReader);
        MovieArray_GRID(:,:,:,z)=ColorMasking(MovieArray(:,:,:,z),GridMask,GridColor);
        waitbar(z/AVI_Info.NumFrames,f,['Loading: ',MovieName]);
    end
    waitbar(1,f,['Finished!']);
    close(f)
    release(videoFReader);
    clear videoFReader
    fprintf(['Finished Loading: ',MovieName,'\n'])


    %Initialze Videoplayer
    videoFReader   = vision.VideoFileReader(MovieName);
    depVideoPlayer = vision.DeployableVideoPlayer;
    MovieSize=[AVI_Info.Width*ScaleFactor,AVI_Info.Height*ScaleFactor];
    if MovieSize(2)>ScreenSize(4)-150
        MovieSizeScalarModifier=(ScreenSize(4)-150)/MovieSize(2);
        MovieSize=round(MovieSize*MovieSizeScalarModifier);
    end
    if MovieSize(1)>ScreenSize(3)
        MovieSizeScalarModifier=ScreenSize(3)/MovieSize(1);
        MovieSize=round(MovieSize*MovieSizeScalarModifier);
    end
    TempLoc=MoviePlaybackControllerPos;
    TempLoc(1)=TempLoc(1)*ScreenSize(3);
    TempLoc(3)=TempLoc(3)*ScreenSize(3);
    TempLoc(2)=TempLoc(2)*ScreenSize(4);
    TempLoc(4)=TempLoc(4)*ScreenSize(4);
    MovieLocation=round([TempLoc(1)+TempLoc(3),TempLoc(2)]);
    set(depVideoPlayer,'Size','Custom','CustomSize',MovieSize,'Location',MovieLocation,'Name',MovieName);
    FrameNum=1;
    if ~GridOn
            frame=MovieArray(:,:,:,FrameNum);
        else
            frame=MovieArray_GRID(:,:,:,FrameNum);
        end
    step(depVideoPlayer, frame);
    t0=clock;
    sys_delay=0;
    if etime(clock,t0)+sys_delay<1
        while etime(clock,t0)+sys_delay<1
            %cont = ~isDone(videoFReader) && isOpen(depVideoPlayer);
            %if rem(etime(clock,t0),1000)==0
                drawnow
            %end
            %refreshdata
        end
    end
    
    
    %initialize controller figure
    MoviePlaybackController=figure;
    set(MoviePlaybackController,'units','normalized','position',MoviePlaybackControllerPos,'name',[MovieName])
    WinOnTop(MoviePlaybackController,true);
%Create UI elements
%     % Create slider
%     sld = uicontrol('Style', 'slider',...
%         'Min',1,'Max',AVI_Info.NumFrames,'Value',1,...
%         'SliderStep',[1/(AVI_Info.NumFrames- 1),10/(AVI_Info.NumFrames- 1)],...
%         'units','normalized',...
%         'Position', [0 0.95 1 0.05],...
%         'Callback', @slider_callback);
    txt = uicontrol('Style','text',...
        'units','normalized',...
        'Fontsize',6,...
        'Position',[0.01 0.8 0.98 0.2],...
        'String',MovieName);
    txt2 = uicontrol('Style','text',...
        'units','normalized',...
        'Fontsize',10,...
        'Position',[0.01 0.75 0.98 0.2],...
        'String','<<<D <R F> U>>>');
    btn2 = uicontrol('Style', 'togglebutton', 'String', 'GRID (Shift)',...
        'units','normalized',...
        'Position', [0.1 0.3 0.8 0.2],...
        'value',GridOn,...
        'Callback', @GridOn_callback);  
    btn1 = uicontrol('Style', 'togglebutton', 'String', 'Play/Pause (Space)',...
        'units','normalized',...
        'Position', [0.1 0.5 0.8 0.3],...
        'TooltipString','Interruptible = on',...
        'Interruptible','on',...
        'value',PlayBack,...
        'Callback', @PauserButton);  
    btn0 = uicontrol('Style', 'pushbutton', 'String', 'Exit(Ctrl/Esc/End)',...
        'units','normalized',...
        'Position', [0.1 0.0 0.8 0.3],...
        'TooltipString','Interruptible = on',...
        'Interruptible','on',...
        'Callback', @ExitMoviePlayer);
    set(MoviePlaybackController,'WindowKeyPressFcn',@Navigation_KeyPressFcn)
    figure(MoviePlaybackController);

    
    fprintf(['Playing: ',MovieName,'\n'])
    fprintf([num2str(FPS),' FPS :: ',num2str(AVI_Info.NumFrames),' Frames :: ',num2str(round(10*AVI_Info.FileSize/1e6)/10),' MB File\n'])
    % tic
    repeat=1;
    while repeat
        figure(MoviePlaybackController);
%         if FrameNum==1
%             BringAllToFront
%         end
        if FrameNum<AVI_Info.NumFrames
            FrameNum=FrameNum+1;
            if ~GridOn
                frame=MovieArray(:,:,:,FrameNum);
            else
                frame=MovieArray_GRID(:,:,:,FrameNum);
            end
            step(depVideoPlayer, frame);
            cont = ~isDone(videoFReader) && isOpen(depVideoPlayer);
            figure(MoviePlaybackController);

            %pause(FrameInterval)
            %ßpause(0.000000001)
            %pauser(clock,5)
            %java.lang.Thread.sleep(1000*FrameInterval)      
            t0=clock;
            sys_delay=0;
            if etime(clock,t0)+sys_delay<FrameInterval
                while etime(clock,t0)+sys_delay<FrameInterval
                    %cont = ~isDone(videoFReader) && isOpen(depVideoPlayer);
                    %if rem(etime(clock,t0),1000)==0
                        drawnow
                    %end
                    %refreshdata
                end
            end
            % t0=tic;
            % while toc(t0)<FrameInterval
            %     %fprintf('.');
            % end
        else 
            videoFReader   = vision.VideoFileReader(MovieName);
            depVideoPlayer = vision.DeployableVideoPlayer;
            set(depVideoPlayer,'Size','Custom','CustomSize',MovieSize,'Location',MovieLocation,'Name',MovieName);

            FrameNum=1;
            if ~GridOn
                frame=MovieArray(:,:,:,FrameNum);
            else
                frame=MovieArray_GRID(:,:,:,FrameNum);
            end
            step(depVideoPlayer, frame);

            figure(MoviePlaybackController);

            t0=clock;
            sys_delay=0;
            if etime(clock,t0)+sys_delay<1
                while etime(clock,t0)+sys_delay<1
                    %cont = ~isDone(videoFReader) && isOpen(depVideoPlayer);
                    %if rem(etime(clock,t0),1000)==0
                        drawnow
                    %end
                    %refreshdata
                end
            end
        end
        %set(sld,'Value',FrameNum)
        if PlayBack
            if ~isOpen(depVideoPlayer)
                repeat=0;
                PlayBack=0;    
                release(videoFReader);
                release(depVideoPlayer);
                clear depVideoPlayer videoFReader
                %cont1=input('<Enter> to continue or <1> to repeat');
                close(MoviePlaybackController)
                clear MovieArray MovieArray_Grid
                if ~isempty(which('MatlabGarbageCollector.jar'))    
                    org.dt.matlab.utilities.JavaMemoryCleaner.clear(0)
                end
                fprintf(['Closing: ',MovieName,'\n'])
                FINISHED_PLAYBACK=1;
            end
        end
%         if FrameNum==AVI_Info.NumFrames;
%             toc
%         end

    end


%         function slider_callback(src,eventdata,arg1)
%     %          Jump2FrameNum = get(src,'Value');
%     %          Jump2FrameNum=round(Jump2FrameNum);
%     %          if Jump2FrameNum>FrameNum
%     %              for i=1:Jump2FrameNum-FrameNum
%     %                  frame = step(videoFReader);
%     %              end
%     %              FrameNum=Jump2FrameNum;
%     %          end
% 
%         end
        function GridOn_callback(src,eventdata,arg1)
            GridOn = get(btn2,'Value');   
        end
    
        function PauserButton(src,eventdata,arg1)
            PlayBack=get(btn1,'Value');
            %PlayBack=~PlayBack;
            %set(btn1,'Value',PlayBack)
            Pauser
        end
        function Pauser
            if ~PlayBack
                uiwait
            else
                uiresume
            end
            if repeat
                set(btn1,'Value',PlayBack)
            end
        end
        function ExitMoviePlayer(src,eventdata,arg1)
            repeat=0;
            PlayBack=0;    
            try
                if exist('depVideoPlayer')
                    release(depVideoPlayer);
                    clear depVideoPlayer
                end
                if exist('videoFReader')
                    release(videoFReader);
                    clear videoFReader
                end
                close(MoviePlaybackController)
                if exist('MovieArray')
                    clear MovieArray
                end
                if ~isempty(which('MatlabGarbageCollector.jar'))    
                    org.dt.matlab.utilities.JavaMemoryCleaner.clear(0)
                end
            catch
                warning('Problem closing but will exit anyway...')
            end
            fprintf(['Closing: ',MovieName,'\n'])
            FINISHED_PLAYBACK=1;
        end

        function Navigation_KeyPressFcn(src, evnt)
            if isequal(evnt.Key,'space')
                PlayBack=get(btn1,'Value');
                PlayBack=~PlayBack;
                set(btn1,'Value',PlayBack)
                Pauser
            elseif isequal(evnt.Key,'shift')
                GridOn = get(btn2,'Value');
                GridOn=~GridOn;
                set(btn2,'Value',GridOn)
            elseif isequal(evnt.Key,'control')||isequal(evnt.Key,'escape')||isequal(evnt.Key,'end')
                ExitMoviePlayer;
            elseif isequal(evnt.Key,'rightarrow') %Pause and Step Forward
                if PlayBack
                    PlayBack=0;
                    set(btn1,'Value',PlayBack)
                    Pauser
                end
                if FrameNum<AVI_Info.NumFrames
                    FrameNum=round(FrameNum)+1;
                else
                    FrameNum=1;
                end
                if ~GridOn
                    frame=MovieArray(:,:,:,FrameNum);
                else
                    frame=MovieArray_GRID(:,:,:,FrameNum);
                end
                if exist('depVideoPlayer')
                    step(depVideoPlayer, frame);
                    cont = ~isDone(videoFReader) && isOpen(depVideoPlayer);
                end
                if ishandle('MoviePlaybackController')
                    figure(MoviePlaybackController);
                end
            elseif isequal(evnt.Key,'uparrow') %Jump Forward and Play
                if FrameNum+FrameJump<AVI_Info.NumFrames
                    FrameNum=round(FrameNum)+FrameJump+1;
                else
                    FrameNum=1;
                end
                if ~GridOn
                    frame=MovieArray(:,:,:,FrameNum);
                else
                    frame=MovieArray_GRID(:,:,:,FrameNum);
                end
                if exist('depVideoPlayer')
                    step(depVideoPlayer, frame);
                    cont = ~isDone(videoFReader) && isOpen(depVideoPlayer);
                end
                if ~PlayBack
                    PlayBack=1;
                    set(btn1,'Value',PlayBack)
                    Pauser
                end
                if ishandle('MoviePlaybackController')
                    figure(MoviePlaybackController);
                end
            elseif isequal(evnt.Key,'leftarrow') %Pause and Step Backward
                if PlayBack
                    PlayBack=0;
                    set(btn1,'Value',PlayBack)
                    Pauser
                end
                if FrameNum>1
                    FrameNum=round(FrameNum)-1;
                else
                    FrameNum=AVI_Info.NumFrames;
                end
                if ~GridOn
                    frame=MovieArray(:,:,:,FrameNum);
                else
                    frame=MovieArray_GRID(:,:,:,FrameNum);
                end
                if exist('depVideoPlayer')
                    step(depVideoPlayer, frame);
                    cont = ~isDone(videoFReader) && isOpen(depVideoPlayer);
                end
                if ishandle('MoviePlaybackController')
                    figure(MoviePlaybackController);
                end
            elseif isequal(evnt.Key,'downarrow') %Jump Backward and Play
                if FrameNum-FrameJump>1
                    FrameNum=round(FrameNum)-FrameJump-1;
                else
                    FrameNum=AVI_Info.NumFrames;
                end
                if ~GridOn
                    frame=MovieArray(:,:,:,FrameNum);
                else
                    frame=MovieArray_GRID(:,:,:,FrameNum);
                end
                if exist('depVideoPlayer')
                    step(depVideoPlayer, frame);
                    cont = ~isDone(videoFReader) && isOpen(depVideoPlayer);
                end
                if ishandle('MoviePlaybackController')
                    figure(MoviePlaybackController);
                end
                if ~PlayBack
                    PlayBack=1;
                    set(btn1,'Value',PlayBack)
                    Pauser
                end
            end
        end


  end