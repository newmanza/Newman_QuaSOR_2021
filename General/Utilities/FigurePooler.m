function FigurePooler(FigDir,FigName,dc,PooledFormat,PoolingDir,SubDir)
    [upperPath, deepestFolder] = fileparts(FigDir);
    if SubDir
        if strcmp(PoolingDir(length(PoolingDir)),dc)
            PoolingDir=[PoolingDir,deepestFolder];
        else
            PoolingDir=[PoolingDir,dc,deepestFolder];
        end
    end


    if ~exist(FigDir)
        FigDirText=[];
        for i=1:length(FigDir)
            if strcmp(FigDir(i),'\')
                FigDirText=[FigDirText,'/'];
            else
                FigDirText=[FigDirText,FigDir(i)];
            end
        end
        warning on
        warning(['Directory: ',FigDirText,' DOES NOT EXIST!'])
    else
        fprintf(['FigName = ',FigName,PooledFormat,'...'])
        if strcmp(FigDir(length(FigDir)),dc)
            FullPath=[FigDir,FigName,PooledFormat];
        else
            FullPath=[FigDir,dc,FigName,PooledFormat];
        end
        FullPathText=[];
        for i=1:length(FullPath)
            if strcmp(FullPath(i),'\')
                FullPathText=[FullPathText,'/'];
            else
                FullPathText=[FullPathText,FullPath(i)];
            end
        end
        if exist(FullPath)
            if ~exist(PoolingDir)
                mkdir(PoolingDir)
            end
            FileInfo = dir(FullPath);
            TimeStamp = FileInfo.date;
            fprintf(['Found!...(',TimeStamp,')...'])
            fprintf('Copying...')
            [copystatus,copymsg]=copyfile(FullPath,PoolingDir);
            if copystatus
                fprintf('Finished!\n')
            else
                warning on
                fprintf('\n')
                warning(['UNABLE TO COPY! ',FullPathText])
                warning(copymsg)
                cd(FigDir)
%                 if exist([FigName,PooledFormat])
%                     warning('Trying alternate copy strategy')
%                 [copystatus2,copymsg2]=copyfile([FigName,PooledFormat],PoolingDir);
            end
        else
            warning on
            warning('Missing!')
        end
    end
end