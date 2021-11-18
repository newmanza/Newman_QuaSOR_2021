%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
[~,HighlightFrameRange(1)] = min(abs(XData_Imaging_Adjusted-HighlightXLim(1)));
[~,HighlightFrameRange(2)] = min(abs(XData_Imaging_Adjusted-HighlightXLim(2)));

HighlightRange=[HighlightFrameRange(1):HighlightFrameRange(2)];
EventSubList=[];
Count=0;
for i1=1:length(HighlightRange)
    i=HighlightRange(i1);
    for e=1:length(EventStruct)
        if any(EventStruct(e).MaxCoord(3)==i)
            Count=Count+1;
            EventSubList(Count).MaxCoord=EventStruct(e).MaxCoord;
            if UseSmoothedTraces
                EventSubList(Count).DeltaFF0_Trace=EventStruct(e).DeltaFF0_Trace_Smoothed;
            else
                EventSubList(Count).DeltaFF0_Trace=EventStruct(e).DeltaFF0_Trace;
            end
            MaxAmps(Count)=max(EventSubList(Count).DeltaFF0_Trace(:));
        end
    end
end
LineColors=varycolor(Count);

if ~exist('TileGroups')
    TileGroups=Count;
end
if isempty(TileGroups)
    TileGroups=Count;
end  
if any(ImagingHighightYRange<0)
    TileShift=-1*max(MaxAmps);
    TileOffset=-1*(TileShift-ImagingHighightYRange(1))/TileGroups;
else
    TileShift=0;
    TileOffset=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
if UseSmoothedTraces
    AdditionalText=[' Smooth',num2str(ImageTraceSmooth)];
else
    AdditionalText=[];
end
if TileOffset
    AdditionalText=[AdditionalText,' Tiled'];
end
if IncludeImages
    AdditionalText=[AdditionalText,' and Images'];
end
FigName=[CurrentAnalysisLabelShort,' Highlight ',EpisodeLabel,' ',num2str(HighlightXLim(1)),'-',num2str(HighlightXLim(2)),HighlightTimeScale,AdditionalText];
fprintf(['Exporting: ',FigName,'...'])
AlignFig=figure('name',StackSaveName);


if IncludeImages
    s1=subtightplot(2,2,2,[0,0],[0,0],[0,0]);
else
    s1=subtightplot(2,1,1,[0,0],[0,0],[0,0]);
end

hold on
plot(XData_Ephys,ConcatenatedTrace,'-','linewidth',0.5,'color','k')
xlim(HighlightXLim)
ylim(EphysHighlightYLim)
YLimits=ylim;
XLimits=xlim;
hold on
p1a=plot([XLimits(1)+0.1,XLimits(1)+0.1+HighlightHorzScale],[YLimits(2),YLimits(2)]-(YLimits(2)-YLimits(1))*0.05,...
    '-','color','k','linewidth',3);
t1a=text(mean([XLimits(1)+0.1,XLimits(1)+0.1+HighlightHorzScale]),[YLimits(2)]-(YLimits(2)-YLimits(1))*0.05,...
    [num2str(HighlightHorzScale),' ',HighlightTimeScale],'color','k','fontsize',14,'horizontalalignment','center','verticalalignment','top');
p1b=plot([XLimits(1),XLimits(1)]+(XLimits(2)-XLimits(1))*0.01,[YLimits(2),YLimits(2)-EphysHighlightScale]-(YLimits(2)-YLimits(1))*0.05,...
    '-','color','k','linewidth',3);
t1b=text(XLimits(1)+(XLimits(2)-XLimits(1))*0.01,mean([YLimits(2),YLimits(2)-EphysHighlightScale]-(YLimits(2)-YLimits(1))*0.05),...
    [' ',num2str(EphysHighlightScale),' ',EphysUnit],'color','k','fontsize',14,'horizontalalignment','left','verticalalignment','middle'); 
box off
axis off
TempPos=get(s1,'position');
TempPos(2)=0.75;
TempPos(4)=0.25;
set(s1,'position',TempPos);


if IncludeImages
    s2=subtightplot(2,2,4,[0,0],[0,0],[0,0]);
else
    s2=subtightplot(2,1,2,[0,0],[0,0],[0,0]);
