for RecordingNum=1:length(Recording)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %Initial Settings from Recording
        [OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(1);
        cd([Recording(RecordingNum).dir]);
        SaveName=Recording(RecordingNum).SaveName;
        StackSaveName=Recording(RecordingNum).StackSaveName;
        ImageSetSaveName=Recording(RecordingNum).ImageSetSaveName;
        ModalitySuffix=Recording(RecordingNum).ModalitySuffix;
        BoutonSuffix=Recording(RecordingNum).BoutonSuffix;
        LoadDir=Recording(RecordingNum).dir;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %Directories
        SaveDir=[Recording(RecordingNum).dir,dc,ModalitySuffix,BoutonSuffix,dc];
        SaveDir1=[Recording(RecordingNum).dir,dc,ModalitySuffix,dc];
        SaveDir2=[Recording(RecordingNum).dir,dc];
        CurrentScratchDir=[ScratchDir,StackSaveName,dc,ModalitySuffix,BoutonSuffix,dc];
        CurrentScratchDir1=[ScratchDir,StackSaveName,dc,ModalitySuffix,dc];
        CurrentScratchDir2=[ScratchDir,StackSaveName,dc];
        if ~exist(CurrentScratchDir)
            mkdir(CurrentScratchDir)
        end
        if ~exist(CurrentScratchDir1)
            mkdir(CurrentScratchDir1)
        end
        if ~exist(CurrentScratchDir2)
            mkdir(CurrentScratchDir2)
        end
        FigureSaveDir=[SaveDir,'Figures',dc,AnalysisLabelShort];
        if ~exist(FigureSaveDir)
            mkdir(FigureSaveDir)
        end
        FigureScratchDir=[CurrentScratchDir,'Figures',dc,AnalysisLabelShort];
        if ~exist(FigureScratchDir)
            mkdir(FigureScratchDir)
        end
        MoviesSaveDir=[SaveDir,'Movies',dc,AnalysisLabelShort];
        if ~exist(MoviesSaveDir)
            mkdir(MoviesSaveDir)
        end
        MoviesScratchDir=[CurrentScratchDir,'Movies',dc,AnalysisLabelShort];
        if ~exist(MoviesScratchDir)
            mkdir(MoviesScratchDir)
        end
        if any(strfind(BoutonSuffix,'Ib'))
            BoutonCount=1;
        elseif any(strfind(BoutonSuffix,'Is'))
            BoutonCount=2;
        else
            BoutonCount=0;
        end
        Safe2CopyDelete=1;
        if strcmp([SaveDir],[CurrentScratchDir])||...
                strcmp([SaveDir],[CurrentScratchDir])||...
                strcmp([SaveDir],[CurrentScratchDir,dc])
            Safe2CopyDelete=0;
            warning('CurrentScratchDir and SaveDir are the same')
        end
        
        
        cont=input(['<ENTER> to perform parameter fix on ',StackSaveName,': ']);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %Load Data
    FileSuffix='_QuaSOR_Data.mat';
    load([SaveDir,StackSaveName,FileSuffix],'QuaSOR_Parameters');
    FileSuffix='_QuaSOR_Maps.mat';
    load([SaveDir,dc,StackSaveName,FileSuffix],'QuaSOR_Map_Settings')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    %fix
    QuaSOR_Parameters.UpScaling.UpScale_CoordinateAdjust=0;
            
    QuaSOR_Map_Settings.QuaSOR_UpScaleFactor=10;
    QuaSOR_Map_Settings.QuaSOR_Gaussian_Filter_SizeBuffer=9;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %Save Data
    FileSuffix='_QuaSOR_Data.mat';
    save([SaveDir,StackSaveName,FileSuffix],'QuaSOR_Parameters','-append');
    clear QuaSOR_Parameters
    FileSuffix='_QuaSOR_Maps.mat';
    save([SaveDir,StackSaveName,FileSuffix],'QuaSOR_Map_Settings','-append');
    clear QuaSOR_Map_Settings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
end
