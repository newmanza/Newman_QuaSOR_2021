function Safe_imwrite(Image,FileNameDir,FileType)
    ReSizeMethod='bicubic';
    ReduceRatio=0.95;
    if ~strcmp(class(Image),'double')
        warning on
        warning('Must convert image to double first!')
        Image=double(Image);
    end
    ImageInfo=whos('Image');
    if ImageInfo.bytes>(2^32-1)
        warning on
        warning(['Image is greater than (2^32-1 bytes! reducing size by ',num2str(ReduceRatio),'!'])
        Image=imresize(Image,ReduceRatio,ReSizeMethod);
        ImageInfo=whos('Image');
        if ImageInfo.bytes>(2^32-1)
            warning on
            warning(['Image is greater than (2^32-1 bytes! reducing size AGAIN by ',num2str(ReduceRatio),'!'])
            Image=imresize(Image,ReduceRatio,ReSizeMethod);
            ImageInfo=whos('Image');
            if ImageInfo.bytes>(2^32-1)
                warning on
                warning(['Image is greater than (2^32-1 bytes! reducing size AGAIN by ',num2str(ReduceRatio),'!'])
                Image=imresize(Image,ReduceRatio,ReSizeMethod);
            end
        end
    end
    
    
    
    
    
   imwrite(Image,FileNameDir,FileType)
end