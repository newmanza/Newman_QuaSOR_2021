function [BlockdemonDispFields,myPool]=SmoothDemonField(myPool,BlockdemonDispFields,DemonSmoothSize,DynamicSmoothing,IsDFTMoving,CircularFilter,CircularFilterFrames,...
    PixelBlockSize,TotalSmoothingArea,VerticalPixels,HorizontalPixels)
%     PixelBlockSize=10;
%     TotalSmoothingArea=Intermediate_Crop_Props.BoundingBox(3)*Intermediate_Crop_Props.BoundingBox(4);
%     VerticalPixels=Intermediate_Crop_Props.BoundingBox(2)+Padding+1:Intermediate_Crop_Props.BoundingBox(2)+Padding+Intermediate_Crop_Props.BoundingBox(4);
%     HorizontalPixels=Intermediate_Crop_Props.BoundingBox(1)+Padding+1:Intermediate_Crop_Props.BoundingBox(1)+Padding+Intermediate_Crop_Props.BoundingBox(3);
    if exist('myPool')
        try
            if isempty(myPool.IdleTimeout)
                disp('Parpool timed out! Restarting now...')
                delete(gcp('nocreate'))
                myPool=parpool;%
            else
                disp('Parpool active...')
            end
        catch
            disp('Parpool timed out! Restarting now...')
            delete(gcp('nocreate'))
            myPool=parpool;%
        end
    else
        delete(gcp('nocreate'))
        myPool=parpool;
    end
    fprintf(['Smoothing Demon Fields...'])
    clear PixelStruct
    clear TempPixelStruct
    NumFields=length(BlockdemonDispFields);
    NumPixelBlocks=ceil(length(VerticalPixels)/PixelBlockSize);
    fprintf(['Deconstructing...'])
    PixelBlock=1;
    BlockPos=0;
    for ii=1:length(VerticalPixels)
        i=VerticalPixels(ii);
        BlockPos=BlockPos+1;
        for l=1:NumFields
            TempPixelStruct(PixelBlock).i=i;
            TempPixelStruct(PixelBlock).SubBlock(BlockPos).dFields(l).dField=BlockdemonDispFields{l}.dField(i,:,:);
        end
        if rem(ii,PixelBlockSize)==0
            PixelBlock=PixelBlock+1;
            BlockPos=0;
        else
        end
    end
    PixelBlock=0;
    fprintf(['Smoothing...'])
    ppm = ParforProgMon('Smoothing Demon Fields', NumPixelBlocks, 1, 1200, 80);
    parfor PixelBlock=1:NumPixelBlocks
        for BlockPos=1:length(TempPixelStruct(PixelBlock).SubBlock)
            for j=1:length(HorizontalPixels)
                TempVector=zeros(2,NumFields);
                for l=1:NumFields
                    for k=1:2
                        TempVector(k,l)=...
                            TempPixelStruct(PixelBlock).SubBlock(BlockPos).dFields(l).dField(1,j,k);
                        if CircularFilter
                            TempVector(k,:)=cat(2,TempVector(k,:),TempVector(k,1:CircularFilterFrames));
                        end
                    end
                end
                for k=1:2
                    for z=1:length(DemonSmoothSize)    
                        if DynamicSmoothing
                            TempVector(k,:)=Zach_MovingAvgFilter_Exclusions(TempVector(k,:),DemonSmoothSize(z),IsDFTMoving);
                        else
                            TempVector(k,:)=Zach_MovingAvgFilter_Exclusions(TempVector(k,:),DemonSmoothSize(z),zeros(size(TempVector(k,:))));
                            %TempVector(k,:)=smooth(TempVector(k,:),DemonSmoothSize(z));
                        end
                    end                                        
                end
                for l=1:NumFields
                    for k=1:2
                        TempPixelStruct(PixelBlock).SubBlock(BlockPos).dFields(l).dField(1,j,k)=...
                            TempVector(k,l);
                    end
                end

            end
        end
        ppm.increment();
    end
    fprintf(['Reconstructing...'])
    PixelBlock=1;
    BlockPos=0;
    for ii=1:length(VerticalPixels)
        i=VerticalPixels(ii);
        BlockPos=BlockPos+1;
        for l=1:NumFields
            TempPixelStruct(PixelBlock).i=i;
            BlockdemonDispFields{l}.dField(i,:,:)=TempPixelStruct(PixelBlock).SubBlock(BlockPos).dFields(l).dField;
        end
        if rem(ii,PixelBlockSize)==0
            PixelBlock=PixelBlock+1;
            BlockPos=0;
        else
        end
    end
    fprintf('Finished!\n')

                    
                    
end