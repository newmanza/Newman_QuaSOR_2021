%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TableDir=[SaveDir,'Exports',dc];
if ~exist(TableDir)
mkdir(TableDir); 
end
TableName=[StackSaveName,' All Pooled QuaSOR Events'];
fprintf(['Exporting: ',TableName,'...']);
X_Coord=QuaSOR_Data.All_Location_Coords_byOverallFrame(:,2);
Y_Coord=QuaSOR_Data.All_Location_Coords_byOverallFrame(:,1);
Episode_Frame=QuaSOR_Data.All_Location_Coords(:,3);
Overall_Frame=QuaSOR_Data.All_Location_Coords_byOverallFrame(:,3);
Stimulus=QuaSOR_Data.All_Location_Coords_byOverallStim(:,3);
Episode=QuaSOR_Data.All_Location_Coords_byEpisodeNum(:,3);
Corr_Amp=QuaSOR_Data.All_Location_Amps';
Max_DeltaFF0=QuaSOR_Data.All_Max_DeltaFF0';
Mean_DeltaFF0Trace_Max=QuaSOR_Data.All_Max_DeltaFF0_MeanTrace';
Event_Type=QuaSOR_Data.EventType';
Treatments=QuaSOR_Data.Treatment';
QuaSOR_Data.EventTable=table(Event_Type,X_Coord,Y_Coord,Episode,Episode_Frame,Overall_Frame,Stimulus,Corr_Amp,Max_DeltaFF0,Mean_DeltaFF0Trace_Max,Treatments);
if exist([TableDir,TableName,'.xlsx'])
delete([TableDir,TableName,'.xlsx'])
end
writetable(QuaSOR_Data.EventTable,[TableDir,TableName,'.xlsx'])
fprintf('Finished!\n');
for Mod=1:length(QuaSOR_Data.Modality)
TableName=[StackSaveName,' All ',QuaSOR_Data.Modality(Mod).Label,' QuaSOR Events'];
fprintf(['Exporting: ',TableName,'...']);
if ~isempty(QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame)
    X_Coord=QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame(:,2);
    Y_Coord=QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame(:,1);
    Episode_Frame=QuaSOR_Data.Modality(Mod).All_Location_Coords(:,3);
    Overall_Frame=QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallFrame(:,3);
    Stimulus=QuaSOR_Data.Modality(Mod).All_Location_Coords_byOverallStim(:,3);
    Episode=QuaSOR_Data.Modality(Mod).All_Location_Coords_byEpisodeNum(:,3);
    Corr_Amp=QuaSOR_Data.Modality(Mod).All_Location_Amps';
    Max_DeltaFF0=QuaSOR_Data.Modality(Mod).All_Max_DeltaFF0';
    Mean_DeltaFF0Trace_Max=QuaSOR_Data.Modality(Mod).All_Max_DeltaFF0_MeanTrace';
    Event_Type=QuaSOR_Data.Modality(Mod).EventType';
    Treatments=QuaSOR_Data.Modality(Mod).Treatment';
else
    X_Coord=[];
    Y_Coord=[];
    Episode_Frame=[];
    Overall_Frame=[];
    Stimulus=[];
    Episode=[];
    Corr_Amp=[];
    Max_DeltaFF0=[];
    Mean_DeltaFF0Trace_Max=[];
    Event_Type=[];
    Treatments=[];
end
QuaSOR_Data.Modality(Mod).EventTable=table(Event_Type,X_Coord,Y_Coord,Episode,Episode_Frame,Overall_Frame,Stimulus,Corr_Amp,Max_DeltaFF0,Mean_DeltaFF0Trace_Max,Treatments);
if exist([TableDir,TableName,'.xlsx'])
    delete([TableDir,TableName,'.xlsx'])
