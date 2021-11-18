% GetProbMap: create probability map from ImageArray_Max
% By running over all pixels in AllBoutonsRegion.
% and counting how many times responses occured in each pixel


function OneImage_ProbMap = GetProbMapZN_parallel2(ImageArray_Max_Input, AllBoutonsRegion, NumOfIndices,se,StackLimits);

        
        
        

    %open the multiple core processing
    %matlabpool open
    myPool=parpool();
    %pctRunOnAll javaaddpath java 


    if ~isempty(StackLimits)
       ImageArray_Max= ImageArray_Max_Input(:,:,StackLimits);
    else
        ImageArray_Max= ImageArray_Max_Input;
    end
    if isempty(NumOfIndices)
       NumOfIndices = size(ImageArray_Max, 3);
    end
    NumOfIndices


    
    ZerosImage = zeros(size(ImageArray_Max(:,:,1)));
    OneImage_ProbMap = ZerosImage;
    StartPixelNum=1;
    TempSaveInterval=100;
    % List of pixels in AllboutonsRegion
    AllBoutonsRegion_Props = regionprops(double(AllBoutonsRegion), 'PixelList');
    AllBoutonsRegion_Pixels = AllBoutonsRegion_Props.PixelList; % list of pixel coordinates (x, y)
    NumberOfPixels = size(AllBoutonsRegion_Pixels, 1)
%     % Create a nine-pixel square around each pixel. Will count how many times a response max
%     % was in this square.
%     se = [1 1 1
%     1 1 1
%     1 1 1];
%     warning off all
    
%NOTE CHANGED TO USE A USER DEFINED square to accomodate higher resolution
%imagine with a 5x5 box

    
    % go over all pixels in AllBoutonsRegion
    
    tic
    
    %tstart=tic;
   
    %for PixelNumber=StartPixelNum:NumberOfPixels
    
    progressStepSize = 100;
  %  ppm = ParforProgMon('Pixel Number: ', NumberOfPixels, progressStepSize, 1000, 80);


    parfor PixelNumber=StartPixelNum:NumberOfPixels
        
        xcoord = AllBoutonsRegion_Pixels(PixelNumber, 1);
        ycoord = AllBoutonsRegion_Pixels(PixelNumber, 2);
            
        MaskImage = ZerosImage;
        MaskImage(ycoord, xcoord) = 1;
        MaskImage = imdilate(MaskImage, se);
    
        Vector_RFNum = CountResponses2(ImageArray_Max, MaskImage);
        Total_RFNum = length(find(Vector_RFNum)); % Will count each index as 1 or 0.
        RF_Prob = Total_RFNum / NumOfIndices;

        %OneImage_ProbMap(ycoord, xcoord) = RF_Prob;
        OneImage_ProbMap_Temp(PixelNumber).ycoord=ycoord;
        OneImage_ProbMap_Temp(PixelNumber).xcoord=xcoord;
        OneImage_ProbMap_Temp(PixelNumber).RF_Prob=RF_Prob;
%      
%         if mod(PixelNumber,progressStepSize)==0
%              ppm.increment();
%              %['PixelNumber:',num2str(PixelNumber)]
%         end
%     
                
    end % end pixels
    
    for PixelNumber=StartPixelNum:NumberOfPixels
        OneImage_ProbMap(OneImage_ProbMap_Temp(PixelNumber).ycoord, OneImage_ProbMap_Temp(PixelNumber).xcoord) = OneImage_ProbMap_Temp(PixelNumber).RF_Prob;
    end
    clear OneImage_ProbMap_Temp
    
    
    %ppm.delete()
     toc   
    
    
    %open the multiple core processing
    %matlabpool close
    delete(gcp)
    %delete temp java folder
    %rmdir(TempJavaFolder,'s');
    
end
             

