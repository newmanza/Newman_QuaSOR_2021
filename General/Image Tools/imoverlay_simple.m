function Image_Overlay=imoverlay_simple(Image,Mask,Color)

        out_red   = Image(:,:,1);
        out_green = Image(:,:,2);
        out_blue  = Image(:,:,3);
        out_red(Mask)   = Color(1);
        out_green(Mask) = Color(2);
        out_blue(Mask)  = Color(3);
        Image_Overlay = cat(3, out_red, out_green, out_blue);
        clear out_red out_green out_blue



end