end
writetable(QuaSOR_Data.Modality(Mod).EventTable,[TableDir,TableName,'.xlsx'])
fprintf('Finished!\n');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FigName=[StackSaveName,' All Pooled QuaSOR Event Amplitude Comparisons'];
figure
h(1)=subplot(1,3,1);
plot([0,QuaSOR_Data.OverallMaxDeltaFF0],[0,QuaSOR_Data.OverallMaxDeltaFF0],'-','color','r','linewidth',0.5);
hold on
plot(QuaSOR_Data.All_Max_DeltaFF0,QuaSOR_Data.All_Location_Amps,'.','color','k','markersize',10)
axis equal tight
xlim([0,QuaSOR_Data.OverallMaxDeltaFF0])
xlabel('Max DeltaF/F');
ylim([0,QuaSOR_Data.OverallMaxDeltaFF0])
ylabel('Max CorrAmp');
h(2)=subplot(1,3,2);
plot([0,QuaSOR_Data.OverallMaxDeltaFF0],[0,QuaSOR_Data.OverallMaxDeltaFF0],'-','color','r','linewidth',0.5);
hold on
plot(QuaSOR_Data.All_Max_DeltaFF0_MeanTrace,QuaSOR_Data.All_Location_Amps,'.','color','k','markersize',10)
axis equal tight
xlim([0,QuaSOR_Data.OverallMaxDeltaFF0])
xlabel('Mean DeltaF/F Trace Max');
ylim([0,QuaSOR_Data.OverallMaxDeltaFF0])
ylabel('Max CorrAmp');
h(3)=subplot(1,3,3);
plot([0,QuaSOR_Data.OverallMaxDeltaFF0],[0,QuaSOR_Data.OverallMaxDeltaFF0],'-','color','r','linewidth',0.5);
hold on
plot(QuaSOR_Data.All_Max_DeltaFF0,QuaSOR_Data.All_Max_DeltaFF0_MeanTrace,'.','color','k','markersize',10)
axis equal tight
xlim([0,QuaSOR_Data.OverallMaxDeltaFF0])
xlabel('Max DeltaF/F');
ylim([0,QuaSOR_Data.OverallMaxDeltaFF0])
ylabel('Mean DeltaF/F Trace Max');
set(gcf,'position',[0,0,1800,800]);
Full_Export_Fig(gcf,h,Check_Dir_and_File(FigureScratchDir,FigName,[],1),1)
clear h
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MaxAmp=0;
MinAmp=1000000;
for Mod=1:length(QuaSOR_Data.Modality)
    if ~isempty(QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_Mean)
        MaxAmp=max([MaxAmp,max(QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_Mean(:))+...
            max(QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_SEM(:))]);
        MinAmp=min([MinAmp,min(QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_Mean(:))-...
            max(QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_SEM(:))]);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FigName=[StackSaveName,' Pooled Mean Event Traces'];
figure
for Mod=1:length(QuaSOR_Data.Modality)
    if ~isempty(QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_Mean)
        h(Mod)=subplot(1,2,Mod);
        lineProps.col{1}='k';
        lineProps.style='-';
        lineProps.width=0.5;
        xdata=[1:size(QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_Mean,2)]*(1000/ImagingInfo.ImagingFrequency);
        mseb(xdata,...
            QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_Mean,...
            QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces_SEM,...
            lineProps,0);
        xlim([0,max(xdata)])
        xlabel('Time (ms)');
        ylim([MinAmp,MaxAmp])
        ylabel(['Mean DeltaF/F (SEM)']);
        title([QuaSOR_Data.Modality(Mod).Label,' (n=',num2str(size(QuaSOR_Data.Modality(Mod).All_DeltaFF0_MeanTraces,1)),')'])
    end
