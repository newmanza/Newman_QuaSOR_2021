if ~exist(CurrentScratchDir)
    mkdir(CurrentScratchDir)
end
CurrentAnalysisLabel='Registration Evaluation';
CurrentAnalysisLabelShort='Reg Eval';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('============================================================')
try
FileSuffix='_DeltaFData.mat';
load([SaveDir,StackSaveName,FileSuffix],'SplitEpisodeFiles')
catch
    
end
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
cd(SaveDir)
FrameAdjust=-0.5;

Evaluation_Episodes=[1:ImagingInfo.NumEpisodes];
KeepChecking=1;
while KeepChecking
    EvalChoice = questdlg({StackSaveName;'Check Registration?'},'Evaluate Stage?','Registered vs Raw','DeltaF vs Registered','Finished','DeltaF vs Registered');
    if strcmp(EvalChoice,'Registered vs Raw')

        warning('Not ready yet')

    elseif strcmp(EvalChoice,'DeltaF vs Registered')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Eval_ImageArray=[];
        InputAnalysis=[];
        ImageCount=0;
        EvaluationEpisodeList=[];
        for e=1:ImagingInfo.NumEpisodes
            EvaluationEpisodeList{e}=['Episode ',num2str(e),' ',num2str(ImagingInfo.FramesPerEpisode),' Frames'];
        end
        [Evaluation_Episodes, ~] = listdlg('PromptString','Select Evaluation Episodes(s)?',...
            'ListString',EvaluationEpisodeList,'ListSize', [800 600],'InitialValue',Evaluation_Episodes);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        
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
        progressbar('Collecting Episodes...')
        for E=1:length(Evaluation_Episodes)
            EpisodeNumber_Load=Evaluation_Episodes(E);
            InputAnalysis.FrameMarkers(EpMarker).Frames=...
                [InputAnalysis.FrameMarkers(EpMarker).Frames,(E-1)*ImagingInfo.FramesPerEpisode+1+FrameAdjust];
            if length(Evaluation_Episodes)>50
                InputAnalysis.FrameMarkers(EpMarker).Labels{length(InputAnalysis.FrameMarkers(EpMarker).Frames)}=...
                    [];
            else
                InputAnalysis.FrameMarkers(EpMarker).Labels{length(InputAnalysis.FrameMarkers(EpMarker).Frames)}=...
                    ['Ep',num2str(EpisodeNumber_Load)];
            end
            if ~isnan(ImagingInfo.StimuliPerEpisode)
                s1=length(InputAnalysis.FrameMarkers(StimMarker).Frames)+1;
                for s=1:ImagingInfo.StimuliPerEpisode
                    InputAnalysis.FrameMarkers(StimMarker).Frames{s}=...
                        [(E-1)*ImagingInfo.FramesPerEpisode+ImagingInfo.IntraEpisode_StimuliFrames(s)+FrameAdjust];
                    if ImagingInfo.StimuliPerEpisode==1
                        InputAnalysis.FrameMarkers(StimMarker).Labels{s1}=...
                            [];
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
            else
                EpisodeNumber=EpisodeNumber_Load;
            end
            Eval_ImageArray_Reg=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_BC;
            Eval_ImageArray_DeltaF=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaF;
            for ImageNumber=1:ImagingInfo.FramesPerEpisode
                ImageCount=ImageCount+1;
                Eval_ImageArray(:,:,1,ImageCount)=Eval_ImageArray_DeltaF(:,:,ImageNumber);
                Eval_ImageArray(:,:,2,ImageCount)=Eval_ImageArray_Reg(:,:,ImageNumber);
            end
            progressbar(E/length(Evaluation_Episodes))
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
        Channel_Labels={'DeltaF','Reg and BC'};
        Channel_Colors={'jet','w'};
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
