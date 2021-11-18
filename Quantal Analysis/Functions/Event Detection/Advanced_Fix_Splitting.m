function ImageArray_CorrAmp_fix = Advanced_Fix_Splitting(ImageArray_CorrAmp,...
    FramesPerSequence, PersistenceChecker, PersistenceOption, MaxPersistence, TrackingMaskMethod, MinAreaTrackingMask,DisplayOn)

    warning on all
    warning off backtrace
    warning off verbose

% PersistenceChecker=1 
% MaxPersistence=3
% TrackingMaskMethod=2;
% MinAreaTrackingMask=20;
     
    if MaxPersistence~=3
        error('Currently only works properly with MaxPersistence = 3')
    end
    clear TrackingTestStack TrackingTest TrackingMask FirstImage SecondImage FirstImage_select FirstImage_select_bw FirstImage_select_bw_2 FirstImage_select_2
    FirstIndex=1;
    ImageArray_CorrAmp_fix = zeros(size(ImageArray_CorrAmp)); 
    TrackingStack=zeros(size(ImageArray_CorrAmp));
    TrackingStack2=zeros(size(ImageArray_CorrAmp));
    FirstImage = ImageArray_CorrAmp(:,:, FirstIndex);
    TrackingMask=zeros(size(ImageArray_CorrAmp,1),size(ImageArray_CorrAmp,2));
    TrackingMask2=zeros(size(ImageArray_CorrAmp,1),size(ImageArray_CorrAmp,2));
    if DisplayOn
        fprintf('Starting Smart Event Split Fixing...')
        progressbar('Performing Smart Event Split Fixing || Image Number','Finding Persistent Events || Event')
    end
    for ImageIndex=FirstIndex:(FramesPerSequence - 1)
        if DisplayOn
            progressbar(ImageIndex/(FramesPerSequence - 1),0)
        end
        SecondImage = ImageArray_CorrAmp(:,:, (ImageIndex + 1));

        if PersistenceChecker
            %Check for persistent Event ROIs in the Tracking Stack
            TrackingTestIndices=[];
            TrackingMask2=TrackingMask;
            TrackingMask=zeros(size(ImageArray_CorrAmp,1),size(ImageArray_CorrAmp,2));
            clear TrackingTestStack
            if ImageIndex>=MaxPersistence&&ImageIndex+MaxPersistence<FramesPerSequence

                TrackingTestIndices=ImageIndex:ImageIndex+MaxPersistence;
                for i=1:length(TrackingTestIndices)
                    TrackingTestStack(:,:,i)=single(TrackingStack(:,:,TrackingTestIndices(i)));
                end

                TrackingTestStack_FixSplit_First=FixSplitting2_noProg(TrackingTestStack(:,:,1:2),2);
                TrackingTestMask_FixSplit_First=logical(TrackingTestStack_FixSplit_First(:,:,2));

                TrackingTestStack_FixSplit_Second=FixSplitting2_noProg(TrackingTestStack(:,:,2:3),2);
                TrackingTestMask_FixSplit_Second=logical(TrackingTestStack_FixSplit_Second(:,:,2));

                TrackingTestStack2=cat(3,TrackingTestMask_FixSplit_First,TrackingTestMask_FixSplit_Second);

                if MaxPersistence>2
                    TrackingTestStack_FixSplit_Third=FixSplitting2_noProg(TrackingTestStack(:,:,3:4),2);
                    TrackingTestMask_FixSplit_Third=logical(TrackingTestStack_FixSplit_Third(:,:,2));                

                    TrackingTestStack2=cat(3,TrackingTestStack2,TrackingTestMask_FixSplit_Third);
                end
                
                if TrackingMaskMethod==1
                    TrackingTest=sum(TrackingTestStack2,3);
                    TrackingMask=TrackingTest;
                    TrackingMask(TrackingMask<MaxPersistence)=0;
                    TrackingMask(TrackingMask>=MaxPersistence)=1;
                    TrackingMask=logical(TrackingMask);
                elseif TrackingMaskMethod==2
                    TrackingTestMask_FixSplit_Merge_1_Props=regionprops(logical(TrackingTestMask_FixSplit_First+TrackingTestMask_FixSplit_Second),'PixelList');
                    TrackingTestMask_FixSplit_Merge_2_Props=regionprops(logical(TrackingTestMask_FixSplit_Third+TrackingTestMask_FixSplit_Second),'PixelList');

                    DuplicateMask=zeros(size(ImageArray_CorrAmp,1),size(ImageArray_CorrAmp,2));
                    NumEvents=length(TrackingTestMask_FixSplit_Merge_1_Props)*length(TrackingTestMask_FixSplit_Merge_2_Props);
                    EventCount=0;
                    for i=1:length(TrackingTestMask_FixSplit_Merge_1_Props)
                        for j=1:length(TrackingTestMask_FixSplit_Merge_2_Props)
                            EventCount=EventCount+1;
                            if DisplayOn
                                progressbar(ImageIndex/(FramesPerSequence - 1),EventCount/NumEvents)
                            end
                            %Only check areas above a certain size
                            if size(TrackingTestMask_FixSplit_Merge_1_Props(i).PixelList,1)>=MinAreaTrackingMask&&...
                                size(TrackingTestMask_FixSplit_Merge_2_Props(j).PixelList,1)>=MinAreaTrackingMask

                                MatchCount=0;
                                for k=1:size(TrackingTestMask_FixSplit_Merge_1_Props(i).PixelList,1)
                                    for l=1:size(TrackingTestMask_FixSplit_Merge_2_Props(j).PixelList,1)
                                        if TrackingTestMask_FixSplit_Merge_1_Props(i).PixelList(k,:)==TrackingTestMask_FixSplit_Merge_2_Props(j).PixelList(l,:)
                                            MatchCount=MatchCount+1;
                                        end
                                    end
                                end
                                if MatchCount>=0.9*length(TrackingTestMask_FixSplit_Merge_2_Props(j).PixelList)
                                    for z=1:size(TrackingTestMask_FixSplit_Merge_2_Props(j).PixelList,1)
                                        DuplicateMask(TrackingTestMask_FixSplit_Merge_2_Props(j).PixelList(z,2),...
                                        TrackingTestMask_FixSplit_Merge_2_Props(j).PixelList(z,1))=1;
                                    end
                                end
                            end
                        end
                    end
                    TrackingMask=DuplicateMask;
                end
            else
                TrackingTestStack=zeros(size(ImageArray_CorrAmp,1),size(ImageArray_CorrAmp,2),MaxPersistence+1);
            end
        end
        % if there are responses in both FirstImage and SecondImage, then look for overlap
        if (sum(sum(FirstImage)) && sum(sum(SecondImage)))

            SecondImage_thick = bwmorph(SecondImage, 'thicken'); 

            % find coordinates of region(s) in SecondImage
            SecondImage_thick_props = regionprops(double(SecondImage_thick), 'PixelList');
            xList = SecondImage_thick_props(1).PixelList(:,1);
            yList = SecondImage_thick_props(1).PixelList(:,2);

            % Select neighboring regions from first image 
            FirstImage_select_bw = bwselect(FirstImage, xList, yList);

            %Remove persistent pixels from mask
            FirstImage_select_bw_2=FirstImage_select_bw.*~TrackingMask;

            FirstImage_select = FirstImage .* FirstImage_select_bw;
            FirstImage_select_2 = FirstImage .* FirstImage_select_bw_2;

        else
            FirstImage_select = zeros(size(FirstImage));
            FirstImage_select_2 = zeros(size(FirstImage));
        end

        % save new image of SecondImage + selected regions and first image-selected regions
        if PersistenceChecker
            ImageArray_CorrAmp_fix(:,:, ImageIndex) =  (FirstImage - FirstImage_select_2);
            if PersistenceOption==1
                ImageArray_CorrAmp_fix(:,:, ImageIndex + 1) = ( SecondImage + FirstImage_select_2);
            elseif PersistenceOption==2
                ImageArray_CorrAmp_fix(:,:, ImageIndex + 1) = max(cat(3,SecondImage,FirstImage_select_2),[],3);
            end
        else
            ImageArray_CorrAmp_fix(:,:, ImageIndex) =  (FirstImage - FirstImage_select);
            if PersistenceOption==1
                ImageArray_CorrAmp_fix(:,:, ImageIndex + 1) = ( SecondImage + FirstImage_select);
            elseif PersistenceOption==2
                ImageArray_CorrAmp_fix(:,:, ImageIndex + 1) = max(cat(3,SecondImage,FirstImage_select),[],3);
            end
        end

        %Update Tracking Stack 
        if PersistenceChecker
            if ImageIndex+MaxPersistence<FramesPerSequence

                TrackingStack(:,:, ImageIndex + 1)=TrackingStack(:,:, ImageIndex + 1).*~TrackingMask;

                TrackingStack(:,:, ImageIndex + 2)=TrackingStack(:,:, ImageIndex + 2).*~TrackingMask;

                if ImageIndex<MaxPersistence+1
                    NewMask2=logical(max(TrackingTestStack,[],3));
                    TrackingStack(:,:, ImageIndex + 3)=NewMask2.*~TrackingMask;
                else
                    TrackingTestStack_FixSplit=FixSplitting2_noProg(TrackingTestStack,size(TrackingTestStack,3));
                    NewMask2=logical(TrackingTestStack_FixSplit(:,:,size(TrackingTestStack,3)));
                    TrackingStack(:,:, ImageIndex + 3)=NewMask2.*~TrackingMask;
                end

                NewMask1=logical(SecondImage + FirstImage_select_2);
                TrackingStack(:,:, ImageIndex + 4)=NewMask1.*~TrackingMask;

            end
        end
        % prepare for next loop
        FirstImage = ImageArray_CorrAmp_fix(:,:, ImageIndex + 1);   

    end
    if DisplayOn
        fprintf('Finished!')
    end

end