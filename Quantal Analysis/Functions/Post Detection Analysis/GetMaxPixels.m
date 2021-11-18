% Written by Einat Peled
% einatspeled@gmail.com
% 

% Input: OneImage, should contain one spot (one mini event)
% Output: keep only the top NumMaxPixels of OneImage

function OneImage_CorrAmp_thresh_MaxPixels = GetMaxPixels(OneImage_CorrAmp_thresh, NumMaxPixels);
% [i,j,v] = find(X) row, column, value

OneImage_Mask = zeros(size(OneImage_CorrAmp_thresh));

% get pixel indices and values
[Vector_row, Vector_col] = find(OneImage_CorrAmp_thresh > 0);
VectorLength = length(Vector_row);
for VectorIndex=1:VectorLength
    Vector_val(VectorIndex) = OneImage_CorrAmp_thresh(Vector_row(VectorIndex), Vector_col(VectorIndex));
end

% sort values
[Vector_tmp Vector_DesInd] = sort(Vector_val, 'descend');

% keep only top NumMaxPixels pixels
LastPixNum = min(NumMaxPixels, length(Vector_val));

% Get output image
for PixNum=1:LastPixNum
    Index_row = Vector_row(Vector_DesInd(PixNum));
    Index_col = Vector_col(Vector_DesInd(PixNum));

    OneImage_Mask(Index_row, Index_col) = 1;
end


OneImage_CorrAmp_thresh_MaxPixels = OneImage_CorrAmp_thresh .* OneImage_Mask;








