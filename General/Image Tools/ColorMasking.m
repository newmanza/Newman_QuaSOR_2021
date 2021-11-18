


function Output_Image_RGB=ColorMasking(Input_Image_RGB,Mask,OverlayColor)
    if size(Input_Image_RGB,1)~=size(Mask,1)||size(Input_Image_RGB,2)~=size(Mask,2)
        warning(['Input Height = ',num2str(size(Input_Image_RGB,1))])
        warning(['Mask Height = ',num2str(size(Mask,1))])
        warning(['Input Width = ',num2str(size(Input_Image_RGB,2))])
        warning(['Mask Width = ',num2str(size(Mask,2))])
        error('Size Mismatch!')
    end
    if size(Input_Image_RGB,3)~=3
        error('Must provide an RGB Image!')
    end
    try
        Mask=logical(Mask);
        Input_Image_R=Input_Image_RGB(:,:,1);
        Input_Image_G=Input_Image_RGB(:,:,2);
        Input_Image_B=Input_Image_RGB(:,:,3);

        Input_Image_R(Mask)=OverlayColor(1);
        Input_Image_G(Mask)=OverlayColor(2);
        Input_Image_B(Mask)=OverlayColor(3);

        Output_Image_RGB=cat(3,Input_Image_R,cat(3,Input_Image_G,Input_Image_B));
    catch
        warning('Memory issue Trying Again...')
        Input_Image_RGB=single(Input_Image_RGB);
        Input_Image_R=Input_Image_RGB(:,:,1);
        Input_Image_G=Input_Image_RGB(:,:,2);
        Input_Image_B=Input_Image_RGB(:,:,3);

        Input_Image_R(Mask)=OverlayColor(1);
        Input_Image_G(Mask)=OverlayColor(2);
        Input_Image_B(Mask)=OverlayColor(3);

        Output_Image_RGB=cat(3,Input_Image_R,cat(3,Input_Image_G,Input_Image_B));
        %Output_Image_RGB=double(Output_Image_RGB);
    end
end



