function [ScaleBarLine,ScaleBarLabel]=Auto_ScaleBar_wText(ImageHeight,ImageWidth,PixelSize,ScaleBar_Size,ScaleBar_Unit,ScaleBar_FontSize,ScaleBar_Location,ScaleBar_LineWitdh,ScaleBar_LineColor,BufferRatio_X,BufferRatio_Y)
    ScaleBar_Length=ScaleBar_Size/PixelSize;
    if strcmp(ScaleBar_Location,'BL')
        ScaleBarPos(1)=ImageWidth*BufferRatio_X;
        ScaleBarPos(2)=ImageHeight-BufferRatio_Y*ImageHeight;
    elseif strcmp(ScaleBar_Location,'BR')
        ScaleBarPos(1)=ImageWidth-ImageWidth*BufferRatio_X-ScaleBar_Length;
        ScaleBarPos(2)=ImageHeight-BufferRatio_Y*ImageHeight;
    elseif strcmp(ScaleBar_Location,'TL')
        ScaleBarPos(1)=ImageWidth*BufferRatio_X;
        ScaleBarPos(2)=BufferRatio_Y*ImageHeight;
    elseif strcmp(ScaleBar_Location,'TR')
        ScaleBarPos(1)=ImageWidth-ImageWidth*BufferRatio_X-ScaleBar_Length;
        ScaleBarPos(2)=BufferRatio_Y*ImageHeight;
    else
        ScaleBar_Location
        error
    end
    hold on
    ScaleBarLine=plot([ScaleBarPos(1),ScaleBarPos(1)+ScaleBar_Length], [ScaleBarPos(2),ScaleBarPos(2)],'-','color',ScaleBar_LineColor,'LineWidth',ScaleBar_LineWitdh);
    hold on
    if ~isempty(ScaleBar_Unit)
        ScaleBarLabel=text(ScaleBarPos(1)+(ScaleBarPos(1)+ScaleBar_Length-ScaleBarPos(1))/2,...
            ScaleBarPos(2)-(ScaleBar_Length)*0.05,...
            [num2str(ScaleBar_Size),' ',ScaleBar_Unit],'color',ScaleBar_LineColor,'FontName','Arial','FontSize',ScaleBar_FontSize,'horizontalalignment','center','verticalalignment','bottom');
    else
        ScaleBarLabel=[];
    end
end