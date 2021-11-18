    
function WriteImageAndROIs(Image,FileNameAndDir,ROIs)
    OS=computer;
    if strcmp(OS,'MACI64')
        dc='/';
    else
        dc='\';
    end

    if length(FileNameAndDir)>260
        error('Shorten Name and or dir...')
    end
    
    [FileDir,FileName]=fileparts(FileNameAndDir);
    FileExtension=FileNameAndDir(length(FileNameAndDir)-3:length(FileNameAndDir));
    if ~exist(FileDir)
        mkdir(FileDir)
    end
    imwrite(double(Image),FileNameAndDir)


    if ~isempty(ROIs)
        ROIDir=[FileDir,dc,'ROIs'];
        if ~exist(ROIDir)
            mkdir(ROIDir);
        end
        if ~isfield(ROIs,'XCoords')||~isfield(ROIs,'YCoords')
            error('Need to provide crop coords for ROI...')
        else
            
            for x=1:length(ROIs)
                if size(Image,3)>1
                    ROI_Image=Image(ROIs(x).YCoords,ROIs(x).XCoords,:);
                else
                    ROI_Image=Image(ROIs(x).YCoords,ROIs(x).XCoords);
                end
                imwrite(double(ROI_Image),[ROIDir,dc,FileName,' ROI',num2str(x),FileExtension])
                clear ROI_Image

            end
            
        end
        
        
    end