end
hold on
TileCount=0;
for e=1:length(EventSubList)
    TileCount=TileCount+1;
    if EventSubList(e).MaxCoord(3)-PreFrames<1
        TempX=[1:EventSubList(e).MaxCoord(3)+PostFrames];
    elseif EventSubList(e).MaxCoord(3)+PostFrames>length(EventSubList(e).DeltaFF0_Trace)
        TempX=[EventSubList(e).MaxCoord(3)-PreFrames:length(EventSubList(e).DeltaFF0_Trace)];
    else
        TempX=[EventSubList(e).MaxCoord(3)-PreFrames:EventSubList(e).MaxCoord(3)+PostFrames];
    end
    TempY=EventSubList(e).DeltaFF0_Trace(TempX)+TileShift+TileOffset*(TileCount);
    TempX=XData_Imaging_Adjusted(TempX);
    
    plot(TempX,TempY,'-','linewidth',1,'color',LineColors(e,:));
    
    if TileCount==TileGroups
        TileCount=0;
    end
    
end
xlim(HighlightXLim)
ylim(ImagingHighightYRange)
YLimits=ylim;
XLimits=xlim;
hold on
TileCount=0;
for e=1:length(EventSubList)
    TileCount=TileCount+1;
    if EventSubList(e).MaxCoord(3)-PreFrames<1
        TempX=[1:EventSubList(e).MaxCoord(3)+PostFrames];
        TracerFrames=[1:EventSubList(e).MaxCoord(3)+TracerPostFrames];
    elseif EventSubList(e).MaxCoord(3)+PostFrames>length(EventSubList(e).DeltaFF0_Trace)
        TempX=[EventSubList(e).MaxCoord(3)-PreFrames:length(EventSubList(e).DeltaFF0_Trace)];
        TracerFrames=[EventSubList(e).MaxCoord(3)-TracerPreFrames:length(EventSubList(e).DeltaFF0_Trace)];
    else
        TempX=[EventSubList(e).MaxCoord(3)-PreFrames:EventSubList(e).MaxCoord(3)+PostFrames];
        TracerFrames=[EventSubList(e).MaxCoord(3)-TracerPreFrames:EventSubList(e).MaxCoord(3)+TracerPostFrames];
    end
    TempY=EventSubList(e).DeltaFF0_Trace(TempX)+TileShift+TileOffset*(TileCount);
    Slope=[];
    TracerIndices=[];
    for i=1:length(TempX)-1
        if any(TempX(i)==TracerFrames)
            TracerIndices(i)=1;
        else
            TracerIndices(i)=0;
        end
    end
    for i=1:length(TempY)-1
        Slope(i)=TempY(i+1)-TempY(i);
    end
    Slope=Slope.*TracerIndices;
    [~,MaxSlope]=max(Slope);
    TempX=XData_Imaging_Adjusted(TempX);
    PeakX=TempX(MaxSlope);
    PeakY=TempY(MaxSlope);
    plot([PeakX,PeakX],[YLimits(2),PeakY],...
        ':','color',LineColors(e,:),'linewidth',0.5)
    if TileCount==TileGroups
        TileCount=0;
    end
end
YLimits=ylim;
XLimits=xlim;
if any(ImagingHighightYRange<0)
    p2a=plot([XLimits(1),XLimits(1)]+(XLimits(2)-XLimits(1))*0.015,...
        -1*[(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale],...
        '-','color','k','linewidth',3);
    t2a=text(XLimits(1)+(XLimits(2)-XLimits(1))*0.015,...
        -1*mean([(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale]),...
        [' ',num2str(ImagingHighlightScale),' ',ImagingHighlightUnit],...
        'color','k','fontsize',14,'horizontalalignment','left','verticalalignment','middle');
else
    p2a=plot([XLimits(1),XLimits(1)]+(XLimits(2)-XLimits(1))*0.015,...
        [(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale],...
        '-','color','k','linewidth',3);
    t2a=text(XLimits(1)+(XLimits(2)-XLimits(1))*0.015,...
        mean([(YLimits(2)-YLimits(1))/2,(YLimits(2)-YLimits(1))/2+ImagingHighlightScale]),...
        [' ',num2str(ImagingHighlightScale),' ',ImagingHighlightUnit],...
        'color','k','fontsize',14,'horizontalalignment','left','verticalalignment','middle');
end
box off
axis off
TempPos=get(s2,'position');
TempPos(4)=1;
set(s2,'position',TempPos);


if IncludeImages
    s0=subtightplot(2,2,3,[0,0],[0,0],[0,0]);
    imshow(zeros(size(AllBoutonsRegion)),'border','tight');
    TempPos=get(s0,'position');
    TempPos(4)=1;
    set(s0,'position',TempPos);

end



set(gcf,'units','normalized','position',[0,0.05,1,0.85]);
fprintf('Finished!\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
