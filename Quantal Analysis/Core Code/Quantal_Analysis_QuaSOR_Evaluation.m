if ~exist(CurrentScratchDir)
    mkdir(CurrentScratchDir)
end
CurrentAnalysisLabel='QuaSOR Evaluation';
CurrentAnalysisLabelShort='QuaSOR Eval';
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
disp('============================================================')
FileSuffix='_QuaSOR_Data.mat';
if ~exist([SaveDir,StackSaveName,FileSuffix])
    warning([StackSaveName,FileSuffix,' Missing!']);
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
        FileSuffix=['_QuaSOR_Data_Ep_',num2str(EpisodeNumber_Load),'.mat'];
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
FileSuffix='_QuaSOR_Maps.mat';
if ~exist([SaveDir,StackSaveName,FileSuffix])
    warning([StackSaveName,FileSuffix,' Missing!']);
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
disp('============================================================')
FileSuffix='_QuaSOR_AZs.mat';
if ~exist([SaveDir,StackSaveName,FileSuffix])
    warning([StackSaveName,FileSuffix,' Missing!']);
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
disp('============================================================')
FileSuffix='_QuaSOR_Evaluation.mat';
if ~exist([SaveDir,StackSaveName,FileSuffix])
    warning([StackSaveName,FileSuffix,' Missing!']);
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
        FileSuffix=['_QuaSOR_Evaluation_Ep_',num2str(EpisodeNumber_Load),'.mat'];
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
load([CurrentScratchDir,StackSaveName,FileSuffix],'EventDetectionSettings');
FileSuffix='_QuaSOR_Data.mat';
load([CurrentScratchDir,StackSaveName,FileSuffix],'QuaSOR_Parameters','QuaSOR_Event_Extraction_Settings','ScaleBar_Upscale');
FileSuffix='_QuaSOR_Maps.mat';
load([CurrentScratchDir,StackSaveName,FileSuffix],'QuaSOR_Map_Settings','PixelMax_Map_Settings','QuaSOR_LowRes_Map_Settings');
FileSuffix='_QuaSOR_AZs.mat';
load([CurrentScratchDir,StackSaveName,FileSuffix],'QuaSOR_Auto_AZ_Settings');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FileSuffix='_QuaSOR_Data.mat';
fprintf(['Loading: ',FileSuffix,'...'])
load([CurrentScratchDir,StackSaveName,FileSuffix])
fprintf('Finished\n')
FileSuffix=['_QuaSOR_Evaluation.mat'];
fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
load([CurrentScratchDir,StackSaveName,FileSuffix],'QuaSOR_Eval_Struct')
fprintf('Finished!\n')
disp('============================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FileSuffix=['_DeltaFData.mat'];
fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
fprintf('Finished!\n')
FileSuffix=['_EventDetectionData.mat'];
fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
load([CurrentScratchDir,StackSaveName,FileSuffix],'EventDetectionStruct')
fprintf('Finished!\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ImageWidth=size(AllBoutonsRegion,2);
ImageHeight=size(AllBoutonsRegion,1);
ZerosImage_UpScale=zeros(ImageHeight*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,ImageWidth*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,'single');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(SaveDir)
FrameAdjust=-0.5;
PreFrames=2;
PostFrames=2;
LocPreFrames=2;
LocPostFrames=2;
Evaluation_Episodes=[1:ImagingInfo.NumEpisodes];
KeepChecking=1;
while KeepChecking
    EvalChoice = questdlg({StackSaveName;'Check QuaSOR Fitting?'},'Evaluate Stage?','Full QuaSOR Fit','QuaSOR Fit','Finished','QuaSOR Fit');
    if strcmp(EvalChoice,'Full QuaSOR Fit')
        HelpPopup = questdlg({'Sometimes I find it helpful to increase the event persistence';'ONLY for overlay purposes.';'Usually I would add one or two pre and post frames';'Zero in both will show event only when it was IDed'},'Useful Hints!','OK','OK');
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
        EvalStruct=[];
        InputAnalysis=[];
        ImageCount=0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for Mod=1:length(QuaSOR_Data.Modality)
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
        InputAnalysis.FrameMarkers(EpMarker).FramesAdjust=FrameAdjust;
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
        InputAnalysis.FrameMarkers(StimMarker).FramesAdjust=FrameAdjust;
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
        progressbar('Merging Episode','Image Number')
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
                load([CurrentScratchDir,StackSaveName,FileSuffix],'EventDetectionStruct')
                fprintf('Finished!\n')
            else
                EpisodeNumber=EpisodeNumber_Load;
            end
            Eval_ImageArray_Input=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaFF0;
            Eval_ImageArray_CorrAmp_Events_Thresh_Clean=EventDetectionStruct(EpisodeNumber).CorrAmp_Output.ImageArray_CorrAmp_Events_Thresh_Clean_Norm;
            for ImageNumber=1:ImagingInfo.FramesPerEpisode
                ImageCount=ImageCount+1;
                EvalStruct(ImageCount).Episode=EpisodeNumber_Load;
                EvalStruct(ImageCount).EpisodeFrame=ImageNumber;
                if ImageNumber-PreFrames<=0
                    FrameRange=1:ImageNumber+PreFrames;
                elseif ImageNumber+PreFrames>=size(Eval_ImageArray_CorrAmp_Events_Thresh_Clean,3)
                    FrameRange=ImageNumber-PreFrames:size(Eval_ImageArray_CorrAmp_Events_Thresh_Clean,3);
                else
                    FrameRange=ImageNumber-PreFrames:ImageNumber+PreFrames;
                end
                Eval_ImageArray(:,:,1,ImageCount)=single(imresize(max(Eval_ImageArray_CorrAmp_Events_Thresh_Clean(:,:,FrameRange),[],3),...
                    QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor,...
                    QuaSOR_Parameters.UpScaling.UpScaleMethod));

                TempImage=ZerosImage_UpScale;
                for ActiveImageCount=1:length(QuaSOR_Eval_Struct(EpisodeNumber).Episode_Eval)
                    if any(QuaSOR_Eval_Struct(EpisodeNumber).Episode_Eval(ActiveImageCount).ImageNumber==FrameRange)
                        TempImage=max(cat(3,TempImage,QuaSOR_Eval_Struct(EpisodeNumber).Episode_Eval(ActiveImageCount).QuaSOR_FitImage),[],3);
                    end
                end
                Eval_ImageArray(:,:,2,ImageCount)=single(TempImage);
                clear TempImage
                
                LocFrameRange=ImageNumber;
%                 if ImageNumber-LocPreFrames<=0
%                     LocFrameRange=1:ImageNumber+LocPreFrames;
%                 elseif ImageNumber+LocPreFrames>=size(Eval_ImageArray_CorrAmp_Events_Thresh_Clean,3)
%                     LocFrameRange=ImageNumber-LocPreFrames:size(Eval_ImageArray_CorrAmp_Events_Thresh_Clean,3);
%                 else
%                     LocFrameRange=ImageNumber-LocPreFrames:ImageNumber+LocPreFrames;
%                 end
                for Mod=1:length(QuaSOR_Data.Episode(EpisodeNumber).Modality)
                    for i=1:length(QuaSOR_Data.Episode(EpisodeNumber).Modality(Mod).All_Location_Coords_byEpisodeFrame)
                        if any(QuaSOR_Data.Episode(EpisodeNumber).Modality(Mod).All_Location_Coords_byEpisodeFrame(i,3)==LocFrameRange)
                            ii=length(InputAnalysis.LocalizationMarkers(Mod).Markers)+1;
                            InputAnalysis.LocalizationMarkers(Mod).Markers(ii).X=...
                                QuaSOR_Data.Episode(EpisodeNumber).Modality(Mod).All_Location_Coords_byEpisodeFrame(i,2)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor;
                            InputAnalysis.LocalizationMarkers(Mod).Markers(ii).Y=...
                                QuaSOR_Data.Episode(EpisodeNumber).Modality(Mod).All_Location_Coords_byEpisodeFrame(i,1)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor;
                            InputAnalysis.LocalizationMarkers(Mod).Markers(ii).T=...
                                ImageNumber+(E-1)*ImagingInfo.FramesPerEpisode;
                            InputAnalysis.LocalizationMarkers(Mod).Markers(ii).Z=...
                                1;
                        end
                    end
                end
                

                progressbar(E/length(Evaluation_Episodes),ImageNumber/ImagingInfo.FramesPerEpisode)
            end 
            clear Eval_ImageArray_Input Eval_ImageArray_CorrAmp_Events_Thresh_Clean
            if SplitEpisodeFiles
                clear PixelMax_Struct QuaSOR_Eval_Struct EventDetectionStruct
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EpisodeLabel=[];
        if length(Evaluation_Episodes)==1
            EpisodeLabel=['E',num2str(Evaluation_Episodes)];
        else
            EpisodeLabel=['E',num2str(Evaluation_Episodes(1)),'-E',num2str(Evaluation_Episodes(length(Evaluation_Episodes)))];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        StackOrder='YXCT';
        Channel_Labels={'CorrAmp','QuaSOR Fit'};
        Channel_Colors={'jet','jet'};
        ImagingInfo.PixelSize=ScaleBar_Upscale.ScaleFactor;
        ImagingInfo.PixelUnit='um';
        ImagingInfo.VoxelDepth=NaN;
        ImagingInfo.VoxelUnit='um';
        ImagingInfo.InterFrameTime=1/ImagingInfo.ImagingFrequency;
        ImagingInfo.FrameUnit='s';
        Channel_Info=[];
        EditRecord=[];
        ReleaseFig=0;
        close all

        ViewData=1;
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
        Eval_ImageArray=[];

    elseif strcmp(EvalChoice,'QuaSOR Fit')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EvaluationEpisodeList=[];
        for e=1:ImagingInfo.NumEpisodes
            EvaluationEpisodeList{e}=['Episode ',num2str(e),' ',num2str(ImagingInfo.FramesPerEpisode),' Frames'];
        end
        [Evaluation_Episodes, ~] = listdlg('PromptString','Select Evaluation Episodes(s)?',...
            'ListString',EvaluationEpisodeList,'ListSize', [800 600],'InitialValue',Evaluation_Episodes);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Eval_ImageArray=[];
        EvalStruct=[];
        InputAnalysis=[];
        ImageCount=0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for Mod=1:length(QuaSOR_Data.Modality)
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
        InputAnalysis.FrameMarkers(EpMarker).FramesAdjust=FrameAdjust;
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
                        InputAnalysis.FrameMarkers(m).Frames(1)=[(MarkerSetInfo.Markers(MarkerCount).MarkerStart-1)*ImagingInfo.FramesPerEpisode+1-FrameAdjust];
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
        StimMarker=length(InputAnalysis.FrameMarkers)+1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        InputAnalysis.FrameMarkers(StimMarker).MarkerOn=1;
        InputAnalysis.FrameMarkers(StimMarker).MarkerTextOn=0;
        InputAnalysis.FrameMarkers(StimMarker).Frames=[];
        InputAnalysis.FrameMarkers(StimMarker).FramesAdjust=FrameAdjust;
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
        PrevImageNum=0;
        for E=1:length(Evaluation_Episodes)
            ActivEp=0;
            EpisodeNumber_Load=Evaluation_Episodes(E);
            if SplitEpisodeFiles
                EpisodeNumber=1;
                FileSuffix=['_QuaSOR_Evaluation_Ep_',num2str(EpisodeNumber_Load),'.mat'];
                fprintf(['Loading: ',StackSaveName,FileSuffix,' from CurrentScratchDir...'])
                load([CurrentScratchDir,StackSaveName,FileSuffix],'QuaSOR_Eval_Struct')
                fprintf('Finished!\n')
            else
                EpisodeNumber=EpisodeNumber_Load;
            end
            for ActiveImageCount=1:length(QuaSOR_Eval_Struct(EpisodeNumber).Episode_Eval)

                ImageNumber=QuaSOR_Eval_Struct(EpisodeNumber).Episode_Eval(ActiveImageCount).ImageNumber;
                ActivEp=ActivEp+1;
%                 if ~isnan(ImagingInfo.StimuliPerEpisode)
%                     if any(InputAnalysis.FrameMarkers(StimMarker).Frames==ImageNumber)
%                         s1=length(InputAnalysis.FrameMarkers(StimMarker).Frames)+1;
%                         for s=1:ImagingInfo.StimuliPerEpisode
%                             InputAnalysis.FrameMarkers(StimMarker).Frames{s}=...
%                                 [(E-1)*ImagingInfo.FramesPerEpisode+ImagingInfo.IntraEpisode_StimuliFrames(s)];
%                             if ImagingInfo.StimuliPerEpisode==1
%                                 InputAnalysis.FrameMarkers(StimMarker).Labels{s1}=...
%                                     [];
%                             elseif ImagingInfo.StimuliPerEpisode>1
%                                 InputAnalysis.FrameMarkers(StimMarker).Labels{s1}=...
%                                     [num2str(s)];
%                             end
%                         end
%                     end
%                 end

                ImageCount=ImageCount+1;
                    EvalStruct(ImageCount).Episode=EpisodeNumber_Load;
                    EvalStruct(ImageCount).EpisodeFrame=ImageNumber;
                Eval_ImageArray(:,:,1,ImageCount)=QuaSOR_Eval_Struct(EpisodeNumber).Episode_Eval(ActiveImageCount).CorrAmp_UpScale;
                Eval_ImageArray(:,:,2,ImageCount)=QuaSOR_Eval_Struct(EpisodeNumber).Episode_Eval(ActiveImageCount).QuaSOR_FitImage;
                for Mod=1:length(QuaSOR_Data.Episode(EpisodeNumber).Modality)
                    for i=1:length(QuaSOR_Data.Episode(EpisodeNumber).Modality(Mod).All_Location_Coords_byEpisodeFrame)
                        if any(QuaSOR_Data.Episode(EpisodeNumber).Modality(Mod).All_Location_Coords_byEpisodeFrame(i,3)==ImageNumber)
                            ii=length(InputAnalysis.LocalizationMarkers(Mod).Markers)+1;
                            InputAnalysis.LocalizationMarkers(Mod).Markers(ii).X=...
                                QuaSOR_Data.Episode(EpisodeNumber).Modality(Mod).All_Location_Coords_byEpisodeFrame(i,2)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor;
                            InputAnalysis.LocalizationMarkers(Mod).Markers(ii).Y=...
                                QuaSOR_Data.Episode(EpisodeNumber).Modality(Mod).All_Location_Coords_byEpisodeFrame(i,1)*QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor;
                            InputAnalysis.LocalizationMarkers(Mod).Markers(ii).T=...
                                ImageCount;
                            InputAnalysis.LocalizationMarkers(Mod).Markers(ii).Z=...
                                1;
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
        Channel_Labels={'CorrAmp','QuaSOR Fit'};
        Channel_Colors={'g','m'};
        ImagingInfo.PixelSize=ScaleBar_Upscale.ScaleFactor;
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
        Eval_ImageArray=[];

    else
        KeepChecking=0;
    end
    if KeepChecking
        KeepCheckingChoice = questdlg({StackSaveName;'Run QuaSOR Evaluation Again?'},'Evaluate?','Repeat','Finished','Repeat');
        switch KeepCheckingChoice
            case 'Repeat'
                KeepChecking=1;
            case 'Finished'
                KeepChecking=0;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