end
set(gcf,'position',[0,0,1000,600]);
Full_Export_Fig(gcf,h,Check_Dir_and_File(FigureScratchDir,FigName,[],1),1)
clear h
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mod=1;
if size(QuaSOR_Data.Modality(Mod).All_Location_Coords,1)>0
    TableName=[StackSaveName,' Auto AZ ',QuaSOR_Data.Modality(Mod).Label,' QuaSOR Raster by Stim'];
    fprintf(['Exporting: ',TableName,'...']);
    TotalNumStim=ImagingInfo.NumEpisodes*ImagingInfo.StimuliPerEpisode;
    ZeroRaster=...
    zeros(TotalNumStim,1,'logical');
    QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).Evoked_Stim_Raster=...
    zeros(TotalNumStim,length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct));
    %AZ_Nums=horzcat(AZ_Nums,{'AZ'});
    clear AZ_Nums
    AZ_Nums={};
    for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct)
        AZ_Nums=horzcat(AZ_Nums,[num2str(AZ)]);
    end
    for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct)
        if ~isempty(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Location_Coords_byEpisodeNum)
            TempAZEpisodes=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Location_Coords_byEpisodeNum(:,3)';
        end
        if ~isempty(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Location_Coords_byOverallStim)
            TempAZStim=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Location_Coords_byOverallStim(:,3)';
            TempAZStim(TempAZStim==0)=[];
        else
            TempAZStim=[];
        end
        TempRaster=ZeroRaster;
        if ~isempty(TempAZStim)
            TempRaster(TempAZStim)=1;
        end
        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).AZRaster=TempRaster;
        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).Evoked_Stim_Raster(:,AZ)=TempRaster;
        clear TempRaster
    end
    figure, imagesc(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).Evoked_Stim_Raster)
    clear EvokedStimRasterTable
    EvokedStimRasterTable=[];
    for AZ=1:length(AZ_Nums)
    clear AZTable AZCell
    AZCell=[];
    AZCell=num2cell(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).Evoked_Stim_Raster(:,AZ));
    %AZCell=vertcat({['AZ',num2str(AZ)]},AZCell);
    AZTable=table(AZCell);
    AZTable.Properties.VariableNames={['AZ',AZ_Nums{AZ}]};
    EvokedStimRasterTable=horzcat(EvokedStimRasterTable,AZTable);
    end
    clear EpisodeTable EpisodeCell
    clear TreatmentTable TreatmentCell
    clear StimTable StimCell
    clear OverallStimTable OverallStimCell
    clear QCTable QCCell
    for s=1:TotalNumStim
    Treatment=' ';
    if ~isempty(MarkerSetInfo.Markers)
        for Marker=1:length(MarkerSetInfo.Markers)
            if any(s/ImagingInfo.StimuliPerEpisode==[MarkerSetInfo.Markers(Marker).MarkerStart:MarkerSetInfo.Markers(Marker).MarkerEnd])
                Treatment=[Treatment,MarkerSetInfo.Markers(Marker).MarkerShortLabel];
            end
        end
    end
    TreatmentCell{s,1}=Treatment;
    OverallStimCell{s,1}=s;
    QCCell{s,1}=sum(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).Evoked_Stim_Raster(s,:));
    EpisodeCell{s,1}=ceil(s/ImagingInfo.StimuliPerEpisode);
    StimCell{s,1}=s-(ceil(s/ImagingInfo.StimuliPerEpisode)-1)*ImagingInfo.StimuliPerEpisode;
    end
    TreatmentTable=table(TreatmentCell);
    TreatmentTable.Properties.VariableNames={'Treatment'};
    StimTable=table(StimCell);
    StimTable.Properties.VariableNames={'Episode_Stim'};
    OverallStimTable=table(OverallStimCell);
    OverallStimTable.Properties.VariableNames={'Overall_Stim'};
    EpisodeTable=table(EpisodeCell);
    EpisodeTable.Properties.VariableNames={'Episode'};
    QCTable=table(QCCell);
    QCTable.Properties.VariableNames={'Quantal_Content'};

    clear RasterTable
    RasterTable=[];
    RasterTable=horzcat(RasterTable,EpisodeTable);
    RasterTable=horzcat(RasterTable,StimTable);
    RasterTable=horzcat(RasterTable,TreatmentTable);
    RasterTable=horzcat(RasterTable,OverallStimTable);
    RasterTable=horzcat(RasterTable,QCTable);
    RasterTable=horzcat(RasterTable,EvokedStimRasterTable);

    if exist([TableDir,TableName,'.xlsx'])
    delete([TableDir,TableName,'.xlsx'])
    end
    writetable(RasterTable,[TableDir,TableName,'.xlsx'])
    fprintf('Finished!\n');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for Mod=1:length(QuaSOR_Data.Modality)      
    if size(QuaSOR_Data.Modality(Mod).All_Location_Coords,1)>0
        TableName=[StackSaveName,' Auto AZ ',QuaSOR_Data.Modality(Mod).Label,' QuaSOR Raster by Frame'];
        fprintf(['Exporting: ',TableName,'...']);
        clear FrameLabels
        ZeroRaster=...
            zeros(ImagingInfo.TotalNumFrames,1,'logical');
        QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).Frame_Raster=...
            zeros(ImagingInfo.TotalNumFrames,length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct));
        %AZ_Nums=horzcat(AZ_Nums,{'AZ'});
        clear AZ_Nums
        AZ_Nums={};
        for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct)
            AZ_Nums=horzcat(AZ_Nums,[num2str(AZ)]);
        end
        for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct)
            if ~isempty(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Location_Coords_byOverallFrame)
                TempAZFrames=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).All_Location_Coords_byOverallFrame(:,3)';
                TempAZFrames(TempAZFrames==0)=[];
            else
                TempAZFrames=[];
            end
            TempRaster=ZeroRaster;
            if ~isempty(TempAZFrames)
                TempRaster(TempAZFrames)=1;
            end
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct(AZ).AZRaster=TempRaster;
            QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).Frame_Raster(:,AZ)=TempRaster;
            clear TempRaster
        end
        figure, imagesc(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).Frame_Raster)
        clear FrameRasterTable
        FrameRasterTable=[];
        for AZ=1:length(AZ_Nums)
            clear AZTable AZCell
            AZCell=[];
            AZCell=num2cell(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).Frame_Raster(:,AZ));
            %AZCell=vertcat({['AZ',num2str(AZ)]},AZCell);
            AZTable=table(AZCell);
            AZTable.Properties.VariableNames={['AZ',AZ_Nums{AZ}]};
            FrameRasterTable=horzcat(FrameRasterTable,AZTable);
        end

        clear EpisodeTable EpisodeCell
        clear TreatmentTable TreatmentCell
        clear StimTable StimCell
        clear OverallStimTable OverallStimCell
        clear FrameTable FrameCell
        clear OverallFrameTable OverallFrameCell
        clear QCTable QCCell
        for f=1:ImagingInfo.TotalNumFrames
            OverallFrameCell{f,1}=f;
            QCCell{f,1}=sum(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).Frame_Raster(f,:));
            CurrentEpisode=ceil(f/ImagingInfo.FramesPerEpisode);
            EpisodeCell{f,1}=CurrentEpisode;
            EpisodeFrame=f-(ceil(f/ImagingInfo.FramesPerEpisode)-1)*ImagingInfo.FramesPerEpisode;
            FrameCell{f,1}=EpisodeFrame;
            Treatment=' ';
            if ~isempty(MarkerSetInfo.Markers)
                for Marker=1:length(MarkerSetInfo.Markers)
                    if any(CurrentEpisode==[MarkerSetInfo.Markers(Marker).MarkerStart:MarkerSetInfo.Markers(Marker).MarkerEnd])
                        Treatment=[Treatment,MarkerSetInfo.Markers(Marker).MarkerShortLabel];
                    end
                end
            end
            TreatmentCell{f,1}=Treatment;
            OverallStimCell{f,1}=' ';
            StimCell{f,1}=' ';
            for s=1:length(ImagingInfo.StimInfo)
                if any(ImagingInfo.StimInfo(s).IntraEpisode_StimulusSortingFrames==EpisodeFrame)
                    OverallStimCell{f,1}=s+(CurrentEpisode-1)*ImagingInfo.StimuliPerEpisode;
                    StimCell{f,1}=s;
                end
            end
        end
        FrameTable=table(FrameCell);
        FrameTable.Properties.VariableNames={'Episode_Frame'};
        OverallFrameTable=table(OverallFrameCell);
        OverallFrameTable.Properties.VariableNames={'Overall_Frame'};
        TreatmentTable=table(TreatmentCell);
        TreatmentTable.Properties.VariableNames={'Treatment'};
        EpisodeTable=table(EpisodeCell);
        EpisodeTable.Properties.VariableNames={'Episode'};
        QCTable=table(QCCell);
        QCTable.Properties.VariableNames={'Quantal_Content'};
        StimTable=table(StimCell);
        StimTable.Properties.VariableNames={'Episode_Stim'};
        OverallStimTable=table(OverallStimCell);
        OverallStimTable.Properties.VariableNames={'Overall_Stim'};

        clear RasterTable
        RasterTable=[];
        RasterTable=horzcat(RasterTable,EpisodeTable);
        RasterTable=horzcat(RasterTable,FrameTable);
        RasterTable=horzcat(RasterTable,StimTable);
        RasterTable=horzcat(RasterTable,TreatmentTable);
        RasterTable=horzcat(RasterTable,OverallStimTable);
        RasterTable=horzcat(RasterTable,OverallFrameTable);
        RasterTable=horzcat(RasterTable,FrameRasterTable);

        if exist([TableDir,TableName,'.xlsx'])
            delete([TableDir,TableName,'.xlsx'])
        end
        writetable(RasterTable,[TableDir,TableName,'.xlsx'])
        fprintf('Finished!\n');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TableName=[StackSaveName,' Auto AZ Mean DeltaFF0 by Frame'];
