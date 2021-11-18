% Written by Einat Peled
% einatspeled@gmail.com
% 

function OneImage_OneLabel_Mask = GetLabelMask(OneImage_Labels, LabelIndex);
       
 % get pixel indices for one label
 [Vector_label_row, Vector_Label_col] = find(OneImage_Labels==LabelIndex);
 % get binary mask image with one label
 OneImage_OneLabel_Mask = bwselect(OneImage_Labels, Vector_Label_col, Vector_label_row, 4); % connectivity = 4
        