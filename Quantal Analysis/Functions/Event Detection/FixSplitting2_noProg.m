
% Fix possible splitting of responses between two consecutive frames
% Version 2 - accumulate everything from one frame to the next

function ImageArray_NoStim_CorrAmp_norm_2 = FixSplitting2_noProg(ImageArray_NoStim_CorrAmp_norm, ImagesPerSequence)

    ImageArray_NoStim_CorrAmp_norm_2 = zeros(size(ImageArray_NoStim_CorrAmp_norm));

    NumOfSequences = size(ImageArray_NoStim_CorrAmp_norm, 3) / ImagesPerSequence;
    for SeqNumber=1:NumOfSequences
        
        FirstIndex = (ImagesPerSequence * (SeqNumber - 1)) + 1; 
        LastIndex = ImagesPerSequence * SeqNumber;

        FirstImage = ImageArray_NoStim_CorrAmp_norm(:,:, FirstIndex);
        %progressbar('Fixing Split Events: Image #')
        for ImageIndex=FirstIndex:(LastIndex - 1)
           
           SecondImage = ImageArray_NoStim_CorrAmp_norm(:,:, (ImageIndex + 1));

           % if there are responses in both FirstImage and SecondImage,
           % then look for overlap
           if (sum(sum(FirstImage)) & sum(sum(SecondImage)))
               
               % find coordinates of region(s) in SecondImage
               SecondImage_thick = bwmorph(SecondImage, 'thicken'); 
               SecondImage_thick_props = regionprops(double(SecondImage_thick), 'PixelList');
               xList = SecondImage_thick_props(1).PixelList(:,1);
               yList = SecondImage_thick_props(1).PixelList(:,2);
               
               
%                FirstImage_thick = bwmorph(FirstImage, 'thicken'); 
%                FirstImage_thick_props = regionprops(double(FirstImage_thick), 'PixelList');
%                xList = FirstImage_thick_props(1).PixelList(:,1);
%                yList = FirstImage_thick_props(1).PixelList(:,2);
%            
                % Select neighboring regions from first image 
                FirstImage_select_bw = bwselect(FirstImage, xList, yList);
                FirstImage_select = FirstImage .* FirstImage_select_bw;
                
%                 SecondImage_select_bw = bwselect(SecondImage, xList, yList);
%                 SecondImage_select = SecondImage .* SecondImage_select_bw;
           else
                FirstImage_select = zeros(size(FirstImage));
           end
           
           % save new image of SecondImage + selected regions
           ImageArray_NoStim_CorrAmp_norm_2(:,:, ImageIndex + 1) =  SecondImage + FirstImage_select;
           ImageArray_NoStim_CorrAmp_norm_2(:,:, ImageIndex) =  FirstImage - FirstImage_select;
           
           % prepare for next loop
           FirstImage = SecondImage + FirstImage_select;
           %progressbar(ImageIndex/(LastIndex - 1))
           
        end
        
        
    end








