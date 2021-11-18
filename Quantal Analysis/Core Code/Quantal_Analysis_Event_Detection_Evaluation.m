if ~exist(CurrentScratchDir)
    mkdir(CurrentScratchDir)
end
CurrentAnalysisLabel='Event Detection Eval';
CurrentAnalysisLabelShort='Event Detect Eval';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('============================================================')
FileSuffix='_DeltaFData.mat';
load([SaveDir,StackSaveName,FileSuffix],'SplitEpisodeFiles')
if ~exist([SaveDir,StackSaveName,FileSuffix])
    error([StackSaveName,FileSuffix,' Missing!']);
else
    FileInfo = dir([SaveDir,StackSaveName,FileSuffix]);
    TimeStamp = FileInfo.date;
    CurrentDateNum=FileInfo.datenum;
    disp([StackSaveName,FileSuffix,' Last updated: ',TimeStamp]);
    if Safe2CopyDelete
        if ~exist([CurrentScratchDir,StackSaveName,FileSuffix])
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
disp('============================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('SplitEpisodeFiles')
    SplitEpisodeFiles=0;
end
if SplitEpisodeFiles&&any(AnalysisParts>0)
    for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
        FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
        if Safe2CopyDelete
            if ~exist([CurrentScratchDir,StackSaveName,FileSuffix])
                fprintf(['Copying: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
                [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
                fprintf('Finished!\n')
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('============================================================')
FileSuffix='_EventDetectionData.mat';
load([SaveDir,StackSaveName,FileSuffix],'SplitEpisodeFiles','EventDetectionSettings')
if ~exist([SaveDir,StackSaveName,FileSuffix])
    error([StackSaveName,FileSuffix,' Missing!']);
else
    FileInfo = dir([SaveDir,StackSaveName,FileSuffix]);
    TimeStamp = FileInfo.date;
    CurrentDateNum=FileInfo.datenum;
    disp([StackSaveName,FileSuffix,' Last updated: ',TimeStamp]);
    if Safe2CopyDelete
        if ~exist([CurrentScratchDir,StackSaveName,FileSuffix])
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
disp('============================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('SplitEpisodeFiles')
    SplitEpisodeFiles=0;
end
if SplitEpisodeFiles&&any(AnalysisParts>0)
    for EpisodeNumber_Load=1:ImagingInfo.NumEpisodes
        FileSuffix=['_EventDetectionData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
        if Safe2CopyDelete
            if ~exist([CurrentScratchDir,StackSaveName,FileSuffix])
                fprintf(['Copying: ',StackSaveName,FileSuffix,' to CurrentScratchDir...'])
                [CopyStatus,CopyMessage]=copyfile([SaveDir,StackSaveName,FileSuffix],CurrentScratchDir);
                fprintf('Finished!\n')
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FileSuffix=['_DeltaFData.mat'];
fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
fprintf('Finished!\n')
FileSuffix=['_EventDetectionData.mat'];
fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
load([CurrentScratchDir,StackSaveName,FileSuffix],'EventDetectionStruct','PixelMax_Struct')
fprintf('Finished!\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('============================================================')
cd(SaveDir)
if ~exist('EditMode')
    EditMode=0;
end
FrameAdjust=-0.5;
if EditMode
    PreFrames=0;
    PostFrames=0;
    LocPreFrames=2;
    LocPostFrames=2;
else
    PreFrames=2;
    PostFrames=2;
    LocPreFrames=2;
    LocPostFrames=2;
end
Evaluation_Episodes=[1:ImagingInfo.NumEpisodes];
KeepChecking=1;
while KeepChecking
    EvalChoice = questdlg({StackSaveName;'Check Event Detection?'},'Evaluate Stage?','Full Event Detect','Event ONLY Detect','Finished','Full Event Detect');
    if strcmp(EvalChoice,'Full Event Detect')

        HelpPopup = questdlg({'Sometimes I find it helpful to increase the event persistence';...
            'ONLY for overlay purposes.';'Usually I would add one or two pre and post frames';...
            'Zero in both will show event only when it was IDed'},'Useful Hints!','OK','OK');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        prompt = {'Frames Pre Peak','Frames Post Peak',...
                    'LocMarkers: Frames Pre Peak','LocMarkers: Frames Post Peak'};
        dlg_title = ['Event Frame Persistence'];
        num_lines = 1;
        def = {num2str(PreFrames),num2str(PostFrames),num2str(LocPreFrames),num2str(LocPostFrames)};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        PreFrames=str2num(answer{1});
        PostFrames=str2num(answer{2});
        LocPreFrames=str2num(answer{3});
        LocPostFrames=str2num(answer{4});
        clear answer;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EvaluationEpisodeList=[];
        for e=1:ImagingInfo.NumEpisodes
            EvaluationEpisodeList{e}=['Episode ',num2str(e),' ',num2str(ImagingInfo.FramesPerEpisode),' Frames'];
        end
        [Evaluation_Episodes, ~] = listdlg('PromptString','Select Evaluation Episodes(s)?',...
            'ListString',EvaluationEpisodeList,'ListSize', [800 600],'InitialValue',Evaluation_Episodes);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Eval_ImageArray=[];
        Eval_Struct=[];
        InputAnalysis=[];
        ImageCount=0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for Mod=1:length(PixelMax_Struct.Modality)
            InputAnalysis.LocalizationMarkers(Mod).MarkerOn=1;
            InputAnalysis.LocalizationMarkers(Mod).MarkerTextOn=0;
            InputAnalysis.LocalizationMarkers(Mod).Label=PixelMax_Struct.Modality(Mod).Label;
            InputAnalysis.LocalizationMarkers(Mod).Labels=[];
            if Mod==1
                InputAnalysis.LocalizationMarkers(Mod).Labels='E';
                InputAnalysis.LocalizationMarkers(Mod).Color='w';
            elseif Mod==2
                InputAnalysis.LocalizationMarkers(Mod).Labels='S';
                InputAnalysis.LocalizationMarkers(Mod).Color='r';
            end
            InputAnalysis.LocalizationMarkers(Mod).LabelPersistence.PreFrames=LocPreFrames;
            InputAnalysis.LocalizationMarkers(Mod).LabelPersistence.PostFrames=LocPostFrames;
            InputAnalysis.LocalizationMarkers(Mod).Style=1;%1 Marker Only, 2 Circle
            InputAnalysis.LocalizationMarkers(Mod).Radius_px=10;%Only used in style 2
            InputAnalysis.LocalizationMarkers(Mod).FontSize=10;
            InputAnalysis.LocalizationMarkers(Mod).TextXOffset=0;
            InputAnalysis.LocalizationMarkers(Mod).TextYOffset=0;
            InputAnalysis.LocalizationMarkers(Mod).HorizontalAlignment='left';
            InputAnalysis.LocalizationMarkers(Mod).VerticalAlignment='middle';
            InputAnalysis.LocalizationMarkers(Mod).LineMarkerStyle='o';
            InputAnalysis.LocalizationMarkers(Mod).LineWidth=0.5;
            InputAnalysis.LocalizationMarkers(Mod).MarkerSize=6;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            InputAnalysis.LocalizationMarkers(Mod).Markers=[];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EpMarker=1;
        InputAnalysis.FrameMarkers(EpMarker).MarkerOn=1;
        InputAnalysis.FrameMarkers(EpMarker).MarkerTextOn=1;
        InputAnalysis.FrameMarkers(EpMarker).Frames=[];
        InputAnalysis.FrameMarkers(EpMarker).FrameAdjust=FrameAdjust;
        InputAnalysis.FrameMarkers(EpMarker).Label='Episodes';
        InputAnalysis.FrameMarkers(EpMarker).Labels=[];
        InputAnalysis.FrameMarkers(EpMarker).LabelPersistence.PreFrames=0;
        InputAnalysis.FrameMarkers(EpMarker).LabelPersistence.PostFrames=ImagingInfo.FramesPerEpisode-1;
        InputAnalysis.FrameMarkers(EpMarker).Color=[0.5,0.5,0.5];
        InputAnalysis.FrameMarkers(EpMarker).Style=1;%1 vert 2 horz top 3 horz bottom
        InputAnalysis.FrameMarkers(EpMarker).FontSize=10;
        InputAnalysis.FrameMarkers(EpMarker).TextXOffset=0;
        InputAnalysis.FrameMarkers(EpMarker).TextYOffset=0;
        InputAnalysis.FrameMarkers(EpMarker).HorizontalAlignment='left';
        InputAnalysis.FrameMarkers(EpMarker).VerticalAlignment='top';
        InputAnalysis.FrameMarkers(EpMarker).LineMarkerStyle=':';
        InputAnalysis.FrameMarkers(EpMarker).LineWidth=0.5;
        InputAnalysis.FrameMarkers(EpMarker).MarkerSize=6;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(MarkerSetInfo)
            m=length(InputAnalysis.FrameMarkers);
            for MarkerCount=1:length(MarkerSetInfo.Markers)
                if any(Evaluation_Episodes==MarkerSetInfo.Markers(MarkerCount).MarkerStart)||...
                     any(Evaluation_Episodes==MarkerSetInfo.Markers(MarkerCount).MarkerEnd)   
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if MarkerSetInfo.Markers(MarkerCount).MarkerStyles==1
                        m=m+1;
                        TempFrames=[];
                        for E=1:length(Evaluation_Episodes)
                            EpisodeNumber_Load=Evaluation_Episodes(E);
                            if any(EpisodeNumber_Load>=MarkerSetInfo.Markers(MarkerCount).MarkerStart)&&...
                                    any(EpisodeNumber_Load<=MarkerSetInfo.Markers(MarkerCount).MarkerEnd)
                                TempFrames=[TempFrames,[(E-1)*ImagingInfo.FramesPerEpisode+1:...
                                    (E)*ImagingInfo.FramesPerEpisode]];
                            end
                        end
                        InputAnalysis.FrameMarkers(m).MarkerOn=1;
                        InputAnalysis.FrameMarkers(m).MarkerTextOn=1;
                        InputAnalysis.FrameMarkers(m).Frames{1}=TempFrames;
                        InputAnalysis.FrameMarkers(m).FrameAdjust=FrameAdjust;
                        InputAnalysis.FrameMarkers(m).Label=MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel;
                        InputAnalysis.FrameMarkers(m).Labels{1}=MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel;
                        InputAnalysis.FrameMarkers(m).LabelPersistence.PreFrames=0;
                        InputAnalysis.FrameMarkers(m).LabelPersistence.PostFrames=ImagingInfo.FramesPerEpisode*length(Evaluation_Episodes);
                        InputAnalysis.FrameMarkers(m).Color=MarkerSetInfo.Markers(MarkerCount).MarkerColor;
                        InputAnalysis.FrameMarkers(m).Style=2;%1 vert 2 horz top 3 horz bottom
                        InputAnalysis.FrameMarkers(m).FontSize=10;
                        InputAnalysis.FrameMarkers(m).TextXOffset=0;
                        InputAnalysis.FrameMarkers(m).TextYOffset=0;
                        InputAnalysis.FrameMarkers(m).HorizontalAlignment='left';
                        InputAnalysis.FrameMarkers(m).VerticalAlignment='top';
                        InputAnalysis.FrameMarkers(m).LineMarkerStyle=MarkerSetInfo.Markers(MarkerCount).MarkerLineStyle;
                        InputAnalysis.FrameMarkers(m).LineWidth=0.5;
                        InputAnalysis.FrameMarkers(m).MarkerSize=6;
                    elseif MarkerSetInfo.Markers(MarkerCount).MarkerStyles==2
                        m=m+1;
                        InputAnalysis.FrameMarkers(m).MarkerOn=1;
                        InputAnalysis.FrameMarkers(m).MarkerTextOn=1;
                        InputAnalysis.FrameMarkers(m).Frames(1)=[(MarkerSetInfo.Markers(MarkerCount).MarkerStart-1)*ImagingInfo.FramesPerEpisode+1];
                        InputAnalysis.FrameMarkers(m).FrameAdjust=-1*FrameAdjust;
                        InputAnalysis.FrameMarkers(m).Label=MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel;
                        InputAnalysis.FrameMarkers(m).Labels{1}=MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel;
                        InputAnalysis.FrameMarkers(m).LabelPersistence.PreFrames=0;
                        InputAnalysis.FrameMarkers(m).LabelPersistence.PostFrames=0;
                        InputAnalysis.FrameMarkers(m).Color=MarkerSetInfo.Markers(MarkerCount).MarkerColor;
                        InputAnalysis.FrameMarkers(m).Style=1;%1 vert 2 horz top 3 horz bottom
                        InputAnalysis.FrameMarkers(m).FontSize=10;
                        InputAnalysis.FrameMarkers(m).TextXOffset=0;
                        InputAnalysis.FrameMarkers(m).TextYOffset=0;
                        InputAnalysis.FrameMarkers(m).HorizontalAlignment='left';
                        InputAnalysis.FrameMarkers(m).VerticalAlignment='top';
                        InputAnalysis.FrameMarkers(m).LineMarkerStyle=MarkerSetInfo.Markers(MarkerCount).MarkerLineStyle;
                        InputAnalysis.FrameMarkers(m).LineWidth=0.5;
                        InputAnalysis.FrameMarkers(m).MarkerSize=6;
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        StimMarker=length(InputAnalysis.FrameMarkers)+1;
        InputAnalysis.FrameMarkers(StimMarker).MarkerOn=1;
        InputAnalysis.FrameMarkers(StimMarker).MarkerTextOn=0;
        InputAnalysis.FrameMarkers(StimMarker).Frames=[];
        InputAnalysis.FrameMarkers(StimMarker).FrameAdjust=FrameAdjust;
        InputAnalysis.FrameMarkers(StimMarker).Label='Stimuli';
        InputAnalysis.FrameMarkers(StimMarker).Labels=[];
        InputAnalysis.FrameMarkers(StimMarker).LabelPersistence.PreFrames=0;
        InputAnalysis.FrameMarkers(StimMarker).LabelPersistence.PostFrames=0;
        InputAnalysis.FrameMarkers(StimMarker).Color=[1,0,0];
        InputAnalysis.FrameMarkers(StimMarker).Style=3;%1 vert 2 horz top 3 horz bottom
        InputAnalysis.FrameMarkers(StimMarker).FontSize=10;
        InputAnalysis.FrameMarkers(StimMarker).TextXOffset=0;
        InputAnalysis.FrameMarkers(StimMarker).TextYOffset=0;
        InputAnalysis.FrameMarkers(StimMarker).HorizontalAlignment='left';
        InputAnalysis.FrameMarkers(StimMarker).VerticalAlignment='bottom';
        InputAnalysis.FrameMarkers(StimMarker).LineMarkerStyle='*';
        InputAnalysis.FrameMarkers(StimMarker).LineWidth=0.5;
        InputAnalysis.FrameMarkers(StimMarker).MarkerSize=6;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        progressbar('Collecting Episodes...')
        for E=1:length(Evaluation_Episodes)
            EpisodeNumber_Load=Evaluation_Episodes(E);
            InputAnalysis.FrameMarkers(EpMarker).Frames=...
                [InputAnalysis.FrameMarkers(EpMarker).Frames,(E-1)*ImagingInfo.FramesPerEpisode+1];
            InputAnalysis.FrameMarkers(EpMarker).Labels{length(InputAnalysis.FrameMarkers(EpMarker).Frames)}=...
                ['Ep',num2str(EpisodeNumber_Load)];
            if length(Evaluation_Episodes)>50
                InputAnalysis.FrameMarkers(EpMarker).MarkerTextOn=0;
            else
                InputAnalysis.FrameMarkers(EpMarker).MarkerTextOn=1;
            end
            if ~isnan(ImagingInfo.StimuliPerEpisode)
                s1=length(InputAnalysis.FrameMarkers(StimMarker).Frames)+1;
                for s=1:ImagingInfo.StimuliPerEpisode
                    InputAnalysis.FrameMarkers(StimMarker).Frames{s}=...
                        [(E-1)*ImagingInfo.FramesPerEpisode+ImagingInfo.IntraEpisode_StimuliFrames(s)];
                    if ImagingInfo.StimuliPerEpisode==1
                        InputAnalysis.FrameMarkers(StimMarker).Labels{s1}=...
                            ['*'];
                    elseif ImagingInfo.StimuliPerEpisode>1
                        InputAnalysis.FrameMarkers(StimMarker).Labels{s1}=...
                            [num2str(s)];
                    end
                end
            end
            if SplitEpisodeFiles
                EpisodeNumber=1;
                FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
                fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
                load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
                fprintf('Finished!\n')
                FileSuffix=['_EventDetectionData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
                fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
                load([CurrentScratchDir,StackSaveName,FileSuffix],'EventDetectionStruct','PixelMax_Struct')
                fprintf('Finished!\n')
            else
                EpisodeNumber=EpisodeNumber_Load;
            end
            if EventDetectionSettings.DataType==1
                Eval_ImageArray_Input=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaF;
                Eval_ImageArray_CorrAmp_Events_Thresh_Clean=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean;
            elseif EventDetectionSettings.DataType==2
                Eval_ImageArray_Input=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaFF0;
                Eval_ImageArray_CorrAmp_Events_Thresh_Clean=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean_Norm;
            end
            Eval_ImageArray_CorrAmp_Events_Thresh_Clean_Persistent=zeros(size(Eval_ImageArray_CorrAmp_Events_Thresh_Clean));
            for ImageNumber=1:size(Eval_ImageArray_CorrAmp_Events_Thresh_Clean,3)
                if ImageNumber-PreFrames<=0
                    FrameRange=1:ImageNumber+PreFrames;
                elseif ImageNumber+PreFrames>=size(Eval_ImageArray_CorrAmp_Events_Thresh_Clean,3)
                    FrameRange=ImageNumber-PreFrames:size(Eval_ImageArray_CorrAmp_Events_Thresh_Clean,3);
                else
                    FrameRange=ImageNumber-PreFrames:ImageNumber+PreFrames;
                end
                Eval_ImageArray_CorrAmp_Events_Thresh_Clean_Persistent(:,:,ImageNumber)=...
                    max(Eval_ImageArray_CorrAmp_Events_Thresh_Clean(:,:,FrameRange),[],3);
                LocFrameRange=ImageNumber;
%                 if ImageNumber-LocPreFrames<=0
%                     LocFrameRange=1:ImageNumber+LocPreFrames;
%                 elseif ImageNumber+LocPreFrames>=size(Eval_ImageArray_CorrAmp_Events_Thresh_Clean,3)
%                     LocFrameRange=ImageNumber-LocPreFrames:size(Eval_ImageArray_CorrAmp_Events_Thresh_Clean,3);
%                 else
%                     LocFrameRange=ImageNumber-LocPreFrames:ImageNumber+LocPreFrames;
%                 end
                for Mod=1:length(PixelMax_Struct.Episode(EpisodeNumber).PixelMax_Output.Modality)
                    for i=1:length(PixelMax_Struct.Episode(EpisodeNumber).PixelMax_Output.Modality(Mod).All_Location_Coords_byFrame)
                        if any(PixelMax_Struct.Episode(EpisodeNumber).PixelMax_Output.Modality(Mod).All_Location_Coords_byFrame(i,3)==LocFrameRange)
                            ii=length(InputAnalysis.LocalizationMarkers(Mod).Markers)+1;
                            InputAnalysis.LocalizationMarkers(Mod).Markers(ii).X=...
                                PixelMax_Struct.Episode(EpisodeNumber).PixelMax_Output.Modality(Mod).All_Location_Coords_byFrame(i,2);
                            InputAnalysis.LocalizationMarkers(Mod).Markers(ii).Y=...
                                PixelMax_Struct.Episode(EpisodeNumber).PixelMax_Output.Modality(Mod).All_Location_Coords_byFrame(i,1);
                            InputAnalysis.LocalizationMarkers(Mod).Markers(ii).T=...
                                ImageNumber+(E-1)*ImagingInfo.FramesPerEpisode;
                            InputAnalysis.LocalizationMarkers(Mod).Markers(ii).Z=...
                                1;
                        end
                    end
                end
            end    
            for ImageNumber=1:ImagingInfo.FramesPerEpisode
                ImageCount=ImageCount+1;
                Eval_Struct(ImageCount).Episode=EpisodeNumber_Load;
                Eval_Struct(ImageCount).EpisodeFrame=ImageNumber;
                Eval_ImageArray(:,:,1,ImageCount)=Eval_ImageArray_Input(:,:,ImageNumber);
                Eval_ImageArray(:,:,2,ImageCount)=Eval_ImageArray_CorrAmp_Events_Thresh_Clean_Persistent(:,:,ImageNumber);
            end
            progressbar(E/length(Evaluation_Episodes))
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EpisodeLabel=[];
        if length(Evaluation_Episodes)==1
            EpisodeLabel=['E',num2str(Evaluation_Episodes)];
        else
            EpisodeLabel=['E',num2str(Evaluation_Episodes(1)),'-E',num2str(Evaluation_Episodes(length(Evaluation_Episodes)))];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        StackOrder='YXCT';
        if EventDetectionSettings.DataType==1
            Channel_Labels={'DeltaF','Events'};
        elseif EventDetectionSettings.DataType==2
            Channel_Labels={'DeltaFF0','Events'};
        end
        Channel_Colors={'g','m'};
        ImagingInfo.PixelSize=ScaleBar.ScaleFactor;
        ImagingInfo.PixelUnit='um';
        ImagingInfo.VoxelDepth=NaN;
        ImagingInfo.VoxelUnit='um';
        ImagingInfo.InterFrameTime=1/ImagingInfo.ImagingFrequency;
        ImagingInfo.FrameUnit='s';
        Channel_Info=[];
        EditRecord=[];
        ReleaseFig=0;
        close all
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ViewData=1;
        while ViewData
            [ViewerFig,Channel_Info,ImagingInfo,OutputAnalysis,Temp_Eval_ImageArray]=Stack_Viewer(Eval_ImageArray,...
                AllBoutonsRegion,StackOrder,Channel_Labels,Channel_Colors,Channel_Info,ImagingInfo,...
                [StackSaveName,' ',EpisodeLabel,' ',CurrentAnalysisLabelShort],InputAnalysis,ReleaseFig);
            if ~isempty(Temp_Eval_ImageArray)
                Eval_ImageArray=Temp_Eval_ImageArray;
            end
            InputAnalysis=OutputAnalysis;
            if EditMode
                if ~exist('CorrAmp_Edit_Record')
                    CorrAmp_Edit_Record=[];
                end
                if isfield(OutputAnalysis,'EditRecord')
                    if ~isempty(OutputAnalysis.EditRecord)
                        
                        
                        
                        for Edit=1:length(OutputAnalysis.EditRecord)
                            TempCount=length(CorrAmp_Edit_Record)+1;
                            CorrAmp_Edit_Record(TempCount).Episode=...
                                Eval_Struct(OutputAnalysis.EditRecord(Edit).Frame).Episode;
                            CorrAmp_Edit_Record(TempCount).EpisodeFrame=...
                                Eval_Struct(OutputAnalysis.EditRecord(Edit).Frame).EpisodeFrame;
                            CorrAmp_Edit_Record(TempCount).EditMode=...
                                OutputAnalysis.EditRecord(Edit).EditMode;
                            CorrAmp_Edit_Record(TempCount).EditRegion=...
                                OutputAnalysis.EditRecord(Edit).EditRegion;
                            CorrAmp_Edit_Record(TempCount).EditData=...
                                OutputAnalysis.EditRecord(Edit).EditData;
                            CorrAmp_Edit_Record(TempCount).EditRegionBorderLine=...
                                OutputAnalysis.EditRecord(Edit).EditRegionBorderLine;
                            
                            
                            
                            
                            
                        end
                    end
                end
            else
                Edited_ImageArray=[];
            
            end
            ViewDataChoice = questdlg({'Re-View Data?'},'Re-View Data?','Re-View','Continue','Continue');
            switch ViewDataChoice
                case 'Re-View'
                    ViewData=1;
                case 'Continue'
                    ViewData=0;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(EvalChoice,'Event ONLY Detect')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EvaluationEpisodeList=[];
        for e=1:ImagingInfo.NumEpisodes
            EvaluationEpisodeList{e}=['Episode ',num2str(e),' ',num2str(ImagingInfo.FramesPerEpisode),' Frames'];
        end
        [Evaluation_Episodes, ~] = listdlg('PromptString','Select Evaluation Episodes(s)?',...
            'ListString',EvaluationEpisodeList,'ListSize', [800 600],'InitialValue',Evaluation_Episodes);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Eval_ImageArray=[];
        Eval_Struct=[];
        InputAnalysis=[];
        ImageCount=0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for Mod=1:length(PixelMax_Struct.Modality)
            InputAnalysis.LocalizationMarkers(Mod).MarkerOn=1;
            InputAnalysis.LocalizationMarkers(Mod).MarkerTextOn=0;
            InputAnalysis.LocalizationMarkers(Mod).Label=PixelMax_Struct.Modality(Mod).Label;
            InputAnalysis.LocalizationMarkers(Mod).Labels=[];
            if Mod==1
                InputAnalysis.LocalizationMarkers(Mod).Labels='E';
                InputAnalysis.LocalizationMarkers(Mod).Color='w';
            elseif Mod==2
                InputAnalysis.LocalizationMarkers(Mod).Labels='S';
                InputAnalysis.LocalizationMarkers(Mod).Color='r';
            end
            InputAnalysis.LocalizationMarkers(Mod).LabelPersistence.PreFrames=LocPreFrames;
            InputAnalysis.LocalizationMarkers(Mod).LabelPersistence.PostFrames=LocPostFrames;
            InputAnalysis.LocalizationMarkers(Mod).Style=1;%1 Marker Only, 2 Circle
            InputAnalysis.LocalizationMarkers(Mod).Radius_px=10;%Only used in style 2
            InputAnalysis.LocalizationMarkers(Mod).FontSize=10;
            InputAnalysis.LocalizationMarkers(Mod).TextXOffset=0;
            InputAnalysis.LocalizationMarkers(Mod).TextYOffset=0;
            InputAnalysis.LocalizationMarkers(Mod).HorizontalAlignment='left';
            InputAnalysis.LocalizationMarkers(Mod).VerticalAlignment='middle';
            InputAnalysis.LocalizationMarkers(Mod).LineMarkerStyle='o';
            InputAnalysis.LocalizationMarkers(Mod).LineWidth=0.5;
            InputAnalysis.LocalizationMarkers(Mod).MarkerSize=6;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            InputAnalysis.LocalizationMarkers(Mod).Markers=[];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EpMarker=1;
        InputAnalysis.FrameMarkers(EpMarker).MarkerOn=1;
        InputAnalysis.FrameMarkers(EpMarker).MarkerTextOn=1;
        InputAnalysis.FrameMarkers(EpMarker).Frames=[];
        InputAnalysis.FrameMarkers(EpMarker).FrameAdjust=FrameAdjust;
        InputAnalysis.FrameMarkers(EpMarker).Label='Episodes';
        InputAnalysis.FrameMarkers(EpMarker).Labels=[];
        InputAnalysis.FrameMarkers(EpMarker).LabelPersistence.PreFrames=0;
        InputAnalysis.FrameMarkers(EpMarker).LabelPersistence.PostFrames=0;
        InputAnalysis.FrameMarkers(EpMarker).Color=[0.5,0.5,0.5];
        InputAnalysis.FrameMarkers(EpMarker).Style=1;%1 vert 2 horz top 3 horz bottom
        InputAnalysis.FrameMarkers(EpMarker).FontSize=10;
        InputAnalysis.FrameMarkers(EpMarker).TextXOffset=0;
        InputAnalysis.FrameMarkers(EpMarker).TextYOffset=0;
        InputAnalysis.FrameMarkers(EpMarker).HorizontalAlignment='left';
        InputAnalysis.FrameMarkers(EpMarker).VerticalAlignment='top';
        InputAnalysis.FrameMarkers(EpMarker).LineMarkerStyle=':';
        InputAnalysis.FrameMarkers(EpMarker).LineWidth=0.5;
        InputAnalysis.FrameMarkers(EpMarker).MarkerSize=6;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(MarkerSetInfo)
            m=length(InputAnalysis.FrameMarkers);
            for MarkerCount=1:length(MarkerSetInfo.Markers)
                if any(Evaluation_Episodes==MarkerSetInfo.Markers(MarkerCount).MarkerStart)||...
                     any(Evaluation_Episodes==MarkerSetInfo.Markers(MarkerCount).MarkerEnd)   
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if MarkerSetInfo.Markers(MarkerCount).MarkerStyles==1
                        m=m+1;
                        TempFrames=[];
                        for E=1:length(Evaluation_Episodes)
                            EpisodeNumber_Load=Evaluation_Episodes(E);
                            if any(EpisodeNumber_Load>=MarkerSetInfo.Markers(MarkerCount).MarkerStart)&&...
                                    any(EpisodeNumber_Load<=MarkerSetInfo.Markers(MarkerCount).MarkerEnd)
                                TempFrames=[TempFrames,[(E-1)*ImagingInfo.FramesPerEpisode+1:...
                                    (E)*ImagingInfo.FramesPerEpisode]];
                            end
                        end
                        InputAnalysis.FrameMarkers(m).MarkerOn=1;
                        InputAnalysis.FrameMarkers(m).MarkerTextOn=1;
                        InputAnalysis.FrameMarkers(m).Frames{1}=TempFrames;
                        InputAnalysis.FrameMarkers(m).FrameAdjust=FrameAdjust;
                        InputAnalysis.FrameMarkers(m).Label=MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel;
                        InputAnalysis.FrameMarkers(m).Labels{1}=MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel;
                        InputAnalysis.FrameMarkers(m).LabelPersistence.PreFrames=0;
                        InputAnalysis.FrameMarkers(m).LabelPersistence.PostFrames=ImagingInfo.FramesPerEpisode*length(Evaluation_Episodes);
                        InputAnalysis.FrameMarkers(m).Color=MarkerSetInfo.Markers(MarkerCount).MarkerColor;
                        InputAnalysis.FrameMarkers(m).Style=2;%1 vert 2 horz top 3 horz bottom
                        InputAnalysis.FrameMarkers(m).FontSize=10;
                        InputAnalysis.FrameMarkers(m).TextXOffset=0;
                        InputAnalysis.FrameMarkers(m).TextYOffset=0;
                        InputAnalysis.FrameMarkers(m).HorizontalAlignment='left';
                        InputAnalysis.FrameMarkers(m).VerticalAlignment='top';
                        InputAnalysis.FrameMarkers(m).LineMarkerStyle=MarkerSetInfo.Markers(MarkerCount).MarkerLineStyle;
                        InputAnalysis.FrameMarkers(m).LineWidth=0.5;
                        InputAnalysis.FrameMarkers(m).MarkerSize=6;
                    elseif MarkerSetInfo.Markers(MarkerCount).MarkerStyles==2
                        m=m+1;
                        InputAnalysis.FrameMarkers(m).MarkerOn=1;
                        InputAnalysis.FrameMarkers(m).MarkerTextOn=1;
                        InputAnalysis.FrameMarkers(m).Frames(1)=[(MarkerSetInfo.Markers(MarkerCount).MarkerStart-1)*ImagingInfo.FramesPerEpisode+1];
                        InputAnalysis.FrameMarkers(m).FrameAdjust=-1*FrameAdjust;
                        InputAnalysis.FrameMarkers(m).Label=MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel;
                        InputAnalysis.FrameMarkers(m).Labels{1}=MarkerSetInfo.Markers(MarkerCount).MarkerShortLabel;
                        InputAnalysis.FrameMarkers(m).LabelPersistence.PreFrames=0;
                        InputAnalysis.FrameMarkers(m).LabelPersistence.PostFrames=0;
                        InputAnalysis.FrameMarkers(m).Color=MarkerSetInfo.Markers(MarkerCount).MarkerColor;
                        InputAnalysis.FrameMarkers(m).Style=1;%1 vert 2 horz top 3 horz bottom
                        InputAnalysis.FrameMarkers(m).FontSize=10;
                        InputAnalysis.FrameMarkers(m).TextXOffset=0;
                        InputAnalysis.FrameMarkers(m).TextYOffset=0;
                        InputAnalysis.FrameMarkers(m).HorizontalAlignment='left';
                        InputAnalysis.FrameMarkers(m).VerticalAlignment='top';
                        InputAnalysis.FrameMarkers(m).LineMarkerStyle=MarkerSetInfo.Markers(MarkerCount).MarkerLineStyle;
                        InputAnalysis.FrameMarkers(m).LineWidth=0.5;
                        InputAnalysis.FrameMarkers(m).MarkerSize=6;
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        StimMarker=length(InputAnalysis.FrameMarkers)+1;
        InputAnalysis.FrameMarkers(StimMarker).MarkerOn=1;
        InputAnalysis.FrameMarkers(StimMarker).MarkerTextOn=0;
        InputAnalysis.FrameMarkers(StimMarker).Frames=[];
        InputAnalysis.FrameMarkers(StimMarker).FrameAdjust=FrameAdjust;
        InputAnalysis.FrameMarkers(StimMarker).Label='Stimuli';
        InputAnalysis.FrameMarkers(StimMarker).Labels=[];
        InputAnalysis.FrameMarkers(StimMarker).LabelPersistence.PreFrames=0;
        InputAnalysis.FrameMarkers(StimMarker).LabelPersistence.PostFrames=0;
        InputAnalysis.FrameMarkers(StimMarker).Color=[1,0,0];
        InputAnalysis.FrameMarkers(StimMarker).Style=3;%1 vert 2 horz top 3 horz bottom
        InputAnalysis.FrameMarkers(StimMarker).FontSize=10;
        InputAnalysis.FrameMarkers(StimMarker).TextXOffset=0;
        InputAnalysis.FrameMarkers(StimMarker).TextYOffset=0;
        InputAnalysis.FrameMarkers(StimMarker).HorizontalAlignment='left';
        InputAnalysis.FrameMarkers(StimMarker).VerticalAlignment='bottom';
        InputAnalysis.FrameMarkers(StimMarker).LineMarkerStyle='*';
        InputAnalysis.FrameMarkers(StimMarker).LineWidth=0.5;
        InputAnalysis.FrameMarkers(StimMarker).MarkerSize=6;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        progressbar('Collecting Episodes...')
        PrevActivEp=0;
        for E=1:length(Evaluation_Episodes)
            ActivEp=0;
            EpisodeNumber_Load=Evaluation_Episodes(E);
            if SplitEpisodeFiles
                EpisodeNumber=1;
                FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
                fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
                load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
                fprintf('Finished!\n')
                FileSuffix=['_EventDetectionData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
                fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
                load([CurrentScratchDir,StackSaveName,FileSuffix],'EventDetectionStruct','PixelMax_Struct')
                fprintf('Finished!\n')
            else
                EpisodeNumber=EpisodeNumber_Load;
            end
            for ImageNumber=1:size(EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean,3)
                TestImage=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean(:,:,ImageNumber);
                if any(TestImage(:)>0)
                    
                    ActivEp=ActivEp+1;
%                     if ~isnan(ImagingInfo.StimuliPerEpisode)
%                         if any(InputAnalysis.FrameMarkers(StimMarker).Frames==ImageNumber)
%                             s1=length(InputAnalysis.FrameMarkers(StimMarker).Frames)+1;
%                             for s=1:ImagingInfo.StimuliPerEpisode
%                                 InputAnalysis.FrameMarkers(StimMarker).Frames{s}=...
%                                     [(E-1)*ImagingInfo.FramesPerEpisode+ImagingInfo.IntraEpisode_StimuliFrames(s)];
%                                 if ImagingInfo.StimuliPerEpisode==1
%                                     InputAnalysis.FrameMarkers(StimMarker).Labels{s1}=...
%                                         [];
%                                 elseif ImagingInfo.StimuliPerEpisode>1
%                                     InputAnalysis.FrameMarkers(StimMarker).Labels{s1}=...
%                                         [num2str(s)];
%                                 end
%                             end
%                         end
%                     end

                    ImageCount=ImageCount+1;
                    Eval_Struct(ImageCount).Episode=EpisodeNumber_Load;
                    Eval_Struct(ImageCount).EpisodeFrame=ImageNumber;
                    if EventDetectionSettings.DataType==1
                        Eval_ImageArray(:,:,1,ImageCount)=...
                            EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaF(:,:,ImageNumber);
                        Eval_ImageArray(:,:,2,ImageCount)=...
                            EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean(:,:,ImageNumber);
                    elseif EventDetectionSettings.DataType==2
                        Eval_ImageArray(:,:,1,ImageCount)=...
                            EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaFF0(:,:,ImageNumber);
                        Eval_ImageArray(:,:,2,ImageCount)=...
                            EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean_Norm(:,:,ImageNumber);
                    end
                    for Mod=1:length(PixelMax_Struct.Episode(EpisodeNumber).PixelMax_Output.Modality)
                        for i=1:length(PixelMax_Struct.Episode(EpisodeNumber).PixelMax_Output.Modality(Mod).All_Location_Coords_byFrame)
                            if any(PixelMax_Struct.Episode(EpisodeNumber).PixelMax_Output.Modality(Mod).All_Location_Coords_byFrame(i,3)==ImageNumber)
                                ii=length(InputAnalysis.LocalizationMarkers(Mod).Markers)+1;
                                InputAnalysis.LocalizationMarkers(Mod).Markers(ii).X=...
                                    PixelMax_Struct.Episode(EpisodeNumber).PixelMax_Output.Modality(Mod).All_Location_Coords_byFrame(i,2);
                                InputAnalysis.LocalizationMarkers(Mod).Markers(ii).Y=...
                                    PixelMax_Struct.Episode(EpisodeNumber).PixelMax_Output.Modality(Mod).All_Location_Coords_byFrame(i,1);
                                InputAnalysis.LocalizationMarkers(Mod).Markers(ii).T=...
                                    ImageCount;
                                InputAnalysis.LocalizationMarkers(Mod).Markers(ii).Z=...
                                    1;
                            end
                        end
                    end
                end
            end
            if any(ActivEp)>0
                if isempty(InputAnalysis.FrameMarkers(EpMarker).Frames)
                    InputAnalysis.FrameMarkers(EpMarker).Frames=1;
                else
                    InputAnalysis.FrameMarkers(EpMarker).Frames=...
                        [InputAnalysis.FrameMarkers(EpMarker).Frames,PrevActivEp+1];
                end
                PrevActivEp=InputAnalysis.FrameMarkers(EpMarker).Frames(length(InputAnalysis.FrameMarkers(EpMarker).Frames));
                InputAnalysis.FrameMarkers(EpMarker).Labels{length(InputAnalysis.FrameMarkers(EpMarker).Frames)}=...
                    ['Ep',num2str(EpisodeNumber_Load)];
                if length(Evaluation_Episodes)>50
                    InputAnalysis.FrameMarkers(EpMarker).MarkerTextOn=0;
                else
                    InputAnalysis.FrameMarkers(EpMarker).MarkerTextOn=1;
                end
            end
            progressbar(E/length(Evaluation_Episodes))
        end
        InputAnalysis.FrameMarkers(EpMarker).Frames=InputAnalysis.FrameMarkers(EpMarker).Frames;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        StackOrder='YXCT';
        if EventDetectionSettings.DataType==1
            Channel_Labels={'DeltaF','Events'};
        elseif EventDetectionSettings.DataType==2
            Channel_Labels={'DeltaFF0','Events'};
        end
        Channel_Colors={'g','m'};
        ImagingInfo.PixelSize=ScaleBar.ScaleFactor;
        ImagingInfo.PixelUnit='um';
        ImagingInfo.VoxelDepth=NaN;
        ImagingInfo.VoxelUnit='um';
        ImagingInfo.InterFrameTime=NaN;
        ImagingInfo.FrameUnit='';
        Channel_Info=[];
        EditRecord=[];
        ReleaseFig=0;
        close all
        ViewData=1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        while ViewData
            [ViewerFig,Channel_Info,ImagingInfo,OutputAnalysis,Temp_Eval_ImageArray]=Stack_Viewer(Eval_ImageArray,...
                AllBoutonsRegion,StackOrder,Channel_Labels,Channel_Colors,Channel_Info,ImagingInfo,...
                [StackSaveName,' ',EpisodeLabel,' ',CurrentAnalysisLabelShort],InputAnalysis,ReleaseFig);
            if ~isempty(Temp_Eval_ImageArray)
                Eval_ImageArray=Temp_Eval_ImageArray;
            end
            ViewDataChoice = questdlg({'Re-View Data?'},'Re-View Data?','Re-View','Continue','Continue');
            switch ViewDataChoice
                case 'Re-View'
                    ViewData=1;
                case 'Continue'
                    ViewData=0;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        KeepChecking=0;
    end
    if KeepChecking
        KeepCheckingChoice = questdlg({StackSaveName;'Run Event Detection Evaluation Again?'},'Evaluate?','Repeat','Finished','Repeat');
        switch KeepCheckingChoice
            case 'Repeat'
                KeepChecking=1;
            case 'Finished'
                KeepChecking=0;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
