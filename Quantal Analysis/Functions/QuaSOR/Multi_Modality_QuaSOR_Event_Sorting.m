
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Merging All Episode QuaSOR Coordinates...')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
    QuaSOR_Data.Episode(EpisodeNumber_Load).Modality=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    QuaSOR_Data.Episode(EpisodeNumber_Load).OverallStimAdjust=(EpisodeNumber_Load-1)*ImagingInfo.StimuliPerEpisode;
    QuaSOR_Data.Episode(EpisodeNumber_Load).OverallFrameAdjust=(EpisodeNumber_Load-1)*ImagingInfo.FramesPerEpisode;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byEpisodeNum=[];
    QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byOverallFrame=[];
    QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byEpisodeStim=[];
    QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byOverallStim=[];
    for Mod=1:length(QuaSOR_Data.Modality)
        QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).Label=QuaSOR_Data.Modality(Mod).Label;
        QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byEpisodeFrame=[];
        QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byEpisodeNum=[];
        QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byOverallFrame=[];
        QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byEpisodeStim=[];
        QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byOverallStim=[];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byEpisodeFrame=...
        QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TempCoords=QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byEpisodeFrame;
    if ~isempty(TempCoords)
        TempCoords(:,3)=TempCoords(:,3)+QuaSOR_Data.Episode(EpisodeNumber_Load).OverallFrameAdjust;
    end
    QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byOverallFrame=TempCoords;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords)
        EpNums=EpisodeNumber_Load*ones(size(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords,1),1);
        QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byEpisodeNum=...
            horzcat(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(:,1:2),EpNums);
        for i=1:size(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords,1)
            Stim=0;
            if any(~isnan(ImagingInfo.StimuliPerEpisode))
                for s=1:ImagingInfo.StimuliPerEpisode
                    if any(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,3)==ImagingInfo.StimInfo(s).IntraEpisode_StimulusSortingFrames)
                        Stim=s;
                    end
                end
            end
            QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byEpisodeStim(i,:)=horzcat(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,1:2),Stim);
            Mod=0;
            if any(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,3)==ImagingInfo.IntraEpisode_Evoked_ActiveFrames)
                Mod=1;
            elseif any(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,3)==ImagingInfo.IntraEpisode_Spont_ActiveFrames)
                Mod=2;
            end
            if Mod~=0
                QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byEpisodeNum=...
                    vertcat(QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byEpisodeNum,...
                    [QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,1:2),EpisodeNumber_Load]);
                QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byEpisodeFrame=...
                    vertcat(QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byEpisodeFrame,...
                    [QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byEpisodeFrame(i,:)]);
                QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byOverallFrame=...
                    vertcat(QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byOverallFrame,...
                    [QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byOverallFrame(i,:)]);
                QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byEpisodeStim=...
                    vertcat(QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byEpisodeStim,...
                    [QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,1:2),Stim]);
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TempCoords=QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byEpisodeStim;
    if ~isempty(TempCoords)
        for i=1:size(TempCoords,1)
            if TempCoords(i,3)~=0
                TempCoords(i,3)=TempCoords(i,3)+QuaSOR_Data.Episode(EpisodeNumber_Load).OverallStimAdjust;
            end
        end
    end
    QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byOverallStim=TempCoords;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for Mod=1:length(QuaSOR_Data.Modality)
        TempCoords=QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byEpisodeFrame;
        if ~isempty(TempCoords)
            TempCoords(:,3)=TempCoords(:,3)+QuaSOR_Data.Episode(EpisodeNumber_Load).OverallFrameAdjust;
        end
        QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byOverallFrame=TempCoords;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for Mod=1:length(QuaSOR_Data.Modality)
        TempCoords=QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byEpisodeStim;
        if ~isempty(TempCoords)
            for i=1:size(TempCoords,1)
                if TempCoords(i,3)~=0
                    TempCoords(i,3)=TempCoords(i,3)+QuaSOR_Data.Episode(EpisodeNumber_Load).OverallStimAdjust;
                end
            end
        end
        QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byOverallStim=TempCoords;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
QuaSOR_Data.All_Location_Coords_byEpisodeNum=[];
QuaSOR_Data.All_Location_Coords_byEpisodeFrame=[];
QuaSOR_Data.All_Location_Coords_byOverallFrame=[];
QuaSOR_Data.All_Location_Coords_byOverallStim=[];
for Mod=1:length(QuaSOR_Data.Modality)
    QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum=[];
    QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeFrame=[];
    QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame=[];
    QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim=[];
