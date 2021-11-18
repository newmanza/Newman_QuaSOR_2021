% Written by Einat Peled
% einatspeled@gmail.com
% 
% Get a vector of response amplitudes
% ImageArray_CorrAmp_norm_InMax: contains images with highest-value pixels at all response locations 

function Vector_RF_CorrAmpNormValues_AllNMJ_Grouped = GetRFAmpValues_Array_Grouped(ImageArray_CorrAmp_norm_InMax, ImageArray_Max, AllBoutonsRegion);

LastImageNumber = size(ImageArray_CorrAmp_norm_InMax, 3);
ResponseIndex = 1;

progressbar('ImageNumber', 'Response Number')
for ImageNumber=1:LastImageNumber
   % get labels image, only include responses in AllBoutonsRegion
    OneImage_Max =  ImageArray_Max(:,:, ImageNumber);
   [OneImage_Labels, NumOfLabels] = bwlabel(OneImage_Max, 8); % connectivity = 8 
   ResponseIndex=1;
   % Create a mask for each label, use that to get an image with the
   % corresponding response, get average response amp
   if NumOfLabels==0
       Vector_RF_CorrAmpNormValues_AllNMJ_Grouped(1, ImageNumber)=0;
       progressbar(ImageNumber/LastImageNumber, 1)
   else
       for LabelIndex=1:NumOfLabels
           progressbar(ImageNumber/LastImageNumber, LabelIndex/NumOfLabels)
           OneImage_OneLabel_Mask = GetLabelMask(OneImage_Labels, LabelIndex);
           OneImage_OneLabel_Mask = OneImage_OneLabel_Mask & AllBoutonsRegion;
           % get image with one response, corresponding to current label
           OneImage_OneResponse = OneImage_OneLabel_Mask .* ImageArray_CorrAmp_norm_InMax(:,:, ImageNumber);

           % save mean response value in output vector
           Vector_RF_CorrAmpNormValues_AllNMJ_Grouped(ResponseIndex, ImageNumber) = mean2(OneImage_OneResponse(OneImage_OneResponse > 0));
           ResponseIndex = ResponseIndex + 1;
       end
   end
end
end








