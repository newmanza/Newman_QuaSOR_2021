function AutoPlayback(ImageArray,PauseInterval,IntensityLimits)

figure();
set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
BringAllToFront();
Beeper(5,0.15)


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