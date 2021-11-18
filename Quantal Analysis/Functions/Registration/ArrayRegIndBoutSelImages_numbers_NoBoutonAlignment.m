% Motion correction according to DeltaX, DeltaY of individual boutons.
% BoutonArray(BoutonNumber).DeltaX, .DeltaY contain the deltas for some of
% the images. The indices of these images are in DeltaXY_ImageNumbers
% (and should be also in BoutonArray(1).DeltaXY_ImageNumbers).
% ImageArray_NoStim contains more images (the above images and additional
% ones), their numbers are in GoodImages_NoStim.
%
% This function should:
% 1. Find which images in GoodImages_NoStim have DeltaX, DeltaY in DeltaXY_ImageNumbers
% 2. Shift by DeltaX, DeltaY (one number for each bouton): these images and all following images (until
% the next image that has its own DeltaX, DeltaY)

function ImageArrayReg_NoStim = ArrayRegIndBoutSelImages_numbers_NOBoutonAlignment(ImageArray_NoStim, GoodImages_NoStim, DeltaXY_ImageNumbers, DeltaX_First, DeltaY_First)

% Find which images in GoodImages_NoStim have DeltaX, DeltaY in DeltaXY_ImageNumbers
% Index_GoodImages - indices in GoodImages_NoStim
% Index_DeltaXY - indices in DeltaXY_ImageNumbers
% Example:
% GoodImages_NoStim = [445:814]
% DeltaXY_ImageNumbers = [ 1 38 75 260 297 334 371 408 445 482 519 556 593 630 667 704 741 778]
% Index_GoodImages = [1 38 75 112 149 186 223 260 297 334]
% Index_DeltaXY = [9:18]
[Index_GoodImages_tf, Index_DeltaXY] = ismember(GoodImages_NoStim, DeltaXY_ImageNumbers);
Index_GoodImages = find(Index_GoodImages_tf);
Index_DeltaXY = nonzeros(Index_DeltaXY);


% Go over indices and shift image array

Vector_Length = length(Index_GoodImages);
for Vector_Index=1:Vector_Length
    % Image array
    clear ImageArray
    FirstImageNumber = Index_GoodImages(Vector_Index);
    if (Vector_Index==Vector_Length)
        LastImageNumber = length(GoodImages_NoStim);
    else
        LastImageNumber = Index_GoodImages(Vector_Index + 1) - 1;
    end
    ImageArray = ImageArray_NoStim(:,:, FirstImageNumber:LastImageNumber);
    ImageArray = double(ImageArray);
    ImageArrayReg_OneSequence = double(zeros(size(ImageArray)));

    % For the above example, FirstImageNumber-LastImageNumber will have
    % values: 1-37, 38-74, 75-111, 112-148, 149-185, 186-222, 223-259,
    % ....,334-370.

    
    % Motion correction for ImageArray
    LastImageNumber = size(ImageArray, 3);
    %LastBoutonNumber = size(BoutonArray, 2);
    %for BoutonNumber=1:LastBoutonNumber
    
        DeltaX = DeltaX_First(Index_DeltaXY(Vector_Index)); %%%
        DeltaY = DeltaY_First(Index_DeltaXY(Vector_Index));
        %DeltaX = BoutonArray(BoutonNumber).DeltaX(Index_DeltaXY(Vector_Index)) + DeltaX_First(Index_DeltaXY(Vector_Index)); %%%
        %DeltaY = BoutonArray(BoutonNumber).DeltaY(Index_DeltaXY(Vector_Index))+ DeltaY_First(Index_DeltaXY(Vector_Index));
        %BoutonArea = BoutonArray(BoutonNumber).ImageArea;
    
        ImageArray_Tmp = TranslateArraySimple(ImageArray, DeltaX, DeltaY); % translating array
    
        for ImageNumber=1:LastImageNumber
            ImageArray_Tmp(:,:,ImageNumber) = ImageArray_Tmp(:,:,ImageNumber); % multiplying by BoutonArea
        end

        ImageArrayReg_OneSequence = max(ImageArrayReg_OneSequence, ImageArray_Tmp);  
%      ImageArray_DeltaGFPnMax_Reg2 = ImageArray_DeltaGFPnMax_Reg2 | ImageArray_Tmp;  
              
    end % BoutonNumber
    
    % % Concatenate the current sequence to the output array
    if (Vector_Index==1)
        ImageArrayReg_NoStim = ImageArrayReg_OneSequence;
    else
        ImageArrayReg_NoStim = cat(3, ImageArrayReg_NoStim, ImageArrayReg_OneSequence); 
    end
    
end % Vector_Index


