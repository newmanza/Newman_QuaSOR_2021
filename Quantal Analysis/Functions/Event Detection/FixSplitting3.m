
% Fix possible splitting of responses between two consecutive frames
% Version 2 - accumulate everything from one frame to the next

function ImageArray_2 = FixSplitting3(ImageArray)

    ImageArray_2 = zeros(size(ImageArray));

        FirstIndex = 1; 
        LastIndex = size(ImageArray,3);

        FirstImage = ImageArray(:,:, FirstIndex);
           %FirstImage = ImageArray(:,:, ImageIndex);     
figure, hold all;
           
        for ImageIndex=FirstIndex:(LastIndex - 1)
           
           SecondImage = ImageArray(:,:, (ImageIndex + 1));
           


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
           
           subplot(3,2,1); imagesc(FirstImage),axis equal tight;title(num2str(ImageIndex));
           subplot(3,2,2); imagesc(SecondImage),axis equal tight;title(num2str(ImageIndex+1));       
           subplot(3,2,3); imagesc(FirstImage_select),axis equal tight;
           subplot(3,2,4); imagesc(SecondImage_thick),axis equal tight;
           subplot(3,2,5); imagesc(FirstImage - FirstImage_select),axis equal tight;
           subplot(3,2,6); imagesc(SecondImage + FirstImage_select ),axis equal tight;
            set(gcf,'position',[1,564,1280,670]);pause(0.2);              
                
                
%                 SecondImage_select_bw = bwselect(SecondImage, xList, yList);
%                 SecondImage_select = SecondImage .* SecondImage_select_bw;
           else
                FirstImage_select = zeros(size(FirstImage));
                
           subplot(3,2,1); imagesc(FirstImage),axis equal tight;title(num2str(ImageIndex));
           subplot(3,2,2); imagesc(SecondImage),axis equal tight;title(num2str(ImageIndex+1));       
           subplot(3,2,3); imagesc(FirstImage_select),axis equal tight;
           subplot(3,2,4); imagesc(FirstImage_select),axis equal tight;
           subplot(3,2,5); imagesc(FirstImage_select),axis equal tight;
           subplot(3,2,6); imagesc(FirstImage_select ),axis equal tight;
            set(gcf,'position',[1,564,1280,670]);pause(0.2);   
                
                
                
           end
           
           % save new image of SecondImage + selected regions
           ImageArray_2(:,:, ImageIndex + 1) =  SecondImage + FirstImage_select;
           ImageArray_2(:,:, ImageIndex) =  FirstImage - FirstImage_select;
           



           
           % prepare for next loop
            FirstImage = SecondImage + FirstImage_select;
            
            %figure, imagesc(FirstImage), axis equal tight
            
           
        end
        
        










