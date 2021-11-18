function ImageStats=ImageStatistics(TempImage, TempMask, PixelScaleFactor_um_px, IntensityBinSize, IntensityBinMax, ShowPlots)
    clear ImageStats
    if ShowPlots
        figure,
        subtightplot(1,2,1)
        imagesc(TempImage),axis equal tight
        subtightplot(1,2,2)
        imshow(TempMask),
    end
    TempPixels=TempImage(TempMask);
    ImageStats.NumPixels=size(TempPixels,1);
    ImageStats.PixelScaleFactor_um_px=PixelScaleFactor_um_px;
    ImageStats.PixelArea_um2=ImageStats.PixelScaleFactor_um_px^2;
    ImageStats.Area_um=ImageStats.NumPixels*ImageStats.PixelArea_um2;
    
    ImageStats.Sum=sum(TempPixels);
    ImageStats.Density_um2=ImageStats.Sum/ImageStats.Area_um;
    ImageStats.Max=max(TempPixels);
    ImageStats.Min=min(TempPixels);
    ImageStats.Median=median(TempPixels);
    ImageStats.BinSize=IntensityBinSize;
    ImageStats.MaxBin=IntensityBinMax;

    [   ImageStats.Mean,...
        ImageStats.STD,...
        ImageStats.SEM, ~]=...
        Mean_STD_SEM(TempPixels);
    
    [   ImageStats.Num_Bins,...
        ImageStats.Bin_Edges,...
        ImageStats.Bin_Labels,...
        ImageStats.Bin_Centers,...
        ImageStats.Histogram,...
        ImageStats.Normalized_Histogram,...
        ImageStats.Cumulative_Histogram,...
        ImageStats.Normalized_Cumulative_Histogram]=...
        Multi_Histogram(TempPixels,...
        [0,ImageStats.MaxBin],ImageStats.BinSize);
    
end