function Auto_ScaleBar(ImageHeight,ImageWidth,PixelSize,ScaleBar_Size,ScaleBar_Location,ScaleBar_LineWitdh,ScaleBar_LineColor,BufferRatio_X,BufferRatio_Y)

    if strcmp(ScaleBar_Location,'BL')
        plot([ImageWidth*BufferRatio_X,ImageWidth*BufferRatio_X+ScaleBar_Size/PixelSize], [ImageHeight-BufferRatio_Y*ImageHeight,ImageHeight-BufferRatio_Y*ImageHeight],'-','color',ScaleBar_LineColor,'LineWidth',ScaleBar_LineWitdh)
    elseif strcmp(ScaleBar_Location,'BR')
        plot([ImageWidth-ImageWidth*BufferRatio_X-ScaleBar_Size/PixelSize,ImageWidth-ImageWidth*BufferRatio_X], [ImageHeight-BufferRatio_Y*ImageHeight,ImageHeight-BufferRatio_Y*ImageHeight],'-','color',ScaleBar_LineColor,'LineWidth',ScaleBar_LineWitdh)
    elseif strcmp(ScaleBar_Location,'TL')
        plot([ImageWidth*BufferRatio_X,ImageWidth*BufferRatio_X+ScaleBar_Size/PixelSize], [BufferRatio_Y*ImageHeight,BufferRatio_Y*ImageHeight],'-','color',ScaleBar_LineColor,'LineWidth',ScaleBar_LineWitdh)
    elseif strcmp(ScaleBar_Location,'TR')
        plot([ImageWidth-ImageWidth*BufferRatio_X-ScaleBar_Size/PixelSize,ImageWidth-ImageWidth*BufferRatio_X], [BufferRatio_Y*ImageHeight,BufferRatio_Y*ImageHeight],'-','color',ScaleBar_LineColor,'LineWidth',ScaleBar_LineWitdh)
    end

end