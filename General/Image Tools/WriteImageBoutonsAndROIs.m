    
function WriteImageBoutonsAndROIs(Image,FileNameAndDir,BoutonROIArray,MaskBouton,ROIs)
    OS=computer;
    if strcmp(OS,'MACI64')
        dc='/';
    else
        dc='\';
    end

    if length(FileNameAndDir)>260
        error('Shorten Name and or dir...')
    end
    

%     Image=double(TempContrastedImageColor);
%     FileNameAndDir=[ImageSaveDir,dc,ImageSaveName,'.tif']
%     BoutonROIArray=QuaSOR_Aligned_BoutonArray
%     MaskBouton=0
%     ROIs=STORM_EHR_ROI_Struct
% 
%                         WriteImageBoutonsAndROIs(double(TempContrastedImageColor),[ImageSaveDir,dc,ImageSaveName,'.tif'],...
%                             QuaSOR_Aligned_BoutonArray,1,STORM_EHR_ROI_Struct)

    if size(Image,3)<3
        error('Need to feed this an RGB image right now...')
    end
    [FileDir,FileName]=fileparts(FileNameAndDir);
    FileExtension=FileNameAndDir(length(FileNameAndDir)-3:length(FileNameAndDir));
    if ~exist(FileDir)
        mkdir(FileDir)
    end
    imwrite(double(Image),FileNameAndDir)
    if ~isempty(BoutonROIArray)
        for Bouton=1:length(BoutonROIArray)
            if ~isempty(BoutonROIArray)
                BoutDir=[FileDir,dc,BoutonROIArray(Bouton).Label];
                if ~exist(BoutDir)
                    mkdir(BoutDir);
                end
                if ~isfield(BoutonROIArray,'XCoords')||~isfield(BoutonROIArray,'YCoords')
                    error('Need to provide crop coords for BoutonROIArray...')
                else
                    TempXCoords1=BoutonROIArray(Bouton).XCoords;
                    TempXCoords1(TempXCoords1<1)=NaN;
                    TempXCoords1(TempXCoords1>size(Image,2))=NaN;
                    TempXCoords=[];
                    for i=1:length(TempXCoords1)
                        if ~isnan(TempXCoords1(i))
                            TempXCoords=[TempXCoords,TempXCoords1(i)];
                        end
                    end
                    TempYCoords1=BoutonROIArray(Bouton).YCoords;
                    TempYCoords1(TempYCoords1<1)=NaN;
                    TempYCoords1(TempYCoords1>size(Image,1))=NaN;
                    TempYCoords=[];
                    for i=1:length(TempYCoords1)
                        if ~isnan(TempYCoords1(i))
                            TempYCoords=[TempYCoords,TempYCoords1(i)];
                        end
                    end
                    %Image_Crop=imcrop(Image,BoutonROIArray(Bouton).Crop_Props.BoundingBox);
                    if ~isempty(TempXCoords)
                        Image_Crop=Image(TempYCoords,TempXCoords,:);
                        if MaskBouton
                            %Mask_Crop=imcrop(BoutonROIArray(Bouton).Mask,BoutonROIArray(Bouton).Crop_Props.BoundingBox);
                            Mask_Crop=BoutonROIArray(Bouton).Mask(TempYCoords,TempXCoords);
                            Image_Crop=single(ColorMasking(Image_Crop,...
                                ~Mask_Crop,BoutonROIArray(Bouton).MaskingColor));
                            imwrite(double(Image_Crop),[BoutDir,dc,FileName,' ',BoutonROIArray(Bouton).Label,' ONLY.tif'])
                        else
                            imwrite(double(Image_Crop),[BoutDir,dc,FileName,' ',BoutonROIArray(Bouton).Label,' ONLY.tif'])
                        end
                    end
                end
            end
        end
    end
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
