function AutoPlaybackBig(ImageArray,PauseInterval,IntensityLimits)

SizeScaleFactor=1.5;

figure();
set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
BringAllToFront();
Beeper(5,0.15)



ArraySize=size(ImageArray);

ScreenSize=get(0, 'screensize');
if ScreenSize(3)>ArraySize(2)*SizeScaleFactor+40&&ScreenSize(4)>ArraySize(1)*SizeScaleFactor+40
    set(gcf,'position',[10,40,ScreenSize(3),ScreenSize(4)])
elseif ScreenSize(3)<ArraySize(2)*SizeScaleFactor+40
    set(gcf,'position',[10,40,ScreenSize(3),ArraySize(1)*SizeScaleFactor])
elseif ScreenSize(4)<ArraySize(1)*SizeScaleFactor+40
    set(gcf,'position',[10,40,ArraySize(2)*SizeScaleFactor,ScreenSize(4)])
else
    set(gcf,'position',[10,40,ArraySize(2)*SizeScaleFactor,ArraySize(1)*SizeScaleFactor])
end
subtightplot(1,1,1,[0,0],[0,0.05],[0,0])

message = sprintf('Ready to start playback of array, press OK to continue');
uiwait(msgbox(message));

pause(1);
pause on;
set(gcf,'SelectionType','extend');

if isempty(IntensityLimits)
    LastRangeNumber = size(ImageArray, 3);
    for ImageNumber = 1:LastRangeNumber
        st=get(gcf,'SelectionType');
        if st(1)=='n'
        pause
        end
        set(gcf,'SelectionType','extend');
       imagesc(ImageArray(:,:,ImageNumber)); axis equal tight; %change intensity range here
       text(5,10,num2str(ImageNumber),'fontsize',14,'color','w');
        set(gcf, 'color', 'white');title('Click anywhere on image to pause and any keyboard button to unpause');set(gca,'XTick', []); set(gca,'YTick', []);
       drawnow;
       pause(PauseInterval);
    end
else
    LastRangeNumber = size(ImageArray, 3);
    for ImageNumber = 1:LastRangeNumber
        
        st=get(gcf,'SelectionType');
        if st(1)=='n'
        pause
        end
        set(gcf,'SelectionType','extend');
       imagesc(ImageArray(:,:,ImageNumber),IntensityLimits); axis equal tight; %change intensity range here
       text(5,10,num2str(ImageNumber),'fontsize',14,'color','w');
        set(gcf, 'color', 'white');title('Click anywhere on image to pause and any keyboard button to unpause');set(gca,'XTick', []); set(gca,'YTick', []);
       drawnow;
       pause(PauseInterval);
    end
    
end
hold off
pause(1); close gcf



end