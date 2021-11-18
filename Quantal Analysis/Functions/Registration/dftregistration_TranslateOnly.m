
function [DFT_Output]=dftregistration_TranslateOnly(DFT_Input,OutputParams,usfac)
    DFT_Input=fft2(DFT_Input);
    if(usfac > 0)
        [nr,nc]=size(DFT_Input);
        Nr = ifftshift([-fix(nr/2):ceil(nr/2)-1]);
        Nc = ifftshift([-fix(nc/2):ceil(nc/2)-1]);
        [Nc,Nr] = meshgrid(Nc,Nr);
        DFT_Output = DFT_Input.*exp(i*2*pi*(-OutputParams(3)*Nr/nr-OutputParams(4)*Nc/nc));
        DFT_Output = DFT_Output*exp(i*OutputParams(2));
    elseif (usfac == 0)
        DFT_Output = DFT_Input*exp(i*OutputParams(2));
    end
    
    DFT_Output=double(real(ifft2(DFT_Output)));

end