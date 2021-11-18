function BoundingBox=SafeBoundingBox(Image,BoundingBox)

    ImageHeight=size(Image,1);
    ImageWidth=size(Image,2);
    
    if BoundingBox(3)>ImageWidth||BoundingBox(4)>ImageHeight
        error('This box will not fit!')
    end
    if BoundingBox(1)<=0
        warning('Adjusting X')
        BoundingBox(1)=1;
    end
    if BoundingBox(2)<=0
        warning('Adjusting Y')
        BoundingBox(2)=1;
    end
    if BoundingBox(1)+BoundingBox(3)>ImageWidth
        warning('Adjusting X')
        BoundingBox(1)=BoundingBox(1)-((BoundingBox(1)+BoundingBox(3))-ImageWidth);
    end
    if BoundingBox(2)+BoundingBox(4)>ImageHeight
        warning('Adjusting Y')
        BoundingBox(2)=BoundingBox(2)-((BoundingBox(2)+BoundingBox(4))-ImageHeight);
    end



end