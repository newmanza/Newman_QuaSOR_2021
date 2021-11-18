    clear EpisodeStruct EpisodeStructCurves
    if ImagingInfo.FramesPerEpisode>500&&ImagingInfo.NumEpisodes>3
        warning('I am going to save each episode sepearately to make loading easier...')
        SplitEpisodeFiles=1;
        fprintf('Processing Episodes...Separate, Bleach Corr, DeltaF....\n')
    else
        fprintf('Processing Episodes...Separate, Bleach Corr, DeltaF....')
        SplitEpisodeFiles=0;
    end
    progressbar('Episode #');
    for EpisodeNumber=1:ImagingInfo.NumEpisodes
        TempFrames=[ImagingInfo.FramesPerEpisode*(EpisodeNumber-1)+1:ImagingInfo.FramesPerEpisode*(EpisodeNumber)];
        ImageArrayReg_Episode=double(ImageArrayReg_AllImages(:,:,TempFrames));
        MeanFirstImageValue=mean(MeanValues(ImageArrayReg_Episode(:,:,1),AllBoutonsRegion));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get bleach-correcting curve
        MeanF_Vector = MeanValues(ImageArrayReg_Episode, AllBoutonsRegion);
        MeanF_Vector_Norm = MeanF_Vector / MeanF_Vector(1);
        xdata = [1:ImagingInfo.FramesPerEpisode];
        % fit using x values that don't include stimulation response
        outliers(1:ImagingInfo.FramesPerEpisode) = 0;
        if ~isfield(RegistrationSettings,'BleachCorr_Outliers')
            RegistrationSettings.BleachCorr_Outliers=[RegistrationSettings.BleachCorr_OutlierLimits(1):RegistrationSettings.BleachCorr_OutlierLimits(2)];
        end
        if ~isempty(RegistrationSettings.BleachCorr_Outliers)
            outliers(RegistrationSettings.BleachCorr_Outliers) = 1; % x values to exclude for exponential
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        switch RegistrationSettings.BleachCorr_Option
            case 0
                MeanF_Vector_Norm_FitResult=[];
                MeanF_Vector_FitTrace=[];
                MeanF_Vector_Norm_FitTrace=[];
            case 1
                % Linear
                MeanF_Vector_Norm_FitResult = fit(xdata', MeanF_Vector_Norm', 'poly1', 'exclude', outliers);

                coeff_p1 = MeanF_Vector_Norm_FitResult.p1;
                coeff_p2 = MeanF_Vector_Norm_FitResult.p2;

                MeanF_Vector_FitTrace = (coeff_p1 * xdata) + coeff_p2;
                MeanF_Vector_Norm_FitTrace = MeanF_Vector_FitTrace / MeanF_Vector_FitTrace(1);
            case 2
                % Single exponential
                MeanF_Vector_Norm_FitResult = fit(xdata', MeanF_Vector_Norm', 'exp1', 'exclude', outliers);

                coeff_a = MeanF_Vector_Norm_FitResult.a;
                coeff_b = MeanF_Vector_Norm_FitResult.b;

                MeanF_Vector_FitTrace = coeff_a * exp(coeff_b * xdata);
                MeanF_Vector_FitTrace = MeanF_Vector_FitTrace / MeanF_Vector_FitTrace(1);
            case 3     
                % Double exponential:
                MeanF_Vector_Norm_FitResult = fit(xdata', MeanF_Vector_Norm', 'exp2', 'exclude', outliers);

                coeff_a = MeanF_Vector_Norm_FitResult.a;
                coeff_b = MeanF_Vector_Norm_FitResult.b;
                coeff_c = MeanF_Vector_Norm_FitResult.c;
                coeff_d = MeanF_Vector_Norm_FitResult.d;

                MeanF_Vector_FitTrace = (coeff_a * exp(coeff_b * xdata)) + (coeff_c * exp(coeff_d * xdata));
                MeanF_Vector_Norm_FitTrace = MeanF_Vector_FitTrace / MeanF_Vector_FitTrace(1);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        switch RegistrationSettings.BaselineOption
            case 1
                Temp_F0_Image=double(ImageArrayReg_Episode(:,:,RegistrationSettings.BaselineFrames));
            case 2
                Temp_F0_Image=mean(double(ImageArrayReg_Episode(:,:,RegistrationSettings.BaselineFrames)),3);
            case 3
                Temp_F0_Image=max(double(ImageArrayReg_Episode(:,:,RegistrationSettings.BaselineFrames)),3);
            case 4
                Temp_F0_Image=min(double(ImageArrayReg_Episode(:,:,RegistrationSettings.BaselineFrames)),3);
            case 5
                TempMinStack=zeros(size(ImageArrayReg_Episode,1),size(ImageArrayReg_Episode,2),RegistrationSettings.BaselineNumBlocks);
                for z=1:RegistrationSettings.BaselineNumBlocks
                    TempMinStack(:,:,z)=min(double(TempArray(:,:,(z-1)*RegistrationSettings.BaselineNumFrames+1:z*RegistrationSettings.BaselineNumFrames)),[],3);
                end
                Temp_F0_Image=mean(TempMinStack,3);
                clear TempMinStack
            case 6
                ImageArrayReg_Episode_MovingMin=movmin(double(ImageArrayReg_Episode),[RegistrationSettings.BaselineNumFrames RegistrationSettings.BaselineNumFrames],3);
                MeanMovingMin_Vector=MeanValues(ImageArrayReg_Episode_MovingMin,AllBoutonsRegion);
                Temp_F0_Image=mean(double(ImageArrayReg_Episode(:,:,RegistrationSettings.BaselineFrames)),3);
        end
        MeanBCValue=mean(Temp_F0_Image(AllBoutonsRegion));
        if RegistrationSettings.BleachCorr_Option==0
            ImageArrayReg_Episode_BC = ImageArrayReg_Episode;
        else
            ImageArrayReg_Episode_BC = zeros(size(ImageArrayReg_Episode));
            for ImageNumber=1:size(ImageArrayReg_Episode,3)
                ImageArrayReg_Episode_BC(:,:,ImageNumber)=ImageArrayReg_Episode(:,:,ImageNumber)+(MeanBCValue-MeanBCValue*MeanF_Vector_Norm_FitTrace(ImageNumber));
            end
        end
        MeanBC_Vector = MeanValues(ImageArrayReg_Episode_BC, AllBoutonsRegion);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ImagingInfo.NumEpisodes<6
            figure('name',['Episode ',num2str(EpisodeNumber)])
            set(gcf,'position',[0,80,1000,500])
            subplot(1,3,1)
            plot([1:ImagingInfo.FramesPerEpisode],MeanF_Vector,'color','k')
            xlim([0,ImagingInfo.FramesPerEpisode])
            xlabel('Frames Per Episode')
            ylabel('Raw F')
            subplot(1,3,2)
            plot([1:ImagingInfo.FramesPerEpisode],MeanF_Vector_Norm,'color','k')
            hold on
            if ~isempty(MeanF_Vector_Norm_FitTrace)
            plot([1:ImagingInfo.FramesPerEpisode],MeanF_Vector_Norm_FitTrace,'color','g','linewidth',2)
            TempTrace=MeanF_Vector_Norm_FitTrace.*outliers;
            TempTrace(TempTrace==0)=NaN;
            plot([1:ImagingInfo.FramesPerEpisode],TempTrace,'color','r','linewidth',2)
            end
            xlim([0,ImagingInfo.FramesPerEpisode])
            xlabel('Frames Per Episode')
            ylabel('Norm F and Fit')
            subplot(1,3,3)
            plot([1:ImagingInfo.FramesPerEpisode],MeanBC_Vector,'color','k')
            xlim([0,ImagingInfo.FramesPerEpisode])
            xlabel('Frames Per Episode')
            ylabel('BC F')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ImageArrayReg_Episode_BC_MovingMin=[];
        MeanMovingMin_Vector=[];
        if RegistrationSettings.BaselineOption==1&&length(RegistrationSettings.BaselineFrames)>1
            warning('BaselineOption = 1 cant have more than one frame, switching to BaselineOption = 2 aka mean');
            warning('BaselineOption = 1 cant have more than one frame, switching to BaselineOption = 2 aka mean');
            warning('BaselineOption = 1 cant have more than one frame, switching to BaselineOption = 2 aka mean');
            warning('BaselineOption = 1 cant have more than one frame, switching to BaselineOption = 2 aka mean');
            warning('BaselineOption = 1 cant have more than one frame, switching to BaselineOption = 2 aka mean');
            RegistrationSettings.BaselineOption=2;
        end
        switch RegistrationSettings.BaselineOption
            case 1
                F0_Image=double(ImageArrayReg_Episode_BC(:,:,RegistrationSettings.BaselineFrames));
            case 2
                F0_Image=mean(double(ImageArrayReg_Episode_BC(:,:,RegistrationSettings.BaselineFrames)),3);
            case 3
                F0_Image=max(double(ImageArrayReg_Episode_BC(:,:,RegistrationSettings.BaselineFrames)),3);
            case 4
                F0_Image=min(double(ImageArrayReg_Episode_BC(:,:,RegistrationSettings.BaselineFrames)),3);
            case 5
                TempMinStack=zeros(size(ImageArrayReg_Episode_BC,1),size(ImageArrayReg_Episode_BC,2),RegistrationSettings.BaselineNumBlocks);
                for z=1:RegistrationSettings.BaselineNumBlocks
                    TempMinStack(:,:,z)=min(double(TempArray(:,:,(z-1)*RegistrationSettings.BaselineNumFrames+1:z*RegistrationSettings.BaselineNumFrames)),[],3);
                end
                F0_Image=mean(TempMinStack,3);
                clear TempMinStack
            case 6
                ImageArrayReg_Episode_BC_MovingMin=movmin(double(ImageArrayReg_Episode_BC),[RegistrationSettings.BaselineNumFrames RegistrationSettings.BaselineNumFrames],3);
                MeanMovingMin_Vector=MeanValues(ImageArrayReg_Episode_BC_MovingMin,AllBoutonsRegion);
                F0_Image=mean(double(ImageArrayReg_Episode_BC(:,:,RegistrationSettings.BaselineFrames)),3);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ImageArrayReg_Episode_DeltaF=zeros(size(ImageArrayReg_Episode_BC));
        ImageArrayReg_Episode_DeltaFF0=zeros(size(ImageArrayReg_Episode_BC));
        for ImageNumber=1:ImagingInfo.FramesPerEpisode
            TempImage=double(ImageArrayReg_Episode_BC(:,:,ImageNumber));
            TempImage=TempImage.*double(AllBoutonsRegion);
            if RegistrationSettings.BaselineOption==6
                Temp_F0_Image=ImageArrayReg_Episode_BC_MovingMin(:,:,ImageNumber);
                ImageArrayReg_Episode_DeltaF(:,:,ImageNumber)=TempImage-Temp_F0_Image;
                ImageArrayReg_Episode_DeltaFF0(:,:,ImageNumber)=(TempImage-Temp_F0_Image)./Temp_F0_Image;
            else
                ImageArrayReg_Episode_DeltaF(:,:,ImageNumber)=TempImage-F0_Image;
                ImageArrayReg_Episode_DeltaFF0(:,:,ImageNumber)=(TempImage-F0_Image)./F0_Image;
            end                   
        end
        MeanDeltaF_Vector=MeanValues(ImageArrayReg_Episode_DeltaF,AllBoutonsRegion);
        MeanDeltaFF0_Vector=MeanValues(ImageArrayReg_Episode_DeltaFF0,AllBoutonsRegion);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ImagingInfo.NumEpisodes<6
            figure('name',['Episode ',num2str(EpisodeNumber)])
            set(gcf,'position',[0,80,1000,500])
            subplot(1,2,1)
            plot([1:ImagingInfo.FramesPerEpisode],MeanDeltaF_Vector,'color','k')
            xlim([0,ImagingInfo.FramesPerEpisode])
            xlabel('Frames Per Episode')
            ylabel('\DeltaF')
            subplot(1,2,2)
            plot([1:ImagingInfo.FramesPerEpisode],MeanDeltaFF0_Vector,'color','k')
            xlim([0,ImagingInfo.FramesPerEpisode])
            xlabel('Frames Per Episode')
            ylabel('\DeltaF/F')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if SplitEpisodeFiles
            CurrentEpisodeNum=1;
        else
            CurrentEpisodeNum=EpisodeNumber;
        end
        EpisodeStruct(CurrentEpisodeNum).FramesPerEpisode=ImagingInfo.FramesPerEpisode;
        EpisodeStruct(CurrentEpisodeNum).Frames=TempFrames;
        EpisodeStruct(CurrentEpisodeNum).ImageArrayReg_Episode=ImageArrayReg_Episode;
        EpisodeStruct(CurrentEpisodeNum).ImageArrayReg_Episode_BC=ImageArrayReg_Episode_BC;
        EpisodeStruct(CurrentEpisodeNum).ImageArrayReg_Episode_BC_MovingMin=ImageArrayReg_Episode_BC_MovingMin;
        EpisodeStruct(CurrentEpisodeNum).ImageArrayReg_Episode_DeltaF=ImageArrayReg_Episode_DeltaF;
        EpisodeStruct(CurrentEpisodeNum).ImageArrayReg_Episode_DeltaFF0=ImageArrayReg_Episode_DeltaFF0;
        %%%%%%%%%%%%
        EpisodeStruct(CurrentEpisodeNum).MeanBCValue=MeanBCValue;
        EpisodeStruct(CurrentEpisodeNum).BleachCorr_Option=RegistrationSettings.BleachCorr_Option;
        EpisodeStruct(CurrentEpisodeNum).BleachCorr_Outliers=RegistrationSettings.BleachCorr_Outliers;
        EpisodeStruct(CurrentEpisodeNum).MeanF_Vector_Norm_FitResult=MeanF_Vector_Norm_FitResult;
        EpisodeStruct(CurrentEpisodeNum).MeanF_Vector_FitTrace=MeanF_Vector_FitTrace;
        EpisodeStruct(CurrentEpisodeNum).MeanF_Vector_Norm_FitTrace=MeanF_Vector_Norm_FitTrace;

        %%%%%%%%%%%%
        EpisodeStruct(CurrentEpisodeNum).BaselineOption=RegistrationSettings.BaselineOption;
        EpisodeStruct(CurrentEpisodeNum).BaselineNumFrames=RegistrationSettings.BaselineNumFrames;
        EpisodeStruct(CurrentEpisodeNum).BaselineFrames=RegistrationSettings.BaselineFrames;
        EpisodeStruct(CurrentEpisodeNum).BaselineNumBlocks=RegistrationSettings.BaselineNumBlocks;
        EpisodeStruct(CurrentEpisodeNum).F0_Image=F0_Image;
        EpisodeStruct(CurrentEpisodeNum).MeanFirstImageValue=MeanFirstImageValue;
        %%%%%%%%%%%%
        EpisodeStruct(CurrentEpisodeNum).MeanF_Vector=MeanF_Vector;
        EpisodeStruct(CurrentEpisodeNum).MeanF_Vector_Norm=MeanF_Vector_Norm;
        EpisodeStruct(CurrentEpisodeNum).MeanF_Vector_Norm_FitResult=MeanF_Vector_Norm_FitResult;
        EpisodeStruct(CurrentEpisodeNum).MeanF_Vector_FitTrace=MeanF_Vector_FitTrace;
        EpisodeStruct(CurrentEpisodeNum).MeanF_Vector_Norm_FitTrace=MeanF_Vector_Norm_FitTrace;
        EpisodeStruct(CurrentEpisodeNum).MeanBC_Vector=MeanBC_Vector;
        EpisodeStruct(CurrentEpisodeNum).MeanMovingMin_Vector=MeanMovingMin_Vector;
        EpisodeStruct(CurrentEpisodeNum).MeanDeltaF_Vector=MeanDeltaF_Vector;
        EpisodeStruct(CurrentEpisodeNum).MeanDeltaFF0_Vector=MeanDeltaF_Vector;
        %%%%%%%%%%%%
        EpisodeStructCurves(EpisodeNumber).MeanF_Vector=MeanF_Vector;
        EpisodeStructCurves(EpisodeNumber).MeanF_Vector_Norm=MeanF_Vector_Norm;
        EpisodeStructCurves(EpisodeNumber).MeanF_Vector_Norm_FitResult=MeanF_Vector_Norm_FitResult;
        EpisodeStructCurves(EpisodeNumber).MeanF_Vector_FitTrace=MeanF_Vector_FitTrace;
        EpisodeStructCurves(EpisodeNumber).MeanF_Vector_Norm_FitTrace=MeanF_Vector_Norm_FitTrace;
        EpisodeStructCurves(EpisodeNumber).MeanBC_Vector=MeanBC_Vector;
        EpisodeStructCurves(EpisodeNumber).MeanMovingMin_Vector=MeanMovingMin_Vector;
        EpisodeStructCurves(EpisodeNumber).MeanDeltaF_Vector=MeanDeltaF_Vector;
        EpisodeStructCurves(EpisodeNumber).MeanDeltaFF0_Vector=MeanDeltaF_Vector;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if SplitEpisodeFiles
            warning on
            FileSuffix=['_DeltaFData_Ep_',num2str(EpisodeNumber),'.mat'];
            fprintf(['Saving... ',StackSaveName,FileSuffix,' to CurrentScratchDir...']);
            save([CurrentScratchDir,dc,StackSaveName,FileSuffix],'EpisodeStruct')
            fprintf('Finished!\n')
            fprintf(['Copying: ',StackSaveName,FileSuffix,' to SaveDir...'])
            [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
            fprintf('Finished!\n')
            if ~CopyStatus
                error('Problem Copying Split Episode Data!')
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        clear TempFrames ImageArrayReg_Episode ImageArrayReg_Episode_BC ImageArrayReg_Episode_BC_MovingMin
        clear ImageArrayReg_Episode_DeltaF ImageArrayReg_Episode_DeltaFF0
        clear TempArray F0_Image TempFirstImage outliers xdata
        clear MeanFirstImageValue MeanF_Vector MeanF_Vector_Norm
        clear MeanF_Vector_Norm_FitResult MeanF_Vector_FitTrace MeanF_Vector_Norm_FitTrace
        clear MeanBC_Vector MeanMovingMin_Vector MeanDeltaF_Vector MeanDeltaFF0_Vector 
        progressbar(EpisodeNumber/ImagingInfo.NumEpisodes);
    end
    fprintf('Finished!\n')
    close all
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %Save
    if SplitEpisodeFile
        warning('Clearing EpisodeStruct')
        EpisodeStruct=[];
    else
    end
    warning on
    FileSuffix='_DeltaFData.mat';
    fprintf(['Saving... ',StackSaveName,FileSuffix,'...']);
    save([CurrentScratchDir,dc,StackSaveName,FileSuffix],'EpisodeStruct','EpisodeStructCurves','SplitEpisodeFiles')
    fprintf('Finished!\n')
    fprintf(['Copying: ',StackSaveName,FileSuffix,' to SaveDir...'])
    [CopyStatus,CopyMessage]=copyfile([CurrentScratchDir,StackSaveName,FileSuffix],SaveDir);
    fprintf('Finished!\n')
    if ~CopyStatus
        error('Problem Copying Split Episode Data!')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