end
for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
    QuaSOR_Data.All_Location_Coords_byEpisodeNum=...
        vertcat(QuaSOR_Data.All_Location_Coords_byEpisodeNum,...
        QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byEpisodeNum);
    QuaSOR_Data.All_Location_Coords_byEpisodeFrame=...
        vertcat(QuaSOR_Data.All_Location_Coords_byEpisodeFrame,...
        QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byEpisodeFrame);
    QuaSOR_Data.All_Location_Coords_byOverallFrame=...
        vertcat(QuaSOR_Data.All_Location_Coords_byOverallFrame,...
        QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byOverallFrame);
    QuaSOR_Data.All_Location_Coords_byOverallStim=...
        vertcat(QuaSOR_Data.All_Location_Coords_byOverallStim,...
        QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byOverallStim);
    for Mod=1:length(QuaSOR_Data.Modality)
        QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum=...
            vertcat(QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum,...
            QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byEpisodeNum);
        QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeFrame=...
            vertcat(QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeFrame,...
            QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byEpisodeFrame);
        QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame=...
            vertcat(QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame,...
            QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byOverallFrame);
        QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim=...
            vertcat(QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim,...
            QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords_byOverallStim);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Collecting CorrAmps...')
for EpisodeNumber_Load=1:length(QuaSOR_Data.Episode)
    for Mod=1:length(QuaSOR_Parameters.Modality)
        QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Amps=[];
    end
    if ~isempty(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords)
        for i=1:size(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords,1)
            Mod=0;
            if any(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,3)==ImagingInfo.IntraEpisode_Evoked_ActiveFrames)
                Mod=1;
            elseif any(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,3)==ImagingInfo.IntraEpisode_Spont_ActiveFrames)
                Mod=2;
            end
            if Mod~=0
                QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Amps=...
                    horzcat(QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Amps,...
                    QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Amps(i));
            end
        end
    else
        QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Amps=[];
        for Mod=1:length(QuaSOR_Parameters.Modality)
            QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Amps=[];
        end
    end
end
QuaSOR_Data.All_Location_Amps=[];
for Mod=1:length(QuaSOR_Data.Modality)
    QuaSOR_Data.Modality(Mod).All_Location_Amps=[];
end
for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
    QuaSOR_Data.All_Location_Amps=...
        horzcat(QuaSOR_Data.All_Location_Amps,...
        QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Amps);
    for Mod=1:length(QuaSOR_Data.Modality)
        QuaSOR_Data.Modality(Mod).All_Location_Amps=...
            horzcat(QuaSOR_Data.Modality(Mod).All_Location_Amps,...
            QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Amps);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Finished!\n')
QuaSOR_Data.Total_Coords=size(QuaSOR_Data.All_Location_Coords_byEpisodeNum,1);
fprintf(['Found a total of ',num2str(QuaSOR_Data.Total_Coords),' QuaSOR Coords Overall\n'])
for Mod=1:length(QuaSOR_Data.Modality)
    QuaSOR_Data.Modality(Mod).Total_Coords=size(QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum,1);
    fprintf(['                 ',num2str(QuaSOR_Data.Modality(Mod).Total_Coords),' ',QuaSOR_Data.Modality(Mod).Label,' QuaSOR Coords\n'])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     if ~isfield(QuaSOR_Data,'All_Location_Amps')
