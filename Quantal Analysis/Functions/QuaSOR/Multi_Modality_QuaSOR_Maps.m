function [QuaSOR_Maps,QuaSOR_Map_Settings,PixelMax_Maps,PixelMax_Map_Settings]=...
    Multi_Modality_QuaSOR_Maps(myPool,OS,dc,SaveName,StackSaveName,SaveDir,CurrentScratchDir,FigureScratchDir,...
    QuaSOR_Map_Settings,QuaSOR_Data,QuaSOR_Parameters,QuaSOR_Event_Extraction_Settings,QuaSOR_LowRes_Map_Settings,...
    PixelMax_Map_Settings,PixelMax_Struct,...
    Image_Height,Image_Width,AllBoutonsRegion,BoutonArray,BorderLine,...
    ScaleBar,ScaleBar_Upscale,MarkerSetInfo,...
    GPU_Memory_Miniumum,GPU_Accelerate,RemoveDuplicates,...
    DisplayIntermediates,ExportImages,CleanupMapRGB,...
    IbIs_CoordinateAdjust,IbIs,BoutonMerge)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Some other less important defaults
    ScreenSize=get(0,'ScreenSize');
    %IbIs_CoordinateAdjust=-1; %Use in conjunction with UpScale_Fix_Adjust from original mapping
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    OverallTimer=tic;
    clear QuaSOR_Maps
    clear QuaSOR_LowRes_Maps
    clear PixelMax_Maps
    disp('=======================================================================')
    disp(['Quantal Analysis Map Processing on: ',StackSaveName])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if GPU_Accelerate
        warning('Trying to intialize GPU...')
        try
            GPU_Device=gpuDevice;
            GPU_Accelerate=true;
            disp(['GPU Processing using the ',GPU_Device.Name,' is ENGAGED!'])
            disp(['GPU: ',num2str(round(GPU_Device.AvailableMemory/1e9*100)/100),'/',...
                num2str(round(GPU_Device.TotalMemory/1e9*100)/100),' GB Memory | ',...
                num2str(GPU_Device.MultiprocessorCount),' Processors | ',...
                num2str(GPU_Device.MaxThreadsPerBlock),' Threads/Block'])
            if GPU_Device.TotalMemory<GPU_Memory_Miniumum
                warning('Total GPU memory may be too small so turning off GPU Acceleration!')
                GPU_Accelerate=false;
            end
        catch
            warning('NO GPU WITH CUDA AVAILABlE!!')
            GPU_Device=[];
            GPU_Accelerate=false;
        end
    end
    if exist('myPool')
        if ~isempty(myPool)&&myPool.Connected~=0
            disp('Parpool active...')
        else
            delete(gcp('nocreate'))
            myPool=parpool;%
        end
    else
        delete(gcp('nocreate'))
        myPool=parpool;%
    end
    close all
    warning on all
    warning off backtrace
    warning off verbose
    if ~exist([FigureScratchDir,dc,'Filters'])
        mkdir([FigureScratchDir,dc,'Filters'])
    end
    if ~exist([FigureScratchDir,dc,'AutoContMaps'])
        mkdir([FigureScratchDir,dc,'AutoContMaps'])
    end
    if ~exist([FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp'])
        mkdir([FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp'])
    end
    if ~exist([FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'QuaSOR'])
        mkdir([FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'QuaSOR'])
    end
    if ~exist([FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'PixelMax'])
        mkdir([FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'PixelMax'])
    end
    if ~exist([FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'QuaSOR_LowRes'])
        mkdir([FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'QuaSOR_LowRes'])
    end
    if ~exist([FigureScratchDir,dc,'AutoContMaps',dc,'ModOver'])
        mkdir([FigureScratchDir,dc,'AutoContMaps',dc,'ModOver'])
    end
    if isfield(QuaSOR_Data,'Modality')
        for Mod=1:length(QuaSOR_Data.Modality)
            if ~exist([FigureScratchDir,dc,'AutoContMaps',dc,QuaSOR_Data.Modality(Mod).Label,dc,'QuaSOR'])
                mkdir([FigureScratchDir,dc,'AutoContMaps',dc,QuaSOR_Data.Modality(Mod).Label,dc,'QuaSOR'])
            end
        end
        for Mod=1:length(QuaSOR_Data.Modality)
            if ~exist([FigureScratchDir,dc,'AutoContMaps',dc,QuaSOR_Data.Modality(Mod).Label,dc,'PixelMax'])
                mkdir([FigureScratchDir,dc,'AutoContMaps',dc,QuaSOR_Data.Modality(Mod).Label,dc,'PixelMax'])
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('======================================')
    disp('Fixing Bouton Border Lines...')
    if IbIs
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Remaking PixelMax Borders...')
        ZerosImage=zeros(size(AllBoutonsRegion));
        ImageWidth=size(ZerosImage,2);
        ImageHeight=size(ZerosImage,1);
        for BoutonCount=1:length(BoutonMerge.BoutonArray)
            PixelMax_Map_Settings.BoutonArray(BoutonCount).PixelMax_Bouton_Mask_BorderLine=BoutonMerge.BoutonArray(BoutonCount).BorderLine;
            QuaSOR_LowRes_Map_Settings.BoutonArray(BoutonCount).QuaSOR_LowRes_Bouton_Mask_BorderLine=BoutonMerge.BoutonArray(BoutonCount).BorderLine;
        end
        figure,
        imshow(AllBoutonsRegion,[])
        hold on      
        for BoutonCount=1:length(BoutonMerge.BoutonArray)
            for j=1:length(PixelMax_Map_Settings.BoutonArray(BoutonCount).PixelMax_Bouton_Mask_BorderLine)
                plot(PixelMax_Map_Settings.BoutonArray(BoutonCount).PixelMax_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    PixelMax_Map_Settings.BoutonArray(BoutonCount).PixelMax_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                    '-','color',BoutonMerge.BoutonArray(BoutonCount).Color,'linewidth',3)
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Remaking QuaSOR Borders...')
        QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion=strel('disk',QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegionSize);
        QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion2=strel('disk',QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegionSize2);
        QuaSOR_Map_Settings.QuaSOR_HighResBoutonErodeRegion=strel('disk',QuaSOR_Map_Settings.QuaSOR_HighResBoutonErodeRegionSize);
        disp('Fixing High Res QuaSOR Bouton Borders...')
        disp('Upscaling Bouton Borders...')
        AllBoutonsRegion_Upscale=imresize(AllBoutonsRegion,QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod);
        QuaSOR_Map_Settings.AllBoutonsRegion_Upscale=AllBoutonsRegion_Upscale;
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask=imresize(AllBoutonsRegion,QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod);
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask<0)=0;
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask>0)=1;
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask=logical(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask);
        disp('Dilating...')
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask=imdilate(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion);
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask=imdilate(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion2);
        disp('Eroding...')
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask=imerode(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.QuaSOR_HighResBoutonErodeRegion);
        for BoutonCount=1:length(BoutonMerge.BoutonArray)
            BoutonMerge.BoutonArray(BoutonCount).AllBoutonsRegion_Upscale=imresize(BoutonMerge.BoutonArray(BoutonCount).AllBoutonsRegion,QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod);
            QuaSOR_Map_Settings.BoutonArray(BoutonCount).AllBoutonsRegion_Upscale=BoutonMerge.BoutonArray(BoutonCount).AllBoutonsRegion_Upscale;
            QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask=imresize(BoutonMerge.BoutonArray(BoutonCount).AllBoutonsRegion,QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod);
            QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask<0)=0;
            QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask>0)=1;
            QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask=logical(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask);
            disp('Dilating...')
            QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask=imdilate(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion);
            QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask=imdilate(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion2);
            disp('Eroding...')
            QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask=imerode(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.QuaSOR_HighResBoutonErodeRegion);
            QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine=[];
            [B,L] = bwboundaries(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask,'noholes');
            count=0;
            LineCount=1;
            for j=1:length(B)
                for k = 1:length(B{j})
                    if B{j}(k,1)~=1&&B{j}(k,2)~=1&&B{j}(k,1)~=size(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask,1)&&B{j}(k,2)~=size(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask,2)
                        count=count+1;
                        QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{LineCount}.BorderLine(count,:) = B{j}(k,:);
                    else
                        if count==0
                        else
                            LineCount=LineCount+1;
                            count=0;
                        end
                    end
                end
                if count==0
                else
                    LineCount=LineCount+1;
                    count=0;
                end
            end
        end
        warning off
        figure, 
        imshow(uint8(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask)+uint8(imresize(AllBoutonsRegion,QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod)),[])
        hold on;         
        for BoutonCount=1:length(BoutonMerge.BoutonArray)
            for j=1:length(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine)
                plot(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                    QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                    '-','color',BoutonMerge.BoutonArray(BoutonCount).Color,'linewidth',3)

            end
        end
        warning on
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Remaking PixelMax Borders...')
        ZerosImage=zeros(size(AllBoutonsRegion));
        ImageWidth=size(ZerosImage,2);
        ImageHeight=size(ZerosImage,1);
        PixelMax_Map_Settings.PixelMax_Bouton_Mask_BorderLine=BorderLine;
        QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Bouton_Mask_BorderLine=BorderLine;
        figure, 
        imshow(AllBoutonsRegion,[])
        hold on;         
        for j=1:length(PixelMax_Map_Settings.PixelMax_Bouton_Mask_BorderLine)
            plot(PixelMax_Map_Settings.PixelMax_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                PixelMax_Map_Settings.PixelMax_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color','r','linewidth',1)
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        disp('Remaking QuaSOR Borders...')
        QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion=strel('disk',QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegionSize);
        QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion2=strel('disk',QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegionSize2);
        QuaSOR_Map_Settings.QuaSOR_HighResBoutonErodeRegion=strel('disk',QuaSOR_Map_Settings.QuaSOR_HighResBoutonErodeRegionSize);
        disp('Fixing High Res QuaSOR Bouton Borders...')
        disp('Upscaling Bouton Borders...')
        AllBoutonsRegion_Upscale=imresize(AllBoutonsRegion,QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod);
        QuaSOR_Map_Settings.AllBoutonsRegion_Upscale=AllBoutonsRegion_Upscale;
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask=imresize(AllBoutonsRegion,QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod);
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask<0)=0;
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask>0)=1;
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask=logical(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask);
        disp('Dilating...')
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask=imdilate(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion);
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask=imdilate(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.QuaSOR_HighResBoutonDilateRegion2);
        disp('Eroding...')
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask=imerode(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.QuaSOR_HighResBoutonErodeRegion);
        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine=[];
        [B,L] = bwboundaries(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,'noholes');
        count=0;
        LineCount=1;
        for j=1:length(B)
            for k = 1:length(B{j})
                if B{j}(k,1)~=1&&B{j}(k,2)~=1&&B{j}(k,1)~=size(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,1)&&B{j}(k,2)~=size(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,2)
                    count=count+1;
                    QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{LineCount}.BorderLine(count,:) = B{j}(k,:);
                else
                    if count==0
                    else
                        LineCount=LineCount+1;
                        count=0;
                    end
                end
            end
            if count==0
            else
                LineCount=LineCount+1;
                count=0;
            end
        end
        warning off
        figure, 
        imshow(uint8(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask)+uint8(imresize(AllBoutonsRegion,QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod)),[])
        hold on;         
        for j=1:length(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine)
            plot(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),'-','color','r','linewidth',3)
        end
        warning on
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    if ~isfield(QuaSOR_Data,'All_Max_DeltaFF0')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
        run('Multi_Modality_QuaSOR_Event_Sorting.m')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
        FileSuffix=['_QuaSOR_Data.mat'];
        fprintf(['Saving... ',StackSaveName,FileSuffix,' to CurrentScratchDir...']);
        if exist([CurrentScratchDir,dc,StackSaveName,FileSuffix])
            save([CurrentScratchDir,dc,StackSaveName,FileSuffix],'QuaSOR_Data','-append')
        else
            save([CurrentScratchDir,dc,StackSaveName,FileSuffix],'QuaSOR_Data')
        end
        fprintf('Finished!\n')
        fprintf(['Copying: ',StackSaveName,FileSuffix,' to SaveDir...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
        fprintf('Finished!\n')
        if ~CopyStatus
            error('Problem Copying Data!')
        else
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    PixelMax_Map_Settings.PixelMax_Upscale_Mask=logical(imresize(AllBoutonsRegion,...
                QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod));
    PixelMax_Map_Settings.MaskDiff=single(PixelMax_Map_Settings.PixelMax_Upscale_Mask)+single(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask);
    PixelMax_Map_Settings.MaskDiff(PixelMax_Map_Settings.MaskDiff>1)=0;
    PixelMax_Map_Settings.MaskDiff(PixelMax_Map_Settings.MaskDiff==1)=1;
    PixelMax_Map_Settings.MaskDiff=logical(PixelMax_Map_Settings.MaskDiff);    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    disp('=======================================================================')
    disp('PixelMax Map Processing...')
    fprintf([num2str(size(PixelMax_Struct.All_Location_Coords_byOverallFrame,1)),' PixelMax Event Localizations to Render\n'])
    disp('=====================================================================')
    disp('=====================================================================')
    disp('=====================================================================')
    disp('=====================================================================')
    if size(PixelMax_Struct.All_Location_Coords_byOverallFrame,1)>1
        PixelMax_NumFrames=max(PixelMax_Struct.All_Location_Coords_byOverallFrame(:,3));
    else
        PixelMax_NumFrames=0;
    end
    fprintf(['From ',num2str(PixelMax_NumFrames),' Timepoints\n'])
    fprintf('Calculating PixelMax Maps Sizes...\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PixelMax_Maps.PixelMax_ImageHeight=round(Image_Height*PixelMax_Map_Settings.PixelMax_UpScaleFactor);
    PixelMax_Maps.PixelMax_ImageWidth=round(Image_Width*PixelMax_Map_Settings.PixelMax_UpScaleFactor);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['PixelMax Image ',num2str(PixelMax_Map_Settings.PixelMax_UpScaleFactor),'X Upscaling Dimensions = ',...
        num2str(PixelMax_Maps.PixelMax_ImageHeight),'(H) X ',num2str(PixelMax_Maps.PixelMax_ImageWidth),'(W)'])
    PixelMax_ZerosImage=zeros(PixelMax_Maps.PixelMax_ImageHeight,PixelMax_Maps.PixelMax_ImageWidth);
    PixelMax_ZerosImage_Color=zeros(PixelMax_Maps.PixelMax_ImageHeight,PixelMax_Maps.PixelMax_ImageWidth,3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Colormap for color projection
    R = linspace(0,1,PixelMax_NumFrames);
    B = linspace(1,0,PixelMax_NumFrames);
    G = zeros(size(R));
    PixelMax_Maps.PixelMax_Temporal_Colormap=( [R(:), G(:), B(:)] );
    clear R B G
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Colormap for versus
    PixelMax_Colormap=makeColorMap([0 0 0],ColorDefinitions(PixelMax_Map_Settings.PixelMax_Overlay_Color),2^16);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Calculating PixelMax Event Filtering Parameters...\n')
    if isempty(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes)
        PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes=zeros(size(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas));
        for z=1:length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas)
            if PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z)~=0
                PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z)=...
                    2*ceil(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z)*2)+PixelMax_Map_Settings.PixelMax_Gaussian_Filter_SizeBuffer;
                if rem(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z),2)==0
                    PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z)=PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z)+1;
                end
            end
        end
    end
    for z=1:length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas)
        disp(['Event Gaussian Filter SIZE = ',num2str(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z)),...
            ' SIGMA = ',num2str(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z))])
        PixelMax_Maps.HighRes_Maps(z).GaussianParticleSize=PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z);
        PixelMax_Maps.HighRes_Maps(z).GaussianParticleSigma=PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z);
        TestImage=zeros(max(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes));
        TestImage(ceil(max(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes)/2),ceil(max(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes)/2))=1;
        if PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z)~=0
            TestImage=imgaussfilt(double(TestImage), PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z),'FilterSize',PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z));
        end
        PixelMax_Maps.HighRes_Maps(z).GaussianParticle_Image=TestImage;        
        PixelMax_Maps.HighRes_Maps(z).PixelMax_Image=double(PixelMax_ZerosImage);
        if PixelMax_Map_Settings.PixelMax_TemporalColorizations(z)
            PixelMax_Maps.HighRes_Maps(z).PixelMax_Image_TemporalColors=double(PixelMax_ZerosImage_Color);
        else
            PixelMax_Maps.HighRes_Maps(z).PixelMax_Image_TemporalColors=[];
        end
        if isfield(QuaSOR_Data,'Modality')
            for Mod=1:length(QuaSOR_Data.Modality)
                PixelMax_Maps.Modality(Mod).Label=QuaSOR_Data.Modality(Mod).Label;
                PixelMax_Maps.Modality(Mod).Color=QuaSOR_Map_Settings.Modality_Colors{Mod};
                PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image=double(PixelMax_ZerosImage);
                if PixelMax_Map_Settings.PixelMax_TemporalColorizations(z)
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image_TemporalColors=double(PixelMax_ZerosImage_Color);
                else
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image_TemporalColors=[];
                end
            end
        end
    end
    for z=1:length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas)
        PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes_nm(z)=PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z)*ScaleBar.ScaleFactor*1000;
        PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas_nm(z)=PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z)*ScaleBar.ScaleFactor*1000;
    end
    figure('name','PixelMax Filters')
    for z=1:length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas)
        subplot(3,3,z)
        imagesc(PixelMax_Maps.HighRes_Maps(z).GaussianParticle_Image)
        SigLabel=[num2str(round(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas_nm(z)*10)/10)];
        if ~any(strfind(SigLabel,'.'))
            SigLabel=[SigLabel,'.0'];
        end
        TempTitle={['SIZE = ',num2str(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z)),'px SIGMA = ',num2str(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z)),' px'];['SIGMA = ',SigLabel,' nm']};
        axis equal tight
        title(TempTitle)
    end
    set(gcf,'position',[0,100,800,700])
    Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'Filters',dc,'QuaSOR Filters'],3)
    pause(1)
    close all
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('======================================')
    fprintf('Making PixelMax Maps...\n')
    if size(PixelMax_Struct.All_Location_Coords_byOverallFrame,1)>1
        for z=1:length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas)
            disp('======================================')
            disp(['Making PixelMax Map #',num2str(z),' for Gaussian Filter SIZE = ',num2str(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z)),...
                ' SIGMA = ',num2str(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z))])
            Repeats=0;
            if GPU_Accelerate
                try
                    [PixelMax_Maps.HighRes_Maps(z).PixelMax_Image,PixelMax_Maps.HighRes_Maps(z).PixelMax_Image_TemporalColors,myPool]=...
                        QuaSOR_Map_Maker(myPool,GPU_Accelerate,PixelMax_Map_Settings.PixelMax_UpScaleFactor,PixelMax_Maps.PixelMax_ImageHeight,PixelMax_Maps.PixelMax_ImageWidth,...
                        PixelMax_Struct.All_Location_Coords_byOverallFrame,PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z),PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z),...
                        QuaSOR_Map_Settings.SpotNormalization,PixelMax_Map_Settings.PixelMax_TemporalColorizations(z),PixelMax_Maps.PixelMax_Temporal_Colormap,0);
                catch
                    warning('GPU Accelerated QuaSOR_Map_Maker Crashed, Sometimes this can be resolved with a restart so trying again in 60s')
                    pause(60)
                    try
                        [PixelMax_Maps.HighRes_Maps(z).PixelMax_Image,PixelMax_Maps.HighRes_Maps(z).PixelMax_Image_TemporalColors,myPool]=...
                            QuaSOR_Map_Maker(myPool,GPU_Accelerate,PixelMax_Map_Settings.PixelMax_UpScaleFactor,PixelMax_Maps.PixelMax_ImageHeight,PixelMax_Maps.PixelMax_ImageWidth,...
                            PixelMax_Struct.All_Location_Coords_byOverallFrame,PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z),PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z),...
                            QuaSOR_Map_Settings.SpotNormalization,PixelMax_Map_Settings.PixelMax_TemporalColorizations(z),PixelMax_Maps.PixelMax_Temporal_Colormap,0);
                    catch
                        warning('GPU Accelerated QuaSOR_Map_Maker Crashed Again Trying ONE More Time Without GPU')
                        try
                            [PixelMax_Maps.HighRes_Maps(z).PixelMax_Image,PixelMax_Maps.HighRes_Maps(z).PixelMax_Image_TemporalColors,myPool]=...
                                QuaSOR_Map_Maker(myPool,0,PixelMax_Map_Settings.PixelMax_UpScaleFactor,PixelMax_Maps.PixelMax_ImageHeight,PixelMax_Maps.PixelMax_ImageWidth,...
                                PixelMax_Struct.All_Location_Coords_byOverallFrame,PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Size,PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigma,...
                                QuaSOR_Map_Settings.SpotNormalization,PixelMax_Maps.PixelMax_TemporalColorization,PixelMax_Maps.PixelMax_Temporal_Colormap,0);
                        catch
                            error('I give up! Exiting....')
                        end
                    end
                end
            else
                [PixelMax_Maps.HighRes_Maps(z).PixelMax_Image,PixelMax_Maps.HighRes_Maps(z).PixelMax_Image_TemporalColors,myPool]=...
                    QuaSOR_Map_Maker(myPool,GPU_Accelerate,PixelMax_Map_Settings.PixelMax_UpScaleFactor,PixelMax_Maps.PixelMax_ImageHeight,PixelMax_Maps.PixelMax_ImageWidth,...
                    PixelMax_Struct.All_Location_Coords_byOverallFrame,PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z),PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z),...
                    QuaSOR_Map_Settings.SpotNormalization,PixelMax_Map_Settings.PixelMax_TemporalColorizations(z),PixelMax_Maps.PixelMax_Temporal_Colormap,0);
            end
            if GPU_Accelerate
                try
                    warning('Resetting GPU...')
                    GPU_Device=gpuDevice;
                    GPU_Accelerate=true;
                    disp(['GPU Processing using the ',GPU_Device.Name,' is ENGAGED!'])
                    disp(['GPU: ',num2str(round(GPU_Device.AvailableMemory/1e9*100)/100),'/',...
                        num2str(round(GPU_Device.TotalMemory/1e9*100)/100),' GB Memory | ',...
                        num2str(GPU_Device.MultiprocessorCount),' Processors | ',...
                        num2str(GPU_Device.MaxThreadsPerBlock),' Threads/Block'])
                        if GPU_Device.TotalMemory<GPU_Memory_Miniumum
                            warning('Total GPU memory may be too small so turning off GPU Acceleration!')
                            GPU_Accelerate=false;
                        end

                catch
                    warning('NO GPU WITH CUDA AVAILABlE!!')
                    GPU_Device=[];
                    GPU_Accelerate=false;
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isfield(QuaSOR_Data,'Modality')
                for Mod=1:length(QuaSOR_Data.Modality)
                    disp('======================================')
                    disp(['Making ',PixelMax_Maps.Modality(Mod).Label,' PixelMax Map #',num2str(z),' for Gaussian Filter SIZE = ',num2str(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z)),...
                        ' SIGMA = ',num2str(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z))])
                    Repeats=0;
                    if GPU_Accelerate
                        try
                            [PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image,PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image_TemporalColors,myPool]=...
                                QuaSOR_Map_Maker(myPool,GPU_Accelerate,PixelMax_Map_Settings.PixelMax_UpScaleFactor,PixelMax_Maps.PixelMax_ImageHeight,PixelMax_Maps.PixelMax_ImageWidth,...
                                PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame,PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z),PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z),...
                                QuaSOR_Map_Settings.SpotNormalization,PixelMax_Map_Settings.PixelMax_TemporalColorizations(z),PixelMax_Maps.PixelMax_Temporal_Colormap,0);
                        catch
                            warning('GPU Accelerated QuaSOR_Map_Maker Crashed, Sometimes this can be resolved with a restart so trying again in 60s')
                            pause(60)
                            try
                                [PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image,PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image_TemporalColors,myPool]=...
                                    QuaSOR_Map_Maker(myPool,GPU_Accelerate,PixelMax_Map_Settings.PixelMax_UpScaleFactor,PixelMax_Maps.PixelMax_ImageHeight,PixelMax_Maps.PixelMax_ImageWidth,...
                                    PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame,PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z),PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z),...
                                    QuaSOR_Map_Settings.SpotNormalization,PixelMax_Map_Settings.PixelMax_TemporalColorizations(z),PixelMax_Maps.PixelMax_Temporal_Colormap,0);
                            catch
                                warning('GPU Accelerated QuaSOR_Map_Maker Crashed Again Trying ONE More Time Without GPU')
                                try
                                    [PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image,PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image_TemporalColors,myPool]=...
                                        QuaSOR_Map_Maker(myPool,0,PixelMax_Map_Settings.PixelMax_UpScaleFactor,PixelMax_Maps.PixelMax_ImageHeight,PixelMax_Maps.PixelMax_ImageWidth,...
                                        PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame,PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Size,PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigma,...
                                        QuaSOR_Map_Settings.SpotNormalization,PixelMax_Maps.PixelMax_TemporalColorization,PixelMax_Maps.PixelMax_Temporal_Colormap,0);
                                catch
                                    error('I give up! Exiting....')
                                end
                            end
                        end
                    else
                        [PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image,PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image_TemporalColors,myPool]=...
                            QuaSOR_Map_Maker(myPool,GPU_Accelerate,PixelMax_Map_Settings.PixelMax_UpScaleFactor,PixelMax_Maps.PixelMax_ImageHeight,PixelMax_Maps.PixelMax_ImageWidth,...
                            PixelMax_Struct.Modality(Mod).All_Location_Coords_byOverallFrame,PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z),PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z),...
                            QuaSOR_Map_Settings.SpotNormalization,PixelMax_Map_Settings.PixelMax_TemporalColorizations(z),PixelMax_Maps.PixelMax_Temporal_Colormap,0);
                    end
                    if GPU_Accelerate
                        try
                            warning('Resetting GPU...')
                            GPU_Device=gpuDevice;
                            GPU_Accelerate=true;
                            disp(['GPU Processing using the ',GPU_Device.Name,' is ENGAGED!'])
                            disp(['GPU: ',num2str(round(GPU_Device.AvailableMemory/1e9*100)/100),'/',...
                                num2str(round(GPU_Device.TotalMemory/1e9*100)/100),' GB Memory | ',...
                                num2str(GPU_Device.MultiprocessorCount),' Processors | ',...
                                num2str(GPU_Device.MaxThreadsPerBlock),' Threads/Block'])
                                if GPU_Device.TotalMemory<GPU_Memory_Miniumum
                                    warning('Total GPU memory may be too small so turning off GPU Acceleration!')
                                    GPU_Accelerate=false;
                                end

                        catch
                            warning('NO GPU WITH CUDA AVAILABlE!!')
                            GPU_Device=[];
                            GPU_Accelerate=false;
                        end
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    else
        warning on
        warning('No events to render!')
        warning('No events to render!')
        warning('No events to render!')
        warning('No events to render!')
        warning('No events to render!')
        for z=1:length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas)
            PixelMax_Maps.HighRes_Maps(z).PixelMax_Image=PixelMax_ZerosImage;
            PixelMax_Maps.HighRes_Maps(z).PixelMax_Image_TemporalColors=[];
            if isfield(PixelMax_Struct,'Modality')
                for Mod=1:length(PixelMax_Struct.Modality)
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image=PixelMax_ZerosImage;
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image_TemporalColors=[];
                end
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    disp('======================================')
    fprintf('Adjusting PixelMax Contrast and Colors...')
    close all
    progressbar('Filter','Contrast')
    for z=1:length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas)
        for x=1:length(PixelMax_Map_Settings.ContrastEnhancements)
            progressbar(z/length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas),x/length(PixelMax_Map_Settings.ContrastEnhancements))
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Map_Settings.PixelMax_Color_Scalar=PixelMax_Map_Settings.PixelMax_Color_Scalar;
            PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement=PixelMax_Map_Settings.ContrastEnhancements(x);
            PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                (ceil(max(PixelMax_Maps.HighRes_Maps(z).PixelMax_Image(:))));
            PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                ceil(PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*...
                PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [~,PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap,~]=...
                Adjust_Contrast_and_Color(PixelMax_Maps.HighRes_Maps(z).PixelMax_Image,...
                0,PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont,QuaSOR_Map_Settings.ExportColorMap,...
                PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Map_Settings.PixelMax_Color_Scalar);
            PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap=...
                ColorMasking(PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap,...
                ~AllBoutonsRegion,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
            PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap=...
                single(PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [~,PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Color,~]=...
                Adjust_Contrast_and_Color(PixelMax_Maps.HighRes_Maps(z).PixelMax_Image,...
                0,PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont,...
                PixelMax_Map_Settings.PixelMax_Overlay_Color,...
                PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Map_Settings.PixelMax_Color_Scalar);
            PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Color=...
                ColorMasking(PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Color,...
                ~AllBoutonsRegion,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
            PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Color=...
                single(PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Color);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end 
    end
    fprintf('FINISHED!\n');
    if isfield(PixelMax_Struct,'Modality')
        for Mod=1:length(PixelMax_Struct.Modality)
            disp('======================================')
                PixelMax_Maps.Modality(Mod).Label=QuaSOR_Parameters.Modality(Mod).Label;
                PixelMax_Maps.Modality(Mod).Color=QuaSOR_Map_Settings.Modality_Colors{Mod};
            fprintf(['Adjusting PixelMax Contrast and Colors for ',PixelMax_Maps.Modality(Mod).Label,'...'])
            close all
            progressbar('Filter','Contrast')
            for z=1:length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas)
                for x=1:length(PixelMax_Map_Settings.ContrastEnhancements)
                    progressbar(z/length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas),x/length(PixelMax_Map_Settings.ContrastEnhancements))
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Map_Settings.PixelMax_Color_Scalar=PixelMax_Map_Settings.PixelMax_Color_Scalar;
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement=PixelMax_Map_Settings.ContrastEnhancements(x);
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                        (ceil(max(PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image(:))));
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                        ceil(PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*...
                        PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [~,PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap,~]=...
                        Adjust_Contrast_and_Color(PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image,...
                        0,PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont,QuaSOR_Map_Settings.ExportColorMap,...
                        PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Map_Settings.PixelMax_Color_Scalar);
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap=...
                        ColorMasking(PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap,...
                        ~AllBoutonsRegion,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap=...
                        single(PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [~,PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Color,~]=...
                        Adjust_Contrast_and_Color(PixelMax_Maps.Modality(Mod).HighRes_Maps(z).PixelMax_Image,...
                        0,PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont,...
                        PixelMax_Maps.Modality(Mod).Color,...
                        PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Map_Settings.PixelMax_Color_Scalar);
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Color=...
                        ColorMasking(PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Color,...
                        ~AllBoutonsRegion,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Color=...
                        single(PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Color);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end 
            end
            fprintf('FINISHED!\n');
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Upscale_Mask=logical(imresize(AllBoutonsRegion,...
                QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod));
    QuaSOR_LowRes_Map_Settings.MaskDiff=single(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Upscale_Mask)+single(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask);
    QuaSOR_LowRes_Map_Settings.MaskDiff(QuaSOR_LowRes_Map_Settings.MaskDiff>1)=0;
    QuaSOR_LowRes_Map_Settings.MaskDiff(QuaSOR_LowRes_Map_Settings.MaskDiff==1)=1;
    QuaSOR_LowRes_Map_Settings.MaskDiff=logical(QuaSOR_LowRes_Map_Settings.MaskDiff);    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    disp('=======================================================================')
    disp('QuaSOR_LowRes Map Processing...')
    fprintf([num2str(size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)),' QuaSOR_LowRes Event Localizations to Render\n'])
    disp('=====================================================================')
    disp('=====================================================================')
    disp('=====================================================================')
    disp('=====================================================================')
    if size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1
        QuaSOR_LowRes_NumFrames=max(QuaSOR_Data.All_Location_Coords_byOverallFrame(:,3));
    else
        QuaSOR_LowRes_NumFrames=0;
    end
    fprintf(['From ',num2str(QuaSOR_LowRes_NumFrames),' Timepoints\n'])
    fprintf('Calculating QuaSOR_LowRes Maps Sizes...\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageHeight=round(Image_Height*QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_UpScaleFactor);
    QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageWidth=round(Image_Width*QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_UpScaleFactor);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['QuaSOR_LowRes Image ',num2str(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_UpScaleFactor),'X Upscaling Dimensions = ',...
        num2str(QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageHeight),'(H) X ',num2str(QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageWidth),'(W)'])
    QuaSOR_LowRes_ZerosImage=zeros(QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageHeight,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageWidth);
    QuaSOR_LowRes_ZerosImage_Color=zeros(QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageHeight,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageWidth,3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Colormap for color projection
    R = linspace(0,1,QuaSOR_LowRes_NumFrames);
    B = linspace(1,0,QuaSOR_LowRes_NumFrames);
    G = zeros(size(R));
    QuaSOR_LowRes_Maps.QuaSOR_LowRes_Temporal_Colormap=( [R(:), G(:), B(:)] );
    clear R B G
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Colormap for versus
    QuaSOR_LowRes_Colormap=makeColorMap([0 0 0],ColorDefinitions(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Overlay_Color),2^16);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Calculating QuaSOR_LowRes Event Filtering Parameters...\n')
    if isempty(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes)
        QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes=zeros(size(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas));
        for z=1:length(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas)
            if QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z)~=0
                QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z)=...
                    2*ceil(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z)*2)+QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_SizeBuffer;
                if rem(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z),2)==0
                    QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z)=QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z)+1;
                end
            end
        end
    end
    for z=1:length(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas)
        disp(['Event Gaussian Filter SIZE = ',num2str(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z)),...
            ' SIGMA = ',num2str(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z))])
        QuaSOR_LowRes_Maps.HighRes_Maps(z).GaussianParticleSize=QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z);
        QuaSOR_LowRes_Maps.HighRes_Maps(z).GaussianParticleSigma=QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z);
        TestImage=zeros(max(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes));
        TestImage(ceil(max(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes)/2),ceil(max(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes)/2))=1;
        if QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z)~=0
            TestImage=imgaussfilt(double(TestImage), QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z),'FilterSize',QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z));
        end
        QuaSOR_LowRes_Maps.HighRes_Maps(z).GaussianParticle_Image=TestImage;        
        QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image=double(QuaSOR_LowRes_ZerosImage);
        if QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_TemporalColorizations(z)
            QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors=double(QuaSOR_LowRes_ZerosImage_Color);
        else
            QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors=[];
        end
        if isfield(QuaSOR_Data,'Modality')
            for Mod=1:length(QuaSOR_Data.Modality)
                QuaSOR_LowRes_Maps.Modality(Mod).Label=QuaSOR_Data.Modality(Mod).Label;
                QuaSOR_LowRes_Maps.Modality(Mod).Color=QuaSOR_Map_Settings.Modality_Colors{Mod};
                QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image=double(QuaSOR_LowRes_ZerosImage);
                if QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_TemporalColorizations(z)
                    QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors=double(QuaSOR_LowRes_ZerosImage_Color);
                else
                    QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors=[];
                end
            end
        end
    end
    for z=1:length(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas)
        QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes_nm(z)=QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z)*ScaleBar.ScaleFactor*1000;
        QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas_nm(z)=QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z)*ScaleBar.ScaleFactor*1000;
    end
    figure('name','QuaSOR_LowRes Filters')
    for z=1:length(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas)
        subplot(3,3,z)
        imagesc(QuaSOR_LowRes_Maps.HighRes_Maps(z).GaussianParticle_Image)
        SigLabel=[num2str(round(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas_nm(z)*10)/10)];
        if ~any(strfind(SigLabel,'.'))
            SigLabel=[SigLabel,'.0'];
        end
        TempTitle={['SIZE = ',num2str(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z)),'px SIGMA = ',num2str(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z)),' px'];['SIGMA = ',SigLabel,' nm']};
        axis equal tight
        title(TempTitle)
    end
    set(gcf,'position',[0,100,800,700])
    Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'Filters',dc,'QuaSOR Filters'],3)
    pause(1)
    close all
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('======================================')
    fprintf('Making QuaSOR_LowRes Maps...\n')
    if size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1
        for z=1:length(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas)
            disp('======================================')
            disp(['Making QuaSOR_LowRes Map #',num2str(z),' for Gaussian Filter SIZE = ',num2str(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z)),...
                ' SIGMA = ',num2str(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z))])
            Repeats=0;
            if GPU_Accelerate
                try
                    [QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image,QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors,myPool]=...
                        QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_UpScaleFactor,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageHeight,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageWidth,...
                        QuaSOR_Data.All_Location_Coords_byOverallFrame,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z),QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z),...
                        QuaSOR_Map_Settings.SpotNormalization,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_TemporalColorizations(z),QuaSOR_LowRes_Maps.QuaSOR_LowRes_Temporal_Colormap,0);
                catch
                    warning('GPU Accelerated QuaSOR_Map_Maker Crashed, Sometimes this can be resolved with a restart so trying again in 60s')
                    pause(60)
                    try
                        [QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image,QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors,myPool]=...
                            QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_UpScaleFactor,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageHeight,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageWidth,...
                            QuaSOR_Data.All_Location_Coords_byOverallFrame,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z),QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z),...
                            QuaSOR_Map_Settings.SpotNormalization,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_TemporalColorizations(z),QuaSOR_LowRes_Maps.QuaSOR_LowRes_Temporal_Colormap,0);
                    catch
                        warning('GPU Accelerated QuaSOR_Map_Maker Crashed Again Trying ONE More Time Without GPU')
                        try
                            [QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image,QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors,myPool]=...
                                QuaSOR_Map_Maker(myPool,0,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_UpScaleFactor,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageHeight,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageWidth,...
                                QuaSOR_Data.All_Location_Coords_byOverallFrame,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Size,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigma,...
                                QuaSOR_Map_Settings.SpotNormalization,QuaSOR_LowRes_Maps.QuaSOR_LowRes_TemporalColorization,QuaSOR_LowRes_Maps.QuaSOR_LowRes_Temporal_Colormap,0);
                        catch
                            error('I give up! Exiting....')
                        end
                    end
                end
            else
                [QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image,QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors,myPool]=...
                    QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_UpScaleFactor,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageHeight,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageWidth,...
                    QuaSOR_Data.All_Location_Coords_byOverallFrame,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z),QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z),...
                    QuaSOR_Map_Settings.SpotNormalization,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_TemporalColorizations(z),QuaSOR_LowRes_Maps.QuaSOR_LowRes_Temporal_Colormap,0);
            end
            if GPU_Accelerate
                try
                    warning('Resetting GPU...')
                    GPU_Device=gpuDevice;
                    GPU_Accelerate=true;
                    disp(['GPU Processing using the ',GPU_Device.Name,' is ENGAGED!'])
                    disp(['GPU: ',num2str(round(GPU_Device.AvailableMemory/1e9*100)/100),'/',...
                        num2str(round(GPU_Device.TotalMemory/1e9*100)/100),' GB Memory | ',...
                        num2str(GPU_Device.MultiprocessorCount),' Processors | ',...
                        num2str(GPU_Device.MaxThreadsPerBlock),' Threads/Block'])
                        if GPU_Device.TotalMemory<GPU_Memory_Miniumum
                            warning('Total GPU memory may be too small so turning off GPU Acceleration!')
                            GPU_Accelerate=false;
                        end

                catch
                    warning('NO GPU WITH CUDA AVAILABlE!!')
                    GPU_Device=[];
                    GPU_Accelerate=false;
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isfield(QuaSOR_Data,'Modality')
                for Mod=1:length(QuaSOR_Data.Modality)
                    disp('======================================')
                    disp(['Making ',QuaSOR_Data.Modality(Mod).Label,' QuaSOR_LowRes Map #',num2str(z),' for Gaussian Filter SIZE = ',num2str(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z)),...
                        ' SIGMA = ',num2str(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z))])
                    Repeats=0;
                    if GPU_Accelerate
                        try
                            [QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image,QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors,myPool]=...
                                QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_UpScaleFactor,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageHeight,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageWidth,...
                                QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z),QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z),...
                                QuaSOR_Map_Settings.SpotNormalization,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_TemporalColorizations(z),QuaSOR_LowRes_Maps.QuaSOR_LowRes_Temporal_Colormap,0);
                        catch
                            warning('GPU Accelerated QuaSOR_Map_Maker Crashed, Sometimes this can be resolved with a restart so trying again in 60s')
                            pause(60)
                            try
                                [QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image,QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors,myPool]=...
                                    QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_UpScaleFactor,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageHeight,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageWidth,...
                                    QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z),QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z),...
                                    QuaSOR_Map_Settings.SpotNormalization,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_TemporalColorizations(z),QuaSOR_LowRes_Maps.QuaSOR_LowRes_Temporal_Colormap,0);
                            catch
                                warning('GPU Accelerated QuaSOR_Map_Maker Crashed Again Trying ONE More Time Without GPU')
                                try
                                    [QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image,QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors,myPool]=...
                                        QuaSOR_Map_Maker(myPool,0,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_UpScaleFactor,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageHeight,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageWidth,...
                                        QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Size,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigma,...
                                        QuaSOR_Map_Settings.SpotNormalization,QuaSOR_LowRes_Maps.QuaSOR_LowRes_TemporalColorization,QuaSOR_LowRes_Maps.QuaSOR_LowRes_Temporal_Colormap,0);
                                catch
                                    error('I give up! Exiting....')
                                end
                            end
                        end
                    else
                        [QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image,QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors,myPool]=...
                            QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_UpScaleFactor,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageHeight,QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageWidth,...
                            QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sizes(z),QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas(z),...
                            QuaSOR_Map_Settings.SpotNormalization,QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_TemporalColorizations(z),QuaSOR_LowRes_Maps.QuaSOR_LowRes_Temporal_Colormap,0);
                    end
                    if GPU_Accelerate
                        try
                            warning('Resetting GPU...')
                            GPU_Device=gpuDevice;
                            GPU_Accelerate=true;
                            disp(['GPU Processing using the ',GPU_Device.Name,' is ENGAGED!'])
                            disp(['GPU: ',num2str(round(GPU_Device.AvailableMemory/1e9*100)/100),'/',...
                                num2str(round(GPU_Device.TotalMemory/1e9*100)/100),' GB Memory | ',...
                                num2str(GPU_Device.MultiprocessorCount),' Processors | ',...
                                num2str(GPU_Device.MaxThreadsPerBlock),' Threads/Block'])
                                if GPU_Device.TotalMemory<GPU_Memory_Miniumum
                                    warning('Total GPU memory may be too small so turning off GPU Acceleration!')
                                    GPU_Accelerate=false;
                                end

                        catch
                            warning('NO GPU WITH CUDA AVAILABlE!!')
                            GPU_Device=[];
                            GPU_Accelerate=false;
                        end
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    else
        warning on
        warning('No events to render!')
        warning('No events to render!')
        warning('No events to render!')
        warning('No events to render!')
        warning('No events to render!')
        for z=1:length(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas)
            QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image=QuaSOR_LowRes_ZerosImage;
            QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors=[];
            if isfield(QuaSOR_Data,'Modality')
                for Mod=1:length(QuaSOR_Data.Modality)
                    QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image=QuaSOR_LowRes_ZerosImage;
                    QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image_TemporalColors=[];
                end
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    disp('======================================')
    fprintf('Adjusting QuaSOR_LowRes Contrast and Colors...')
    close all
    progressbar('Filter','Contrast')
    for z=1:length(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas)
        for x=1:length(QuaSOR_LowRes_Map_Settings.ContrastEnhancements)
            progressbar(z/length(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas),x/length(QuaSOR_LowRes_Map_Settings.ContrastEnhancements))
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Color_Scalar=QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Color_Scalar;
            QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement=QuaSOR_LowRes_Map_Settings.ContrastEnhancements(x);
            QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                (ceil(max(QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image(:))));
            QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                ceil(QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*...
                QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [~,QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Heatmap,~]=...
                Adjust_Contrast_and_Color(QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image,...
                0,QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont,QuaSOR_Map_Settings.ExportColorMap,...
                QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Color_Scalar);
            QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Heatmap=...
                ColorMasking(QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Heatmap,...
                ~AllBoutonsRegion,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
            QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Heatmap=...
                single(QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Heatmap);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [~,QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Color,~]=...
                Adjust_Contrast_and_Color(QuaSOR_LowRes_Maps.HighRes_Maps(z).QuaSOR_LowRes_Image,...
                0,QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont,...
                QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Overlay_Color,...
                QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Color_Scalar);
            QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Color=...
                ColorMasking(QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Color,...
                ~AllBoutonsRegion,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
            QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Color=...
                single(QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Color);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end 
    end
    fprintf('FINISHED!\n');
    if isfield(QuaSOR_Data,'Modality')
        for Mod=1:length(QuaSOR_Data.Modality)
            disp('======================================')
                QuaSOR_LowRes_Maps.Modality(Mod).Label=QuaSOR_Data.Modality(Mod).Label;
                QuaSOR_LowRes_Maps.Modality(Mod).Color=QuaSOR_Map_Settings.Modality_Colors{Mod};
            fprintf(['Adjusting QuaSOR_LowRes Contrast and Colors for ',QuaSOR_LowRes_Maps.Modality(Mod).Label,'...'])
            close all
            progressbar('Filter','Contrast')
            for z=1:length(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas)
                for x=1:length(QuaSOR_LowRes_Map_Settings.ContrastEnhancements)
                    progressbar(z/length(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas),x/length(QuaSOR_LowRes_Map_Settings.ContrastEnhancements))
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Color_Scalar=QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Color_Scalar;
                    QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement=QuaSOR_LowRes_Map_Settings.ContrastEnhancements(x);
                    QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                        (ceil(max(QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image(:))));
                    QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                        ceil(QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*...
                        QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [~,QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Heatmap,~]=...
                        Adjust_Contrast_and_Color(QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image,...
                        0,QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont,QuaSOR_Map_Settings.ExportColorMap,...
                        QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Color_Scalar);
                    QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Heatmap=...
                        ColorMasking(QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Heatmap,...
                        ~AllBoutonsRegion,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
                    QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Heatmap=...
                        single(QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Heatmap);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [~,QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Color,~]=...
                        Adjust_Contrast_and_Color(QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_LowRes_Image,...
                        0,QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont,...
                        QuaSOR_LowRes_Maps.Modality(Mod).Color,...
                        QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Color_Scalar);
                    QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Color=...
                        ColorMasking(QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Color,...
                        ~AllBoutonsRegion,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
                    QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Color=...
                        single(QuaSOR_LowRes_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Color);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end 
            end
            fprintf('FINISHED!\n');
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    disp('=======================================================================')
    disp('QuaSOR Map Processing...')
    fprintf([num2str(size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)),' QuaSOR Event Localizations to Render\n'])
    disp('=====================================================================')
    disp('=====================================================================')
    disp('=====================================================================')
    disp('=====================================================================')
    warning('Checking For Duplicate Coordinates! NEEDS FIXING')
    [   DuplicateCoords,...
        DuplicateIndices,...
        DuplicateCount]=...
        DuplicateFinder(QuaSOR_Data.All_Location_Coords_byOverallFrame);
    if DuplicateCount>0
       warning(['QuaSOR_Data.All_Location_Coords_byOverallFrame has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_Data.All_Location_Coords_byOverallFrame has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_Data.All_Location_Coords_byOverallFrame has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_Data.All_Location_Coords_byOverallFrame has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_Data.All_Location_Coords_byOverallFrame has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_Data.All_Location_Coords_byOverallFrame has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_Data.All_Location_Coords_byOverallFrame has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_Data.All_Location_Coords_byOverallFrame has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_Data.All_Location_Coords_byOverallFrame has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)),' Duplicate QuaSOR Coordinates!']) 
       warning(['QuaSOR_Data.All_Location_Coords_byOverallFrame has ',num2str(DuplicateCount),'/',num2str(size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)),' Duplicate QuaSOR Coordinates!']) 
       if RemoveDuplicates
           error('REMOVE DUPLICATES!')
       end
       
    end
    disp('=====================================================================')
    disp('=====================================================================')
    disp('=====================================================================')
    disp('=====================================================================')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1
        QuaSOR_NumFrames=max(QuaSOR_Data.All_Location_Coords_byOverallFrame(:,3));
    else
        QuaSOR_NumFrames=0;
    end
    fprintf(['From ',num2str(QuaSOR_NumFrames),' Timepoints\n'])
    fprintf('Calculating QuaSOR Maps Sizes...\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor=QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor;
    QuaSOR_Maps.QuaSOR_ImageHeight=round(Image_Height*QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor);
    QuaSOR_Maps.QuaSOR_ImageWidth=round(Image_Width*QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['QuaSOR Image ',num2str(QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor),'X Upscaling Dimensions = ',...
        num2str(QuaSOR_Maps.QuaSOR_ImageHeight),'(H) X ',num2str(QuaSOR_Maps.QuaSOR_ImageWidth),'(W)'])
    QuaSOR_ZerosImage=zeros(QuaSOR_Maps.QuaSOR_ImageHeight,QuaSOR_Maps.QuaSOR_ImageWidth);
    QuaSOR_ZerosImage_Color=zeros(QuaSOR_Maps.QuaSOR_ImageHeight,QuaSOR_Maps.QuaSOR_ImageWidth,3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Colormap for color projection
    R = linspace(0,1,QuaSOR_NumFrames);
    B = linspace(1,0,QuaSOR_NumFrames);
    G = zeros(size(R));
    QuaSOR_Maps.QuaSOR_Temporal_Colormap=( [R(:), G(:), B(:)] );
    clear R B G
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Colormap for versus
    QuaSOR_Colormap=makeColorMap([0 0 0],ColorDefinitions(QuaSOR_Map_Settings.QuaSOR_Overlay_Color),2^16);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Calculating QuaSOR Event Filtering Parameters...\n')
    if isempty(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes)
        QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes=zeros(size(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas));
        for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
            if QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z)~=0
                QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z)=...
                    2*ceil(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z)*2)+QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_SizeBuffer;
                if rem(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z),2)==0
                    QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z)=QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z)+1;
                end
            end
        end
    end
    for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
        QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes_nm(z)=QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z)*ScaleBar_Upscale.ScaleFactor*1000;
        QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas_nm(z)=QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z)*ScaleBar_Upscale.ScaleFactor*1000;
    end
    for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
        disp(['Event Gaussian Filter SIZE = ',num2str(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z)),...
            ' SIGMA = ',num2str(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z))])
        QuaSOR_Maps.HighRes_Maps(z).GaussianParticleSize=QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z);
        QuaSOR_Maps.HighRes_Maps(z).GaussianParticleSigma=QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z);
        TestImage=zeros(max(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes));
        TestImage(ceil(max(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes)/2),ceil(max(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes)/2))=1;
        if QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z)~=0
            TestImage=imgaussfilt(double(TestImage), QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z),'FilterSize',QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z));
        end
        QuaSOR_Maps.HighRes_Maps(z).GaussianParticle_Image=TestImage;        
        QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image=double(QuaSOR_ZerosImage);
        if QuaSOR_Map_Settings.QuaSOR_TemporalColorizations(z)
            QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image_TemporalColors=double(QuaSOR_ZerosImage_Color);
        else
            QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image_TemporalColors=[];
        end
        if isfield(QuaSOR_Data,'Modality')
            for Mod=1:length(QuaSOR_Data.Modality)
                QuaSOR_Maps.Modality(Mod).Label=QuaSOR_Data.Modality(Mod).Label;
                QuaSOR_Maps.Modality(Mod).Color=QuaSOR_Map_Settings.Modality_Colors{Mod};
                QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image=double(QuaSOR_ZerosImage);
                if QuaSOR_Map_Settings.QuaSOR_TemporalColorizations(z)
                    QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image_TemporalColors=double(QuaSOR_ZerosImage_Color);
                else
                    QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image_TemporalColors=[];
                end
            end
        end
    end
    figure('name','QuaSOR Filters')
    for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
        subplot(3,3,z)
        imagesc(QuaSOR_Maps.HighRes_Maps(z).GaussianParticle_Image)
        SigLabel=[num2str(round(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas_nm(z)*10)/10)];
        if ~any(strfind(SigLabel,'.'))
            SigLabel=[SigLabel,'.0'];
        end
        TempTitle={['SIZE = ',num2str(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z)),'px SIGMA = ',num2str(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z)),' px'];['SIGMA = ',SigLabel,' nm']};
        axis equal tight
        title(TempTitle)
    end
    set(gcf,'position',[0,100,800,700])
    Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'Filters',dc,'QuaSOR Filters'],3)
    pause(1)
    close all
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('======================================')
    fprintf('Making QuaSOR Maps...\n')
    if size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1
        for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
            disp('======================================')
            disp(['Making QuaSOR Map #',num2str(z),' for Gaussian Filter SIZE = ',num2str(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z)),...
                ' SIGMA = ',num2str(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z))])
            Repeats=0;
            if GPU_Accelerate
                try
                    [QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image,QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image_TemporalColors,myPool]=...
                        QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor,QuaSOR_Maps.QuaSOR_ImageHeight,QuaSOR_Maps.QuaSOR_ImageWidth,...
                        QuaSOR_Data.All_Location_Coords_byOverallFrame,QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z),QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z),...
                        QuaSOR_Map_Settings.SpotNormalization,QuaSOR_Map_Settings.QuaSOR_TemporalColorizations(z),QuaSOR_Maps.QuaSOR_Temporal_Colormap,0);
                catch
                    warning('GPU Accelerated QuaSOR_Map_Maker Crashed, Sometimes this can be resolved with a restart so trying again in 60s')
                    pause(60)
                    try
                        [QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image,QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image_TemporalColors,myPool]=...
                            QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor,QuaSOR_Maps.QuaSOR_ImageHeight,QuaSOR_Maps.QuaSOR_ImageWidth,...
                            QuaSOR_Data.All_Location_Coords_byOverallFrame,QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z),QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z),...
                            QuaSOR_Map_Settings.SpotNormalization,QuaSOR_Map_Settings.QuaSOR_TemporalColorizations(z),QuaSOR_Maps.QuaSOR_Temporal_Colormap,0);
                    catch
                        warning('GPU Accelerated QuaSOR_Map_Maker Crashed Again Trying ONE More Time Without GPU')
                        try
                            [QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image,QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image_TemporalColors,myPool]=...
                                QuaSOR_Map_Maker(myPool,0,QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor,QuaSOR_Maps.QuaSOR_ImageHeight,QuaSOR_Maps.QuaSOR_ImageWidth,...
                                QuaSOR_Data.All_Location_Coords_byOverallFrame,QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Size,QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigma,...
                                QuaSOR_Map_Settings.SpotNormalization,QuaSOR_Maps.QuaSOR_TemporalColorization,QuaSOR_Maps.QuaSOR_Temporal_Colormap,0);
                        catch
                            error('I give up! Exiting....')
                        end
                    end
                end
            else
                [QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image,QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image_TemporalColors,myPool]=...
                    QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor,QuaSOR_Maps.QuaSOR_ImageHeight,QuaSOR_Maps.QuaSOR_ImageWidth,...
                    QuaSOR_Data.All_Location_Coords_byOverallFrame,QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z),QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z),...
                    QuaSOR_Map_Settings.SpotNormalization,QuaSOR_Map_Settings.QuaSOR_TemporalColorizations(z),QuaSOR_Maps.QuaSOR_Temporal_Colormap,0);
            end
            if GPU_Accelerate
                try
                    warning('Resetting GPU...')
                    GPU_Device=gpuDevice;
                    GPU_Accelerate=true;
                    disp(['GPU Processing using the ',GPU_Device.Name,' is ENGAGED!'])
                    disp(['GPU: ',num2str(round(GPU_Device.AvailableMemory/1e9*100)/100),'/',...
                        num2str(round(GPU_Device.TotalMemory/1e9*100)/100),' GB Memory | ',...
                        num2str(GPU_Device.MultiprocessorCount),' Processors | ',...
                        num2str(GPU_Device.MaxThreadsPerBlock),' Threads/Block'])
                        if GPU_Device.TotalMemory<GPU_Memory_Miniumum
                            warning('Total GPU memory may be too small so turning off GPU Acceleration!')
                            GPU_Accelerate=false;
                        end

                catch
                    warning('NO GPU WITH CUDA AVAILABlE!!')
                    GPU_Device=[];
                    GPU_Accelerate=false;
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isfield(QuaSOR_Data,'Modality')
                for Mod=1:length(QuaSOR_Data.Modality)
                    disp('======================================')
                    disp(['Making ',QuaSOR_Data.Modality(Mod).Label,' QuaSOR Map #',num2str(z),' for Gaussian Filter SIZE = ',num2str(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z)),...
                        ' SIGMA = ',num2str(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z))])
                    Repeats=0;
                    if GPU_Accelerate
                        try
                            [QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image,QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image_TemporalColors,myPool]=...
                                QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor,QuaSOR_Maps.QuaSOR_ImageHeight,QuaSOR_Maps.QuaSOR_ImageWidth,...
                                QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame,QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z),QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z),...
                                QuaSOR_Map_Settings.SpotNormalization,QuaSOR_Map_Settings.QuaSOR_TemporalColorizations(z),QuaSOR_Maps.QuaSOR_Temporal_Colormap,0);
                        catch
                            warning('GPU Accelerated QuaSOR_Map_Maker Crashed, Sometimes this can be resolved with a restart so trying again in 60s')
                            pause(60)
                            try
                                [QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image,QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image_TemporalColors,myPool]=...
                                    QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor,QuaSOR_Maps.QuaSOR_ImageHeight,QuaSOR_Maps.QuaSOR_ImageWidth,...
                                    QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame,QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z),QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z),...
                                    QuaSOR_Map_Settings.SpotNormalization,QuaSOR_Map_Settings.QuaSOR_TemporalColorizations(z),QuaSOR_Maps.QuaSOR_Temporal_Colormap,0);
                            catch
                                warning('GPU Accelerated QuaSOR_Map_Maker Crashed Again Trying ONE More Time Without GPU')
                                try
                                    [QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image,QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image_TemporalColors,myPool]=...
                                        QuaSOR_Map_Maker(myPool,0,QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor,QuaSOR_Maps.QuaSOR_ImageHeight,QuaSOR_Maps.QuaSOR_ImageWidth,...
                                        QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame,QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Size,QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigma,...
                                        QuaSOR_Map_Settings.SpotNormalization,QuaSOR_Maps.QuaSOR_TemporalColorization,QuaSOR_Maps.QuaSOR_Temporal_Colormap,0);
                                catch
                                    error('I give up! Exiting....')
                                end
                            end
                        end
                    else
                        [QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image,QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image_TemporalColors,myPool]=...
                            QuaSOR_Map_Maker(myPool,GPU_Accelerate,QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor,QuaSOR_Maps.QuaSOR_ImageHeight,QuaSOR_Maps.QuaSOR_ImageWidth,...
                            QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame,QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z),QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z),...
                            QuaSOR_Map_Settings.SpotNormalization,QuaSOR_Map_Settings.QuaSOR_TemporalColorizations(z),QuaSOR_Maps.QuaSOR_Temporal_Colormap,0);
                    end
                    if GPU_Accelerate
                        try
                            warning('Resetting GPU...')
                            GPU_Device=gpuDevice;
                            GPU_Accelerate=true;
                            disp(['GPU Processing using the ',GPU_Device.Name,' is ENGAGED!'])
                            disp(['GPU: ',num2str(round(GPU_Device.AvailableMemory/1e9*100)/100),'/',...
                                num2str(round(GPU_Device.TotalMemory/1e9*100)/100),' GB Memory | ',...
                                num2str(GPU_Device.MultiprocessorCount),' Processors | ',...
                                num2str(GPU_Device.MaxThreadsPerBlock),' Threads/Block'])
                                if GPU_Device.TotalMemory<GPU_Memory_Miniumum
                                    warning('Total GPU memory may be too small so turning off GPU Acceleration!')
                                    GPU_Accelerate=false;
                                end

                        catch
                            warning('NO GPU WITH CUDA AVAILABlE!!')
                            GPU_Device=[];
                            GPU_Accelerate=false;
                        end
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    else
        warning on
        warning('No events to render!')
        warning('No events to render!')
        warning('No events to render!')
        warning('No events to render!')
        warning('No events to render!')
        for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
            QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image=QuaSOR_ZerosImage;
            QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image_TemporalColors=[];
            if isfield(QuaSOR_Data,'Modality')
                for Mod=1:length(QuaSOR_Data.Modality)
                    QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image=QuaSOR_ZerosImage;
                    QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image_TemporalColors=[];
                end
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    disp('======================================')
    fprintf('Adjusting QuaSOR Contrast and Colors...')
    close all
    progressbar('Filter','Contrast')
    for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
        for x=1:length(QuaSOR_Map_Settings.ContrastEnhancements)
            progressbar(z/length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas),x/length(QuaSOR_Map_Settings.ContrastEnhancements))
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Map_Settings.QuaSOR_Color_Scalar=QuaSOR_Map_Settings.QuaSOR_Color_Scalar;
            QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement=QuaSOR_Map_Settings.ContrastEnhancements(x);
            QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                (ceil(max(QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image(:))));
            QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                ceil(QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*...
                QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [~,QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap,~]=...
                Adjust_Contrast_and_Color(QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image,...
                0,QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont,QuaSOR_Map_Settings.ExportColorMap,...
                QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Map_Settings.QuaSOR_Color_Scalar);
            QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap=...
                ColorMasking(QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap,...
                ~QuaSOR_Map_Settings.AllBoutonsRegion_Upscale,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
            QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap=...
                single(QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [~,QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color,~]=...
                Adjust_Contrast_and_Color(QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image,...
                0,QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont,...
                QuaSOR_Map_Settings.QuaSOR_Overlay_Color,...
                QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Map_Settings.QuaSOR_Color_Scalar);
            QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color=...
                ColorMasking(QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color,...
                ~QuaSOR_Map_Settings.AllBoutonsRegion_Upscale,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
            QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color=...
                single(QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end 
    end
    fprintf('FINISHED!\n');
    for Mod=1:length(QuaSOR_Data.Modality)
        disp('======================================')
        QuaSOR_Maps.Modality(Mod).Label=QuaSOR_Data.Modality(Mod).Label;
        QuaSOR_Maps.Modality(Mod).Color=QuaSOR_Map_Settings.Modality_Colors{Mod};
        fprintf(['Adjusting QuaSOR Contrast and Colors for ',QuaSOR_Maps.Modality(Mod).Label,'...'])
        close all
        progressbar('Filter','Contrast')
        for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
            for x=1:length(QuaSOR_Map_Settings.ContrastEnhancements)
                progressbar(z/length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas),x/length(QuaSOR_Map_Settings.ContrastEnhancements))
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Map_Settings.QuaSOR_Color_Scalar=QuaSOR_Map_Settings.QuaSOR_Color_Scalar;
                QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement=QuaSOR_Map_Settings.ContrastEnhancements(x);
                QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue=...
                    (ceil(max(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image(:))));
                QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont=...
                    ceil(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue*...
                    QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).ContrastEnhancement);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [~,QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap,~]=...
                    Adjust_Contrast_and_Color(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image,...
                    0,QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont,QuaSOR_Map_Settings.ExportColorMap,...
                    QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Map_Settings.QuaSOR_Color_Scalar);
                QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap=...
                    ColorMasking(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap,...
                    ~QuaSOR_Map_Settings.AllBoutonsRegion_Upscale,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
                QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap=...
                    single(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [~,QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color,~]=...
                    Adjust_Contrast_and_Color(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image,...
                    0,QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont,...
                    QuaSOR_Maps.Modality(Mod).Color,...
                    QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Map_Settings.QuaSOR_Color_Scalar);
                QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color=...
                    ColorMasking(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color,...
                    ~QuaSOR_Map_Settings.AllBoutonsRegion_Upscale,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
                QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color=...
                    single(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end 
        end
        fprintf('FINISHED!\n');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    disp('=======================================================================')
    close all
    if DisplayIntermediates
        disp('Displaying Results...')
        DisplayMaxSaturation=0.5;
        for z=1:length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas)
            figure, imagesc(PixelMax_Maps.HighRes_Maps(z).PixelMax_Image)
            axis equal tight, caxis([0,max(PixelMax_Maps.HighRes_Maps(z).PixelMax_Image(:))*DisplayMaxSaturation]);
            colorbar;
            title(['PixelMax | Filter SIZE = ',num2str(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sizes(z)),...
                ' SIGMA = ',num2str(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas(z))])
        end
        for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
            figure, imagesc(QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image)
            axis equal tight, caxis([0,max(QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image(:))*DisplayMaxSaturation])
            colorbar;
            title(['QuaSOR | Filter SIZE = ',num2str(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sizes(z)),...
                ' SIGMA = ',num2str(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas(z))])
        end
        pause(5)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    disp('======================================')
    fprintf('Making PixelMax vs QuaSOR Images...')
    if size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1
    
        PixelMax_Resize_Image_HeatMap=imresize(PixelMax_Maps.HighRes_Maps(PixelMax_Map_Settings.PixelMax_Overlay_FilterIndex).ContrastedOutputImages(PixelMax_Map_Settings.PixelMax_Overlay_ContrastIndex).PixelMax_Image_Heatmap,...
            QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod);    
        PixelMax_Resize_Image_Color=imresize(PixelMax_Maps.HighRes_Maps(PixelMax_Map_Settings.PixelMax_Overlay_FilterIndex).ContrastedOutputImages(PixelMax_Map_Settings.PixelMax_Overlay_ContrastIndex).PixelMax_Image_Color,...
            QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod);

        QuaSOR_vs_PixelMax_Maps.PixelMax_Image=PixelMax_Resize_Image_Color+...
            QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Color;
        QuaSOR_vs_PixelMax_Maps.PixelMax_Image=ColorMasking(QuaSOR_vs_PixelMax_Maps.PixelMax_Image,...
                    PixelMax_Map_Settings.MaskDiff,[0,0,0]);
        QuaSOR_vs_PixelMax_Maps.PixelMax_Image=ColorMasking(QuaSOR_vs_PixelMax_Maps.PixelMax_Image,...
                    ~QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);

        QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithHeatMaps=PixelMax_Resize_Image_HeatMap;
        QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithHeatMaps=vertcat(QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithHeatMaps,...
            QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Heatmap);
        QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithHeatMaps=vertcat(QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithHeatMaps,QuaSOR_vs_PixelMax_Maps.PixelMax_Image);

        QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithColors=PixelMax_Resize_Image_Color;
        QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithColors=vertcat(QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithColors,...
            QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Color);
        QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithColors=vertcat(QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithColors,QuaSOR_vs_PixelMax_Maps.PixelMax_Image);

    else
        PixelMax_Resize_Image_HeatMap=QuaSOR_ZerosImage_Color;
        PixelMax_Resize_Image_Color=QuaSOR_ZerosImage_Color;
        QuaSOR_vs_PixelMax_Maps.PixelMax_Image=QuaSOR_ZerosImage_Color;
        QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithHeatMaps=QuaSOR_ZerosImage_Color;
        QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithColors=QuaSOR_ZerosImage_Color;
    end
    fprintf('FINISHED!\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    disp('======================================')
    fprintf('Making QuaSOR Low Res vs QuaSOR UpScale Images...')
    if size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1
    
        QuaSOR_LowRes_Resize_Image_HeatMap=imresize(QuaSOR_LowRes_Maps.HighRes_Maps(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Overlay_ContrastIndex).QuaSOR_LowRes_Image_Heatmap,...
            QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod);    
        QuaSOR_LowRes_Resize_Image_Color=imresize(QuaSOR_LowRes_Maps.HighRes_Maps(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Overlay_ContrastIndex).QuaSOR_LowRes_Image_Color,...
            QuaSOR_Maps.QuaSOR_Map_Settings.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod);

        QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image=QuaSOR_LowRes_Resize_Image_Color+...
            QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Color;
        QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image=ColorMasking(QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image,...
                    QuaSOR_LowRes_Map_Settings.MaskDiff,[0,0,0]);
        QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image=ColorMasking(QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image,...
                    ~QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);

        QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithHeatMaps=QuaSOR_LowRes_Resize_Image_HeatMap;
        QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithHeatMaps=vertcat(QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithHeatMaps,...
            QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Heatmap);
        QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithHeatMaps=vertcat(QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithHeatMaps,QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image);

        QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithColors=QuaSOR_LowRes_Resize_Image_Color;
        QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithColors=vertcat(QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithColors,...
            QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Color);
        QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithColors=vertcat(QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithColors,QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image);

    else
        QuaSOR_LowRes_Resize_Image_HeatMap=QuaSOR_ZerosImage_Color;
        QuaSOR_LowRes_Resize_Image_Color=QuaSOR_ZerosImage_Color;
        QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image=QuaSOR_ZerosImage_Color;
        QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithHeatMaps=QuaSOR_ZerosImage_Color;
        QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithColors=QuaSOR_ZerosImage_Color;
    end
    fprintf('FINISHED!\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    disp('======================================')
    fprintf('Making Modality Overlay QuaSOR Images...')
    if size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1

        QuaSOR_Modality_Overlay_Maps.QuaSOR_Image=QuaSOR_ZerosImage_Color;
        QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithHeatMaps=[];
        QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithColors=[];
        for Mod=1:length(QuaSOR_Data.Modality)

            QuaSOR_Modality_Overlay_Maps.QuaSOR_Image=QuaSOR_Modality_Overlay_Maps.QuaSOR_Image+...
                QuaSOR_Maps.Modality(Mod).HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_FilterIndex).ContrastedOutputImages(...
                QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_ContrastIndices(Mod)).QuaSOR_Image_Color;

            QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithHeatMaps=vertcat(QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithHeatMaps,...
                QuaSOR_Maps.Modality(Mod).HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_FilterIndex).ContrastedOutputImages(...
                QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_ContrastIndices(Mod)).QuaSOR_Image_Heatmap);

            QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithColors=vertcat(QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithColors,...
                QuaSOR_Maps.Modality(Mod).HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_FilterIndex).ContrastedOutputImages(...
                QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_ContrastIndices(Mod)).QuaSOR_Image_Color);
        end
        QuaSOR_Modality_Overlay_Maps.QuaSOR_Image=ColorMasking(QuaSOR_Modality_Overlay_Maps.QuaSOR_Image,...
            ~QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
        QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithColors=vertcat(QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithColors,...
            QuaSOR_Modality_Overlay_Maps.QuaSOR_Image);
    else
        QuaSOR_Modality_Overlay_Maps.QuaSOR_Image=QuaSOR_ZerosImage_Color;
        QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithHeatMaps=[];
        QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithColors=[];
    end
    fprintf('FINISHED!\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    figure, imshow(QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithColors)
    figure, imshow(QuaSOR_Modality_Overlay_Maps.QuaSOR_Image)
    figure, imshow(QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithHeatMaps)
    figure, imshow(QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithColors)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    if ExportImages
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        disp('======================================')
        disp('Exporting PixelMax Images...')
        warning off
        for z=1:length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas)
            SigLabel=[num2str(round(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas_nm(z)*10)/10)];
            if ~any(strfind(SigLabel,'.'))
                SigLabel=[SigLabel,'.0'];
            end
            for x=1:length(PixelMax_Map_Settings.ContrastEnhancements)
                ContLabel=[num2str(round(double(PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont)*10)/10)];
                FigName=['AllCoords_PixelMax_H_Sig',SigLabel,'nm_Max',ContLabel];
                fprintf(['Exporting: ',FigName,' Figures...']);

                imwrite(double(PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'PixelMax',dc,FigName,'.tif'])

                figure('name',FigName)
                imshow(PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap)
                hold on;
                if IbIs
                    for BoutonCount=1:length(PixelMax_Map_Settings.BoutonArray)
                        for j=1:length(PixelMax_Map_Settings.BoutonArray(BoutonCount).PixelMax_Bouton_Mask_BorderLine)
                            plot(PixelMax_Map_Settings.BoutonArray(BoutonCount).PixelMax_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                                PixelMax_Map_Settings.BoutonArray(BoutonCount).PixelMax_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                                '-','color',BoutonArray(BoutonCount).Color,'linewidth',1)
                        end
                    end
                else
                    for j=1:length(PixelMax_Map_Settings.PixelMax_Bouton_Mask_BorderLine)
                        plot(PixelMax_Map_Settings.PixelMax_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            PixelMax_Map_Settings.PixelMax_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                            '-','color',QuaSOR_Map_Settings.ExportBorderColor,'linewidth',PixelMax_Map_Settings.PixelMax_BorderLine_Width)
                    end
                end
                plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',PixelMax_Map_Settings.PixelMax_BorderLine_Width);
                set(gcf, 'color', 'white');
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gca,'units','normalized','position',[0,0,1,1])
                pause(1)
                set(gcf,'units','pixels','position',[ScreenSize(3)+100,ScreenSize(4)+100,...
                    round(PixelMax_Map_Settings.PixelMax_PixelSizeScalar*PixelMax_Maps.PixelMax_ImageWidth),round(PixelMax_Map_Settings.PixelMax_PixelSizeScalar*PixelMax_Maps.PixelMax_ImageHeight)])
                Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'PixelMax',dc, FigName, ' Bord'],3)
                %And just Color Image
                FigName=['AllCoords_PixelMax_C_Sig',SigLabel,'nm_Max',ContLabel];            
                imwrite(double(PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Color),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'PixelMax',dc,FigName,'.tif'])

                fprintf('FINISHED!\n');
            end
            close all
        end
        warning on
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        disp('======================================')
        disp('Exporting QuaSOR_LowRes Images...')
        warning off
        for z=1:length(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas)
            SigLabel=[num2str(round(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas_nm(z)*10)/10)];
            if ~any(strfind(SigLabel,'.'))
                SigLabel=[SigLabel,'.0'];
            end
            for x=1:length(QuaSOR_LowRes_Map_Settings.ContrastEnhancements)
                ContLabel=[num2str(round(double(QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont)*10)/10)];
                FigName=['AllCoords_QuaSOR_LowRes_H_Sig',SigLabel,'nm_Max',ContLabel];
                fprintf(['Exporting: ',FigName,' Figures...']);

                imwrite(double(QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Heatmap),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'QuaSOR_LowRes',dc,FigName,'.tif'])

                figure('name',FigName)
                imshow(QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Heatmap)
                hold on;
                if IbIs
                    for BoutonCount=1:length(QuaSOR_LowRes_Map_Settings.BoutonArray)
                        for j=1:length(QuaSOR_LowRes_Map_Settings.BoutonArray(BoutonCount).QuaSOR_LowRes_Bouton_Mask_BorderLine)
                            plot(QuaSOR_LowRes_Map_Settings.BoutonArray(BoutonCount).QuaSOR_LowRes_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                                QuaSOR_LowRes_Map_Settings.BoutonArray(BoutonCount).QuaSOR_LowRes_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                                '-','color',BoutonArray(BoutonCount).Color,'linewidth',1)
                        end
                    end
                else
                    for j=1:length(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Bouton_Mask_BorderLine)
                        plot(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                            '-','color',QuaSOR_Map_Settings.ExportBorderColor,'linewidth',QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_BorderLine_Width)
                    end
                end
                plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_BorderLine_Width);
                set(gcf, 'color', 'white');
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gca,'units','normalized','position',[0,0,1,1])
                pause(1)
                set(gcf,'units','pixels','position',[ScreenSize(3)+100,ScreenSize(4)+100,...
                    round(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_PixelSizeScalar*QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageWidth),round(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_PixelSizeScalar*QuaSOR_LowRes_Maps.QuaSOR_LowRes_ImageHeight)])
                Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'QuaSOR_LowRes',dc, FigName, ' Bord'],3)
                %And just Color Image
                FigName=['AllCoords_QuaSOR_LowRes_C_Sig',SigLabel,'nm_Max',ContLabel];            
                imwrite(double(QuaSOR_LowRes_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_LowRes_Image_Color),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'QuaSOR_LowRes',dc,FigName,'.tif'])

                fprintf('FINISHED!\n');
            end
            close all
        end
        warning on
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        disp('======================================')
        disp('Exporting ALL Coordinate QuaSOR Images...')
        warning off
        for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
            SigLabel=[num2str(round(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas_nm(z)*10)/10)];
            if ~any(strfind(SigLabel,'.'))
                SigLabel=[SigLabel,'.0'];
            end
            for x=1:length(QuaSOR_Map_Settings.ContrastEnhancements)
                ContLabel=[num2str(round(double(QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont)*10)/10)];

                FigName=['AllCoords_QuaSOR_H_Sig',SigLabel,'nm_Max',ContLabel];
                fprintf(['Exporting: ',FigName,' Figures...']);

                imwrite(double(QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'QuaSOR',dc,FigName,'.tif'])

                figure('name',FigName)
                imshow(QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap)
                hold on;        
                if IbIs
                    for BoutonCount=1:length(QuaSOR_Map_Settings.BoutonArray)
                        for j=1:length(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine)
                            plot(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                                QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                                '-','color',BoutonArray(BoutonCount).Color,'linewidth',1)
                        end
                    end
                else
                    for j=1:length(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine)
                        plot(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                            '-','color',QuaSOR_Map_Settings.ExportBorderColor,'linewidth',QuaSOR_Map_Settings.QuaSOR_BorderLine_Width)
                    end
                end
                plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',QuaSOR_Map_Settings.QuaSOR_BorderLine_Width);
                set(gcf, 'color', 'white');
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gca,'units','normalized','position',[0,0,1,1])
                pause(1)
                set(gcf,'units','pixels','position',[ScreenSize(3)+100,ScreenSize(4)+100,...
                    round(QuaSOR_Map_Settings.QuaSOR_PixelSizeScalar*QuaSOR_Maps.QuaSOR_ImageWidth),round(QuaSOR_Map_Settings.QuaSOR_PixelSizeScalar*QuaSOR_Maps.QuaSOR_ImageWidth)])
                Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'QuaSOR',dc, FigName, ' Bord'],3)
                %And just Color Image
                FigName=['AllCoords_QuaSOR_C_Sig',SigLabel,'nm_Max',ContLabel];            
                imwrite(double(QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'QuaSOR',dc,FigName,'.tif'])

                fprintf('FINISHED!\n');
            end
            close all
        end
        warning on
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        disp('======================================')
        disp('Exporting Modality-Specific QuaSOR Images...')
        warning off
        for Mod=1:length(QuaSOR_Data.Modality)
            if size(QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame,1)==1

                FigName=[QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_H_NO_EVENTS'];
                fprintf(['Exporting: ',FigName,' Figures...']);

                imwrite(double(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap),[FigureScratchDir,dc,'AutoContMaps',dc,QuaSOR_Maps.Modality(Mod).Label,dc,'QuaSOR',dc,FigName,'.tif'])

                figure('name',FigName)
                imshow(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap)
                hold on;        
                if IbIs
                    for BoutonCount=1:length(QuaSOR_Map_Settings.BoutonArray)
                        for j=1:length(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine)
                            plot(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                                QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                                '-','color',BoutonArray(BoutonCount).Color,'linewidth',1)
                        end
                    end
                else
                    for j=1:length(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine)
                        plot(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                            '-','color',QuaSOR_Map_Settings.ExportBorderColor,'linewidth',QuaSOR_Map_Settings.QuaSOR_BorderLine_Width)
                    end
                end
                plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',QuaSOR_Map_Settings.QuaSOR_BorderLine_Width);
                set(gcf, 'color', 'white');
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gca,'units','normalized','position',[0,0,1,1])
                pause(1)
                set(gcf,'units','pixels','position',[ScreenSize(3)+100,ScreenSize(4)+100,...
                    round(QuaSOR_Map_Settings.QuaSOR_PixelSizeScalar*QuaSOR_Maps.QuaSOR_ImageWidth),round(QuaSOR_Map_Settings.QuaSOR_PixelSizeScalar*QuaSOR_Maps.QuaSOR_ImageWidth)])
                Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'AutoContMaps',dc,QuaSOR_Maps.Modality(Mod).Label,dc,'QuaSOR',dc, FigName, ' Bord'],3)
                %And just Color Image
                FigName=[QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_C_NO_EVENTS'];            
                imwrite(double(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color),[FigureScratchDir,dc,'AutoContMaps',dc,QuaSOR_Maps.Modality(Mod).Label,dc,'QuaSOR',dc,FigName,'.tif'])

                fprintf('FINISHED!\n');
                
            else
                for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
                    SigLabel=[num2str(round(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas_nm(z)*10)/10)];
                    if ~any(strfind(SigLabel,'.'))
                        SigLabel=[SigLabel,'.0'];
                    end
                    for x=1:length(QuaSOR_Map_Settings.ContrastEnhancements)
                        ContLabel=[num2str(round(double(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).MaxValue_Cont)*10)/10)];

                        FigName=[QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_H_Sig',SigLabel,'nm_Max',ContLabel];
                        fprintf(['Exporting: ',FigName,' Figures...']);

                        imwrite(double(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap),[FigureScratchDir,dc,'AutoContMaps',dc,QuaSOR_Maps.Modality(Mod).Label,dc,'QuaSOR',dc,FigName,'.tif'])

                        figure('name',FigName)
                        imshow(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap)
                        hold on;        
                        if IbIs
                            for BoutonCount=1:length(QuaSOR_Map_Settings.BoutonArray)
                                for j=1:length(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine)
                                    plot(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                                        QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                                        '-','color',BoutonArray(BoutonCount).Color,'linewidth',1)
                                end
                            end
                        else
                            for j=1:length(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine)
                                plot(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                                    QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                                    '-','color',QuaSOR_Map_Settings.ExportBorderColor,'linewidth',QuaSOR_Map_Settings.QuaSOR_BorderLine_Width)
                            end
                        end
                        plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',QuaSOR_Map_Settings.QuaSOR_BorderLine_Width);
                        set(gcf, 'color', 'white');
                        set(gca,'XTick', []); set(gca,'YTick', []);
                        set(gca,'units','normalized','position',[0,0,1,1])
                        pause(1)
                        set(gcf,'units','pixels','position',[ScreenSize(3)+100,ScreenSize(4)+100,...
                            round(QuaSOR_Map_Settings.QuaSOR_PixelSizeScalar*QuaSOR_Maps.QuaSOR_ImageWidth),round(QuaSOR_Map_Settings.QuaSOR_PixelSizeScalar*QuaSOR_Maps.QuaSOR_ImageWidth)])
                        Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'AutoContMaps',dc,QuaSOR_Maps.Modality(Mod).Label,dc,'QuaSOR',dc, FigName, ' Bord'],3)
                        %And just Color Image
                        FigName=[QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_C_Sig',SigLabel,'nm_Max',ContLabel];            
                        imwrite(double(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color),[FigureScratchDir,dc,'AutoContMaps',dc,QuaSOR_Maps.Modality(Mod).Label,dc,'QuaSOR',dc,FigName,'.tif'])

                        fprintf('FINISHED!\n');
                    end
                    close all
                end
            end
        end
        warning on
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        disp('======================================')
        disp('Exporting QuaSOR vs PixelMax Images...')
        if size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1
            warning off
            SigLabel=[num2str(round(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas_nm(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex)*10)/10)];
            if ~any(strfind(SigLabel,'.'))
                SigLabel=[SigLabel,'.0'];
            end
            ContLabel=[num2str(round(double(QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Overlay_ContrastIndex).MaxValue_Cont)*10)/10)];

            FigName=['AllCoords_QuaSOR_H_Sig',SigLabel,'nm_Max',ContLabel];
            FigName2=['AllCoords_QuaSOR_C_Sig',SigLabel,'nm_Max',ContLabel];            
            FigName2a=['AllCoords_QuaSOR_H_Sig',SigLabel,'nm_Max',ContLabel];            
            FigName3=['AllCoords_QuaSOR_HC_Sig',SigLabel,'nm_Max',ContLabel];
            FigName3a=['AllCoords_QuaSOR_CC_Sig',SigLabel,'nm_Max',ContLabel];

            SigLabel=[num2str(round(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas_nm(PixelMax_Map_Settings.PixelMax_Overlay_FilterIndex)*10)/10)];
            if ~any(strfind(SigLabel,'.'))
                SigLabel=[SigLabel,'.0'];
            end
            ContLabel=[num2str(round(double(PixelMax_Maps.HighRes_Maps(PixelMax_Map_Settings.PixelMax_Overlay_FilterIndex).ContrastedOutputImages(PixelMax_Map_Settings.PixelMax_Overlay_ContrastIndex).MaxValue_Cont)*10)/10)];
            FigName=[FigName,'_v_PixelMax_Sig',SigLabel,'nm_Max',ContLabel];
            FigName2b=['AllCoords_PixelMax_C_Sig',SigLabel,'nm_Max',ContLabel];            
            FigName2c=['AllCoords_PixelMax_H_Sig',SigLabel,'nm_Max',ContLabel];            
            FigName3=[FigName3,'_v_PixelMax_Sig',SigLabel,'nm_Max',ContLabel];
            FigName3a=[FigName3a,'_v_PixelMax_Sig',SigLabel,'nm_Max',ContLabel];

            fprintf(['Exporting: ',FigName,' Figures...']);
            imwrite(double(QuaSOR_vs_PixelMax_Maps.PixelMax_Image),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName,'.tif'])

            figure('name',FigName)
            imshow(QuaSOR_vs_PixelMax_Maps.PixelMax_Image)
            hold on;         
            if IbIs
                for BoutonCount=1:length(QuaSOR_Map_Settings.BoutonArray)
                    for j=1:length(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine)
                        plot(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                            '-','color',BoutonArray(BoutonCount).Color,'linewidth',1)
                    end
                end
            else
                for j=1:length(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine)
                    plot(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                        '-','color',QuaSOR_Map_Settings.ExportBorderColor,'linewidth',QuaSOR_Map_Settings.QuaSOR_BorderLine_Width)
                end
            end
            plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',QuaSOR_Map_Settings.QuaSOR_BorderLine_Width);
            set(gcf, 'color', 'white');
            set(gca,'XTick', []); set(gca,'YTick', []);
            set(gca,'units','normalized','position',[0,0,1,1])
            pause(1)
            set(gcf,'units','pixels','position',[ScreenSize(3)+100,ScreenSize(4)+100,...
                round(QuaSOR_Map_Settings.QuaSOR_PixelSizeScalar*QuaSOR_Maps.QuaSOR_ImageWidth),round(QuaSOR_Map_Settings.QuaSOR_PixelSizeScalar*QuaSOR_Maps.QuaSOR_ImageWidth)])
            Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc, FigName, ' Bord'],3)
            fprintf('FINISHED!\n');

            %And just Color Image
            fprintf(['Exporting: ',FigName2,' Figure...']);
            imwrite(double(QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Color),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName2,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName2a,' Figure...']);
            imwrite(double(QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Heatmap),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName2a,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName2b,' Figure...']);
            imwrite(double(PixelMax_Resize_Image_Color),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName2b,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName2c,' Figure...']);
            imwrite(double(PixelMax_Resize_Image_HeatMap),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName2c,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName3,' Figure...']);
            imwrite(double(QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithHeatMaps),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName3,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName3a,' Figure...']);
            imwrite(double(QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithColors),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName3a,'.tif'])
            fprintf('FINISHED!\n');


            %And Save To Pooled Dir

        else
           warning('Not exporting any images because no events...') 
           warning('Not exporting any images because no events...') 
           warning('Not exporting any images because no events...') 
           warning('Not exporting any images because no events...') 
           warning('Not exporting any images because no events...') 

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        disp('======================================')
        disp('Exporting QuaSOR vs QuaSOR_LowRes Images...')
        if size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1
            warning off
            SigLabel=[num2str(round(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas_nm(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex)*10)/10)];
            if ~any(strfind(SigLabel,'.'))
                SigLabel=[SigLabel,'.0'];
            end
            ContLabel=[num2str(round(double(QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Overlay_ContrastIndex).MaxValue_Cont)*10)/10)];

            FigName=['AllCoords_QuaSOR_H_Sig',SigLabel,'nm_Max',ContLabel];
            FigName2=['AllCoords_QuaSOR_C_Sig',SigLabel,'nm_Max',ContLabel];            
            FigName2a=['AllCoords_QuaSOR_H_Sig',SigLabel,'nm_Max',ContLabel];            
            FigName3=['AllCoords_QuaSOR_HC_Sig',SigLabel,'nm_Max',ContLabel];
            FigName3a=['AllCoords_QuaSOR_CC_Sig',SigLabel,'nm_Max',ContLabel];

            SigLabel=[num2str(round(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Gaussian_Filter_Sigmas_nm(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Overlay_FilterIndex)*10)/10)];
            if ~any(strfind(SigLabel,'.'))
                SigLabel=[SigLabel,'.0'];
            end
            ContLabel=[num2str(round(double(QuaSOR_LowRes_Maps.HighRes_Maps(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_LowRes_Map_Settings.QuaSOR_LowRes_Overlay_ContrastIndex).MaxValue_Cont)*10)/10)];
            FigName=[FigName,'_v_QuaSOR_LowRes_Sig',SigLabel,'nm_Max',ContLabel];
            FigName2b=['AllCoords_QuaSOR_LowRes_C_Sig',SigLabel,'nm_Max',ContLabel];            
            FigName2c=['AllCoords_QuaSOR_LowRes_H_Sig',SigLabel,'nm_Max',ContLabel];            
            FigName3=[FigName3,'_v_QuaSOR_LowRes_Sig',SigLabel,'nm_Max',ContLabel];
            FigName3a=[FigName3a,'_v_QuaSOR_LowRes_Sig',SigLabel,'nm_Max',ContLabel];

            fprintf(['Exporting: ',FigName,' Figures...']);
            imwrite(double(QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName,'.tif'])

            figure('name',FigName)
            imshow(QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image)
            hold on;         
            if IbIs
                for BoutonCount=1:length(QuaSOR_Map_Settings.BoutonArray)
                    for j=1:length(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine)
                        plot(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                            '-','color',BoutonArray(BoutonCount).Color,'linewidth',1)
                    end
                end
            else
                for j=1:length(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine)
                    plot(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                        '-','color',QuaSOR_Map_Settings.ExportBorderColor,'linewidth',QuaSOR_Map_Settings.QuaSOR_BorderLine_Width)
                end
            end
            plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',QuaSOR_Map_Settings.QuaSOR_BorderLine_Width);
            set(gcf, 'color', 'white');
            set(gca,'XTick', []); set(gca,'YTick', []);
            set(gca,'units','normalized','position',[0,0,1,1])
            pause(1)
            set(gcf,'units','pixels','position',[ScreenSize(3)+100,ScreenSize(4)+100,...
                round(QuaSOR_Map_Settings.QuaSOR_PixelSizeScalar*QuaSOR_Maps.QuaSOR_ImageWidth),round(QuaSOR_Map_Settings.QuaSOR_PixelSizeScalar*QuaSOR_Maps.QuaSOR_ImageWidth)])
            Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc, FigName, ' Bord'],3)
            fprintf('FINISHED!\n');

            %And just Color Image
            fprintf(['Exporting: ',FigName2,' Figure...']);
            imwrite(double(QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Color),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName2,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName2a,' Figure...']);
            imwrite(double(QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Overlay_ContrastIndex).QuaSOR_Image_Heatmap),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName2a,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName2b,' Figure...']);
            imwrite(double(QuaSOR_LowRes_Resize_Image_Color),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName2b,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName2c,' Figure...']);
            imwrite(double(QuaSOR_LowRes_Resize_Image_HeatMap),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName2c,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName3,' Figure...']);
            imwrite(double(QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithHeatMaps),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName3,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName3a,' Figure...']);
            imwrite(double(QuaSOR_vs_QuaSOR_LowRes_Maps.QuaSOR_LowRes_Image_WithColors),[FigureScratchDir,dc,'AutoContMaps',dc,'AllCoords',dc,'ResComp',dc,FigName3a,'.tif'])
            fprintf('FINISHED!\n');


            %And Save To Pooled Dir

        else
           warning('Not exporting any images because no events...') 
           warning('Not exporting any images because no events...') 
           warning('Not exporting any images because no events...') 
           warning('Not exporting any images because no events...') 
           warning('Not exporting any images because no events...') 

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        disp('======================================')
        disp('Exporting QuaSOR Modality Overlay Images...')
        if size(QuaSOR_Data.All_Location_Coords_byOverallFrame,1)>1
            warning off
            Mod=1;
            SigLabel=[num2str(round(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas_nm(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_FilterIndex)*10)/10)];
            if ~any(strfind(SigLabel,'.'))
                SigLabel=[SigLabel,'.0'];
            end
            ContLabel=[num2str(round(double(QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_ContrastIndices(Mod)).MaxValue_Cont)*10)/10)];
            FigName=[QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_H_Sig',SigLabel,'nm_Max',ContLabel];
            FigName2=[QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_C_Sig',SigLabel,'nm_Max',ContLabel];            
            FigName2a=[QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_H_Sig',SigLabel,'nm_Max',ContLabel];            
            FigName3=[QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_HC_Sig',SigLabel,'nm_Max',ContLabel];
            FigName3a=[QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_CC_Sig',SigLabel,'nm_Max',ContLabel];
            Mod=2;
            SigLabel=[num2str(round(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas_nm(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_FilterIndex)*10)/10)];
            if ~any(strfind(SigLabel,'.'))
                SigLabel=[SigLabel,'.0'];
            end
            ContLabel=[num2str(round(double(QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_ContrastIndices(Mod)).MaxValue_Cont)*10)/10)];
            FigName=[FigName,'_v_',QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_Sig',SigLabel,'nm_Max',ContLabel];
            FigName2b=[QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_C_Sig',SigLabel,'nm_Max',ContLabel];            
            FigName2c=[QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_H_Sig',SigLabel,'nm_Max',ContLabel];            
            FigName3=[FigName3,'_v_',QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_Sig',SigLabel,'nm_Max',ContLabel];
            FigName3a=[FigName3a,'_v_',QuaSOR_Maps.Modality(Mod).Label,'_QuaSOR_Sig',SigLabel,'nm_Max',ContLabel];

            fprintf(['Exporting: ',FigName,' Figures...']);
            imwrite(double(QuaSOR_Modality_Overlay_Maps.QuaSOR_Image),[FigureScratchDir,dc,'AutoContMaps',dc,'ModOver',dc,FigName,'.tif'])

            figure('name',FigName)
            imshow(QuaSOR_Modality_Overlay_Maps.QuaSOR_Image)
            hold on;         
            if IbIs
                for BoutonCount=1:length(QuaSOR_Map_Settings.BoutonArray)
                    for j=1:length(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine)
                        plot(QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            QuaSOR_Map_Settings.BoutonArray(BoutonCount).QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                            '-','color',BoutonArray(BoutonCount).Color,'linewidth',1)
                    end
                end
            else
                for j=1:length(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine)
                    plot(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                        '-','color',QuaSOR_Map_Settings.ExportBorderColor,'linewidth',QuaSOR_Map_Settings.QuaSOR_BorderLine_Width)
                end
            end
            plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',QuaSOR_Map_Settings.QuaSOR_BorderLine_Width);
            set(gcf, 'color', 'white');
            set(gca,'XTick', []); set(gca,'YTick', []);
            set(gca,'units','normalized','position',[0,0,1,1])
            pause(1)
            set(gcf,'units','pixels','position',[ScreenSize(3)+100,ScreenSize(4)+100,...
                round(QuaSOR_Map_Settings.QuaSOR_PixelSizeScalar*QuaSOR_Maps.QuaSOR_ImageWidth),round(QuaSOR_Map_Settings.QuaSOR_PixelSizeScalar*QuaSOR_Maps.QuaSOR_ImageWidth)])
            Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'AutoContMaps',dc,'ModOver',dc, FigName, ' Bord'],3)
            fprintf('FINISHED!\n');

            Mod=1;
            %And just Color Image
            fprintf(['Exporting: ',FigName2,' Figure...']);
            imwrite(double(QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_ContrastIndices(Mod)).QuaSOR_Image_Color),[FigureScratchDir,dc,'AutoContMaps',dc,'ModOver',dc,FigName2,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName2a,' Figure...']);
            imwrite(double(QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_ContrastIndices(Mod)).QuaSOR_Image_Heatmap),[FigureScratchDir,dc,'AutoContMaps',dc,'ModOver',dc,FigName2a,'.tif'])
            fprintf('FINISHED!\n');

            Mod=2;
            %And just Color Image
            fprintf(['Exporting: ',FigName2,' Figure...']);
            imwrite(double(QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_ContrastIndices(Mod)).QuaSOR_Image_Color),[FigureScratchDir,dc,'AutoContMaps',dc,'ModOver',dc,FigName2,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName2a,' Figure...']);
            imwrite(double(QuaSOR_Maps.HighRes_Maps(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_FilterIndex).ContrastedOutputImages(QuaSOR_Map_Settings.QuaSOR_Modality_Overlay_ContrastIndices(Mod)).QuaSOR_Image_Heatmap),[FigureScratchDir,dc,'AutoContMaps',dc,'ModOver',dc,FigName2a,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName3,' Figure...']);
            imwrite(double(QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithHeatMaps),[FigureScratchDir,dc,'AutoContMaps',dc,'ModOver',dc,FigName3,'.tif'])
            fprintf('FINISHED!\n');

            fprintf(['Exporting: ',FigName3a,' Figure...']);
            imwrite(double(QuaSOR_Modality_Overlay_Maps.QuaSOR_Image_WithColors),[FigureScratchDir,dc,'AutoContMaps',dc,'ModOver',dc,FigName3a,'.tif'])
            fprintf('FINISHED!\n');


            %And Save To Pooled Dir

        else
           warning('Not exporting any images because no events...') 
           warning('Not exporting any images because no events...') 
           warning('Not exporting any images because no events...') 
           warning('Not exporting any images because no events...') 
           warning('Not exporting any images because no events...') 

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    else
        warning on
        warning('NOT EXPORTING ALL IMAGES!')
        warning('NOT EXPORTING ALL IMAGES!')
        warning('NOT EXPORTING ALL IMAGES!')
        warning('NOT EXPORTING ALL IMAGES!')
        warning('NOT EXPORTING ALL IMAGES!')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    if CleanupMapRGB
        for z=1:length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas)
            for x=1:length(QuaSOR_Map_Settings.ContrastEnhancements)
                PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap=[];
                PixelMax_Maps.HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Color=[];
            end
        end
        for Mod=1:length(PixelMax_Struct.Modality)
            for z=1:length(PixelMax_Map_Settings.PixelMax_Gaussian_Filter_Sigmas)
                for x=1:length(QuaSOR_Map_Settings.ContrastEnhancements)
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Heatmap=[];
                    PixelMax_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).PixelMax_Image_Color=[];
                end
            end
        end
        for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
            for x=1:length(QuaSOR_Map_Settings.ContrastEnhancements)
                QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap=[];
                QuaSOR_Maps.HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color=[];
            end
        end
        for Mod=1:length(QuaSOR_Data.Modality)
            for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
                for x=1:length(QuaSOR_Map_Settings.ContrastEnhancements)
                    QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Heatmap=[];
                    QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).ContrastedOutputImages(x).QuaSOR_Image_Color=[];
                end
            end
        end
        QuaSOR_vs_PixelMax_Maps.PixelMax_Image=[];
        QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithHeatMaps=[];
        QuaSOR_vs_PixelMax_Maps.PixelMax_Image_WithColors=[];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    FileSuffix=['_QuaSOR_Maps.mat'];
    fprintf(['Saving... ',StackSaveName,FileSuffix,' to CurrentScratchDir...']);
    save([CurrentScratchDir,dc,StackSaveName,FileSuffix],'QuaSOR_Maps','QuaSOR_Map_Settings','QuaSOR_Modality_Overlay_Maps',...
        'QuaSOR_vs_PixelMax_Maps','PixelMax_Maps','PixelMax_Map_Settings',...
        'QuaSOR_vs_QuaSOR_LowRes_Maps','QuaSOR_LowRes_Maps','QuaSOR_LowRes_Map_Settings')
    fprintf('Finished!\n')
    fprintf(['Copying: ',StackSaveName,FileSuffix,' to SaveDir...'])
    [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
    fprintf('Finished!\n')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    fprintf('FINISHED!\n');
    OverallTime=toc(OverallTimer);
    fprintf(['Rendering and Exporting All QuaSOR Data Took: ',num2str(OverallTime/60),'min\n'])
    close all
    disp('======================================')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

end