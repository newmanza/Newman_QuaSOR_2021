


function Output_Image_RGB=Color_NAN_Masking(Input_Image_RGB,Mask)
    try
        Mask=logical(Mask);
        Input_Image_R=Input_Image_RGB(:,:,1);
        Input_Image_G=Input_Image_RGB(:,:,2);
        Input_Image_B=Input_Image_RGB(:,:,3);

        Input_Image_R(Mask)=NaN;
        Input_Image_G(Mask)=NaN;
        Input_Image_B(Mask)=NaN;

        Output_Image_RGB=cat(3,Input_Image_R,cat(3,Input_Image_G,Input_Image_B));
    catch
        warning('Memory issue Trying Again...')
        Input_Image_RGB=single(Input_Image_RGB);
        Input_Image_R=Input_Image_RGB(:,:,1);
        Input_Image_G=Input_Image_RGB(:,:,2);
        Input_Image_B=Input_Image_RGB(:,:,3);

        Input_Image_R(Mask)=NaN;
        Input_Image_G(Mask)=NaN;
        Input_Image_B(Mask)=NaN;

        Output_Image_RGB=cat(3,Input_Image_R,cat(3,Input_Image_G,Input_Image_B));
        %Output_Image_RGB=double(Output_Image_RGB);
    end
end