fprintf(['Exporting: ',TableName,'...']);
Mod=1;
clear FrameLabels
ZeroDeltaFF0=...
zeros(ImagingInfo.TotalNumFrames,1,'logical');
%AZ_Nums=horzcat(AZ_Nums,{'AZ'});
clear AZ_Nums
AZ_Nums={};
for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct)
AZ_Nums=horzcat(AZ_Nums,[num2str(AZ)]);
end
for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).AZ_Struct)
QuaSOR_Auto_AZ.QuaSOR_AutoQuant.All_DeltaFF0(:,AZ)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZ_Struct(AZ).DeltaFF0_MeanTrace';
end

figure, imagesc(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.All_DeltaFF0)
clear DeltaFF0Table
DeltaFF0Table=[];
for AZ=1:length(AZ_Nums)
clear AZTable AZCell
AZCell=[];
AZCell=num2cell(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.All_DeltaFF0(:,AZ));
%AZCell=vertcat({['AZ',num2str(AZ)]},AZCell);
AZTable=table(AZCell);
AZTable.Properties.VariableNames={['AZ',AZ_Nums{AZ}]};
DeltaFF0Table=horzcat(DeltaFF0Table,AZTable);
end

clear EpisodeTable EpisodeCell
clear TreatmentTable TreatmentCell
clear StimTable StimCell
clear OverallStimTable OverallStimCell
clear FrameTable FrameCell
clear OverallFrameTable OverallFrameCell
clear FrameEventCountTable FrameEventCountCell
for f=1:ImagingInfo.TotalNumFrames
    OverallFrameCell{f,1}=f;
    TempSum=0;
    for Mod=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality)
        if size(QuaSOR_Data.Modality(Mod).All_Location_Coords,1)>0
            TempSum=TempSum+sum(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).Frame_Raster(f,:));
        end
    end
    FrameEventCountCell{f,1}=TempSum;
    CurrentEpisode=ceil(f/ImagingInfo.FramesPerEpisode);
    EpisodeCell{f,1}=CurrentEpisode;
    EpisodeFrame=f-(ceil(f/ImagingInfo.FramesPerEpisode)-1)*ImagingInfo.FramesPerEpisode;
    FrameCell{f,1}=EpisodeFrame;
    Treatment=' ';
    if ~isempty(MarkerSetInfo.Markers)
        for Marker=1:length(MarkerSetInfo.Markers)
            if any(CurrentEpisode==[MarkerSetInfo.Markers(Marker).MarkerStart:MarkerSetInfo.Markers(Marker).MarkerEnd])
                Treatment=[Treatment,MarkerSetInfo.Markers(Marker).MarkerShortLabel];
            end
        end
    end
    TreatmentCell{f,1}=Treatment;
    OverallStimCell{f,1}=' ';
    StimCell{f,1}=' ';
    for s=1:length(ImagingInfo.StimInfo)
        if any(ImagingInfo.StimInfo(s).IntraEpisode_StimulusSortingFrames==EpisodeFrame)
            OverallStimCell{f,1}=s+(CurrentEpisode-1)*ImagingInfo.StimuliPerEpisode;
            StimCell{f,1}=s;
        end
    end
