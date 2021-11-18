function [FoundCurrentParentDir]=FindCurrentParentDir(CurrentParentDir)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    warning('I currently only have the default parent directories set up for a few folks, but you can add more options here when re-generating fixing lists')
    FoundCurrentParentDir=[];
    if strcmp(CurrentParentDir,'z:\Enterprise Image Analysis 4\')
        FoundCurrentParentDir='ParentDir';
    elseif strcmp(CurrentParentDir,'z:\Enterprise Image Analysis\')
        FoundCurrentParentDir='ParentDir1';
    elseif strcmp(CurrentParentDir,'z:\Enterprise Image Analysis 2\')
        FoundCurrentParentDir='ParentDir2';
    elseif strcmp(CurrentParentDir,'z:\Enterprise Image Analysis 3\')
        FoundCurrentParentDir='ParentDir3';
    elseif strcmp(CurrentParentDir,'U:\Enterprise Image Analysis\')
        FoundCurrentParentDir='DariyaParentDir';
    elseif strcmp(CurrentParentDir,'D:\Enterprise Image Analysis\')
        FoundCurrentParentDir='RyanParentDir';
    else
        warning('Unable to match tthe CurrentParentDir to default options...')
    end
    warning(['FoundCurrentParentDir = ',CurrentParentDir])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
