% SearchDir=ParentDir3
% Destination=['Z:\Temporary QuaSOR File Backup'];
SearchString='_MiniEvoked_SOQA_Data2.mat'
SearchDir='/Volumes/Time Machine Backup/Enterprise Image Analysis 3/'
Destination='/Volumes/Zach/Temporary QuaSOR File Backup/'
function Search_and_Destroy_or_Save(SearchDir,SearchString,Destination)
    %Note this currently only searches 3 folders deep

    OS=computer;
    if strcmp(OS,'MACI64')
        dc='/';
    else
        dc='\';
    end

    if isempty(Destination)
        warning(['This will delete all files containing: ',SearchString,' in the Directory: ',SearchDir])
        warning(['This will delete all files containing: ',SearchString,' in the Directory: ',SearchDir])
        warning(['This will delete all files containing: ',SearchString,' in the Directory: ',SearchDir])
        warning(['This will delete all files containing: ',SearchString,' in the Directory: ',SearchDir])
        Confirm=input('Type: DELETE to proceed:');
        if strcmp(Confirm,'DELETE')
           DeleteMode=1;
        else
            DeleteMode=0;
            return
        end
    else    
        DeleteMode=0;
        if ~exist(Destination)
            mkdir(Destination)
        end
    end
    FoundFiles=[];
    FoundDirectories=[];
    FoundCount=0;
    InputFolderList1=dir(SearchDir);
    progressbar('Folder','File')
    fprintf('Searching...')
    for FolderNum1=1:length(InputFolderList1)
        if InputFolderList1(FolderNum1).isdir
            TempDir1=[InputFolderList1(FolderNum1).folder,dc,InputFolderList1(FolderNum1).name];
            TempFileList1=dir(TempDir1);
            for FileNum1=1:length(TempFileList1)
                progressbar(FolderNum1/length(InputFolderList1),FileNum1/length(TempFileList1))
                if ~TempFileList1(FileNum1).isdir
                    if any(strfind(TempFileList1(FileNum1).name,SearchString))
                        FoundCount=FoundCount+1;
                        FoundFiles{FoundCount}=TempFileList1(FileNum1).name;
                        FoundDirectories{FoundCount}=TempFileList1(FileNum1).folder;
                    end
                else
                    
                    
                end
            end
        end
    end
    fprintf(['Finished! Found: ',num2str(FoundCount),' Files!\n'])
    
    if ~DeleteMode
        disp('==========================')
        disp('Copying Files...')
        progressbar('File')
        for File2Copy=1:FoundCount
            progressbar(File2Copy/FoundCount)
            if exist([FoundDirectories{File2Copy},dc,FoundFiles{File2Copy}])
                fprintf(['Copying File #',num2str(File2Copy),': ',FoundFiles{File2Copy},'...']);
                [CopyStatus,CopyMessage]=copyfile([FoundDirectories{File2Copy},dc,FoundFiles{File2Copy}],Destination);
                if CopyStatus
                    fprintf('Finished!\n')
                else
                    warning('Problem Copying!')
                end
            end
        end
        disp('==========================')
        disp('Validating Files...')
        for File2Copy=1:FoundCount
            fprintf(['Original File #',num2str(File2Copy),': ',FoundFiles{File2Copy},'...']);
            if exist([FoundDirectories{File2Copy},dc,FoundFiles{File2Copy}])
                fprintf('Found!\n')
            else
                warning('Missing!')
            end
            fprintf(['New File      #',num2str(File2Copy),': ',FoundFiles{File2Copy},'...']);
            if exist([Destination,FoundFiles{File2Copy}])
                fprintf('Found!\n')
            else
                warning('Missing!')
            end
        end
    else
        warning('Deleting isnt set up yet!')
        warning('Deleting isnt set up yet!')
        warning('Deleting isnt set up yet!')
        warning('Deleting isnt set up yet!')
        warning('Deleting isnt set up yet!')
        warning('Deleting isnt set up yet!')
        warning('Deleting isnt set up yet!')
        warning('Deleting isnt set up yet!')
        warning('Deleting isnt set up yet!')
    end
    
    
    
end