end
FrameTable=table(FrameCell);
FrameTable.Properties.VariableNames={'Episode_Frame'};
OverallFrameTable=table(OverallFrameCell);
OverallFrameTable.Properties.VariableNames={'Overall_Frame'};
TreatmentTable=table(TreatmentCell);
TreatmentTable.Properties.VariableNames={'Treatment'};
EpisodeTable=table(EpisodeCell);
EpisodeTable.Properties.VariableNames={'Episode'};
FrameEventCountTable=table(FrameEventCountCell);
QCTable.Properties.VariableNames={'Num_Events'};
StimTable=table(StimCell);
StimTable.Properties.VariableNames={'Episode_Stim'};
OverallStimTable=table(OverallStimCell);
OverallStimTable.Properties.VariableNames={'Overall_Stim'};

clear RasterTable
RasterTable=[];
RasterTable=horzcat(RasterTable,EpisodeTable);
RasterTable=horzcat(RasterTable,FrameTable);
RasterTable=horzcat(RasterTable,StimTable);
RasterTable=horzcat(RasterTable,TreatmentTable);
RasterTable=horzcat(RasterTable,OverallStimTable);
RasterTable=horzcat(RasterTable,QCTable);
RasterTable=horzcat(RasterTable,OverallFrameTable);
RasterTable=horzcat(RasterTable,DeltaFF0Table);

