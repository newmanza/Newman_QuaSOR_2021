% Written by Einat Peled
% einatspeled@gmail.com
% 

% Input: ImageArray_CorrAmp_norm: array with response images
%        ImageArray_Labels: array with each image split to response labels.
% Output: An image array that shows only the top NumMaxPixels of each
% response

% For each input image: go over individaul responses (according to labels),
% for each response create an image with top NumMaxPixels, then add up all
% top pixel images.

function ImageArray_CorrAmp_norm_InMax = GetMaxPixels_LabelsArray_NoProgressBar_Region(ImageArray_CorrAmp_norm, ImageArray_Labels, NumMaxPixels,se);

LastImageNumber = size(ImageArray_CorrAmp_norm, 3);
ImageArray_CorrAmp_norm_InMax=zeros(size(ImageArray_CorrAmp_norm));
% run over images
%progressbar('Image #','Event #')
for ImageNumber=1:LastImageNumber
    OneImage_CorrAmp_norm = ImageArray_CorrAmp_norm(:,:, ImageNumber);
    OneImage_Corramp_norm_InMax = zeros(size(OneImage_CorrAmp_norm));
    
    OneImage_Labels = ImageArray_Labels(:,:, ImageNumber);
    FirstLabelNum = min(OneImage_Labels(OneImage_Labels > 0));
    LastLabelNum = max(max(OneImage_Labels));

    % run over labels in OneImage_Labels
    for LabelIndex=FirstLabelNum:LastLabelNum     
         OneImage_Mask = zeros(size(OneImage_Labels));
       
         % get pixel indices for one label
        [Vector_label_row, Vector_Label_col] = find(OneImage_Labels==LabelIndex);
        % get binary mask image with one label
        OneImage_OneLabel_Mask = bwselect(OneImage_Labels, Vector_Label_col, Vector_label_row, 4); % connectivity = 4
        
        OneImage_OneLabel_Mask=imdilate(OneImage_OneLabel_Mask,se);
        
        % get image with one response, corresponding to current label
        
        MaskedImage=OneImage_CorrAmp_norm .* OneImage_OneLabel_Mask;
        
        MaxAmp=max(max(MaskedImage));
        
        OneImage_OneResponse = MaxAmp .* OneImage_OneLabel_Mask;
        
        % get pixel indices and values for OneResponse
        [Vector_row, Vector_col Vector_val] = find(OneImage_OneResponse > 0);
        % sort values
        [Vector_tmp Vector_DesInd] = sort(Vector_val, 'descend');
        % keep only top NumMaxPixels pixels
        % (if Max spot is smaller than NumMaxPixels - take all pixels in
        % Max, otherwise will take top NumMaxPixels pixels)
        LastPixNum = min(NumMaxPixels, length(Vector_val));
        % Get image mask
        for PixNum=1:LastPixNum
            Index_row = Vector_row(Vector_DesInd(PixNum));
            Index_col = Vector_col(Vector_DesInd(PixNum));
            OneImage_Mask(Index_row, Index_col) = 1;
        end
        
        % Output image
        OneImage_Corramp_norm_InMax = OneImage_Corramp_norm_InMax + (OneImage_CorrAmp_norm .* OneImage_Mask);       
        %progressbar(ImageNumber/LastImageNumber,LabelIndex/LastLabelNum)
    end
 
    ImageArray_CorrAmp_norm_InMax(:,:, ImageNumber) = OneImage_Corramp_norm_InMax;
end


