%         for EpisodeNumber_Load=1:length(QuaSOR_Data.Episode)
%             for Mod=1:length(QuaSOR_Parameters.Modality)
%                 QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Amps=[];
%             end
%             if ~isempty(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords)
%                 for i=1:size(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords,1)
%                     Mod=0;
%                     if any(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,3)==ImagingInfo.IntraEpisode_Evoked_ActiveFrames)
%                         Mod=1;
%                     elseif any(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,3)==ImagingInfo.IntraEpisode_Spont_ActiveFrames)
%                         Mod=2;
%                     end
%                     if Mod~=0
%                         QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Amps=...
%                             horzcat(QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Amps,...
%                             QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Amps(i));
%                     end
%                 end
%             else
%                 QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Amps=[];
%                 for Mod=1:length(QuaSOR_Parameters.Modality)
%                     QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Amps=[];
%                 end
%             end
%         end
%         QuaSOR_Data.All_Location_Amps=[];
%         for Mod=1:length(QuaSOR_Data.Modality)
%             QuaSOR_Data.Modality(Mod).All_Location_Amps=[];
%         end
%         for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
%             QuaSOR_Data.All_Location_Amps=...
%                 horzcat(QuaSOR_Data.All_Location_Amps,...
%                 QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Amps);
%             for Mod=1:length(QuaSOR_Data.Modality)
%                 QuaSOR_Data.Modality(Mod).All_Location_Amps=...
%                     horzcat(QuaSOR_Data.Modality(Mod).All_Location_Amps,...
%                     QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Amps);
%             end
%         end
% 
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('============================================================')
    disp('Extracting Event DeltaF/Fs...')
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
    if ~exist('QuaSOR_Event_Extraction_Settings')
        QuaSOR_Event_Extraction_Settings=Default_QuaSOR_Event_Extraction_Settings;
    end
    QuaSOR_Event_Extraction_Settings.RegionRadius_px=ceil(QuaSOR_Event_Extraction_Settings.RegionRadius_nm/(ScaleBar.ScaleFactor*1000));
    ProgressBarOn=1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [DeltaFF0_Col DeltaFF0_Row] = meshgrid(1:Image_Width,...
        1:Image_Height);
    ZerosImage=zeros(Image_Height,Image_Width,'logical');
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
        %Event Centered Traces
        fprintf('by Events...')
        EventStruct=[];
        for i=1:size(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords,1)
            EventStruct(i).Coord=QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,:);
            EventStruct(i).Coord_Round=round(EventStruct(i).Coord);
            EventStruct(i).Mask =    (DeltaFF0_Row - EventStruct(i).Coord_Round(1)).^2 + ...
                (DeltaFF0_Col - EventStruct(i).Coord_Round(2)).^2 <= ...
                QuaSOR_Event_Extraction_Settings.RegionRadius_px.^2;
            EventStruct(i).Mask=logical(EventStruct(i).Mask);
            EventStruct(i).TraceFrames=[EventStruct(i).Coord(3)-QuaSOR_Event_Extraction_Settings.PreTraceFrames:EventStruct(i).Coord(3)+QuaSOR_Event_Extraction_Settings.PostTraceFrames];
            EventStruct(i).TracePeakFrame=QuaSOR_Event_Extraction_Settings.PreTraceFrames+1;
            EventStruct(i).PeakFrames=[EventStruct(i).TracePeakFrame-QuaSOR_Event_Extraction_Settings.PrePeakFrames:EventStruct(i).TracePeakFrame+QuaSOR_Event_Extraction_Settings.PostPeakFrames];
            EventStruct(i).DeltaFF0_MeanTrace=[];
            EventStruct(i).DeltaFF0_MaxTrace=[];
            EventStruct(i).DeltaFF0_MeanTrace_Max=[];
            EventStruct(i).DeltaFF0_Max=[];
        end
        if ~any(strcmp(OS,'MACI64'))&&ProgressBarOn
            ppm = ParforProgMon([StackSaveName,' || Episode # ',num2str(EpisodeNumber_Load),' || ',...
                num2str(size(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byFrame,1)),' Events '],...
                size(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords_byFrame,1), 1, 1000, 80);
        else
            ppm=0;
        end
        parfor i=1:size(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords,1)
            TempDataStruct=[];
            TempMaxVals=[];
            TempMeanTrace=[];
            TempOverallMax=0;
            for f1=1:length(EventStruct(i).TraceFrames)
                TempDataStruct(f1).DeltaFF0=NaN;
                f=EventStruct(i).TraceFrames(f1);
                if f>0&&f<=ImagingInfo.FramesPerEpisode
                    TempImage=TempDeltaFF0(:,:,f);
                    TempDataStruct(f1).DeltaFF0=TempImage(EventStruct(i).Mask);
                else
                    TempDataStruct(f1).DeltaFF0=NaN;
                end
                TempMaxVals(f1)=max(TempDataStruct(f1).DeltaFF0(:));
                TempDataStruct(f1).DeltaFF0_Mean=nanmean(TempDataStruct(f1).DeltaFF0);
                TempMeanTrace(f1)=TempDataStruct(f1).DeltaFF0_Mean;
            end
            TempOverallMax=max(TempMaxVals(EventStruct(i).PeakFrames));
            TempMeanMax=max(TempMeanTrace(EventStruct(i).PeakFrames));
            EventStruct(i).DeltaFF0_Max=TempOverallMax;
            EventStruct(i).DeltaFF0_MeanTrace=TempMeanTrace;
            EventStruct(i).DeltaFF0_MaxTrace=TempMaxVals;
            EventStruct(i).DeltaFF0_MeanTrace_Max=TempMeanMax;
            EventStruct(i).Mask=[];
            if ~any(strcmp(OS,'MACI64'))&&ProgressBarOn
                ppm.increment();
            end
        end
        QuaSOR_Data.Episode(EpisodeNumber_Load).EventStruct=EventStruct;
        clear EventStruct
        %%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('Finished!\n')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    QuaSOR_Data.QuaSOR_Event_Extraction_Settings=QuaSOR_Event_Extraction_Settings;
    for Mod=1:length(QuaSOR_Parameters.Modality)
        QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces=[];
    end
    for EpisodeNumber_Load=1:length(QuaSOR_Data.Episode)
        QuaSOR_Data.Episode(EpisodeNumber_Load).Max_DeltaFF0=[];
        QuaSOR_Data.Episode(EpisodeNumber_Load).Max_DeltaFF0_MeanTrace=[];
        for Mod=1:length(QuaSOR_Parameters.Modality)
            QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords=[];
            QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).Max_DeltaFF0=[];
            QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).Max_DeltaFF0_MeanTrace=[];
        end
        if ~isempty(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords)
            if length(QuaSOR_Data.Episode(EpisodeNumber_Load).EventStruct)~=...
                    size(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords,1)
                error('Size mismatch!')
            end
            for i=1:size(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords,1)
                QuaSOR_Data.Episode(EpisodeNumber_Load).Max_DeltaFF0=...
                    horzcat(QuaSOR_Data.Episode(EpisodeNumber_Load).Max_DeltaFF0,...
                    QuaSOR_Data.Episode(EpisodeNumber_Load).EventStruct(i).DeltaFF0_Max);
                QuaSOR_Data.Episode(EpisodeNumber_Load).Max_DeltaFF0_MeanTrace=...
                    horzcat(QuaSOR_Data.Episode(EpisodeNumber_Load).Max_DeltaFF0_MeanTrace,...
                    QuaSOR_Data.Episode(EpisodeNumber_Load).EventStruct(i).DeltaFF0_MeanTrace_Max);
                Mod=0;
                if any(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,3)==ImagingInfo.IntraEpisode_Evoked_ActiveFrames)
                    Mod=1;
                elseif any(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,3)==ImagingInfo.IntraEpisode_Spont_ActiveFrames)
                    Mod=2;
                end
                if Mod~=0
                    QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords=...
                        vertcat(QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords,...
                        QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,:));
                    QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).Max_DeltaFF0=...
                        horzcat(QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).Max_DeltaFF0,...
                        QuaSOR_Data.Episode(EpisodeNumber_Load).EventStruct(i).DeltaFF0_Max);
                    QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).Max_DeltaFF0_MeanTrace=...
                        horzcat(QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).Max_DeltaFF0_MeanTrace,...
                        QuaSOR_Data.Episode(EpisodeNumber_Load).EventStruct(i).DeltaFF0_MeanTrace_Max);
                    QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces=...
                        vertcat(QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces,...
                        QuaSOR_Data.Episode(EpisodeNumber_Load).EventStruct(i).DeltaFF0_MeanTrace);
                end
            end
        else
            QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Amps=[];
            for Mod=1:length(QuaSOR_Parameters.Modality)
                QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Amps=[];
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for Mod=1:length(QuaSOR_Parameters.Modality)
        [QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_Mean,...
            QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_STD,...
            QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_SEM, ~]=...
            Mean_STD_SEM2(1,QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces);
    end
    MaxAmp=0;
    MinAmp=10000000;
    for Mod=1:length(QuaSOR_Data.Modality)
       MaxAmp=max([MaxAmp,max(QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_Mean)+...
            max(QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_SEM)]);
        MinAmp=min([MinAmp,min(QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_Mean)-...
            max(QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_SEM)]);
    end
    MaxAmp=ceil(MaxAmp*10)/10;
    MinAmp=floor(MinAmp*100)/100;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    QuaSOR_Data.Treatment=[];
    QuaSOR_Data.TreatmentCount=0;
    QuaSOR_Data.EventType=[];
    QuaSOR_Data.EventTypeCount=0;
    QuaSOR_Data.All_Location_Coords=[];
    QuaSOR_Data.All_Max_DeltaFF0=[];
    QuaSOR_Data.All_Max_DeltaFF0_MeanTrace=[];
    for Mod=1:length(QuaSOR_Data.Modality)
        QuaSOR_Data.Modality(Mod).Treatment=[];
        QuaSOR_Data.Modality(Mod).TreatmentCount=0;
        QuaSOR_Data.Modality(Mod).EventType=[];
        QuaSOR_Data.Modality(Mod).EventTypeCount=0;
        QuaSOR_Data.Modality(Mod).All_Location_Coords=[];
        QuaSOR_Data.Modality(Mod).All_Max_DeltaFF0=[];
        QuaSOR_Data.Modality(Mod).All_Max_DeltaFF0_MeanTrace=[];
    end
    for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
        Treatment='';
        if ~isempty(MarkerSetInfo.Markers)
            for Marker=1:length(MarkerSetInfo.Markers)
                if any(EpisodeNumber_Load==[MarkerSetInfo.Markers(Marker).MarkerStart:MarkerSetInfo.Markers(Marker).MarkerEnd])
                    Treatment=[Treatment,MarkerSetInfo.Markers(Marker).MarkerShortLabel,' '];
                end
            end
        end
        QuaSOR_Data.All_Location_Coords=...
            vertcat(QuaSOR_Data.All_Location_Coords,...
            QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords);
        QuaSOR_Data.All_Max_DeltaFF0=...
            horzcat(QuaSOR_Data.All_Max_DeltaFF0,...
            QuaSOR_Data.Episode(EpisodeNumber_Load).Max_DeltaFF0);
        QuaSOR_Data.All_Max_DeltaFF0_MeanTrace=...
            horzcat(QuaSOR_Data.All_Max_DeltaFF0_MeanTrace,...
            QuaSOR_Data.Episode(EpisodeNumber_Load).Max_DeltaFF0_MeanTrace);
        for i=1:length(QuaSOR_Data.Episode(EpisodeNumber_Load).Max_DeltaFF0)
            QuaSOR_Data.TreatmentCount=QuaSOR_Data.TreatmentCount+1;
            QuaSOR_Data.Treatment{QuaSOR_Data.TreatmentCount}=Treatment;
            Mod=0;
            if any(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,3)==ImagingInfo.IntraEpisode_Evoked_ActiveFrames)
                Mod=1;
            elseif any(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(i,3)==ImagingInfo.IntraEpisode_Spont_ActiveFrames)
                Mod=2;
            end
            if Mod~=0
                QuaSOR_Data.EventTypeCount=QuaSOR_Data.EventTypeCount+1;
                QuaSOR_Data.EventType{QuaSOR_Data.EventTypeCount}=QuaSOR_Data.Modality(Mod).Label;
            end
        end
        for Mod=1:length(QuaSOR_Data.Modality)
            QuaSOR_Data.Modality(Mod).All_Location_Coords=...
                vertcat(QuaSOR_Data.Modality(Mod).All_Location_Coords,...
                QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).All_Location_Coords);
            QuaSOR_Data.Modality(Mod).All_Max_DeltaFF0=...
                horzcat(QuaSOR_Data.Modality(Mod).All_Max_DeltaFF0,...
                QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).Max_DeltaFF0);
            QuaSOR_Data.Modality(Mod).All_Max_DeltaFF0_MeanTrace=...
                horzcat(QuaSOR_Data.Modality(Mod).All_Max_DeltaFF0_MeanTrace,...
                QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).Max_DeltaFF0_MeanTrace);
            for i=1:length(QuaSOR_Data.Episode(EpisodeNumber_Load).Modality(Mod).Max_DeltaFF0)
                QuaSOR_Data.Modality(Mod).TreatmentCount=QuaSOR_Data.Modality(Mod).TreatmentCount+1;
                QuaSOR_Data.Modality(Mod).Treatment{QuaSOR_Data.Modality(Mod).TreatmentCount}=Treatment;
                QuaSOR_Data.Modality(Mod).EventTypeCount=QuaSOR_Data.Modality(Mod).EventTypeCount+1;
                QuaSOR_Data.Modality(Mod).EventType{QuaSOR_Data.Modality(Mod).EventTypeCount}=QuaSOR_Data.Modality(Mod).Label;
            end
        end
    end
    QuaSOR_Data.OverallMaxDeltaFF0=max([max(QuaSOR_Data.All_Location_Amps),max(QuaSOR_Data.All_Max_DeltaFF0),max(QuaSOR_Data.All_Max_DeltaFF0_MeanTrace)]);
    disp(['QuaSOR_Data.OverallMaxDeltaFF0 = ',num2str(QuaSOR_Data.OverallMaxDeltaFF0)]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
