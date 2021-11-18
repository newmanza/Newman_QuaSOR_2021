function [TempTrace2]=Smart_Trace_Align(TempTrace1,AlignFrame,FrameWindow,MaxFrames)
%Smart_Trace_Align(All_TestTraces_DeltaFF0(i,:),All_TestTraces_Event_Peaks(i),EventDetectionSettings.SimpleEventTestFrameWindow,ImagingInfo.FramesPerEpisode)
% TempTrace1=All_TestTraces_DeltaFF0(i,:);
% FrameWindow=EventDetectionSettings.SimpleEventTestFrameWindow
% MaxFrames=ImagingInfo.FramesPerEpisode;
% AlignFrame=All_TestTraces_Event_Peaks(i)
    TempTrace2=zeros(1,FrameWindow(2)+FrameWindow(1)+1);
    TempTrace2(TempTrace2==0)=NaN;
    
    TempFrames1=[AlignFrame-FrameWindow(1):...
        AlignFrame+FrameWindow(2)];
    TempFrames2=[1:length(TempFrames1)];
    
    if any(TempFrames1<1)
        warning('Right Shifting a Trace')
        FrameShift=sum(TempFrames1<1);
        TempFrames1_Adjusted=TempFrames1(1+FrameShift):length(TempFrames1)-FrameShift;
        TempFrames2_Adjusted=TempFrames2+FrameShift:length(TempFrames2);
    elseif any(TempFrames1>MaxFrames)
        warning('Left Shifting a Trace')
        FrameShift=sum(TempFrames1>MaxFrames);
        TempFrames1_Adjusted=TempFrames1(1):TempFrames1(length(TempFrames1)-FrameShift);
        TempFrames2_Adjusted=TempFrames2(1):length(TempFrames2)-FrameShift;
    else
        FrameShift=0;
        TempFrames1_Adjusted=TempFrames1;
        TempFrames2_Adjusted=TempFrames2;
    end
    TempTrace2(TempFrames2_Adjusted)=TempTrace1(TempFrames1_Adjusted);
end