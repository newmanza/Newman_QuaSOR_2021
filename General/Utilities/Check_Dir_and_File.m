function ValidFullPath=Check_Dir_and_File(InputFileDir,InputFileName,LengthLim,ForceFix)
    if ~exist(InputFileDir)
        mkdir(InputFileDir)
    end
    OS=computer;
    if strcmp(OS,'MACI64')
        dc='/';
        if strcmp(InputFileDir(length(InputFileDir)),dc)
            FullPath=[InputFileDir,InputFileName];
        else
            InputFileDir=[InputFileDir,dc];
            FullPath=[InputFileDir,InputFileName];
        end
        ValidFileDir=InputFileDir;
        ValidFileName=InputFileName;
    else
        dc='\';
        if strcmp(InputFileDir(length(InputFileDir)),dc)
            FullPath=[InputFileDir,InputFileName];
        else
            InputFileDir=[InputFileDir,dc];
            FullPath=[InputFileDir,InputFileName];
        end
        PathLength=length(FullPath);
        FileType=InputFileName(length(InputFileName)-3:length(InputFileName));
        if ~strcmp(FileType(1),'.')
            FileType=InputFileName(length(InputFileName)-1:length(InputFileName));
            FileExtension=0;
        else
            FileExtension=1;
        end
        if ~strcmp(FileType(1),'.')
            FileType=[];
            FileExtension=0;
        else
            FileExtension=1;
        end
        if FileExtension
            if ~exist('LengthLim')
                LengthLim=259;
            end
            if isempty(LengthLim)
                LengthLim=259;
            end
        else
            if ~exist('LengthLim')
                LengthLim=255;
            end
            if isempty(LengthLim)
                LengthLim=255;
            end
        end
        LengthDif=PathLength-LengthLim;
        if PathLength>LengthLim&&ForceFix~=0
            warning on
            fprintf('\n')
            warning(['Current Path length is ',num2str(PathLength),' so I will try to fix so that the windows wont have a problem'])
            if ForceFix==1
                warning(['Deleting ',num2str(LengthDif),' Characters from the front of the file name...'])
                ValidFileDir=InputFileDir;
                ValidFileName=InputFileName(LengthDif+1:length(InputFileName));
            elseif ForceFix==2
                warning(['Deleting ',num2str(LengthDif),' Characters from the front of the file name...'])
                ValidFileDir=InputFileDir;
                InputFileName=InputFileName(1:length(InputFileName)-length(FileType));
                ValidFileName=[InputFileName(1:length(InputFileName)-LengthDif),FileType];
            end
        else    
            ValidFileDir=InputFileDir;
            ValidFileName=InputFileName;
        end
    end
    ValidFullPath=[ValidFileDir,ValidFileName];
end