if exist([TableDir,TableName,'.xlsx'])
delete([TableDir,TableName,'.xlsx'])
end
writetable(RasterTable,[TableDir,TableName,'.xlsx'])
fprintf('Finished!\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TableName=[StackSaveName,' Auto AZ Stats'];
fprintf(['Exporting: ',TableName,'...']);
ColumnTitles={};
AllAZData=[];
for AZ=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.AZ_Struct)
    ColumnPos=0;
    ColumnPos=ColumnPos+1;
    if AZ==1
        ColumnTitles{ColumnPos}='AZNum';
    end
    AllAZData(AZ,ColumnPos)=AZ;
    ColumnPos=ColumnPos+1;
    if AZ==1
        ColumnTitles{ColumnPos}='XCoord';
    end
    AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord_Round(1);
    ColumnPos=ColumnPos+1;
    if AZ==1
        ColumnTitles{ColumnPos}='YCoord';
    end
    AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.AZ_Struct(AZ).Coord_Round(2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for Mod=1:length(QuaSOR_Data.Modality)      
        ColumnPos=ColumnPos+1;
        if AZ==1
            ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.ShortLabel,'_Count'];
        end
        AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_EventCount(AZ);
        ColumnPos=ColumnPos+1;
        if AZ==1
            ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.ShortLabel,'_MeanCorrAmp'];
        end
        AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Mean_Amp(AZ);
        ColumnPos=ColumnPos+1;
        if AZ==1
            ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.ShortLabel,'_MeanDFF'];
        end
        AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Mean_DeltaFF0(AZ);
        if Mod==1
            ColumnPos=ColumnPos+1;
            if AZ==1
                ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.ShortLabel,'_Pr'];
            end
            AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Pr(AZ);
        elseif Mod==2
            ColumnPos=ColumnPos+1;
            if AZ==1
                ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.ShortLabel,'_Fs'];
            end
            AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).OverallAZStats.AZ_Fs(AZ);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for Mod=1:length(QuaSOR_Data.Modality)      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for Treatment=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats)
            ColumnPos=ColumnPos+1;
            if AZ==1
                ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).ShortLabel,'_Count'];
            end
            AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_EventCount(AZ);
        end
        for Treatment=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats)
            ColumnPos=ColumnPos+1;
            if AZ==1
                ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).ShortLabel,'_MeanCorrAmp'];
            end
            AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Mean_Amp(AZ);
        end
        for Treatment=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats)
            ColumnPos=ColumnPos+1;
            if AZ==1
                ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).ShortLabel,'_MeanDFF'];
            end
            AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Mean_DeltaFF0(AZ);
        end
        if Mod==1
            for Treatment=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats)
                ColumnPos=ColumnPos+1;
                if AZ==1
                    ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).ShortLabel,'_Pr'];
                end
                AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Pr(AZ);
            end
        elseif Mod==2
            for Treatment=1:length(QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats)
                ColumnPos=ColumnPos+1;
                if AZ==1
                    ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).ShortLabel,'_Fs'];
                end
                AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).TreatmentAZStats(Treatment).AZ_Fs(AZ);
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for Mod=1:length(QuaSOR_Data.Modality)      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for Ep=1:TempNumEpisodes
            ColumnPos=ColumnPos+1;
            if AZ==1
                ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).ShortLabel,'_Count'];
            end
            AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_EventCount(AZ);
        end
        for Ep=1:TempNumEpisodes
            ColumnPos=ColumnPos+1;
            if AZ==1
                ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).ShortLabel,'_MeanCorrAmp'];
            end
            AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Mean_Amp(AZ);
        end
        for Ep=1:TempNumEpisodes
            ColumnPos=ColumnPos+1;
            if AZ==1
                ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).ShortLabel,'_MeanDFF'];
            end
            AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Mean_DeltaFF0(AZ);
        end
        if Mod==1
            for Ep=1:TempNumEpisodes
                ColumnPos=ColumnPos+1;
                if AZ==1
                    ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).ShortLabel,'_Pr'];
                end
                AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Pr(AZ);
            end
        elseif Mod==2
            for Ep=1:TempNumEpisodes
                ColumnPos=ColumnPos+1;
                if AZ==1
                    ColumnTitles{ColumnPos}=[QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).ShortLabel,'_Fs'];
                end
                AllAZData(AZ,ColumnPos)=QuaSOR_Auto_AZ.QuaSOR_AutoQuant.Quant_Modality(Mod).EpisodeAZStats(Ep).AZ_Fs(AZ);
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end
AllAZDataTable=[];
for col=1:size(AllAZData,2)
    TempColumn=table(AllAZData(:,col));
    AllAZDataTable=horzcat(AllAZDataTable,TempColumn);
    AllAZDataTable.Properties.VariableNames{col}=ColumnTitles{col};
