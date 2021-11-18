function [QuaSOR_Fitting_Struct,QuaSOR_Data,QuaSOR_Parameters,AllBoutonsRegion_Upscale,ScaleBar_Upscale,BorderLine_Upscale,AbortStatus]=...
    Multi_Modality_QuaSOR(myPool,OS,dc,SaveName,StackSaveName,SaveDir,...
    ScratchDir,CurrentScratchDir,ImagingInfo,QuaSOR_Parameters,QuaSOR_Event_Extraction_Settings,...
    SplitEpisodeFiles,AllBoutonsRegion,ScaleBar,ScaleBar_Upscale,MarkerSetInfo,Image_Width,Image_Height,AbortButton,TrackerDir,Safe2CopyDelete)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    close all
    fprintf(['==========================================================================================\n'])
    fprintf(['==========================================================================================\n'])
    fprintf(['==========================================================================================\n'])
    fprintf(['Starting Muli_Modality_QuaSOR on ',StackSaveName,'\n']);
    [OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(1);
    warning on all
    warning off verbose
    warning off backtrace
    if ~isempty(myPool)
        RunParallel=1;
    else
        RunParallel=0;
    end
    if RunParallel
        if isempty(myPool)
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
        end
    end
    OverallTimer=tic;
    TimeHandle=tic;
    %Safe Abort Figure
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    close all
    clear AbortButtonHandle
    AbortStatus=0;
    if AbortButton
        AbortFig = figure('name',[StackSaveName]);
        set(gcf,'Units','normalized','Position',[0.8 0.8 0.2 0.1]);
        AbortText = uicontrol('Style','text',...
            'units','normalized',...
            'Fontsize',12,...
            'Position',[0.01 0.8 0.98 0.2],...
            'String',['Abort QuaSOR ',StackSaveName],'fontsize',8);
        AbortButtonHandle = uicontrol('Units','Normalized','Position', [0.05 0.05 0.9 0.75],'style','push',...
            'string',['Abort ',StackSaveName],'callback','set(gcbo,''userdata'',1,''string'',''Aborting!!'')', ...
            'userdata',0) ;
    end
    AbortStatus=get(AbortButtonHandle,'userdata');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~exist(ScratchDir)||isempty(ScratchDir)
       [~,~,~,~,~,~,~,ScratchDir]=BatchStartup;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Parameters
    MaxNumEpisodeRepeats=3;
    ParallelDebug=0;
    TextUpdateEpisodeCutoff=10;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %Check if possible to use Pre-Peak image for fitting by loading
    %template
    if QuaSOR_Parameters.GMM.Check_Prior_Frame_Fit
        
        error('QuaSOR_Parameters.GMM.Check_Prior_Frame_Fit IS NOT CURRENTLY POSSIBLE')
        fprintf(['NOTE: Checking Template for Fitting Alternative Frame\n'])

        if EventDetectionSettings.Template.EventDetectionSettings.Template.TemplateResponse(...
                EventDetectionSettings.Template.TemplatePeakPosition-QuaSOR_Parameters.GMM.Check_Prior_Frame_Fit_NumFrames)>...
                QuaSOR_Parameters.GMM.Check_Prior_Frame_Limits(1)&&...
                EventDetectionSettings.Template.TemplateResponse(...
                EventDetectionSettings.Template.TemplatePeakPosition-QuaSOR_Parameters.GMM.Check_Prior_Frame_Fit_NumFrames)<...
                QuaSOR_Parameters.GMM.Check_Prior_Frame_Limits(2)
            Fit_Frame=EventDetectionSettings.Template.TemplatePeakPosition-QuaSOR_Parameters.GMM.Check_Prior_Frame_Fit_NumFrames;
            fprintf(['NOTE: Using Episode Frame #: ',num2str(Fit_Frame),' Instead of CorrAmp for Fitting\n'])
        else
            Fit_Frame=0;
             fprintf(['NOTE: Using CorrAmp for Fitting\n'])
        end
    else
        Fit_Frame=0;
        fprintf(['NOTE: Using CorrAmp for Fitting\n'])
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    AllBoutonsRegion=logical(AllBoutonsRegion);
    AllBoutonsRegionPerim=bwperim(AllBoutonsRegion);
    [BorderY_Crop BorderX_Crop] = find(AllBoutonsRegionPerim);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ImagingInfo.NumEpisodes<TextUpdateEpisodeCutoff
        TextUpdateMode=1;
        warning('Full Text Updates are On!');
    else
        TextUpdateMode=0;
    end
    TestRange=[1:QuaSOR_Parameters.Components.MaxNumGaussians];
    ZerosImage=zeros(size(AllBoutonsRegion));
    ImageWidth=size(ZerosImage,2);
    ImageHeight=size(ZerosImage,1);
    ZerosImage_Upscale=zeros(size(AllBoutonsRegion,1)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,size(AllBoutonsRegion,2)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor);
    %Check the math here for the QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust!!
    x1 = 1:size(ZerosImage,2); y1 = 1:size(ZerosImage,1);
    [X1,Y1] = meshgrid(x1,y1);
    x2 = (1/QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor):(1/QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor):size(AllBoutonsRegion,2); y2 = (1/QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor):(1/QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor):size(AllBoutonsRegion,1);
    [X2,Y2] = meshgrid(x2,y2);
    XDimData=1:size(ZerosImage_Upscale,2);
    YDimData=1:size(ZerosImage_Upscale,1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %ReferenceImage_Upscale=imresize(ReferenceImage,QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod);
    AllBoutonsRegion_Upscale=imresize(AllBoutonsRegion,QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,QuaSOR_Parameters.UpScaling.UpScaleMethod);
    AllBoutonsRegionPerim_Upscale=bwperim(AllBoutonsRegion_Upscale);
    [BorderY_Crop_Upscale BorderX_Crop_Upscale] = find(AllBoutonsRegionPerim_Upscale);
    if ~isempty(QuaSOR_Parameters.Display.DilateRegion)
        [B,L] = bwboundaries(imdilate(AllBoutonsRegion_Upscale,ones(QuaSOR_Parameters.Display.DilateRegion)),'noholes');
    else
        [B,L] = bwboundaries(AllBoutonsRegion_Upscale,'noholes');
    end
    for j=1:length(B)
        for k = 1:length(B{j})
            BorderLine_Upscale{j}.BorderLine_Crop(k,:) = B{j}(k,:);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     ImageArray_QuaSOR_Upscale_Max_Sharp=logical(zeros(size(AllBoutonsRegion,1)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,size(AllBoutonsRegion,2)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,ImagingInfo.NumEpisodes));
%     ImageArray_QuaSOR_Upscale_Sharp_Sum=single(ImageArray_QuaSOR_Upscale_Max_Sharp);
%     ImageArray_QuaSOR_Upscale_Sharp_Prob_Filt=single(ImageArray_QuaSOR_Upscale_Max_Sharp);
%     if QuaSOR_Parameters.General.Reconstruct_Upscale_Fit_Stack
%         ImageArray_QuaSOR_Upscale_Reconstructed=single(ImageArray_QuaSOR_Upscale_Max_Sharp);
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Adjust weighting if needed
    QuaSOR_Parameters.Dist_Weights.Amp_Score.Norm_Hist_Shift=(QuaSOR_Parameters.Dist_Weights.Amp_Score.Norm_Hist+QuaSOR_Parameters.Dist_Weights.Amp_Score.Shift)/max(QuaSOR_Parameters.Dist_Weights.Amp_Score.Norm_Hist+QuaSOR_Parameters.Dist_Weights.Amp_Score.Shift);
    QuaSOR_Parameters.Dist_Weights.Var_Score.Norm_Hist_Shift=(QuaSOR_Parameters.Dist_Weights.Var_Score.Norm_Hist+QuaSOR_Parameters.Dist_Weights.Var_Score.Shift)/max(QuaSOR_Parameters.Dist_Weights.Var_Score.Norm_Hist+QuaSOR_Parameters.Dist_Weights.Var_Score.Shift);
    QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Norm_Hist_Shift=(QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Norm_Hist+QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Shift)/max(QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Norm_Hist+QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Shift);
    QuaSOR_Parameters.Dist_Weights.Cov_Score.Norm_Hist_Shift=(QuaSOR_Parameters.Dist_Weights.Cov_Score.Norm_Hist+QuaSOR_Parameters.Dist_Weights.Cov_Score.Shift)/max(QuaSOR_Parameters.Dist_Weights.Cov_Score.Norm_Hist+QuaSOR_Parameters.Dist_Weights.Cov_Score.Shift);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('========================================================================')
    disp('========================================================================')
    disp('========================================================================')
    DisplayETA=0;
    if any(strcmp(OS,'MACI64'))
        warning('Not showing ParforProgMon Progressbar if running in MaxOSX, have had Java Issues...')
        warning('Turning on DisplayETA...')
        DisplayETA=1;
    end
    warning on;
    disp('========================')
    disp('Critical Settings:')
    disp(['QuaSOR_Parameters.QuaSOR_Mode = ',num2str(QuaSOR_Parameters.QuaSOR_Mode)]);
    disp(['QuaSOR_Parameters.GMM.Minimum_Peak_Amplitude = ',num2str(QuaSOR_Parameters.GMM.Minimum_Peak_Amplitude)])
    if exist('QuaSOR_Parameters.GMM.Minimum_Peak_Amplitude_EpisodeDelta')
        disp(['QuaSOR_Parameters.GMM.Minimum_Peak_Amplitude_EpisodeDelta = ',num2str(QuaSOR_Parameters.GMM.Minimum_Peak_Amplitude_EpisodeDelta)])
    end
    disp(['QuaSOR_Parameters.GMM.MinDistance = ',num2str(QuaSOR_Parameters.GMM.MinDistance)])
    disp(['QuaSOR_Parameters.GMM.NumCompPenalty = ',num2str(QuaSOR_Parameters.GMM.NumCompPenalty)])
    disp(['QuaSOR_Parameters.GMM.Corr_Score_Scalar = ',num2str(QuaSOR_Parameters.GMM.Corr_Score_Scalar)])
    disp(['QuaSOR_Parameters.Dist_Weights.Amp_Score.Scalar = ',num2str(QuaSOR_Parameters.Dist_Weights.Amp_Score.Scalar)])
    disp(['QuaSOR_Parameters.Dist_Weights.Var_Score.Scalar = ',num2str(QuaSOR_Parameters.Dist_Weights.Var_Score.Scalar)])
    disp(['QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Scalar = ',num2str(QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Scalar)])
    disp(['QuaSOR_Parameters.Dist_Weights.Cov_Score.Scalar = ',num2str(QuaSOR_Parameters.Dist_Weights.Cov_Score.Scalar)])
    disp('========================')
    if QuaSOR_Parameters.Region.FixedROISize
        fprintf('Using a Fixed Size ROI...\n')
    else
        fprintf('Using Adaptive ROIs...\n')
        fprintf(['NOTE: Using CorrAmp for Fitting\n'])
        fprintf(['NOTE: Max ROI Size: ',num2str(QuaSOR_Parameters.Region.Max_Region_Area_px2),'\n'])
    end
    disp('========================================================================')
    disp('========================================================================')
    disp('========================================================================')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if ~SplitEpisodeFiles
        FileSuffix=['_EventDetectionData.mat'];
        fprintf(['Loading... ',StackSaveName,FileSuffix,' From CurrentScratchDir...']);
        load([CurrentScratchDir,dc,StackSaveName,FileSuffix],'EventDetectionStruct')
        fprintf('Finished!\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %Main Processing
    disp('========================================================================')
    disp('========================================================================')
    disp('========================================================================')
    disp(['Starting Main QuaSOR Processing on ',StackSaveName])
    disp(['QuaSOR Mode = ',num2str(QuaSOR_Parameters.QuaSOR_Mode)])
    pause(1)
    switch QuaSOR_Parameters.QuaSOR_Mode
        case 1
            error('QuaSOR_Parameters.QuaSOR_Mode 1 is not up to date but 2 should work fine')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             DeltaFF0_Stack=EpisodeArray_CorrAmp_Events_Thresh_Clean_Norm;
%             DeltaFF0_Stack(isnan(DeltaFF0_Stack))=0;
%             Max_Stack=EpisodeArray_Max_Sharp;
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %Run on each stimulus EpisodeNumber
%             for EpisodeNumber=1:ImagingInfo.NumEpisodes
%                 EpisodeTimer=tic;
% 
%                 fprintf(['Episode ',num2str(EpisodeNumber),'/',num2str(ImagingInfo.NumEpisodes),': ','Splitting Regions...'])
% 
% 
%                 DeltaFF0_Image=DeltaFF0_Stack(:,:,EpisodeNumber);
%                 if QuaSOR_Parameters.GMM.FitFiltered
%                     DeltaFF0_Image=imfilter(DeltaFF0_Image,fspecial('gaussian', QuaSOR_Parameters.GMM.PreFit_FilterSize_px, QuaSOR_Parameters.GMM.PreFit_FilterSigma_px));
%                 end        
%                 QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image=DeltaFF0_Image;
% 
%                 Max_Image=Max_Stack(:,:,EpisodeNumber);
%                 NumMaxEvents=sum(Max_Image(:));               
%                 [Pixel_Max_Locations(EpisodeNumber).Max_YCoord,Pixel_Max_Locations(EpisodeNumber).Max_XCoord]=ind2sub(size(Max_Stack(:,:,EpisodeNumber)), find(Max_Stack(:,:,EpisodeNumber)==1));
%                 QuaSOR_Fitting_Data(EpisodeNumber).Pixel_Max_Locations=horzcat(Pixel_Max_Locations(EpisodeNumber).Max_YCoord,Pixel_Max_Locations(EpisodeNumber).Max_XCoord);
% 
% 
%                 if isempty(Fit_Frame)||Fit_Frame==0
%                 else
%                     error('UPDATE!')
%                     load([StackSaveName,'_GFPs_',num2str(EpisodeNumber),'.mat'],'ImageArray_WithStim_DeltaGFPn')
%                     DeltaFF0_Alternative_Image=ImageArray_WithStim_DeltaGFPn(:,:,Fit_Frame);
%                     if QuaSOR_Parameters.GMM.FitFiltered
%                         DeltaFF0_Alternative_Image=imfilter(DeltaFF0_Alternative_Image,fspecial('gaussian', QuaSOR_Parameters.GMM.PreFit_FilterSize_px, QuaSOR_Parameters.GMM.PreFit_FilterSigma_px));
%                     end
%                     DeltaFF0_Alternative_Image(DeltaFF0_Alternative_Image<QuaSOR_Parameters.GMM.Minimum_Peak_Amplitude)=0;
%                     QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Alternative_Image=DeltaFF0_Alternative_Image;            
%                     DeltaFF0_Alternative_Image(DeltaFF0_Alternative_Image<QuaSOR_Parameters.GMM.Minimum_Peak_Amplitude)=0;
% 
%                 end
% 
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 %Split into smaller regions 
%                 clear QuaSOR_Fits AnalysisRegions
%                 QuaSOR_Fits=[];
%                 AnalysisRegions=[];
%                 %Make a mask for all events and apply a threshold to get regions to split    
%                 if isempty(Fit_Frame)||Fit_Frame==0
%                     TempDeltaFF0_Image=QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image;
%                 else
%                     TempDeltaFF0_Image=QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Alternative_Image;
%                 end
%                 if QuaSOR_Parameters.GMM.FitFiltered
%                     TempDeltaFF0_Image=imfilter(TempDeltaFF0_Image, fspecial('gaussian', QuaSOR_Parameters.GMM.PreFit_FilterSize_px, QuaSOR_Parameters.GMM.PreFit_FilterSigma_px));
%                 end
%                 TempDeltaFF0_Image(TempDeltaFF0_Image<=QuaSOR_Parameters.Region.RegionSplitting_Threshold)=0;
%                 TempDeltaFF0_Image(isnan(TempDeltaFF0_Image))=0;
%                 TempDeltaFF0_Image_Mask=logical(TempDeltaFF0_Image);
%                 Initial_AnalysisRegions.Components=bwconncomp(TempDeltaFF0_Image_Mask);
%                 Initial_AnalysisRegions.RegionProps=regionprops(Initial_AnalysisRegions.Components,'Centroid','BoundingBox');
%                 clear TempDeltaFF0_Image TempDeltaFF0_Image_Mask
%         %         figure(); subtightplot(1,1,1,[0.01,0.01],[0,0],[0,0])
%         %         if isempty(Fit_Frame)||Fit_Frame==0
%         %             imagesc(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image),axis equal tight,caxis([0,max(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image(:)*0.8)]),colormap jet
%         %         else
%         %             imagesc(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Alternative_Image),axis equal tight,caxis([0,max(DeltaFF0_Alternative_Image(:)*0.8)]),colormap jet
%         %         end
%         %         hold all
%         %         for z=1:size(Initial_AnalysisRegions.RegionProps,1)
%         %             PlotBox(Initial_AnalysisRegions.RegionProps(z).BoundingBox,'-','y',1,[],15,'y')
%         %             Initial_AnalysisRegions.RegionProps(z).Area=Initial_AnalysisRegions.RegionProps(z).BoundingBox(3)*Initial_AnalysisRegions.RegionProps(z).BoundingBox(4);
%         %             disp(num2str(Initial_AnalysisRegions.RegionProps(z).Area))
%         %         end        
%                 %Check and adjust region sizes so that extra large regions are split if possible
%                 count=0;
%                 for z=1:length(Initial_AnalysisRegions.RegionProps)
%                     Initial_AnalysisRegions.RegionProps(z).Area=Initial_AnalysisRegions.RegionProps(z).BoundingBox(3)*Initial_AnalysisRegions.RegionProps(z).BoundingBox(4);
%                     %disp(num2str(Initial_AnalysisRegions.RegionProps(z).Area))
%                     if Initial_AnalysisRegions.RegionProps(z).Area<QuaSOR_Parameters.Region.Max_Region_Area_px2&&Initial_AnalysisRegions.RegionProps(z).Area>QuaSOR_Parameters.Region.Min_Region_Area_px2
%                         count=count+1;
%                         AnalysisRegions(count).RegionProps=Initial_AnalysisRegions.RegionProps(z);
%                     elseif Initial_AnalysisRegions.RegionProps(z).Area>=QuaSOR_Parameters.Region.Max_Region_Area_px2
% 
%                         Initial_AnalysisRegions.RegionProps(z).BoundingBox=[ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(1)),ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(2)),ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(3)),ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(4))];
% 
%                         XCoords=ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(1)):ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(1))+ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(3));
%                         YCoords=ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(2)):ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(2))+ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(4));
% 
%                         XAdjust=0;
%                         YAdjust=0;
%                         if any(XCoords<1)
%                             XAdjust=XAdjust+sum(XCoords<1);
%                             XCoords=XCoords(1+XAdjust):XCoords(length(XCoords));
%                         end
%                         if any(XCoords>ImageWidth)
%                             XAdjust=XAdjust-sum(XCoords>ImageWidth);
%                             XCoords=XCoords(1):XCoords(length(XCoords))+XAdjust;
%                         end       
%                         if any(YCoords<1)
%                             YAdjust=YAdjust+sum(YCoords<1);
%                             YCoords=YCoords(1+YAdjust):YCoords(length(YCoords));
%                         end
%                         if any(YCoords>ImageHeight)
%                             YAdjust=YAdjust-sum(YCoords>ImageHeight);
%                             YCoords=YCoords(1):YCoords(length(YCoords))+YAdjust;
%                         end
%                         RegionMask=zeros(size(DeltaFF0_Image));
%                         RegionMask(YCoords,XCoords)=1;
%                         if isempty(Fit_Frame)||Fit_Frame==0
%                             TempDeltaFF0_Image= QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image;
%                         else
%                             TempDeltaFF0_Image=QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Alternative_Image;
%                         end
%                         if QuaSOR_Parameters.GMM.FitFiltered
%                             TempDeltaFF0_Image=imfilter(TempDeltaFF0_Image, fspecial('gaussian', QuaSOR_Parameters.GMM.PreFit_FilterSize_px, QuaSOR_Parameters.GMM.PreFit_FilterSigma_px));
%                         end
%                         TempDeltaFF0_Image2=TempDeltaFF0_Image;
%                         %TempDeltaFF0_Image2(TempDeltaFF0_Image2==0)=NaN;
%                         ThreshTest=1;
%                         cont=1;
%                         while cont
%                             TempDeltaFF0_Image=TempDeltaFF0_Image.*RegionMask;
%                             TempDeltaFF0_Image(TempDeltaFF0_Image<=QuaSOR_Parameters.Region.RegionSplitting_Threshold+QuaSOR_Parameters.Region.RegionSplitting_Threshold_Increase*ThreshTest)=0;
%         %                     Temp=TempDeltaFF0_Image2;
%         %                     Temp(TempDeltaFF0_Image<QuaSOR_Parameters.Region.RegionSplitting_Threshold+QuaSOR_Parameters.Region.RegionSplitting_Threshold_Increase*(ThreshTest-1))=0;
%         %                     Temp(TempDeltaFF0_Image>QuaSOR_Parameters.Region.RegionSplitting_Threshold+QuaSOR_Parameters.Region.RegionSplitting_Threshold_Increase*ThreshTest)=0;
%         %                     TempDeltaFF0_Image3=TempDeltaFF0_Image2.*RegionMask;
%         %                     NumTotalPixels=sum(logical(TempDeltaFF0_Image3(:)));
%         %                     NumRemovingPixels=sum(logical(Temp(:)));
%         %                     PercentPixelsRemoved=NumRemovingPixels/NumTotalPixels
%                             %figure, imagesc(TempDeltaFF0_Image),axis equal tight
%                             TempDeltaFF0_Image(isnan(TempDeltaFF0_Image))=0;
%                             TempDeltaFF0_Image_Mask=logical(TempDeltaFF0_Image);
%                             SubRegion_AnalysisRegions.Components=bwconncomp(TempDeltaFF0_Image_Mask);
%                             SubRegion_AnalysisRegions.RegionProps=regionprops(SubRegion_AnalysisRegions.Components,'Centroid','BoundingBox');
%                             TempSizes=[];
%                             for y=1:length(SubRegion_AnalysisRegions.RegionProps)
%                                 SubRegion_AnalysisRegions.RegionProps(y).Area=SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(3)*SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(4);
%                                 TempSizes(y)=SubRegion_AnalysisRegions.RegionProps(y).Area;
%                                 %disp(num2str(Initial_AnalysisRegions.RegionProps(y).Area))
%                             end
% 
%                             for y=1:length(SubRegion_AnalysisRegions.RegionProps)
%                                 if SubRegion_AnalysisRegions.RegionProps(y).Area>QuaSOR_Parameters.Region.Min_Region_Area_px2&&SubRegion_AnalysisRegions.RegionProps(y).Area<=QuaSOR_Parameters.Region.Max_Region_Area_px2
%                                     count=count+1;
%                                     XCoords2=ceil(SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(1)):ceil(SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(1))+ceil(SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(3));
%                                     YCoords2=ceil(SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(2)):ceil(SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(2))+ceil(SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(4));
%                                     RegionMask(YCoords2,XCoords2)=0;
% 
%                                     if rem(ThreshTest,2)==0
%                                         SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(1)=SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(1)-QuaSOR_Parameters.General.BoxAdjustment;
%                                         SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(2)=SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(2)-QuaSOR_Parameters.General.BoxAdjustment;
%                                         SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(3)=SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(3)+QuaSOR_Parameters.General.BoxAdjustment*2;
%                                         SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(4)=SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(4)+QuaSOR_Parameters.General.BoxAdjustment*2;
%                                         SubRegion_AnalysisRegions.RegionProps(y).Area=SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(3)*SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(4);
%                                     end
%                                     AnalysisRegions(count).RegionProps=SubRegion_AnalysisRegions.RegionProps(y);
%         %                             hold on
%         %                             PlotBox(AnalysisRegions(count).RegionProps.BoundingBox,'-','y',1,[],15,'y')
%         %                             disp(num2str(AnalysisRegions(count).RegionProps.Area))
% 
%                                     Hold_TempDeltaFF0_Image=TempDeltaFF0_Image.*RegionMask;
% 
%                                 end
%                             end
%                             if any(TempSizes>QuaSOR_Parameters.Region.Max_Region_Area_px2)
%                                 ThreshTest=ThreshTest+1;
%                                 cont=1;
%                             else
%                                 clear SubRegion_AnalysisRegions TempSizes 
%                                 cont=0;
%                             end
% 
%                             if ThreshTest>40
%                                 count=count+1;
%                                 cont=0;
%                                 AnalysisRegions(count).RegionProps=Initial_AnalysisRegions.RegionProps(z);
%                             end
%                         end 
%                         clear TempDeltaFF0_Image TempDeltaFF0_Image_Mask RegionMask Hold_TempDeltaFF0_Image TempDeltaFF0_Image2 TempDeltaFF0_Image3
%                     end
%                 end
%                 clear Initial_AnalysisRegions
%                 %Pad the regions and adjust if too big at edges
%                 for z=1:length(AnalysisRegions)
% 
%                     AnalysisRegions(z).RegionProps.BoundingBox=ceil(AnalysisRegions(z).RegionProps.BoundingBox);
%                     AnalysisRegions(z).RegionProps.BoundingBox(1)=AnalysisRegions(z).RegionProps.BoundingBox(1)-QuaSOR_Parameters.Region.RegionEdge_Padding;
%                     AnalysisRegions(z).RegionProps.BoundingBox(2)=AnalysisRegions(z).RegionProps.BoundingBox(2)-QuaSOR_Parameters.Region.RegionEdge_Padding;
%                     AnalysisRegions(z).RegionProps.BoundingBox(3)=AnalysisRegions(z).RegionProps.BoundingBox(3)+QuaSOR_Parameters.Region.RegionEdge_Padding*2;
%                     AnalysisRegions(z).RegionProps.BoundingBox(4)=AnalysisRegions(z).RegionProps.BoundingBox(4)+QuaSOR_Parameters.Region.RegionEdge_Padding*2;
% 
%                     AnalysisRegions(z).XCoords=AnalysisRegions(z).RegionProps.BoundingBox(1):AnalysisRegions(z).RegionProps.BoundingBox(1)+AnalysisRegions(z).RegionProps.BoundingBox(3);
%                     AnalysisRegions(z).YCoords=AnalysisRegions(z).RegionProps.BoundingBox(2):AnalysisRegions(z).RegionProps.BoundingBox(2)+AnalysisRegions(z).RegionProps.BoundingBox(4);
%                     %Region_AnalysisRegions(z).XCoords=1:AnalysisRegions(z).RegionProps.BoundingBox(3);
%                     %Region_AnalysisRegions(z).YCoords=1:AnalysisRegions(z).RegionProps.BoundingBox(4);
%                     XAdjust=0;
%                     YAdjust=0;
%                     if any(AnalysisRegions(z).XCoords<1)
%                         XAdjust=XAdjust+sum(AnalysisRegions(z).XCoords<1);
%                         AnalysisRegions(z).XCoords=AnalysisRegions(z).XCoords(1+XAdjust):AnalysisRegions(z).XCoords(length(AnalysisRegions(z).XCoords));
%                         AnalysisRegions(z).RegionProps.BoundingBox(1)=1;
%                     end
%                     if any(AnalysisRegions(z).XCoords>ImageWidth)
%                         XAdjust=XAdjust-sum(AnalysisRegions(z).XCoords>ImageWidth);
%                         AnalysisRegions(z).XCoords=AnalysisRegions(z).XCoords(1):AnalysisRegions(z).XCoords(length(AnalysisRegions(z).XCoords))+XAdjust;
%                         AnalysisRegions(z).RegionProps.BoundingBox(3)=length(AnalysisRegions(z).XCoords);
%                     end       
%                     if any(AnalysisRegions(z).YCoords<1)
%                         YAdjust=YAdjust+sum(AnalysisRegions(z).YCoords<1);
%                         AnalysisRegions(z).YCoords=AnalysisRegions(z).YCoords(1+YAdjust):AnalysisRegions(z).YCoords(length(AnalysisRegions(z).YCoords));
%                         AnalysisRegions(z).RegionProps.BoundingBox(2)=1;
%                     end
%                     if any(AnalysisRegions(z).YCoords>ImageHeight)
%                         YAdjust=YAdjust-sum(AnalysisRegions(z).YCoords>ImageHeight);
%                         AnalysisRegions(z).YCoords=AnalysisRegions(z).YCoords(1):AnalysisRegions(z).YCoords(length(AnalysisRegions(z).YCoords))+YAdjust;
%                         AnalysisRegions(z).RegionProps.BoundingBox(4)=length(AnalysisRegions(z).YCoords);
%                     end
%                     AnalysisRegions(z).RegionProps.Area=AnalysisRegions(z).RegionProps.BoundingBox(3)*AnalysisRegions(z).RegionProps.BoundingBox(4);
%                 end
% 
%         %         figure(); subtightplot(1,1,1,[0.01,0.01],[0,0],[0,0])
%         %         if isempty(Fit_Frame)||Fit_Frame==0
%         %             imagesc(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image),axis equal tight,caxis([0,max(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image(:)*0.8)]),colormap jet
%         %         else
%         %             imagesc(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Alternative_Image),axis equal tight,caxis([0,max(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Alternative_Image(:)*0.8)]),colormap jet
%         %         end
%         %         hold all
%         %         for z=1:length(AnalysisRegions)
%         %             PlotBox(AnalysisRegions(z).RegionProps.BoundingBox,'-','m',1,[],15,'y')
%         %         end
% 
%                     %Add any remaining regions that might have been cropped above
%                     %Remove all good regions so we can add any remaining
%                     if isempty(Fit_Frame)||Fit_Frame==0
%                         TempDeltaFF0_Image= QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image;
%                     else
%                         TempDeltaFF0_Image=QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Alternative_Image;
%                     end
%                     for z=1:length(AnalysisRegions)
%                         NewMask=ones(size(TempDeltaFF0_Image));
%                         NewMask(AnalysisRegions(z).YCoords,AnalysisRegions(z).XCoords)=0;
%                         TempDeltaFF0_Image=TempDeltaFF0_Image.*NewMask;
%                     end
%                     if QuaSOR_Parameters.GMM.FitFiltered
%                         TempDeltaFF0_Image=imfilter(TempDeltaFF0_Image, fspecial('gaussian', QuaSOR_Parameters.GMM.PreFit_FilterSize_px, QuaSOR_Parameters.GMM.PreFit_FilterSigma_px));
%                     end            
%                     TempDeltaFF0_Image(TempDeltaFF0_Image<=QuaSOR_Parameters.Region.RegionSplitting_Threshold)=0;
%                     BW_test = bwareaopen(TempDeltaFF0_Image, QuaSOR_Parameters.Region.Min_Region_Area_px2*2, conndef(2, 'minimal'));
%                     TempDeltaFF0_Image=TempDeltaFF0_Image.*BW_test;
%                     TempDeltaFF0_Image(isnan(TempDeltaFF0_Image))=0;
%                     TempDeltaFF0_Image_Mask=logical(TempDeltaFF0_Image);
%                     if sum(TempDeltaFF0_Image_Mask(:))>=QuaSOR_Parameters.Region.Min_Region_Area_px2
%                         Initial_AnalysisRegions_Round2.Components=bwconncomp(TempDeltaFF0_Image_Mask);
%                         Initial_AnalysisRegions_Round2.RegionProps=regionprops(Initial_AnalysisRegions_Round2.Components,'Centroid','BoundingBox');
%                         clear TempDeltaFF0_Image TempDeltaFF0_Image_Mask
%                 %         figure(); subtightplot(1,1,1,[0.01,0.01],[0,0],[0,0])
%                 %         if isempty(Fit_Frame)||Fit_Frame==0
%                 %             imagesc(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image),axis equal tight,caxis([0,max(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image(:)*0.8)]),colormap jet
%                 %         else
%                 %             imagesc(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Alternative_Image),axis equal tight,caxis([0,max(DeltaFF0_Alternative_Image(:)*0.8)]),colormap jet
%                 %         end
%                 %         hold all
%                 %         for z=1:size(Initial_AnalysisRegions_Round2.RegionProps,1)
%                 %             PlotBox(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox,'-','y',1,[],15,'y')
%                 %             Initial_AnalysisRegions_Round2.RegionProps(z).Area=Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(3)*Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(4);
%                 %             disp(num2str(Initial_AnalysisRegions_Round2.RegionProps(z).Area))
%                 %         end        
% 
%                         %Check and adjust region sizes so that extra large regions are split if possible
%                         count=0;
%                         for z=1:length(Initial_AnalysisRegions_Round2.RegionProps)
%                             Initial_AnalysisRegions_Round2.RegionProps(z).Area=Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(3)*Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(4);
%                             %disp(num2str(Initial_AnalysisRegions_Round2.RegionProps(z).Area))
%                             if Initial_AnalysisRegions_Round2.RegionProps(z).Area<QuaSOR_Parameters.Region.Max_Region_Area_px2&&Initial_AnalysisRegions_Round2.RegionProps(z).Area>QuaSOR_Parameters.Region.Min_Region_Area_px2
%                                 count=count+1;
%                                 AnalysisRegions_Round2(count).RegionProps=Initial_AnalysisRegions_Round2.RegionProps(z);
%                             elseif Initial_AnalysisRegions_Round2.RegionProps(z).Area>=QuaSOR_Parameters.Region.Max_Region_Area_px2
% 
%                                 Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox=[ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(1)),ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(2)),ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(3)),ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(4))];
% 
%                                 XCoords=ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(1)):ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(1))+ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(3));
%                                 YCoords=ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(2)):ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(2))+ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(4));
% 
%                                 XAdjust=0;
%                                 YAdjust=0;
%                                 if any(XCoords<1)
%                                     XAdjust=XAdjust+sum(XCoords<1);
%                                     XCoords=XCoords(1+XAdjust):XCoords(length(XCoords))+XAdjust;
%                                 end
%                                 if any(XCoords>ImageWidth)
%                                     XAdjust=XAdjust-sum(XCoords>ImageWidth);
%                                     XCoords=XCoords(1):XCoords(length(XCoords))-XAdjust;
%                                 end       
%                                 if any(YCoords<1)
%                                     YAdjust=YAdjust+sum(YCoords<1);
%                                     YCoords=YCoords(1+YAdjust):YCoords(length(YCoords))+YAdjust;
%                                 end
%                                 if any(YCoords>ImageHeight)
%                                     YAdjust=YAdjust-sum(YCoords>ImageHeight);
%                                     YCoords=YCoords(1):YCoords(length(YCoords))-YAdjust;
%                                 end
%                                 RegionMask=zeros(size(DeltaFF0_Image));
%                                 RegionMask(YCoords,XCoords)=1;
%                                 if isempty(Fit_Frame)||Fit_Frame==0
%                                     TempDeltaFF0_Image= QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image;
%                                 else
%                                     TempDeltaFF0_Image=QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Alternative_Image;
%                                 end
%                                 if QuaSOR_Parameters.GMM.FitFiltered
%                                     TempDeltaFF0_Image=imfilter(TempDeltaFF0_Image, fspecial('gaussian', QuaSOR_Parameters.GMM.PreFit_FilterSize_px, QuaSOR_Parameters.GMM.PreFit_FilterSigma_px));
%                                 end
%                                 TempDeltaFF0_Image2=TempDeltaFF0_Image;
%                                 %TempDeltaFF0_Image2(TempDeltaFF0_Image2==0)=NaN;
%                                 ThreshTest=1;
%                                 cont=1;
%                                 while cont
%                                     TempDeltaFF0_Image=TempDeltaFF0_Image.*RegionMask;
%                                     TempDeltaFF0_Image(TempDeltaFF0_Image<=QuaSOR_Parameters.Region.RegionSplitting_Threshold+QuaSOR_Parameters.Region.RegionSplitting_Threshold_Increase*ThreshTest)=0;
%                 %                     Temp=TempDeltaFF0_Image2;
%                 %                     Temp(TempDeltaFF0_Image<QuaSOR_Parameters.Region.RegionSplitting_Threshold+QuaSOR_Parameters.Region.RegionSplitting_Threshold_Increase*(ThreshTest-1))=0;
%                 %                     Temp(TempDeltaFF0_Image>QuaSOR_Parameters.Region.RegionSplitting_Threshold+QuaSOR_Parameters.Region.RegionSplitting_Threshold_Increase*ThreshTest)=0;
%                 %                     TempDeltaFF0_Image3=TempDeltaFF0_Image2.*RegionMask;
%                 %                     NumTotalPixels=sum(logical(TempDeltaFF0_Image3(:)));
%                 %                     NumRemovingPixels=sum(logical(Temp(:)));
%                 %                     PercentPixelsRemoved=NumRemovingPixels/NumTotalPixels
%                                     %figure, imagesc(TempDeltaFF0_Image),axis equal tight
%                                     TempDeltaFF0_Image_Mask=logical(TempDeltaFF0_Image);
%                                     SubRegion_AnalysisRegions_Round2.Components=bwconncomp(TempDeltaFF0_Image_Mask);
%                                     SubRegion_AnalysisRegions_Round2.RegionProps=regionprops(SubRegion_AnalysisRegions_Round2.Components,'Centroid','BoundingBox');
%                                     TempSizes=[];
%                                     for y=1:length(SubRegion_AnalysisRegions_Round2.RegionProps)
%                                         SubRegion_AnalysisRegions_Round2.RegionProps(y).Area=SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(3)*SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(4);
%                                         TempSizes(y)=SubRegion_AnalysisRegions_Round2.RegionProps(y).Area;
%                                         %disp(num2str(Initial_AnalysisRegions_Round2.RegionProps(y).Area))
%                                     end
% 
%                                     for y=1:length(SubRegion_AnalysisRegions_Round2.RegionProps)
%                                         if SubRegion_AnalysisRegions_Round2.RegionProps(y).Area>QuaSOR_Parameters.Region.Min_Region_Area_px2&&SubRegion_AnalysisRegions_Round2.RegionProps(y).Area<=QuaSOR_Parameters.Region.Max_Region_Area_px2
%                                             count=count+1;
%                                             XCoords2=ceil(SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(1)):ceil(SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(1))+ceil(SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(3));
%                                             YCoords2=ceil(SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(2)):ceil(SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(2))+ceil(SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(4));
%                                             RegionMask(YCoords2,XCoords2)=0;
% 
%                                             if rem(ThreshTest,2)==0
%                                                 SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(1)=SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(1)-QuaSOR_Parameters.General.BoxAdjustment;
%                                                 SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(2)=SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(2)-QuaSOR_Parameters.General.BoxAdjustment;
%                                                 SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(3)=SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(3)+QuaSOR_Parameters.General.BoxAdjustment*2;
%                                                 SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(4)=SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(4)+QuaSOR_Parameters.General.BoxAdjustment*2;
%                                                 SubRegion_AnalysisRegions_Round2.RegionProps(y).Area=SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(3)*SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(4);
%                                             end
%                                             AnalysisRegions_Round2(count).RegionProps=SubRegion_AnalysisRegions_Round2.RegionProps(y);
%                 %                             hold on
%                 %                             PlotBox(AnalysisRegions_Round2(count).RegionProps.BoundingBox,'-','y',1,[],15,'y')
%                 %                             disp(num2str(AnalysisRegions_Round2(count).RegionProps.Area))
% 
%                                             Hold_TempDeltaFF0_Image=TempDeltaFF0_Image.*RegionMask;
% 
%                                         end
%                                     end
%                                     if any(TempSizes>QuaSOR_Parameters.Region.Max_Region_Area_px2)
%                                         ThreshTest=ThreshTest+1;
%                                         cont=1;
%                                     else
%                                         clear SubRegion_AnalysisRegions_Round2 TempSizes 
%                                         cont=0;
%                                     end
% 
%                                     if ThreshTest>40
%                                         count=count+1;
%                                         cont=0;
%                                         AnalysisRegions_Round2(count).RegionProps=Initial_AnalysisRegions_Round2.RegionProps(z);
%                                     end
%                                 end 
%                                 clear TempDeltaFF0_Image TempDeltaFF0_Image_Mask RegionMask Hold_TempDeltaFF0_Image TempDeltaFF0_Image2 TempDeltaFF0_Image3
%                             end
%                         end
%                         clear Initial_AnalysisRegions_Round2
% 
%                         %adjust if too big at edges
%                         if exist('AnalysisRegions_Round2')
%                             if ~isempty(AnalysisRegions_Round2)
%                                 for z=1:length(AnalysisRegions_Round2)
% 
%                                     AnalysisRegions_Round2(z).RegionProps.BoundingBox=ceil(AnalysisRegions_Round2(z).RegionProps.BoundingBox);
%                                     AnalysisRegions_Round2(z).RegionProps.BoundingBox(1)=AnalysisRegions_Round2(z).RegionProps.BoundingBox(1)-QuaSOR_Parameters.Region.RegionEdge_Padding;
%                                     AnalysisRegions_Round2(z).RegionProps.BoundingBox(2)=AnalysisRegions_Round2(z).RegionProps.BoundingBox(2)-QuaSOR_Parameters.Region.RegionEdge_Padding;
%                                     AnalysisRegions_Round2(z).RegionProps.BoundingBox(3)=AnalysisRegions_Round2(z).RegionProps.BoundingBox(3)+QuaSOR_Parameters.Region.RegionEdge_Padding*2;
%                                     AnalysisRegions_Round2(z).RegionProps.BoundingBox(4)=AnalysisRegions_Round2(z).RegionProps.BoundingBox(4)+QuaSOR_Parameters.Region.RegionEdge_Padding*2;
% 
%                                     AnalysisRegions_Round2(z).XCoords=AnalysisRegions_Round2(z).RegionProps.BoundingBox(1):AnalysisRegions_Round2(z).RegionProps.BoundingBox(1)+AnalysisRegions_Round2(z).RegionProps.BoundingBox(3);
%                                     AnalysisRegions_Round2(z).YCoords=AnalysisRegions_Round2(z).RegionProps.BoundingBox(2):AnalysisRegions_Round2(z).RegionProps.BoundingBox(2)+AnalysisRegions_Round2(z).RegionProps.BoundingBox(4);
%                                     %Region_AnalysisRegions_Round2(z).XCoords=1:AnalysisRegions_Round2(z).RegionProps.BoundingBox(3);
%                                     %Region_AnalysisRegions_Round2(z).YCoords=1:AnalysisRegions_Round2(z).RegionProps.BoundingBox(4);
%                                     XAdjust=0;
%                                     YAdjust=0;
%                                     if any(AnalysisRegions_Round2(z).XCoords<1)
%                                         XAdjust=XAdjust+sum(AnalysisRegions_Round2(z).XCoords<1);
%                                         AnalysisRegions_Round2(z).XCoords=AnalysisRegions_Round2(z).XCoords(1+XAdjust):AnalysisRegions_Round2(z).XCoords(length(AnalysisRegions_Round2(z).XCoords));
%                                         AnalysisRegions_Round2(z).RegionProps.BoundingBox(1)=1;
%                                     end
%                                     if any(AnalysisRegions_Round2(z).XCoords>ImageWidth)
%                                         XAdjust=XAdjust-sum(AnalysisRegions_Round2(z).XCoords>ImageWidth);
%                                         AnalysisRegions_Round2(z).XCoords=AnalysisRegions_Round2(z).XCoords(1):AnalysisRegions_Round2(z).XCoords(length(AnalysisRegions_Round2(z).XCoords))+XAdjust;
%                                         AnalysisRegions_Round2(z).RegionProps.BoundingBox(3)=length(AnalysisRegions_Round2(z).XCoords);
%                                     end       
%                                     if any(AnalysisRegions_Round2(z).YCoords<1)
%                                         YAdjust=YAdjust+sum(AnalysisRegions_Round2(z).YCoords<1);
%                                         AnalysisRegions_Round2(z).YCoords=AnalysisRegions_Round2(z).YCoords(1+YAdjust):AnalysisRegions_Round2(z).YCoords(length(AnalysisRegions_Round2(z).YCoords));
%                                         AnalysisRegions_Round2(z).RegionProps.BoundingBox(2)=1;
%                                     end
%                                     if any(AnalysisRegions_Round2(z).YCoords>ImageHeight)
%                                         YAdjust=YAdjust-sum(AnalysisRegions_Round2(z).YCoords>ImageHeight);
%                                         AnalysisRegions_Round2(z).YCoords=AnalysisRegions_Round2(z).YCoords(1):AnalysisRegions_Round2(z).YCoords(length(AnalysisRegions_Round2(z).YCoords))+YAdjust;
%                                         AnalysisRegions_Round2(z).RegionProps.BoundingBox(4)=length(AnalysisRegions_Round2(z).YCoords);
%                                     end
%                                     AnalysisRegions_Round2(z).RegionProps.Area=AnalysisRegions_Round2(z).RegionProps.BoundingBox(3)*AnalysisRegions_Round2(z).RegionProps.BoundingBox(4);
% 
%                                 end
%                             end
%                         end
% 
%                         %Merge Structures
%                         if exist('AnalysisRegions_Round2')
%                             if ~isempty(AnalysisRegions_Round2)
%                                 AnalysisRegions=cat(2,AnalysisRegions,AnalysisRegions_Round2);clear AnalysisRegions_Round2
%                             end
%                         end
%                     end
% 
% %                 if QuaSOR_Parameters.General.DisplayRegionTracking
% %                     if exist('RegionFig')
% %                         try
% %                             close(RegionFig)
% %                             clear RegionFig
% %                         catch
% %                             clear RegionFig
% %                         end
% %                     end
% %                      RegionFig=figure(); subtightplot(1,1,1,[0.01,0.01],[0,0],[0,0])
% %                     if isempty(Fit_Frame)||Fit_Frame==0
% %                         imagesc(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image),axis equal tight,caxis([0,1]),colormap jet
% %                     else
% %                         imagesc(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Alternative_Image),axis equal tight,caxis([0,max(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Alternative_Image(:)*0.8)]),colormap jet
% %                     end
% %                     hold on
% % 
% %                     if QuaSOR_Parameters.Display.UseBorderLine
% %                         for j=1:length(BorderLine)
% %                             plot(BorderLine{j}.BorderLine_Crop(:,2)+QuaSOR_Parameters.Display.BorderLineAdjustment, BorderLine{j}.BorderLine_Crop(:,1)+QuaSOR_Parameters.Display.BorderLineAdjustment,'-' , 'color', QuaSOR_Parameters.Display.BorderColor,'linewidth', QuaSOR_Parameters.Display.BorderThickness); 
% %                         end
% %                     else
% %                         plot(BorderX_Crop, BorderY_Crop,['s'] , 'MarkerEdgeColor', QuaSOR_Parameters.Display.BorderColor,'MarkerFaceColor', QuaSOR_Parameters.Display.BorderColor, 'MarkerSize', QuaSOR_Parameters.Display.BorderThickness,'LineWidth',QuaSOR_Parameters.Display.BorderThickness);
% %                     end
% %                     for z=1:length(AnalysisRegions)
% %                         PlotBox_Adjusted(AnalysisRegions(z).RegionProps.BoundingBox,'-','m',1,[],15,'y')
% %                         %disp(num2str(AnalysisRegions(z).RegionProps.Area))
% %                     end
% %                     text(LabelLocation(1),LabelLocation(2),[num2str(EpisodeNumber)],'color','w','FontName','Arial','FontSize',20)
% %                     plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',QuaSOR_Parameters.Display.BorderThickness);
% %                     set(gca,'XTick', []); set(gca,'YTick', []);
% %                     set(gcf,'units','normalized','position',[0.5,0,0.5,1])
% %                     drawnow
% %                 end
% 
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 %Add info to QuaSOR_Fits
%                 for z=1:length(AnalysisRegions)
%                     QuaSOR_Fits(z).XCoord=round(AnalysisRegions(z).RegionProps.Centroid(2));
%                     QuaSOR_Fits(z).YCoord=round(AnalysisRegions(z).RegionProps.Centroid(1));
%                     QuaSOR_Fits(z).YCoords=AnalysisRegions(z).YCoords;
%                     QuaSOR_Fits(z).XCoords=AnalysisRegions(z).XCoords;
%                     QuaSOR_Fits(z).RegionProps=AnalysisRegions(z).RegionProps;
%                     QuaSOR_Fits(z).NumReplicates=QuaSOR_Parameters.Components.NumReplicates;
%                 end
% 
%                 %Split Regions
%                 for z=1:length(AnalysisRegions)
%                     TestImage=zeros(AnalysisRegions(z).RegionProps.BoundingBox(4)-YAdjust,AnalysisRegions(z).RegionProps.BoundingBox(3)-XAdjust);
%                     if isempty(Fit_Frame)||Fit_Frame==0
%                         if AnalysisRegions(z).YCoords(1)>0&&...
%                                 AnalysisRegions(z).XCoords(1)>0&&...
%                                 AnalysisRegions(z).YCoords(length(AnalysisRegions(z).YCoords))<=size(DeltaFF0_Image,1)&&...
%                                 AnalysisRegions(z).XCoords(length(AnalysisRegions(z).XCoords))<=size(DeltaFF0_Image,2)
%                             TestImage=DeltaFF0_Image(AnalysisRegions(z).YCoords,AnalysisRegions(z).XCoords);
%                         else
%                             %Fix Regions that are off the edges
%                             if AnalysisRegions(z).YCoords(1)<1
%                                 Shift=sum(AnalysisRegions(z).YCoords<1);
%                                 AnalysisRegions(z).YCoords=AnalysisRegions(z).YCoords+Shift;
%                             end
%                             if AnalysisRegions(z).XCoords(1)<1
%                                 Shift=sum(AnalysisRegions(z).XCoords<1);
%                                 AnalysisRegions(z).XCoords=AnalysisRegions(z).XCoords+Shift;
%                             end
%                             if AnalysisRegions(z).YCoords(length(AnalysisRegions(z).YCoords))>size(DeltaFF0_Image,1)
%                                 Shift=sum(AnalysisRegions(z).YCoords>size(DeltaFF0_Image,1));
%                                 AnalysisRegions(z).YCoords=AnalysisRegions(z).YCoords-Shift;
%                             end
%                             if AnalysisRegions(z).XCoords(length(AnalysisRegions(z).XCoords))>size(DeltaFF0_Image,2)
%                                 Shift=sum(AnalysisRegions(z).XCoords>size(DeltaFF0_Image,2));
%                                 AnalysisRegions(z).XCoords=AnalysisRegions(z).XCoords-Shift;
%                             end
%                             TestImage=DeltaFF0_Image(AnalysisRegions(z).YCoords,AnalysisRegions(z).XCoords);
%                         end
%                     else
%                         if AnalysisRegions(z).YCoords(1)>0&&...
%                                 AnalysisRegions(z).XCoords(1)>0&&...
%                                 AnalysisRegions(z).YCoords(length(AnalysisRegions(z).YCoords))<=size(DeltaFF0_Image,1)&&...
%                                 AnalysisRegions(z).XCoords(length(AnalysisRegions(z).XCoords))<=size(DeltaFF0_Image,2)
%                             TestImage=DeltaFF0_Alternative_Image(AnalysisRegions(z).YCoords,AnalysisRegions(z).XCoords);
%                         else
%                             %Fix Regions that are off the edges
%                             if AnalysisRegions(z).YCoords(1)<1
%                                 Shift=sum(AnalysisRegions(z).YCoords<1);
%                                 AnalysisRegions(z).YCoords=AnalysisRegions(z).YCoords+Shift;
%                             end
%                             if AnalysisRegions(z).XCoords(1)<1
%                                 Shift=sum(AnalysisRegions(z).XCoords<1);
%                                 AnalysisRegions(z).XCoords=AnalysisRegions(z).XCoords+Shift;
%                             end
%                             if AnalysisRegions(z).YCoords(length(AnalysisRegions(z).YCoords))>size(DeltaFF0_Image,1)
%                                 Shift=sum(AnalysisRegions(z).YCoords>size(DeltaFF0_Image,1));
%                                 AnalysisRegions(z).YCoords=AnalysisRegions(z).YCoords-Shift;
%                             end
%                             if AnalysisRegions(z).XCoords(length(AnalysisRegions(z).XCoords))>size(DeltaFF0_Image,2)
%                                 Shift=sum(AnalysisRegions(z).XCoords>size(DeltaFF0_Image,2));
%                                 AnalysisRegions(z).XCoords=AnalysisRegions(z).XCoords-Shift;
%                             end
%                             TestImage=DeltaFF0_Alternative_Image(AnalysisRegions(z).YCoords,AnalysisRegions(z).XCoords);
%                         end
%                     end
%                     TestImage(isnan(TestImage))=0;
%                     QuaSOR_Fits(z).TestImage=TestImage;
% 
%                     if QuaSOR_Parameters.Region.SuppressBorder
%                         Mask=ones(size(QuaSOR_Fits(z).TestImage));
%                         Mask(QuaSOR_Parameters.Region.SuppressBorderSize+1:size(Mask,1)-QuaSOR_Parameters.Region.SuppressBorderSize,QuaSOR_Parameters.Region.SuppressBorderSize+1:size(Mask,2)-QuaSOR_Parameters.Region.SuppressBorderSize)=0;
%                         Mask=Mask*QuaSOR_Parameters.Region.SuppressBorderRatio;
%                         Mask(Mask==0)=1;
%                         QuaSOR_Fits(z).TestImage=QuaSOR_Fits(z).TestImage.*Mask;
%                     end
%                     QuaSOR_Fits(z).TestImage_Z_Scaled=round(QuaSOR_Fits(z).TestImage/(max(QuaSOR_Fits(z).TestImage(:)/QuaSOR_Parameters.General.ScalePoint_Scalar)));
%                     QuaSOR_Fits(z).TestImage_Filt = imfilter(QuaSOR_Fits(z).TestImage, fspecial('gaussian', QuaSOR_Parameters.GMM.PreFit_FilterSize_px, QuaSOR_Parameters.GMM.PreFit_FilterSigma_px)); 
%                     QuaSOR_Fits(z).TestImage_Filt_Z_Scaled=round(QuaSOR_Fits(z).TestImage_Filt/(max(QuaSOR_Fits(z).TestImage_Filt(:)/QuaSOR_Parameters.General.ScalePoint_Scalar)));
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     %convert intensity data into scaled point density representation for unfiltered and filtered data
%                     Count=0;
%                     QuaSOR_Fits(z).ScalePoints=[];
%                     for i=1:size(QuaSOR_Fits(z).TestImage,1)
%                         for j=1:size(QuaSOR_Fits(z).TestImage,2)
%                             for k=1:QuaSOR_Fits(z).TestImage_Z_Scaled(i,j)
%                                 Count=Count+1;
%                                 QuaSOR_Fits(z).ScalePoints(Count,:)=[i,j];
%                             end
%                         end
%                     end
%                     Count=0;
%                     QuaSOR_Fits(z).ScalePoints_Filt=[];
%                     for i=1:size(QuaSOR_Fits(z).TestImage_Filt,1)
%                         for j=1:size(QuaSOR_Fits(z).TestImage_Filt,2)
%                             for k=1:QuaSOR_Fits(z).TestImage_Filt_Z_Scaled(i,j)
%                                 Count=Count+1;
%                                 QuaSOR_Fits(z).ScalePoints_Filt(Count,:)=[i,j];
%                             end
%                         end
%                     end
%                 end
% 
%                 %Set up structure elements prior to parallel processing
%                 for z=1:length(AnalysisRegions)
%                     for i=1:QuaSOR_Parameters.Components.MaxAllowed_NumReplicates
%                         for j=1:QuaSOR_Parameters.Components.MaxAllowed_NumGaussians
%                             QuaSOR_Fits(z).AllFitTests(i,j)=struct('GaussianFitModel',[]);
%                         end
%                     end
%                     QuaSOR_Fits(z).NumResets=0;
%                     QuaSOR_Fits(z).QuaSOR_Parameters.Components.NumReplicates=QuaSOR_Parameters.Components.NumReplicates;
%                     QuaSOR_Fits(z).PooledScoreTotals=zeros(QuaSOR_Parameters.Components.MaxAllowed_NumReplicates,QuaSOR_Parameters.Components.MaxAllowed_NumGaussians);
%                     QuaSOR_Fits(z).Successful_Fit=[];
%                     QuaSOR_Fits(z).Best_NumGaussian=[];
%                     QuaSOR_Fits(z).Best_Replicate=[];
%                     QuaSOR_Fits(z).Best_GaussianFitModel=[];
%                     QuaSOR_Fits(z).Best_GaussianFitTest=[];
%                     QuaSOR_Fits(z).Best_GaussianFitImage=zeros(size(QuaSOR_Fits(z).TestImage));
%                     QuaSOR_Fits(z).BestGaussianFitModel_Clean.mu=[];
%                     QuaSOR_Fits(z).BestGaussianFitModel_Clean.Sigma=[];
%                     QuaSOR_Fits(z).BestGaussianFitModel_Clean.NumComponents=[];
%                     QuaSOR_Fits(z).BestGaussianFitModel_Clean.ComponentProportion=[];    
%                 end
% 
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
% %                 if QuaSOR_Parameters.General.DisplayOn
% %                     figure
% %                     subtightplot(1,1,1,[0.0,0.0],[0,0],[0,0])
% %                     imagesc(DeltaFF0_Stack(:,:,EpisodeNumber)),axis equal tight,caxis([0,max(max(DeltaFF0_Stack(:,:,EpisodeNumber))*0.8)]),colormap jet
% %                     hold all
% %                     if QuaSOR_Parameters.Display.UseBorderLine
% %                         for j=1:length(BorderLine)
% %                             plot(BorderLine{j}.BorderLine_Crop(:,2)+QuaSOR_Parameters.Display.BorderLineAdjustment, BorderLine{j}.BorderLine_Crop(:,1)+QuaSOR_Parameters.Display.BorderLineAdjustment,'-' , 'color', QuaSOR_Parameters.Display.BorderColor,'linewidth', QuaSOR_Parameters.Display.BorderThickness); 
% %                         end
% %                     else
% %                         plot(BorderX_Crop, BorderY_Crop,['s'] , 'MarkerEdgeColor', QuaSOR_Parameters.Display.BorderColor,'MarkerFaceColor', QuaSOR_Parameters.Display.BorderColor, 'MarkerSize', QuaSOR_Parameters.Display.BorderThickness,'LineWidth',QuaSOR_Parameters.Display.BorderThickness);
% %                     end
% %                     %text(LabelLocation(1),LabelLocation(2),['Stim #',num2str(EpisodeNumber),' => ',num2str(Vector_OQA_NumEvents(EpisodeNumber)),' OQA Events'],'color','w','FontName','Arial','FontSize',20)
% %                     plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',QuaSOR_Parameters.Display.BorderThickness);
% %                     set(gca,'XTick', []); set(gca,'YTick', []);
% %                     set(gcf,'units','normalized','position',[0,0,0.5,0.5])
% %                     %set(gca,'units','normalized','position',[0,0,1,1])
% % 
% %                     for z=1:length(AnalysisRegions)
% %                         PlotBox(AnalysisRegions(z).RegionProps.BoundingBox,'-','y',1,num2str(z),15,'y')
% %                     end
% %                 end
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %Region Mode
%                 for x=1:20
%                     fprintf('\b');
%                 end
%                 if ~isempty(AnalysisRegions)
%                     fprintf([num2str(length(AnalysisRegions)),' Regions ==> Fitting in Parallel Mode...'])
%                 else
%                     fprintf(['NO REGIONS FOUND! '])
%                 end
% 
%                 parfor z=1:length(AnalysisRegions)
%                     warning off
%                     General=QuaSOR_Parameters.General;
%                     UpScaling=QuaSOR_Parameters.UpScaling;
%                     Display=QuaSOR_Parameters.Display;
%                     Region=QuaSOR_Parameters.Region;
%                     Components=QuaSOR_Parameters.Components;
%                     GMM=QuaSOR_Parameters.GMM;
%                     Dist_Weights=QuaSOR_Parameters.Dist_Weights;
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Temp_MaxVar=Dist_Weights.Var_Score.Hist_XData(length(Dist_Weights.Var_Score.Hist_XData));
%                     Temp_MaxCov=Dist_Weights.Cov_Score.Hist_XData(length(Dist_Weights.Cov_Score.Hist_XData));
%                     Temp_MaxVarDiff=Dist_Weights.Var_Diff_Score.Hist_XData(length(Dist_Weights.Var_Diff_Score.Hist_XData));
%                     MaxNumGaussians=Components.MaxNumGaussians;%Increase if no good matches are found
%                     GMDistFitOptions=GMM.GMDistFitOptions;
%                     InternalReplicates=GMM.InternalReplicates;
%                     %Run All Fits first
%                     if General.DisplayOn
%                         progressbar('Components','Replicates');
%                     end
%                     %for j=1:Components.MaxNumGaussians
%                     Searching=1;
%                     Success=0;
%                     NumResets=0;
%                     j=1;
%                     while Searching 
%                         for i=1:QuaSOR_Fits(z).NumReplicates
%                             QuaSOR_Fits(z).AllFitTests(i,j).ScoreTotal=[];
%                             QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp=[];
%                             if General.DisplayOn
%                                 progressbar((j-1)/MaxNumGaussians,i/QuaSOR_Fits(z).NumReplicates)
%                             end
%                             %Run Fitting
%                             cont=1;
%                             while cont
%                                 if GMM.FitFiltered
%                                     GaussianFitModel=fitgmdist(QuaSOR_Fits(z).ScalePoints_Filt,(j),'Start',GMM.StartCondition,'Regularize', GMM.RegularizationValue,'replicates',InternalReplicates,'options',GMDistFitOptions);
%                                 else
%                                     GaussianFitModel=fitgmdist(QuaSOR_Fits(z).ScalePoints,(j),'Start',GMM.StartCondition,'Regularize', GMM.RegularizationValue,'replicates',InternalReplicates,'options',GMDistFitOptions);
%                                 end
%                                 if any(GaussianFitModel.ComponentProportion==0)||any(GaussianFitModel.mu(:)==0)
%                                     cont=1;
%                                 else
%                                     cont=0;
%                                     QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel=GaussianFitModel;
%                                 end
%                             end
%                             %Calculate Distances
%                             QuaSOR_Fits(z).AllFitTests(i,j).DistanceMatrix=zeros(QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.NumComponents);
%                             for m=1:QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.NumComponents
%                                 for n=1:QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.NumComponents
%                                     QuaSOR_Fits(z).AllFitTests(i,j).DistanceMatrix(m,n)=sqrt((QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.mu(m,1)-QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.mu(n,1))^2+(QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.mu(m,2)-QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.mu(n,2))^2);
%                                 end
%                             end
%                             QuaSOR_Fits(z).AllFitTests(i,j).DistanceMatrix(QuaSOR_Fits(z).AllFitTests(i,j).DistanceMatrix==0)=NaN;
%                             %Calculate Amplitudes
%                             for k=1:QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.NumComponents
%                                 %Calculate an approximate amplitude based on the mu location
%                                 MaxAmp=max(QuaSOR_Fits(z).TestImage(:));
%                                 QuaSOR_Fits(z).AllFitTests(i,j).Amp(k)=QuaSOR_Fits(z).TestImage(round(QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.mu(k,1)),round(QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.mu(k,2)));
%                                 %Calculate an approximate amplitude based on the component proportion of the fits
%                                 QuaSOR_Fits(z).AllFitTests(i,j).Amp_Scaled(k)=MaxAmp*QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.ComponentProportion(k);
%                             end
%                             %Flag if the gaussian params are not within the mini
%                             %range or if the amplitude is too low (probably latched
%                             %onto noise, especially if using unfiltered data
%                             FLAGGED=0;
%                             for k=1:QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.NumComponents %Flag any Gaussians that arent within the hist ranges
%                                 TestSigma=QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.Sigma(:,:,k);
%                                 if TestSigma(1,1)>Temp_MaxVar||TestSigma(2,2)>Temp_MaxVar
%                                     FLAGGED=1;
%                                 end
%                                 if abs(TestSigma(1,2))>Temp_MaxCov
%                                     FLAGGED=1;
%                                 end
%                                 if abs(TestSigma(1,1)-TestSigma(2,2))>Temp_MaxVarDiff
%                                     FLAGGED=1;
%                                 end
%                                 if QuaSOR_Fits(z).AllFitTests(i,j).Amp(k)<GMM.Minimum_Peak_Amplitude
%                                         FLAGGED=1;
%                                 end
% 
%                             end
% 
%                             if any(QuaSOR_Fits(z).AllFitTests(i,j).DistanceMatrix(:)<GMM.MinDistance)%Dont allow any options with centers too close together or
%                                 QuaSOR_Fits(z).AllFitTests(i,j).ScoreTotal=0;
%                                 QuaSOR_Fits(z).PooledScoreTotals(i,j)=QuaSOR_Fits(z).AllFitTests(i,j).ScoreTotal;
%                             elseif FLAGGED %Dont allow if parameters fall outside the histogram ranges
%                                 QuaSOR_Fits(z).AllFitTests(i,j).ScoreTotal=0;
%                                 QuaSOR_Fits(z).PooledScoreTotals(i,j)=QuaSOR_Fits(z).AllFitTests(i,j).ScoreTotal;
%                             else
%                                 %Scale by mu amplitude at that location or component proportion relative to the max amplitude
%                                 x = 1:size(QuaSOR_Fits(z).TestImage,2); y = 1:size(QuaSOR_Fits(z).TestImage,1);
%                                 [X,Y] = meshgrid(x,y);
%                                 QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp=zeros(length(y),length(x));
%                                 QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp_Scaled=zeros(length(y),length(x));
%                                 for k=1:QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.NumComponents
% 
%                                     %flip sigma on diagonal
%                                     TestSigma=QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.Sigma(:,:,k);
%                                     temp1=TestSigma(1,1);
%                                     temp2=TestSigma(2,2);
%                                     TestSigma(1,1)=temp2;TestSigma(2,2)=temp1;
% 
%                                     %less accurate
%                                     F1 = mvnpdf([X(:) Y(:)],fliplr(QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.mu(k,:)),TestSigma);
%                                     F1 = reshape(F1,length(y),length(x));
%                                     F1=(F1/max(F1(:)))*QuaSOR_Fits(z).AllFitTests(i,j).Amp_Scaled(k);
%                                     QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp_Scaled=QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp_Scaled+F1;
% 
%                                     %maybe more accurate with well isolated spots
%                                     F1 = mvnpdf([X(:) Y(:)],fliplr(QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.mu(k,:)),TestSigma);
%                                     F1 = reshape(F1,length(y),length(x));
%                                     F1=(F1/max(F1(:)))*QuaSOR_Fits(z).AllFitTests(i,j).Amp(k);
%                                     QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp=QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp+F1;
% 
%                                     %All Weighting Score calculaitons
% 
%                                     %More accurate of the two amp score weights
%                                     tmp = abs(Dist_Weights.Amp_Score.Hist_XData-QuaSOR_Fits(z).AllFitTests(i,j).Amp_Scaled(k));
%                                     [~, idx] = min(tmp);
%                                     QuaSOR_Fits(z).AllFitTests(i,j).Amp_Scaled_Score(k)=(Dist_Weights.Amp_Score.Norm_Hist_Shift(idx))*Dist_Weights.Amp_Score.Scalar;
% 
%                                     %Not using this score right now
%                                     tmp = abs(Dist_Weights.Amp_Score.Hist_XData-QuaSOR_Fits(z).AllFitTests(i,j).Amp(k));
%                                     [~, idx] = min(tmp);
%                                     QuaSOR_Fits(z).AllFitTests(i,j).Amp_Score(k)=(Dist_Weights.Amp_Score.Norm_Hist_Shift(idx))*Dist_Weights.Amp_Score.Scalar;
% 
%                                     tmp = abs(Dist_Weights.Var_Score.Hist_XData-TestSigma(1,1));
%                                     [~, idx] = min(tmp);
%                                     QuaSOR_Fits(z).AllFitTests(i,j).Var_Score(k,1)=(Dist_Weights.Var_Score.Norm_Hist_Shift(idx))*Dist_Weights.Var_Score.Scalar;
% 
%                                     tmp = abs(Dist_Weights.Var_Score.Hist_XData-TestSigma(2,2));
%                                     [~, idx] = min(tmp);
%                                     QuaSOR_Fits(z).AllFitTests(i,j).Var_Score(k,2)=(Dist_Weights.Var_Score.Norm_Hist_Shift(idx))*Dist_Weights.Var_Score.Scalar;
% 
%                                     tmp = abs(Dist_Weights.Cov_Score.Hist_XData-(abs(TestSigma(1,2))));
%                                     [~, idx] = min(tmp);
%                                     QuaSOR_Fits(z).AllFitTests(i,j).Cov_Score(k)=(Dist_Weights.Cov_Score.Norm_Hist_Shift(idx))*Dist_Weights.Cov_Score.Scalar;
% 
%                                     tmp = abs(Dist_Weights.Var_Diff_Score.Hist_XData-abs(TestSigma(1,1)-TestSigma(2,2)));
%                                     [~, idx] = min(tmp);
%                                     QuaSOR_Fits(z).AllFitTests(i,j).Var_Diff_Score(k)=(Dist_Weights.Var_Diff_Score.Norm_Hist_Shift(idx))*Dist_Weights.Var_Diff_Score.Scalar;
% 
%                                 end
%                                 if GMM.TestFiltered
%                                     TestCorr = normxcorr2(QuaSOR_Fits(z).TestImage_Filt,QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp);
%                                     QuaSOR_Fits(z).AllFitTests(i,j).CorrCoef = corr2(QuaSOR_Fits(z).TestImage_Filt,QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp);
%                                 else
%                                     TestCorr = normxcorr2(QuaSOR_Fits(z).TestImage,QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp);
%                                     QuaSOR_Fits(z).AllFitTests(i,j).CorrCoef = corr2(QuaSOR_Fits(z).TestImage,QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp);
%                                 end
%                                 QuaSOR_Fits(z).AllFitTests(i,j).Max_NormCorr2=max(TestCorr(:));
%                                 QuaSOR_Fits(z).AllFitTests(i,j).Max_NormCorr2_Score=QuaSOR_Fits(z).AllFitTests(i,j).Max_NormCorr2*GMM.Corr_Score_Scalar; %Not used right now
% 
%                                 QuaSOR_Fits(z).AllFitTests(i,j).CorrCoef_Score=QuaSOR_Fits(z).AllFitTests(i,j).CorrCoef*GMM.Corr_Score_Scalar;
% 
%                                 if GMM.PenalizeMoreComponents
%                                     QuaSOR_Fits(z).AllFitTests(i,j).Pentalty=(j-1)*GMM.NumCompPenalty;
%                                 else
%                                     QuaSOR_Fits(z).AllFitTests(i,j).Pentalty=0;
%                                 end
%                                 QuaSOR_Fits(z).AllFitTests(i,j).MaxVar=Temp_MaxVar;
%                                 QuaSOR_Fits(z).AllFitTests(i,j).MaxCov=Temp_MaxCov;
%                                 QuaSOR_Fits(z).AllFitTests(i,j).MaxVarDiff=Temp_MaxVarDiff;
%                                 QuaSOR_Fits(z).AllFitTests(i,j).GMM.GMDistFitOptions.MaxIter=GMDistFitOptions.MaxIter;
%                                 QuaSOR_Fits(z).AllFitTests(i,j).AllScores=[QuaSOR_Fits(z).AllFitTests(i,j).CorrCoef_Score,...
%                                     QuaSOR_Fits(z).AllFitTests(i,j).Max_NormCorr2_Score...
%                                     QuaSOR_Fits(z).AllFitTests(i,j).Pentalty,...
%                                     mean(QuaSOR_Fits(z).AllFitTests(i,j).Amp_Scaled),...
%                                     mean(QuaSOR_Fits(z).AllFitTests(i,j).Var_Score(:)),...
%                                     mean(QuaSOR_Fits(z).AllFitTests(i,j).Cov_Score),...
%                                     mean(QuaSOR_Fits(z).AllFitTests(i,j).Var_Diff_Score)];
%                                 QuaSOR_Fits(z).AllFitTests(i,j).ScoreTotal=sum(QuaSOR_Fits(z).AllFitTests(i,j).AllScores);
%                                 QuaSOR_Fits(z).PooledScoreTotals(i,j)=QuaSOR_Fits(z).AllFitTests(i,j).ScoreTotal;
% 
%         %                             x = 0:0.1:size(QuaSOR_Fits(z).TestImage,2); y = 0:0.1:size(QuaSOR_Fits(z).TestImage,1);
%         %                             [X,Y] = meshgrid(x,y);
%         %                             QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp_Upscale=zeros(length(y),length(x));
%         %                             for k=1:QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.NumComponents
%         %                                 Amp=QuaSOR_Fits(z).TestImage(round(QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.mu(k,1)),round(QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.mu(k,2)));
%         %                                 TestSigma=QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.Sigma(:,:,k);
%         %                                 temp1=TestSigma(1,1);
%         %                                 temp2=TestSigma(2,2);
%         %                                 TestSigma(1,1)=temp2;TestSigma(2,2)=temp1;
%         %                                 F1 = mvnpdf([X(:) Y(:)],fliplr(QuaSOR_Fits(z).AllFitTests(i,j).GaussianFitModel.mu(k,:)),TestSigma);
%         %                                 F1 = reshape(F1,length(y),length(x));
%         %                                 F1=(F1/max(F1(:)))*Amp;
%         %                                 QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp_Upscale=QuaSOR_Fits(z).AllFitTests(i,j).FitImage_Amp_Upscale+F1;
%         %                                 clear TestSigma F1
%         %                             end
%                             end
%                         end
%                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         %Increase num components and adjust parameters
%                         if NumResets>Components.MaxAllowed_NumResets %Will kill the searching after so many repeats
%                             Searching=0;
%                             Success=0;
%                         elseif j>=Components.MaxAllowed_NumGaussians||i>=Components.MaxAllowed_NumReplicates %reset if you hit the maximum allowed replicates or num components and then weaken all restrictions to try to fit
%                             NumResets=NumResets+1;
%                             j=1;
%                             %One reason it often fails is a large region so also mask the image to try to get spots to split
%                             TempImage=QuaSOR_Fits(z).TestImage_Z_Scaled;
%                             TempImage(TempImage<(Components.Repeat_Amp_Threshold+(NumResets-1)/2*Components.Repeat_Amp_Threshold)*QuaSOR_Parameters.General.ScalePoint_Scalar)=0;
%                             Count=0;
%                             QuaSOR_Fits(z).ScalePoints=[];
%                             for m=1:size(TempImage,1)
%                                 for n=1:size(TempImage,2)
%                                     for k=1:TempImage(m,n)
%                                         Count=Count+1;
%                                         QuaSOR_Fits(z).ScalePoints(Count,:)=[m,n];
%                                     end
%                                 end
%                             end
%                             TempImage=QuaSOR_Fits(z).TestImage_Filt_Z_Scaled;
%                             TempImage(TempImage<(Components.Repeat_Amp_Threshold+(NumResets-1)/2*Components.Repeat_Amp_Threshold)*QuaSOR_Parameters.General.ScalePoint_Scalar)=0;
%                             Count=0;
%                             QuaSOR_Fits(z).ScalePoints_Filt=[];
%                             for m=1:size(TempImage,1)
%                                 for n=1:size(TempImage,2)
%                                     for k=1:TempImage(m,n)
%                                         Count=Count+1;
%                                         QuaSOR_Fits(z).ScalePoints_Filt(Count,:)=[m,n];
%                                     end
%                                 end
%                             end
%                             %weaken parameters
%                             QuaSOR_Fits(z).AllFitTests=struct('GaussianFitModel',[]);
%                             for k=1:Components.MaxAllowed_NumReplicates
%                                 for l=1:Components.MaxAllowed_NumGaussians
%                                     QuaSOR_Fits(z).AllFitTests(k,l)=struct('GaussianFitModel',[]);
%                                 end
%                             end
%                             QuaSOR_Fits(z).NumResets=NumResets;
%                             QuaSOR_Fits(z).NumReplicates=Components.NumReplicates;
%                             QuaSOR_Fits(z).PooledScoreTotals=zeros(Components.MaxAllowed_NumReplicates,Components.MaxAllowed_NumGaussians);
%                             Temp_MaxVar=Dist_Weights.Var_Score.Hist_XData(length(Dist_Weights.Var_Score.Hist_XData))+NumResets*10;
%                             Temp_MaxCov=Dist_Weights.Cov_Score.Hist_XData(length(Dist_Weights.Cov_Score.Hist_XData))+NumResets*5;
%                             Temp_MaxVarDiff=Dist_Weights.Var_Diff_Score.Hist_XData(length(Dist_Weights.Var_Diff_Score.Hist_XData))+NumResets*5;
%                             MaxNumGaussians=Components.MaxNumGaussians;
%                             GMDistFitOptions=GMM.GMDistFitOptions;
%                             %InternalReplicates=GMM.InternalReplicates+NumResets*2;
%                             InternalReplicates=GMM.InternalReplicates;
%                             Searching=1;
%                             if General.DisplayOn
%                                 progressbar('Components','Replicates');
%                             end
%                         elseif j<Components.MaxNumGaussians
%                             j=j+1;
%                             if General.DisplayOn
%                                 %progressbar('Components','Replicates');
%                                 progressbar((j-1)/MaxNumGaussians,0)
%                             end
%                             %increase num replicates as the number of componentes increases to increase the likelihood of finding a good match
%                             QuaSOR_Fits(z).NumReplicates=QuaSOR_Fits(z).NumReplicates+Components.ReplicateIncrease;
%                             Searching=1;
%                         elseif any(QuaSOR_Fits(z).PooledScoreTotals(:)>0)
%                             Searching=0;
%                             Success=1;
%                         else
%                             %adjust conditions to make a fit easier
%                             Temp_MaxVar=Temp_MaxVar+10;
%                             Temp_MaxCov=Temp_MaxCov+2;
%                             Temp_MaxVarDiff=Temp_MaxVarDiff+10;
%         %                     if GMDistFitOptions.MaxIter>5
%         %                         GMDistFitOptions.MaxIter=GMDistFitOptions.MaxIter-1;
%         %                     end
%                             MaxNumGaussians=MaxNumGaussians+1;
%                             if General.DisplayOn
%                                 progressbar((j-1)/MaxNumGaussians,0)
%                             end
%                             j=j+1;
%                             %increase num replicates as the number of componentes increases to increase the likelihood of finding a good match
%                             QuaSOR_Fits(z).NumReplicates=QuaSOR_Fits(z).NumReplicates+Components.ReplicateIncrease;
%                             Searching=1;
%                         end
%                     end
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     if Success
%                         %Pick Winner
%                         QuaSOR_Fits(z).Successful_Fit=1;
%                         [~,QuaSOR_Fits(z).Best_NumGaussian]=max(max(QuaSOR_Fits(z).PooledScoreTotals,[],1));
%                         test=QuaSOR_Fits(z).PooledScoreTotals(:,QuaSOR_Fits(z).Best_NumGaussian);
%                         [~,QuaSOR_Fits(z).Best_Replicate]=max(test(:),[],1);
% 
%                         %Assign winner data
%                         QuaSOR_Fits(z).Best_GaussianFitModel=QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).GaussianFitModel;
%                         QuaSOR_Fits(z).Best_GaussianFitTest=QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian);
%                         QuaSOR_Fits(z).Best_GaussianFitImage=QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).FitImage_Amp;
%                         QuaSOR_Fits(z).BestGaussianFitModel_Clean.Amp=QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).Amp;
%                         QuaSOR_Fits(z).BestGaussianFitModel_Clean.Amp_Scaled=QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).Amp_Scaled;
%                         QuaSOR_Fits(z).BestGaussianFitModel_Clean.mu=QuaSOR_Fits(z).Best_GaussianFitModel.mu;
%                         QuaSOR_Fits(z).BestGaussianFitModel_Clean.Sigma=QuaSOR_Fits(z).Best_GaussianFitModel.Sigma;
%                         QuaSOR_Fits(z).BestGaussianFitModel_Clean.NumComponents=QuaSOR_Fits(z).Best_GaussianFitModel.NumComponents;
%                         QuaSOR_Fits(z).BestGaussianFitModel_Clean.ComponentProportion=QuaSOR_Fits(z).Best_GaussianFitModel.ComponentProportion;                   
%                     else
%                         QuaSOR_Fits(z).Successful_Fit=0;
%                     end
%                 end
%         %END Region
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 if QuaSOR_Parameters.General.DisplayOn
%                     for z=1:length(QuaSOR_Fits)
%                         figure('name',num2str(z))
%                         subtightplot(3,1,1)
%                         imagesc(QuaSOR_Fits(z).TestImage), axis equal tight,colorbar
%                         hold on
%                         for k=1:QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).GaussianFitModel.NumComponents
%                             plot(QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).GaussianFitModel.mu(k,2),QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).GaussianFitModel.mu(k,1),'.','MarkerSize',25,'color','k')
%                         end
%                         subtightplot(3,1,2)
%                         imagesc(QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).FitImage_Amp),axis equal tight,colorbar
%                         hold on
%                         for k=1:QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).GaussianFitModel.NumComponents
%                             plot(QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).GaussianFitModel.mu(k,2),QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).GaussianFitModel.mu(k,1),'.','MarkerSize',25,'color','k')
%                         end
%                         subtightplot(3,1,3)
%                         imagesc(QuaSOR_Fits(z).TestImage_Filt-QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).FitImage_Amp),axis equal tight,colorbar
%                         hold on
%                         for k=1:QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).GaussianFitModel.NumComponents
%                             plot(QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).GaussianFitModel.mu(k,2),QuaSOR_Fits(z).AllFitTests(QuaSOR_Fits(z).Best_Replicate,QuaSOR_Fits(z).Best_NumGaussian).GaussianFitModel.mu(k,1),'.','MarkerSize',25,'color','k')
%                         end
%                     end
%                 end
% 
%                 %Merge Data
%                 QuaSOR_Fitting_Data(EpisodeNumber).Num_Successful_Fits=0;
%                 QuaSOR_Fitting_Data(EpisodeNumber).Num_Failed_Fits=0;
%                 for z=1:length(QuaSOR_Fits)
%                     if QuaSOR_Fits(z).Successful_Fit
%                         QuaSOR_Fitting_Data(EpisodeNumber).Num_Successful_Fits=QuaSOR_Fitting_Data(EpisodeNumber).Num_Successful_Fits+1;
%                     else
%                         QuaSOR_Fitting_Data(EpisodeNumber).Num_Failed_Fits=QuaSOR_Fitting_Data(EpisodeNumber).Num_Failed_Fits+1;
%                     end
%                 end
%                 for x=1:27
%                     fprintf('\b');
%                 end
%                 fprintf([num2str(QuaSOR_Fitting_Data(EpisodeNumber).Num_Successful_Fits),' Fit ',num2str(QuaSOR_Fitting_Data(EpisodeNumber).Num_Failed_Fits),' Fail ==> '])
%                 fprintf('Merging...')
% 
%                 if ~isempty(AnalysisRegions)
% 
%                     %Check the math here for the QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust!!
%                     x1 = 1:size(DeltaFF0_Image,2); y1 = 1:size(DeltaFF0_Image,1);
%                     [X1,Y1] = meshgrid(x1,y1);
%                     %ReconstructedFitImage=ZerosImage;
%                     AllNewFit_MaxCoords=[];
%                     AllNewFit_Amp=[];
%                     AllNewFit_Amp_Scaled=[];
%                     AllNewFit_Sigma=[];
%                     AllNewFit_Episode=[];
%                     Count=0;
%                     for z=1:length(QuaSOR_Fits)
%                         %Delete AllFitTests if not needed
%                         if ~QuaSOR_Parameters.General.StoreAllFitTests
%                             QuaSOR_Fits(z).AllFitTests=[];
%                         end            
%                         if QuaSOR_Fits(z).Successful_Fit
%                             for k=1:QuaSOR_Fits(z).BestGaussianFitModel_Clean.NumComponents
% 
%                                 TempCoord=QuaSOR_Fits(z).BestGaussianFitModel_Clean.mu(k,:);
%                                 XFix=AnalysisRegions(z).RegionProps.BoundingBox(1)+QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust;
%                                 YFix=AnalysisRegions(z).RegionProps.BoundingBox(2)+QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust;
%                                 TempCoordFix=[TempCoord(1)+YFix,TempCoord(2)+XFix];
%                                 QuaSOR_Fits(z).BestGaussianFitModel_Clean.mu_Fix(k,:)=TempCoordFix;
%                                 Count=Count+1;
%                                 AllNewFit_MaxCoords(Count,:)=QuaSOR_Fits(z).BestGaussianFitModel_Clean.mu_Fix(k,:);
%                                 AllNewFit_Amp(Count)=QuaSOR_Fits(z).BestGaussianFitModel_Clean.Amp(k);
%                                 AllNewFit_Amp_Scaled(Count)=QuaSOR_Fits(z).BestGaussianFitModel_Clean.Amp_Scaled(k);
%                                 AllNewFit_Sigma(:,:,Count)=QuaSOR_Fits(z).BestGaussianFitModel_Clean.Sigma(:,:,k);
%                                 AllNewFit_Episode(Count,:)=[z,k];%use this to pull from the Fit data later 
%             %                     TestSigma=QuaSOR_Fits(z).BestGaussianFitModel_Clean.Sigma(:,:,k);
%             %                     temp1=TestSigma(1,1);
%             %                     temp2=TestSigma(2,2);
%             %                     TestSigma(1,1)=temp2;TestSigma(2,2)=temp1;
%             %                     clear temp1 temp2
%             %                     F2 = mvnpdf([X1(:) Y1(:)],fliplr(TempCoordFix),TestSigma);
%             %                     F2 = reshape(F2,length(y1),length(x1));
%             %                     F2=F2/max(F2(:))*max(DeltaFF0_Image(:));
%             %                     ReconstructedFitImage=ReconstructedFitImage+F2;
%             %                     clear F2
%                             end
%                         end
%                     end
% 
%                     %Remove overlapping regions
% 
%                     DistanceMatrix=zeros(size(AllNewFit_MaxCoords,1));           
%                     TestRecord=zeros(size(DistanceMatrix));
% 
%                     for m=1:size(AllNewFit_MaxCoords,1)
%                         for n=1:size(AllNewFit_MaxCoords,1)
%                             DistanceMatrix(m,n)=sqrt((AllNewFit_MaxCoords(m,1)-AllNewFit_MaxCoords(n,1))^2+(AllNewFit_MaxCoords(m,2)-AllNewFit_MaxCoords(n,2))^2);
%                             if m==n
%                                 TestRecord(m,n)=1;
%                             else
%                                 TestRecord(m,n)=0;
%                             end
%                         end
%                     end
%                     DistanceMatrix(DistanceMatrix==0)=NaN;
%                     if any(DistanceMatrix(:)<=QuaSOR_Parameters.GMM.MinDistance)
%                         CheckDistance=1;
%                     else
%                         CheckDistance=0;
%                     end
%                     %Search for events that are too close
%                     RemoveCount=0;
%                     RemoveRegions=[];
%                     if CheckDistance
%                         %progressbar('Region 1','Region 2')
%                         for k=1:size(AllNewFit_MaxCoords,1)
%                             for n=k+1:size(AllNewFit_MaxCoords,1)
%                                % progressbar(k/size(AllNewFit_MaxCoords,1),n/size(AllNewFit_MaxCoords,1));
%                                 if ~TestRecord(k,n)&&~TestRecord(n,k)
%                                     TestRecord(k,n)=1;
%                                     TestRecord(n,k)=1;
%                                     if DistanceMatrix(n,k)<=QuaSOR_Parameters.GMM.MinDistance
%                                         RemoveCount=RemoveCount+1;
%                                         TestSigma=AllNewFit_Sigma(:,:,k);
%                                         temp1=TestSigma(1,1);
%                                         temp2=TestSigma(2,2);
%                                         TestSigma(1,1)=temp2;TestSigma(2,2)=temp1;
%                                         clear temp1 temp2
%                                         TestGaussian1 = mvnpdf([X1(:) Y1(:)],fliplr(AllNewFit_MaxCoords(k,:)),TestSigma);
%                                         TestGaussian1 = reshape(TestGaussian1,length(y1),length(x1));
%                                         TestGaussian1=TestGaussian1/max(TestGaussian1(:))*max(DeltaFF0_Image(:));
% 
%                                         TestSigma=AllNewFit_Sigma(:,:,n);
%                                         temp1=TestSigma(1,1);
%                                         temp2=TestSigma(2,2);
%                                         TestSigma(1,1)=temp2;TestSigma(2,2)=temp1;
%                                         clear temp1 temp2
%                                         TestGaussian2 = mvnpdf([X1(:) Y1(:)],fliplr(AllNewFit_MaxCoords(n,:)),TestSigma);
%                                         TestGaussian2 = reshape(TestGaussian2,length(y1),length(x1));
%                                         TestGaussian2=TestGaussian2/max(TestGaussian2(:))*max(DeltaFF0_Image(:));
% 
%                                         TestCorrelations1 = normxcorr2(DeltaFF0_Image,TestGaussian1);
%                                         TestCorrelations2 = normxcorr2(DeltaFF0_Image,TestGaussian2);
%                                         TempMaxCorr1=max(TestCorrelations1(:));
%                                         TempMaxCorr2=max(TestCorrelations2(:));
% 
%                                         if ~(TempMaxCorr1==TempMaxCorr2)
%                                             if TempMaxCorr1>TempMaxCorr2
%                                                 RemoveRegions(RemoveCount)=n;
%                                             else
%                                                 RemoveRegions(RemoveCount)=k;
%                                             end
%                                         else
%                                             RemoveRegions(RemoveCount)=n;
%                                         end
%                                     end
%                                 end
%                             end
%                         end
%                     end
% 
%                     %Remove duplicates which can arise after multiple tests
%                     %or remove any that were flagged as too close
%                     Count=0;
%                     Temp_AllNewFit_MaxCoords=[];
%                     Temp_AllNewFit_Amp=[];
%                     Temp_AllNewFit_Amp_Scaled=[];
%                     Temp_AllNewFit_Sigma=[];
%                     Temp_AllNewFit_Episode=[];
%                     Test=[];
%                     for k=1:size(AllNewFit_MaxCoords)
% 
%                         TempCoord=[AllNewFit_MaxCoords(k,1),AllNewFit_MaxCoords(k,2)];
%                         AlreadyAdded=0;
%                         for y=1:size(Test,1)
%                             if TempCoord(1)==Test(y,1)&&TempCoord(2)==Test(y,2)
%                                 AlreadyAdded=1;
%                             end
%                         end
%                         Test(k,:)=TempCoord;
% 
%                         if any(k==RemoveRegions)||AlreadyAdded
% 
%                         else
%                             Count=Count+1;
%                             Temp_AllNewFit_MaxCoords(Count,:)=AllNewFit_MaxCoords(k,:);
%                             Temp_AllNewFit_Amp(Count)=AllNewFit_Amp(k);
%                             Temp_AllNewFit_Amp_Scaled(Count)=AllNewFit_Amp_Scaled(k);
%                             Temp_AllNewFit_Sigma(:,:,Count)=AllNewFit_Sigma(:,:,k);
%                             Temp_AllNewFit_Episode(Count,:)=AllNewFit_Episode(k,:);       
% 
%                         end
%                     end
%                     AllNewFit_MaxCoords=Temp_AllNewFit_MaxCoords;
%                     AllNewFit_Amp=Temp_AllNewFit_Amp;
%                     AllNewFit_Amp_Scaled=Temp_AllNewFit_Amp_Scaled;
%                     AllNewFit_Sigma=Temp_AllNewFit_Sigma;
%                     AllNewFit_Episode=Temp_AllNewFit_Episode;           
%                     AllNewFit_FinalNumComponents=size(AllNewFit_MaxCoords,1);
% 
%                     %Adjust the coordinates so they will match old locations
%                     if AllNewFit_FinalNumComponents>0
%                         AllNewFit_MaxCoords(:,1)=AllNewFit_MaxCoords(:,1)+QuaSOR_Parameters.UpScaling.YOffset;
%                         AllNewFit_MaxCoords(:,2)=AllNewFit_MaxCoords(:,2)+QuaSOR_Parameters.UpScaling.XOffset;
%                     end
%                     %Remap all coordinates and gaussian fits (takes a little time)
%                     ReconstructedFitImage=zeros(size(DeltaFF0_Image));
%                     ReconstructedFitImage_Upscale=double(ZerosImage_Upscale);
%                     Max_Image=ZerosImage_Upscale;
%                     for k=1:AllNewFit_FinalNumComponents
% 
%                         Num_Locations=Num_Locations+1;
%                         All_Location_Coords(Num_Locations,:)=[AllNewFit_MaxCoords(k,1),AllNewFit_MaxCoords(k,2),EpisodeNumber];
%                         All_Location_Amps(Num_Locations)=AllNewFit_Amp(k);
% 
%                         TempCoord=AllNewFit_MaxCoords(k,:);
%                         TestSigma=AllNewFit_Sigma(:,:,k);
%                         temp1=TestSigma(1,1);
%                         temp2=TestSigma(2,2);
%                         TestSigma(1,1)=temp2;TestSigma(2,2)=temp1;
%                         clear temp1 temp2
% 
%                         %Max location reconstruction
%                         TempImage=ZerosImage_Upscale;
%                         TempCoord=round(TempCoord*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor)+QuaSOR_Parameters.UpScaling.UpScale_CoordinateAdjust*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor;
%                         if TempCoord(1)>0&&TempCoord(1)<=size(TempImage,1)&&TempCoord(2)>0&&TempCoord(2)<=size(TempImage,2)
%                             TempImage(TempCoord(1),TempCoord(2))=1;
%                             Max_Image=Max_Image+TempImage; 
%                         end
%                         clear TempImage
% 
%                         %Normal Res reconstruction
%                         TempCoord=AllNewFit_MaxCoords(k,:);
%                         F2 = mvnpdf([X1(:) Y1(:)],fliplr(TempCoord),TestSigma);
%                         F2 = reshape(F2,length(y1),length(x1));
%                         F2=F2/max(F2(:))*AllNewFit_Amp(k);
%                         ReconstructedFitImage=ReconstructedFitImage+F2;
%                         clear F2
% 
%                         %Upscale Reconstruction
%                         TempCoord=AllNewFit_MaxCoords(k,:);
%                         F2 = mvnpdf([X2(:) Y2(:)],fliplr(TempCoord),TestSigma);
%                         F2 = reshape(F2,length(y2),length(x2));
%                         F2=F2/max(F2(:))*AllNewFit_Amp(k);
%                         ReconstructedFitImage_Upscale=ReconstructedFitImage_Upscale+F2;
%                         clear F2
% 
%                     end
%                     %figure, imagesc(Max_Image),axis equal tight
%                     %figure, imagesc(ReconstructedFitImage),axis equal tight
%                     %figure, imagesc(ReconstructedFitImage_Upscale),axis equal tight
% 
%                     %We could save to the individual files here but for now see if
%                     %memory can handle storing the structure
%                     QuaSOR_Fitting_Data(EpisodeNumber).AnalysisRegions=AnalysisRegions; clear AnalysisRegions
%                     QuaSOR_Fitting_Data(EpisodeNumber).ReconstructedFitImage=ReconstructedFitImage; clear ReconstructedFitImage
%                     QuaSOR_Fitting_Data(EpisodeNumber).QuaSOR_Fits=QuaSOR_Fits; clear QuaSOR_Fits
%                     QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords=AllNewFit_MaxCoords; clear AllNewFit_MaxCoords
%                     QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_Amp=AllNewFit_Amp; clear AllNewFit_Amp
%                     QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_Amp_Scaled=AllNewFit_Amp_Scaled; clear AllNewFit_Amp_Scaled
%                     QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_Sigma=AllNewFit_Sigma; clear AllNewFit_Sigma
%                     QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_Episode=AllNewFit_Episode; clear AllNewFit_Episode
%                     QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_FinalNumComponents=AllNewFit_FinalNumComponents; clear AllNewFit_FinalNumComponents 
%                     
%                     EpNums=EpisodeNumber*ones(size(QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords,1),1);
%                     QuaSOR_Data(EpisodeNumber).All_Location_Coords_byEpisodeNum=cat(2,QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords,EpNums);
%                     FrameNums=((EpisodeNumber-1)*ImagingInfo.FramesPerEpisode+ImagingInfo.PeakFrame)*ones(size(QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords,1),1);
%                     QuaSOR_Data(EpisodeNumber).All_Location_Coords_byFrame=cat(2,QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords,FrameNums);
%                     StimNums=EpisodeNumber*ones(size(QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords,1),1);
%                     if ImagingInfo.StimuliPerEpisode>1
%                         error('Not currently set up to handle more than one stim per episode here!')
%                     end
%                     QuaSOR_Data(EpisodeNumber).All_Location_Coords_byStim=cat(2,QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords,StimNums);
% 
%                     %May want to save this later but it is very large
%                     %QuaSOR_Fitting_Data(EpisodeNumber).ReconstructedFitImage_Upscale=ReconstructedFitImage_Upscale; 
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%                     if QuaSOR_Parameters.General.Reconstruct_Upscale_Fit_Stack
%                         ImageArray_QuaSOR_Upscale_Reconstructed(:,:,EpisodeNumber)=ReconstructedFitImage_Upscale; 
%                     end
%                     ImageArray_QuaSOR_Upscale_Max_Sharp(:,:,EpisodeNumber)=Max_Image; clear Max_Image
%                     ImageArray_QuaSOR_Upscale_Sharp_Sum(:,:,EpisodeNumber)=sum(ImageArray_QuaSOR_Upscale_Max_Sharp(:,:,1:EpisodeNumber),3);
%                     ImageArray_QuaSOR_Upscale_Sharp_Prob_Filt(:,:,EpisodeNumber) = imfilter(single(ImageArray_QuaSOR_Upscale_Sharp_Sum(:,:,EpisodeNumber)), fspecial('gaussian', QuaSOR_Parameters.Display.UpScale_Map_FilterSize, QuaSOR_Parameters.Display.UpScale_Map_FilterSigma)); 
% 
%                     Temp=ImageArray_QuaSOR_Upscale_Max_Sharp(:,:,EpisodeNumber);
%                     Vector_QuaSOR_NumEvents(EpisodeNumber)=sum(Temp(:));
%                     Temp=Max_Stack(:,:,EpisodeNumber);
%                     Vector_OQA_NumEvents(EpisodeNumber)=sum(Temp(:));
%                 else
%                     ReconstructedFitImage=zeros(size(DeltaFF0_Image));
%                     ReconstructedFitImage_Upscale=double(ZerosImage_Upscale);
%                     Max_Image=ZerosImage_Upscale;
%                     QuaSOR_Fitting_Data(EpisodeNumber).AnalysisRegions=AnalysisRegions; clear AnalysisRegions
%                     QuaSOR_Fitting_Data(EpisodeNumber).ReconstructedFitImage=ReconstructedFitImage; clear ReconstructedFitImage
%                     QuaSOR_Fitting_Data(EpisodeNumber).QuaSOR_Fits=QuaSOR_Fits; clear QuaSOR_Fits
%                     QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords=[];
%                     QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_Amp=[];
%                     QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_Amp_Scaled=[];
%                     QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_Sigma=[];
%                     QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_Episode=[];
%                     QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_FinalNumComponents=0;
%                     QuaSOR_Data(EpisodeNumber).All_Location_Coords_byEpisodeNum=[];
%                     QuaSOR_Data(EpisodeNumber).All_Location_Coords_byFrame=[];
%                     if ImagingInfo.StimuliPerEpisode>1
%                         error('Not currently set up to handle more than one stim per episode here!')
%                     end
%                     QuaSOR_Data(EpisodeNumber).All_Location_Coords_byStim=[];
%                     if QuaSOR_Parameters.General.Reconstruct_Upscale_Fit_Stack
%                         ImageArray_QuaSOR_Upscale_Reconstructed(:,:,EpisodeNumber)=ReconstructedFitImage_Upscale; 
%                     end
%                     ImageArray_QuaSOR_Upscale_Max_Sharp(:,:,EpisodeNumber)=Max_Image; clear Max_Image
%                     ImageArray_QuaSOR_Upscale_Sharp_Sum(:,:,EpisodeNumber)=sum(ImageArray_QuaSOR_Upscale_Max_Sharp(:,:,1:EpisodeNumber),3);
%                     ImageArray_QuaSOR_Upscale_Sharp_Prob_Filt(:,:,EpisodeNumber) = imfilter(single(ImageArray_QuaSOR_Upscale_Sharp_Sum(:,:,EpisodeNumber)), fspecial('gaussian', QuaSOR_Parameters.Display.UpScale_Map_FilterSize, QuaSOR_Parameters.Display.UpScale_Map_FilterSigma)); 
% 
%                     Vector_QuaSOR_NumEvents(EpisodeNumber)=0;
%                     Vector_OQA_NumEvents(EpisodeNumber)=0;
%                 end
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%                 if QuaSOR_Parameters.General.DisplayFinal
%                     if ~exist('FinalFig')
%                         FinalFig=figure;
%                         %set(FinalFig,'units','normalized','position',[0,0.04,1,0.88])
%                         FigureSize=[ImageWidth*2*ScaleFactor,ImageHeight*2*ScaleFactor];
%                         set(FinalFig,'units','Pixels','position',[0,40,FigureSize]);
%                         set(FinalFig, 'color', 'white');
%                     else
%                         figure(FinalFig);
%                     end
%                     clf
%                     %%%%%%%%%%%
%                     subtightplot(2,2,1,[0.01,0.01],[0,0],[0,0])
%                     if isempty(Fit_Frame)||Fit_Frame==0
%                         imagesc(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image),axis equal tight,caxis([0,max(QuaSOR_Fitting_Data(EpisodeNumber).DeltaFF0_Image(:)*0.8)]),colormap jet
%                     else
%                         imagesc(DeltaFF0_Alternative_Image),axis equal tight,caxis([0,max(DeltaFF0_Alternative_Image(:)*0.8)]),colormap jet
%                     end
%                     hold all
%                     for z=1:length(QuaSOR_Fitting_Data(EpisodeNumber).AnalysisRegions)
%                         if QuaSOR_Fitting_Data(EpisodeNumber).QuaSOR_Fits(z).Successful_Fit
%                             PlotBox(QuaSOR_Fitting_Data(EpisodeNumber).AnalysisRegions(z).RegionProps.BoundingBox,'-','y',1,[],15,'y')
%                         else
%                             PlotBox(QuaSOR_Fitting_Data(EpisodeNumber).AnalysisRegions(z).RegionProps.BoundingBox,'-','r',2,[],15,'r')
%                         end
%                     end
%         %                     for z=1:size(QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords,1)
%         %                         plot(QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords(z,2)+QuaSOR_Parameters.UpScaling.YOffset,QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords(z,1)+QuaSOR_Parameters.UpScaling.XOffset,'.','color','m','MarkerSize',MovieQuaSOR_Parameters.Display.MarkerSize)
%         %                     end
%                     if QuaSOR_Parameters.Display.UseBorderLine
%                         for j=1:length(BorderLine)
%                             plot(BorderLine{j}.BorderLine_Crop(:,2)+QuaSOR_Parameters.Display.BorderLineAdjustment, BorderLine{j}.BorderLine_Crop(:,1)+QuaSOR_Parameters.Display.BorderLineAdjustment,'-' , 'color', QuaSOR_Parameters.Display.BorderColor,'linewidth', QuaSOR_Parameters.Display.BorderThickness); 
%                         end
%                     else
%                         plot(BorderX_Crop, BorderY_Crop,['s'] , 'MarkerEdgeColor', QuaSOR_Parameters.Display.BorderColor,'MarkerFaceColor', QuaSOR_Parameters.Display.BorderColor, 'MarkerSize', QuaSOR_Parameters.Display.BorderThickness,'LineWidth',QuaSOR_Parameters.Display.BorderThickness);
%                     end
%                     if TextOn
%                         text(LabelLocation(1),LabelLocation(2),['Stim #',num2str(EpisodeNumber),' => ',num2str(Vector_OQA_NumEvents(EpisodeNumber)),' OQA Events'],'color','w','FontName','Arial','FontSize',20)
%                     else 
%                         text(LabelLocation(1),LabelLocation(2),[num2str(EpisodeNumber)],'color','w','FontName','Arial','FontSize',12)
%                     end
%                     plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',QuaSOR_Parameters.Display.BorderThickness);
%                     set(gca,'XTick', []); set(gca,'YTick', []);
%                     %%%%%%%%%%%
%                     subtightplot(2,2,3,[0.01,0.01],[0,0],[0,0])
%                     imagesc(ReconstructedFitImage_Upscale),axis equal tight,caxis([0,max(ReconstructedFitImage_Upscale(:)*0.6)]),colormap jet
%                     hold all
%                     for z=1:size(QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords,1)
%                         plot((QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords(z,2))*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,(QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords(z,1))*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,'.','color','k','MarkerSize',QuaSOR_Parameters.Display.MarkerSize+5)
%                         plot((QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords(z,2))*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,(QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords(z,1))*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,'.','color','w','MarkerSize',QuaSOR_Parameters.Display.MarkerSize-5)
%                     end
%                     if QuaSOR_Parameters.Display.UseBorderLine
%                         for j=1:length(BorderLine_Upscale)
%                             plot(BorderLine_Upscale{j}.BorderLine_Crop(:,2)+QuaSOR_Parameters.Display.BorderLineAdjustment, BorderLine_Upscale{j}.BorderLine_Crop(:,1)+QuaSOR_Parameters.Display.BorderLineAdjustment,'-' , 'color', QuaSOR_Parameters.Display.BorderColor,'linewidth', QuaSOR_Parameters.Display.BorderThickness); 
%                         end
%                     else
%                         plot(BorderX_Crop_Upscale, BorderY_Crop_Upscale,['s'] , 'MarkerEdgeColor', QuaSOR_Parameters.Display.BorderColor,'MarkerFaceColor', QuaSOR_Parameters.Display.BorderColor, 'MarkerSize', QuaSOR_Parameters.Display.BorderThickness,'LineWidth',QuaSOR_Parameters.Display.BorderThickness);
%                     end
%                     if TextOn
%                         text(LabelLocation(1)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,LabelLocation(2)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,['Stim #',num2str(EpisodeNumber),' => ',num2str(Vector_QuaSOR_NumEvents(EpisodeNumber)),' SOQA Events'],'color','w','FontName','Arial','FontSize',20)
%                     end
%                     plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',QuaSOR_Parameters.Display.BorderThickness);
%                     set(gca,'XTick', []); set(gca,'YTick', []);
%                     %%%%%%%%%%%
%                     subtightplot(2,2,2,[0.01,0.01],[0,0],[0,0])
%                     ColorLimits=[min(OneImage_WithStim_Upscale_Max_Sharp_Prob_Filt(:))+QuaSOR_Parameters.Display.LowPercent*min(OneImage_WithStim_Upscale_Max_Sharp_Prob_Filt(:)),max(OneImage_WithStim_Upscale_Max_Sharp_Prob_Filt(:))-QuaSOR_Parameters.Display.HighPercent*max(OneImage_WithStim_Upscale_Max_Sharp_Prob_Filt(:))];
%                     imagesc(OneImage_WithStim_Upscale_Max_Sharp_Prob_Filt,ColorLimits); axis equal tight;
%                     hold on
%                     if QuaSOR_Parameters.Display.UseBorderLine
%                         for j=1:length(BorderLine_Upscale)
%                             plot(BorderLine_Upscale{j}.BorderLine_Crop(:,2)+QuaSOR_Parameters.Display.BorderLineAdjustment, BorderLine_Upscale{j}.BorderLine_Crop(:,1)+QuaSOR_Parameters.Display.BorderLineAdjustment,'-' , 'color', QuaSOR_Parameters.Display.BorderColor,'linewidth', QuaSOR_Parameters.Display.BorderThickness); 
%                         end
%                     else
%                         plot(BorderX_Crop_Upscale, BorderY_Crop_Upscale,['s'] , 'MarkerEdgeColor', QuaSOR_Parameters.Display.BorderColor,'MarkerFaceColor', QuaSOR_Parameters.Display.BorderColor, 'MarkerSize', QuaSOR_Parameters.Display.BorderThickness,'LineWidth',QuaSOR_Parameters.Display.BorderThickness);
%                     end
%                     if TextOn
%                         text(LabelLocation(1)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,LabelLocation(2)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,['OQA P_r and SOQA Pos.'],'color','w','FontName','Arial','FontSize',20)
%                     end
%                     plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',QuaSOR_Parameters.Display.BorderThickness);
%                     set(gca,'XTick', []); set(gca,'YTick', []);
%                     for z=1:size(QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords,1)
%                         plot((QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords(z,2))*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,(QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords(z,1))*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,'.','color','k','MarkerSize',QuaSOR_Parameters.Display.MarkerSize+5)
%                         plot((QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords(z,2))*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,(QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords(z,1))*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,'.','color','w','MarkerSize',QuaSOR_Parameters.Display.MarkerSize-5)
%                     end
%                     hold off
%                     %%%%%%%%%%%
%                     subtightplot(2,2,4,[0.01,0.01],[0,0],[0,0])
% 
%                     OneImage_WithStim_QuaSOR_Upscale_Sharp_Prob_Filt = ImageArray_QuaSOR_Upscale_Sharp_Prob_Filt(:,:,EpisodeNumber); 
%                     if max(OneImage_WithStim_QuaSOR_Upscale_Sharp_Prob_Filt(:))>0
%                         ColorLimits=[0,max(OneImage_WithStim_QuaSOR_Upscale_Sharp_Prob_Filt(:))-QuaSOR_Parameters.Display.HighPercent1*max(OneImage_WithStim_QuaSOR_Upscale_Sharp_Prob_Filt(:))];
%                     else
%                         ColorLimits=[0,1];
%                     end
%                     imagesc(OneImage_WithStim_QuaSOR_Upscale_Sharp_Prob_Filt,ColorLimits); axis equal tight;
%                     hold on
%                     if QuaSOR_Parameters.Display.UseBorderLine
%                         for j=1:length(BorderLine_Upscale)
%                             plot(BorderLine_Upscale{j}.BorderLine_Crop(:,2)+QuaSOR_Parameters.Display.BorderLineAdjustment, BorderLine_Upscale{j}.BorderLine_Crop(:,1)+QuaSOR_Parameters.Display.BorderLineAdjustment,'-' , 'color', QuaSOR_Parameters.Display.BorderColor,'linewidth', QuaSOR_Parameters.Display.BorderThickness); 
%                         end
%                     else
%                         plot(BorderX_Crop_Upscale, BorderY_Crop_Upscale,['s'] , 'MarkerEdgeColor', QuaSOR_Parameters.Display.BorderColor,'MarkerFaceColor', QuaSOR_Parameters.Display.BorderColor, 'MarkerSize', QuaSOR_Parameters.Display.BorderThickness,'LineWidth',QuaSOR_Parameters.Display.BorderThickness);
%                     end
%                     if TextOn
%                         text(LabelLocation(1)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,LabelLocation(2)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,['SOQA P_r (',num2str(QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor),'X Res.)'],'color','w','FontName','Arial','FontSize',20)
%                     end
%                     plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',QuaSOR_Parameters.Display.BorderThickness);
%                     set(gca,'XTick', []); set(gca,'YTick', []);
%                     hold off
%                     set(FinalFig,'units','Pixels','position',[0,40,FigureSize]);
%                     drawnow
%                     pause(0.001)
%                     if QuaSOR_Parameters.General.Reconstruct_Upscale_Fit_Stack
%                         FigPos=get(FinalFig,'Position');
%                         CurrentSize=FigPos(3:4);
%                         if ~isempty(mov.Width)
%                             MovieSize=[mov.Width,mov.Height];
%                             %if CurrentSize(1)~=MovieSize(1)&&CurrentSize(2)~=MovieSize(2)
%                                 %set(FinalFig,'units','pixels','Position',[0,40,MovieSize]);
%                                 %drawnow
%                             %end
%                         end
%                         OneFrame = getframe(FinalFig);
%                         writeVideo(mov,OneFrame);
%                     end
%                     if QuaSOR_Parameters.General.MinimizeFigureWindow
%                         warning off
%                         jFrame = get(handle(gcf),'JavaFrame');
%                         pause(0.1)  %//This is important
%                         jFrame.setMinimized(true);
%                         warning on 
%                     end
% 
%                 end
%                 clear ReconstructedFitImage_Upscale
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 TimePerEpisode=toc(EpisodeTimer);
%                 QuaSOR_Fitting_Data(EpisodeNumber).TimePerEpisode=TimePerEpisode
%                 for x=1:15
%                     fprintf('\b')
%                 end
%                 ETA=(TimePerEpisode*(size(DeltaFF0_Stack,3)-EpisodeNumber))/3600;
%                 fprintf([' ==> Complete! ',num2str(round(TimePerEpisode)),'s ETA = ',num2str(round(ETA*10)/10),' hrs\n'])
%                 beep;pause(0.1);beep;pause(0.1);beep;pause(0.1);beep;
%                 if QuaSOR_Parameters.General.DisplayFinal
%                     set(FinalFig,'name',['Episode # ',num2str(EpisodeNumber),'/',num2str(ImagingInfo.NumEpisodes),' :: ',num2str(size(QuaSOR_Fitting_Data(EpisodeNumber).AllNewFit_MaxCoords,1)),' Regions Total ==> Complete! ',num2str(round(TimePerEpisode)),'s ETA = ',num2str(round(ETA*10)/10),' hrs'])
%                 end
%             end
%             %End Episode
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             if QuaSOR_Parameters.General.DisplayFinal
%                 if QuaSOR_Parameters.General.Reconstruct_Upscale_Fit_Stack
%                     close(mov);
%                 end
%                 close(FinalFig)
%                 clear FinalFig mov
%             end
%             fprintf('\n');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 2
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            EpisodeTimes=[];
            QuaSOR_Fitting_Struct=[];
            QuaSOR_Data=[];
            Mod=1;
            QuaSOR_Data.Modality(Mod).Label='Evoked';
            Mod=2;
            QuaSOR_Data.Modality(Mod).Label='Spontaneous';
            for EpisodeNumber=1:ImagingInfo.NumEpisodes
                QuaSOR_Data.Episode(EpisodeNumber).FinalEventCount=0;
                QuaSOR_Data.Episode(EpisodeNumber).All_Location_Amps=[];
                QuaSOR_Data.Episode(EpisodeNumber).All_Location_Coords=[];
                QuaSOR_Data.Episode(EpisodeNumber).All_Location_Coords_byOverallFrame=[];
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Main Loop
            for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
                AbortStatus=get(AbortButtonHandle,'userdata');
                if ~AbortStatus
                    EpisodeTimer=tic;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if SplitEpisodeFiles
                        FileSuffix=['_EventDetectionData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
                        fprintf(['Loading... ',StackSaveName,FileSuffix,' From CurrentScratchDir...']);
                        load([CurrentScratchDir,dc,StackSaveName,FileSuffix],'EventDetectionStruct')
                        EpisodeNumber=1;
                        DeltaFF0_Stack=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean_Norm;
                        DeltaFF0_Stack(isnan(DeltaFF0_Stack))=0;
                        Max_Stack=EventDetectionStruct(EpisodeNumber).PixelMax_Output.ImageArray_Max_Sharp;
                        fprintf('Finished!\n')
                    else
                        EpisodeNumber=EpisodeNumber_Load;
                        DeltaFF0_Stack=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean_Norm;
                        DeltaFF0_Stack(isnan(DeltaFF0_Stack))=0;
                        Max_Stack=EventDetectionStruct(EpisodeNumber).PixelMax_Output.ImageArray_Max_Sharp;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    ProgressBarOn=1;
                    if sum(Max_Stack(:))<20
                        ProgressBarOn=0;
                    end
                    fprintf(['Episode ',num2str(EpisodeNumber_Load),'/',num2str(ImagingInfo.NumEpisodes),': ','Splitting Regions...'])
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    EpisodeRepeat=0;
                    SuccessfulEpisode=0;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    while EpisodeRepeat<=MaxNumEpisodeRepeats&&...
                            ~SuccessfulEpisode&&~AbortStatus
                        try
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Split Regions
                            AbortStatus=get(AbortButtonHandle,'userdata');
                            if ~AbortStatus
                                AnalysisRegions=[];
                                QuaSOR_Fits=[];
                                All_QuaSOR_Fit_EpisodeTiming=[];
                                ROI_Count=0;
                                if QuaSOR_Parameters.Region.FixedROISize
                                    ZerosRegion=zeros(QuaSOR_Parameters.Region.RegionSize_px+1);
                                    if ProgressBarOn
                                        progressbar('Splitting ROIs (Fixed) ImageNumber');
                                    end
                                    for ImageNumber=1:ImagingInfo.FramesPerEpisode
                                        if ProgressBarOn
                                            progressbar(ImageNumber/ImagingInfo.FramesPerEpisode);
                                        end
                                        AnalysisRegions=[];
                                        Max_Image=Max_Stack(:,:,ImageNumber);
                                        NumMaxEvents=sum(Max_Image(:));
                                        if NumMaxEvents>0
                                            [Max_YCoord,Max_XCoord]=ind2sub(size(Max_Image), find(Max_Image==1));
                                            for z=1:length(Max_YCoord)
                            %                         for x=1:length(num2str(ROI_Count))
                            %                             fprintf('\b')
                            %                         end
                                                ROI_Count=ROI_Count+1;
                                                %fprintf(num2str(ROI_Count))

                                                XCoords=Max_XCoord(z)-QuaSOR_Parameters.Region.RegionSize_px/2:Max_XCoord(z)+QuaSOR_Parameters.Region.RegionSize_px/2;
                                                YCoords=Max_YCoord(z)-QuaSOR_Parameters.Region.RegionSize_px/2:Max_YCoord(z)+QuaSOR_Parameters.Region.RegionSize_px/2;
                                                Region_XCoords=1:size(ZerosRegion,2);
                                                Region_YCoords=1:size(ZerosRegion,1);
                                                if any(XCoords<1)
                                                    Region_XCoords=Region_XCoords(sum(XCoords<1)+1:length(Region_XCoords));
                                                    XCoords=1:XCoords(length(XCoords));
                                                end
                                                if any(XCoords>ImageWidth)
                                                    Region_XCoords=Region_XCoords(1:length(Region_XCoords)-sum(XCoords>ImageWidth));
                                                    XCoords=XCoords(1):ImageWidth;
                                                end       
                                                if any(YCoords<1)
                                                    Region_YCoords=Region_YCoords(sum(YCoords<1)+1:length(Region_YCoords));
                                                    YCoords=1:YCoords(length(YCoords));
                                                end
                                                if any(YCoords>ImageHeight)
                                                    Region_YCoords=Region_YCoords(1:length(Region_YCoords)-sum(YCoords>ImageHeight));
                                                    YCoords=YCoords(1):ImageHeight;
                                                end              
                                                RegionProps.BoundingBox(1)=XCoords(1);
                                                RegionProps.BoundingBox(2)=YCoords(1);
                                                RegionProps.BoundingBox(3)=length(Region_XCoords);
                                                RegionProps.BoundingBox(4)=length(Region_YCoords);
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                AnalysisRegions(ROI_Count).EpisodeNumber=EpisodeNumber_Load;
                                                AnalysisRegions(ROI_Count).ImageNumber=ImageNumber;
                                                AnalysisRegions(ROI_Count).XCoord=round(Max_XCoord(z));
                                                AnalysisRegions(ROI_Count).YCoord=round(Max_YCoord(z));
                                                AnalysisRegions(ROI_Count).YCoords=Region_YCoords;
                                                AnalysisRegions(ROI_Count).XCoords=Region_XCoords;
                                                AnalysisRegions(ROI_Count).RegionProps=RegionProps;
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                QuaSOR_Fits(ROI_Count).EpisodeNumber=EpisodeNumber_Load;
                                                QuaSOR_Fits(ROI_Count).ImageNumber=ImageNumber;
                                                QuaSOR_Fits(ROI_Count).XCoord=AnalysisRegions(ROI_Count).XCoord;
                                                QuaSOR_Fits(ROI_Count).YCoord=AnalysisRegions(ROI_Count).YCoord;
                                                QuaSOR_Fits(ROI_Count).YCoords=AnalysisRegions(ROI_Count).YCoords;
                                                QuaSOR_Fits(ROI_Count).XCoords=AnalysisRegions(ROI_Count).XCoords;
                                                QuaSOR_Fits(ROI_Count).RegionProps=AnalysisRegions(ROI_Count).RegionProps;
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                QuaSOR_Fits(ROI_Count).TestImage=DeltaFF0_Stack(YCoords,XCoords,ImageNumber);
                                                QuaSOR_Fits(ROI_Count).TestImage(isnan(QuaSOR_Fits(ROI_Count).TestImage))=0;
                                                if QuaSOR_Parameters.Region.SuppressBorder
                                                    Mask=ones(size(QuaSOR_Fits(ROI_Count).TestImage));
                                                    Mask(QuaSOR_Parameters.Region.SuppressBorderSize+1:size(Mask,1)-QuaSOR_Parameters.Region.SuppressBorderSize,QuaSOR_Parameters.Region.SuppressBorderSize+1:size(Mask,2)-QuaSOR_Parameters.Region.SuppressBorderSize)=0;
                                                    Mask=Mask*QuaSOR_Parameters.Region.SuppressBorderRatio;
                                                    Mask(Mask==0)=1;
                                                    QuaSOR_Fits(ROI_Count).TestImage=QuaSOR_Fits(ROI_Count).TestImage.*Mask;
                                                end
                                                QuaSOR_Fits(ROI_Count).TestImage_Z_Scaled=round(QuaSOR_Fits(ROI_Count).TestImage/(max(QuaSOR_Fits(ROI_Count).TestImage(:)/QuaSOR_Parameters.General.ScalePoint_Scalar)));
                                                QuaSOR_Fits(ROI_Count).TestImage_Filt = imfilter(QuaSOR_Fits(ROI_Count).TestImage, fspecial('gaussian', QuaSOR_Parameters.GMM.PreFit_FilterSize_px, QuaSOR_Parameters.GMM.PreFit_FilterSigma_px)); 
                                                QuaSOR_Fits(ROI_Count).TestImage_Filt_Z_Scaled=round(QuaSOR_Fits(ROI_Count).TestImage_Filt/(max(QuaSOR_Fits(ROI_Count).TestImage_Filt(:)/QuaSOR_Parameters.General.ScalePoint_Scalar)));
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %convert intensity data into scaled point density representation for unfiltered and filtered data
                                                Count=0;
                                                QuaSOR_Fits(ROI_Count).ScalePoints=[];
                                                for i=1:size(QuaSOR_Fits(ROI_Count).TestImage,1)
                                                    for j=1:size(QuaSOR_Fits(ROI_Count).TestImage,2)
                                                        for k=1:QuaSOR_Fits(ROI_Count).TestImage_Z_Scaled(i,j)
                                                            Count=Count+1;
                                                            QuaSOR_Fits(ROI_Count).ScalePoints(Count,:)=[i,j];
                                                        end
                                                    end
                                                end
                                                Count=0;
                                                QuaSOR_Fits(ROI_Count).ScalePoints_Filt=[];
                                                for i=1:size(QuaSOR_Fits(ROI_Count).TestImage_Filt,1)
                                                    for j=1:size(QuaSOR_Fits(ROI_Count).TestImage_Filt,2)
                                                        for k=1:QuaSOR_Fits(ROI_Count).TestImage_Filt_Z_Scaled(i,j)
                                                            Count=Count+1;
                                                            QuaSOR_Fits(ROI_Count).ScalePoints_Filt(Count,:)=[i,j];
                                                        end
                                                    end
                                                end
                                                %Set up structure elements prior to parallel processing
                                                for k=1:QuaSOR_Parameters.Components.MaxAllowed_NumReplicates+QuaSOR_Parameters.Components.MaxAllowed_NumResets*QuaSOR_Parameters.Components.ReplicateIncrease*2
                                                    for l=1:QuaSOR_Parameters.Components.MaxAllowed_NumGaussians+QuaSOR_Parameters.Components.MaxAllowed_NumResets*2
                                                        QuaSOR_Fits(ROI_Count).AllFitTests(k,l)=struct(   'GaussianFitModel',[]);
                            %                                                                         'FitImage_Amp',[],...
                            %                                                                         'FitImage_Amp_Scaled',[],...
                            %                                                                         'DistanceMatrix',zeros(QuaSOR_Parameters.Components.MaxAllowed_NumGaussians+QuaSOR_Parameters.Components.MaxAllowed_NumResets*2),...
                            %                                                                         'Amp',[],...
                            %                                                                         'Amp_Scaled',[],...
                            %                                                                         'Amp_Scaled_Score',[],...
                            %                                                                         'Amp_Score',[],...
                            %                                                                         'Var_Score',[],...
                            %                                                                         'Cov_Score',[],...
                            %                                                                         'Var_Diff_Score',[],...
                            %                                                                         'CorrCoef',[],...
                            %                                                                         'Max_NormCorr2',[],...
                            %                                                                         'Max_NormCorr2_Score',[],...
                            %                                                                         'CorrCoef_Score',[],...
                            %                                                                         'Pentalty',[],...
                            %                                                                         'MaxVar',[],...
                            %                                                                         'MaxCov',[],...
                            %                                                                         'MaxVarDiff',[],...
                            %                                                                         'GMDistFitOptions',[],...
                            %                                                                         'AllScores',[],...
                            %                                                                         'ScoreTotal',[]);
                                                    end
                                                end
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                QuaSOR_Fits(ROI_Count).NumResets=0;
                                                QuaSOR_Fits(ROI_Count).NumReplicates=QuaSOR_Parameters.Components.NumReplicates;
                                                QuaSOR_Fits(ROI_Count).MaxNumGaussians=[];
                                                QuaSOR_Fits(ROI_Count).NumReplicates=[];
                                                QuaSOR_Fits(ROI_Count).InternalReplicates=[];
                                                QuaSOR_Fits(ROI_Count).MaxVar=[];
                                                QuaSOR_Fits(ROI_Count).MaxCov=[];
                                                QuaSOR_Fits(ROI_Count).MaxVarDiff=[];
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                QuaSOR_Fits(ROI_Count).PooledScoreTotals=zeros(QuaSOR_Parameters.Components.MaxAllowed_NumReplicates+QuaSOR_Parameters.Components.MaxAllowed_NumResets*QuaSOR_Parameters.Components.ReplicateIncrease*2,...
                                                    QuaSOR_Parameters.Components.MaxAllowed_NumGaussians+QuaSOR_Parameters.Components.MaxAllowed_NumResets*2);
                                                QuaSOR_Fits(ROI_Count).Successful_Fit=[];
                                                QuaSOR_Fits(ROI_Count).Best_NumGaussian=[];
                                                QuaSOR_Fits(ROI_Count).Best_Replicate=[];
                                                QuaSOR_Fits(ROI_Count).Best_GaussianFitModel=[];
                                                QuaSOR_Fits(ROI_Count).Best_GaussianFitTest=[];
                                                QuaSOR_Fits(ROI_Count).Best_GaussianFitImage=zeros(size(QuaSOR_Fits(ROI_Count).TestImage));
                                                QuaSOR_Fits(ROI_Count).BestGaussianFitModel_Clean.mu=[];
                                                QuaSOR_Fits(ROI_Count).BestGaussianFitModel_Clean.Sigma=[];
                                                QuaSOR_Fits(ROI_Count).BestGaussianFitModel_Clean.NumComponents=[];
                                                QuaSOR_Fits(ROI_Count).BestGaussianFitModel_Clean.ComponentProportion=[];
                                                QuaSOR_Fits(ROI_Count).TimePerROI=0;
                                            end
                                        end
                                    end
                                    if ProgressBarOn
                                        progressbar(1);
                                    end
                                else
                                    if ProgressBarOn
                                        progressbar('Splitting ROIs (Adaptive Size) ImageNumber');
                                    end
                                    for ImageNumber=1:ImagingInfo.FramesPerEpisode
                                        if ProgressBarOn
                                            progressbar(ImageNumber/ImagingInfo.FramesPerEpisode);
                                        end
                                        AnalysisRegions=[];
                                        Max_Image=Max_Stack(:,:,ImageNumber);
                                        NumMaxEvents=sum(Max_Image(:));
                                        RegionMask=zeros(size(Max_Image));

                                        %Make a mask for all events and apply a threshold to get regions to split    
                                %         if isempty(Fit_Frame)||Fit_Frame==0
                                %             TempDeltaFF0_Image= QuaSOR_Fitting_Struct(EpisodeNumber).DeltaFF0_Image;
                                %         else
                                %             TempDeltaFF0_Image=QuaSOR_Fitting_Struct(EpisodeNumber).DeltaFF0_Alternative_Image;
                                %         end
                                        TempDeltaFF0_Image=DeltaFF0_Stack(:,:,ImageNumber);
                                        if QuaSOR_Parameters.GMM.FitFiltered
                                            TempDeltaFF0_Image=imfilter(TempDeltaFF0_Image, fspecial('gaussian', QuaSOR_Parameters.GMM.PreFit_FilterSize_px, QuaSOR_Parameters.GMM.PreFit_FilterSigma_px));
                                        end
                                        TempDeltaFF0_Image(TempDeltaFF0_Image<=QuaSOR_Parameters.Region.RegionSplitting_Threshold)=0;
                                        TempDeltaFF0_Image(isnan(TempDeltaFF0_Image))=0;
                                        TempDeltaFF0_Image_Mask=logical(TempDeltaFF0_Image);
                                        Initial_AnalysisRegions.Components=bwconncomp(TempDeltaFF0_Image_Mask);
                                        Initial_AnalysisRegions.RegionProps=regionprops(Initial_AnalysisRegions.Components,'Centroid','BoundingBox');

                            %                 figure(); subtightplot(1,1,1,[0.01,0.01],[0,0],[0,0])
                            %                 imagesc(TempDeltaFF0_Image),axis equal tight,caxis([0,max(TempDeltaFF0_Image(:)*0.8)]),colormap jet
                            %                 hold all
                            %                 for z=1:size(Initial_AnalysisRegions.RegionProps,1)
                            %                     PlotBox(Initial_AnalysisRegions.RegionProps(z).BoundingBox,'-','y',1,[],15,'y')
                            %                     Initial_AnalysisRegions.RegionProps(z).Area=Initial_AnalysisRegions.RegionProps(z).BoundingBox(3)*Initial_AnalysisRegions.RegionProps(z).BoundingBox(4);
                            %                     disp(num2str(Initial_AnalysisRegions.RegionProps(z).Area))
                            %                 end        

                                        clear TempDeltaFF0_Image TempDeltaFF0_Image_Mask
                                        %Check and adjust region sizes so that extra large regions are split if possible
                                        count=0;
                                        for z=1:length(Initial_AnalysisRegions.RegionProps)
                                            Initial_AnalysisRegions.RegionProps(z).Area=Initial_AnalysisRegions.RegionProps(z).BoundingBox(3)*Initial_AnalysisRegions.RegionProps(z).BoundingBox(4);
                                            %disp(num2str(Initial_AnalysisRegions.RegionProps(z).Area))
                                            if Initial_AnalysisRegions.RegionProps(z).Area<QuaSOR_Parameters.Region.Max_Region_Area_px2&&Initial_AnalysisRegions.RegionProps(z).Area>QuaSOR_Parameters.Region.Min_Region_Area_px2
                                                count=count+1;
                                                AnalysisRegions(count).RegionProps.Centroid=Initial_AnalysisRegions.RegionProps(z).Centroid;
                                                AnalysisRegions(count).RegionProps.BoundingBox=Initial_AnalysisRegions.RegionProps(z).BoundingBox;
                                                AnalysisRegions(count).RegionProps.Area=Initial_AnalysisRegions.RegionProps(z).Area;
                                            elseif Initial_AnalysisRegions.RegionProps(z).Area>=QuaSOR_Parameters.Region.Max_Region_Area_px2

                                                Initial_AnalysisRegions.RegionProps(z).BoundingBox=[ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(1)),ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(2)),ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(3)),ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(4))];

                                                XCoords=ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(1)):ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(1))+ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(3));
                                                YCoords=ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(2)):ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(2))+ceil(Initial_AnalysisRegions.RegionProps(z).BoundingBox(4));

                                                XAdjust=0;
                                                YAdjust=0;
                                                if any(XCoords<1)
                                                    XAdjust=XAdjust+sum(XCoords<1);
                                                    XCoords=XCoords(1+XAdjust):XCoords(length(XCoords));
                                                end
                                                if any(XCoords>ImageWidth)
                                                    XAdjust=XAdjust-sum(XCoords>ImageWidth);
                                                    XCoords=XCoords(1):XCoords(length(XCoords))+XAdjust;
                                                end       
                                                if any(YCoords<1)
                                                    YAdjust=YAdjust+sum(YCoords<1);
                                                    YCoords=YCoords(1+YAdjust):YCoords(length(YCoords));
                                                end
                                                if any(YCoords>ImageHeight)
                                                    YAdjust=YAdjust-sum(YCoords>ImageHeight);
                                                    YCoords=YCoords(1):YCoords(length(YCoords))+YAdjust;
                                                end
                                                RegionMask=zeros(size(Max_Image));
                                                RegionMask(YCoords,XCoords)=1;
                                %                 if isempty(Fit_Frame)||Fit_Frame==0
                                %                     TempDeltaFF0_Image= QuaSOR_Fitting_Struct(EpisodeNumber).DeltaFF0_Image;
                                %                 else
                                %                     TempDeltaFF0_Image=QuaSOR_Fitting_Struct(EpisodeNumber).DeltaFF0_Alternative_Image;
                                %                 end
                                                TempDeltaFF0_Image=DeltaFF0_Stack(:,:,ImageNumber);
                                                if QuaSOR_Parameters.GMM.FitFiltered
                                                    TempDeltaFF0_Image=imfilter(TempDeltaFF0_Image, fspecial('gaussian', QuaSOR_Parameters.GMM.PreFit_FilterSize_px, QuaSOR_Parameters.GMM.PreFit_FilterSigma_px));
                                                end
                                                TempDeltaFF0_Image2=TempDeltaFF0_Image;
                                                %TempDeltaFF0_Image2(TempDeltaFF0_Image2==0)=NaN;
                                                ThreshTest=1;
                                                cont=1;
                                                while cont
                                                    TempDeltaFF0_Image=TempDeltaFF0_Image.*RegionMask;
                                                    TempDeltaFF0_Image(TempDeltaFF0_Image<=QuaSOR_Parameters.Region.RegionSplitting_Threshold+QuaSOR_Parameters.Region.RegionSplitting_Threshold_Increase*ThreshTest)=0;
                                %                     Temp=TempDeltaFF0_Image2;
                                %                     Temp(TempDeltaFF0_Image<QuaSOR_Parameters.Region.RegionSplitting_Threshold+QuaSOR_Parameters.Region.RegionSplitting_Threshold_Increase*(ThreshTest-1))=0;
                                %                     Temp(TempDeltaFF0_Image>QuaSOR_Parameters.Region.RegionSplitting_Threshold+QuaSOR_Parameters.Region.RegionSplitting_Threshold_Increase*ThreshTest)=0;
                                %                     TempDeltaFF0_Image3=TempDeltaFF0_Image2.*RegionMask;
                                %                     NumTotalPixels=sum(logical(TempDeltaFF0_Image3(:)));
                                %                     NumRemovingPixels=sum(logical(Temp(:)));
                                %                     PercentPixelsRemoved=NumRemovingPixels/NumTotalPixels
                                                    %figure, imagesc(TempDeltaFF0_Image),axis equal tight
                                                    TempDeltaFF0_Image(isnan(TempDeltaFF0_Image))=0;
                                                    TempDeltaFF0_Image_Mask=logical(TempDeltaFF0_Image);
                                                    SubRegion_AnalysisRegions.Components=bwconncomp(TempDeltaFF0_Image_Mask);
                                                    SubRegion_AnalysisRegions.RegionProps=regionprops(SubRegion_AnalysisRegions.Components,'Centroid','BoundingBox');
                                                    TempSizes=[];
                                                    for y=1:length(SubRegion_AnalysisRegions.RegionProps)
                                                        SubRegion_AnalysisRegions.RegionProps(y).Area=SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(3)*SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(4);
                                                        TempSizes(y)=SubRegion_AnalysisRegions.RegionProps(y).Area;
                                                        %disp(num2str(Initial_AnalysisRegions.RegionProps(y).Area))
                                                    end

                                                    for y=1:length(SubRegion_AnalysisRegions.RegionProps)
                                                        if SubRegion_AnalysisRegions.RegionProps(y).Area>QuaSOR_Parameters.Region.Min_Region_Area_px2&&SubRegion_AnalysisRegions.RegionProps(y).Area<=QuaSOR_Parameters.Region.Max_Region_Area_px2
                                                            count=count+1;
                                                            XCoords2=ceil(SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(1)):ceil(SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(1))+ceil(SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(3));
                                                            YCoords2=ceil(SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(2)):ceil(SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(2))+ceil(SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(4));
                                                            RegionMask(YCoords2,XCoords2)=0;

                                                            if rem(ThreshTest,2)==0
                                                                SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(1)=SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(1)-QuaSOR_Parameters.General.BoxAdjustment;
                                                                SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(2)=SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(2)-QuaSOR_Parameters.General.BoxAdjustment;
                                                                SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(3)=SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(3)+QuaSOR_Parameters.General.BoxAdjustment*2;
                                                                SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(4)=SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(4)+QuaSOR_Parameters.General.BoxAdjustment*2;
                                                                SubRegion_AnalysisRegions.RegionProps(y).Area=SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(3)*SubRegion_AnalysisRegions.RegionProps(y).BoundingBox(4);
                                                            end
                                                            AnalysisRegions(count).RegionProps.Centroid=SubRegion_AnalysisRegions.RegionProps(y).Centroid;
                                                            AnalysisRegions(count).RegionProps.BoundingBox=SubRegion_AnalysisRegions.RegionProps(y).BoundingBox;
                                                            AnalysisRegions(count).RegionProps.Area=SubRegion_AnalysisRegions.RegionProps(y).Area;

                                %                             hold on
                                %                             PlotBox(AnalysisRegions(count).RegionProps.BoundingBox,'-','y',1,[],15,'y')
                                %                             disp(num2str(AnalysisRegions(count).RegionProps.Area))

                                                            Hold_TempDeltaFF0_Image=TempDeltaFF0_Image.*RegionMask;

                                                        end
                                                    end
                                                    if any(TempSizes>QuaSOR_Parameters.Region.Max_Region_Area_px2)
                                                        ThreshTest=ThreshTest+1;
                                                        cont=1;
                                                    else
                                                        clear SubRegion_AnalysisRegions TempSizes 
                                                        cont=0;
                                                    end

                                                    if ThreshTest>40
                                                        count=count+1;
                                                        cont=0;
                                                        AnalysisRegions(count).RegionProps.Centroid=Initial_AnalysisRegions.RegionProps(z).Centroid;
                                                        AnalysisRegions(count).RegionProps.BoundingBox=Initial_AnalysisRegions.RegionProps(z).BoundingBox;
                                                        AnalysisRegions(count).RegionProps.Area=Initial_AnalysisRegions.RegionProps(z).Area;
                                                    end
                                                end 
                                                clear TempDeltaFF0_Image TempDeltaFF0_Image_Mask RegionMask Hold_TempDeltaFF0_Image TempDeltaFF0_Image2 TempDeltaFF0_Image3
                                            end
                                        end
                                        clear Initial_AnalysisRegions
                                        %Pad the regions and adjust if too big at edges
                                        for z=1:length(AnalysisRegions)

                                            AnalysisRegions(z).RegionProps.BoundingBox=ceil(AnalysisRegions(z).RegionProps.BoundingBox);
                                            AnalysisRegions(z).RegionProps.BoundingBox(1)=AnalysisRegions(z).RegionProps.BoundingBox(1)-QuaSOR_Parameters.Region.RegionEdge_Padding;
                                            AnalysisRegions(z).RegionProps.BoundingBox(2)=AnalysisRegions(z).RegionProps.BoundingBox(2)-QuaSOR_Parameters.Region.RegionEdge_Padding;
                                            AnalysisRegions(z).RegionProps.BoundingBox(3)=AnalysisRegions(z).RegionProps.BoundingBox(3)+QuaSOR_Parameters.Region.RegionEdge_Padding*2;
                                            AnalysisRegions(z).RegionProps.BoundingBox(4)=AnalysisRegions(z).RegionProps.BoundingBox(4)+QuaSOR_Parameters.Region.RegionEdge_Padding*2;

                                            AnalysisRegions(z).XCoords=AnalysisRegions(z).RegionProps.BoundingBox(1):AnalysisRegions(z).RegionProps.BoundingBox(1)+AnalysisRegions(z).RegionProps.BoundingBox(3);
                                            AnalysisRegions(z).YCoords=AnalysisRegions(z).RegionProps.BoundingBox(2):AnalysisRegions(z).RegionProps.BoundingBox(2)+AnalysisRegions(z).RegionProps.BoundingBox(4);
                                            %Region_AnalysisRegions(z).XCoords=1:AnalysisRegions(z).RegionProps.BoundingBox(3);
                                            %Region_AnalysisRegions(z).YCoords=1:AnalysisRegions(z).RegionProps.BoundingBox(4);
                                            XAdjust=0;
                                            YAdjust=0;
                                            if any(AnalysisRegions(z).XCoords<1)
                                                XAdjust=XAdjust+sum(AnalysisRegions(z).XCoords<1);
                                                AnalysisRegions(z).XCoords=AnalysisRegions(z).XCoords(1+XAdjust):AnalysisRegions(z).XCoords(length(AnalysisRegions(z).XCoords));
                                                AnalysisRegions(z).RegionProps.BoundingBox(1)=1;
                                            end
                                            if any(AnalysisRegions(z).XCoords>ImageWidth)
                                                XAdjust=XAdjust-sum(AnalysisRegions(z).XCoords>ImageWidth);
                                                AnalysisRegions(z).XCoords=AnalysisRegions(z).XCoords(1):AnalysisRegions(z).XCoords(length(AnalysisRegions(z).XCoords))+XAdjust;
                                                AnalysisRegions(z).RegionProps.BoundingBox(3)=length(AnalysisRegions(z).XCoords);
                                            end       
                                            if any(AnalysisRegions(z).YCoords<1)
                                                YAdjust=YAdjust+sum(AnalysisRegions(z).YCoords<1);
                                                AnalysisRegions(z).YCoords=AnalysisRegions(z).YCoords(1+YAdjust):AnalysisRegions(z).YCoords(length(AnalysisRegions(z).YCoords));
                                                AnalysisRegions(z).RegionProps.BoundingBox(2)=1;
                                            end
                                            if any(AnalysisRegions(z).YCoords>ImageHeight)
                                                YAdjust=YAdjust-sum(AnalysisRegions(z).YCoords>ImageHeight);
                                                AnalysisRegions(z).YCoords=AnalysisRegions(z).YCoords(1):AnalysisRegions(z).YCoords(length(AnalysisRegions(z).YCoords))+YAdjust;
                                                AnalysisRegions(z).RegionProps.BoundingBox(4)=length(AnalysisRegions(z).YCoords);
                                            end
                                            AnalysisRegions(z).RegionProps.Area=AnalysisRegions(z).RegionProps.BoundingBox(3)*AnalysisRegions(z).RegionProps.BoundingBox(4);
                                        end

                            %                 figure(); subtightplot(1,1,1,[0.01,0.01],[0,0],[0,0])
                            %                 TempDeltaFF0_Image=DeltaFF0_Stack(:,:,ImageNumber);
                            %                 imagesc(TempDeltaFF0_Image),axis equal tight,caxis([0,max(TempDeltaFF0_Image(:)*0.8)]),colormap jet
                            %                 hold all
                            %                 for z=1:length(AnalysisRegions)
                            %                     PlotBox(AnalysisRegions(z).RegionProps.BoundingBox,'-','m',1,[],15,'y')
                            %                 end

                                            %Add any remaining regions that might have been cropped above
                                            %Remove all good regions so we can add any remaining
                                %             if isempty(Fit_Frame)||Fit_Frame==0
                                %                 TempDeltaFF0_Image= QuaSOR_Fitting_Struct(EpisodeNumber).DeltaFF0_Image;
                                %             else
                                %                 TempDeltaFF0_Image=QuaSOR_Fitting_Struct(EpisodeNumber).DeltaFF0_Alternative_Image;
                                %             end
                                        TempDeltaFF0_Image=DeltaFF0_Stack(:,:,ImageNumber);
                                        for z=1:length(AnalysisRegions)
                                            NewMask=ones(size(TempDeltaFF0_Image));
                                            NewMask(AnalysisRegions(z).YCoords,AnalysisRegions(z).XCoords)=0;
                                            TempDeltaFF0_Image=TempDeltaFF0_Image.*NewMask;
                                        end
                                        if QuaSOR_Parameters.GMM.FitFiltered
                                            TempDeltaFF0_Image=imfilter(TempDeltaFF0_Image, fspecial('gaussian', QuaSOR_Parameters.GMM.PreFit_FilterSize_px, QuaSOR_Parameters.GMM.PreFit_FilterSigma_px));
                                        end            
                                        TempDeltaFF0_Image(TempDeltaFF0_Image<=QuaSOR_Parameters.Region.RegionSplitting_Threshold)=0;
                                        BW_test = bwareaopen(TempDeltaFF0_Image, QuaSOR_Parameters.Region.Min_Region_Area_px2*2, conndef(2, 'minimal'));
                                        TempDeltaFF0_Image=TempDeltaFF0_Image.*BW_test;
                                        TempDeltaFF0_Image(isnan(TempDeltaFF0_Image))=0;
                                        TempDeltaFF0_Image_Mask=logical(TempDeltaFF0_Image);
                                        if sum(TempDeltaFF0_Image_Mask(:))>=QuaSOR_Parameters.Region.Min_Region_Area_px2
                                            Initial_AnalysisRegions_Round2.Components=bwconncomp(TempDeltaFF0_Image_Mask);
                                            Initial_AnalysisRegions_Round2.RegionProps=regionprops(Initial_AnalysisRegions_Round2.Components,'Centroid','BoundingBox');
                                            clear TempDeltaFF0_Image TempDeltaFF0_Image_Mask
                                    %         figure(); subtightplot(1,1,1,[0.01,0.01],[0,0],[0,0])
                                    %         if isempty(Fit_Frame)||Fit_Frame==0
                                    %             imagesc(QuaSOR_Fitting_Struct(EpisodeNumber).DeltaFF0_Image),axis equal tight,caxis([0,max(QuaSOR_Fitting_Struct(EpisodeNumber).DeltaFF0_Image(:)*0.8)]),colormap jet
                                    %         else
                                    %             imagesc(QuaSOR_Fitting_Struct(EpisodeNumber).DeltaFF0_Alternative_Image),axis equal tight,caxis([0,max(DeltaFF0_Alternative_Image(:)*0.8)]),colormap jet
                                    %         end
                                    %         hold all
                                    %         for z=1:size(Initial_AnalysisRegions_Round2.RegionProps,1)
                                    %             PlotBox(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox,'-','y',1,[],15,'y')
                                    %             Initial_AnalysisRegions_Round2.RegionProps(z).Area=Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(3)*Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(4);
                                    %             disp(num2str(Initial_AnalysisRegions_Round2.RegionProps(z).Area))
                                    %         end        

                                            %Check and adjust region sizes so that extra large regions are split if possible
                                            count=0;
                                            for z=1:length(Initial_AnalysisRegions_Round2.RegionProps)
                                                Initial_AnalysisRegions_Round2.RegionProps(z).Area=Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(3)*Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(4);
                                                %disp(num2str(Initial_AnalysisRegions_Round2.RegionProps(z).Area))
                                                if Initial_AnalysisRegions_Round2.RegionProps(z).Area<QuaSOR_Parameters.Region.Max_Region_Area_px2&&Initial_AnalysisRegions_Round2.RegionProps(z).Area>QuaSOR_Parameters.Region.Min_Region_Area_px2
                                                    count=count+1;
                                                    AnalysisRegions_Round2(count).RegionProps=Initial_AnalysisRegions_Round2.RegionProps(z);
                                                elseif Initial_AnalysisRegions_Round2.RegionProps(z).Area>=QuaSOR_Parameters.Region.Max_Region_Area_px2

                                                    Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox=[ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(1)),ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(2)),ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(3)),ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(4))];

                                                    XCoords=ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(1)):ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(1))+ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(3));
                                                    YCoords=ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(2)):ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(2))+ceil(Initial_AnalysisRegions_Round2.RegionProps(z).BoundingBox(4));

                                                    XAdjust=0;
                                                    YAdjust=0;
                                                    if any(XCoords<1)
                                                        XAdjust=XAdjust+sum(XCoords<1);
                                                        XCoords=XCoords(1+XAdjust):XCoords(length(XCoords))+XAdjust;
                                                    end
                                                    if any(XCoords>ImageWidth)
                                                        XAdjust=XAdjust-sum(XCoords>ImageWidth);
                                                        XCoords=XCoords(1):XCoords(length(XCoords))-XAdjust;
                                                    end       
                                                    if any(YCoords<1)
                                                        YAdjust=YAdjust+sum(YCoords<1);
                                                        YCoords=YCoords(1+YAdjust):YCoords(length(YCoords))+YAdjust;
                                                    end
                                                    if any(YCoords>ImageHeight)
                                                        YAdjust=YAdjust-sum(YCoords>ImageHeight);
                                                        YCoords=YCoords(1):YCoords(length(YCoords))-YAdjust;
                                                    end
                                                    RegionMask=zeros(size(Max_Image));
                                                    RegionMask(YCoords,XCoords)=1;
                            %                         if isempty(Fit_Frame)||Fit_Frame==0
                            %                             TempDeltaFF0_Image= QuaSOR_Fitting_Struct(EpisodeNumber).DeltaFF0_Image;
                            %                         else
                            %                             TempDeltaFF0_Image=QuaSOR_Fitting_Struct(EpisodeNumber).DeltaFF0_Alternative_Image;
                            %                         end
                                                    TempDeltaFF0_Image=DeltaFF0_Stack(:,:,ImageNumber);
                                                    if QuaSOR_Parameters.GMM.FitFiltered
                                                        TempDeltaFF0_Image=imfilter(TempDeltaFF0_Image, fspecial('gaussian', QuaSOR_Parameters.GMM.PreFit_FilterSize_px, QuaSOR_Parameters.GMM.PreFit_FilterSigma_px));
                                                    end
                                                    TempDeltaFF0_Image2=TempDeltaFF0_Image;
                                                    %TempDeltaFF0_Image2(TempDeltaFF0_Image2==0)=NaN;
                                                    ThreshTest=1;
                                                    cont=1;
                                                    while cont
                                                        TempDeltaFF0_Image=TempDeltaFF0_Image.*RegionMask;
                                                        TempDeltaFF0_Image(TempDeltaFF0_Image<=QuaSOR_Parameters.Region.RegionSplitting_Threshold+QuaSOR_Parameters.Region.RegionSplitting_Threshold_Increase*ThreshTest)=0;
                                    %                     Temp=TempDeltaFF0_Image2;
                                    %                     Temp(TempDeltaFF0_Image<QuaSOR_Parameters.Region.RegionSplitting_Threshold+QuaSOR_Parameters.Region.RegionSplitting_Threshold_Increase*(ThreshTest-1))=0;
                                    %                     Temp(TempDeltaFF0_Image>QuaSOR_Parameters.Region.RegionSplitting_Threshold+QuaSOR_Parameters.Region.RegionSplitting_Threshold_Increase*ThreshTest)=0;
                                    %                     TempDeltaFF0_Image3=TempDeltaFF0_Image2.*RegionMask;
                                    %                     NumTotalPixels=sum(logical(TempDeltaFF0_Image3(:)));
                                    %                     NumRemovingPixels=sum(logical(Temp(:)));
                                    %                     PercentPixelsRemoved=NumRemovingPixels/NumTotalPixels
                                                        %figure, imagesc(TempDeltaFF0_Image),axis equal tight
                                                        TempDeltaFF0_Image_Mask=logical(TempDeltaFF0_Image);
                                                        SubRegion_AnalysisRegions_Round2.Components=bwconncomp(TempDeltaFF0_Image_Mask);
                                                        SubRegion_AnalysisRegions_Round2.RegionProps=regionprops(SubRegion_AnalysisRegions_Round2.Components,'Centroid','BoundingBox');
                                                        TempSizes=[];
                                                        for y=1:length(SubRegion_AnalysisRegions_Round2.RegionProps)
                                                            SubRegion_AnalysisRegions_Round2.RegionProps(y).Area=SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(3)*SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(4);
                                                            TempSizes(y)=SubRegion_AnalysisRegions_Round2.RegionProps(y).Area;
                                                            %disp(num2str(Initial_AnalysisRegions_Round2.RegionProps(y).Area))
                                                        end

                                                        for y=1:length(SubRegion_AnalysisRegions_Round2.RegionProps)
                                                            if SubRegion_AnalysisRegions_Round2.RegionProps(y).Area>QuaSOR_Parameters.Region.Min_Region_Area_px2&&SubRegion_AnalysisRegions_Round2.RegionProps(y).Area<=QuaSOR_Parameters.Region.Max_Region_Area_px2
                                                                count=count+1;
                                                                XCoords2=ceil(SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(1)):ceil(SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(1))+ceil(SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(3));
                                                                YCoords2=ceil(SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(2)):ceil(SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(2))+ceil(SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(4));
                                                                RegionMask(YCoords2,XCoords2)=0;

                                                                if rem(ThreshTest,2)==0
                                                                    SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(1)=SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(1)-QuaSOR_Parameters.General.BoxAdjustment;
                                                                    SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(2)=SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(2)-QuaSOR_Parameters.General.BoxAdjustment;
                                                                    SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(3)=SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(3)+QuaSOR_Parameters.General.BoxAdjustment*2;
                                                                    SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(4)=SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(4)+QuaSOR_Parameters.General.BoxAdjustment*2;
                                                                    SubRegion_AnalysisRegions_Round2.RegionProps(y).Area=SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(3)*SubRegion_AnalysisRegions_Round2.RegionProps(y).BoundingBox(4);
                                                                end
                                                                AnalysisRegions_Round2(count).RegionProps=SubRegion_AnalysisRegions_Round2.RegionProps(y);
                                    %                             hold on
                                    %                             PlotBox(AnalysisRegions_Round2(count).RegionProps.BoundingBox,'-','y',1,[],15,'y')
                                    %                             disp(num2str(AnalysisRegions_Round2(count).RegionProps.Area))

                                                                Hold_TempDeltaFF0_Image=TempDeltaFF0_Image.*RegionMask;

                                                            end
                                                        end
                                                        if any(TempSizes>QuaSOR_Parameters.Region.Max_Region_Area_px2)
                                                            ThreshTest=ThreshTest+1;
                                                            cont=1;
                                                        else
                                                            clear SubRegion_AnalysisRegions_Round2 TempSizes 
                                                            cont=0;
                                                        end

                                                        if ThreshTest>40
                                                            count=count+1;
                                                            cont=0;
                                                            AnalysisRegions_Round2(count).RegionProps=Initial_AnalysisRegions_Round2.RegionProps(z);
                                                        end
                                                    end 
                                                    clear TempDeltaFF0_Image TempDeltaFF0_Image_Mask RegionMask Hold_TempDeltaFF0_Image TempDeltaFF0_Image2 TempDeltaFF0_Image3
                                                end
                                            end
                                            clear Initial_AnalysisRegions_Round2

                                            %adjust if too big at edges
                                            if exist('AnalysisRegions_Round2')
                                                if ~isempty(AnalysisRegions_Round2)
                                                    for z=1:length(AnalysisRegions_Round2)

                                                        AnalysisRegions_Round2(z).RegionProps.BoundingBox=ceil(AnalysisRegions_Round2(z).RegionProps.BoundingBox);
                                                        AnalysisRegions_Round2(z).RegionProps.BoundingBox(1)=AnalysisRegions_Round2(z).RegionProps.BoundingBox(1)-QuaSOR_Parameters.Region.RegionEdge_Padding;
                                                        AnalysisRegions_Round2(z).RegionProps.BoundingBox(2)=AnalysisRegions_Round2(z).RegionProps.BoundingBox(2)-QuaSOR_Parameters.Region.RegionEdge_Padding;
                                                        AnalysisRegions_Round2(z).RegionProps.BoundingBox(3)=AnalysisRegions_Round2(z).RegionProps.BoundingBox(3)+QuaSOR_Parameters.Region.RegionEdge_Padding*2;
                                                        AnalysisRegions_Round2(z).RegionProps.BoundingBox(4)=AnalysisRegions_Round2(z).RegionProps.BoundingBox(4)+QuaSOR_Parameters.Region.RegionEdge_Padding*2;

                                                        AnalysisRegions_Round2(z).XCoords=AnalysisRegions_Round2(z).RegionProps.BoundingBox(1):AnalysisRegions_Round2(z).RegionProps.BoundingBox(1)+AnalysisRegions_Round2(z).RegionProps.BoundingBox(3);
                                                        AnalysisRegions_Round2(z).YCoords=AnalysisRegions_Round2(z).RegionProps.BoundingBox(2):AnalysisRegions_Round2(z).RegionProps.BoundingBox(2)+AnalysisRegions_Round2(z).RegionProps.BoundingBox(4);
                                                        %Region_AnalysisRegions_Round2(z).XCoords=1:AnalysisRegions_Round2(z).RegionProps.BoundingBox(3);
                                                        %Region_AnalysisRegions_Round2(z).YCoords=1:AnalysisRegions_Round2(z).RegionProps.BoundingBox(4);
                                                        XAdjust=0;
                                                        YAdjust=0;
                                                        if any(AnalysisRegions_Round2(z).XCoords<1)
                                                            XAdjust=XAdjust+sum(AnalysisRegions_Round2(z).XCoords<1);
                                                            AnalysisRegions_Round2(z).XCoords=AnalysisRegions_Round2(z).XCoords(1+XAdjust):AnalysisRegions_Round2(z).XCoords(length(AnalysisRegions_Round2(z).XCoords));
                                                            AnalysisRegions_Round2(z).RegionProps.BoundingBox(1)=1;
                                                        end
                                                        if any(AnalysisRegions_Round2(z).XCoords>ImageWidth)
                                                            XAdjust=XAdjust-sum(AnalysisRegions_Round2(z).XCoords>ImageWidth);
                                                            AnalysisRegions_Round2(z).XCoords=AnalysisRegions_Round2(z).XCoords(1):AnalysisRegions_Round2(z).XCoords(length(AnalysisRegions_Round2(z).XCoords))+XAdjust;
                                                            AnalysisRegions_Round2(z).RegionProps.BoundingBox(3)=length(AnalysisRegions_Round2(z).XCoords);
                                                        end       
                                                        if any(AnalysisRegions_Round2(z).YCoords<1)
                                                            YAdjust=YAdjust+sum(AnalysisRegions_Round2(z).YCoords<1);
                                                            AnalysisRegions_Round2(z).YCoords=AnalysisRegions_Round2(z).YCoords(1+YAdjust):AnalysisRegions_Round2(z).YCoords(length(AnalysisRegions_Round2(z).YCoords));
                                                            AnalysisRegions_Round2(z).RegionProps.BoundingBox(2)=1;
                                                        end
                                                        if any(AnalysisRegions_Round2(z).YCoords>ImageHeight)
                                                            YAdjust=YAdjust-sum(AnalysisRegions_Round2(z).YCoords>ImageHeight);
                                                            AnalysisRegions_Round2(z).YCoords=AnalysisRegions_Round2(z).YCoords(1):AnalysisRegions_Round2(z).YCoords(length(AnalysisRegions_Round2(z).YCoords))+YAdjust;
                                                            AnalysisRegions_Round2(z).RegionProps.BoundingBox(4)=length(AnalysisRegions_Round2(z).YCoords);
                                                        end
                                                        AnalysisRegions_Round2(z).RegionProps.Area=AnalysisRegions_Round2(z).RegionProps.BoundingBox(3)*AnalysisRegions_Round2(z).RegionProps.BoundingBox(4);

                                                    end
                                                end
                                            end

                                            %Merge Structures
                                            if exist('AnalysisRegions_Round2')
                                                if ~isempty(AnalysisRegions_Round2)
                                                    AnalysisRegions=cat(2,AnalysisRegions,AnalysisRegions_Round2);clear AnalysisRegions_Round2
                                                end
                                            end
                                        end

                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %Add to QuaSOR_Fits
                                        for z=1:length(AnalysisRegions)
                            %                         for x=1:length(num2str(ROI_Count))
                            %                             fprintf('\b')
                            %                         end
                                            ROI_Count=ROI_Count+1;
                                            %fprintf(num2str(ROI_Count))

                                            Max_XCoord=round(AnalysisRegions(z).RegionProps.Centroid(2));
                                            Max_YCoord=round(AnalysisRegions(z).RegionProps.Centroid(1));
                                            YCoords=AnalysisRegions(z).YCoords;
                                            XCoords=AnalysisRegions(z).XCoords;
                                            TempRegionProps=AnalysisRegions(z).RegionProps;

                                            %XCoords=Max_XCoord(z)-QuaSOR_Parameters.Region.RegionSize_px/2:Max_XCoord(z)+QuaSOR_Parameters.Region.RegionSize_px/2;
                                            %YCoords=Max_YCoord(z)-QuaSOR_Parameters.Region.RegionSize_px/2:Max_YCoord(z)+QuaSOR_Parameters.Region.RegionSize_px/2;
                                            Region_XCoords=1:TempRegionProps.BoundingBox(3);
                                            Region_YCoords=1:TempRegionProps.BoundingBox(4);
                                            if any(XCoords<1)
                                                Region_XCoords=Region_XCoords(sum(XCoords<1)+1:length(Region_XCoords));
                                                XCoords=1:XCoords(length(XCoords));
                                            end
                                            if any(XCoords>ImageWidth)
                                                Region_XCoords=Region_XCoords(1:length(Region_XCoords)-sum(XCoords>ImageWidth));
                                                XCoords=XCoords(1):ImageWidth;
                                            end       
                                            if any(YCoords<1)
                                                Region_YCoords=Region_YCoords(sum(YCoords<1)+1:length(Region_YCoords));
                                                YCoords=1:YCoords(length(YCoords));
                                            end
                                            if any(YCoords>ImageHeight)
                                                Region_YCoords=Region_YCoords(1:length(Region_YCoords)-sum(YCoords>ImageHeight));
                                                YCoords=YCoords(1):ImageHeight;
                                            end              
                                            RegionProps.BoundingBox(1)=XCoords(1);
                                            RegionProps.BoundingBox(2)=YCoords(1);
                                            RegionProps.BoundingBox(3)=length(Region_XCoords);
                                            RegionProps.BoundingBox(4)=length(Region_YCoords);
                                            RegionProps.Centroid=TempRegionProps.Centroid;
                                            RegionProps.Area=RegionProps.BoundingBox(3)*RegionProps.BoundingBox(4);
                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                             AnalysisRegions(ROI_Count).EpisodeNumber=EpisodeNumber_Load;
                %                             AnalysisRegions(ROI_Count).ImageNumber=ImageNumber;
                %                             AnalysisRegions(ROI_Count).XCoord=round(Max_XCoord);
                %                             AnalysisRegions(ROI_Count).YCoord=round(Max_YCoord);
                %                             AnalysisRegions(ROI_Count).XCoords=Region_XCoords;
                %                             AnalysisRegions(ROI_Count).YCoords=Region_YCoords;
                %                             AnalysisRegions(ROI_Count).RegionProps=RegionProps;
                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            QuaSOR_Fits(ROI_Count).EpisodeNumber=EpisodeNumber_Load;
                                            QuaSOR_Fits(ROI_Count).ImageNumber=ImageNumber;
                                            QuaSOR_Fits(ROI_Count).XCoord=round(Max_XCoord);
                                            QuaSOR_Fits(ROI_Count).YCoord=round(Max_YCoord);
                                            QuaSOR_Fits(ROI_Count).XCoords=Region_XCoords;
                                            QuaSOR_Fits(ROI_Count).YCoords=Region_YCoords;
                                            QuaSOR_Fits(ROI_Count).RegionProps=RegionProps;
                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            QuaSOR_Fits(ROI_Count).TestImage=DeltaFF0_Stack(YCoords,XCoords,ImageNumber);
                                            QuaSOR_Fits(ROI_Count).TestImage(isnan(QuaSOR_Fits(ROI_Count).TestImage))=0;
                                            if QuaSOR_Parameters.Region.SuppressBorder
                                                Mask=ones(size(QuaSOR_Fits(ROI_Count).TestImage));
                                                Mask(QuaSOR_Parameters.Region.SuppressBorderSize+1:size(Mask,1)-QuaSOR_Parameters.Region.SuppressBorderSize,QuaSOR_Parameters.Region.SuppressBorderSize+1:size(Mask,2)-QuaSOR_Parameters.Region.SuppressBorderSize)=0;
                                                Mask=Mask*QuaSOR_Parameters.Region.SuppressBorderRatio;
                                                Mask(Mask==0)=1;
                                                QuaSOR_Fits(ROI_Count).TestImage=QuaSOR_Fits(ROI_Count).TestImage.*Mask;
                                            end
                                            QuaSOR_Fits(ROI_Count).TestImage_Z_Scaled=...
                                                round(QuaSOR_Fits(ROI_Count).TestImage/...
                                                (max(QuaSOR_Fits(ROI_Count).TestImage(:)/QuaSOR_Parameters.General.ScalePoint_Scalar)));
                                            QuaSOR_Fits(ROI_Count).TestImage_Filt =...
                                                imfilter(QuaSOR_Fits(ROI_Count).TestImage, fspecial('gaussian', QuaSOR_Parameters.GMM.PreFit_FilterSize_px, QuaSOR_Parameters.GMM.PreFit_FilterSigma_px)); 
                                            QuaSOR_Fits(ROI_Count).TestImage_Filt_Z_Scaled=...
                                                round(QuaSOR_Fits(ROI_Count).TestImage_Filt/...
                                                (max(QuaSOR_Fits(ROI_Count).TestImage_Filt(:)/QuaSOR_Parameters.General.ScalePoint_Scalar)));
                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            %convert intensity data into scaled point density representation for unfiltered and filtered data
                                            Count=0;
                                            QuaSOR_Fits(ROI_Count).ScalePoints=[];
                                            for i=1:size(QuaSOR_Fits(ROI_Count).TestImage,1)
                                                for j=1:size(QuaSOR_Fits(ROI_Count).TestImage,2)
                                                    for k=1:QuaSOR_Fits(ROI_Count).TestImage_Z_Scaled(i,j)
                                                        Count=Count+1;
                                                        QuaSOR_Fits(ROI_Count).ScalePoints(Count,:)=[i,j];
                                                    end
                                                end
                                            end
                                            Count=0;
                                            QuaSOR_Fits(ROI_Count).ScalePoints_Filt=[];
                                            for i=1:size(QuaSOR_Fits(ROI_Count).TestImage_Filt,1)
                                                for j=1:size(QuaSOR_Fits(ROI_Count).TestImage_Filt,2)
                                                    for k=1:QuaSOR_Fits(ROI_Count).TestImage_Filt_Z_Scaled(i,j)
                                                        Count=Count+1;
                                                        QuaSOR_Fits(ROI_Count).ScalePoints_Filt(Count,:)=[i,j];
                                                    end
                                                end
                                            end

                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            %Set up some variables and structs so parfor will work
                                            for k=1:QuaSOR_Parameters.Components.MaxAllowed_NumReplicates+QuaSOR_Parameters.Components.MaxAllowed_NumResets*QuaSOR_Parameters.Components.ReplicateIncrease*2
                                                for l=1:QuaSOR_Parameters.Components.MaxAllowed_NumGaussians+QuaSOR_Parameters.Components.MaxAllowed_NumResets*2
                                                    QuaSOR_Fits(ROI_Count).AllFitTests(k,l)=struct(   'GaussianFitModel',[]);
                            %                                                                     'FitImage_Amp',[],...
                            %                                                                     'FitImage_Amp_Scaled',[],...
                            %                                                                     'DistanceMatrix',zeros(QuaSOR_Parameters.Components.MaxAllowed_NumGaussians+QuaSOR_Parameters.Components.MaxAllowed_NumResets*2),...
                            %                                                                     'Amp',[],...
                            %                                                                     'Amp_Scaled',[],...
                            %                                                                     'Amp_Scaled_Score',[],...
                            %                                                                     'Amp_Score',[],...
                            %                                                                     'Var_Score',[],...
                            %                                                                     'Cov_Score',[],...
                            %                                                                     'Var_Diff_Score',[],...
                            %                                                                     'CorrCoef',[],...
                            %                                                                     'Max_NormCorr2',[],...
                            %                                                                     'Max_NormCorr2_Score',[],...
                            %                                                                     'CorrCoef_Score',[],...
                            %                                                                     'Pentalty',[],...
                            %                                                                     'MaxVar',[],...
                            %                                                                     'MaxCov',[],...
                            %                                                                     'MaxVarDiff',[],...
                            %                                                                     'GMDistFitOptions',[],...
                            %                                                                     'AllScores',[],...
                            %                                                                     'ScoreTotal',[]);
                                                end
                                            end
                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            QuaSOR_Fits(ROI_Count).NumResets=0;
                                            QuaSOR_Fits(ROI_Count).NumReplicates=QuaSOR_Parameters.Components.NumReplicates;
                                            QuaSOR_Fits(ROI_Count).MaxNumGaussians=[];
                                            QuaSOR_Fits(ROI_Count).NumReplicates=[];
                                            QuaSOR_Fits(ROI_Count).InternalReplicates=[];
                                            QuaSOR_Fits(ROI_Count).MaxVar=[];
                                            QuaSOR_Fits(ROI_Count).MaxCov=[];
                                            QuaSOR_Fits(ROI_Count).MaxVarDiff=[];
                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            QuaSOR_Fits(ROI_Count).PooledScoreTotals=zeros(QuaSOR_Parameters.Components.MaxAllowed_NumReplicates+QuaSOR_Parameters.Components.MaxAllowed_NumResets*QuaSOR_Parameters.Components.ReplicateIncrease*2,...
                                                QuaSOR_Parameters.Components.MaxAllowed_NumGaussians+QuaSOR_Parameters.Components.MaxAllowed_NumResets*2);
                                            QuaSOR_Fits(ROI_Count).Successful_Fit=[];
                                            QuaSOR_Fits(ROI_Count).Best_NumGaussian=[];
                                            QuaSOR_Fits(ROI_Count).Best_Replicate=[];
                                            QuaSOR_Fits(ROI_Count).Best_GaussianFitModel=[];
                                            QuaSOR_Fits(ROI_Count).Best_GaussianFitTest=[];
                                            QuaSOR_Fits(ROI_Count).Best_GaussianFitImage=zeros(size(QuaSOR_Fits(ROI_Count).TestImage));
                                            QuaSOR_Fits(ROI_Count).BestGaussianFitModel_Clean.mu=[];
                                            QuaSOR_Fits(ROI_Count).BestGaussianFitModel_Clean.Sigma=[];
                                            QuaSOR_Fits(ROI_Count).BestGaussianFitModel_Clean.NumComponents=[];
                                            QuaSOR_Fits(ROI_Count).BestGaussianFitModel_Clean.ComponentProportion=[];    
                                            QuaSOR_Fits(ROI_Count).TimePerROI=0;

                                            clear TempRegionProps

                                        end
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


                                    end
                                    if ProgressBarOn
                                        progressbar(1);
                                    end
                                end
                                if TextUpdateMode
                                    fprintf('Preparations Complete!\n');
                                    fprintf(['Will analyze a total of: ',num2str(ROI_Count),' ROIs\n'])
                                    fprintf('=================================================================\n')
                                else
                                    for x=1:20
                                        fprintf('\b');
                                    end
                                    if ROI_Count>0
                                        fprintf([num2str(ROI_Count),' Regions ==> Fitting in Parallel Mode...'])
                                    else
                                        fprintf(['NO REGIONS FOUND! '])
                                    end
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Set up
                            AbortStatus=get(AbortButtonHandle,'userdata');
                            if ~AbortStatus
                                parfor zzz=1:1
                                end
                                progressStepSize = 1;
                                TotalNumROIs=length(QuaSOR_Fits);
                                for ROI=1:TotalNumROIs
                                    QuaSOR_Fits(ROI).TimePerROI=0;
                                end
                                if DisplayETA
                                    ppm=0;
                                else
                                    if ~any(strcmp(OS,'MACI64'))&&ProgressBarOn
                                        ppm = ParforProgMon([StackSaveName,' || Episode # ',num2str(EpisodeNumber_Load),' || ',...
                                            num2str(TotalNumROIs),' ROIs || GMM Fitting Each ROI in Parallel: '], TotalNumROIs, progressStepSize, 1000, 80);
                                    else
                                        ppm=0;
                                    end
                                end
                                if ParallelDebug
                                    LogDir=['QuaSOR Debug Errors'];
                                    if exist([CurrentScratchDir,LogDir])
                                        rmdir([CurrentScratchDir,LogDir],'s')
                                        mkdir([CurrentScratchDir,LogDir])
                                    else
                                        warning off
                                        mkdir([CurrentScratchDir,LogDir])
                                        warning on
                                    end
                                end
                                ErrorLogDir=['QuaSOR Errors'];
                                if ~exist([CurrentScratchDir,ErrorLogDir])
                                    mkdir([CurrentScratchDir,ErrorLogDir])
                                else
                                    rmdir([CurrentScratchDir,ErrorLogDir],'s')
                                    mkdir([CurrentScratchDir,ErrorLogDir])
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Run on each Event
                            AbortStatus=get(AbortButtonHandle,'userdata');
                            if ~AbortStatus
                                if TextUpdateMode
                                    disp(['Starting GMM Calculations for: ',StackSaveName,' Episode # ',num2str(EpisodeNumber_Load),' Total # ROIs = ',num2str(TotalNumROIs)])
                                end
                                parfor ROI=1:TotalNumROIs
                                    LogDir=['QuaSOR Debug Errors'];
                                    ROI_Timer=tic;
                                    if ParallelDebug
                                        CurrentTime=clock;
                                        TimeStampString=[' Started at : ',num2str(CurrentTime(4)),':',num2str(CurrentTime(5)),':',num2str(CurrentTime(6)),'  ',...
                                            num2str(CurrentTime(2)),'/',num2str(CurrentTime(3)),'/',num2str(CurrentTime(1))];
                                        errorfile=fopen([CurrentScratchDir,LogDir,dc,'ROI ',num2str(z),'.txt'],'w');
                                        fprintf(errorfile, ['ROI ',num2str(z),'   ',TimeStampString,'\n']);fclose(errorfile);
                                    end
                                    try
                                        warning off
                                        if rem(z,1000)==0
                                            disp(['Currently Running GMM Fitting On: ',StackSaveName,' Total # ROIs = ',num2str(TotalNumROIs)])
                                        end
                                        if DisplayETA
                                            fprintf(['GMM ROI ',num2str(z),'/',num2str(TotalNumROIs),': '])
                                        end
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        General=QuaSOR_Parameters.General;
                                        UpScaling=QuaSOR_Parameters.UpScaling;
                                        Display=QuaSOR_Parameters.Display;
                                        Region=QuaSOR_Parameters.Region;
                                        Components=QuaSOR_Parameters.Components;
                                        GMM=QuaSOR_Parameters.GMM;
                                        Dist_Weights=QuaSOR_Parameters.Dist_Weights;
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        Temp_MaxVar=Dist_Weights.Var_Score.Hist_XData(length(Dist_Weights.Var_Score.Hist_XData));
                                        Temp_MaxCov=Dist_Weights.Cov_Score.Hist_XData(length(Dist_Weights.Cov_Score.Hist_XData));
                                        Temp_MaxVarDiff=Dist_Weights.Var_Diff_Score.Hist_XData(length(Dist_Weights.Var_Diff_Score.Hist_XData));
                                        Temp_MaxNumGaussians=Components.MaxNumGaussians;%Increase if no good matches are found
                                        GMDistFitOptions=GMM.GMDistFitOptions;
                                        Temp_NumReplicates=Components.NumReplicates;
                                        Temp_InternalReplicates=GMM.InternalReplicates;
                                        %Run All Fits first
                                        Searching=1;
                                        Success=0;
                                        NumResets=0;
                                        jj=1;
                                        while Searching 
                                            for ii=1:Temp_NumReplicates
                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal=[];
                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp=[];

                                                %Run Fitting
                                                cont=1;
                                                while cont
                                                    if GMM.FitFiltered
                                                        GaussianFitModel=fitgmdist(QuaSOR_Fits(ROI).ScalePoints_Filt,(jj),'Start',GMM.StartCondition,'Regularize', GMM.RegularizationValue,'replicates',Temp_InternalReplicates,'options',GMDistFitOptions);
                                                    else
                                                        GaussianFitModel=fitgmdist(QuaSOR_Fits(ROI).ScalePoints,(jj),'Start',GMM.StartCondition,'Regularize', GMM.RegularizationValue,'replicates',Temp_InternalReplicates,'options',GMDistFitOptions);
                                                    end
                                                    if any(GaussianFitModel.ComponentProportion==0)||any(GaussianFitModel.mu(:)==0)
                                                        cont=1;
                                                    else
                                                        cont=0;
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel=GaussianFitModel;
                                                    end
                                                end
                                                %Calculate Distances
                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).DistanceMatrix=zeros(QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.NumComponents);
                                                for m=1:QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.NumComponents
                                                    for n=1:QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.NumComponents
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).DistanceMatrix(m,n)=sqrt((QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(m,1)-QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(n,1))^2+(QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(m,2)-QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(n,2))^2);
                                                    end
                                                end
                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).DistanceMatrix(QuaSOR_Fits(ROI).AllFitTests(ii,jj).DistanceMatrix==0)=NaN;
                                                %Calculate Amplitudes
                                                for k=1:QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.NumComponents
                                                    %Calculate an approximate amplitude based on the mu location
                                                    MaxAmp=max(QuaSOR_Fits(ROI).TestImage(:));
                                                    QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp(k)=QuaSOR_Fits(ROI).TestImage(round(QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(k,1)),round(QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(k,2)));
                                                    %Calculate an approximate amplitude based on the component proportion of the fits
                                                    QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp_Scaled(k)=MaxAmp*QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.ComponentProportion(k);
                                                end
                                                %Flag if the gaussian params are not within the mini
                                                %range or if the amplitude is too low (probably latched
                                                %onto noise, especially if using unfiltered data
                                                FLAGGED=0;
                                                for k=1:QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.NumComponents %Flag any Gaussians that arent within the hist ranges
                                                    TestSigma=QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.Sigma(:,:,k);
                                                    if TestSigma(1,1)>Temp_MaxVar||TestSigma(2,2)>Temp_MaxVar
                                                        FLAGGED=1;
                                                    end
                                                    if abs(TestSigma(1,2))>Temp_MaxCov
                                                        FLAGGED=1;
                                                    end
                                                    if abs(TestSigma(1,1)-TestSigma(2,2))>Temp_MaxVarDiff
                                                        FLAGGED=1;
                                                    end
                                                    if QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp(k)<(GMM.Minimum_Peak_Amplitude+GMM.Minimum_Peak_Amplitude_EpisodeDelta*QuaSOR_Fits(ROI).EpisodeNumber)
                                                        FLAGGED=1;
                                                    end

                                                end

                                                if any(QuaSOR_Fits(ROI).AllFitTests(ii,jj).DistanceMatrix(:)<GMM.MinDistance)%Dont allow any options with centers too close together or
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal=0;
                                                        QuaSOR_Fits(ROI).PooledScoreTotals(ii,jj)=QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal;
                                                    elseif FLAGGED %Dont allow if parameters fall outside the histogram ranges
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal=0;
                                                        QuaSOR_Fits(ROI).PooledScoreTotals(ii,jj)=QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal;
                                                    else
                                                        %Scale by mu amplitude at that location or component proportion relative to the max amplitude
                                                        x = 1:size(QuaSOR_Fits(ROI).TestImage,2); y = 1:size(QuaSOR_Fits(ROI).TestImage,1);
                                                        [X,Y] = meshgrid(x,y);
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp=zeros(length(y),length(x));
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp_Scaled=zeros(length(y),length(x));
                                                        for k=1:QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.NumComponents

                                                            %flip sigma on diagonal
                                                            TestSigma=QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.Sigma(:,:,k);
                                                            temp1=TestSigma(1,1);
                                                            temp2=TestSigma(2,2);
                                                            TestSigma(1,1)=temp2;TestSigma(2,2)=temp1;

                                                            %less accurate
                                                            F1 = mvnpdf([X(:) Y(:)],fliplr(QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(k,:)),TestSigma);
                                                            F1 = reshape(F1,length(y),length(x));
                                                            F1=(F1/max(F1(:)))*QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp_Scaled(k);
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp_Scaled=QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp_Scaled+F1;

                                                            %maybe more accurate with well isolated spots
                                                            F1 = mvnpdf([X(:) Y(:)],fliplr(QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(k,:)),TestSigma);
                                                            F1 = reshape(F1,length(y),length(x));
                                                            F1=(F1/max(F1(:)))*QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp(k);
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp=QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp+F1;

                                                            %All Weighting Score calculaitons

                                                            %More accurate of the two amp score weights
                                                            tmp = abs(Dist_Weights.Amp_Score.Hist_XData-QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp_Scaled(k));
                                                            [~, idx] = min(tmp);
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp_Scaled_Score(k)=(Dist_Weights.Amp_Score.Norm_Hist_Shift(idx))*Dist_Weights.Amp_Score.Scalar;

                                                            %Not using this score right now
                                                            tmp = abs(Dist_Weights.Amp_Score.Hist_XData-QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp(k));
                                                            [~, idx] = min(tmp);
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp_Score(k)=(Dist_Weights.Amp_Score.Norm_Hist_Shift(idx))*Dist_Weights.Amp_Score.Scalar;

                                                            tmp = abs(Dist_Weights.Var_Score.Hist_XData-TestSigma(1,1));
                                                            [~, idx] = min(tmp);
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).Var_Score(k,1)=(Dist_Weights.Var_Score.Norm_Hist_Shift(idx))*Dist_Weights.Var_Score.Scalar;

                                                            tmp = abs(Dist_Weights.Var_Score.Hist_XData-TestSigma(2,2));
                                                            [~, idx] = min(tmp);
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).Var_Score(k,2)=(Dist_Weights.Var_Score.Norm_Hist_Shift(idx))*Dist_Weights.Var_Score.Scalar;

                                                            tmp = abs(Dist_Weights.Cov_Score.Hist_XData-(abs(TestSigma(1,2))));
                                                            [~, idx] = min(tmp);
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).Cov_Score(k)=(Dist_Weights.Cov_Score.Norm_Hist_Shift(idx))*Dist_Weights.Cov_Score.Scalar;

                                                            tmp = abs(Dist_Weights.Var_Diff_Score.Hist_XData-abs(TestSigma(1,1)-TestSigma(2,2)));
                                                            [~, idx] = min(tmp);
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).Var_Diff_Score(k)=(Dist_Weights.Var_Diff_Score.Norm_Hist_Shift(idx))*Dist_Weights.Var_Diff_Score.Scalar;

                                                        end
                                                        if GMM.TestFiltered
                                                            TestCorr = normxcorr2(QuaSOR_Fits(ROI).TestImage_Filt,QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp);
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).CorrCoef = corr2(QuaSOR_Fits(ROI).TestImage_Filt,QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp);
                                                        else
                                                            TestCorr = normxcorr2(QuaSOR_Fits(ROI).TestImage,QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp);
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).CorrCoef = corr2(QuaSOR_Fits(ROI).TestImage,QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp);
                                                        end
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).Max_NormCorr2=max(TestCorr(:));
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).Max_NormCorr2_Score=QuaSOR_Fits(ROI).AllFitTests(ii,jj).Max_NormCorr2*GMM.Corr_Score_Scalar; %Not used right now

                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).CorrCoef_Score=QuaSOR_Fits(ROI).AllFitTests(ii,jj).CorrCoef*GMM.Corr_Score_Scalar;

                                                        if GMM.PenalizeMoreComponents
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).Pentalty=(jj-1)*GMM.NumCompPenalty;
                                                        else
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).Pentalty=0;
                                                        end
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).MaxVar=Temp_MaxVar;
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).MaxCov=Temp_MaxCov;
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).MaxVarDiff=Temp_MaxVarDiff;
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).GMDistFitOptions.MaxIter=GMDistFitOptions.MaxIter;
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).AllScores=...
                                                            [QuaSOR_Fits(ROI).AllFitTests(ii,jj).CorrCoef_Score,...
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).Pentalty,...
                                                            mean(QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp_Scaled),...
                                                            mean(QuaSOR_Fits(ROI).AllFitTests(ii,jj).Var_Score(:)),...
                                                            mean(QuaSOR_Fits(ROI).AllFitTests(ii,jj).Cov_Score),...
                                                            mean(QuaSOR_Fits(ROI).AllFitTests(ii,jj).Var_Diff_Score)];
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal=sum(QuaSOR_Fits(ROI).AllFitTests(ii,jj).AllScores);
                                                        QuaSOR_Fits(ROI).PooledScoreTotals(ii,jj)=QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal;
                                                end
                                            end
                                            %Increase num components and adjust parameters
                                            if NumResets>Components.MaxAllowed_NumResets %Will kill the searching after so many repeats
                                                Searching=0;
                                                Success=0;
                                            elseif jj>=Components.MaxAllowed_NumGaussians||ii>=Components.MaxAllowed_NumReplicates %reset if you hit the maximum allowed replicates or num components and then weaken all restrictions to try to fit
                                                if any(QuaSOR_Fits(ROI).PooledScoreTotals(:)>0)
                                                    Searching=0;
                                                    Success=1;
                                                else
                                                    NumResets=NumResets+1;

                                                    jj=1;
                                                    %One reason it often fails is a large region so also mask the image to try to get spots to split
                                                    TempImage=QuaSOR_Fits(ROI).TestImage_Z_Scaled;
                                                    TempImage(TempImage<(Components.Repeat_Amp_Threshold+(NumResets-1)/2*Components.Repeat_Amp_Threshold)*QuaSOR_Parameters.General.ScalePoint_Scalar)=0;
                                                    Count=0;
                                                    QuaSOR_Fits(ROI).ScalePoints=[];
                                                    for m=1:size(TempImage,1)
                                                        for n=1:size(TempImage,2)
                                                            for k=1:TempImage(m,n)
                                                                Count=Count+1;
                                                                QuaSOR_Fits(ROI).ScalePoints(Count,:)=[m,n];
                                                            end
                                                        end
                                                    end
                                                    TempImage=QuaSOR_Fits(ROI).TestImage_Filt_Z_Scaled;
                                                    TempImage(TempImage<(Components.Repeat_Amp_Threshold+(NumResets-1)/2*Components.Repeat_Amp_Threshold)*QuaSOR_Parameters.General.ScalePoint_Scalar)=0;
                                                    Count=0;
                                                    QuaSOR_Fits(ROI).ScalePoints_Filt=[];
                                                    for m=1:size(TempImage,1)
                                                        for n=1:size(TempImage,2)
                                                            for k=1:TempImage(m,n)
                                                                Count=Count+1;
                                                                QuaSOR_Fits(ROI).ScalePoints_Filt(Count,:)=[m,n];
                                                            end
                                                        end
                                                    end
                                                    %weaken parameters
                                                    %QuaSOR_Fits(ROI).AllFitTests=struct('GaussianFitModel',[]);
                            %                         for k=1:Components.MaxAllowed_NumReplicates+Components.MaxAllowed_NumResets*Components.ReplicateIncrease*2
                            %                             for l=1:Components.MaxAllowed_NumGaussians+Components.MaxAllowed_NumResets*2
                            %                                 QuaSOR_Fits(ROI).AllFitTests(k,l)=struct(   'GaussianFitModel',[],...
                            %                                                                         'FitImage_Amp',[],...
                            %                                                                         'FitImage_Amp_Scaled',[],...
                            %                                                                         'DistanceMatrix',zeros(Components.MaxAllowed_NumGaussians+Components.MaxAllowed_NumResets*2),...
                            %                                                                         'Amp',[],...
                            %                                                                         'Amp_Scaled',[],...
                            %                                                                         'Amp_Scaled_Score',[],...
                            %                                                                         'Amp_Score',[],...
                            %                                                                         'Var_Score',[],...
                            %                                                                         'Cov_Score',[],...
                            %                                                                         'Var_Diff_Score',[],...
                            %                                                                         'CorrCoef',[],...
                            %                                                                         'Max_NormCorr2',[],...
                            %                                                                         'Max_NormCorr2_Score',[],...
                            %                                                                         'CorrCoef_Score',[],...
                            %                                                                         'Pentalty',[],...
                            %                                                                         'MaxVar',[],...
                            %                                                                         'MaxCov',[],...
                            %                                                                         'MaxVarDiff',[],...
                            %                                                                         'GMM.GMDistFitOptions',[],...
                            %                                                                         'AllScores',[],...
                            %                                                                         'ScoreTotal',[]);
                            %                             end
                            %                         end
                                                    QuaSOR_Fits(ROI).NumResets=NumResets;
                                                    Temp_NumReplicates=Components.NumReplicates;
                                                    QuaSOR_Fits(ROI).PooledScoreTotals=zeros(Components.MaxAllowed_NumReplicates+Components.MaxAllowed_NumResets*Components.ReplicateIncrease*2,...
                                                        Components.MaxAllowed_NumGaussians+Components.MaxAllowed_NumResets*2);
                                                    Temp_MaxVar=Dist_Weights.Var_Score.Hist_XData(length(Dist_Weights.Var_Score.Hist_XData))+NumResets*10;
                                                    Temp_MaxCov=Dist_Weights.Cov_Score.Hist_XData(length(Dist_Weights.Cov_Score.Hist_XData))+NumResets*5;
                                                    Temp_MaxVarDiff=Dist_Weights.Var_Diff_Score.Hist_XData(length(Dist_Weights.Var_Diff_Score.Hist_XData))+NumResets*5;
                                                    Temp_MaxNumGaussians=Components.MaxNumGaussians;
                                                    GMDistFitOptions=GMM.GMDistFitOptions;
                                                    Temp_InternalReplicates=Temp_InternalReplicates+NumResets*2;
                                                    %Temp_InternalReplicates=GMM.InternalReplicates;
                                                    Searching=1;

                                                end
                                            elseif jj<Temp_MaxNumGaussians
                                                jj=jj+1;

                                                %increase num replicates as the number of componentes increases to increase the likelihood of finding a good match
                                                Temp_NumReplicates=Temp_NumReplicates+Components.ReplicateIncrease;
                                                Searching=1;
                                            elseif any(QuaSOR_Fits(ROI).PooledScoreTotals(:)>0)
                                                Searching=0;
                                                Success=1;
                                            else
                                                %adjust conditions to make a fit easier
                                                Temp_MaxVar=Temp_MaxVar+10;
                                                Temp_MaxCov=Temp_MaxCov+2;
                                                Temp_MaxVarDiff=Temp_MaxVarDiff+10;
                                                if GMDistFitOptions.MaxIter>5
                                                    GMDistFitOptions.MaxIter=GMDistFitOptions.MaxIter-1;
                                                end
                                                Temp_MaxNumGaussians=Temp_MaxNumGaussians+1;
                                                jj=jj+1;
                                                %increase num replicates as the number of componentes increases to increase the likelihood of finding a good match
                                                Temp_NumReplicates=Temp_NumReplicates+Components.ReplicateIncrease;
                                                Searching=1;
                                            end
                                        end
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        if Success
                                            QuaSOR_Fits(ROI).MaxNumGaussians=Temp_MaxNumGaussians;
                                            QuaSOR_Fits(ROI).NumReplicates=Temp_NumReplicates;
                                            QuaSOR_Fits(ROI).InternalReplicates=Temp_InternalReplicates;
                                            QuaSOR_Fits(ROI).MaxVar=Temp_MaxVar;
                                            QuaSOR_Fits(ROI).MaxCov=Temp_MaxCov;
                                            QuaSOR_Fits(ROI).MaxVarDiff=Temp_MaxVarDiff;
                                            %Pick Winner
                                            QuaSOR_Fits(ROI).Successful_Fit=1;
                                            [~,QuaSOR_Fits(ROI).Best_NumGaussian]=max(max(QuaSOR_Fits(ROI).PooledScoreTotals,[],1));
                                            test=QuaSOR_Fits(ROI).PooledScoreTotals(:,QuaSOR_Fits(ROI).Best_NumGaussian);
                                            [~,QuaSOR_Fits(ROI).Best_Replicate]=max(test(:),[],1);

                                            %Assign winner data
                                            QuaSOR_Fits(ROI).Best_GaussianFitModel=QuaSOR_Fits(ROI).AllFitTests(QuaSOR_Fits(ROI).Best_Replicate,QuaSOR_Fits(ROI).Best_NumGaussian).GaussianFitModel;
                                            QuaSOR_Fits(ROI).Best_GaussianFitTest=QuaSOR_Fits(ROI).AllFitTests(QuaSOR_Fits(ROI).Best_Replicate,QuaSOR_Fits(ROI).Best_NumGaussian);
                                            QuaSOR_Fits(ROI).Best_GaussianFitImage=QuaSOR_Fits(ROI).AllFitTests(QuaSOR_Fits(ROI).Best_Replicate,QuaSOR_Fits(ROI).Best_NumGaussian).FitImage_Amp;
                                            QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.Amp=QuaSOR_Fits(ROI).AllFitTests(QuaSOR_Fits(ROI).Best_Replicate,QuaSOR_Fits(ROI).Best_NumGaussian).Amp;
                                            QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.Amp_Scaled=QuaSOR_Fits(ROI).AllFitTests(QuaSOR_Fits(ROI).Best_Replicate,QuaSOR_Fits(ROI).Best_NumGaussian).Amp_Scaled;
                                            QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.mu=QuaSOR_Fits(ROI).Best_GaussianFitModel.mu;
                                            QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.Sigma=QuaSOR_Fits(ROI).Best_GaussianFitModel.Sigma;
                                            QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.NumComponents=QuaSOR_Fits(ROI).Best_GaussianFitModel.NumComponents;
                                            QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.ComponentProportion=QuaSOR_Fits(ROI).Best_GaussianFitModel.ComponentProportion;                      
                                        else
                                            QuaSOR_Fits(ROI).Successful_Fit=0;
                                        end
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        QuaSOR_Fits(ROI).TimePerROI=toc(ROI_Timer);
                                        if DisplayETA
                                            if QuaSOR_Fits(ROI).Successful_Fit
                                                fprintf(['Fit ',num2str(QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.NumComponents),'Comp'])
                                            else
                                                fprintf('FAILED')
                                            end
                                            ETA1=(QuaSOR_Fits(ROI).TimePerROI*(TotalNumROIs-ROI))/3600;
                                            fprintf([' ==> ',num2str(round(QuaSOR_Fits(ROI).TimePerROI)),'s  ETA = ',num2str(round(ETA1*10)/10),' hrs\n'])
                                        else
                                            if ~any(strcmp(OS,'MACI64'))&&ProgressBarOn
                                                ppm.increment();
                                            end
                                        end
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    catch
                                        warning on
                                        warning(['Error1 in ROI #',num2str(ROI)]);disp(['Error1 in ROI #',num2str(ROI)])
                                        warning(['Error1 in ROI #',num2str(ROI)]);disp(['Error1 in ROI #',num2str(ROI)])
                                        errorfile=fopen([CurrentScratchDir,ErrorLogDir,dc,'Error1 in ROI ',num2str(ROI),'.txt'],'w');
                                        fprintf(errorfile, ['Error1 in ROI ',num2str(ROI),'.txt']);fclose(errorfile);
                                        warning off
                                    end
                                    if ParallelDebug
                                        CurrentTime=clock;
                                        TimeStampString=['Finished at : ',num2str(CurrentTime(4)),':',num2str(CurrentTime(5)),':',num2str(CurrentTime(6)),'  ',...
                                            num2str(CurrentTime(2)),'/',num2str(CurrentTime(3)),'/',num2str(CurrentTime(1))];
                                        errorfile=fopen([CurrentScratchDir,LogDir,dc,'ROI ',num2str(ROI),'.txt'],'w');
                                        fprintf(errorfile, ['ROI ',num2str(ROI),'   ',TimeStampString,'\n']);fclose(errorfile);
                                    end
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Check for Errors
                            AbortStatus=get(AbortButtonHandle,'userdata');
                            if ~AbortStatus
                                if TextUpdateMode
                                    disp('Checking for Error ROIs...')
                                end
                                Prefix='Error1 in ROI ';
                                Suffix='.txt';
                                clear ErrorFileList
                                ErrorFileList=[];
                                FileList=dir(ErrorLogDir);
                                NumErrors=0;
                                for err=1:length(FileList)
                                    TempName=FileList(err).name;
                                    if length(TempName)>5
                                        NumErrors=NumErrors+1;
                                        FixedName=TempName(1:length(TempName)-length(Suffix));
                                        FixedName2=FixedName(length(Prefix)+1:length(FixedName));
                                        ErrorFileList(NumErrors).name=FileList(err).name;
                                        ErrorFileList(NumErrors).ErrorNum=str2num(FixedName2);
                                    end
                                    clear TempName FixedName2 FixedName
                                end
                                warning on;
                                if NumErrors>0
                                    warning(['Found ',num2str(NumErrors),' Errors'])
                                    warning(['Found ',num2str(NumErrors),' Errors'])
                                    warning(['Found ',num2str(NumErrors),' Errors'])
                                    warning(['Found ',num2str(NumErrors),' Errors'])
                                end
                                warning off
                                QuaSOR_Fitting_Struct(EpisodeNumber).ErrorFileList=ErrorFileList;
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Re-Run on each Error Event
                            AbortStatus=get(AbortButtonHandle,'userdata');
                            if ~AbortStatus
                                if NumErrors>0
                                    DisplayETA=1;
                                    disp(['Starting Error ROI GMM Calculations for: ',StackSaveName])
                                    for err=1:NumErrors
                                        z=ErrorFileList(err).ErrorNum;
                                        try
                                            warning off
                                            ROITimer=tic;
                                            if DisplayETA
                                                fprintf(['GMM ROI ',num2str(ROI),'/',num2str(TotalNumROIs),': '])
                                            end
                                            %QuaSOR_Fits(ROI).PooledScoreTotals=[];
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            Temp_MaxVar=QuaSOR_Parameters.Dist_Weights.Var_Score.Hist_XData(length(QuaSOR_Parameters.Dist_Weights.Var_Score.Hist_XData));
                                            Temp_MaxCov=QuaSOR_Parameters.Dist_Weights.Cov_Score.Hist_XData(length(QuaSOR_Parameters.Dist_Weights.Cov_Score.Hist_XData));
                                            Temp_MaxVarDiff=QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Hist_XData(length(QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Hist_XData));
                                            Temp_MaxNumGaussians=QuaSOR_Parameters.Components.MaxNumGaussians;%Increase if no good matches are found
                                            GMDistFitOptions=QuaSOR_Parameters.GMM.GMDistFitOptions;
                                            Temp_NumReplicates=QuaSOR_Parameters.Components.NumReplicates;
                                            Temp_InternalReplicates=QuaSOR_Parameters.GMM.InternalReplicates;
                                            %Run All Fits first
                                            Searching=1;
                                            Success=0;
                                            NumResets=0;
                                            jj=1;
                                            while Searching 
                                                for ii=1:NumReplicates
                                                    QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal=[];
                                                    QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp=[];

                                                    %Run Fitting
                                                    cont=1;
                                                    while cont
                                                        if QuaSOR_Parameters.GMM.FitFiltered
                                                            GaussianFitModel=fitgmdist(QuaSOR_Fits(ROI).ScalePoints_Filt,(jj),'Start',QuaSOR_Parameters.GMM.StartCondition,'Regularize', QuaSOR_Parameters.GMM.RegularizationValue,'replicates',Temp_InternalReplicates,'options',GMDistFitOptions);
                                                        else
                                                            GaussianFitModel=fitgmdist(QuaSOR_Fits(ROI).ScalePoints,(jj),'Start',QuaSOR_Parameters.GMM.StartCondition,'Regularize', QuaSOR_Parameters.GMM.RegularizationValue,'replicates',Temp_InternalReplicates,'options',GMDistFitOptions);
                                                        end
                                                        if any(GaussianFitModel.ComponentProportion==0)||any(GaussianFitModel.mu(:)==0)
                                                            cont=1;
                                                        else
                                                            cont=0;
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel=GaussianFitModel;
                                                        end
                                                    end
                                                    %Calculate Distances
                                                    QuaSOR_Fits(ROI).AllFitTests(ii,jj).DistanceMatrix=zeros(QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.NumComponents);
                                                    for m=1:QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.NumComponents
                                                        for n=1:QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.NumComponents
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).DistanceMatrix(m,n)=sqrt((QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(m,1)-QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(n,1))^2+(QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(m,2)-QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(n,2))^2);
                                                        end
                                                    end
                                                    QuaSOR_Fits(ROI).AllFitTests(ii,jj).DistanceMatrix(QuaSOR_Fits(ROI).AllFitTests(ii,jj).DistanceMatrix==0)=NaN;
                                                    %Calculate Amplitudes
                                                    for k=1:QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.NumComponents
                                                        %Calculate an approximate amplitude based on the mu location
                                                        MaxAmp=max(QuaSOR_Fits(ROI).TestImage(:));
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp(k)=QuaSOR_Fits(ROI).TestImage(round(QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(k,1)),round(QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(k,2)));
                                                        %Calculate an approximate amplitude based on the component proportion of the fits
                                                        QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp_Scaled(k)=MaxAmp*QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.ComponentProportion(k);
                                                    end
                                                    %Flag if the gaussian params are not within the mini
                                                    %range or if the amplitude is too low (probably latched
                                                    %onto noise, especially if using unfiltered data
                                                    FLAGGED=0;
                                                    for k=1:QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.NumComponents %Flag any Gaussians that arent within the hist ranges
                                                        TestSigma=QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.Sigma(:,:,k);
                                                        if TestSigma(1,1)>Temp_MaxVar||TestSigma(2,2)>Temp_MaxVar
                                                            FLAGGED=1;
                                                        end
                                                        if abs(TestSigma(1,2))>Temp_MaxCov
                                                            FLAGGED=1;
                                                        end
                                                        if abs(TestSigma(1,1)-TestSigma(2,2))>Temp_MaxVarDiff
                                                            FLAGGED=1;
                                                        end
                                                        if QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp(k)<QuaSOR_Parameters.GMM.Minimum_Peak_Amplitude
                                                                FLAGGED=1;
                                                        end

                                                    end

                                                    if any(QuaSOR_Fits(ROI).AllFitTests(ii,jj).DistanceMatrix(:)<QuaSOR_Parameters.GMM.MinDistance)%Dont allow any options with centers too close together or
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal=0;
                                                            QuaSOR_Fits(ROI).PooledScoreTotals(ii,jj)=QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal;
                                                        elseif FLAGGED %Dont allow if parameters fall outside the histogram ranges
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal=0;
                                                            QuaSOR_Fits(ROI).PooledScoreTotals(ii,jj)=QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal;
                                                        else
                                                            %Scale by mu amplitude at that location or component proportion relative to the max amplitude
                                                            x = 1:size(QuaSOR_Fits(ROI).TestImage,2); y = 1:size(QuaSOR_Fits(ROI).TestImage,1);
                                                            [X,Y] = meshgrid(x,y);
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp=zeros(length(y),length(x));
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp_Scaled=zeros(length(y),length(x));
                                                            for k=1:QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.NumComponents

                                                                %flip sigma on diagonal
                                                                TestSigma=QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.Sigma(:,:,k);
                                                                temp1=TestSigma(1,1);
                                                                temp2=TestSigma(2,2);
                                                                TestSigma(1,1)=temp2;TestSigma(2,2)=temp1;

                                                                %less accurate
                                                                F1 = mvnpdf([X(:) Y(:)],fliplr(QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(k,:)),TestSigma);
                                                                F1 = reshape(F1,length(y),length(x));
                                                                F1=(F1/max(F1(:)))*QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp_Scaled(k);
                                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp_Scaled=QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp_Scaled+F1;

                                                                %maybe more accurate with well isolated spots
                                                                F1 = mvnpdf([X(:) Y(:)],fliplr(QuaSOR_Fits(ROI).AllFitTests(ii,jj).GaussianFitModel.mu(k,:)),TestSigma);
                                                                F1 = reshape(F1,length(y),length(x));
                                                                F1=(F1/max(F1(:)))*QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp(k);
                                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp=QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp+F1;

                                                                %All Weighting Score calculaitons

                                                                %More accurate of the two amp score weights
                                                                tmp = abs(QuaSOR_Parameters.Dist_Weights.Amp_Score.Hist_XData-QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp_Scaled(k));
                                                                [~, idx] = min(tmp);
                                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp_Scaled_Score(k)=(QuaSOR_Parameters.Dist_Weights.Amp_Score.Norm_Hist_Shift(idx))*QuaSOR_Parameters.Dist_Weights.Amp_Score.Scalar;

                                                                %Not using this score right now
                                                                tmp = abs(QuaSOR_Parameters.Dist_Weights.Amp_Score.Hist_XData-QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp(k));
                                                                [~, idx] = min(tmp);
                                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp_Score(k)=(QuaSOR_Parameters.Dist_Weights.Amp_Score.Norm_Hist_Shift(idx))*QuaSOR_Parameters.Dist_Weights.Amp_Score.Scalar;

                                                                tmp = abs(QuaSOR_Parameters.Dist_Weights.Var_Score.Hist_XData-TestSigma(1,1));
                                                                [~, idx] = min(tmp);
                                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).Var_Score(k,1)=(QuaSOR_Parameters.Dist_Weights.Var_Score.Norm_Hist_Shift(idx))*QuaSOR_Parameters.Dist_Weights.Var_Score.Scalar;

                                                                tmp = abs(QuaSOR_Parameters.Dist_Weights.Var_Score.Hist_XData-TestSigma(2,2));
                                                                [~, idx] = min(tmp);
                                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).Var_Score(k,2)=(QuaSOR_Parameters.Dist_Weights.Var_Score.Norm_Hist_Shift(idx))*QuaSOR_Parameters.Dist_Weights.Var_Score.Scalar;

                                                                tmp = abs(QuaSOR_Parameters.Dist_Weights.Cov_Score.Hist_XData-(abs(TestSigma(1,2))));
                                                                [~, idx] = min(tmp);
                                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).Cov_Score(k)=(QuaSOR_Parameters.Dist_Weights.Cov_Score.Norm_Hist_Shift(idx))*QuaSOR_Parameters.Dist_Weights.Cov_Score.Scalar;

                                                                tmp = abs(QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Hist_XData-abs(TestSigma(1,1)-TestSigma(2,2)));
                                                                [~, idx] = min(tmp);
                                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).Var_Diff_Score(k)=(QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Norm_Hist_Shift(idx))*QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Scalar;

                                                            end
                                                            if QuaSOR_Parameters.GMM.TestFiltered
                                                                TestCorr = normxcorr2(QuaSOR_Fits(ROI).TestImage_Filt,QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp);
                                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).CorrCoef = corr2(QuaSOR_Fits(ROI).TestImage_Filt,QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp);
                                                            else
                                                                TestCorr = normxcorr2(QuaSOR_Fits(ROI).TestImage,QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp);
                                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).CorrCoef = corr2(QuaSOR_Fits(ROI).TestImage,QuaSOR_Fits(ROI).AllFitTests(ii,jj).FitImage_Amp);
                                                            end
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).Max_NormCorr2=max(TestCorr(:));
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).Max_NormCorr2_Score=QuaSOR_Fits(ROI).AllFitTests(ii,jj).Max_NormCorr2*QuaSOR_Parameters.GMM.Corr_Score_Scalar; %Not used right now

                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).CorrCoef_Score=QuaSOR_Fits(ROI).AllFitTests(ii,jj).CorrCoef*QuaSOR_Parameters.GMM.Corr_Score_Scalar;

                                                            if QuaSOR_Parameters.GMM.PenalizeMoreComponents
                                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).Pentalty=(jj-1)*QuaSOR_Parameters.GMM.NumCompPenalty;
                                                            else
                                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).Pentalty=0;
                                                            end
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).MaxVar=Temp_MaxVar;
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).MaxCov=Temp_MaxCov;
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).MaxVarDiff=Temp_MaxVarDiff;
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).GMDistFitOptions.MaxIter=GMDistFitOptions.MaxIter;
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).AllScores=...
                                                                [QuaSOR_Fits(ROI).AllFitTests(ii,jj).CorrCoef_Score,...
                                                                QuaSOR_Fits(ROI).AllFitTests(ii,jj).Pentalty,...
                                                                mean(QuaSOR_Fits(ROI).AllFitTests(ii,jj).Amp_Scaled),...
                                                                mean(QuaSOR_Fits(ROI).AllFitTests(ii,jj).Var_Score(:)),...
                                                                mean(QuaSOR_Fits(ROI).AllFitTests(ii,jj).Cov_Score),...
                                                                mean(QuaSOR_Fits(ROI).AllFitTests(ii,jj).Var_Diff_Score)];
                                                            QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal=sum(QuaSOR_Fits(ROI).AllFitTests(ii,jj).AllScores);
                                                            QuaSOR_Fits(ROI).PooledScoreTotals(ii,jj)=QuaSOR_Fits(ROI).AllFitTests(ii,jj).ScoreTotal;

                                        %                             x = 0:0.1:size(QuaSOR_Fits(ROI).TestImage,2); y = 0:0.1:size(QuaSOR_Fits(ROI).TestImage,1);
                                        %                             [X,Y] = meshgrid(x,y);
                                        %                             QuaSOR_Fits(ROI).AllFitTests(i,j).FitImage_Amp_Upscale=zeros(length(y),length(x));
                                        %                             for k=1:QuaSOR_Fits(ROI).AllFitTests(i,j).GaussianFitModel.NumComponents
                                        %                                 Amp=QuaSOR_Fits(ROI).TestImage(round(QuaSOR_Fits(ROI).AllFitTests(i,j).GaussianFitModel.mu(k,1)),round(QuaSOR_Fits(ROI).AllFitTests(i,j).GaussianFitModel.mu(k,2)));
                                        %                                 TestSigma=QuaSOR_Fits(ROI).AllFitTests(i,j).GaussianFitModel.Sigma(:,:,k);
                                        %                                 temp1=TestSigma(1,1);
                                        %                                 temp2=TestSigma(2,2);
                                        %                                 TestSigma(1,1)=temp2;TestSigma(2,2)=temp1;
                                        %                                 F1 = mvnpdf([X(:) Y(:)],fliplr(QuaSOR_Fits(ROI).AllFitTests(i,j).GaussianFitModel.mu(k,:)),TestSigma);
                                        %                                 F1 = reshape(F1,length(y),length(x));
                                        %                                 F1=(F1/max(F1(:)))*Amp;
                                        %                                 QuaSOR_Fits(ROI).AllFitTests(i,j).FitImage_Amp_Upscale=QuaSOR_Fits(ROI).AllFitTests(i,j).FitImage_Amp_Upscale+F1;
                                        %                                 clear TestSigma F1
                                        %                             end
                                                    end
                                                end
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %Increase num components and adjust parameters
                                                if NumResets>QuaSOR_Parameters.Components.MaxAllowed_NumResets %Will kill the searching after so many repeats
                                                    Searching=0;
                                                    Success=0;
                                                elseif jj>=QuaSOR_Parameters.Components.MaxAllowed_NumGaussians||ii>=QuaSOR_Parameters.Components.MaxAllowed_NumReplicates %reset if you hit the maximum allowed replicates or num components and then weaken all restrictions to try to fit
                                                    if any(QuaSOR_Fits(ROI).PooledScoreTotals(:)>0)
                                                        Searching=0;
                                                        Success=1;
                                                    else
                                                        NumResets=NumResets+1;
                                                        jj=1;
                                                        %One reason it often fails is a large region so also mask the image to try to get spots to split
                                                        TempImage=QuaSOR_Fits(ROI).TestImage_Z_Scaled;
                                                        TempImage(TempImage<(QuaSOR_Parameters.Components.Repeat_Amp_Threshold+(NumResets-1)/2*QuaSOR_Parameters.Components.Repeat_Amp_Threshold)*QuaSOR_Parameters.General.ScalePoint_Scalar)=0;
                                                        Count=0;
                                                        QuaSOR_Fits(ROI).ScalePoints=[];
                                                        for m=1:size(TempImage,1)
                                                            for n=1:size(TempImage,2)
                                                                for k=1:TempImage(m,n)
                                                                    Count=Count+1;
                                                                    QuaSOR_Fits(ROI).ScalePoints(Count,:)=[m,n];
                                                                end
                                                            end
                                                        end
                                                        TempImage=QuaSOR_Fits(ROI).TestImage_Filt_Z_Scaled;
                                                        TempImage(TempImage<(QuaSOR_Parameters.Components.Repeat_Amp_Threshold+(NumResets-1)/2*QuaSOR_Parameters.Components.Repeat_Amp_Threshold)*QuaSOR_Parameters.General.ScalePoint_Scalar)=0;
                                                        Count=0;
                                                        QuaSOR_Fits(ROI).ScalePoints_Filt=[];
                                                        for m=1:size(TempImage,1)
                                                            for n=1:size(TempImage,2)
                                                                for k=1:TempImage(m,n)
                                                                    Count=Count+1;
                                                                    QuaSOR_Fits(ROI).ScalePoints_Filt(Count,:)=[m,n];
                                                                end
                                                            end
                                                        end
                                                        %weaken parameters
                                                        %QuaSOR_Fits(ROI).AllFitTests=struct('GaussianFitModel',[]);
                                                        for k=1:QuaSOR_Parameters.Components.MaxAllowed_NumReplicates+...
                                                                QuaSOR_Parameters.Components.MaxAllowed_NumResets*QuaSOR_Parameters.Components.ReplicateIncrease*2
                                                            for l=1:QuaSOR_Parameters.Components.MaxAllowed_NumGaussians+QuaSOR_Parameters.Components.MaxAllowed_NumResets*2
                                                                QuaSOR_Fits(ROI).AllFitTests(k,l)=struct(   'GaussianFitModel',[]);
                            %                                                                             'FitImage_Amp',[],...
                            %                                                                             'FitImage_Amp_Scaled',[],...
                            %                                                                             'DistanceMatrix',zeros(QuaSOR_Parameters.Components.MaxAllowed_NumGaussians+QuaSOR_Parameters.Components.MaxAllowed_NumResets*2),...
                            %                                                                             'Amp',[],...
                            %                                                                             'Amp_Scaled',[],...
                            %                                                                             'Amp_Scaled_Score',[],...
                            %                                                                             'Amp_Score',[],...
                            %                                                                             'Var_Score',[],...
                            %                                                                             'Cov_Score',[],...
                            %                                                                             'Var_Diff_Score',[],...
                            %                                                                             'CorrCoef',[],...
                            %                                                                             'Max_NormCorr2',[],...
                            %                                                                             'Max_NormCorr2_Score',[],...
                            %                                                                             'CorrCoef_Score',[],...
                            %                                                                             'Pentalty',[],...
                            %                                                                             'MaxVar',[],...
                            %                                                                             'MaxCov',[],...
                            %                                                                             'MaxVarDiff',[],...
                            %                                                                             'QuaSOR_Parameters.GMM.GMDistFitOptions',[],...
                            %                                                                             'AllScores',[],...
                            %                                                                             'ScoreTotal',[]);
                                                            end
                                                        end


                                                        QuaSOR_Fits(ROI).NumResets=NumResets;
                                                        %.Components.NumReplicates=QuaSOR_Parameters.Components.NumReplicates;
                                                        QuaSOR_Fits(ROI).PooledScoreTotals=zeros(QuaSOR_Parameters.Components.MaxAllowed_NumReplicates+QuaSOR_Parameters.Components.MaxAllowed_NumResets*QuaSOR_Parameters.Components.ReplicateIncrease*2,...
                                                            QuaSOR_Parameters.Components.MaxAllowed_NumGaussians+QuaSOR_Parameters.Components.MaxAllowed_NumResets*2);
                                                        Temp_MaxVar=QuaSOR_Parameters.Dist_Weights.Var_Score.Hist_XData(length(QuaSOR_Parameters.Dist_Weights.Var_Score.Hist_XData))+NumResets*10;
                                                        Temp_MaxCov=QuaSOR_Parameters.Dist_Weights.Cov_Score.Hist_XData(length(QuaSOR_Parameters.Dist_Weights.Cov_Score.Hist_XData))+NumResets*5;
                                                        Temp_MaxVarDiff=QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Hist_XData(length(QuaSOR_Parameters.Dist_Weights.Var_Diff_Score.Hist_XData))+NumResets*5;
                                                        Temp_MaxNumGaussians=QuaSOR_Parameters.Components.MaxNumGaussians;
                                                        GMDistFitOptions=QuaSOR_Parameters.GMM.GMDistFitOptions;
                                                        Temp_NumReplicates=QuaSOR_Parameters.Components.NumReplicates;
                                                        Temp_InternalReplicates=QuaSOR_Parameters.Temp_InternalReplicates+NumResets*2;
                                                        %Temp_InternalReplicates=QuaSOR_Parameters.Temp_InternalReplicates;
                                                        Searching=1;

                                                    end
                                                elseif jj<Temp_MaxNumGaussians
                                                    jj=jj+1;

                                                    %increase num replicates as the number of componentes increases to increase the likelihood of finding a good match
                                                    Temp_NumReplicates=Temp_NumReplicates+QuaSOR_Parameters.Components.ReplicateIncrease;
                                                    Searching=1;
                                                elseif any(QuaSOR_Fits(ROI).PooledScoreTotals(:)>0)
                                                    Searching=0;
                                                    Success=1;
                                                else
                                                    %adjust conditions to make a fit easier
                                                    Temp_MaxVar=Temp_MaxVar+10;
                                                    Temp_MaxCov=Temp_MaxCov+2;
                                                    Temp_MaxVarDiff=Temp_MaxVarDiff+10;
                                                    if GMDistFitOptions.MaxIter>5
                                                        GMDistFitOptions.MaxIter=GMDistFitOptions.MaxIter-1;
                                                    end
                                                    Temp_MaxNumGaussians=Temp_MaxNumGaussians+1;
                                                    jj=jj+1;
                                                    %increase num replicates as the number of componentes increases to increase the likelihood of finding a good match
                                                    Temp_NumReplicates=Temp_NumReplicates+QuaSOR_Parameters.Components.ReplicateIncrease;
                                                    Searching=1;
                                                end
                                            end
                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            if Success
                                                QuaSOR_Fits(ROI).MaxNumGaussians=Temp_MaxNumGaussians;
                                                QuaSOR_Fits(ROI).NumReplicates=Temp_NumReplicates;
                                                QuaSOR_Fits(ROI).InternalReplicates=Temp_InternalReplicates;
                                                QuaSOR_Fits(ROI).MaxVar=Temp_MaxVar;
                                                QuaSOR_Fits(ROI).MaxCov=Temp_MaxCov;
                                                QuaSOR_Fits(ROI).MaxVarDiff=Temp_MaxVarDiff;
                                                %Pick Winner
                                                QuaSOR_Fits(ROI).Successful_Fit=1;
                                                [~,QuaSOR_Fits(ROI).Best_NumGaussian]=max(max(QuaSOR_Fits(ROI).PooledScoreTotals,[],1));
                                                test=QuaSOR_Fits(ROI).PooledScoreTotals(:,QuaSOR_Fits(ROI).Best_NumGaussian);
                                                [~,QuaSOR_Fits(ROI).Best_Replicate]=max(test(:),[],1);

                                                %Assign winner data
                                                QuaSOR_Fits(ROI).Best_GaussianFitModel=QuaSOR_Fits(ROI).AllFitTests(QuaSOR_Fits(ROI).Best_Replicate,QuaSOR_Fits(ROI).Best_NumGaussian).GaussianFitModel;
                                                QuaSOR_Fits(ROI).Best_GaussianFitTest=QuaSOR_Fits(ROI).AllFitTests(QuaSOR_Fits(ROI).Best_Replicate,QuaSOR_Fits(ROI).Best_NumGaussian);
                                                QuaSOR_Fits(ROI).Best_GaussianFitImage=QuaSOR_Fits(ROI).AllFitTests(QuaSOR_Fits(ROI).Best_Replicate,QuaSOR_Fits(ROI).Best_NumGaussian).FitImage_Amp;
                                                QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.Amp=QuaSOR_Fits(ROI).AllFitTests(QuaSOR_Fits(ROI).Best_Replicate,QuaSOR_Fits(ROI).Best_NumGaussian).Amp;
                                                QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.Amp_Scaled=QuaSOR_Fits(ROI).AllFitTests(QuaSOR_Fits(ROI).Best_Replicate,QuaSOR_Fits(ROI).Best_NumGaussian).Amp_Scaled;
                                                QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.mu=QuaSOR_Fits(ROI).Best_GaussianFitModel.mu;
                                                QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.Sigma=QuaSOR_Fits(ROI).Best_GaussianFitModel.Sigma;
                                                QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.NumComponents=QuaSOR_Fits(ROI).Best_GaussianFitModel.NumComponents;
                                                QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.ComponentProportion=QuaSOR_Fits(ROI).Best_GaussianFitModel.ComponentProportion;                      
                                            else
                                                QuaSOR_Fits(ROI).Successful_Fit=0;
                                            end
                                            QuaSOR_Fits(ROI).TimePerROI=toc(ROITimer);
                                            if DisplayETA
                                                if QuaSOR_Fits(ROI).Successful_Fit
                                                    fprintf(['Fit ',num2str(QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.NumComponents),'Comp'])
                                                else
                                                    fprintf('FAILED')
                                                end
                                                ETA1=(QuaSOR_Fits(ROI).TimePerROI*(TotalNumROIs-z))/3600;
                                                fprintf([' ==> ',num2str(round(QuaSOR_Fits(ROI).TimePerROI)),'s  ETA = ',num2str(round(ETA1*10)/10),' hrs\n'])
                                            else
                                                if ~any(strcmp(OS,'MACI64'))&&ProgressBarOn
                                                    ppm.increment();
                                                end
                                            end
                                        catch
                                            warning on
                                            warning(['Error1 in ROI #',num2str(ROI)]);disp(['Error1 in ROI #',num2str(ROI)])
                                            warning(['Error1 in ROI #',num2str(ROI)]);disp(['Error1 in ROI #',num2str(ROI)])
                                            errorfile=fopen([CurrentScratchDir,ErrorLogDir,dc,'Error1 in ROI ',num2str(ROI),'.txt'],'w');
                                            fprintf(errorfile, ['Error1 in ROI ',num2str(ROI),'.txt']);fclose(errorfile);
                                            warning off
                                        end

                                    end 
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Separate QuaSOR_Fitting_Struct to individual events    
                            AbortStatus=get(AbortButtonHandle,'userdata');
                            if ~AbortStatus
                                %ReconstructedFitImage=ZerosImage;
                                QuaSOR_Upscale_Max_Sum=ZerosImage_Upscale;
                                All_QuaSOR_Fit_RecordingPosition=[];
                                All_QuaSOR_Fit_OverallTiming=[];
                                All_QuaSOR_Fit_MaxCoords=[];
                                All_QuaSOR_Fit_Amp=[];
                                All_QuaSOR_Fit_Amp_Scaled=[];
                                All_QuaSOR_Fit_Sigma=[];
                                All_QuaSOR_Fit_Episode=[];
                                All_Location_Coords=[];
                                All_Location_Coords_byFrame=[];
                                All_Location_Amps=[];
                                FinalEventCount=0; 
                                if ProgressBarOn
                                    progressbar(['GMM Fit ROI Post Processing...'])
                                end
                                for ROI=1:TotalNumROIs
                                    if ProgressBarOn
                                        progressbar(ROI/TotalNumROIs)
                                    end
                                    Max_Image=ZerosImage_Upscale;      
                                    if QuaSOR_Fits(ROI).Successful_Fit
                                        for k=1:QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.NumComponents

                                            TempCoord=QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.mu(k,:);
                                            XFix=QuaSOR_Fits(ROI).RegionProps.BoundingBox(1)+QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust;
                                            YFix=QuaSOR_Fits(ROI).RegionProps.BoundingBox(2)+QuaSOR_Parameters.UpScaling.ReMap_CoordinateAdjust;
                                            TempCoordFix=[TempCoord(1)+YFix,TempCoord(2)+XFix];
                                            QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.mu_Fix(k,:)=TempCoordFix;
                                            FinalEventCount=FinalEventCount+1;
                                            All_QuaSOR_Fit_RecordingPosition(FinalEventCount,:)=[QuaSOR_Fits(ROI).EpisodeNumber,QuaSOR_Fits(ROI).ImageNumber];
                                            All_QuaSOR_Fit_EpisodeTiming(FinalEventCount)=QuaSOR_Fits(ROI).ImageNumber;
                                            All_QuaSOR_Fit_OverallTiming(FinalEventCount)=(QuaSOR_Fits(ROI).EpisodeNumber-1)*ImagingInfo.FramesPerEpisode+QuaSOR_Fits(ROI).ImageNumber;
                                            All_QuaSOR_Fit_MaxCoords(FinalEventCount,:)=QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.mu_Fix(k,:);

                                            %Adjust the coordinates so they will match old locations
                                            All_QuaSOR_Fit_MaxCoords(FinalEventCount,1)=All_QuaSOR_Fit_MaxCoords(FinalEventCount,1)+QuaSOR_Parameters.UpScaling.YOffset;
                                            All_QuaSOR_Fit_MaxCoords(FinalEventCount,2)=All_QuaSOR_Fit_MaxCoords(FinalEventCount,2)+QuaSOR_Parameters.UpScaling.XOffset;

                                            All_QuaSOR_Fit_Amp(FinalEventCount)=QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.Amp(k);
                                            All_QuaSOR_Fit_Amp_Scaled(FinalEventCount)=QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.Amp_Scaled(k);
                                            All_QuaSOR_Fit_Sigma(:,:,FinalEventCount)=QuaSOR_Fits(ROI).BestGaussianFitModel_Clean.Sigma(:,:,k);
                                            All_QuaSOR_Fit_Episode(FinalEventCount,:)=[z,k];%use this to pull from the Fit data later 

                                            All_Location_Coords(FinalEventCount,:)=[All_QuaSOR_Fit_MaxCoords(FinalEventCount,1),All_QuaSOR_Fit_MaxCoords(FinalEventCount,2),All_QuaSOR_Fit_EpisodeTiming(FinalEventCount)];
                                            All_Location_Coords_byFrame(FinalEventCount,:)=[All_QuaSOR_Fit_MaxCoords(FinalEventCount,1),All_QuaSOR_Fit_MaxCoords(FinalEventCount,2),All_QuaSOR_Fit_OverallTiming(FinalEventCount)];
                                            All_Location_Amps(FinalEventCount)=All_QuaSOR_Fit_Amp(FinalEventCount);

                                            %Max location reconstruction
                                            TempCoord=All_QuaSOR_Fit_MaxCoords(FinalEventCount,:);
                                            TempImage=ZerosImage_Upscale;
                                            TempCoord=round(TempCoord*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor)+QuaSOR_Parameters.UpScaling.UpScale_CoordinateAdjust*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor;
                                            if TempCoord(1)>0&&TempCoord(1)<=size(TempImage,1)&&TempCoord(2)>0&&TempCoord(2)<=size(TempImage,2)
                                                TempImage(TempCoord(1),TempCoord(2))=1;
                                                Max_Image=Max_Image+TempImage; 
                                            end
                                            clear TempImage TempCoord

                                        end
                                        QuaSOR_Upscale_Max_Sum=QuaSOR_Upscale_Max_Sum+Max_Image;
                                    else

                                    end
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Check for Duplications!
                            AbortStatus=get(AbortButtonHandle,'userdata');
                            if ~AbortStatus
                                QuaSOR_Fitting_Struct(EpisodeNumber).FoundDuplicate=0;
                                [   QuaSOR_Fitting_Struct(EpisodeNumber).DuplicateCoords,...
                                    QuaSOR_Fitting_Struct(EpisodeNumber).DuplicateIndices,...
                                    QuaSOR_Fitting_Struct(EpisodeNumber).DuplicateCount]=...
                                    DuplicateFinder(All_Location_Coords_byFrame);
                                if QuaSOR_Fitting_Struct(EpisodeNumber).DuplicateCount>0
                                    QuaSOR_Fitting_Struct(EpisodeNumber).FoundDuplicate=1;
                                    fprintf('\n');
                                    warning on
                                    warning(['Episode ',num2str(EpisodeNumber_Load),' I Found ',num2str(QuaSOR_Fitting_Struct(EpisodeNumber).DuplicateCount),' Duplicate Event(s)! Fixing...'])
                                    for dup=QuaSOR_Fitting_Struct(EpisodeNumber).DuplicateCount:-1:1
                                        TempIndex=max(QuaSOR_Fitting_Struct(EpisodeNumber).DuplicateIndices(dup,:));
                                        warning(['Removing Event #',num2str(TempIndex)]);
                                        All_QuaSOR_Fit_RecordingPosition(TempIndex,:)=[];
                                        All_QuaSOR_Fit_EpisodeTiming(TempIndex)=[];
                                        All_QuaSOR_Fit_OverallTiming(TempIndex)=[];
                                        All_QuaSOR_Fit_MaxCoords(TempIndex,:)=[];
                                        All_QuaSOR_Fit_MaxCoords(TempIndex,:)=[];
                                        All_QuaSOR_Fit_Amp(TempIndex)=[];
                                        All_QuaSOR_Fit_Amp_Scaled(TempIndex)=[];
                                        All_QuaSOR_Fit_Sigma(:,:,TempIndex)=[];
                                        All_QuaSOR_Fit_Episode(TempIndex,:)=[];
                                        All_Location_Coords(TempIndex,:)=[];
                                        All_Location_Coords_byFrame(TempIndex,:)=[];
                                        All_Location_Amps(TempIndex)=[];
                                    end
                                end
                                [   DuplicateCoords,...
                                    DuplicateIndices,...
                                    DuplicateCount]=...
                                    DuplicateFinder(All_Location_Coords_byFrame);
                                if DuplicateCount>0
                                    error(['Episode ',num2str(EpisodeNumber_Load),'Still has a Duplicate Event(s)'])
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Populate QuaSOR_Fitting_Struct and
                            AbortStatus=get(AbortButtonHandle,'userdata');
                            if ~AbortStatus
                                FinalEventCount=size(All_QuaSOR_Fit_MaxCoords,1);
                                All_QuaSOR_Fit_FinalNumComponents=size(All_QuaSOR_Fit_MaxCoords,1);
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                QuaSOR_Fitting_Struct(EpisodeNumber).EpisodeRepeat=EpisodeRepeat;
                                QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits=QuaSOR_Fits; 
                                QuaSOR_Fitting_Struct(EpisodeNumber).All_QuaSOR_Fit_RecordingPosition=All_QuaSOR_Fit_RecordingPosition; 
                                QuaSOR_Fitting_Struct(EpisodeNumber).All_QuaSOR_Fit_EpisodeTiming=All_QuaSOR_Fit_EpisodeTiming; 
                                QuaSOR_Fitting_Struct(EpisodeNumber).All_QuaSOR_Fit_OverallTiming=All_QuaSOR_Fit_OverallTiming;
                                QuaSOR_Fitting_Struct(EpisodeNumber).All_QuaSOR_Fit_MaxCoords=All_QuaSOR_Fit_MaxCoords; 
                                QuaSOR_Fitting_Struct(EpisodeNumber).All_QuaSOR_Fit_Amp=All_QuaSOR_Fit_Amp;
                                QuaSOR_Fitting_Struct(EpisodeNumber).All_QuaSOR_Fit_Amp_Scaled=All_QuaSOR_Fit_Amp_Scaled;
                                QuaSOR_Fitting_Struct(EpisodeNumber).All_QuaSOR_Fit_Sigma=All_QuaSOR_Fit_Sigma;
                                QuaSOR_Fitting_Struct(EpisodeNumber).All_QuaSOR_Fit_Episode=All_QuaSOR_Fit_Episode;
                                QuaSOR_Fitting_Struct(EpisodeNumber).All_QuaSOR_Fit_FinalNumComponents=All_QuaSOR_Fit_FinalNumComponents;
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                                QuaSOR_Data.Episode(EpisodeNumber_Load).FinalEventCount=FinalEventCount;
                                QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Amps=All_Location_Amps;
                                QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords=All_Location_Coords;
                                QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byFrame=All_Location_Coords_byFrame;
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                                clear DuplicateCoords DuplicateIndices DuplicateCount
                                clear All_Location_Amps All_Location_Coords All_Location_Coords_byFrame QuaSOR_Fits
                                clear All_QuaSOR_Fit_RecordingPosition All_QuaSOR_Fit_EpisodeTiming All_QuaSOR_Fit_OverallTiming All_QuaSOR_Fit_MaxCoords All_QuaSOR_Fit_Amp
                                clear All_QuaSOR_Fit_Amp_Scaled All_QuaSOR_Fit_Sigma All_QuaSOR_Fit_Episode All_QuaSOR_Fit_FinalNumComponents 
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Fit Stats
                            AbortStatus=get(AbortButtonHandle,'userdata');
                            if ~AbortStatus
                                if ProgressBarOn
                                    progressbar(['Checking for Failed Fits #'])
                                end
                                QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Failed_Fits=0;
                                QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Successful_Fits=0;
                                QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.SuccessfulFits_MaxAmps=[];
                                QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.SuccessfulFits_MeanAmps=[];
                                QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.SuccessfulFits_Areas=[];
                                QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.FailedFits_MaxAmps=[];
                                QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.FailedFits_MeanAmps=[];
                                QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.FailedFits_Areas=[];
                                for ROI_Count=1:length(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits)
                                    if ProgressBarOn
                                        progressbar(ROI_Count/length(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits))
                                    end
                                    TempImage=QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).TestImage;
                                    TempImage(TempImage==0)=NaN;
                                    if QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).Successful_Fit
                                        QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Successful_Fits=QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Successful_Fits+1;
                                        QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.SuccessfulFits_MaxAmps(QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Successful_Fits,:)=[ROI_Count,max(TempImage(:))];
                                        QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.SuccessfulFits_MeanAmps(QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Successful_Fits,:)=[ROI_Count,nanmean(TempImage(:))];
                                        QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.SuccessfulFits_Areas(QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Successful_Fits,:)=[ROI_Count,sum(~isnan(TempImage(:)))];
                                    else
                                        QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Failed_Fits=QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Failed_Fits+1;
                                        QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.FailedFits_MaxAmps(QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Failed_Fits,:)=[ROI_Count,max(TempImage(:))];
                                        QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.FailedFits_MeanAmps(QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Failed_Fits,:)=[ROI_Count,nanmean(TempImage(:))];
                                        QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.FailedFits_Areas(QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Failed_Fits,:)=[ROI_Count,sum(~isnan(TempImage(:)))];
                                    end
                                end
                                if QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Successful_Fits>0
                                    QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.PercentSuccessfulFits=QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Successful_Fits/ROI_Count;
                                else
                                    QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.PercentSuccessfulFits=NaN;
                                end
                                QuaSOR_Data.Episode(EpisodeNumber_Load).FitStats=QuaSOR_Fitting_Struct(EpisodeNumber).FitStats;
                                if TextUpdateMode
                                    fprintf([num2str(QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Successful_Fits),' Fit ',num2str(QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Failed_Fits),' Fail\n'])
                                    warning(['EpisodeNumber ',num2str(EpisodeNumber_Load)]);
                                    warning(['Num_Successful_Fits = ',num2str(QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Successful_Fits)])
                                    warning(['Num_Failed_Fits = ',num2str(QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Failed_Fits)])
                                    warning(['ROI_Count = ',num2str(ROI_Count)])
                                    warning(['PercentSuccessfulFits = ',num2str(QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.PercentSuccessfulFits)])
                                else
                                    if ROI_Count>0
                                        if ~QuaSOR_Fitting_Struct(EpisodeNumber).FoundDuplicate
                                            for x=1:27
                                                fprintf('\b');
                                            end
                                        end
                                    end
                                    fprintf([num2str(QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Successful_Fits),' Fit ',num2str(QuaSOR_Fitting_Struct(EpisodeNumber).FitStats.Num_Failed_Fits),' Fail ==> '])
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Reduce structure sizes if needed
                            AbortStatus=get(AbortButtonHandle,'userdata');
                            if ~AbortStatus
                                if ROI_Count>QuaSOR_Parameters.General.EventThreshold
                                    if TextUpdateMode
                                        warning('ROI_Count>QuaSOR_Parameters.General.EventThreshold...will engage QuaSOR_Parameters.General.MemorySaver')
                                    end
                                   QuaSOR_Parameters.General.MemorySaver=1;
                                end
                                if QuaSOR_Parameters.General.MemorySaver
                                    TempInfo1=whos('QuaSOR_Fitting_Struct');
                                    if TextUpdateMode
                                        warning on
                                        warning('Converting some of the QuaSOR_Fits fields from Double to Single to save space...')
                                        warning(['Num ROIs = ',num2str(length(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits))])
                                        warning(['Pre-Compression QuaSOR_Data = ',num2str(TempInfo1.bytes/1e9),'GB'])
                                    end
                                    if ProgressBarOn
                                        progressbar(['Compressing'])
                                    end
                                    for ROI_Count=1:length(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits)
                                        if ProgressBarOn
                                            progressbar(ROI_Count/length(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits))
                                        end
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).EpisodeNumber           =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).EpisodeNumber);
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).ImageNumber             =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).ImageNumber);
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).XCoord                  =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).XCoord);
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).YCoord                  =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).YCoord);
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).YCoords                 =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).YCoords);
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).XCoords                 =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).XCoords);                    
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).TestImage               =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).TestImage);
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).TestImage_Z_Scaled      =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).TestImage_Z_Scaled);
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).TestImage_Filt          =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).TestImage_Filt);
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).TestImage_Filt_Z_Scaled =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).TestImage_Filt_Z_Scaled);
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).ScalePoints             =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).ScalePoints);
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).ScalePoints_Filt        =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).ScalePoints_Filt);
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).NumResets               =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).NumResets);
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).NumReplicates           =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).NumReplicates);
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).PooledScoreTotals       =single(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).PooledScoreTotals);
                                    end
                                    TempInfo2=whos('QuaSOR_Fitting_Struct');
                                    if TextUpdateMode
                                        warning(['Post-Compression QuaSOR_Fits = ',num2str(TempInfo2.bytes/1e9),'GB'])
                                        warning(['Compression Ratio = ',num2str(TempInfo2.bytes/TempInfo1.bytes)])
                                    end
                                end
                                if ~QuaSOR_Parameters.General.StoreAllFitTests
                                    TempInfo1=whos('QuaSOR_Fitting_Struct');
                                    if TextUpdateMode
                                        warning on
                                        warning('Clearing AllFitTests to save space...')
                                        warning(['Num ROIs = ',num2str(length(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits))])
                                        warning(['Pre-Compression QuaSOR_Data = ',num2str(TempInfo1.bytes/1e9),'GB'])
                                    end
                                    if ProgressBarOn
                                        progressbar(['Clearing AllFitTests'])
                                    end
                                    for ROI_Count=1:length(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits)
                                        if ProgressBarOn
                                            progressbar(ROI_Count/length(QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits))
                                        end
                                        QuaSOR_Fitting_Struct(EpisodeNumber).QuaSOR_Fits(ROI_Count).AllFitTests=[];
                                    end
                                    TempInfo2=whos('QuaSOR_Fitting_Struct');
                                    if TextUpdateMode
                                        warning(['Post-Compression QuaSOR_Fits = ',num2str(TempInfo2.bytes/1e9),'GB'])
                                        warning(['Compression Ratio = ',num2str(TempInfo2.bytes/TempInfo1.bytes)])
                                    end
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Save if SplitEpisodeFiles
                            AbortStatus=get(AbortButtonHandle,'userdata');
                            if ~AbortStatus
                                if SplitEpisodeFiles
                                    warning on
                                    FileSuffix=['_QuaSOR_Data_Ep_',num2str(EpisodeNumber_Load),'.mat'];
                                    fprintf(['Saving... ',StackSaveName,FileSuffix,' to CurrentScratchDir...']);
                                    save([CurrentScratchDir,dc,StackSaveName,FileSuffix],'QuaSOR_Fitting_Struct','QuaSOR_Parameters')
                                    fprintf('Finished!\n')
                                    fprintf(['Copying: ',StackSaveName,FileSuffix,' to SaveDir...'])
                                    [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
                                    fprintf('Finished!\n')
                                    if ~CopyStatus
                                        error('Problem Copying Split Episode Data!')
                                    else
                                    end
                                    
                                    warning('Clearing QuaSOR_Fitting_Struct')
                                    QuaSOR_Fitting_Struct=[];
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Clear Parallel Debug Directory
                            AbortStatus=get(AbortButtonHandle,'userdata');
                            if ~AbortStatus
                                if ParallelDebug
                                    if exist([CurrentScratchDir,LogDir])
                                        rmdir([CurrentScratchDir,LogDir],'s')
                                    end
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Update User
                            AbortStatus=get(AbortButtonHandle,'userdata');
                            if ~AbortStatus
                                SuccessfulEpisode=1;
                                QuaSOR_Data.Episode(EpisodeNumber_Load).TimePerEpisode=toc(EpisodeTimer);
                                EpisodeTimes(EpisodeNumber_Load)=QuaSOR_Data.Episode(EpisodeNumber_Load).TimePerEpisode;
                                ETA=(mean(EpisodeTimes)*(ImagingInfo.NumEpisodes-EpisodeNumber_Load))/3600;
                                if TextUpdateMode
                                    fprintf(['Episode ',num2str(EpisodeNumber_Load),' Complete! ',num2str(round(QuaSOR_Data.Episode(EpisodeNumber_Load).TimePerEpisode)),'s ETA = ',num2str(round(ETA*10)/10),' hrs\n'])
                                else
                                    fprintf(['Complete! ',num2str(round(QuaSOR_Data.Episode(EpisodeNumber_Load).TimePerEpisode)),'s ETA = ',num2str(round(ETA*10)/10),' hrs\n'])
                                end
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        catch
                            fprintf('\n')
                            warning on
                            warning(['Error in Episode #',num2str(EpisodeNumber_Load),' Repeat #',num2str(EpisodeRepeat),' Trying again!'])
                            warning(['Error in Episode #',num2str(EpisodeNumber_Load),' Repeat #',num2str(EpisodeRepeat),' Trying again!'])
                            EpisodeRepeat=EpisodeRepeat+1;
                            if EpisodeRepeat<=MaxNumEpisodeRepeats
                                fprintf(['REPEATING Episode ',num2str(EpisodeNumber_Load),'/',num2str(ImagingInfo.NumEpisodes),': ','Splitting Regions...'])
                            end
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if ~SuccessfulEpisode&&~AbortStatus
                        fprintf('\n')
                        warning on
                        warning(['Error in Episode #',num2str(EpisodeNumber_Load),' Repeat #',num2str(EpisodeRepeat),' Trying again!'])
                        warning(['Error in Episode #',num2str(EpisodeNumber_Load),' Repeat #',num2str(EpisodeRepeat),' Trying again!'])
                        warning(['Error in Episode #',num2str(EpisodeNumber_Load),' Repeat #',num2str(EpisodeRepeat),' Trying again!'])
                        warning(['Error in Episode #',num2str(EpisodeNumber_Load),' Repeat #',num2str(EpisodeRepeat),' Trying again!'])
                        error(['Error in Episode #',num2str(EpisodeNumber_Load),' Repeat #',num2str(EpisodeRepeat),' Trying again!'])
                    end
                    AbortStatus=get(AbortButtonHandle,'userdata');
                    if AbortStatus
                        fprintf('\n')
                        warning on
                        warning(['ABORT ACTIVATED in Episode #',num2str(EpisodeNumber_Load)])
                        warning(['ABORT ACTIVATED in Episode #',num2str(EpisodeNumber_Load)])
                        warning(['ABORT ACTIVATED in Episode #',num2str(EpisodeNumber_Load)])
                        warning(['ABORT ACTIVATED in Episode #',num2str(EpisodeNumber_Load)])
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
            end 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    disp('========================================================================')
    disp('========================================================================')
    disp('========================================================================')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Merging All Episode QuaSOR Coordinates
    AbortStatus=get(AbortButtonHandle,'userdata');
    if ~AbortStatus
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
        run('Multi_Modality_QuaSOR_Event_Sorting.m')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
    else
        warning('ABORT ACTIVATED! Skipping: Merging All Episode QuaSOR Coordinates')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Saving Data
    try
        AbortStatus=get(AbortButtonHandle,'userdata');
    catch
        AbortStatus=0;
    end
    if ~AbortStatus
        if SplitEpisodeFiles
            warning('Clearing QuaSOR_Fitting_Struct')
            QuaSOR_Fitting_Struct=[];
        end
        FileSuffix=['_QuaSOR_Data.mat'];
        fprintf(['Saving...',StackSaveName,FileSuffix,' to CurrentScratchDir...']);
        save([CurrentScratchDir,dc,StackSaveName,FileSuffix],...
            'QuaSOR_Fitting_Struct','QuaSOR_Data','QuaSOR_Parameters','QuaSOR_Event_Extraction_Settings',...
            'AllBoutonsRegion_Upscale','ScaleBar_Upscale','BorderLine_Upscale')
        fprintf('Finished!\n')
        fprintf(['Copying: ',StackSaveName,FileSuffix,' to SaveDir...'])
        [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
        fprintf('Finished!\n')
        if ~CopyStatus
            error('Problem Copying Data!')
        else
        end
        disp('========================================================================')
        disp('========================================================================')
        disp('========================================================================')
        OverallTime=toc(OverallTimer);
        fprintf(['Finished GMM Fits for: ',StackSaveName,'Overall Time: ',num2str(OverallTime/3600),' hrs\n']);
        disp('========================================================================')
        disp('========================================================================')
        disp('========================================================================')
    else
        warning('ABORT ACTIVATED! Skipping: Saving Data')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Abort Button Triggers
    try
        AbortStatus=get(AbortButtonHandle,'userdata');
    catch
        AbortStatus=0;
    end
    if AbortStatus
        warning('ABORT ACTIVATED!')
        AbortStatus=1;
        warning([StackSaveName,' Was Aborted! Killing Script Now'])
        warning([StackSaveName,' Was Aborted! Killing Script Now'])
        warning([StackSaveName,' Was Aborted! Killing Script Now'])
        warning([StackSaveName,' Was Aborted! Killing Script Now'])
        if exist([TrackerDir,StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
            fprintf('Deleting Currently Running Tracking File...')
            delete([TrackerDir,StackSaveName,' ',AnalysisLabel,' Currently Running.mat'])
            fprintf('Finished!\n')
        end
        error([StackSaveName,' Was Aborted! Killing Script Now'])
    end
    close all
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end





