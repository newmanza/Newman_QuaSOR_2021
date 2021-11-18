function [QuaSOR_Image,QuaSOR_Image_TemporalColors,myPool]=QuaSOR_Map_Maker(myPool,GPU_Accelerate,...
    QuaSOR_UpScaleFactor,QuaSOR_ImageHeight,QuaSOR_ImageWidth,...
    All_Location_Coords,QuaSOR_Gaussian_Filter_Size,QuaSOR_Gaussian_Filter_Sigma,...
    SpotNormalization,TemporalColorization,QuaSOR_Colormap,Verbose)
    
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist('myPool')
        if ~isempty(myPool)&&myPool.Connected~=0
        else
            delete(gcp('nocreate'))
            myPool=parpool;%
        end
    else
        delete(gcp('nocreate'))
        myPool=parpool;%
    end
    warning on all
    warning off backtrace
    warning off verbose
    MapCreationTimer=tic;
    DeBug=0;
    if DeBug
        warning('Debug mode on!')
        warning('Debug mode on!')
        warning('Debug mode on!')
        warning('Debug mode on!')
        warning('Debug mode on!')
        warning('Debug mode on!')
        warning('Debug mode on!')
        warning('Debug mode on!')
        
    end
    if rem(QuaSOR_Gaussian_Filter_Size,2)==0&&QuaSOR_Gaussian_Filter_Size~=0
        warning('Must used an odd numbered filter kernel!')
        warning('Must used an odd numbered filter kernel!')
        error('Must used an odd numbered filter kernel!')
    elseif QuaSOR_Gaussian_Filter_Size==0
        EventImage=zeros(11,'single');
        EventCenter=ceil(11/2);
        EventImage(EventCenter,EventCenter)=1;
    else
        EventImage=zeros(QuaSOR_Gaussian_Filter_Size,'single');
        EventCenter=ceil(QuaSOR_Gaussian_Filter_Size/2);
        EventImage(EventCenter,EventCenter)=1;
        if QuaSOR_Gaussian_Filter_Sigma>0
            EventImage=single(imgaussfilt(double(EventImage), QuaSOR_Gaussian_Filter_Sigma,'FilterSize',QuaSOR_Gaussian_Filter_Size));
        end
        if SpotNormalization
            EventImage=EventImage/max(EventImage(:));
        end
    end
    if DeBug
        EventFig=figure;
        imagesc(EventImage),axis equal tight,title('Event Image')
    end
        
    %NOTE: I am leaving this on currently permanently, technically there is
    %a small difference when using the fast map but per event the
    %differences were only on order of teh Fast Map being less by at most 1x10-7 out of 1 so I figure it is ok!
    FastMap=1;
    if FastMap
        if ~Verbose
            warning('FastMap on...')
            warning('FastMap on...')
            warning('Leaving FastMap on will loose events within 1/2 filter size from edge currently...')
            warning('I still recommend leaving it on though because it is approx. 10-100x faster!')
            warning('Forcing TemporalColorization off...')
            warning('Forcing GPU Acceleration off as well, it doesnt provide any benefit with fastmap!')
        end
        TemporalColorization=0;
        GPU_Accelerate=0;
    else
        warning('I really think you should turn on FastMap!')
        warning('I really think you should turn on FastMap!')
        warning('I really think you should turn on FastMap!')
        warning('I really think you should turn on FastMap!')
        warning('I really think you should turn on FastMap!')
        warning('I really think you should turn on FastMap!')
        warning('I really think you should turn on FastMap!')
        warning('I really think you should turn on FastMap!')
        warning('I really think you should turn on FastMap!')
        warning('I really think you should turn on FastMap!')
        warning('I really think you should turn on FastMap!')
        warning('I really think you should turn on FastMap!')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Defaults
    SpotColorIntervals=1000;
    ColorReduction=0.05;
    TotalNumPixels=QuaSOR_ImageHeight*QuaSOR_ImageWidth;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ZerosImage=zeros(QuaSOR_ImageHeight,QuaSOR_ImageWidth,'single');
    ZerosImage_Color=zeros(QuaSOR_ImageHeight,QuaSOR_ImageWidth,3,'single');
    QuaSOR_Image=ZerosImage;
    if GPU_Accelerate&&~TemporalColorization
        ZerosImage_GPU=gpuArray(ZerosImage);
        %ZerosImage_Color_GPU=gpuArray(ZerosImage_Color);
        if ~Verbose
            warning('GPU Acceleration: ENGAGED!')
            warning('GPU Acceleration: ENGAGED!')
            warning('Colorization is not ENGAGED!')
        end
        QuaSOR_Image_TemporalColors=[];
    else
        if ~Verbose
            warning('GPU Acceleration: NOT USING!')
            warning('GPU Acceleration: NOT USING!')
        end
        if TemporalColorization
            if ~Verbose
                warning('Colorization is currently ENGAGED!')
                warning('Adding colors is too much for GPU acceleration so turning off')
            end
            QuaSOR_Image_TemporalColors=ZerosImage_Color;
        else
            QuaSOR_Image_TemporalColors=[];
            if ~Verbose
                warning('Colorization is not ENGAGED!')
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(All_Location_Coords)
    
        NumEvents=size(All_Location_Coords,1);
        NumBlocks=myPool.NumWorkers;
        if GPU_Accelerate&&TotalNumPixels>1.4e7
            if ~Verbose
                warning('Reducing Number of parallel processing blocks because too many may cause GPU memory problems...')
            end
            NumBlocks=NumBlocks-1;
        end
        if NumEvents<=10*myPool.NumWorkers
            if ~Verbose
                warning('Reducing Number of parallel processing blocks because very few events...')
            end
            NumBlocks=1;
        end
        EventsPerBlock=ceil(NumEvents/NumBlocks);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~Verbose
            disp(['Processing ',num2str(NumEvents),' Events'])
            disp(['Parallel Pool has ',num2str(myPool.NumWorkers),' Workers'])
            disp(['Map maker will split the events into ',num2str(NumBlocks),' Groups with ',num2str(EventsPerBlock),' Events per Block'])
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        clear Event_Struct
        if ~Verbose
            disp('Setting Up Coordinate Groups...')
        end
        TestCount=0;
        for Block=1:NumBlocks
            if Block<NumBlocks
                Event_Struct(Block).EventIndices=[(Block-1)*EventsPerBlock+1:(Block)*EventsPerBlock];
            else
                Event_Struct(Block).EventIndices=[(Block-1)*EventsPerBlock+1:NumEvents];
            end
            Event_Struct(Block).Coords=All_Location_Coords(Event_Struct(Block).EventIndices,1:3);
            if GPU_Accelerate&&~TemporalColorization
                Event_Struct(Block).QuaSOR_Image=ZerosImage_GPU;
                %Event_Struct(Block).QuaSOR_Image_Color=ZerosImage_Color_GPU;
            else
                Event_Struct(Block).QuaSOR_Image=ZerosImage;
                if TemporalColorization
                    Event_Struct(Block).QuaSOR_Image_Color=ZerosImage_Color;
                end
            end
            Event_Struct(Block).NumEvents=size(Event_Struct(Block).Coords,1);
            TestCount=TestCount+Event_Struct(Block).NumEvents;
        end
        if ~Verbose
            fprintf('Checking that all events have been accounted for...')
        end
        if TestCount==NumEvents
            if ~Verbose
                fprintf('OK!\n')
            end
        else
            error('Missing Events!')
        end
        if ~Verbose
            disp(['Event Gaussian Filter SIZE = ',num2str(QuaSOR_Gaussian_Filter_Size),' SIGMA = ',num2str(QuaSOR_Gaussian_Filter_Sigma)])
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if GPU_Accelerate&&~TemporalColorization&&~FastMap
            if ~Verbose
                fprintf('Starting GPU Accelerated Rendering...')
            end
            warning off
            %ppm = ParforProgMon('GPU Rendering ||| Block: ', NumBlocks,1, 600, 100);
            parfor Block=1:NumBlocks
                for Event=1:Event_Struct(Block).NumEvents
                    TempImage=ZerosImage_GPU;
                    %TempImage_Color=ZerosImage_Color_GPU;
                    TempCoordinate=Event_Struct(Block).Coords(Event,:);
                    TempCoordinate1=round(TempCoordinate(1:2)*QuaSOR_UpScaleFactor);
                    if any(TempCoordinate1<1)||TempCoordinate1(1)>QuaSOR_ImageHeight||TempCoordinate1(2)>QuaSOR_ImageWidth
                    else
                        TempImage(TempCoordinate1(1),TempCoordinate1(2))=1;
                        if QuaSOR_Gaussian_Filter_Sigma~=0
                            TempImage=imgaussfilt(double(TempImage),QuaSOR_Gaussian_Filter_Sigma,...
                                'FilterSize',QuaSOR_Gaussian_Filter_Size);
                            if SpotNormalization
                                TempImage=TempImage/max(TempImage(:));
                            end
    %                         if TemporalColorization
    %                             TempImage=round(TempImage/max(TempImage(:))*SpotColorIntervals);
    %                             TempColor=QuaSOR_Colormap(TempCoordinate(3),:);
    %                             TempColorMap=[  linspace(0,TempColor(1),SpotColorIntervals)',...
    %                                             linspace(0,TempColor(2),SpotColorIntervals)',...
    %                                             linspace(0,TempColor(3),SpotColorIntervals)'];
    %                             TempImage_Color=ind2rgb(TempImage,TempColorMap);
    %                         end
                        end
                        Event_Struct(Block).QuaSOR_Image=...
                            Event_Struct(Block).QuaSOR_Image+TempImage;
    %                     if TemporalColorization
    %                         Event_Struct(Block).QuaSOR_Image_Color=...
    %                             Event_Struct(Block).QuaSOR_Image_Color+TempImage_Color;
    %                     end
                    end
                end
                %ppm.increment();
            end
            if ~Verbose
                fprintf('FINISHED!\n')
            end
            warning on
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif FastMap&&~GPU_Accelerate
            if ~Verbose
                fprintf('Starting FastMap Rendering...')
            end
            warning off
            if DeBug
                disp(['QuaSOR_ImageHeight = ',num2str(QuaSOR_ImageHeight)])
                disp(['QuaSOR_ImageWidth = ',num2str(QuaSOR_ImageWidth)])
                disp(['EventCenter = ',num2str(EventCenter)])
            end

            parfor Block=1:NumBlocks
                for Event=1:Event_Struct(Block).NumEvents
                    TempCoordinate=Event_Struct(Block).Coords(Event,:);
                    TempCoordinate1=round(TempCoordinate(1:2)*QuaSOR_UpScaleFactor);
                    if DeBug
                        disp(['Block: ',num2str(Block),' Event: ',num2str(Event)])
                        disp(num2str(TempCoordinate1))
                    end

                    if any(TempCoordinate1<1)||TempCoordinate1(1)>QuaSOR_ImageHeight||TempCoordinate1(2)>QuaSOR_ImageWidth||...
                            any(TempCoordinate1<EventCenter)||TempCoordinate1(1)>QuaSOR_ImageHeight-EventCenter||TempCoordinate1(2)>QuaSOR_ImageWidth-EventCenter
                        if DeBug
                            warning on
                            warning('Event Outside of area')
                            warning off
                        end

                    else
                        if QuaSOR_Gaussian_Filter_Sigma~=0
                            TempY=[TempCoordinate1(1)-(EventCenter-1):TempCoordinate1(1)+(EventCenter-1)];
                            TempX=[TempCoordinate1(2)-(EventCenter-1):TempCoordinate1(2)+(EventCenter-1)];
                            TempImage=Event_Struct(Block).QuaSOR_Image(TempY,TempX);
                            TempImage=TempImage+EventImage;
                            Event_Struct(Block).QuaSOR_Image(TempY,TempX)=TempImage;
                        else
                            Event_Struct(Block).QuaSOR_Image(TempCoordinate1(1),TempCoordinate1(2))=...
                                Event_Struct(Block).QuaSOR_Image(TempCoordinate1(1),TempCoordinate1(2))+1;
                        end
                    end
                end
            end
            if ~Verbose
                fprintf('FINISHED!\n')
            end
            warning on
        else
            if ~Verbose
                fprintf('Starting Standard Rendering...')
            end
            warning off
            %ppm = ParforProgMon('Standard Rendering ||| Block: ', NumBlocks,1, 600, 100);
            parfor Block=1:NumBlocks
                for Event=1:Event_Struct(Block).NumEvents
                    TempImage=ZerosImage;
                    if TemporalColorization
                        TempImage_Color=ZerosImage_Color;
                    else
                        TempImage_Color=[];
                    end
                    TempCoordinate=Event_Struct(Block).Coords(Event,:);
                    TempCoordinate1=round(TempCoordinate(1:2)*QuaSOR_UpScaleFactor);
                    if any(TempCoordinate1<1)||TempCoordinate1(1)>QuaSOR_ImageHeight||TempCoordinate1(2)>QuaSOR_ImageWidth
                    else
                        TempImage(TempCoordinate1(1),TempCoordinate1(2))=1;
                        if QuaSOR_Gaussian_Filter_Sigma~=0
                            TempImage=imgaussfilt(double(TempImage),QuaSOR_Gaussian_Filter_Sigma,...
                                'FilterSize',QuaSOR_Gaussian_Filter_Size);
                            if SpotNormalization
                                TempImage=TempImage/max(TempImage(:));
                            end
                            if TemporalColorization
                                TempImage=round(TempImage/max(TempImage(:))*round(SpotColorIntervals*ColorReduction));
                                TempColor=QuaSOR_Colormap(TempCoordinate(3),:);
                                TempColorMap=[  linspace(0,TempColor(1),SpotColorIntervals)',...
                                                linspace(0,TempColor(2),SpotColorIntervals)',...
                                                linspace(0,TempColor(3),SpotColorIntervals)'];
                                TempImage_Color=ind2rgb(TempImage,TempColorMap);
                            else
                                TempColor=[];
                                TempColorMap=[];
                                TempImage_Color=[];
                            end
                        end
                        Event_Struct(Block).QuaSOR_Image=...
                            Event_Struct(Block).QuaSOR_Image+TempImage;
                        if TemporalColorization
                            Event_Struct(Block).QuaSOR_Image_Color=...
                                Event_Struct(Block).QuaSOR_Image_Color+TempImage_Color;
                        else
                            Event_Struct(Block).QuaSOR_Image_Color=[];
                        end
                    end
                end
                %ppm.increment();
            end
            if ~Verbose
                fprintf('FINISHED!\n')
            end
            warning on
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~Verbose
            fprintf('Reconstructing Image..')
        end
        for Block=1:NumBlocks
            if GPU_Accelerate&&~TemporalColorization
                QuaSOR_Image=QuaSOR_Image+gather(Event_Struct(Block).QuaSOR_Image);
                %QuaSOR_Image_TemporalColors=QuaSOR_Image_TemporalColors+gather(Event_Struct(Block).QuaSOR_Image_Color);
            else
                QuaSOR_Image=QuaSOR_Image+Event_Struct(Block).QuaSOR_Image;
                if TemporalColorization
                    QuaSOR_Image_TemporalColors=QuaSOR_Image_TemporalColors+Event_Struct(Block).QuaSOR_Image_Color;
                end
            end
        end
        if ~Verbose
            fprintf('FINISHED!\n')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        RenderingTime=toc(MapCreationTimer);
        if ~Verbose
        fprintf(['Rendering QuaSOR Image Took: ',num2str(RenderingTime),'s\n'])
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        QuaSOR_Image=ZerosImage;
        QuaSOR_Image_TemporalColors=[];
    end
end