end

if exist([TableDir,TableName,'.xlsx'])
    delete([TableDir,TableName,'.xlsx'])
end
writetable(AllAZDataTable,[TableDir,TableName,'.xlsx'])
fprintf('Finished!\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% 
%             %Some Alignment CHecking to go from QuaSOR High res back to
%             %Original resolution
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             EpisodeNumber_Load=5
%             fprintf(['Extracting Episode ',num2str(EpisodeNumber_Load),' Traces...'])
%             if SplitEpisodeFiles
%                 FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
%                 fprintf(['Loading: ',FileSuffix,'...'])
%                 load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
%                 EpisodeNumber=1;
%             else
%                 EpisodeNumber=EpisodeNumber_Load;
%             end
%             TempDeltaFF0=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaFF0;
%             size(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords,1)
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             TempEvent=5
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Temp.Coord=QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords(TempEvent,:);
%             Temp.Coord_Round=round(Temp.Coord);
%             Temp.Mask =    (DeltaFF0_Row - Temp.Coord_Round(1)).^2 + ...
%                 (DeltaFF0_Col - Temp.Coord_Round(2)).^2 <= ...
%                 2.^2;
%             Temp.Mask=logical(Temp.Mask);
%             Temp.Point = zeros(size(Temp.Mask));
%             Temp.Point(Temp.Coord_Round(1),Temp.Coord_Round(2))=1;
%             Temp.TraceFrames=[Temp.Coord(3)-QuaSOR_Event_Extraction_Settings.PreTraceFrames:Temp.Coord(3)+QuaSOR_Event_Extraction_Settings.PostTraceFrames];
%             if length(Temp.TraceFrames)>size(TempDeltaFF0,3)
%                 Temp.TraceFrames=[1:size(TempDeltaFF0,3)];
%             end
%             figure, imshow(Temp.Mask)
%             TempStack=TempDeltaFF0(:,:,Temp.TraceFrames);
%             TempStackMasked=TempDeltaFF0(:,:,Temp.TraceFrames);
%             TempStackMasked2=TempDeltaFF0(:,:,Temp.TraceFrames);
%             for t=1:length(Temp.TraceFrames)
%                TempStackMasked(:,:,t)=TempStackMasked(:,:,t).*Temp.Mask; 
%                TempStackMasked2(:,:,t)=TempStackMasked(:,:,t).*Temp.Point; 
%             end
%             %TempStackMasked(TempStackMasked==0)=NaN;
%             %TempStackMasked2(TempStackMasked2==0)=NaN;
%             TempDisplay=[];
%             TempDisplay=cat(4,TempStack,TempStackMasked);
%             TempDisplay=cat(4,TempDisplay,TempStackMasked2);
%             Temp.Coord
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             close all
%             Stack_Viewer(TempDisplay,AllBoutonsRegion,'YXTC');
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Mod=1
%             QuantMod=1
%             for AZ=1:length(QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(2).AZ_Struct)
%                 disp([num2str(AZ),' ',num2str(QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).EventCount)])
%             end
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             AZ=12
%             QuaSOR_Auto_AZ.Modality(Mod).QuaSOR_AutoQuant.Quant_Modality(QuantMod).AZ_Struct(AZ).All_Location_Coords_byOverallFrame
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             EpisodeNumber_Load=12
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             fprintf(['Extracting Episode ',num2str(EpisodeNumber_Load),' Traces...'])
%             if SplitEpisodeFiles
%                 FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber_Load),'.mat'];
%                 fprintf(['Loading: ',FileSuffix,'...'])
%                 load([CurrentScratchDir,StackSaveName,FileSuffix],'EpisodeStruct')
%                 EpisodeNumber=1;
%             else
%                 EpisodeNumber=EpisodeNumber_Load;
%             end
%             TempDeltaFF0=EpisodeStruct(EpisodeNumber).ImageArrayReg_Episode_DeltaFF0;
%             size(QuaSOR_Data.Episode(EpisodeNumber_Load).All_Location_Coords,1)
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             AZ_Struct=QuaSOR_Auto_AZ.Modality(Mod).AZ_Struct;
%             TempMask=zeros(Image_Height,Image_Width,'uint16');
%             Temp.Coord_Orig=AZ_Struct(AZ).Coord;
%             Temp.Coord_Orig=round(Temp.Coord_Orig/QuaSOR_Parameters.UpScaling.QuaSOR_UpScaleFactor);
%             Temp.Mask =    (DeltaFF0_Row - Temp.Coord_Orig(2)).^2 + ...
%                 (DeltaFF0_Col - Temp.Coord_Orig(1)).^2 <= ...
%                 2.^2;
%             Temp.Mask=logical(Temp.Mask);
%             Temp.Point = zeros(size(Temp.Mask));
%             Temp.Point(Temp.Coord_Orig(2),Temp.Coord_Orig(1))=1;
%             Temp.TraceFrames=[1:size(TempDeltaFF0,3)];
%             figure, imshow(Temp.Mask)
%             TempStack=TempDeltaFF0(:,:,Temp.TraceFrames);
%             TempStackMasked=TempDeltaFF0(:,:,Temp.TraceFrames);
%             TempStackMasked2=TempDeltaFF0(:,:,Temp.TraceFrames);
%             for t=1:length(Temp.TraceFrames)
%                TempStackMasked(:,:,t)=TempStackMasked(:,:,t).*Temp.Mask; 
%                TempStackMasked2(:,:,t)=TempStackMasked2(:,:,t).*Temp.Point; 
%             end
%             TempDisplay=[];
%             TempDisplay=cat(4,TempStack,TempStackMasked);
%             TempDisplay=cat(4,TempDisplay,TempStackMasked2);
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             close all
%             Stack_Viewer(TempDisplay,AllBoutonsRegion,'YXTC');
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
