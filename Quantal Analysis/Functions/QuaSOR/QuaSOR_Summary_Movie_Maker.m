function MovieSuccess=QuaSOR_Summary_Movie_Maker(StackSaveName,StackSaveNameSuffix,ImagingModality,PreviewIndices)

    
    
    close all
    [OS,dc,~,~,~,~,~,ScratchDir]=BatchStartup;
                        
    ScreenSize=get(0,'ScreenSize');

    warning on all
    warning off backtrace
    warning off verbose
    jheapcl
    CurrentDir=cd;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %StackSaveName='CpxRNAi_42017_OK6_GC6_25C_MiniMiniEvoked_2_Ib_Mini';
    %StackSaveName='OK6_Dcr2 Unc13RNAi_GC6_25C_MiniEvoked8_1_Ib_MiniEvoked';
    %StackSaveName='OK6_UAS_Munc13_RNAi_29548_Dcr2_GC6_29C_FreqCompTest_1_Ib_01Hz'
    %StackSaveName='OK6_UAS_Munc13_RNAi_29548_Dcr2_GC6_29C_FreqCompTest_1_Ib'
    %StackSaveNameSuffix='_5Hz10s';
    %Spont
    %ImagingModality=2;
    %PreviewIndices=[1];
    %ImagingModality=1;
    %PreviewIndices=[];    
    try
        BufferFrames=2;
        EventCircleBufferFrames=4;
        if any(strfind(OS,'MACI64'))
            warning('Using Mac Defaults...')
            BorderThickness=1;
            BorderColor='w';
            LabelFontSize=12;
            LabelFontSize1=10;
            UpScaleFilterSize=21;
            UpScaleFilterSigma=5;
            EventCircleColor='m';
            EventCircleLineWidth=1;
            EventCircleRadius=10;
            MovieScaleFactor=1.5;
            TextColor='y';
            TextOffset=10;
        else
            warning('Using PC Defaults...')
            BorderThickness=1;
            BorderColor='w';
            LabelFontSize=10;
            LabelFontSize1=8;
            UpScaleFilterSize=21;
            UpScaleFilterSigma=5;
            EventCircleColor='m';
            EventCircleLineWidth=1;
            EventCircleRadius=10;
            MovieScaleFactor=2;
            TextColor='y';
            TextOffset=8;
        end
        if ImagingModality==4
            warning('Using In vivo Presets...')
            BorderThickness=1;
            BorderColor='w';
            LabelFontSize=12;
            LabelFontSize1=10;
            UpScaleFilterSize=21;
            UpScaleFilterSigma=5;
            EventCircleColor='m';
            EventCircleLineWidth=1;
            EventCircleRadius=8;
            MovieScaleFactor=2;
            TextColor='y';
            TextOffset=8;
            MovieFPS=25;
            MovieQuality=90;
            F_HighPercent=0.25;
            F_LowPercent=0.6;
            DeltaF_HighPercent=-0.5;
            DeltaF_LowPercent=0;
            DeltaFF0_HighPercent=-0.5;
            DeltaFF0_LowPercent=0;    
        else
            MovieFPS=20;
            MovieQuality=90;
            F_HighPercent=-0.3;
            F_LowPercent=0;
            DeltaF_HighPercent=-0.75;
            DeltaF_LowPercent=0;
            DeltaFF0_HighPercent=-0.75;
            DeltaFF0_LowPercent=0;    
        end
        AdjustmentBuffer=0.2;
        QuaSOR_HighPercent=-0.8;
        BorderLineAdjustment=0;
        EventCircleLineStyle='-';
        PreviewMovieName=' QuaSOR Summary Preview.avi';
        FullMovieName=' QuaSOR Summary.avi';
        MovieSaveDir=['QuaSOR Movies'];
        if ~exist(MovieSaveDir)
            mkdir(MovieSaveDir)
        end
        Visibility=1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ImagingModality==2||ImagingModality==4
            disp(['Loading: ',StackSaveName,StackSaveNameSuffix,'_ContinuousImagingAnalysis.mat'])
            load([StackSaveName,StackSaveNameSuffix,'_ContinuousImagingAnalysis.mat'])
            clear ImageArrayReg_FirstImages ImageArray_FirstImages clear ScratchDir
            [OS,dc,~,~,~,~,~,ScratchDir]=BatchStartup;
        elseif ImagingModality==3
            disp(['Loading: ',StackSaveName,StackSaveNameSuffix,'_HighFreqContinuousImagingAnalysis.mat'])
            load([StackSaveName,StackSaveNameSuffix,'_HighFreqContinuousImagingAnalysis.mat'])
            clear ImageArrayReg_FirstImages ImageArray_FirstImages clear ScratchDir
            [OS,dc,~,~,~,~,~,ScratchDir]=BatchStartup;
        elseif ImagingModality==1
            disp(['Loading: ',StackSaveName,StackSaveNameSuffix,'_First.mat'])
            load([StackSaveName,StackSaveNameSuffix,'_First.mat'])
            load([StackSaveName,StackSaveNameSuffix,'_GFPs_1.mat'],'AllBoutonsRegion')
            clear ImageArrayReg_FirstImages ImageArray_FirstImages clear ScratchDir
            [OS,dc,~,~,~,~,~,ScratchDir]=BatchStartup;
        end
        if exist([StackSaveName,StackSaveNameSuffix,'_SOQA_EventLocations2.mat'])
            disp(['Loading: ',StackSaveName,StackSaveNameSuffix,'_SOQA_EventLocations2.mat'])
            load([StackSaveName,StackSaveNameSuffix,'_SOQA_EventLocations2.mat'],...
                'All_Location_Coords',...
                'OneImage_NoStim_SOQA_Upscale_Sharp_Prob_Filt','OneImage_NoStim_SOQA_Upscale_Sharp_Prob',...
                'OneImage_HighFreq_SOQA_Upscale_Sharp_Prob_Filt','OneImage_HighFreq_SOQA_Upscale_Sharp_Prob',...
                'OneImage_WithStim_SOQA_Upscale_Sharp_Prob_Filt','OneImage_WithStim_SOQA_Upscale_Sharp_Prob')
        elseif exist([StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat'])
            disp(['Loading: ',StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat'])
            load([StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat'],...
                'All_Location_Coords',...
                'OneImage_NoStim_SOQA_Upscale_Sharp_Prob_Filt','OneImage_NoStim_SOQA_Upscale_Sharp_Prob',...
                'OneImage_HighFreq_SOQA_Upscale_Sharp_Prob_Filt','OneImage_HighFreq_SOQA_Upscale_Sharp_Prob',...
                'OneImage_WithStim_SOQA_Upscale_Sharp_Prob_Filt','OneImage_WithStim_SOQA_Upscale_Sharp_Prob')
        else
            warning('Missing All_Location_Coords!')
            warning('Missing All_Location_Coords!')
            warning('Missing All_Location_Coords!')
            warning('Missing All_Location_Coords!')
            error('Missing All_Location_Coords!')
        end
        
        load([StackSaveName,StackSaveNameSuffix '_ScaleBar.mat'])

        LoadTimer=tic;
        disp(['ScratchDir: ',ScratchDir]);
        fprintf('Trying to Copy _SOQA_Data2 File to Scratch Dir...')
        [CopyStatus,CopyMessage]=copyfile([StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat'],ScratchDir);
        if CopyStatus
            fprintf('Copy successful!\n')
            fprintf('Loading SOQA_Data from ScratchDir...')
            load([ScratchDir,StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat'],...
                'SOQA_Data','ZerosImage_Upscale')
            load([ScratchDir,StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat'],...
                'XOffset','YOffset','BorderLine_Upscale','ScaleBar_Upscale',...
                'UpScale_CoordinateAdjust','UpScaleRatio','x2','y2','X2','Y2');
            fprintf('Finished!\n')
        else
            warning(CopyMessage)
            warning(['Unable to Copy ',StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat...Loading from server copy'])
            fprintf('Loading SOQA_Data from Server...')
            load([StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat'],...
                'SOQA_Data','ZerosImage_Upscale');
            load([StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat'],...
                'XOffset','YOffset','BorderLine_Upscale','ScaleBar_Upscale',...
                'UpScale_CoordinateAdjust','UpScaleRatio','x2','y2','X2','Y2');
        end
        LoadTime=toc(LoadTimer);
        FileInfo=dir([ScratchDir,StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat']);
        warning on
        warning([StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat = ',...
            num2str(round(FileInfo.bytes/(1e9)*10)/10),'GB (Loaded @ ',...
            num2str(round((FileInfo.bytes/(1e6))/LoadTime*10)/10),' MB/s)'])
        if any(strfind(StackSaveName,'I_Mini'))
           warning('Post-MiniEvoked Split Mini Data fixing NumSequences...')
           warning('Post-MiniEvoked Split Mini Data fixing NumSequences...')
           warning('Post-MiniEvoked Split Mini Data fixing NumSequences...')
           warning('Post-MiniEvoked Split Mini Data fixing NumSequences...')
           NumSequences=1
        end
        ZerosImage_Upscale=logical(ZerosImage_Upscale);
        if ~exist('YOffset')
            warning('Missing XOffset and YOffset...Using Defaults...')
            warning('Missing XOffset and YOffset...Using Defaults...')
            warning('Missing XOffset and YOffset...Using Defaults...')
            warning('Missing XOffset and YOffset...Using Defaults...')
            XOffset=-1
            YOffset=-1
        end
        if ~exist('X2')

            x2 = (1/UpScaleRatio):(1/UpScaleRatio):size(AllBoutonsRegion,2); y2 = (1/UpScaleRatio):(1/UpScaleRatio):size(AllBoutonsRegion,1);
            [X2,Y2] = meshgrid(x2,y2);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('Previewing Image Stack Data for all Indices...')
        progressbar('Previewing IndexNumber');
        F_Max=0;
        F_Min=2^16;
        DeltaF_Max=0;
        DeltaFF0_Max=0;
        if ImagingModality==2||ImagingModality==4
            for IndexNumber=1:NumSequences
                load([StackSaveName,StackSaveNameSuffix '_ImageArrayReg_AllImages_DeltaGFP_',num2str(IndexNumber)],...
                    'ImageArray_NoStim_CorrAmp_Clean_norm',...
                    'ImageArrayReg_AllImages_BC',...
                    'ImageArrayReg_AllImages_DeltaGFP');
                %WholeRecording_Structure(IndexNumber).BC_F_Stack=single(ImageArrayReg_AllImages_BC);
                %WholeRecording_Structure(IndexNumber).DeltaF_Stack=single(ImageArrayReg_AllImages_DeltaGFP);
                %WholeRecording_Structure(IndexNumber).CorrAmp_Stack=single(ImageArray_NoStim_CorrAmp_Clean_norm);
                %WholeRecording_Structure(IndexNumber).Max_Stack=logical(ImageArray_NoStim_Max_Sharp); 
                F_Max=max([F_Max,max(ImageArrayReg_AllImages_BC(:))]);
                F_Min=min([F_Min,min(ImageArrayReg_AllImages_BC(:))]);
                DeltaF_Max=max([DeltaF_Max,max(ImageArrayReg_AllImages_DeltaGFP(:))]);
                DeltaFF0_Max=max([DeltaFF0_Max,max(ImageArray_NoStim_CorrAmp_Clean_norm(:))]);

                progressbar(IndexNumber/NumSequences)
                clear ImageArray_NoStim_Max_Sharp ImageArray_NoStim_CorrAmp_Clean_norm Max_Image ImageArrayReg_AllImages_BC ImageArrayReg_AllImages_DeltaGFP
            end
        elseif ImagingModality==3
            IndexNumber=1;
            load([StackSaveName,StackSaveNameSuffix '_Results.mat'],...
                'ImageArrayReg_AllImages_BC','ImageArray_DeltaF');
            load([StackSaveName,StackSaveNameSuffix '_Results1.mat'],...
                'ImageArray_HighFreq_CorrAmp_Clean_norm',...
                'ImageArray_HighFreq_CorrAmp_thresh_norm')
            if ~exist('ImageArray_HighFreq_CorrAmp_Clean_norm')
                ImageArray_HighFreq_CorrAmp_Clean_norm=...
                    ImageArray_HighFreq_CorrAmp_thresh_norm;
                clear ImageArray_HighFreq_CorrAmp_thresh_norm
            end
            %WholeRecording_Structure(IndexNumber).BC_F_Stack=single(ImageArrayReg_AllImages_BC);
            %WholeRecording_Structure(IndexNumber).DeltaF_Stack=single(ImageArrayReg_AllImages_DeltaGFP);
            %WholeRecording_Structure(IndexNumber).CorrAmp_Stack=single(ImageArray_NoStim_CorrAmp_Clean_norm);
            %WholeRecording_Structure(IndexNumber).Max_Stack=logical(ImageArray_NoStim_Max_Sharp); 
            F_Max=max([F_Max,max(ImageArrayReg_AllImages_BC(:))]);
            F_Min=min([F_Min,min(ImageArrayReg_AllImages_BC(:))]);
            DeltaF_Max=max([DeltaF_Max,max(ImageArray_DeltaF(:))]);
            DeltaFF0_Max=max([DeltaFF0_Max,max(ImageArray_HighFreq_CorrAmp_Clean_norm(:))]);
            
            progressbar(1)
            clear ImageArrayReg_AllImages_BC ImageArray_DeltaF ImageArray_HighFreq_CorrAmp_Clean_norm ImageArray_HighFreq_CorrAmp_thresh_norm
        elseif ImagingModality==1
            for IndexNumber=1:LastIndexNumber
                load([StackSaveName,StackSaveNameSuffix '_GFPs_',num2str(IndexNumber)],...
                    'OneImage_WithStim_CorrAmp_norm',...
                    'ImageArrayRegBC_WithStim',...
                    'ImageArray_WithStim_DeltaGFP');
                %WholeRecording_Structure(IndexNumber).BC_F_Stack=single(ImageArrayReg_AllImages_BC);
                %WholeRecording_Structure(IndexNumber).DeltaF_Stack=single(ImageArrayReg_AllImages_DeltaGFP);
                %WholeRecording_Structure(IndexNumber).CorrAmp_Stack=single(ImageArray_NoStim_CorrAmp_Clean_norm);
                %WholeRecording_Structure(IndexNumber).Max_Stack=logical(ImageArray_NoStim_Max_Sharp); 
                F_Max=max([F_Max,max(ImageArrayRegBC_WithStim(:))]);
                F_Min=min([F_Min,min(ImageArrayRegBC_WithStim(:))]);
                DeltaF_Max=max([DeltaF_Max,max(ImageArray_WithStim_DeltaGFP(:))]);
                DeltaFF0_Max=max([DeltaFF0_Max,max(OneImage_WithStim_CorrAmp_norm(:))]);

                progressbar(IndexNumber/LastIndexNumber)
                clear ImageArray_WithStim_Max_Sharp OneImage_WithStim_CorrAmp_norm Max_Image ImageArrayRegBC_WithStim ImageArray_WithStim_DeltaGFP
            end
        end
        

        
        DilateRegion=ones(1);
        AllBoutonsRegionPerim=bwperim(AllBoutonsRegion);
        [BorderY_Crop BorderX_Crop] = find(AllBoutonsRegionPerim);
        if ~isempty(DilateRegion)
            [B,L] = bwboundaries(imdilate(AllBoutonsRegion,DilateRegion),'noholes');
        else
            [B,L] = bwboundaries(AllBoutonsRegion,'noholes');
        end
        for j=1:length(B)
            for k = 1:length(B{j})
                BorderLine{j}.BorderLine_Crop(k,:) = B{j}(k,:);
            end
        end
        fprintf('Finished!\n')
        disp('Finishing Prep Work!')
        F_Contrast=[F_Min+F_Max*F_LowPercent,F_Max+F_Max*F_HighPercent];
        DeltaF_Contrast=[0+DeltaF_Max*DeltaF_LowPercent,DeltaF_Max+DeltaF_Max*DeltaF_HighPercent];
        DeltaFF0_Contrast=[0+DeltaFF0_Max*DeltaFF0_LowPercent,DeltaFF0_Max+DeltaFF0_Max*DeltaFF0_HighPercent];
        LabelLocation=[ScaleBar.XData(1),ScaleBar.YData(1)-TextOffset];
        LabelLocation1=[ScaleBar.XData(1),ScaleBar.YData(1)-TextOffset*2];
        LabelLocation2=[ScaleBar.XData(1),ScaleBar.YData(1)-TextOffset*3];
        LabelLocation3=[ScaleBar_Upscale.XData(1),ScaleBar_Upscale.YData(1)-12*UpScaleRatio];
        ImageHeight=size(AllBoutonsRegion,1);
        ImageWidth=size(AllBoutonsRegion,2);
        disp(['ImageWidth = ',num2str(ImageWidth)])
        disp(['ImageHeight = ',num2str(ImageHeight)])
        disp(['Default MovieScaleFactor = ',num2str(MovieScaleFactor)])
        FigureSize=[ImageWidth*3*MovieScaleFactor,ImageHeight*2*MovieScaleFactor];
        disp(['Intial FigureSize = ',num2str(FigureSize(1)),' X ',num2str(FigureSize(2))])
        if FigureSize(2)*(1+AdjustmentBuffer)>ScreenSize(4)
            AdjustmentFactor=(ScreenSize(4)/FigureSize(2)-AdjustmentBuffer);
            warning(['Movie will be too tall! Adjusting MovieScaleFactor and Text Sizes by ',num2str(AdjustmentFactor)])
            MovieScaleFactor=MovieScaleFactor*AdjustmentFactor;
            LabelFontSize=ceil(LabelFontSize*AdjustmentFactor);
            LabelFontSize1=ceil(LabelFontSize1*AdjustmentFactor);
            TextOffset=ceil(TextOffset*AdjustmentFactor);
        end
        FigureSize=round([ImageWidth*3*MovieScaleFactor,ImageHeight*2*MovieScaleFactor]);
        disp(['MovieScaleFactor = ',num2str(MovieScaleFactor)])
        disp(['FigureSize = ',num2str(FigureSize(1)),' X ',num2str(FigureSize(2))])
        if ImagingModality==2||ImagingModality==4
            NumIndices=NumSequences;
        elseif ImagingModality==3
            NumIndices=1;
        elseif ImagingModality==1
            NumIndices=LastIndexNumber;
        end
        disp(['NumIndices = ',num2str(NumIndices)])
        disp('============================================')
        disp('============================================')
        disp('============================================')
        CurrentVariableMemoryUsage(whos,1e8)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        close all
        jheapcl

        %Safe Abort Figure
        f = figure('name',[StackSaveName,StackSaveNameSuffix]);
        set(gcf,'Units','normalized','Position',[0.7 0.75 0.3 0.1]);
        AbortButtonHandle = uicontrol('Units','Normalized','Position', [0.05 0.05 0.9 0.9],'style','push',...
            'string',['Abort: ',StackSaveName,StackSaveNameSuffix],'callback','set(gcbo,''userdata'',1,''string'',''Aborting!!'')', ...
            'userdata',0) ;  
        AbortedMovie=0;

        if ~isempty(PreviewIndices)
            disp('Initializing Preview Movie...')
            Preview_mov = VideoWriter([ScratchDir,StackSaveName,StackSaveNameSuffix, PreviewMovieName],'Motion JPEG AVI');
            Preview_mov.FrameRate = MovieFPS;  % Default 30
            Preview_mov.Quality = MovieQuality;    % Default 75
            open(Preview_mov);
        end

        disp('Initializing Full Record Movie...')
        Full_mov = VideoWriter([ScratchDir,StackSaveName,StackSaveNameSuffix, FullMovieName],'Motion JPEG AVI');
        Full_mov.FrameRate = MovieFPS;  % Default 30
        Full_mov.Quality = MovieQuality;    % Default 75
        open(Full_mov);
        
        MovieFig=figure('name',[StackSaveName,StackSaveNameSuffix]);
        set(MovieFig,'units','Pixels','position',[0,40,FigureSize]);
        set(MovieFig, 'color', 'white');
        if Visibility
        else
            set(MovieFig, 'visible', 'off');
            warning('Visibility is turned off so movie will be generated in background!!')
            warning('Visibility is turned off so movie will be generated in background!!')
            warning('Visibility is turned off so movie will be generated in background!!')
            warning('Visibility is turned off so movie will be generated in background!!')
            warning('Visibility is turned off so movie will be generated in background!!')
            warning('Visibility is turned off so movie will be generated in background!!')
            warning('Visibility is turned off so movie will be generated in background!!')
            warning('Visibility is turned off so movie will be generated in background!!')
            warning('Visibility is turned off so movie will be generated in background!!')
        end
        pause(0.001)
  
        disp('Its ShowTime!!!!!!!!!!!!')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SOQA_Upscale_Max_Sum=single(ZerosImage_Upscale);
        cont=1;
        IndexNumber=1;
        warning off
        while IndexNumber<=NumIndices && cont
            IndexTimer=tic;
            fprintf(['Processing Index # ',num2str(IndexNumber),'...'])
            fprintf('Loading Data...')
            if ImagingModality==2||ImagingModality==4
                load([StackSaveName,StackSaveNameSuffix '_ImageArrayReg_AllImages_DeltaGFP_',num2str(IndexNumber)],...
                    'ImageArray_NoStim_Max_Sharp','ImageArray_NoStim_CorrAmp_Clean_norm',...
                    'ImageArrayReg_AllImages_BC','ImageArrayReg_AllImages_DeltaGFP');
                BC_F_Stack=single(ImageArrayReg_AllImages_BC);
                DeltaF_Stack=single(ImageArrayReg_AllImages_DeltaGFP);
                CorrAmp_Stack=single(ImageArray_NoStim_CorrAmp_Clean_norm);

                CorrAmp_Stack_Temporal_Projection=zeros(size(CorrAmp_Stack));
                for z=BufferFrames+1:size(CorrAmp_Stack,3)-BufferFrames
                    CorrAmp_Stack_Temporal_Projection(:,:,z)=...
                       max(CorrAmp_Stack(:,:,[z-BufferFrames:z+BufferFrames]),[],3);
                end
                %Max_Stack=logical(ImageArray_NoStim_Max_Sharp); 
                clear CorrAmp_Stack
                clear ImageArray_NoStim_Max_Sharp ImageArray_NoStim_CorrAmp_Clean_norm Max_Image ImageArrayReg_AllImages_BC ImageArrayReg_AllImages_DeltaGFP

            elseif ImagingModality==3
                            
                load([StackSaveName,StackSaveNameSuffix '_Results.mat'],...
                    'ImageArrayReg_AllImages_BC','ImageArray_DeltaF');
                load([StackSaveName,StackSaveNameSuffix '_Results1.mat'],...
                    'ImageArray_HighFreq_CorrAmp_Clean_norm',...
                    'ImageArray_HighFreq_CorrAmp_thresh_norm')
                if ~exist('ImageArray_HighFreq_CorrAmp_Clean_norm')
                    ImageArray_HighFreq_CorrAmp_Clean_norm=...
                        ImageArray_HighFreq_CorrAmp_thresh_norm;
                    clear ImageArray_HighFreq_CorrAmp_thresh_norm
                end
                BC_F_Stack=single(ImageArrayReg_AllImages_BC);
                DeltaF_Stack=single(ImageArray_DeltaF);
                CorrAmp_Stack=single(ImageArray_HighFreq_CorrAmp_Clean_norm);

                CorrAmp_Stack_Temporal_Projection=zeros(size(CorrAmp_Stack));
                for z=BufferFrames+1:size(CorrAmp_Stack,3)-BufferFrames
                    CorrAmp_Stack_Temporal_Projection(:,:,z)=...
                       max(CorrAmp_Stack(:,:,[z-BufferFrames:z+BufferFrames]),[],3);
                end
                %Max_Stack=logical(ImageArray_NoStim_Max_Sharp); 
                clear CorrAmp_Stack
                clear ImageArray_HighFreq_CorrAmp_Clean_norm ImageArray_HighFreq_CorrAmp_thresh_norm ImageArray_DeltaF ImageArrayReg_AllImages_BC
                FramesPerSequence=size(DeltaF_Stack,3);

            
            elseif ImagingModality==1
                load([StackSaveName,StackSaveNameSuffix '_GFPs_',num2str(IndexNumber)],...
                    'OneImage_WithStim_CorrAmp_norm',...
                    'ImageArrayRegBC_WithStim',...
                    'ImageArray_WithStim_DeltaGFP');
                BC_F_Stack=single(ImageArrayRegBC_WithStim);
                DeltaF_Stack=single(ImageArray_WithStim_DeltaGFP);
                CorrAmp_Stack=single(OneImage_WithStim_CorrAmp_norm);
                CorrAmp_Stack_Temporal_Projection=zeros(size(CorrAmp_Stack,1),size(CorrAmp_Stack,2),ImagesPerSequence);
                for z=1:ImagesPerSequence
                    CorrAmp_Stack_Temporal_Projection(:,:,z)=...
                       CorrAmp_Stack;
                end
                clear ImageArray_WithStim_DeltaGFP ImageArrayRegBC_WithStim OneImage_WithStim_CorrAmp_norm CorrAmp_Stack
                FramesPerSequence=ImagesPerSequence;
            end
            
            %%%%%%%%%%%%%%
            if Visibility
                fprintf('Writing Data...')
            else
                fprintf('Writing Data In Background...')
            end
            ImageNumber=1;
            ImageCount=0;%Move above if you want running time
            if Visibility
                figure(MovieFig)
            else
                figure(MovieFig)
                clf
                pause(0.001);
                set(MovieFig, 'visible', 'off');
            end
            while ImageNumber<=FramesPerSequence && cont
                if Visibility
                    figure(MovieFig)
                else
                    %set(MovieFig, 'visible', 'off');
                    set(0,'CurrentFigure',MovieFig)
                end
                clf
                if ImagingModality==2||ImagingModality==3||ImagingModality==4
                    if (ImageCount/ImagingFrequency)/10<1
                        Buffer=['   '];
                    elseif (ImageCount/ImagingFrequency)/10>=1&&(ImageCount/ImagingFrequency)/100<1
                        Buffer=['  '];
                    elseif (ImageCount/ImagingFrequency)/100>=1&&(ImageCount/ImagingFrequency)/1000<1
                        Buffer=[' '];
                    elseif (ImageCount/ImagingFrequency)/1000>=1
                        Buffer=[''];
                    else
                        Buffer=['    '];
                    end
                    if rem((ImageCount/ImagingFrequency),1)==0
                        TimePoint=[num2str((ImageCount)*(1/ImagingFrequency)),'.00s'];
                    elseif rem((ImageCount/ImagingFrequency),0.1)==0
                        TimePoint=[num2str((ImageCount)*(1/ImagingFrequency)),'0s'];
                    else
                        TimePoint=[num2str((ImageCount)*(1/ImagingFrequency)),'s'];
                    end
                    TimePoint=[Buffer,TimePoint];
                else
                    TimePoint=[];
                end

                F_Image=BC_F_Stack(:,:,ImageNumber);
                DeltaF_Image=DeltaF_Stack(:,:,ImageNumber);
                DeltaFF0_Image=CorrAmp_Stack_Temporal_Projection(:,:,ImageNumber);

                F_Image=F_Image.*AllBoutonsRegion;
                DeltaF_Image=DeltaF_Image.*AllBoutonsRegion;
                DeltaFF0_Image=DeltaFF0_Image.*AllBoutonsRegion;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Remap all coordinates and gaussian fits (takes a little time)
                if ImagingModality==2||ImagingModality==3||ImagingModality==4
                    CoordinatesImage_Upscale=single(ZerosImage_Upscale);
                    SOQA_Upscale_Max_Sum_Filt=single(ZerosImage_Upscale);
                    ReconstructedFitImage_Upscale=single(ZerosImage_Upscale);
                    CurrentCoords=[];

                    %Highlight Coords
                    if ImageNumber>EventCircleBufferFrames&&ImageNumber<FramesPerSequence-EventCircleBufferFrames
                        for z=1:length(SOQA_Data)
                            if isempty(SOQA_Data(z).Successful_Fit)
                                SOQA_Data(z).Successful_Fit=0;
                            end
                            if      SOQA_Data(z).IndexNumber==IndexNumber&&...
                                    any(SOQA_Data(z).ImageNumber==[ImageNumber-EventCircleBufferFrames:ImageNumber+EventCircleBufferFrames])&&...
                                    SOQA_Data(z).Successful_Fit
                                for k=1:SOQA_Data(z).BestGaussianFitModel_Clean.NumComponents
                                    TempCoord=SOQA_Data(z).BestGaussianFitModel_Clean.mu_Fix(k,:);
                                    %TempCoord(1)=TempCoord(1)+YOffset;
                                    %TempCoord(2)=TempCoord(2)+XOffset;
                                    CurrentCoords=vertcat(CurrentCoords,round(TempCoord));
                                end
                            end
                        end
                    end
                    %Reconstruct Coords and fit and maps
                    if ImageNumber>BufferFrames&&ImageNumber<FramesPerSequence-BufferFrames
                        Max_Image=ZerosImage_Upscale;
                        for z=1:length(SOQA_Data)
                            if isempty(SOQA_Data(z).Successful_Fit)
                                SOQA_Data(z).Successful_Fit=0;
                            end
                            if      SOQA_Data(z).IndexNumber==IndexNumber&&...
                                    any(SOQA_Data(z).ImageNumber==[ImageNumber-BufferFrames:ImageNumber+BufferFrames])&&...
                                    SOQA_Data(z).Successful_Fit
                                for k=1:SOQA_Data(z).BestGaussianFitModel_Clean.NumComponents
                                    TempCoord=SOQA_Data(z).BestGaussianFitModel_Clean.mu_Fix(k,:);
                                    TempCoord(1)=TempCoord(1)+YOffset;
                                    TempCoord(2)=TempCoord(2)+XOffset;
                                    TestSigma=SOQA_Data(z).BestGaussianFitModel_Clean.Sigma(:,:,k);

                                    %Upscale Reconstruction
                                    temp1=TestSigma(1,1);
                                    temp2=TestSigma(2,2);
                                    TestSigma(1,1)=temp2;TestSigma(2,2)=temp1;
                                    clear temp1 temp2
                                    F2 = mvnpdf([X2(:) Y2(:)],fliplr(TempCoord),TestSigma);
                                    F2 = reshape(F2,length(y2),length(x2));
                                    F2=F2/max(F2(:))*SOQA_Data(z).BestGaussianFitModel_Clean.Amp(k);
                                    ReconstructedFitImage_Upscale=ReconstructedFitImage_Upscale+F2;
                                    clear F2

                                    %Max location reconstruction
                                    TempImage=ZerosImage_Upscale;
                                    TempCoord=round(TempCoord*UpScaleRatio)+UpScale_CoordinateAdjust*UpScaleRatio;
                                    if TempCoord(1)>0&&TempCoord(1)<=size(TempImage,1)&&TempCoord(2)>0&&TempCoord(2)<=size(TempImage,2)
                                        TempImage(TempCoord(1),TempCoord(2))=1;
                                        Max_Image=Max_Image+TempImage; 
                                    end
                                    clear TempImage

                    %                 %Normal Res reconstruction
                    %                 TempCoord=AllNewFit_MaxCoords(TempFinalEventCount,:);
                    %                 F2 = mvnpdf([X1(:) Y1(:)],fliplr(TempCoord),TestSigma);
                    %                 F2 = reshape(F2,length(y1),length(x1));
                    %                 F2=F2/max(F2(:))*AllNewFit_Amp(TempFinalEventCount);
                    %                 ReconstructedFitImage=ReconstructedFitImage+F2;
                    %                 clear F2


                                end
                                SOQA_Upscale_Max_Sum=SOQA_Upscale_Max_Sum+Max_Image;
                                CoordinatesImage_Upscale=CoordinatesImage_Upscale+Max_Image;
                            else

                            end
                        end
                    end
                    CoordinatesImage_Upscale = imfilter(single(CoordinatesImage_Upscale), fspecial('gaussian', UpScaleFilterSize, UpScaleFilterSigma));
                    CoordinatesImage_Upscale=CoordinatesImage_Upscale/max(CoordinatesImage_Upscale(:));
                    SOQA_Upscale_Max_Sum_Filt = imfilter(single(SOQA_Upscale_Max_Sum), fspecial('gaussian', UpScaleFilterSize, UpScaleFilterSigma));
                    CoordinatesImage_Upscale(isnan(CoordinatesImage_Upscale))=0;
                    SOQA_Upscale_Max_Sum_Filt(isnan(SOQA_Upscale_Max_Sum_Filt))=0;
                    QuaSOR_Map_Contrast=[0,max(SOQA_Upscale_Max_Sum_Filt(:))+max(SOQA_Upscale_Max_Sum_Filt(:))*QuaSOR_HighPercent];
                    QuaSOR_Map_Contrast2=[0,max(CoordinatesImage_Upscale(:))+max(CoordinatesImage_Upscale(:))*QuaSOR_HighPercent];

                else
                    if ImageNumber==1
                        CoordinatesImage_Upscale=single(ZerosImage_Upscale);
                        SOQA_Upscale_Max_Sum_Filt=single(ZerosImage_Upscale);
                        ReconstructedFitImage_Upscale=single(ZerosImage_Upscale);
                        CurrentCoords=[];

                        
                        Max_Image=ZerosImage_Upscale;
                        %Highlight Coords
                        for z=1:SOQA_Data(IndexNumber).Num_Successful_Fits
                            for k=1:SOQA_Data(IndexNumber).AllBestFits(z).BestGaussianFitModel_Clean.NumComponents
                                TempCoord=SOQA_Data(IndexNumber).AllBestFits(z).BestGaussianFitModel_Clean.mu_Fix(k,:);
                                %TempCoord(1)=TempCoord(1)+YOffset;
                                %TempCoord(2)=TempCoord(2)+XOffset;
                                CurrentCoords=vertcat(CurrentCoords,round(TempCoord));
                            end
                        end

                        %Reconstruct Coords and fit and maps
                        for z=1:SOQA_Data(IndexNumber).Num_Successful_Fits
                            for k=1:SOQA_Data(IndexNumber).AllBestFits(z).BestGaussianFitModel_Clean.NumComponents
                                TempCoord=SOQA_Data(IndexNumber).AllBestFits(z).BestGaussianFitModel_Clean.mu_Fix(k,:);
                                TempCoord(1)=TempCoord(1)+YOffset;
                                TempCoord(2)=TempCoord(2)+XOffset;
                                TestSigma=SOQA_Data(IndexNumber).AllBestFits(z).BestGaussianFitModel_Clean.Sigma(:,:,k);

                                %Upscale Reconstruction
                                temp1=TestSigma(1,1);
                                temp2=TestSigma(2,2);
                                TestSigma(1,1)=temp2;TestSigma(2,2)=temp1;
                                clear temp1 temp2
                                F2 = mvnpdf([X2(:) Y2(:)],fliplr(TempCoord),TestSigma);
                                F2 = reshape(F2,length(y2),length(x2));
                                F2=F2/max(F2(:))*SOQA_Data(IndexNumber).AllBestFits(z).BestGaussianFitModel_Clean.Amp(k);
                                ReconstructedFitImage_Upscale=ReconstructedFitImage_Upscale+F2;
                                clear F2

                                %Max location reconstruction
                                TempImage=ZerosImage_Upscale;
                                TempCoord=round(TempCoord*UpScaleRatio)+UpScale_CoordinateAdjust*UpScaleRatio;
                                if TempCoord(1)>0&&TempCoord(1)<=size(TempImage,1)&&TempCoord(2)>0&&TempCoord(2)<=size(TempImage,2)
                                    TempImage(TempCoord(1),TempCoord(2))=1;
                                    Max_Image=Max_Image+TempImage; 
                                end
                                clear TempImage

                %                 %Normal Res reconstruction
                %                 TempCoord=AllNewFit_MaxCoords(TempFinalEventCount,:);
                %                 F2 = mvnpdf([X1(:) Y1(:)],fliplr(TempCoord),TestSigma);
                %                 F2 = reshape(F2,length(y1),length(x1));
                %                 F2=F2/max(F2(:))*AllNewFit_Amp(TempFinalEventCount);
                %                 ReconstructedFitImage=ReconstructedFitImage+F2;
                %                 clear F2


                            end
                            SOQA_Upscale_Max_Sum=SOQA_Upscale_Max_Sum+Max_Image;
                            CoordinatesImage_Upscale=CoordinatesImage_Upscale+Max_Image;

                        end
                        CoordinatesImage_Upscale = imfilter(single(CoordinatesImage_Upscale), fspecial('gaussian', UpScaleFilterSize, UpScaleFilterSigma));
                        CoordinatesImage_Upscale=CoordinatesImage_Upscale/max(CoordinatesImage_Upscale(:));
                        SOQA_Upscale_Max_Sum_Filt = imfilter(single(SOQA_Upscale_Max_Sum), fspecial('gaussian', UpScaleFilterSize, UpScaleFilterSigma));
                        CoordinatesImage_Upscale(isnan(CoordinatesImage_Upscale))=0;
                        SOQA_Upscale_Max_Sum_Filt(isnan(SOQA_Upscale_Max_Sum_Filt))=0;
                        QuaSOR_Map_Contrast=[0,max(SOQA_Upscale_Max_Sum_Filt(:))+max(SOQA_Upscale_Max_Sum_Filt(:))*QuaSOR_HighPercent];
                        QuaSOR_Map_Contrast2=[0,max(CoordinatesImage_Upscale(:))+max(CoordinatesImage_Upscale(:))*QuaSOR_HighPercent];

                    end
                    
                end
                

                if QuaSOR_Map_Contrast(2)==0
                    QuaSOR_Map_Contrast(2)=1;
                end
                if QuaSOR_Map_Contrast2(2)==0
                    QuaSOR_Map_Contrast2(2)=1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                subtightplot(2,3,1,[0.0,0.0],[0,0],[0,0])
                imagesc(F_Image, F_Contrast); axis equal tight; 
                colormap('gray')
                hold on
                for j=1:length(BorderLine)
                    plot(BorderLine{j}.BorderLine_Crop(:,2)+BorderLineAdjustment, BorderLine{j}.BorderLine_Crop(:,1)+BorderLineAdjustment,'-' , 'color', BorderColor,'linewidth', BorderThickness); 
                end
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gcf, 'color', 'white');
                plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',ScaleBar.Width);
                text(LabelLocation(1),LabelLocation(2),['Corr. Data'],'fontsize',LabelFontSize,'color',TextColor)
                if ImagingModality==2
                    text(LabelLocation1(1),LabelLocation1(2),['Movie ',num2str(IndexNumber),' ',TimePoint],'fontsize',LabelFontSize1,'color',TextColor)
                elseif ImagingModality==3||ImagingModality==4
                    text(LabelLocation1(1),LabelLocation1(2),[TimePoint],'fontsize',LabelFontSize1,'color',TextColor)
                elseif ImagingModality==1
                    text(LabelLocation1(1),LabelLocation1(2),['Stim ',num2str(IndexNumber)],'fontsize',LabelFontSize1,'color',TextColor)
                else
                    text(LabelLocation1(1),LabelLocation1(2),[TimePoint],'fontsize',LabelFontSize1,'color',TextColor)
                end
                %text(LabelLocation2(1),LabelLocation2(2),['Movie ',num2str(IndexNumber)],'fontsize',LabelFontSize,'color','w')
                %text(LabelLocation(1),LabelLocation(2),[num2str(IndexNumber),'|',num2str(ImageNumber)],'fontsize',LabelFontSize,'color','w')
                if ~isempty(CurrentCoords)
                    for CircleNum=1:size(CurrentCoords,1)
                        Plot_Circle2(CurrentCoords(CircleNum,2),CurrentCoords(CircleNum,1),...
                            EventCircleRadius,EventCircleLineStyle,EventCircleLineWidth,EventCircleColor);
                    end
                end
                xlim([1,ImageWidth])
                ylim([1,ImageHeight])
                freezeColors
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                subtightplot(2,3,4,[0.0,0.0],[0,0],[0,0])
                imagesc(DeltaF_Image, DeltaF_Contrast); axis equal tight; 
                colormap('jet')
                hold on
                for j=1:length(BorderLine)
                    plot(BorderLine{j}.BorderLine_Crop(:,2)+BorderLineAdjustment, BorderLine{j}.BorderLine_Crop(:,1)+BorderLineAdjustment,'-' , 'color', BorderColor,'linewidth', BorderThickness); 
                end
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gcf, 'color', 'white');
                plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',ScaleBar.Width);
                text(LabelLocation(1),LabelLocation(2),['\DeltaF'],'fontsize',LabelFontSize,'color',TextColor)
                if ~isempty(CurrentCoords)
                    for CircleNum=1:size(CurrentCoords,1)
                        Plot_Circle2(CurrentCoords(CircleNum,2),CurrentCoords(CircleNum,1),...
                            EventCircleRadius,EventCircleLineStyle,EventCircleLineWidth,EventCircleColor);
                    end
                end
                xlim([1,ImageWidth])
                ylim([1,ImageHeight])
                %text(LabelLocation(1),LabelLocation(2),[num2str(IndexNumber),'|',num2str(ImageNumber)],'fontsize',LabelFontSize,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                subtightplot(2,3,2,[0.0,0.0],[0,0],[0,0])
                imagesc(DeltaFF0_Image, DeltaFF0_Contrast); axis equal tight; 
                colormap('jet')
                hold on
                for j=1:length(BorderLine)
                    plot(BorderLine{j}.BorderLine_Crop(:,2)+BorderLineAdjustment, BorderLine{j}.BorderLine_Crop(:,1)+BorderLineAdjustment,'-' , 'color', BorderColor,'linewidth', BorderThickness); 
                end
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gcf, 'color', 'white');
                plot(ScaleBar.XData,ScaleBar.YData,'-','color',ScaleBar.Color,'LineWidth',ScaleBar.Width);
                text(LabelLocation(1),LabelLocation(2),['Quantal \DeltaF/F'],'fontsize',LabelFontSize,'color',TextColor)
                %text(LabelLocation(1),LabelLocation(2),[num2str(IndexNumber),'|',num2str(ImageNumber)],'fontsize',LabelFontSize,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                subtightplot(2,3,5,[0.0,0.0],[0,0],[0,0])
                imagesc(ReconstructedFitImage_Upscale, DeltaFF0_Contrast); axis equal tight; 
                colormap('jet')
                hold on
                for j=1:length(BorderLine_Upscale)
                    plot(BorderLine_Upscale{j}.BorderLine_Crop(:,2)+BorderLineAdjustment, BorderLine_Upscale{j}.BorderLine_Crop(:,1)+BorderLineAdjustment,'-' , 'color', BorderColor,'linewidth', BorderThickness); 
                end
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gcf, 'color', 'white');
                plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',ScaleBar_Upscale.Width);
                text(LabelLocation3(1),LabelLocation3(2),['QuaSOR Fit'],'fontsize',LabelFontSize,'color',TextColor)
                %text(LabelLocation(1),LabelLocation(2),[num2str(IndexNumber),'|',num2str(ImageNumber)],'fontsize',LabelFontSize,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                subtightplot(2,3,3,[0.0,0.0],[0,0],[0,0])
                imagesc(CoordinatesImage_Upscale, QuaSOR_Map_Contrast2); axis equal tight; 
                colormap('jet')
                hold on
                for j=1:length(BorderLine_Upscale)
                    plot(BorderLine_Upscale{j}.BorderLine_Crop(:,2)+BorderLineAdjustment, BorderLine_Upscale{j}.BorderLine_Crop(:,1)+BorderLineAdjustment,'-' , 'color', BorderColor,'linewidth', BorderThickness); 
                end
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gcf, 'color', 'white');
                plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',ScaleBar_Upscale.Width);
                text(LabelLocation3(1),LabelLocation3(2),['QuaSOR Loc.'],'fontsize',LabelFontSize,'color',TextColor)
                %text(LabelLocation(1),LabelLocation(2),[num2str(IndexNumber),'|',num2str(ImageNumber)],'fontsize',LabelFontSize,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                subtightplot(2,3,6,[0.0,0.0],[0,0],[0,0])
                imagesc(SOQA_Upscale_Max_Sum_Filt,QuaSOR_Map_Contrast); axis equal tight; 
                colormap('jet')
                hold on
                for j=1:length(BorderLine_Upscale)
                    plot(BorderLine_Upscale{j}.BorderLine_Crop(:,2)+BorderLineAdjustment, BorderLine_Upscale{j}.BorderLine_Crop(:,1)+BorderLineAdjustment,'-' , 'color', BorderColor,'linewidth', BorderThickness); 
                end
                set(gca,'XTick', []); set(gca,'YTick', []);
                set(gcf, 'color', 'white');
                plot(ScaleBar_Upscale.XData,ScaleBar_Upscale.YData,'-','color',ScaleBar_Upscale.Color,'LineWidth',ScaleBar_Upscale.Width);
                text(LabelLocation3(1),LabelLocation3(2),['QuaSOR Map'],'fontsize',LabelFontSize,'color',TextColor)
                %text(LabelLocation(1),LabelLocation(2),[num2str(IndexNumber),'|',num2str(ImageNumber)],'fontsize',LabelFontSize,'color','w')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if Visibility
                    drawnow
                    pause(0.001)
                else
                    if rem(ImageNumber,100)==0
                        fprintf('.')
                    end
                end
                OneFrame = getframe(MovieFig);
                writeVideo(Full_mov,OneFrame);
                if ~isempty(PreviewIndices)
                    if IndexNumber<=PreviewIndices(length(PreviewIndices))
                        writeVideo(Preview_mov,OneFrame);
                    end
                end
                clear OneFrame
                ImageNumber=ImageNumber+1;
                ImageCount=ImageCount+1;
                figure(f);
                if get(AbortButtonHandle,'userdata')
                    warning on;warning('Aborting Movie...');warning off;
                    cont=0;
                    AbortedMovie=1;
                else
                    cont=1;
                    AbortedMovie=0;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            IndexTime=toc(IndexTimer);
            fprintf(['Finished! (Took ',num2str(round(IndexTime)),'s)\n'])
            if ~isempty(PreviewIndices)
                if IndexNumber==PreviewIndices(length(PreviewIndices))
                    fprintf('Finished Preview Movie!...\n')
                    close(Preview_mov);
                    FileInfo=dir([ScratchDir,StackSaveName,StackSaveNameSuffix , PreviewMovieName]);
                    warning on
                    warning([StackSaveName,StackSaveNameSuffix , PreviewMovieName,' = ',...
                        num2str(round(FileInfo.bytes/(1e9)*10)/10),'GB'])
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    disp('Copying Preview Movie From Scratch Dir...')
                    [CopyStatus,CopyMessage]=copyfile([ScratchDir,StackSaveName,StackSaveNameSuffix , PreviewMovieName],MovieSaveDir);
                    if CopyStatus
                        disp('Copy successful!')
                        warning(['Deleting: ',ScratchDir,StackSaveName,StackSaveNameSuffix , PreviewMovieName]);
                        delete([ScratchDir,dc,StackSaveName,StackSaveNameSuffix , PreviewMovieName])
                    else
                        warning(CopyMessage)
                        warning('Not Deleting File from Scratch Dir!')
                    end
                end
            end
            IndexNumber=IndexNumber+1;
            if get(AbortButtonHandle,'userdata')
                warning on;warning('Aborting Movie...');warning off;
                cont=0;
            else
                cont=1;
            end
            clear BC_F_Stack DeltaF_Stack CorrAmp_Stack CorrAmp_Stack_Temporal_Projection ReconstructedFitImage_Upscale CoordinatesImage_Upscale
        end
        warning on
        clear SOQA_Upscale_Max_Sum SOQA_Upscale_Max_Sum_Filt
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('Finished Full Movie!...\n')
        warning on
        close(Full_mov);
        close(MovieFig)
        close(f)
        close all
        jheapcl


        FileInfo=dir([ScratchDir,StackSaveName,StackSaveNameSuffix, FullMovieName]);
        warning on
        warning([StackSaveName,StackSaveNameSuffix , FullMovieName,' = ',...
            num2str(round(FileInfo.bytes/(1e9)*10)/10),'GB'])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Copying Full Record Movie From Scratch Dir...')
        [CopyStatus,CopyMessage]=copyfile([ScratchDir,StackSaveName,StackSaveNameSuffix, FullMovieName],MovieSaveDir);
        if CopyStatus
            disp('Copy successful!')
            warning(['Deleting: ',ScratchDir,StackSaveName,StackSaveNameSuffix, FullMovieName]);
            delete([ScratchDir,StackSaveName,StackSaveNameSuffix, FullMovieName])
        else
            warning(CopyMessage)
            warning('Not Deleting File from Scratch Dir!')
        end
        disp('Finished Summary Movie!')
        disp('Finished Summary Movie!')
        disp('Finished Summary Movie!')
        disp('Finished Summary Movie!')
        disp('Finished Summary Movie!')
        disp('Finished Summary Movie!')
        disp('Finished Summary Movie!')
        
        if AbortedMovie
            warning('Movie was Aborted early...')
            MovieSuccess=input('Enter 1 to call it good or enter nothing to leave this entry in the queue: ');
            if isempty(MovieSuccess)
                MovieSuccess=0;
            else
                MovieSuccess=1;
            end
        else
            MovieSuccess=1;
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    catch
        warning('Problem Making the Movie!!!')
        warning('Problem Making the Movie!!!')
        warning('Problem Making the Movie!!!')
        warning('Problem Making the Movie!!!')
        warning('Problem Making the Movie!!!')
        warning('Problem Making the Movie!!!')
        warning('Problem Making the Movie!!!')
        warning('Problem Making the Movie!!!')
        warning('Problem Making the Movie!!!')
        MovieSuccess=0;
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist([ScratchDir,StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat'])
        warning(['Deleting ',StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat from ScratchDir'])
        warning(['Deleting ',StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat from ScratchDir'])
        warning(['Deleting ',StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat from ScratchDir'])
        delete([ScratchDir,StackSaveName,StackSaveNameSuffix,'_SOQA_Data2.mat'])
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end