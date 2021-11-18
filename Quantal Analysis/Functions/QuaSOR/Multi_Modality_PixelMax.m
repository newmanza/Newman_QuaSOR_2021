function [PixelMax_Output] = Multi_Modality_PixelMax(...
    myPool,OS,CorrAmp_Output,ImagingInfo,EventDetectionSettings,MarkerSetInfo,DisplayOn,EpisodeNumber,MappingLabel)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    warning on all
    warning off backtrace
    warning off verbose
    if strcmp(OS,'MACI64')
        ProgressBarOn=0;
    else
        if ImagingInfo.FramesPerEpisode<100
            ProgressBarOn=0;
        else
            ProgressBarOn=1;
        end
    end
    if ~DisplayOn
        ProgressBarOn=0;
    end
    progressStepSize = 100;
    if DisplayOn
        disp('=============================================')
        disp('=============================================')
        fprintf(['Starting: ',MappingLabel,'...\n'])
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isfield(ImagingInfo,'StimInfo')
        warning('ImagingInfo is missing StimInfo')
        if ImagingInfo.ModalityType==1||ImagingInfo.ModalityType==3
            if ImagingInfo.StimuliPerEpisode>0
                ImagingInfo.StimInfo=[];
                for s=1:ImagingInfo.StimuliPerEpisode
                    ImagingInfo.StimInfo(s).IntraEpisode_StimNum=s;
                    ImagingInfo.StimInfo(s).IntraEpisode_StimulusSortingFrames=...
                        [ImagingInfo.IntraEpisode_StimuliFrames(s):...
                        ImagingInfo.IntraEpisode_StimuliFrames(s)+ImagingInfo.FramesPerStimulus-1];
                end
            else
                ImagingInfo.StimInfo=[];
            end

        else
            ImagingInfo.StimInfo=[];
        end
    end
    if DisplayOn
        progressbar('Sorting events with PixelMax settings...')
    end
    TempArray_Filtered=imfilter(CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean,...
        fspecial('gaussian', EventDetectionSettings.Max_Pixel_FilterSize_px, EventDetectionSettings.Max_Pixel_FilterSigma_px));
    ImageArray_BW = ThreshArray(TempArray_Filtered, EventDetectionSettings.Max_Pixel_CorrAmp_Amp_Threshold);
    PixelMax_Output.ImageArray_Max = ExtendedMaxArray(TempArray_Filtered, EventDetectionSettings.Max_Pixel_CorrAmp_Size_Threshold);
    PixelMax_Output.ImageArray_Max = PixelMax_Output.ImageArray_Max .* ImageArray_BW;
    EventDetectionSettings.Max_Region=strel('disk',EventDetectionSettings.Max_Pixel_EdgeSize);
    PixelMax_Output.ImageArray_Max = imclose(PixelMax_Output.ImageArray_Max, EventDetectionSettings.Max_Region);
    PixelMax_Output.ImageArray_Max_Sharp=zeros(size(PixelMax_Output.ImageArray_Max));
    PixelMax_Output.NumFrames=size(PixelMax_Output.ImageArray_Max_Sharp,3);
    PixelMax_Output.All_Location_Coords_byEpisodeNum=[];
    PixelMax_Output.All_Location_Coords_byFrame=[];
    PixelMax_Output.All_Location_Coords_byStim=[];
    Mod=1;
    PixelMax_Output.Modality(Mod).Label='Evoked';
    Mod=2;
    PixelMax_Output.Modality(Mod).Label='Spontaneous';
    for Mod=1:length(PixelMax_Output.Modality)
        PixelMax_Output.Modality(Mod).All_Location_Coords_byEpisodeNum=[];
        PixelMax_Output.Modality(Mod).All_Location_Coords_byFrame=[];
        PixelMax_Output.Modality(Mod).All_Location_Coords_byStim=[];
    end
    for ImageNumber=1:ImagingInfo.FramesPerEpisode
        Stim=0;
        if ~isempty(ImagingInfo.StimInfo)
            for s=1:ImagingInfo.StimuliPerEpisode
                if any(ImageNumber==ImagingInfo.StimInfo(s).IntraEpisode_StimulusSortingFrames)
                    Stim=s;
                end
            end
        end
        Mod=0;
        if any(ImageNumber==ImagingInfo.IntraEpisode_Evoked_ActiveFrames)
            Mod=1;
        elseif any(ImageNumber==ImagingInfo.IntraEpisode_Spont_ActiveFrames)
            Mod=2;
        end
        TempImage = PixelMax_Output.ImageArray_Max(:,:,ImageNumber);
        TempImage = imfill(TempImage, 'holes'); % fill holes, for next steps to work
        TempImage = bwmorph(TempImage, 'shrink', Inf); % Shrink each maxima to one pixel, to make a clear decision whether it is in the chosen region
        PixelMax_Output.ImageArray_Max_Sharp(:,:,ImageNumber)=TempImage;
        [TempY,TempX]=find(PixelMax_Output.ImageArray_Max_Sharp(:,:,ImageNumber));
        if ~isempty(TempY)
            TempT=ones(size(TempY))*ImageNumber;
            TempS=ones(size(TempY))*Stim;
            TempE=ones(size(TempY))*EpisodeNumber;
            Temp_Location_Coords=horzcat(TempY,TempX);
            Temp_Location_Coords_Frame=horzcat(Temp_Location_Coords,TempT);
            Temp_Location_Coords_Stim=horzcat(Temp_Location_Coords,TempS);
            Temp_Location_Coords_EpisodeNum=horzcat(Temp_Location_Coords,TempE);
            PixelMax_Output.All_Location_Coords_byFrame=...
                vertcat(PixelMax_Output.All_Location_Coords_byFrame,Temp_Location_Coords_Frame);
            PixelMax_Output.All_Location_Coords_byStim=...
                vertcat(PixelMax_Output.All_Location_Coords_byStim,Temp_Location_Coords_Stim);
            PixelMax_Output.All_Location_Coords_byEpisodeNum=...
                vertcat(PixelMax_Output.All_Location_Coords_byEpisodeNum,Temp_Location_Coords_EpisodeNum);
            if Mod~=0
                PixelMax_Output.Modality(Mod).All_Location_Coords_byFrame=...
                    vertcat(PixelMax_Output.Modality(Mod).All_Location_Coords_byFrame,Temp_Location_Coords_Frame);
                PixelMax_Output.Modality(Mod).All_Location_Coords_byStim=...
                    vertcat(PixelMax_Output.Modality(Mod).All_Location_Coords_byStim,Temp_Location_Coords_Stim);
                PixelMax_Output.Modality(Mod).All_Location_Coords_byEpisodeNum=...
                    vertcat(PixelMax_Output.Modality(Mod).All_Location_Coords_byEpisodeNum,Temp_Location_Coords_EpisodeNum);
            end
        end
        clear Temp_Location_Coords Temp_Location_Coords_Frame Temp_Location_Coords_Stim Temp_Location_Coords_EpisodeNum TempX TempY TempT
        if DisplayOn
            progressbar(ImageNumber/ImagingInfo.FramesPerEpisode)
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ImagingInfo.ModalityType==1
        PixelMax_Output.Image_Max_Sharp=logical(sum(double(PixelMax_Output.ImageArray_Max_Sharp(:,:, EventDetectionSettings.Template.PeakFrames)), 3));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if DisplayOn
        fprintf(['Finished: ',MappingLabel,'!\n'])
        disp('=============================================')
        disp('=============================================')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end