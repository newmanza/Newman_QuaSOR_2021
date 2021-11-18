function [ImageArray,MetaData]=CZI_Importer(FileName)

    TempMeta=czifinfo(FileName);
    MetaData = GetOMEData(FileName);

    if any(strfind(TempMeta.genInfo.pixelType,'16'))
        MetaData.BitDepth=16;
    elseif any(strfind(TempMeta.genInfo.pixelType,'8'))
        MetaData.BitDepth=8;
    end
    if MetaData.BitDepth==16
        ImageArray=zeros(MetaData.SizeY,MetaData.SizeX,MetaData.SizeZ,MetaData.SizeC,'uint16');
    elseif MetaData.BitDepth==8
        ImageArray=zeros(MetaData.SizeY,MetaData.SizeX,MetaData.SizeZ,MetaData.SizeC,'uint8');
    end
    if MetaData.SizeT==1
        warning('Not loading time series!')
        t=1;
        fprintf('Loading Data...')
        warning off
        f = waitbar(0,'Loading CZI Data Please wait...');
        ImageCount=MetaData.SizeZ*MetaData.SizeC;
        Count=0;
        for z=1:MetaData.SizeZ
            for c=1:MetaData.SizeC
                warning off
                ImageArray(:,:,z,c)=imreadBF(FileName,z,t,c);
                Count=Count+1;
                waitbar(Count/ImageCount,f,'Loading CZI Data Please wait...');
            end
        end
        fprintf('Finished!\n')
        waitbar(1,f,['Finished!']);
        close(f)
    else
        
        error('I dont yet have the Timeseries import set up')
    
    end
    warning on
end