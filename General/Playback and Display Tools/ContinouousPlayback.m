function ContinouousPlayback(FIGHANDLE,PLAYBACKON,ImageArray,PauseInterval,IntensityLimits,AllBoutonsRegion,BorderLineStruct,HighlightFrames,HighlightColor,MovieColormap)
    figure(FIGHANDLE);
    set(FIGHANDLE,'WindowKeyPressFcn',@Navigation_KeyPressFcn)
    LastRangeNumber = size(ImageArray, 3);
    ImageNumber=0;
    Pause=0;
    while ishandle(FIGHANDLE)&&PLAYBACKON
        if ~Pause
       if ImageNumber<LastRangeNumber
           ImageNumber=ImageNumber+1;
           TempImage=ImageArray(:,:,ImageNumber).*AllBoutonsRegion;
           TempImage(~AllBoutonsRegion)=NaN;
           imagesc(TempImage);
           colormap(MovieColormap)
            caxis(IntensityLimits)
            hold on
            set(gcf, 'color', 'white');
            set(gca,'XTick', []);
            set(gca,'YTick', []);
            set(gca,'position',[0,0,1,1])
           axis equal tight;
           if ~isempty(BorderLineStruct)
                if any(ImageNumber==HighlightFrames)
                    for j=1:length(BorderLineStruct.BorderLine)
                        plot(BorderLineStruct.BorderLine{j}.BorderLine(:,2)+BorderLineStruct.BorderLineAdjustment,...
                            BorderLineStruct.BorderLine{j}.BorderLine(:,1)+BorderLineStruct.BorderLineAdjustment,...
                            '-' , 'color', HighlightColor,'linewidth', BorderLineStruct.BorderThickness); 
                    end

                else
                    for j=1:length(BorderLineStruct.BorderLine)
                        plot(BorderLineStruct.BorderLine{j}.BorderLine(:,2)+BorderLineStruct.BorderLineAdjustment,...
                            BorderLineStruct.BorderLine{j}.BorderLine(:,1)+BorderLineStruct.BorderLineAdjustment,...
                            '-' , 'color', BorderLineStruct.BorderColor,'linewidth', BorderLineStruct.BorderThickness); 
                    end
                end
           end
           text(5,10,num2str(ImageNumber),'fontsize',14,'color','w');
           drawnow;
           pause(PauseInterval);
       else
           ImageNumber=0;
           clf
       end
        else
            
           pause(1); 
        end
    end
    
    function Navigation_KeyPressFcn(src, evnt)
       if isequal(evnt.Key,'control')||isequal(evnt.Key,'escape')||isequal(evnt.Key,'return')||isequal(evnt.Key,'numpad0')
           PLAYBACKON=0;
           close(FIGHANDLE);
       elseif isequal(evnt.Key,'space')
           Pause=~Pause;
       end
    end
end