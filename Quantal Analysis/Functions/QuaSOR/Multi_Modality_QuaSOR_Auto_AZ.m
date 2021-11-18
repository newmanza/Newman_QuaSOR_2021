function [QuaSOR_Auto_AZ,QuaSOR_Auto_AZ_Settings]=...
    Multi_Modality_QuaSOR_Auto_AZ(myPool,OS,dc,SaveName,StackSaveName,SaveDir,CurrentScratchDir,FigureScratchDir,...
    ImagingInfo,QuaSOR_Auto_AZ_Settings,QuaSOR_Map_Settings,QuaSOR_Event_Extraction_Settings,QuaSOR_Maps,QuaSOR_Data,QuaSOR_Parameters,...
    ScaleBar,ScaleBar_Upscale,MarkerSetInfo,Image_Width,Image_Height,Safe2CopyDelete)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Some other less important defaults
    ScreenSize=get(0,'ScreenSize');
    %IbIs_CoordinateAdjust=-1; %Use in conjunction with UpScale_Fix_Adjust from original mapping
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if QuaSOR_Data.Total_Coords>0
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ProgressBarOn=1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        OverallTimer=tic;
        clear QuaSOR_Auto_AZ
        disp('=======================================================================')
        disp(['QuaSOR Auto AZ Calculation Processing on: ',StackSaveName])
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
        QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_px=...
            round(QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_nm/(ScaleBar_Upscale.ScaleFactor*1000));
        QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_px=...
            round(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_um/ScaleBar_Upscale.ScaleFactor);
        QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_nm=...
            QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_um*1000;
        QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma=...
            QuaSOR_Maps.HighRes_Maps(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index).GaussianParticleSigma;
        QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size=...
            QuaSOR_Maps.HighRes_Maps(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index).GaussianParticleSize;
        QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma_nm=...
            QuaSOR_Maps.HighRes_Maps(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index).GaussianParticleSigma*(ScaleBar_Upscale.ScaleFactor*1000);
        QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size_nm=...
            QuaSOR_Maps.HighRes_Maps(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index).GaussianParticleSize*(ScaleBar_Upscale.ScaleFactor*1000);
        QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_px=...
            QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_px;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Mod=1;
        QuaSOR_Auto_AZ_Settings.Modality(Mod).Auto_AZ_Quant_ROI_Radius_px=QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_px;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Mod=2;
        QuaSOR_Auto_AZ_Settings.Modality(Mod).Auto_AZ_Quant_ROI_Radius_px=QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_px;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~exist([FigureScratchDir,dc,'AutoAZ',dc,QuaSOR_Auto_AZ_Settings.Label])
            mkdir([FigureScratchDir,dc,'AutoAZ',dc,QuaSOR_Auto_AZ_Settings.Label])
        end
        for Mod=1:length(QuaSOR_Maps.Modality)
            if ~exist([FigureScratchDir,dc,'AutoAZ',dc,QuaSOR_Auto_AZ_Settings.Modality(Mod).Label])
                mkdir([FigureScratchDir,dc,'AutoAZ',dc,QuaSOR_Auto_AZ_Settings.Modality(Mod).Label])
            end
        end
        if ~exist([FigureScratchDir,dc,'Filters'])
            mkdir([FigureScratchDir,dc,'Filters'])
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ThresholdTest_Max=[];
        %figure, 
        for zzz=1:max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)

            TestImage1=zeros(max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size),max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)*2);
            TestImage1(ceil(max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)/2),ceil(max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)/2))=1;
            TestImage1=imgaussfilt(double(TestImage1), QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma,'FilterSize',QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size);
            TestImage1=TestImage1/max(TestImage1(:));

            TestImage2=zeros(max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size),max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)*2);
            TestImage2(ceil(max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)/2),ceil(max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)/2)+zzz)=1;
            TestImage2=imgaussfilt(double(TestImage2), QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma,'FilterSize',QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size);
            TestImage2=TestImage2/max(TestImage2(:));

            TestMerge=TestImage1+TestImage2;
            ThresholdTest_Max(zzz)=max(TestMerge(:));
    %         
    %         subplot(1,1,1);
    %         imagesc(TestMerge)
    %         colorbar
    %         axis equal tight
    %         pause(0.1)
        end
        TestImage1=zeros(max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size),...
            max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)*2);
        TestImage1(ceil(max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)/2),...
            ceil(max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)/2))=1;
        TestImage1=imgaussfilt(double(TestImage1),...
            QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma,'FilterSize',QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size);
        TestImage1=TestImage1/max(TestImage1(:));
        figure, imagesc(TestImage1),axis equal tight

        TestImage2=zeros(max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size),...
            max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)*2);
        TestImage2(ceil(max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)/2),...
            ceil(max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)/2)+QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_px)=1;
        TestImage2=imgaussfilt(double(TestImage2),...
            QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma,'FilterSize',QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size);
        TestImage2=TestImage2/max(TestImage2(:));

        TestMerge=TestImage1+TestImage2([1:size(TestMerge,1)],[1:size(TestMerge,2)]);
        subplot(1,2,1);
        imagesc(TestMerge)
        axis equal tight,colorbar
        subplot(1,2,2);
        plot([1:max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size)],ThresholdTest_Max,'.-','color','k')
        hold on
        plot([QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_px,QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_px],[0,2],'-','color','r')
        ylim([0,max(ThresholdTest_Max(:))])
        ylabel('Pixel Max'),xlabel('Pixel Distance')
        set(gcf,'position',[200 200 1000 400])
        Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'Filters',dc,'QuaSOR AZ_Detect_Adaptive_Threshold'],3)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [QuaSOR_Col QuaSOR_Row] = meshgrid(1:size(QuaSOR_Maps.HighRes_Maps(1).QuaSOR_Image,2),...
            1:size(QuaSOR_Maps.HighRes_Maps(1).QuaSOR_Image,1));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for Mod=1:length(QuaSOR_Maps.Modality)
            disp('====================================================')
            disp('====================================================')
            disp('====================================================')
            disp(['Identifying AZ Locations for: ',QuaSOR_Auto_AZ_Settings.Modality(Mod).Label])
            disp(['AZ Detection Gaussian Filter Sigma = ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma),'px'])
            disp(['AZ Detection Gaussian Filter Sigma = ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma_nm),'nm'])
            disp(['AZ Detection Min_Event_Distance_px = ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_px),'px'])
            disp(['AZ Detection Min_Event_Distance_nm = ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_nm),'nm'])
            if QuaSOR_Auto_AZ_Settings.Modality(Mod).AZ_Detect_Adaptive_Threshold
                warning('Using Thresholds with Lower limit set by two events within the minimum distance...')
                disp(['Thresholds based on a filter SIZE = ',...
                    num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size),...
                        ' SIGMA = ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma)])
                disp(['AND a Minimum Event Distance of : ',...
                        num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_um),'um'])

                QuaSOR_Auto_AZ_Settings.Modality(Mod).AZ_Threshold=ThresholdTest_Max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_px);
            end
            if size(QuaSOR_Data.Modality(Mod).All_Location_Coords,1)<QuaSOR_Auto_AZ_Settings.NumEventsRevertThresh
                warning(['ONLY ',size(QuaSOR_Data.Modality(Mod).All_Location_Coords,1),' Events!'])
                warning(['ONLY ',size(QuaSOR_Data.Modality(Mod).All_Location_Coords,1),' Events!'])
                warning(['Lowering Threshold to 1 Event!'])
                warning(['Lowering Threshold to 1 Event!'])
                QuaSOR_Auto_AZ_Settings.Modality(Mod).AZ_Threshold=1;
            end
            QuaSOR_Auto_AZ.Modality(Mod).Auto_AZ_Quant_ROI_Radius_nm=QuaSOR_Auto_AZ_Settings.Modality(Mod).Auto_AZ_Quant_ROI_Radius_nm;
            QuaSOR_Auto_AZ.Modality(Mod).Auto_AZ_Quant_ROI_Radius_px=QuaSOR_Auto_AZ_Settings.Modality(Mod).Auto_AZ_Quant_ROI_Radius_px;
            disp(['AZ Fixed ROI Quant Radius Auto_AZ_Quant_ROI_Radius_px = ',num2str(QuaSOR_Auto_AZ.Modality(Mod).Auto_AZ_Quant_ROI_Radius_px),'px'])
            disp(['AZ Fixed ROI Quant Radius Auto_AZ_Quant_ROI_Radius_nm = ',num2str(QuaSOR_Auto_AZ.Modality(Mod).Auto_AZ_Quant_ROI_Radius_nm),'nm'])
            disp(['Max Auto Match Distance AutoMatch_AZ_Max_Dist_nm = ',num2str(QuaSOR_Auto_AZ_Settings.AutoMatch_AZ_Max_Dist_nm),'nm'])
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if size(QuaSOR_Data.Modality(Mod).All_Location_Coords,1)>0
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                switch QuaSOR_Auto_AZ_Settings.Auto_Detect_Method
                    case 1
                        QuaSOR_Auto_AZ.Modality(Mod).AZ_ThresholdMask = ...
                            imextendedmax(QuaSOR_Maps.Modality(Mod).HighRes_Maps(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index).QuaSOR_Image,...
                            QuaSOR_Auto_AZ_Settings.Modality(Mod).AZ_Threshold);
                    case 2
                        MaskedImage=QuaSOR_Maps.Modality(Mod).HighRes_Maps(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index).QuaSOR_Image;
                        MaskedImage(MaskedImage<QuaSOR_Auto_AZ_Settings.Modality(Mod).AZ_Threshold)=0;
                        QuaSOR_Auto_AZ.Modality(Mod).AZ_ThresholdMask=imregionalmax(MaskedImage);
                end
                Temp_AZ_Site_Props=...
                    regionprops(QuaSOR_Auto_AZ.Modality(Mod).AZ_ThresholdMask,...
                    'centroid','area','BoundingBox','Perimeter');
                disp(['AZ Threshold ',num2str(QuaSOR_Auto_AZ_Settings.Modality(Mod).AZ_Threshold),...
                    ' Preliminary Num Sites: ',num2str(size(Temp_AZ_Site_Props,1))])
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                disp(['Checking AZ Distances with minimum distance of ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_AZ_Distance_um),'um'])
                TestImage=QuaSOR_Maps.Modality(Mod).HighRes_Maps(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index).QuaSOR_Image;
                AZ_Detect_Min_AZ_Distance_px=round(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_AZ_Distance_um/ScaleBar_Upscale.ScaleFactor);
                PrelimNumAZ=size(Temp_AZ_Site_Props,1);
                Temp_All_AZ_Distances=zeros(PrelimNumAZ);
                Temp_All_AZ_Distances(Temp_All_AZ_Distances==0)=NaN;
                for z=1:PrelimNumAZ
                    Temp_AZ_Site_Props(z).Delete=0;
                end
                for i=1:PrelimNumAZ
                    for j=i+1:PrelimNumAZ
                        if i~=j
                            Coord1=Temp_AZ_Site_Props(i).Centroid;
                            Coord2=Temp_AZ_Site_Props(j).Centroid;
                            Temp_All_AZ_Distances(i,j)=sqrt((Coord1(1)-Coord2(1))^2+(Coord1(2)-Coord2(2))^2);
                        end
                    end
                end
                figure, imagesc(Temp_All_AZ_Distances), axis equal tight, colormap('jet'),colorbar
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [Flagged1,Flagged2]=find(Temp_All_AZ_Distances<AZ_Detect_Min_AZ_Distance_px);
                if ~isempty(Flagged1)
                    warning(['Found ',num2str(length(Flagged1)),' Potential Pairs that are too close!'])
                    for i=1:length(Flagged1)
                        Value1=TestImage(round(Temp_AZ_Site_Props(Flagged1(i)).Centroid(2)),...
                            round(Temp_AZ_Site_Props(Flagged1(i)).Centroid(1)));
                        Value2=TestImage(round(Temp_AZ_Site_Props(Flagged2(i)).Centroid(2)),...
                            round(Temp_AZ_Site_Props(Flagged2(i)).Centroid(1)));
                        if Value1>Value2
                            Temp_AZ_Site_Props(Flagged2(i)).Delete=1;
                        elseif Value2>Value1
                            Temp_AZ_Site_Props(Flagged1(i)).Delete=1;
                        elseif Value1==Value2
                            Temp_AZ_Site_Props(Flagged1(i)).Delete=1;
                        end
                    end
                end
                AZ_Count=0;
                Temp_AZ_Site_Props_Fixed=[];
                for z=1:PrelimNumAZ
                    if ~Temp_AZ_Site_Props(z).Delete
                        AZ_Count=AZ_Count+1;
                       Temp_AZ_Site_Props_Fixed(AZ_Count,1).Centroid=Temp_AZ_Site_Props(z).Centroid;
                    end
                end
                All_AZ_Distances=zeros(AZ_Count);
                All_AZ_Distances(All_AZ_Distances==0)=NaN;
                for z=1:PrelimNumAZ
                    AZ_Site_Props(z).Delete=0;
                end
                for i=1:AZ_Count
                    for j=i+1:AZ_Count
                        if i~=j
                            Coord1=Temp_AZ_Site_Props_Fixed(i).Centroid;
                            Coord2=Temp_AZ_Site_Props_Fixed(j).Centroid;
                            All_AZ_Distances(i,j)=sqrt((Coord1(1)-Coord2(1))^2+(Coord1(2)-Coord2(2))^2);
                        end
                    end
                end
                figure, imagesc(All_AZ_Distances), axis equal tight, colormap('jet'),colorbar
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                QuaSOR_Auto_AZ.Modality(Mod).Auto_Detect_Method=QuaSOR_Auto_AZ_Settings.Auto_Detect_Method;
                QuaSOR_Auto_AZ.Modality(Mod).AZ_Detect_Min_Event_Distance_um=QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_um;
                QuaSOR_Auto_AZ.Modality(Mod).AZ_Detect_Min_Event_Distance_px=QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_px;
                QuaSOR_Auto_AZ.Modality(Mod).AZ_Detect_Gaussian_Index=QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index;
                QuaSOR_Auto_AZ.Modality(Mod).AZ_Detect_Gaussian_Sigma=QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma;
                QuaSOR_Auto_AZ.Modality(Mod).AZ_Detect_Gaussian_Size=QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size;
                QuaSOR_Auto_AZ.Modality(Mod).AZ_Detect_Min_AZ_Distance_um=QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_AZ_Distance_um;
                QuaSOR_Auto_AZ.Modality(Mod).AZ_Detect_Color=QuaSOR_Auto_AZ_Settings.AZ_Detect_Color;
                QuaSOR_Auto_AZ.Modality(Mod).AZ_Threshold=QuaSOR_Auto_AZ_Settings.Modality(Mod).AZ_Threshold;
                QuaSOR_Auto_AZ.Modality(Mod).ThresholdTest_Max=ThresholdTest_Max;
                QuaSOR_Auto_AZ.Modality(Mod).PrelimNumAZ=PrelimNumAZ;
                QuaSOR_Auto_AZ.Modality(Mod).AZ_Count=AZ_Count;
                QuaSOR_Auto_AZ.Modality(Mod).All_AZ_Distances=All_AZ_Distances;
                QuaSOR_Auto_AZ.Modality(Mod).AZ_Site_Props=Temp_AZ_Site_Props_Fixed;
                QuaSOR_Auto_AZ.Modality(Mod).AZ_Detect_Adaptive_Threshold=QuaSOR_Auto_AZ_Settings.Modality(Mod).AZ_Detect_Adaptive_Threshold;
                disp(['AZ Threshold ',num2str(QuaSOR_Auto_AZ_Settings.Modality(Mod).AZ_Threshold),...
                    ' Minimum Distance of ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_AZ_Distance_um),'um',...
                    ' Num Sites: ',num2str(size(QuaSOR_Auto_AZ.Modality(Mod).AZ_Site_Props,1))])
                QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct=[];
                QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.AZ_AutoMask_Sum=...
                    uint16(zeros(size(QuaSOR_Maps.Modality(Mod).HighRes_Maps(1).QuaSOR_Image)));
                progressbar('Generating AZ Struct...')
                for AZ=1:size(QuaSOR_Auto_AZ.Modality(Mod).AZ_Site_Props,1)
                    QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct(AZ).Coord=QuaSOR_Auto_AZ.Modality(Mod).AZ_Site_Props(AZ).Centroid;
                    QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct(AZ).Coord_Round=round(QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct(AZ).Coord);
                    TempRegion =    (QuaSOR_Row - QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct(AZ).Coord_Round(2)).^2 + ...
                        (QuaSOR_Col - QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct(AZ).Coord_Round(1)).^2 <= ...
                        QuaSOR_Auto_AZ.Modality(Mod).Auto_AZ_Quant_ROI_Radius_px.^2;
                    QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.AZ_AutoMask_Sum=...
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.AZ_AutoMask_Sum+uint16(TempRegion);
                    TempRegion_Props=regionprops(TempRegion,'PixelList');
                    QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct(AZ).PixelList=TempRegion_Props.PixelList;
                    clear TempRegion_Props
                    progressbar(AZ/size(QuaSOR_Auto_AZ.Modality(Mod).AZ_Site_Props,1))
                end
                figure
                imshow(QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.AZ_AutoMask_Sum,[])
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant_FixedROI.Quant_Modality=[];
                QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality=[];
                for QuantMod=1:length(QuaSOR_Data.Modality)
                    for AZ=1:size(QuaSOR_Auto_AZ.Modality(Mod).AZ_Site_Props,1)
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).Coord=QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct(AZ).Coord;
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).Coord_Round=QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct(AZ).Coord_Round;
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).EventCount=0;
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords=[];
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords_byEpisodeNum=[];
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords_byOverallFrame=[];
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords_byOverallStim=[];
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Amps=[];
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Max_DeltaFF0=[];

                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).Coord=QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct(AZ).Coord;
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).Coord_Round=QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct(AZ).Coord_Round;
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).EventCount=0;
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords=[];
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords_byEpisodeNum=[];
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords_byOverallFrame=[];
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords_byOverallStim=[];
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Amps=[];
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Max_DeltaFF0=[];
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for QuantMod=1:length(QuaSOR_Data.Modality)
                    if ~isempty(QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byOverallFrame)
                        fprintf(['AZ Mod# ',num2str(Mod),...
                            ' Quant Mod# ',num2str(QuantMod),' FIXED ROI Radius ',num2str(QuaSOR_Auto_AZ.Modality(Mod).Auto_AZ_Quant_ROI_Radius_nm),'nm...'])
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if ~strcmp(OS,'MACI64')
                            ppm = ParforProgMon(['AZ Mod# ',num2str(Mod),...
                                ' Quant Mod# ',num2str(QuantMod),' Radius ',num2str(QuaSOR_Auto_AZ.Modality(Mod).Auto_AZ_Quant_ROI_Radius_nm),'nm | FIXED ROI'], length(QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct), 1, 1000, 80);
                        else
                            ppm = 0;
                        end
                        %progressbar('Radius','AZ')
                        clear TempAZStruct All_Location_Coords_byEpisodeNum All_Location_Coords_byOverallFrame All_Location_Coords_byOverallStimQuaSOR_Data
                        TempAZStruct=QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct;
                        for AZ=1:length(TempAZStruct)
                            TempAZStruct(AZ).PixelList=QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct(AZ).PixelList;
                        end
                        All_Location_Coords=QuaSOR_Data.Modality(QuantMod).All_Location_Coords;
                        All_Location_Coords_byEpisodeNum=QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byEpisodeNum;
                        All_Location_Coords_byOverallFrame=QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byOverallFrame;
                        All_Location_Coords_byOverallStim=QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byOverallStim;
                        All_Location_Amps=QuaSOR_Data.Modality(QuantMod).All_Location_Amps;
                        All_Max_DeltaFF0=QuaSOR_Data.Modality(QuantMod).All_Max_DeltaFF0;
                        parfor AZ=1:length(TempAZStruct)
                            for p=1:size(TempAZStruct(AZ).PixelList,1)
                                for e=1:size(All_Location_Coords_byOverallFrame,1)
                                    TempCoord=All_Location_Coords_byOverallFrame(e,1:2)*QuaSOR_Map_Settings.QuaSOR_UpScaleFactor;
                                    TempCoord=round(TempCoord);
                                    if TempCoord(1)==TempAZStruct(AZ).PixelList(p,2)&&...
                                        TempCoord(2)==TempAZStruct(AZ).PixelList(p,1)
                                        TempAZStruct(AZ).EventCount=TempAZStruct(AZ).EventCount+1;
                                        TempAZStruct(AZ).All_Location_Coords=vertcat(...
                                            TempAZStruct(AZ).All_Location_Coords,...
                                            All_Location_Coords(e,:));
                                        TempAZStruct(AZ).All_Location_Coords_byEpisodeNum=vertcat(...
                                            TempAZStruct(AZ).All_Location_Coords_byEpisodeNum,...
                                            All_Location_Coords_byEpisodeNum(e,:));
                                        TempAZStruct(AZ).All_Location_Coords_byOverallFrame=vertcat(...
                                            TempAZStruct(AZ).All_Location_Coords_byOverallFrame,...
                                            All_Location_Coords_byOverallFrame(e,:));
                                        TempAZStruct(AZ).All_Location_Coords_byOverallStim=vertcat(...
                                            TempAZStruct(AZ).All_Location_Coords_byOverallStim,...
                                            All_Location_Coords_byOverallStim(e,:));
                                        TempAZStruct(AZ).All_Location_Amps=horzcat(...
                                            TempAZStruct(AZ).All_Location_Amps,...
                                            All_Location_Amps(e));
                                        TempAZStruct(AZ).All_Max_DeltaFF0=horzcat(...
                                            TempAZStruct(AZ).All_Max_DeltaFF0,...
                                            All_Max_DeltaFF0(e));
                                    end
                                end
                            end
                            if ~strcmp(OS,'MACI64')
                                ppm.increment();
                            end
                        end
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct=TempAZStruct;
                        clear TempAZStruct
                        fprintf('Finished!\n')
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for QuantMod=1:length(QuaSOR_Data.Modality)
                    if ~isempty(QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byOverallFrame)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        fprintf(['AZ Mod# ',num2str(Mod),...
                            ' Quant Mod# ',num2str(QuantMod),' Nearest AZ Match...\n'])
                        TempAZStruct=QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct;
                        All_Location_Coords=QuaSOR_Data.Modality(QuantMod).All_Location_Coords;
                        All_Location_Coords_byEpisodeNum=QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byEpisodeNum;
                        All_Location_Coords_byOverallFrame=QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byOverallFrame;
                        All_Location_Coords_byOverallStim=QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byOverallStim;
                        All_Location_Amps=QuaSOR_Data.Modality(QuantMod).All_Location_Amps;
                        All_Max_DeltaFF0=QuaSOR_Data.Modality(QuantMod).All_Max_DeltaFF0;
                        QuaSOR_AZ_Coord_List=[];
                        for AZ=1:length(TempAZStruct)
                            QuaSOR_AZ_Coord_List=vertcat(QuaSOR_AZ_Coord_List,TempAZStruct.Coord_Round);
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        BestPairs=zeros(length(All_Location_Coords_byOverallFrame),10);
                        Temp_QuaSOR_Coords=[...
                            All_Location_Coords_byOverallFrame(:,2),...
                            All_Location_Coords_byOverallFrame(:,1)];
                        Temp_QuaSOR_Coords=Temp_QuaSOR_Coords*QuaSOR_Map_Settings.QuaSOR_UpScaleFactor;
                        Temp_QuaSOR_Coords_Refined=[];
                        All_Location_Coords_Refined=[];
                        All_Location_Coords_byEpisodeNum_Refined=[];
                        All_Location_Coords_byOverallFrame_Refined=[];
                        All_Location_Coords_byOverallStim_Refined=[];
                        All_Location_Amps_Refined=[];
                        All_Max_DeltaFF0_Refined=[];
                        for i=1:size(Temp_QuaSOR_Coords,1)
                            TempRefine=0;
                            TempCoord=Temp_QuaSOR_Coords(i,:);
                            TempCoord=round(TempCoord);
                            if ~any(TempCoord<=0)&&TempCoord(2)<=size(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,1)&&TempCoord(1)<=size(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,2)
                                if QuaSOR_Map_Settings.QuaSOR_Bouton_Mask(TempCoord(2),TempCoord(1))
                                    TempRefine=1;
                                end
            %                                 for k=1:length(QuaSOR_Refining_ROIs.QuaSOR_Exclusion)
            %                                     if QuaSOR_Refining_ROIs.QuaSOR_Exclusion(k).ImageArea(TempCoord(2),TempCoord(1))
            %                                         TempRefine=0;
            %                                     end
            %                                 end
                                if TempRefine
                                    Temp_QuaSOR_Coords_Refined=vertcat(Temp_QuaSOR_Coords_Refined,Temp_QuaSOR_Coords(i,:));
                                    All_Location_Coords_Refined=vertcat(All_Location_Coords_Refined,All_Location_Coords(i,:));
                                    All_Location_Coords_byEpisodeNum_Refined=vertcat(All_Location_Coords_byEpisodeNum_Refined,All_Location_Coords_byEpisodeNum(i,:));
                                    All_Location_Coords_byOverallFrame_Refined=vertcat(All_Location_Coords_byOverallFrame_Refined,All_Location_Coords_byOverallFrame(i,:));
                                    All_Location_Coords_byOverallStim_Refined=vertcat(All_Location_Coords_byOverallStim_Refined,All_Location_Coords_byOverallStim(i,:));
                                    All_Location_Amps_Refined=horzcat(All_Location_Amps_Refined,All_Location_Amps(i));
                                    All_Max_DeltaFF0_Refined=horzcat(All_Max_DeltaFF0_Refined,All_Max_DeltaFF0(i));
                                end
                                clear TempRefine
                            else
                            end
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        figure,
                        plot(Temp_QuaSOR_Coords(:,1),Temp_QuaSOR_Coords(:,2),'.','color','r','markersize',8)
                        hold on
                        plot(Temp_QuaSOR_Coords_Refined(:,1),Temp_QuaSOR_Coords_Refined(:,2),'.','color','g','markersize',12)
                        hold on
                        plot(QuaSOR_AZ_Coord_List(:,1),QuaSOR_AZ_Coord_List(:,2),'o','color','m','markersize',4)
                        set(gca,'ydir','reverse')
                        axis equal tight
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Total_Num_Coords=size(Temp_QuaSOR_Coords,1);
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Input_Coords=Temp_QuaSOR_Coords;
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_Coords=Temp_QuaSOR_Coords_Refined;
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_Num_Coords=size(Temp_QuaSOR_Coords_Refined,1);
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_Percent=...
                            QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_Num_Coords/...
                            QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Total_Num_Coords;
                        [QuaSORIndex2Match,QuaSORIndex2MatchDist_px]=dsearchn(QuaSOR_AZ_Coord_List,Temp_QuaSOR_Coords_Refined);
                        QuaSORIndex2MatchDist_nm=QuaSORIndex2MatchDist_px*(ScaleBar_Upscale.ScaleFactor*1000);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        figure, 
                        title(['Mod ',num2str(QuantMod)])
                        subplot(1,2,1)
                        hist(QuaSORIndex2MatchDist_px);
                        xlabel('Pixel Distance')
                        subplot(1,2,2)
                        hist(QuaSORIndex2MatchDist_nm);
                        xlabel('nm distance')
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_DistMatrix_nm=QuaSORIndex2MatchDist_nm;
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_Dist_Mean_nm=mean(QuaSORIndex2MatchDist_nm);
                        disp(['Mod ',num2str(QuantMod),' Mean AZ Distance (nm) = ',...
                            num2str(round(QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_Dist_Mean_nm))])
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AllDistances2AZ_px=QuaSORIndex2MatchDist_px;
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AllDistances2AZ_nm=QuaSORIndex2MatchDist_nm;
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).QuaSORIndex2Match=QuaSORIndex2Match;
                        if size(QuaSORIndex2Match,1)~=size(All_Location_Coords_byOverallFrame_Refined,1)
                            error('Matching Mismatch')
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        progressbar('Sorting all events...')
                        Temp_QuaSOR_Coords_Matched=[];
                        for e=1:size(QuaSORIndex2Match,1)
                            TempAZ=QuaSORIndex2Match(e);
                            if ~isempty(TempAZ)&&QuaSORIndex2MatchDist_nm(e)<QuaSOR_Auto_AZ_Settings.AutoMatch_AZ_Max_Dist_nm
                                TempAZStruct(TempAZ).EventCount=TempAZStruct(TempAZ).EventCount+1;
                                TempAZStruct(TempAZ).All_Location_Coords=vertcat(...
                                    TempAZStruct(TempAZ).All_Location_Coords,...
                                    All_Location_Coords_Refined(e,:));
                                TempAZStruct(TempAZ).All_Location_Coords_byEpisodeNum=vertcat(...
                                    TempAZStruct(TempAZ).All_Location_Coords_byEpisodeNum,...
                                    All_Location_Coords_byEpisodeNum_Refined(e,:));
                                TempAZStruct(TempAZ).All_Location_Coords_byOverallFrame=vertcat(...
                                    TempAZStruct(TempAZ).All_Location_Coords_byOverallFrame,...
                                    All_Location_Coords_byOverallFrame_Refined(e,:));
                                TempAZStruct(TempAZ).All_Location_Coords_byOverallStim=vertcat(...
                                    TempAZStruct(TempAZ).All_Location_Coords_byOverallStim,...
                                    All_Location_Coords_byOverallStim_Refined(e,:));
                                Temp_QuaSOR_Coords_Matched=vertcat(...
                                    Temp_QuaSOR_Coords_Matched,...
                                    Temp_QuaSOR_Coords_Refined(e,:));
                                TempAZStruct(TempAZ).All_Location_Amps=horzcat(...
                                    TempAZStruct(TempAZ).All_Location_Amps,...
                                    All_Location_Amps_Refined(e));
                                TempAZStruct(TempAZ).All_Max_DeltaFF0=horzcat(...
                                    TempAZStruct(TempAZ).All_Max_DeltaFF0,...
                                    All_Max_DeltaFF0_Refined(e));
                            else
                                warning(['Did not match event ',num2str(e),' ',num2str(QuaSORIndex2MatchDist_nm(e)),'nm'])
                            end
                            progressbar(e/size(QuaSORIndex2Match,1))
                        end
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct=TempAZStruct;
                        clear TempAZStruct
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Matched_Coords=Temp_QuaSOR_Coords_Matched;
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Matched_Num_Coords=size(Temp_QuaSOR_Coords_Matched,1);
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Matched_Percent=...
                            QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Matched_Num_Coords/...
                            QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Total_Num_Coords;
                        disp(['Mod ',num2str(QuantMod),' # Coords = ',...
                            num2str(QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Total_Num_Coords)])
                        disp(['Mod ',num2str(QuantMod),' # Refine Coords = ',...
                            num2str(QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Matched_Num_Coords)])
                        disp(['Mod ',num2str(QuantMod),' % Refined = ',...
                            num2str(QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).Matched_Percent*100),'%'])
                        fprintf(['FINISHED! AZ Mod# ',num2str(Mod),...
                            ' Quant Mod# ',num2str(QuantMod),' Nearest AZ Match...\n'])
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    end
                end        
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                close all
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for zzzz=1:1
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            disp('====================================================')
            disp('====================================================')
            disp('====================================================')
            disp(['Identifying AZ Locations for: ',QuaSOR_Auto_AZ_Settings.Label])
            disp(['AZ Detection Gaussian Filter Sigma = ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma),'px'])
            disp(['AZ Detection Gaussian Filter Sigma = ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma_nm),'nm'])
            disp(['AZ Detection Min_Event_Distance_px = ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_px),'px'])
            disp(['AZ Detection Min_Event_Distance_nm = ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_nm),'nm'])
            if QuaSOR_Auto_AZ_Settings.AZ_Detect_Adaptive_Threshold
                warning('Using Thresholds with Lower limit set by two events within the minimum distance...')
                disp(['Thresholds based on a filter SIZE = ',...
                    num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size),...
                        ' SIGMA = ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma)])
                disp(['AND a Minimum Event Distance of : ',...
                        num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_um),'um'])

                QuaSOR_Auto_AZ_Settings.AZ_Threshold=ThresholdTest_Max(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_px);
            end
            if size(QuaSOR_Data.All_Location_Coords,1)<QuaSOR_Auto_AZ_Settings.NumEventsRevertThresh
                warning(['ONLY ',size(QuaSOR_Data.All_Location_Coords,1),' Events!'])
                warning(['ONLY ',size(QuaSOR_Data.All_Location_Coords,1),' Events!'])
                warning(['Lowering Threshold to 1 Event!'])
                warning(['Lowering Threshold to 1 Event!'])
                QuaSOR_Auto_AZ_Settings.AZ_Threshold=1;
            end
            QuaSOR_Auto_AZ.Auto_AZ_Quant_ROI_Radius_nm=QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_nm;
            QuaSOR_Auto_AZ.Auto_AZ_Quant_ROI_Radius_px=QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_px;
            disp(['AZ Fixed ROI Quant Radius Auto_AZ_Quant_ROI_Radius_px = ',num2str(QuaSOR_Auto_AZ.Auto_AZ_Quant_ROI_Radius_px),'px'])
            disp(['AZ Fixed ROI Quant Radius Auto_AZ_Quant_ROI_Radius_nm = ',num2str(QuaSOR_Auto_AZ.Auto_AZ_Quant_ROI_Radius_nm),'nm'])
            disp(['Max Auto Match Distance AutoMatch_AZ_Max_Dist_nm = ',num2str(QuaSOR_Auto_AZ_Settings.AutoMatch_AZ_Max_Dist_nm),'nm'])
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            switch QuaSOR_Auto_AZ_Settings.Auto_Detect_Method
                case 1
                    QuaSOR_Auto_AZ.AZ_ThresholdMask = ...
                        imextendedmax(QuaSOR_Maps.HighRes_Maps(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index).QuaSOR_Image,...
                        QuaSOR_Auto_AZ_Settings.AZ_Threshold);
                case 2
                    MaskedImage=QuaSOR_Maps.HighRes_Maps(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index).QuaSOR_Image;
                    MaskedImage(MaskedImage<QuaSOR_Auto_AZ_Settings.AZ_Threshold)=0;
                    QuaSOR_Auto_AZ.AZ_ThresholdMask=imregionalmax(MaskedImage);
            end
            Temp_AZ_Site_Props=...
                regionprops(QuaSOR_Auto_AZ.AZ_ThresholdMask,...
                'centroid','area','BoundingBox','Perimeter');
            disp(['AZ Threshold ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Threshold),...
                ' Preliminary Num Sites: ',num2str(size(Temp_AZ_Site_Props,1))])
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            disp(['Checking AZ Distances with minimum distance of ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_AZ_Distance_um),'um'])
            TestImage=QuaSOR_Maps.HighRes_Maps(QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index).QuaSOR_Image;
            AZ_Detect_Min_AZ_Distance_px=round(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_AZ_Distance_um/ScaleBar_Upscale.ScaleFactor);
            PrelimNumAZ=size(Temp_AZ_Site_Props,1);
            Temp_All_AZ_Distances=zeros(PrelimNumAZ);
            Temp_All_AZ_Distances(Temp_All_AZ_Distances==0)=NaN;
            for z=1:PrelimNumAZ
                Temp_AZ_Site_Props(z).Delete=0;
            end
            for i=1:PrelimNumAZ
                for j=i+1:PrelimNumAZ
                    if i~=j
                        Coord1=Temp_AZ_Site_Props(i).Centroid;
                        Coord2=Temp_AZ_Site_Props(j).Centroid;
                        Temp_All_AZ_Distances(i,j)=sqrt((Coord1(1)-Coord2(1))^2+(Coord1(2)-Coord2(2))^2);
                    end
                end
            end
            figure, imagesc(Temp_All_AZ_Distances), axis equal tight, colormap('jet'),colorbar
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [Flagged1,Flagged2]=find(Temp_All_AZ_Distances<AZ_Detect_Min_AZ_Distance_px);
            if ~isempty(Flagged1)
                warning(['Found ',num2str(length(Flagged1)),' Potential Pairs that are too close!'])
                for i=1:length(Flagged1)
                    Value1=TestImage(round(Temp_AZ_Site_Props(Flagged1(i)).Centroid(2)),...
                        round(Temp_AZ_Site_Props(Flagged1(i)).Centroid(1)));
                    Value2=TestImage(round(Temp_AZ_Site_Props(Flagged2(i)).Centroid(2)),...
                        round(Temp_AZ_Site_Props(Flagged2(i)).Centroid(1)));
                    if Value1>Value2
                        Temp_AZ_Site_Props(Flagged2(i)).Delete=1;
                    elseif Value2>Value1
                        Temp_AZ_Site_Props(Flagged1(i)).Delete=1;
                    elseif Value1==Value2
                        Temp_AZ_Site_Props(Flagged1(i)).Delete=1;
                    end
                end
            end
            AZ_Count=0;
            Temp_AZ_Site_Props_Fixed=[];
            for z=1:PrelimNumAZ
                if ~Temp_AZ_Site_Props(z).Delete
                    AZ_Count=AZ_Count+1;
                   Temp_AZ_Site_Props_Fixed(AZ_Count,1).Centroid=Temp_AZ_Site_Props(z).Centroid;
                end
            end
            All_AZ_Distances=zeros(AZ_Count);
            All_AZ_Distances(All_AZ_Distances==0)=NaN;
            for z=1:PrelimNumAZ
                AZ_Site_Props(z).Delete=0;
            end
            for i=1:AZ_Count
                for j=i+1:AZ_Count
                    if i~=j
                        Coord1=Temp_AZ_Site_Props_Fixed(i).Centroid;
                        Coord2=Temp_AZ_Site_Props_Fixed(j).Centroid;
                        All_AZ_Distances(i,j)=sqrt((Coord1(1)-Coord2(1))^2+(Coord1(2)-Coord2(2))^2);
                    end
                end
            end
            figure, imagesc(All_AZ_Distances), axis equal tight, colormap('jet'),colorbar
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            QuaSOR_Auto_AZ.Auto_Detect_Method=QuaSOR_Auto_AZ_Settings.Auto_Detect_Method;
            QuaSOR_Auto_AZ.AZ_Detect_Min_Event_Distance_um=QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_um;
            QuaSOR_Auto_AZ.AZ_Detect_Min_Event_Distance_px=QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_Event_Distance_px;
            QuaSOR_Auto_AZ.AZ_Detect_Gaussian_Index=QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Index;
            QuaSOR_Auto_AZ.AZ_Detect_Gaussian_Sigma=QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Sigma;
            QuaSOR_Auto_AZ.AZ_Detect_Gaussian_Size=QuaSOR_Auto_AZ_Settings.AZ_Detect_Gaussian_Size;
            QuaSOR_Auto_AZ.AZ_Detect_Min_AZ_Distance_um=QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_AZ_Distance_um;
            QuaSOR_Auto_AZ.AZ_Detect_Color=QuaSOR_Auto_AZ_Settings.AZ_Detect_Color;
            QuaSOR_Auto_AZ.AZ_Threshold=QuaSOR_Auto_AZ_Settings.AZ_Threshold;
            QuaSOR_Auto_AZ.ThresholdTest_Max=ThresholdTest_Max;
            QuaSOR_Auto_AZ.PrelimNumAZ=PrelimNumAZ;
            QuaSOR_Auto_AZ.AZ_Count=AZ_Count;
            QuaSOR_Auto_AZ.All_AZ_Distances=All_AZ_Distances;
            QuaSOR_Auto_AZ.AZ_Site_Props=Temp_AZ_Site_Props_Fixed;
            QuaSOR_Auto_AZ.AZ_Detect_Adaptive_Threshold=QuaSOR_Auto_AZ_Settings.AZ_Detect_Adaptive_Threshold;
            disp(['AZ Threshold ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Threshold),...
                ' Minimum Distance of ',num2str(QuaSOR_Auto_AZ_Settings.AZ_Detect_Min_AZ_Distance_um),'um',...
                ' Num Sites: ',num2str(size(QuaSOR_Auto_AZ.AZ_Site_Props,1))])
            QuaSOR_Auto_AZ.AZ_Struct=[];
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZ_AutoMask_Sum=...
                uint16(zeros(size(QuaSOR_Maps.HighRes_Maps(1).QuaSOR_Image)));
            progressbar('Generating AZ Struct...')
            for AZ=1:size(QuaSOR_Auto_AZ.AZ_Site_Props,1)
                QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord=QuaSOR_Auto_AZ.AZ_Site_Props(AZ).Centroid;
                QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord_Round=round(QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord);
                TempRegion =    (QuaSOR_Row - QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord_Round(2)).^2 + ...
                    (QuaSOR_Col - QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord_Round(1)).^2 <= ...
                    QuaSOR_Auto_AZ.Auto_AZ_Quant_ROI_Radius_px.^2;
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZ_AutoMask_Sum=...
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZ_AutoMask_Sum+uint16(TempRegion);
                TempRegion_Props=regionprops(TempRegion,'PixelList');
                QuaSOR_Auto_AZ.AZ_Struct(AZ).PixelList=TempRegion_Props.PixelList;
                clear TempRegion_Props
                progressbar(AZ/size(QuaSOR_Auto_AZ.AZ_Site_Props,1))
            end
            figure
            imshow(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZ_AutoMask_Sum,[])
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant_FixedROI.Quant_Modality=[];
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality=[];
            for QuantMod=1:length(QuaSOR_Data.Modality)
                for AZ=1:size(QuaSOR_Auto_AZ.AZ_Site_Props,1)
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).Coord=QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).Coord_Round=QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord_Round;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).EventCount=0;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords=[];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords_byEpisodeNum=[];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords_byOverallFrame=[];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords_byOverallStim=[];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Amps=[];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Max_DeltaFF0=[];

                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).Coord=QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).Coord_Round=QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord_Round;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).EventCount=0;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords=[];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords_byEpisodeNum=[];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords_byOverallFrame=[];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords_byOverallStim=[];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Amps=[];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Max_DeltaFF0=[];
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for QuantMod=1:length(QuaSOR_Data.Modality)
                if ~isempty(QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byOverallFrame)
                    fprintf(['AZ Mod# ',num2str(Mod),...
                        ' Quant Mod# ',num2str(QuantMod),' FIXED ROI Radius ',num2str(QuaSOR_Auto_AZ.Auto_AZ_Quant_ROI_Radius_nm),'nm...'])
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if ~strcmp(OS,'MACI64')
                        ppm = ParforProgMon(['AZ Mod# ',num2str(Mod),...
                            ' Quant Mod# ',num2str(QuantMod),' Radius ',num2str(QuaSOR_Auto_AZ.Auto_AZ_Quant_ROI_Radius_nm),'nm | FIXED ROI'], length(QuaSOR_Auto_AZ.AZ_Struct), 1, 1000, 80);
                    else
                        ppm = 0;
                    end
                    %progressbar('Radius','AZ')
                    clear TempAZStruct All_Location_Coords_byEpisodeNum All_Location_Coords_byOverallFrame All_Location_Coords_byOverallStimQuaSOR_Data
                    TempAZStruct=QuaSOR_Auto_AZ.QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct;
                    for AZ=1:length(TempAZStruct)
                        TempAZStruct(AZ).PixelList=QuaSOR_Auto_AZ.AZ_Struct(AZ).PixelList;
                    end
                    All_Location_Coords=QuaSOR_Data.Modality(QuantMod).All_Location_Coords;
                    All_Location_Coords_byEpisodeNum=QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byEpisodeNum;
                    All_Location_Coords_byOverallFrame=QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byOverallFrame;
                    All_Location_Coords_byOverallStim=QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byOverallStim;
                    All_Location_Amps=QuaSOR_Data.Modality(QuantMod).All_Location_Amps;
                    All_Max_DeltaFF0=QuaSOR_Data.Modality(QuantMod).All_Max_DeltaFF0;
                    parfor AZ=1:length(TempAZStruct)
                        for p=1:size(TempAZStruct(AZ).PixelList,1)
                            for e=1:size(All_Location_Coords_byOverallFrame,1)
                                TempCoord=All_Location_Coords_byOverallFrame(e,1:2)*QuaSOR_Map_Settings.QuaSOR_UpScaleFactor;
                                TempCoord=round(TempCoord);
                                if TempCoord(1)==TempAZStruct(AZ).PixelList(p,2)&&...
                                    TempCoord(2)==TempAZStruct(AZ).PixelList(p,1)
                                    TempAZStruct(AZ).EventCount=TempAZStruct(AZ).EventCount+1;
                                    TempAZStruct(AZ).All_Location_Coords=vertcat(...
                                        TempAZStruct(AZ).All_Location_Coords,...
                                        All_Location_Coords(e,:));
                                    TempAZStruct(AZ).All_Location_Coords_byEpisodeNum=vertcat(...
                                        TempAZStruct(AZ).All_Location_Coords_byEpisodeNum,...
                                        All_Location_Coords_byEpisodeNum(e,:));
                                    TempAZStruct(AZ).All_Location_Coords_byOverallFrame=vertcat(...
                                        TempAZStruct(AZ).All_Location_Coords_byOverallFrame,...
                                        All_Location_Coords_byOverallFrame(e,:));
                                    TempAZStruct(AZ).All_Location_Coords_byOverallStim=vertcat(...
                                        TempAZStruct(AZ).All_Location_Coords_byOverallStim,...
                                        All_Location_Coords_byOverallStim(e,:));
                                    TempAZStruct(AZ).All_Location_Amps=horzcat(...
                                        TempAZStruct(AZ).All_Location_Amps,...
                                        All_Location_Amps(e));
                                    TempAZStruct(AZ).All_Max_DeltaFF0=horzcat(...
                                        TempAZStruct(AZ).All_Max_DeltaFF0,...
                                        All_Max_DeltaFF0(e));
                                end
                            end
                        end
                        if ~strcmp(OS,'MACI64')
                            ppm.increment();
                        end
                    end
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct=TempAZStruct;
                    clear TempAZStruct
                    fprintf('Finished!\n')
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for QuantMod=1:length(QuaSOR_Data.Modality)
                if ~isempty(QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byOverallFrame)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf(['AZ Mod# ',num2str(Mod),...
                        ' Quant Mod# ',num2str(QuantMod),' Nearest AZ Match...\n'])
                    TempAZStruct=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct;
                    All_Location_Coords=QuaSOR_Data.Modality(QuantMod).All_Location_Coords;
                    All_Location_Coords_byEpisodeNum=QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byEpisodeNum;
                    All_Location_Coords_byOverallFrame=QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byOverallFrame;
                    All_Location_Coords_byOverallStim=QuaSOR_Data.Modality(QuantMod).All_Location_Coords_byOverallStim;
                    All_Location_Amps=QuaSOR_Data.Modality(QuantMod).All_Location_Amps;
                    All_Max_DeltaFF0=QuaSOR_Data.Modality(QuantMod).All_Max_DeltaFF0;
                    QuaSOR_AZ_Coord_List=[];
                    for AZ=1:length(TempAZStruct)
                        QuaSOR_AZ_Coord_List=vertcat(QuaSOR_AZ_Coord_List,TempAZStruct.Coord_Round);
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    BestPairs=zeros(length(All_Location_Coords_byOverallFrame),10);
                    Temp_QuaSOR_Coords=[...
                        All_Location_Coords_byOverallFrame(:,2),...
                        All_Location_Coords_byOverallFrame(:,1)];
                    Temp_QuaSOR_Coords=Temp_QuaSOR_Coords*QuaSOR_Map_Settings.QuaSOR_UpScaleFactor;
                    Temp_QuaSOR_Coords_Refined=[];
                    All_Location_Coords_Refined=[];
                    All_Location_Coords_byEpisodeNum_Refined=[];
                    All_Location_Coords_byOverallFrame_Refined=[];
                    All_Location_Coords_byOverallStim_Refined=[];
                    All_Location_Amps_Refined=[];
                    All_Max_DeltaFF0_Refined=[];
                    for i=1:size(Temp_QuaSOR_Coords,1)
                        TempRefine=0;
                        TempCoord=Temp_QuaSOR_Coords(i,:);
                        TempCoord=round(TempCoord);
                        if ~any(TempCoord<=0)&&TempCoord(2)<=size(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,1)&&TempCoord(1)<=size(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,2)
                            if QuaSOR_Map_Settings.QuaSOR_Bouton_Mask(TempCoord(2),TempCoord(1))
                                TempRefine=1;
                            end
        %                                 for k=1:length(QuaSOR_Refining_ROIs.QuaSOR_Exclusion)
        %                                     if QuaSOR_Refining_ROIs.QuaSOR_Exclusion(k).ImageArea(TempCoord(2),TempCoord(1))
        %                                         TempRefine=0;
        %                                     end
        %                                 end
                            if TempRefine
                                Temp_QuaSOR_Coords_Refined=vertcat(Temp_QuaSOR_Coords_Refined,Temp_QuaSOR_Coords(i,:));
                                All_Location_Coords_Refined=vertcat(All_Location_Coords_Refined,All_Location_Coords(i,:));
                                All_Location_Coords_byEpisodeNum_Refined=vertcat(All_Location_Coords_byEpisodeNum_Refined,All_Location_Coords_byEpisodeNum(i,:));
                                All_Location_Coords_byOverallFrame_Refined=vertcat(All_Location_Coords_byOverallFrame_Refined,All_Location_Coords_byOverallFrame(i,:));
                                All_Location_Coords_byOverallStim_Refined=vertcat(All_Location_Coords_byOverallStim_Refined,All_Location_Coords_byOverallStim(i,:));
                                All_Location_Amps_Refined=horzcat(All_Location_Amps_Refined,All_Location_Amps(i));
                                All_Max_DeltaFF0_Refined=horzcat(All_Max_DeltaFF0_Refined,All_Max_DeltaFF0(i));
                            end
                            clear TempRefine
                        else
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    figure,
                    plot(Temp_QuaSOR_Coords(:,1),Temp_QuaSOR_Coords(:,2),'.','color','r','markersize',8)
                    hold on
                    plot(Temp_QuaSOR_Coords_Refined(:,1),Temp_QuaSOR_Coords_Refined(:,2),'.','color','g','markersize',12)
                    hold on
                    plot(QuaSOR_AZ_Coord_List(:,1),QuaSOR_AZ_Coord_List(:,2),'o','color','m','markersize',4)
                    set(gca,'ydir','reverse')
                    axis equal tight
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Total_Num_Coords=size(Temp_QuaSOR_Coords,1);
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Input_Coords=Temp_QuaSOR_Coords;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_Coords=Temp_QuaSOR_Coords_Refined;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_Num_Coords=size(Temp_QuaSOR_Coords_Refined,1);
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_Percent=...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_Num_Coords/...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Total_Num_Coords;
                    [QuaSORIndex2Match,QuaSORIndex2MatchDist_px]=dsearchn(QuaSOR_AZ_Coord_List,Temp_QuaSOR_Coords_Refined);
                    QuaSORIndex2MatchDist_nm=QuaSORIndex2MatchDist_px*(ScaleBar_Upscale.ScaleFactor*1000);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    figure, 
                    title(['Mod ',num2str(QuantMod)])
                    subplot(1,2,1)
                    hist(QuaSORIndex2MatchDist_px)
                    xlabel('Pixel Distance')
                    subplot(1,2,2)
                    hist(QuaSORIndex2MatchDist_nm)
                    xlabel('nm distance')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_DistMatrix_nm=QuaSORIndex2MatchDist_nm;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_Dist_Mean_nm=mean(QuaSORIndex2MatchDist_nm);
                    disp(['Mod ',num2str(QuantMod),' Mean AZ Distance (nm) = ',...
                        num2str(round(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Refine_Dist_Mean_nm))])
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AllDistances2AZ_px=QuaSORIndex2MatchDist_px;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AllDistances2AZ_nm=QuaSORIndex2MatchDist_nm;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).QuaSORIndex2Match=QuaSORIndex2Match;
                    if size(QuaSORIndex2Match,1)~=size(All_Location_Coords_byOverallFrame_Refined,1)
                        error('Matching Mismatch')
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    progressbar('Sorting all events...')
                    Temp_QuaSOR_Coords_Matched=[];
                    for e=1:size(QuaSORIndex2Match,1)
                        TempAZ=QuaSORIndex2Match(e);
                        if ~isempty(TempAZ)&&QuaSORIndex2MatchDist_nm(e)<QuaSOR_Auto_AZ_Settings.AutoMatch_AZ_Max_Dist_nm
                            TempAZStruct(TempAZ).EventCount=TempAZStruct(TempAZ).EventCount+1;
                            TempAZStruct(TempAZ).All_Location_Coords=vertcat(...
                                TempAZStruct(TempAZ).All_Location_Coords,...
                                All_Location_Coords_Refined(e,:));
                            TempAZStruct(TempAZ).All_Location_Coords_byEpisodeNum=vertcat(...
                                TempAZStruct(TempAZ).All_Location_Coords_byEpisodeNum,...
                                All_Location_Coords_byEpisodeNum_Refined(e,:));
                            TempAZStruct(TempAZ).All_Location_Coords_byOverallFrame=vertcat(...
                                TempAZStruct(TempAZ).All_Location_Coords_byOverallFrame,...
                                All_Location_Coords_byOverallFrame_Refined(e,:));
                            TempAZStruct(TempAZ).All_Location_Coords_byOverallStim=vertcat(...
                                TempAZStruct(TempAZ).All_Location_Coords_byOverallStim,...
                                All_Location_Coords_byOverallStim_Refined(e,:));
                            Temp_QuaSOR_Coords_Matched=vertcat(...
                                Temp_QuaSOR_Coords_Matched,...
                                Temp_QuaSOR_Coords_Refined(e,:));
                            TempAZStruct(TempAZ).All_Location_Amps=horzcat(...
                                TempAZStruct(TempAZ).All_Location_Amps,...
                                All_Location_Amps_Refined(e));
                            TempAZStruct(TempAZ).All_Max_DeltaFF0=horzcat(...
                                TempAZStruct(TempAZ).All_Max_DeltaFF0,...
                                All_Max_DeltaFF0_Refined(e));
                        else
                            warning(['Did not match event ',num2str(e),' ',num2str(QuaSORIndex2MatchDist_nm(e)),'nm'])
                        end
                        progressbar(e/size(QuaSORIndex2Match,1))
                    end
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct=TempAZStruct;
                    clear TempAZStruct
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Matched_Coords=Temp_QuaSOR_Coords_Matched;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Matched_Num_Coords=size(Temp_QuaSOR_Coords_Matched,1);
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Matched_Percent=...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Matched_Num_Coords/...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Total_Num_Coords;
                    disp(['Mod ',num2str(QuantMod),' # Coords = ',...
                        num2str(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Total_Num_Coords)])
                    disp(['Mod ',num2str(QuantMod),' # Refine Coords = ',...
                        num2str(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Matched_Num_Coords)])
                    disp(['Mod ',num2str(QuantMod),' % Refined = ',...
                        num2str(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).Matched_Percent*100),'%'])
                    fprintf(['FINISHED! AZ Mod# ',num2str(Mod),...
                        ' Quant Mod# ',num2str(QuantMod),' Nearest AZ Match...\n'])
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
            end        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            close all
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('============================================================')
        FileSuffix='_DeltaFData.mat';
        if ~exist([CurrentScratchDir,StackSaveName,FileSuffix])
            if ~exist([SaveDir,StackSaveName,FileSuffix])
                error([StackSaveName,FileSuffix,' Missing!']);
            else
                FileInfo = dir([SaveDir,StackSaveName,FileSuffix]);
                TimeStamp = FileInfo.date;
                CurrentDateNum=FileInfo.datenum;
                disp([StackSaveName,FileSuffix,' Last updated: ',TimeStamp]);
                if Safe2CopyDelete
                    fprintf(['Copying ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
                    [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
                    if CopyStatus
                        fprintf('Copy successful!\n')
                    else
                        error(CopyMessage)
                    end               
                end
            end
        end
        fprintf(['Loading ',StackSaveName,FileSuffix,'...']);
        load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct','EpisodeStructCurves','SplitEpisodeFiles');
        fprintf('Finished!\n')
        disp('============================================================')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~exist('SplitEpisodeFiles')
            SplitEpisodeFiles=0;
        end
        if SplitEpisodeFiles
            for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
                FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
                if ~exist([CurrentScratchDir,StackSaveName,FileSuffix])
                    fprintf(['Copying: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
                    [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
                    fprintf('Finished!\n')
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZTrace.RegionRadius_nm=QuaSOR_Auto_AZ_Settings.Auto_AZ_Quant_ROI_Radius_nm;
        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZTrace.RegionRadius_px=...
            ceil((QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZTrace.RegionRadius_nm/1000)/(ScaleBar.ScaleFactor));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Collecting Traces
        [DeltaFF0_Col DeltaFF0_Row] = meshgrid(1:Image_Width,...
            1:Image_Height);
        ZerosImage=zeros(Image_Height,Image_Width,'logical');
        close all
        for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
            fprintf(['Extracting Episode ',num2str(EpisodeNumber_Load),' Traces...'])
            if SplitEpisodeFiles
                FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
                fprintf(['Loading: ',FileSuffix,'...'])
                load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
                EpisodeNumber=1;
            else
                EpisodeNumber=EpisodeNumber_Load;
            end
            TempDeltaFF0=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaFF0;
            %%%%%%%%%%%%%%%%%%%%%%%%
            %QuaSOR AZ Centered Traces
            fprintf('by AZ Pooled Mod...')
            AZ_Struct=QuaSOR_Auto_AZ.AZ_Struct;
            TempMask=zeros(Image_Height,Image_Width,'uint16');
            for AZ=1:length(AZ_Struct)
                AZ_Struct(AZ).Coord_Orig=AZ_Struct(AZ).Coord;
                AZ_Struct(AZ).Coord_Orig=round(AZ_Struct(AZ).Coord_Orig/QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor);
                AZ_Struct(AZ).Mask =    (DeltaFF0_Row - AZ_Struct(AZ).Coord_Orig(2)).^2 + ...
                    (DeltaFF0_Col - AZ_Struct(AZ).Coord_Orig(1)).^2 <= ...
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZTrace.RegionRadius_px.^2;
                AZ_Struct(AZ).Mask=logical(AZ_Struct(AZ).Mask);
                TempMask=TempMask+uint16(AZ_Struct(AZ).Mask);
                AZ_Struct(AZ).DeltaFF0_MeanTrace=[];
                AZ_Struct(AZ).DeltaFF0_MaxTrace=[];
            end
            if ~any(strcmp(OS,'MACI64'))&&ProgressBarOn
                ppm = ParforProgMon([StackSaveName,' || Episode # ',num2str(EpisodeNumber_Load),' || ',...
                    num2str(length(AZ_Struct)),' AZs '],...
                    length(AZ_Struct), 1, 1000, 80);
            else
                ppm=0;
            end
            parfor AZ=1:length(AZ_Struct)
                TempMaxVals=[];
                TempMeanTrace=[];
                for f1=1:size(TempDeltaFF0,3)
                    TempImage=TempDeltaFF0(:,:,f1);
                    TempVals=TempImage(AZ_Struct(AZ).Mask);
                    TempMaxVals(f1)=max(TempVals(:));
                    TempMeanTrace(f1)=nanmean(TempVals(:));
                end
                AZ_Struct(AZ).DeltaFF0_MeanTrace=TempMeanTrace;
                AZ_Struct(AZ).DeltaFF0_MaxTrace=TempMaxVals;
                AZ_Struct(AZ).Mask=[];
                if ~any(strcmp(OS,'MACI64'))&&ProgressBarOn
                    ppm.increment();
                end
            end
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Episode(EpisodeNumber_Load).AZ_Struct=AZ_Struct;
            clear AZ_Struct
            %%%%%%%%%%%%%%%%%%%%%%%%
            for Mod=1:length(QuaSOR_Auto_AZ.Modality)
                QuaSOR_Auto_AZ.Modality(Mod).Label=QuaSOR_Data.Modality(Mod).Label;
                fprintf([QuaSOR_Auto_AZ.Modality(Mod).Label,'...'])
                AZ_Struct=QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct;
                TempMask=zeros(Image_Height,Image_Width,'uint16');
                for AZ=1:length(AZ_Struct)
                    AZ_Struct(AZ).Coord_Orig=AZ_Struct(AZ).Coord;
                    AZ_Struct(AZ).Coord_Orig=round(AZ_Struct(AZ).Coord_Orig/QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor);
                    AZ_Struct(AZ).Mask =    (DeltaFF0_Row - AZ_Struct(AZ).Coord_Orig(2)).^2 + ...
                        (DeltaFF0_Col - AZ_Struct(AZ).Coord_Orig(1)).^2 <= ...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZTrace.RegionRadius_px.^2;
                    AZ_Struct(AZ).Mask=logical(AZ_Struct(AZ).Mask);
                    TempMask=TempMask+uint16(AZ_Struct(AZ).Mask);
                    AZ_Struct(AZ).DeltaFF0_MeanTrace=[];
                    AZ_Struct(AZ).DeltaFF0_MaxTrace=[];
                end
                if ~any(strcmp(OS,'MACI64'))&&ProgressBarOn
                    ppm = ParforProgMon([StackSaveName,' || Episode # ',num2str(EpisodeNumber_Load),' || ',...
                        num2str(length(AZ_Struct)),' AZs '],...
                        length(AZ_Struct), 1, 1000, 80);
                else
                    ppm=0;
                end
                parfor AZ=1:length(AZ_Struct)
                    TempMaxVals=[];
                    TempMeanTrace=[];
                    for f1=1:size(TempDeltaFF0,3)
                        TempImage=TempDeltaFF0(:,:,f1);
                        TempVals=TempImage(AZ_Struct(AZ).Mask);
                        TempMaxVals(f1)=max(TempVals(:));
                        TempMeanTrace(f1)=nanmean(TempVals(:));
                    end
                    AZ_Struct(AZ).DeltaFF0_MeanTrace=TempMeanTrace;
                    AZ_Struct(AZ).DeltaFF0_MaxTrace=TempMaxVals;
                    AZ_Struct(AZ).Mask=[];
                    if ~any(strcmp(OS,'MACI64'))&&ProgressBarOn
                        ppm.increment();
                    end
                end
                QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Episode(EpisodeNumber_Load).AZ_Struct=AZ_Struct;
                clear AZ_Struct
            end
            %%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('Finished!\n')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Merging Traces
        fprintf('Merging Episode Traces...')
        for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Episode(1).AZ_Struct)
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZ_Struct(AZ).DeltaFF0_MeanTrace=[];
            for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZ_Struct(AZ).DeltaFF0_MeanTrace=...
                    horzcat(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZ_Struct(AZ).DeltaFF0_MeanTrace,...
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Episode(EpisodeNumber_Load).AZ_Struct(AZ).DeltaFF0_MeanTrace);
            end
        end
        for Mod=1:length(QuaSOR_Auto_AZ.Modality)      
            for AZ=1:length(QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Episode(1).AZ_Struct)
                QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.AZ_Struct(AZ).DeltaFF0_MeanTrace=[];
                for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
                    QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.AZ_Struct(AZ).DeltaFF0_MeanTrace=...
                        horzcat(QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.AZ_Struct(AZ).DeltaFF0_MeanTrace,...
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Episode(EpisodeNumber_Load).AZ_Struct(AZ).DeltaFF0_MeanTrace);
                end
            end
        end
        fprintf('Finished!\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %AZ Stats
        fprintf('Collecting Auto AZ Stats...')
        for Mod=1:length(QuaSOR_Data.Modality)      
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.Label=['Pooled','_',QuaSOR_Data.Modality(Mod).Label];
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.ShortLabel=['Pool','_',QuaSOR_Data.Modality(Mod).Label(1:2)];
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.EpisodeFrames=[];
            if Mod==1
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.EpisodeFrames=...
                    ImagingInfo.IntraEpisode_Evoked_ActiveFrames;
            elseif Mod==2
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.EpisodeFrames=...
                    ImagingInfo.IntraEpisode_Spont_ActiveFrames;
            else
                error('unknown mod')
            end
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.OverallFrames=[];
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.EpisodeCount=0;
            for e=1:ImagingInfo.NumEpisodes
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.EpisodeCount=...
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.EpisodeCount+1;
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.OverallFrames=...
                    [QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.OverallFrames,...
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.EpisodeFrames+...
                    (e-1)*ImagingInfo.FramesPerEpisode];
            end
            if ~isnan(ImagingInfo.StimuliPerEpisode)
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.StimCount=...
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.EpisodeCount*ImagingInfo.StimuliPerEpisode;
            else
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.StimCount=0;
            end
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.ImagingDuration=...
                (length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.EpisodeFrames)*(1/ImagingInfo.ImagingFrequency));
            for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct)
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).EventCount=0;
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).All_Location_Amps=[];
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).All_Max_DeltaFF0=[];
                %QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).QuantalContent=NaN;
                %QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).QuantalDensity=NaN;
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).Pr=NaN;
                %QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).SpontCount=NaN;
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).Fs=NaN;
                %QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).AreaNorm_Fs=NaN;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats=[];
            for Treatment=1:length(MarkerSetInfo.Markers)+1
                Treatment1=Treatment-1;
                if Treatment1==0
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).Label=['Base','_',QuaSOR_Data.Modality(Mod).Label];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).ShortLabel=['Base','_',QuaSOR_Data.Modality(Mod).Label(1:2)];
                else
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).Label=...
                        [MarkerSetInfo.Markers(Treatment1).MarkerShortLabel,'_',QuaSOR_Data.Modality(Mod).Label];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).ShortLabel=...
                        [MarkerSetInfo.Markers(Treatment1).MarkerShortLabel,'_',QuaSOR_Data.Modality(Mod).Label(1:2)];
                end
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).EpisodeFrames=[];
                if Mod==1
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).EpisodeFrames=...
                        ImagingInfo.IntraEpisode_Evoked_ActiveFrames;
                elseif Mod==2
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).EpisodeFrames=...
                        ImagingInfo.IntraEpisode_Spont_ActiveFrames;
                else
                    error('unknown mod')
                end
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).OverallFrames=[];
                for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct)
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).EventCount=0;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).All_Location_Amps=[];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).All_Max_DeltaFF0=[];
                    %QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).QuantalContent=NaN;
                    %QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).QuantalDensity=NaN;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).Pr=NaN;
                    %QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).SpontCount=NaN;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).Fs=NaN;
                    %QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).AreaNorm_Fs=NaN;
                end
            end
            for Treatment=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats)
                Treatment1=Treatment-1;
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).EpisodeCount=0;
                for e=1:ImagingInfo.NumEpisodes
                    FoundMarker=0;
                    for Marker=1:length(MarkerSetInfo.Markers)
                        if any(e==[MarkerSetInfo.Markers(Marker).MarkerStart:MarkerSetInfo.Markers(Marker).MarkerEnd])
                            FoundMarker=Marker;
                        end
                    end
                    if FoundMarker==Treatment1
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).EpisodeCount=...
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).EpisodeCount+1;
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).OverallFrames=...
                            [QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).OverallFrames,...
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).EpisodeFrames+...
                            (e-1)*ImagingInfo.FramesPerEpisode];
                    end
                end
                if ~isnan(ImagingInfo.StimuliPerEpisode)
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).StimCount=...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).EpisodeCount*ImagingInfo.StimuliPerEpisode;
                else
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).StimCount=0;
                end
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).ImagingDuration=...
                    (length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).EpisodeFrames)*(1/ImagingInfo.ImagingFrequency));
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).EpisodeAZStats=[];
            if ImagingInfo.StimuliPerEpisode>1
                TempNumEpisodes=ImagingInfo.NumEpisodes;
            else
                TempNumEpisodes=1;
            end
            for Ep=1:TempNumEpisodes
                if TempNumEpisodes==1
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).Label=['All_Epi','_',QuaSOR_Data.Modality(Mod).Label];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).ShortLabel=['All_Epi','_',QuaSOR_Data.Modality(Mod).Label(1:2)];
                else
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).Label=...
                        ['Epi_',num2str(Ep),'_',QuaSOR_Data.Modality(Mod).Label];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).ShortLabel=...
                        ['Epi_',num2str(Ep),'_',QuaSOR_Data.Modality(Mod).Label(1:2)];
                end
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).EpisodeFrames=[];
                if Mod==1
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).EpisodeFrames=...
                        ImagingInfo.IntraEpisode_Evoked_ActiveFrames;
                elseif Mod==2
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).EpisodeFrames=...
                        ImagingInfo.IntraEpisode_Spont_ActiveFrames;
                else
                    error('unknown mod')
                end
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).OverallFrames=[];
                for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct)
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).EventCount=0;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).All_Location_Amps=[];
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).All_Max_DeltaFF0=[];
                    %QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).QuantalContent=NaN;
                    %QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).QuantalDensity=NaN;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).Pr=NaN;
                    %QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).SpontCount=NaN;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).Fs=NaN;
                    %QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).AreaNorm_Fs=NaN;

                end
            end
            for Ep=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats)
                for e=1:ImagingInfo.NumEpisodes
                    if ImagingInfo.StimuliPerEpisode>1
                        if Ep==e
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).OverallFrames=...
                                [QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).OverallFrames,...
                                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).EpisodeFrames+...
                                (e-1)*ImagingInfo.FramesPerEpisode];
                        end
                    else
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).OverallFrames=...
                            [QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).OverallFrames,...
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).EpisodeFrames+...
                            (e-1)*ImagingInfo.FramesPerEpisode];
                    end
                end
                if TempNumEpisodes==1
                    if ~isnan(ImagingInfo.StimuliPerEpisode)
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).StimCount=...
                            ImagingInfo.NumEpisodes*ImagingInfo.StimuliPerEpisode;
                    else
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).StimCount=0;
                    end
                else
                if ~isnan(ImagingInfo.StimuliPerEpisode)
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).StimCount=...
                        1*ImagingInfo.StimuliPerEpisode;
                else
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).StimCount=0;
                end
                end
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).ImagingDuration=...
                    (length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).EpisodeFrames)*(1/ImagingInfo.ImagingFrequency));
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        for Mod=1:length(QuaSOR_Data.Modality)      
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_EventCount=[];
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Mean_Amp=[];
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Mean_DeltaFF0=[];
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Pr=[];
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Fs=[];
            for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct)
                TempEvents=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Location_Coords_byOverallFrame;
                TempAmps=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Location_Amps;
                TempDeltaFF0=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Max_DeltaFF0;
                for i=1:size(TempEvents,1)
                    if any(TempEvents(i,3)==QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.OverallFrames)
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).EventCount=...
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).EventCount+1;
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).All_Location_Amps=...
                            horzcat(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).All_Location_Amps,TempAmps(i));
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).All_Max_DeltaFF0=...
                            horzcat(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).All_Max_DeltaFF0,TempDeltaFF0(i));
                    end
                end
                if Mod==1
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).Pr=...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).EventCount/...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.StimCount;
                elseif Mod==2
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).Fs=...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).EventCount/...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.ImagingDuration;
                end
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_EventCount(AZ)=...
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).EventCount;
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Mean_Amp(AZ)=...
                    nanmean(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).All_Location_Amps);
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Mean_DeltaFF0(AZ)=...
                    nanmean(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).All_Max_DeltaFF0);
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Pr(AZ)=...
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).Pr;
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Fs(AZ)=...
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Struct(AZ).Fs;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for Treatment=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats)
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_EventCount=[];
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Mean_Amp=[];
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Mean_DeltaFF0=[];
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Pr=[];
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Fs=[];
                for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct)
                    TempEvents=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Location_Coords_byOverallFrame;
                    TempAmps=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Location_Amps;
                    TempDeltaFF0=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Max_DeltaFF0;
                    for i=1:size(TempEvents,1)
                        if any(TempEvents(i,3)==QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).OverallFrames)
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).EventCount=...
                                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).EventCount+1;
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).All_Location_Amps=...
                                horzcat(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).All_Location_Amps,TempAmps(i));
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).All_Max_DeltaFF0=...
                                horzcat(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).All_Max_DeltaFF0,TempDeltaFF0(i));
                        end
                    end
                    if Mod==1
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).Pr=...
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).EventCount/...
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).StimCount;
                    elseif Mod==2
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).Fs=...
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).EventCount/...
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).ImagingDuration;
                    end
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_EventCount(AZ)=...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).EventCount;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Mean_Amp(AZ)=...
                        nanmean(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).All_Location_Amps);
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Mean_DeltaFF0(AZ)=...
                        nanmean(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).All_Max_DeltaFF0);
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Pr(AZ)=...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).Pr;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Fs(AZ)=...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Struct(AZ).Fs;
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for Ep=1:TempNumEpisodes
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_EventCount=[];
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Mean_Amp=[];
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Mean_DeltaFF0=[];
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Pr=[];
                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Fs=[];
                for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct)
                    TempEvents=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Location_Coords_byOverallFrame;
                    TempAmps=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Location_Amps;
                    TempDeltaFF0=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Max_DeltaFF0;
                    for i=1:size(TempEvents,1)
                        if any(TempEvents(i,3)==QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).OverallFrames)
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).EventCount=...
                                QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).EventCount+1;
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).All_Location_Amps=...
                                horzcat(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).All_Location_Amps,TempAmps(i));
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).All_Max_DeltaFF0=...
                                horzcat(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).All_Max_DeltaFF0,TempDeltaFF0(i));
                        end
                    end
                    if Mod==1
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).Pr=...
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).EventCount/...
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).StimCount;
                    elseif Mod==2
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).Fs=...
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).EventCount/...
                            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).ImagingDuration;
                    end
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_EventCount(AZ)=...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).EventCount;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Mean_Amp(AZ)=...
                        nanmean(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).All_Location_Amps);
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Mean_DeltaFF0(AZ)=...
                        nanmean(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).All_Max_DeltaFF0);
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Pr(AZ)=...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).Pr;
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Fs(AZ)=...
                        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Struct(AZ).Fs;
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        fprintf('Finished!\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Export Tables
        run('Multi_Modality_QuaSOR_Info_Export.m')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Figures
        for Mod=1:length(QuaSOR_Maps.Modality)
            if size(QuaSOR_Data.Modality(Mod).All_Location_Coords,1)>0
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FigName=[QuaSOR_Auto_AZ_Settings.Modality(Mod).Label,' QuaSOR Auto AZ Count Comparison'];
                figure
                hold on
                xlabel('Fixed ROI Counts')
                ylabel('Auto AZ Match Counts')
                for QuantMod=1:length(QuaSOR_Data.Modality)
                    for AZ=1:size(QuaSOR_Auto_AZ.Modality(Mod).AZ_Site_Props,1)
                        plot(QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).EventCount,...
                        QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).EventCount,...
                        '.','color',QuaSOR_Map_Settings.Modality_Colors{QuantMod},'markersize',10)
                    end
                end
                axis equal tight
                set(gcf, 'color', 'white');
                Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'AutoAZ',dc,QuaSOR_Auto_AZ_Settings.Modality(Mod).Label,dc,FigName],3)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf('Making some figures...\n')
                for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
                    SigLabel=[num2str(round(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas_nm(z)*10)/10)];
                    if ~any(strfind(SigLabel,'.'))
                        SigLabel=[SigLabel,'.0'];
                    end
                    TempMax=...
                        (ceil(max(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image(:))));
                    TempMaxCont=ceil(TempMax*...
                        QuaSOR_Auto_AZ_Settings.AZ_Map_Display_Contrast);
                    ContLabel=[num2str(round(double(TempMaxCont)*10)/10)];

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [~,TempQuaSORImage,~]=...
                        Adjust_Contrast_and_Color(QuaSOR_Maps.Modality(Mod).HighRes_Maps(z).QuaSOR_Image,...
                        0,TempMaxCont,QuaSOR_Map_Settings.ExportColorMap,...
                        QuaSOR_Map_Settings.QuaSOR_Color_Scalar);
                    TempQuaSORImage=...
                        ColorMasking(TempQuaSORImage,...
                        ~QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    FigName=[QuaSOR_Auto_AZ_Settings.Modality(Mod).Label,'_QuaSOR_H_Sig',SigLabel,'nm_Max',ContLabel,' Auto AZ Locs'];
                    fprintf(['Exporting: ',FigName,' Figures...']);
                    imwrite(double(TempQuaSORImage),[FigureScratchDir,dc,'AutoAZ',dc,QuaSOR_Auto_AZ_Settings.Modality(Mod).Label,dc,FigName,'.tif'])
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    figure
                    imshow(TempQuaSORImage,[],'border','tight')
                    for i=1:size(QuaSOR_Auto_AZ.Modality(Mod).AZ_Site_Props,1)
                        Plot_Circle2(QuaSOR_Auto_AZ.Modality(Mod).AZ_Site_Props(i).Centroid(1),...
                            QuaSOR_Auto_AZ.Modality(Mod).AZ_Site_Props(i).Centroid(2),...
                            QuaSOR_Auto_AZ.Modality(Mod).Auto_AZ_Quant_ROI_Radius_px,'-',0.5,QuaSOR_Auto_AZ_Settings.AZ_Detect_Color);
                    end
                    hold on
                    for j=1:length(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine)
                        plot(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                            QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                            '-','color','w','linewidth',1)
                    end
                    set(gca,'units','normalized','position',[0,0,1,1])
                    set(gcf, 'color', 'white');
                    set(gca,'XTick', []); set(gca,'YTick', []);
                    Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'AutoAZ',dc,QuaSOR_Auto_AZ_Settings.Modality(Mod).Label,dc,FigName],3)
                    warning on
                    pause(0.1)
                    fprintf('Finished!\n')
                    close all
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                close all
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
        for zzzz=1:1
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            FigName=[QuaSOR_Auto_AZ_Settings.Label,' QuaSOR Auto AZ Count Comparison'];
            figure
            hold on
            xlabel('Fixed ROI Counts')
            ylabel('Auto AZ Match Counts')
            for QuantMod=1:length(QuaSOR_Data.Modality)
                for AZ=1:size(QuaSOR_Auto_AZ.AZ_Site_Props,1)
                    plot(QuaSOR_Auto_AZ.QuaSOR_AutoQuant_FixedROI.Quant_Modality(QuantMod).AZ_Struct(AZ).EventCount,...
                    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).EventCount,...
                    '.','color',QuaSOR_Map_Settings.Modality_Colors{QuantMod},'markersize',10)
                end
            end
            axis equal tight
            set(gcf, 'color', 'white');
            Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'AutoAZ',dc,QuaSOR_Auto_AZ_Settings.Label,dc,FigName],3)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('Making some figures...\n')
            for z=1:length(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas)
                SigLabel=[num2str(round(QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_Sigmas_nm(z)*10)/10)];
                if ~any(strfind(SigLabel,'.'))
                    SigLabel=[SigLabel,'.0'];
                end
                TempMax=...
                    (ceil(max(QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image(:))));
                TempMaxCont=ceil(TempMax*...
                    QuaSOR_Auto_AZ_Settings.AZ_Map_Display_Contrast);
                ContLabel=[num2str(round(double(TempMaxCont)*10)/10)];

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [~,TempQuaSORImage,~]=...
                    Adjust_Contrast_and_Color(QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image,...
                    0,TempMaxCont,QuaSOR_Map_Settings.ExportColorMap,...
                    QuaSOR_Map_Settings.QuaSOR_Color_Scalar);
                TempQuaSORImage=...
                    ColorMasking(TempQuaSORImage,...
                    ~QuaSOR_Map_Settings.QuaSOR_Bouton_Mask,QuaSOR_Map_Settings.Bouton_Region_Mask_Background_Color);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FigName=[QuaSOR_Auto_AZ_Settings.Label,'_QuaSOR_H_Sig',SigLabel,'nm_Max',ContLabel,' Auto AZ Locs'];
                fprintf(['Exporting: ',FigName,' Figures...']);

                imwrite(double(TempQuaSORImage),[FigureScratchDir,dc,'AutoAZ',dc,QuaSOR_Auto_AZ_Settings.Label,dc,FigName,'.tif'])

                figure
                imshow(TempQuaSORImage,[],'border','tight')
                caxis([0,max(QuaSOR_Maps.HighRes_Maps(z).QuaSOR_Image(:))*QuaSOR_Auto_AZ_Settings.AZ_Map_Display_Contrast]);
                for i=1:size(QuaSOR_Auto_AZ.AZ_Site_Props,1)
                    Plot_Circle2(QuaSOR_Auto_AZ.AZ_Site_Props(i).Centroid(1),...
                        QuaSOR_Auto_AZ.AZ_Site_Props(i).Centroid(2),...
                        QuaSOR_Auto_AZ.Auto_AZ_Quant_ROI_Radius_px,'-',0.5,QuaSOR_Auto_AZ_Settings.AZ_Detect_Color);
                end
                hold on
                for j=1:length(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine)
                    plot(QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,2),...
                        QuaSOR_Map_Settings.QuaSOR_Bouton_Mask_BorderLine{j}.BorderLine(:,1),...
                        '-','color','w','linewidth',1)
                end
                set(gca,'units','normalized','position',[0,0,1,1])
                set(gcf, 'color', 'white');set(gca,'XTick', []); set(gca,'YTick', []);
                Full_Export_Fig(gcf,gca,[FigureScratchDir,dc,'AutoAZ',dc,QuaSOR_Auto_AZ_Settings.Label,dc,FigName],3)
                warning on
                pause(0.1)
                fprintf('Finished!\n')
                close all
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            close all
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FileSuffix=['_QuaSOR_AZs.mat'];
        fprintf(['Saving... ',StackSaveName,FileSuffix,' to CurrentScratchDir...']);
        save([CurrentScratchDir,dc,StackSaveName,FileSuffix],'QuaSOR_Auto_AZ','QuaSOR_Auto_AZ_Settings')
        fprintf('Finished!\n')
        fprintf(['Copying: ',StackSaveName,FileSuffix,' to SaveDir...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
        fprintf('Finished!\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('FINISHED!\n');
        OverallTime=toc(OverallTimer);
        fprintf(['Auto QuaSOR AZ Analysis Took: ',num2str(OverallTime/60),'min\n'])
        close all
        disp('======================================')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        warning on
        warning('NO QuaSOR COORDINATES!')
        QuaSOR_Auto_AZ=[];
        FileSuffix=['_QuaSOR_AZs.mat'];
        fprintf(['Saving... ',StackSaveName,FileSuffix,' to CurrentScratchDir...']);
        save([CurrentScratchDir,dc,StackSaveName,FileSuffix],'QuaSOR_Auto_AZ','QuaSOR_Auto_AZ_Settings')
        fprintf('Finished!\n')
        fprintf(['Copying: ',StackSaveName,FileSuffix,' to SaveDir...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
        fprintf('Finished!\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

