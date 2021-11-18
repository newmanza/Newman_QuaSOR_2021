function AutoPlaybackNew(ImageArray,FrameInterval,PauseInterval,IntensityLimits,Coloring)
%   1,0.0001,[],'jet')
if isempty(Coloring)
    Coloring=jet;
end
if isempty(FrameInterval)
    FrameInterval=1;
end

ImageHeight=size(ImageArray,1);
ImageWidth=size(ImageArray,2);
ScreenSize=get(0,'ScreenSize');

AspectRatio=ImageWidth/ImageHeight;

ScaledValue=0.5*ScreenSize(4);

figure();
subtightplot(1,1,1,[0,0],[0,0],[0,0])
set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
hold on
imagesc(zeros(ImageHeight,ImageWidth)),colormap('gray');
axis equal tight; 
set(gcf,'units','pixels')
Pos=get(gcf,'position');
set(gcf,'position',[0.05*ScreenSize(4),0.05*ScreenSize(4),AspectRatio*ScaledValue,ScaledValue])
%set(gca,'units','normalized','position',[0.05,0.05,AspectRatio*ScaledValue,ScaledValue])
set(gca,'Ydir','reverse')
BringAllToFront();
Beeper(5,0.15)


message = sprintf('Ready to start playback of array, press OK to continue');
uiwait(msgbox(message));

pause(1);
pause on;
set(gcf,'SelectionType','extend');

if isempty(IntensityLimits)
    LastRangeNumber = size(ImageArray, 3);
    for ImageNumber = 1:FrameInterval:LastRangeNumber
        st=get(gcf,'SelectionType');
        if st(1)=='n'
        pause
        end
        set(gcf,'SelectionType','extend');
       cla
        subtightplot(1,1,1,[0,0],[0,0],[0,0])
        imagesc(ImageArray(:,:,ImageNumber)); axis equal tight; %change intensity range here
       colormap(Coloring)
       text(5,10,num2str(ImageNumber),'fontsize',14,'color','w');
        set(gcf, 'color', 'white');title('Click anywhere on image to pause and any keyboard button to unpause');set(gca,'XTick', []); set(gca,'YTick', []);
       drawnow;
       pause(PauseInterval);
    end
else
    LastRangeNumber = size(ImageArray, 3);
    for ImageNumber = 1:FrameInterval:LastRangeNumber
        
        st=get(gcf,'SelectionType');
        if st(1)=='n'
        pause
        end
        set(gcf,'SelectionType','extend');
        cla
        subtightplot(1,1,1,[0,0],[0,0],[0,0])
        imagesc(ImageArray(:,:,ImageNumber),IntensityLimits); axis equal tight; %change intensity range here
        colormap(Coloring)
       text(5,10,num2str(ImageNumber),'fontsize',14,'color','w');
       %colorbar;
        set(gcf, 'color', 'white');title('Click anywhere on image to pause and any keyboard button to unpause');set(gca,'XTick', []); set(gca,'YTick', []);
       drawnow;
       pause(PauseInterval);
    end
    
end
hold off
pause(1); close gcf



end