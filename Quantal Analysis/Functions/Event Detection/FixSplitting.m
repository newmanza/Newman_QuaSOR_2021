
% Fix possible splitting of responses between two consecutive frames

function ImageArray_NoStim_CorrAmp_norm_2 = FixSplitting(ImageArray_NoStim_CorrAmp_norm, ImagesPerSequence)

    ImageArray_NoStim_CorrAmp_norm_2 = zeros(size(ImageArray_NoStim_CorrAmp_norm));

    NumOfSequences = size(ImageArray_NoStim_CorrAmp_norm, 3) / ImagesPerSequence;
    for SeqNumber=1:NumOfSequences
        
        FirstIndex = (ImagesPerSequence * (SeqNumber - 1)) + 1; 
        LastIndex = ImagesPerSequence * SeqNumber;

        FirstImage = ImageArray_NoStim_CorrAmp_norm(:,:, FirstIndex);
        
        for ImageIndex=FirstIndex:(LastIndex - 1)
           
           SecondImage = ImageArray_NoStim_CorrAmp_norm(:,:, (ImageIndex + 1));

           % if there are responses in both FirstImage and SecondImage,
           % then look for overlap
           if (sum(sum(FirstImage)) & sum(sum(SecondImage)))
               
               % find coordinates of region(s) in FirstImage
               FirstImage_thick = bwmorph(FirstImage, 'thicken'); 
               FirstImage_thick_props = regionprops(double(FirstImage_thick), 'PixelList');
               xList = FirstImage_thick_props(1).PixelList(:,1);
               yList = FirstImage_thick_props(1).PixelList(:,2);
           
                % Select neighboring regions from second image 
                SecondImage_select_bw = bwselect(SecondImage, xList, yList);
                SecondImage_select = SecondImage .* SecondImage_select_bw;
           else
                SecondImage_select = zeros(size(SecondImage));
           end
           
           % save new image of FirstImage + selected regions
           ImageArray_NoStim_CorrAmp_norm_2(:,:, ImageIndex) =  FirstImage + SecondImage_select;
           
           % prepare for next loop
           FirstImage = SecondImage - SecondImage_select;
           
        end
        
        
    end








