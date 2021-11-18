%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Directories
CurrentSaveDir=[LoadDir,dc,ModalitySuffix,BoutonSuffix,dc];
CurrentSaveDir1=[LoadDir,dc,ModalitySuffix,dc];
CurrentSaveDir2=[LoadDir,dc];
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
FigureSaveDir=[CurrentSaveDir,'Figures',dc,AnalysisLabelShort];
if ~exist(FigureSaveDir)
    error('Missing FigureSaveDir')
end
FigureScratchDir=[CurrentScratchDir,'Figures',dc,AnalysisLabelShort];
if ~exist(FigureScratchDir)
    mkdir(FigureScratchDir)
end
if CheckingMode==1
    MoviesSaveDir=[CurrentSaveDir,'Movies',dc,AnalysisLabelShort];
    if ~exist(MoviesSaveDir)
        error('Missing MoviesSaveDir')
    end
    MoviesScratchDir=[CurrentScratchDir,'Movies',dc,AnalysisLabelShort];
    if ~exist(MoviesScratchDir)
        mkdir(MoviesScratchDir)
    end
end
if any(strfind(BoutonSuffix,'Ib'))
    BoutonCount=1;
elseif any(strfind(BoutonSuffix,'Is'))
    BoutonCount=2;
else
    BoutonCount=0;
end
Safe2CopyDelete=1;
if strcmp([CurrentSaveDir],[CurrentScratchDir])||...
        strcmp([CurrentSaveDir,dc],[CurrentScratchDir])||...
        strcmp([CurrentSaveDir],[CurrentScratchDir,dc])
    Safe2CopyDelete=0;
    warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
    warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
    warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
    warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
    warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
    warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
    warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
    warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
    warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
    warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
    warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
    warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
    warning('CurrentSaveDir and CurrentScratchDir are the same WILL NOT COPY AND DELETE')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%Parameters
PlayBackFPS=[];
MoviePlayBackScaleFactor=1;
MoviePreload=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
if CheckingMode==1
    MovieInfo=dir(MoviesSaveDir);
    NumMovies=length(MovieInfo);
    if NumMovies>0
        MovieList=[];
        MovieIndex=[];
        count=1;
        MovieList{count}='Finished!';
        fprintf(['Copying Movies to ScratchDir']);
        for movie=1:NumMovies
            if any(strfind(MovieInfo(movie).name,'.avi'))
                count=count+1;
                MovieList{count}=MovieInfo(movie).name;
                MovieIndex(count)=movie;
                fprintf('.')
                if ~exist([MoviesScratchDir,dc,MovieInfo(movie).name])
                    copyfile([MoviesSaveDir,dc,MovieInfo(movie).name],MoviesScratchDir)
                end
            end
        end
        fprintf('Finished!\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        CheckingRec=1;
        while CheckingRec
            [MovieChoice, checking] = listdlg('PromptString','Select a Movie:','SelectionMode','single','ListString',MovieList,'ListSize', [800 600]);
            if MovieChoice==1
                CheckingRec=0;
            else
                try
                    Zach_AVI_Player([MoviesScratchDir,dc],MovieInfo(MovieIndex(MovieChoice)).name,MoviePlayBackScaleFactor,MoviePreload,PlayBackFPS)
                catch
                    warning on
                    warning(['Unable to open: ',MovieInfo(MovieIndex(MovieChoice)).name]);
                    warning off
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    else
        error('No Movies!')
    end
elseif CheckingMode==2
    error('Not Ready Yet')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
